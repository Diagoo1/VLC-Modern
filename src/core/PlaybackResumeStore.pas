unit PlaybackResumeStore;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.IOUtils, System.Hash;

type
  TFilePlaybackState = record
    Position: Int64;       // in milliseconds
    AudioTrack: Integer;   // Track ID
    SubtitleTrack: Integer; // SPU ID
    Volume: Integer;
    LastPlayed: TDateTime;
  end;

  TPlaybackResumeStore = class
  private
    FIniPath: string;
    function MakeKey(const AFilePath: string): string;
  public
    constructor Create(const AIniPath: string = '');
    procedure SaveState(const AFilePath: string; const State: TFilePlaybackState);
    function LoadState(const AFilePath: string; out State: TFilePlaybackState): Boolean;
    procedure DeleteState(const AFilePath: string);
    procedure Prune(MaxEntries: Integer = 500);
    property IniPath: string read FIniPath write FIniPath;
  end;

var
  GlobalResumeStore: TPlaybackResumeStore = nil;

function ResumeStore: TPlaybackResumeStore;

implementation

uses SettingsStore, System.Math;

function ResumeStore: TPlaybackResumeStore;
begin
  if GlobalResumeStore = nil then
    GlobalResumeStore := TPlaybackResumeStore.Create;
  Result := GlobalResumeStore;
end;

constructor TPlaybackResumeStore.Create(const AIniPath: string);
begin
  inherited Create;
  if AIniPath <> '' then
    FIniPath := AIniPath
  else
    FIniPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'VLCModern_Resume.ini');
end;

function TPlaybackResumeStore.MakeKey(const AFilePath: string): string;
begin
  Result := THashSHA1.GetHashString(AnsiLowerCase(Trim(AFilePath)));
end;

procedure TPlaybackResumeStore.SaveState(const AFilePath: string; const State: TFilePlaybackState);
var
  Ini: TAppSettings;
  Key: string;
begin
  if Trim(AFilePath) = '' then Exit;
  Key := MakeKey(AFilePath);
  Ini := TAppSettings.Create(FIniPath);
  try
    Ini.WriteInt64(Key, 'Position', State.Position);
    Ini.WriteInteger(Key, 'AudioTrack', State.AudioTrack);
    Ini.WriteInteger(Key, 'SubtitleTrack', State.SubtitleTrack);
    Ini.WriteInteger(Key, 'Volume', State.Volume);
    Ini.WriteDateTime(Key, 'LastPlayed', Now);
  finally
    Ini.Free;
  end;
end;

function TPlaybackResumeStore.LoadState(const AFilePath: string; out State: TFilePlaybackState): Boolean;
var
  Ini: TAppSettings;
  Key: string;
begin
  Result := False;
  State.Position := 0;
  State.AudioTrack := -1;
  State.SubtitleTrack := -1;
  State.Volume := -1;
  State.LastPlayed := 0;

  if Trim(AFilePath) = '' then Exit;
  Key := MakeKey(AFilePath);

  Ini := TAppSettings.Create(FIniPath);
  try
    if not Ini.SectionExists(Key) then Exit;
    State.Position := Ini.ReadInt64(Key, 'Position', 0);
    State.AudioTrack := Ini.ReadInteger(Key, 'AudioTrack', -1);
    State.SubtitleTrack := Ini.ReadInteger(Key, 'SubtitleTrack', -1);
    State.Volume := Ini.ReadInteger(Key, 'Volume', -1);
    State.LastPlayed := Ini.ReadDateTime(Key, 'LastPlayed', 0);
    Result := (State.Position > 1000);
  finally
    Ini.Free;
  end;
end;

procedure TPlaybackResumeStore.DeleteState(const AFilePath: string);
var
  Ini: TAppSettings;
  Key: string;
begin
  if Trim(AFilePath) = '' then Exit;
  Key := MakeKey(AFilePath);
  Ini := TAppSettings.Create(FIniPath);
  try
    Ini.EraseSection(Key);
  finally
    Ini.Free;
  end;
end;

procedure TPlaybackResumeStore.Prune(MaxEntries: Integer);
var
  Ini: TAppSettings;
  Sections: TStringList;
  I: Integer;
begin
  Ini := TAppSettings.Create(FIniPath);
  Sections := TStringList.Create;
  try
    Ini.ReadSections(Sections);
    I := Sections.IndexOf('__Store');
    if I >= 0 then Sections.Delete(I);
    MaxEntries := Max(0, MaxEntries);
    if Sections.Count > MaxEntries then
    begin
      for I := 0 to Sections.Count - MaxEntries - 1 do
        Ini.EraseSection(Sections[I]);
    end;
  finally
    Sections.Free;
    Ini.Free;
  end;
end;

initialization

finalization
  if GlobalResumeStore <> nil then
    FreeAndNil(GlobalResumeStore);

end.
