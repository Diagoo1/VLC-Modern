unit AboutForm;

interface

uses System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, System.Threading, CurvedControls;

type
  TFrmAbout = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FUpdate: IFuture<string>;
    FUpdateTimer: TTimer;
    FUpdateButton: TPlayerTextButton;
    FUpdateStatus: TLabel;
    FUpdateTrack, FUpdateFill: TShape;
    FUpdateFile, FUpdateTag: string;
    FUpdateBytes: Int64;
    FUpdateProgress: TArray<Integer>;
    procedure StartUpdateDownload(const URL, Digest: string);
    procedure CanCloseDuringUpdate(Sender: TObject; var CanClose: Boolean);
    procedure DragSurface(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckUpdate(Sender: TObject);
    procedure UpdateFinished(Sender: TObject);
    procedure OpenLink(Sender: TObject);
    procedure OpenShortcuts(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

uses Winapi.Windows, Winapi.ShellAPI, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.Messages, System.Types, System.SysUtils, System.JSON, System.Net.HttpClient, System.Hash,
  System.IOUtils, System.Win.Registry, System.SyncObjs, Vcl.Graphics,
  PlayerDialogs, MainForm, PlayerLanguage;

{$R *.dfm}

procedure TFrmAbout.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

const
  Links: array[0..4] of string = (
    'https://github.com/Diagoo1/VLC-Modern',
    'https://github.com/Diagoo1',
    'https://paypal.me/Diagoo1',
    'mailto:tarek.sadek44@gmail.com',
    'https://github.com/Diagoo1/VLC-Modern/issues/new');

type
  TAboutArtwork = class(TGraphicControl)
  private
    FSource: IStream;
    FImage, FRendered: TGPBitmap;
    FFramed: Boolean;
    procedure RenderArtwork;
  protected
    procedure Paint; override;
  public
    constructor CreateResource(AOwner: TComponent; const ResourceName: string;
      Framed: Boolean);
    destructor Destroy; override;
  end;

constructor TAboutArtwork.CreateResource(AOwner: TComponent;
  const ResourceName: string; Framed: Boolean);
begin
  inherited Create(AOwner);
  FFramed := Framed;
  FSource := TStreamAdapter.Create(
    TResourceStream.Create(HInstance, ResourceName, RT_RCDATA), soOwned);
  FImage := TGPBitmap.Create(FSource);
end;

destructor TAboutArtwork.Destroy;
begin
  FRendered.Free;
  FImage.Free;
  FSource := nil;
  inherited;
end;

procedure TAboutArtwork.RenderArtwork;
const
  QualityScale = 3;
var
  HiRes: TGPBitmap;
  Graphics: TGPGraphics;
  Frame: TGPLinearGradientBrush;
  Mask: TGPGraphicsPath;
  W, H, Inset: Integer;
begin
  FreeAndNil(FRendered);
  W := Width * QualityScale;
  H := Height * QualityScale;
  HiRes := TGPBitmap.Create(W, H, PixelFormat32bppPARGB);
  try
    Graphics := TGPGraphics.Create(HiRes);
    try
      Graphics.Clear(0);
      Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
      Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      Inset := 0;
      if FFramed then
      begin
        Frame := TGPLinearGradientBrush.Create(MakeRect(0, 0, W, H),
          MakeColor(255, 96, 205, 255), MakeColor(255, 23, 58, 89),
          LinearGradientModeForwardDiagonal);
        try
          Graphics.FillEllipse(Frame, 3, 3, W - 6, H - 6);
        finally
          Frame.Free;
        end;
        Inset := MulDiv(4, CurrentPPI, 96) * QualityScale;
        Mask := TGPGraphicsPath.Create;
        try
          Mask.AddEllipse(Inset, Inset, W - 2 * Inset, H - 2 * Inset);
          Graphics.SetClip(Mask);
        finally
          Mask.Free;
        end;
      end;
      Graphics.DrawImage(FImage, Inset, Inset, W - 2 * Inset, H - 2 * Inset);
    finally
      Graphics.Free;
    end;
    FRendered := TGPBitmap.Create(Width, Height, PixelFormat32bppPARGB);
    Graphics := TGPGraphics.Create(FRendered);
    try
      Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      Graphics.DrawImage(HiRes, 0, 0, Width, Height);
    finally
      Graphics.Free;
    end;
  finally
    HiRes.Free;
  end;
end;

procedure TAboutArtwork.Paint;
var
  Graphics: TGPGraphics;
begin
  if (FImage = nil) or (Width < 10) or (Height < 10) then Exit;
  if (FRendered = nil) or (Integer(FRendered.GetWidth) <> Width) or
    (Integer(FRendered.GetHeight) <> Height) then RenderArtwork;
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.DrawImage(FRendered, 0, 0);
  finally
    Graphics.Free;
  end;
end;

procedure TFrmAbout.CheckUpdate(Sender: TObject);
begin
  if FUpdate <> nil then Exit;
  FUpdateStatus.Caption := Translate('Checking GitHub for updates...');
  FUpdate := TTask.Future<string>(
    function: string
    var
      Client: THTTPClient;
      Response: IHTTPResponse;
    begin
      Result := '';
      try
        Client := THTTPClient.Create;
        try
          Client.ConnectionTimeout := 5000;
          Client.ResponseTimeout := 5000;
          Client.UserAgent := 'VLC-Modern';
          Response := Client.Get('https://api.github.com/repos/Diagoo1/VLC-Modern/releases/latest');
          if Response.StatusCode = 200 then Result := Response.ContentAsString;
        finally
          Client.Free;
        end;
      except
        Result := '';
      end;
    end);
  FUpdateTimer.Enabled := True;
end;

function RunningVersionTag: string;
var
  Size, Ignored, InfoSize: DWORD;
  Data: TBytes;
  Info: PVSFixedFileInfo;
  FileName: string;
begin
  Result := '';
  FileName := Application.ExeName;
  Size := GetFileVersionInfoSize(PChar(FileName), Ignored);
  if Size = 0 then Exit;
  SetLength(Data, Size);
  if not GetFileVersionInfo(PChar(FileName), 0, Size, @Data[0]) then Exit;
  if not VerQueryValue(@Data[0], '\', Pointer(Info), InfoSize) then Exit;
  if (InfoSize < SizeOf(TVSFixedFileInfo)) or (Info.dwSignature <> $FEEF04BD) then Exit;
  Result := Format('v%d.%d.%d', [HiWord(Info.dwFileVersionMS),
    LoWord(Info.dwFileVersionMS), HiWord(Info.dwFileVersionLS)]);
end;

function ReleaseVersion(const Tag: string; out Version: UInt64): Boolean;
var
  Part: string;
  Parts: TArray<string>;
  Number: Integer;
begin
  Result := False;
  Version := 0;
  if (Tag = '') or (Tag[1] <> 'v') then Exit;
  Parts := Tag.Substring(1).Split(['.']);
  if Length(Parts) <> 3 then Exit;
  for Part in Parts do
  begin
    if not TryStrToInt(Part, Number) or (Number < 0) or (Number > 65535) or
      (IntToStr(Number) <> Part) then Exit;
    Version := (Version shl 16) or UInt64(Number);
  end;
  Result := True;
end;

function InstalledEdition: string;
var
  Registry: TRegistry;
  Name, Location: string;
begin
  Result := '';
  Registry := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if not Registry.OpenKeyReadOnly(
      'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLCModern.Win32_is1') then Exit;
    Location := Registry.ReadString('InstallLocation');
    if (Location = '') or not SameFileName(TPath.Combine(Location, 'VLCModern.exe'),
      Application.ExeName) then Exit;
    Name := Registry.ReadString('DisplayName');
    if Name.EndsWith(' (Full)') then Result := 'Full';
    if Name.EndsWith(' (Lite)') then Result := 'Lite';
  finally
    Registry.Free;
  end;
end;

procedure TFrmAbout.CanCloseDuringUpdate(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FUpdateFile = '';
end;

procedure TFrmAbout.StartUpdateDownload(const URL, Digest: string);
var
  DownloadPath: string;
  ExpectedSize: Int64;
  Progress: TArray<Integer>;
  Id: TGUID;
begin
  if CreateGUID(Id) <> S_OK then
  begin
    FUpdateButton.Enabled := True;
    FUpdateStatus.Caption := Translate('Update download failed. Try again.');
    Exit;
  end;
  DownloadPath := TPath.Combine(TPath.GetTempPath, 'VLCModern-' + GUIDToString(Id) + '.exe');
  ExpectedSize := FUpdateBytes;
  SetLength(Progress, 1);
  FUpdateProgress := Progress;
  FUpdateFile := DownloadPath;
  FUpdateTrack.Visible := True;
  FUpdateFill.Visible := True;
  FUpdateFill.Width := 0;
  FUpdateStatus.Caption := Format(Translate('Downloading update %s… %d%%'), [FUpdateTag, 0]);
  FUpdate := TTask.Future<string>(
    function: string
    var
      Client: THTTPClient;
      Stream: TFileStream;
      Response: IHTTPResponse;
    begin
      Result := '';
      try
        Client := THTTPClient.Create;
        try
          Client.ConnectionTimeout := 10000;
          Client.ResponseTimeout := 30000;
          Client.UserAgent := 'VLC-Modern';
          Client.ReceiveDataCallback :=
            procedure(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean)
            begin
              AAbort := AReadCount > ExpectedSize;
              if not AAbort then
                TInterlocked.Exchange(Progress[0], Integer(AReadCount * 100 div ExpectedSize));
            end;
          Stream := TFileStream.Create(DownloadPath, fmCreate);
          try
            Response := Client.Get(URL, Stream);
            if (Response.StatusCode <> 200) or (Stream.Size <> ExpectedSize) then
              raise EInOutError.Create('Unexpected update response');
          finally
            Stream.Free;
          end;
          if not SameText('sha256:' + THashSHA2.GetHashStringFromFile(DownloadPath), Digest) then
            raise EInOutError.Create('Update checksum did not match');
          Result := DownloadPath;
        finally
          Client.Free;
        end;
      except
        System.SysUtils.DeleteFile(DownloadPath);
      end;
    end);
  FUpdateTimer.Enabled := True;
end;

procedure TFrmAbout.UpdateFinished(Sender: TObject);
const
  ReleaseRoot = 'https://github.com/Diagoo1/VLC-Modern/releases/';
var
  Tag, Payload, Edition, Name, AssetName, Url, Digest, Arguments: string;
  Data, Item: TJSONValue;
  Assets: TJSONArray;
  Published, Running: UInt64;
  Percent: Integer;
begin
  if FUpdate = nil then Exit;
  if FUpdate.Status <> TTaskStatus.Completed then
  begin
    if Length(FUpdateProgress) > 0 then
    begin
      Percent := TInterlocked.CompareExchange(FUpdateProgress[0], 0, 0);
      FUpdateFill.Width := FUpdateTrack.Width * Percent div 100;
      FUpdateStatus.Caption := Format(Translate('Downloading update %s… %d%%'), [FUpdateTag, Percent]);
    end;
    Exit;
  end;

  FUpdateTimer.Enabled := False;
  Payload := FUpdate.Value;
  FUpdate := nil;
  FUpdateButton.Enabled := True;
  if FUpdateFile <> '' then
  begin
    FUpdateFile := '';
    FUpdateProgress := nil;
    FUpdateTrack.Visible := False;
    FUpdateFill.Visible := False;
    if Payload = '' then
    begin
      FUpdateStatus.Caption := Translate('Update download failed. Try again.');
      Exit;
    end;
    Arguments := '/SILENT /NORESTART /DIR="' + ExtractFileDir(Application.ExeName) + '"';
    if ShellExecute(Handle, 'runas', PChar(Payload), PChar(Arguments), nil, SW_SHOWNORMAL) <= 32 then
    begin
      System.SysUtils.DeleteFile(Payload);
      FUpdateStatus.Caption := Translate('The update installer could not start.');
      Exit;
    end;
    ModalResult := mrOk;
    Application.MainForm.Close;
    Exit;
  end;

  FUpdateStatus.Caption := Translate('Could not check for updates. Try again later.');
  Data := TJSONObject.ParseJSONValue(Payload);
  try
    if not (Data is TJSONObject) or not Data.TryGetValue<string>('tag_name', Tag) or
      not ReleaseVersion(Tag, Published) or not ReleaseVersion(RunningVersionTag, Running) then Exit;
    if Published <= Running then
    begin
      FUpdateStatus.Caption := Format(Translate('You have the latest published release (%s).'), [Tag]);
      Exit;
    end;
    Edition := InstalledEdition;
    if (Edition <> '') and Data.TryGetValue<TJSONArray>('assets', Assets) then
    begin
      AssetName := 'VLC-Modern-' + Tag + '-Setup-' + Edition + '-Windows.exe';
      for Item in Assets do
        if Item.TryGetValue<string>('name', Name) and (Name = AssetName) and
          Item.TryGetValue<string>('browser_download_url', Url) and
          (Url = ReleaseRoot + 'download/' + Tag + '/' + AssetName) and
          Item.TryGetValue<string>('digest', Digest) and Digest.StartsWith('sha256:') and
          (Length(Digest) = 71) and Item.TryGetValue<Int64>('size', FUpdateBytes) and
          (FUpdateBytes > 0) then
        begin
          FUpdateTag := Tag;
          FUpdateButton.Enabled := False;
          StartUpdateDownload(Url, Digest);
          Exit;
        end;
    end;
    FUpdateStatus.Caption := Format(Translate('GitHub release %s is listed under Releases.'), [Tag]);
    ShellExecute(Handle, 'open', PChar(ReleaseRoot + 'tag/' + Tag), nil, nil, SW_SHOWNORMAL);
  finally
    Data.Free;
  end;
end;

procedure TFrmAbout.OpenLink(Sender: TObject);
begin
  if ShellExecute(Handle, 'open', PChar(Links[TPlayerTextButton(Sender).Tag]), nil, nil,
    SW_SHOWNORMAL) <= 32 then
    PlayerMessage('Windows could not open this link.');
end;

procedure TFrmAbout.OpenShortcuts(Sender: TObject);
begin
  if Assigned(FrmMain) then FrmMain.ShowHotkeysReference;
end;

procedure TFrmAbout.DragSurface(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then Exit;
  var Position := TControl(Sender).ClientToScreen(Point(X, Y));
  ReleaseCapture;
  SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, MakeLParam(Position.X, Position.Y));
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
const
  DarkHeroFill = $00342518;   // Deep blue surface under the project cyan
  DarkHeroEdge = $00634528;
  Captions: array[0..4] of string = ('Project on GitHub', 'Developer profile', 'Support', 'Email', 'Report a bug');
  Glyphs: array[0..4] of Char = (#$E12B, #$E77B, #$E719, #$E715, #$E90F);
var
  Body: TPanel;
  Hero, Profile, Badge: TModernCardPanel;
  AppIcon: TAboutArtwork;
  HeroFill, HeroEdge, BadgeFill, WatermarkColor: TColor;
  VersionText, EngineText, CreditText, AccountText: TLabel;
  Button: TPlayerTextButton;

  function Px(Value: Integer): Integer;
  begin
    Result := MulDiv(Value, CurrentPPI, 96);
  end;

  procedure Place(Control: TControl; X, Y, W, H: Integer);
  begin
    Control.SetBounds(Px(X), Px(Y), Px(W), Px(H));
  end;

  function Card(Host: TWinControl; X, Y, W, H, Radius: Integer;
    Fill, Edge: TColor): TModernCardPanel;
  begin
    Result := TModernCardPanel.Create(Self);
    Result.Parent := Host;
    Result.CardColor := Fill;
    Result.BorderColor := Edge;
    Result.CornerRadius := Radius;
    Result.OnMouseDown := DragSurface;
    Place(Result, X, Y, W, H);
  end;

  function Text(Host: TWinControl; const Caption: string; X, Y, Size: Integer;
    Bold: Boolean = False): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Host;
    Result.Caption := Caption;
    Result.Font.Size := Size;
    if Bold then Result.Font.Style := [fsBold];
    Result.Transparent := True;
    Result.OnMouseDown := DragSurface;
    Result.Left := Px(X);
    Result.Top := Px(Y);
  end;

  function Action(const Caption: string; X, Y, W: Integer): TPlayerTextButton;
  begin
    Result := TPlayerTextButton.Create(Self);
    Result.Parent := Body;
    Result.Caption := Caption;
    Place(Result, X, Y, W, 34);
  end;

begin
  ClientWidth := Px(576);
  ClientHeight := Px(396);
  Body := TPanel.Create(Self);
  Body.Parent := Self;
  Body.Align := alClient;
  Body.BevelOuter := bvNone;
  Body.OnMouseDown := DragSurface;

  HeroFill := DarkHeroFill;
  HeroEdge := DarkHeroEdge;
  BadgeFill := $004B3421;
  WatermarkColor := $004F4339;
  if PlayerLightTheme then
  begin
    HeroFill := DP_COLOR_ACCSOFT;
    HeroEdge := DP_COLOR_BORDER;
    BadgeFill := DP_COLOR_ELEVATED;
    WatermarkColor := DP_COLOR_BORDER;
  end;
  Hero := Card(Body, 16, 14, 532, 102, 14, HeroFill, HeroEdge);
  AppIcon := TAboutArtwork.CreateResource(Self, 'APP_ICON_PNG', False);
  AppIcon.Parent := Hero;
  Place(AppIcon, 14, 14, 74, 74);
  Text(Hero, 'VLC Modern', 96, 15, 22, True);
  EngineText := Text(Hero, 'Windows media player powered by LibVLC', 97, 61, 10);
  Badge := Card(Hero, 380, 19, 132, 28, 10, BadgeFill, HeroEdge);
  VersionText := Text(Badge, RunningVersionTag, 0, 5, 9, True);
  if VersionText.Caption = '' then VersionText.Caption := 'Unknown version';
  VersionText.Left := (Badge.Width - VersionText.Width) div 2;

  Profile := Card(Body, 16, 130, 532, 139, 14, DP_COLOR_ELEVATED, DP_COLOR_BORDER);
  var Portrait := TAboutArtwork.CreateResource(Self, 'DEV_AVATAR', True);
  Portrait.Parent := Profile;
  Place(Portrait, 20, 18, 104, 104);
  CreditText := Text(Profile, 'DESIGN & DEVELOPMENT', 147, 24, 9, True);
  CreditText.ShowAccelChar := False;
  Text(Profile, 'Tarek Sadek', 146, 45, 22, True);
  var TagCard := Card(Profile, 146, 88, 100, 29, 9, DP_COLOR_BG, DP_COLOR_BORDER);
  AccountText := Text(TagCard, '@Diagoo1', 10, 5, 10, True);
  var CodeWatermark := Text(Profile, '</>', 389, 34, 36, True);

  for var Index := Low(Captions) to High(Captions) do
  begin
    Button := Action(Glyphs[Index], 16 + Index * 50, 283, 42);
    Button.Font.Name := 'Segoe MDL2 Assets';
    Button.Font.Size := 12;
    Button.Hint := Captions[Index];
    Button.ShowHint := True;
    Button.Tag := Index;
    Button.OnClick := OpenLink;
  end;
  Button := Action(#$E765, 266, 283, 42);
  Button.Font.Name := 'Segoe MDL2 Assets';
  Button.Font.Size := 12;
  Button.Hint := 'Keyboard shortcuts';
  Button.ShowHint := True;
  Button.OnClick := OpenShortcuts;
  FUpdateButton := Action('Check for updates', 372, 283, 176);
  FUpdateButton.Hint := 'Check GitHub for a newer VLC Modern release';
  FUpdateButton.ShowHint := True;
  FUpdateButton.OnClick := CheckUpdate;
  OnCloseQuery := CanCloseDuringUpdate;
  FUpdateTimer := TTimer.Create(Self);
  FUpdateTimer.Enabled := False;
  FUpdateTimer.Interval := 100;
  FUpdateTimer.OnTimer := UpdateFinished;
  FUpdateStatus := Text(Body, '', 16, 336, 9);
  FUpdateTrack := TShape.Create(Self);
  FUpdateTrack.Parent := Body;
  Place(FUpdateTrack, 16, 361, 410, 7);
  FUpdateTrack.Shape := stRoundRect;
  FUpdateTrack.Pen.Style := psClear;
  FUpdateTrack.Brush.Color := DP_COLOR_BORDER;
  FUpdateTrack.Visible := False;
  FUpdateFill := TShape.Create(Self);
  FUpdateFill.Parent := Body;
  Place(FUpdateFill, 16, 361, 0, 7);
  FUpdateFill.Shape := stRoundRect;
  FUpdateFill.Pen.Style := psClear;
  FUpdateFill.Brush.Color := DP_COLOR_ACCENT;
  FUpdateFill.Visible := False;
  Button := Action('Close', 452, 331, 96);
  Button.Hint := 'Close About';
  Button.ShowHint := True;
  Button.ModalResult := mrCancel;
  Button.Cancel := True;
  Button.Default := True;

  ApplyPlayerAppearance(Self, True);
  AccountText.BiDiMode := bdLeftToRight;
  Body.Color := DP_COLOR_SURFACE;
  FUpdateStatus.Font.Color := DP_COLOR_MUTED;
  VersionText.Font.Color := DP_COLOR_ACCENT;
  EngineText.Font.Color := DP_COLOR_MUTED;
  CreditText.Font.Color := DP_COLOR_ACCENT;
  AccountText.Font.Color := DP_COLOR_MUTED;
  CodeWatermark.Font.Color := WatermarkColor;
end;

end.
