unit RuntimeComponents;

interface

uses Vcl.Forms;

function PlaybackPluginsInstalled: Boolean;
function PlaybackPluginsPath: string;
procedure ApplyPendingComponents;
procedure ShowRuntimeComponents(Owner: TForm);

implementation

uses System.Classes, System.SysUtils, System.IOUtils, System.Zip, System.JSON,
  System.Hash, System.RegularExpressions, System.Net.HttpClient, Winapi.Windows,
  Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, CurvedControls, PlayerDialogs, LibVLC, PlayerPaths;

const
  ReleaseAPI = 'https://api.github.com/repos/Diagoo1/VLC-Modern/releases/tags/components-v1';
  DownloadBase = 'https://github.com/Diagoo1/VLC-Modern/releases/download/components-v1/';
  PluginsAsset = 'VLC-Modern-LibVLC3-971959D4-x86-Plugins.zip';
  EncoderAsset = 'VLC-Modern-FFmpeg-Windows-x64.zip';

function AppPath(const Name: string): string;
begin
  Result := PlayerDataPath(Name);
end;

function HasPlaybackPlugins(const Folder: string): Boolean;
begin
  Result := TDirectory.Exists(TPath.Combine(Folder, 'codec')) and
    TDirectory.Exists(TPath.Combine(Folder, 'audio_output')) and
    TDirectory.Exists(TPath.Combine(Folder, 'video_output'));
end;

function PlaybackPluginsInstalled: Boolean;
begin
  Result := HasPlaybackPlugins(PlaybackPluginsPath);
end;

function PlaybackPluginsPath: string;
begin
  Result := ComponentPath('plugins');
  if not HasPlaybackPlugins(Result) then
    Result := BundledPath('plugins-basic');
end;

procedure ApplyPendingComponents;
var Current, Pending, Backup: string;
begin
  Current := AppPath('plugins');
  Pending := AppPath('plugins.pending');
  Backup := AppPath('maintenance\plugins-rollback');

  // Recover an interrupted swap before considering a staged update again.
  if not TDirectory.Exists(Current) and HasPlaybackPlugins(Backup) then
  begin
    TDirectory.Move(Backup, Current);
    Exit;
  end;

  if not TDirectory.Exists(Pending) then Exit;
  if not HasPlaybackPlugins(Pending) or
     not TFile.Exists(TPath.Combine(Pending, '.release-digest')) then
    raise Exception.Create('The staged plugin update is incomplete. The installed set was kept.');

  if TDirectory.Exists(Current) then
  begin
    TDirectory.CreateDirectory(TPath.GetDirectoryName(Backup));
    if TDirectory.Exists(Backup) then TDirectory.Delete(Backup, True);
    TDirectory.Move(Current, Backup);
  end;
  try
    TDirectory.Move(Pending, Current);
  except
    if HasPlaybackPlugins(Backup) and not TDirectory.Exists(Current) then
      TDirectory.Move(Backup, Current);
    raise;
  end;
end;

type
  TComponentProgress = reference to procedure(const Message: string; Percent: Integer);
  TDownloadMeter = class
    Progress: TComponentProgress;
    LastPercent: Integer;
    procedure Receive(const Sender: TObject; AContentLength, AReadCount: Int64;
      var AAbort: Boolean);
  end;

procedure TDownloadMeter.Receive(const Sender: TObject; AContentLength, AReadCount: Int64;
  var AAbort: Boolean);
begin
  if AContentLength <= 0 then Exit;
  if AReadCount > AContentLength then
  begin
    AAbort := True;
    Exit;
  end;
  var Percent := Integer(AReadCount * 100 div AContentLength);
  if (Percent < LastPercent + 5) and (Percent <> 100) then Exit;
  LastPercent := Percent;
  Progress('Downloading', Percent);
end;

function MatchesRevision(const Stamp, Digest: string): Boolean;
begin
  Result := TFile.Exists(Stamp) and SameText(Trim(TFile.ReadAllText(Stamp)), Digest);
end;

function RevisionText(const Stamp: string): string;
begin
  if not TFile.Exists(Stamp) then Exit('local build');
  var Digest := Trim(TFile.ReadAllText(Stamp));
  if not TRegEx.IsMatch(Digest, '^sha256:[0-9a-fA-F]{64}$') then Exit('local build');
  Result := Copy(Digest, 8, 8);
end;

function StageComponent(Client: THTTPClient; Assets: TJSONArray; Plugins: Boolean;
  const Progress: TComponentProgress): string;
var Name, Digest, Stamp, Archive, Stage, Target, Entry, Path: string;
    Asset: TJSONObject; Response: IHTTPResponse; Bytes, Size: Int64;
    Output: TFileStream; Zip: TZipFile; HasEncoder: Boolean; Meter: TDownloadMeter;
begin
  if Plugins then
  begin
    Name := PluginsAsset;
    Target := AppPath('plugins.pending');
    if not SameText(THashSHA2.GetHashStringFromFile(BundledPath('libvlc.dll')),
      '971959D423C31A9FC414F5E8040DACE63254A39E894B544E9F4D551D5321705B') then
      raise Exception.Create('The plugin package is for a different LibVLC build.');
  end
  else
  begin
    Name := EncoderAsset;
    Target := AppPath('tools');
  end;
  Asset := nil;
  for var Value in Assets do
    if (Value is TJSONObject) and SameText(TJSONObject(Value).GetValue<string>('name', ''), Name) then
    begin
      Asset := TJSONObject(Value);
      Break;
    end;
  if Asset = nil then raise Exception.Create('Package is unavailable on GitHub: ' + Name);
  Digest := Asset.GetValue<string>('digest', '');
  Size := Asset.GetValue<Int64>('size', 0);
  if not TRegEx.IsMatch(Digest, '^sha256:[0-9a-fA-F]{64}$') or
     (Size <= 0) or (Size > 160 * 1024 * 1024) then
    raise Exception.Create('The release package could not be verified.');
  if Plugins then Stamp := ComponentPath('plugins\.release-digest')
  else Stamp := TPath.Combine(TPath.GetDirectoryName(ComponentPath('tools\ffmpeg.exe')),
    '.ffmpeg-release-digest');
  if MatchesRevision(Stamp, Digest) and
     ((Plugins and PlaybackPluginsInstalled) or
      (not Plugins and TFile.Exists(ComponentPath('tools\ffmpeg.exe')))) then Exit('Up to date');
  if Plugins and TDirectory.Exists(Target) then
  begin
    if MatchesRevision(TPath.Combine(Target, '.release-digest'), Digest) then
      Exit('Ready after restart');
    raise Exception.Create('Restart VLC Modern before staging another plugin version.');
  end;
  Progress('Downloading', 0);
  Stage := AppPath('.components-' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Stage);
  Archive := TPath.Combine(Stage, 'download.zip');
  try
    Output := TFileStream.Create(Archive, fmCreate);
    try
      Meter := TDownloadMeter.Create;
      try
        Meter.Progress := Progress;
        Client.OnReceiveData := Meter.Receive;
        Response := Client.Get(DownloadBase + Name, Output);
        Bytes := Output.Size;
      finally
        Client.OnReceiveData := nil;
        Meter.Free;
      end;
    finally Output.Free; end;
    Progress('Verifying and unpacking', 100);
    if (Response.StatusCode <> 200) or (Bytes <> Size) or
       not SameText('sha256:' + THashSHA2.GetHashStringFromFile(Archive), Digest) then
      raise Exception.Create('Package download failed verification.');
    Path := TPath.Combine(Stage, 'payload');
    TDirectory.CreateDirectory(Path);
    Zip := TZipFile.Create;
    try
      Zip.Open(Archive, zmRead);
      Bytes := 0;
      HasEncoder := False;
      for var I := 0 to Zip.FileCount - 1 do
      begin
        Entry := StringReplace(Zip.FileNames[I], '\', '/', [rfReplaceAll]);
        if Entry.EndsWith('/') then Continue;
        if Plugins then
        begin
          if not SameText(Entry, 'plugins.dat') and
             not TRegEx.IsMatch(Entry, '^[a-zA-Z0-9_]+/[a-zA-Z0-9_-]+\.dll$') and
             not TRegEx.IsMatch(Entry, '^access/libbluray-(awt-)?j2se-[0-9.]+\.jar$') then
            raise Exception.Create('Unexpected plugin file: ' + Entry);
        end
        else if SameText(Entry, 'ffmpeg.exe') then HasEncoder := True
        else if not TRegEx.IsMatch(Entry, '^FFmpeg-[a-zA-Z0-9_-]+\.txt$') then
          raise Exception.Create('Unexpected FFmpeg file: ' + Entry);
        Inc(Bytes, Zip.FileInfo[I].UncompressedSize);
        if Bytes > 260 * 1024 * 1024 then raise Exception.Create('Package is too large.');
        Zip.Extract(I, Path, True);
      end;
    finally Zip.Free; end;
    if Plugins then
    begin
      if not TDirectory.Exists(TPath.Combine(Path, 'codec')) or
         not TDirectory.Exists(TPath.Combine(Path, 'audio_output')) or
         not TDirectory.Exists(TPath.Combine(Path, 'video_output')) then
        raise Exception.Create('The plugin package is incomplete.');
      TFile.WriteAllText(TPath.Combine(Path, '.release-digest'), Digest);
      if TDirectory.Exists(Target) then
        raise Exception.Create('A plugin update is already staged. Restart the player first.');
      TDirectory.Move(Path, Target);
      Result := 'Ready after restart';
    end
    else
    begin
      if not HasEncoder then raise Exception.Create('FFmpeg executable is missing.');
      TDirectory.CreateDirectory(Target);
      for var FileName in TDirectory.GetFiles(Path) do
        if not MoveFileEx(PChar(FileName), PChar(TPath.Combine(Target, TPath.GetFileName(FileName))),
          MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
      TFile.WriteAllText(TPath.Combine(Target, '.ffmpeg-release-digest'), Digest);
      Result := 'Installed';
    end;
  finally
    TDirectory.Delete(Stage, True);
  end;
end;

type
  TComponentsDialog = class(TForm)
  private
    Plugins, Encoder: TCheckBox;
    Status, PluginInfo, EncoderInfo: TLabel;
    ProgressBar: TProgressBar;
    SyncButton, CloseButton: TButton;
    Busy: Boolean;
    procedure RefreshVersions;
    procedure PostProgress(const Component, Message: string; Percent: Integer);
    procedure Sync(Sender: TObject);
    procedure CanCloseDialog(Sender: TObject; var CanClose: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TComponentsDialog.Create(AOwner: TComponent);
  function AddLabel(const Text: string; X, Y: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Self;
    Result.SetBounds(X, Y, 600, 22);
    Result.Caption := Text;
  end;
  function AddChoice(const Text, Description: string; Y: Integer; Checked: Boolean): TCheckBox;
  begin
    Result := TCheckBox.Create(Self);
    Result.Parent := Self;
    Result.SetBounds(24, Y, 560, 25);
    Result.Caption := Text;
    Result.Checked := Checked;
    AddLabel(Description, 45, Y + 29);
  end;
  function AddButton(const Text: string; X: Integer): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := Self;
    Result.SetBounds(X, 326, 145, 34);
    Result.Caption := Text;
  end;
begin
  inherited CreateNew(AOwner);
  Caption := 'Playback Components';
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;
  ClientWidth := 650;
  ClientHeight := 380;
  AddLabel('Select components to install or synchronize from VLC Modern on GitHub.', 24, 22);
  Plugins := AddChoice('LibVLC playback plugins',
    'Adds the complete LibVLC playback and streaming plugin set.',
    62, not HasPlaybackPlugins(ComponentPath('plugins')));
  Encoder := AddChoice('FFmpeg (64-bit Windows)',
    'Enables precise MP4 clipping with frame-accurate start positions.',
    151, False);
  Encoder.Enabled := TOSVersion.Architecture = arIntelX64;
  PluginInfo := AddLabel('', 45, 111);
  EncoderInfo := AddLabel('', 45, 200);
  ProgressBar := TProgressBar.Create(Self);
  ProgressBar.Parent := Self;
  ProgressBar.SetBounds(24, 245, 600, 9);
  ProgressBar.Max := 100;
  Status := AddLabel('', 24, 265);
  Status.AutoSize := False;
  Status.WordWrap := True;
  Status.Height := 44;
  SyncButton := AddButton('Synchronize', 323);
  SyncButton.OnClick := Sync;
  CloseButton := AddButton('Close', 480);
  CloseButton.Cancel := True;
  CloseButton.ModalResult := mrCancel;
  OnCloseQuery := CanCloseDialog;
  ApplyPlayerAppearance(Self);
  PluginInfo.Font.Color := DP_COLOR_MUTED;
  EncoderInfo.Font.Color := DP_COLOR_MUTED;
  RefreshVersions;
end;

procedure TComponentsDialog.RefreshVersions;
begin
  var Engine := 'LibVLC';
  if IsLibVLCLoaded and Assigned(libvlc_get_version) then
  begin
    var Match := TRegEx.Match(string(libvlc_get_version()), '^[0-9]+(?:\.[0-9]+)+');
    if Match.Success then Engine := Engine + ' ' + Match.Value;
  end;
  if HasPlaybackPlugins(ComponentPath('plugins')) then
    PluginInfo.Caption := Engine + '  |  Installed  |  Revision ' +
      RevisionText(ComponentPath('plugins\.release-digest'))
  else if PlaybackPluginsInstalled then
    PluginInfo.Caption := Engine + '  |  Basic playback included'
  else PluginInfo.Caption := Engine + '  |  Not installed';
  if TDirectory.Exists(AppPath('plugins.pending')) then
    PluginInfo.Caption := PluginInfo.Caption + '  |  Restart required';
  if TFile.Exists(ComponentPath('tools\ffmpeg.exe')) then
  begin
    var Version := 'FFmpeg';
    var EncoderDirectory := TPath.GetDirectoryName(ComponentPath('tools\ffmpeg.exe'));
    var Notice := TPath.Combine(EncoderDirectory, 'FFmpeg-NOTICE.txt');
    if TFile.Exists(Notice) then
    begin
      var Match := TRegEx.Match(TFile.ReadAllText(Notice), '^FFmpeg [0-9]+(?:\.[0-9]+)+');
      if Match.Success then Version := Match.Value;
    end;
    EncoderInfo.Caption := Version + '  |  Installed  |  Revision ' +
      RevisionText(TPath.Combine(EncoderDirectory, '.ffmpeg-release-digest'));
  end
  else EncoderInfo.Caption := 'FFmpeg  |  Not installed';
end;

procedure TComponentsDialog.PostProgress(const Component, Message: string; Percent: Integer);
begin
  TThread.Queue(nil, TThreadProcedure(
    procedure
    begin
      Status.Caption := Component + '  |  ' + Message + '  ' + IntToStr(Percent) + '%';
      ProgressBar.Position := Percent;
    end));
end;

procedure TComponentsDialog.CanCloseDialog(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Busy;
end;

procedure TComponentsDialog.Sync(Sender: TObject);
begin
  var WantPlugins := Plugins.Checked;
  var WantEncoder := Encoder.Checked and Encoder.Enabled;
  if not WantPlugins and not WantEncoder then
  begin
    Status.Caption := 'Select at least one component.';
    Exit;
  end;
  Busy := True;
  Plugins.Enabled := False;
  Encoder.Enabled := False;
  SyncButton.Enabled := False;
  CloseButton.Enabled := False;
  ProgressBar.Position := 0;
  Status.Caption := 'Checking GitHub for component updates...';
  TThread.CreateAnonymousThread(
    procedure
    var Client: THTTPClient; Response: IHTTPResponse; Catalog: TJSONValue;
        ResultText: string;
    begin
      Client := THTTPClient.Create;
      try
        try
          Client.UserAgent := 'VLCModern';
          Client.ConnectionTimeout := 10000;
          Client.ResponseTimeout := 30000;
          Response := Client.Get(ReleaseAPI);
          if Response.StatusCode <> 200 then raise Exception.Create('GitHub is currently unavailable.');
          Catalog := TJSONObject.ParseJSONValue(Response.ContentAsString);
          try
            if not (Catalog is TJSONObject) then raise Exception.Create('Invalid release information.');
            var Assets := TJSONObject(Catalog).GetValue<TJSONArray>('assets');
            if Assets = nil then raise Exception.Create('The release contains no packages.');
            ResultText := '';
            if WantPlugins then
              ResultText := 'LibVLC: ' + StageComponent(Client, Assets, True,
                procedure(const Message: string; Percent: Integer)
                begin PostProgress('LibVLC plugins', Message, Percent); end);
            if WantEncoder then
            begin
              if ResultText <> '' then ResultText := ResultText + sLineBreak;
              ResultText := ResultText + 'FFmpeg: ' + StageComponent(Client, Assets, False,
                procedure(const Message: string; Percent: Integer)
                begin PostProgress('FFmpeg', Message, Percent); end);
            end;
          finally Catalog.Free; end;
        except
          on E: Exception do ResultText := E.Message;
        end;
      finally Client.Free; end;
      TThread.Queue(nil, TThreadProcedure(
        procedure
        begin
          RefreshVersions;
          ProgressBar.Position := 0;
          Status.Caption := ResultText;
          Busy := False;
          Plugins.Enabled := True;
          Encoder.Enabled := TOSVersion.Architecture = arIntelX64;
          SyncButton.Enabled := True;
          CloseButton.Enabled := True;
        end));
    end).Start;
end;

procedure ShowRuntimeComponents(Owner: TForm);
begin
  with TComponentsDialog.Create(Owner) do
    try ShowModal; finally Free; end;
end;

end.
