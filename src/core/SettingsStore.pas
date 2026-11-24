unit SettingsStore;

interface

uses System.Classes, System.IniFiles, System.Win.Registry;

type
  TAppSettings = class(TRegistryIniFile)
  public
    constructor Create(const LegacyFile: string);
    function Snapshot: string;
    procedure Restore(const Data: string);
  end;

function SettingsRegistryRoot: string;

implementation

uses System.SysUtils, Winapi.Windows;

function SettingsRegistryRoot: string;
var TestID: string;
begin
  Result := 'Software\Orvana\VLCModern';
  TestID := GetEnvironmentVariable('VLC_SETTINGS_TEST_ID');
  if TestID <> '' then
  begin
    for var C in TestID do
      if not CharInSet(C, ['a'..'z', 'A'..'Z', '0'..'9', '-']) then
        raise EArgumentException.Create('Invalid isolated settings identifier');
    Result := Result + '\Tests\' + TestID;
  end;
end;

procedure CopyValues(Source, Target: TCustomIniFile);
var Sections, Keys, Values: TStringList;
begin
  Sections := TStringList.Create;
  Keys := TStringList.Create;
  Values := TStringList.Create;
  try
    Source.ReadSections(Sections);
    for var Section in Sections do
    begin
      Source.ReadSection(Section, Keys);
      Values.Clear;
      Source.ReadSectionValues(Section, Values);
      for var Key in Keys do
        Target.WriteString(Section, Key, Values.Values[Key]);
    end;
  finally Values.Free; Keys.Free; Sections.Free; end;
end;

constructor TAppSettings.Create(const LegacyFile: string);
var Legacy: TIniFile;
begin
  inherited Create(SettingsRegistryRoot + '\' + ChangeFileExt(ExtractFileName(LegacyFile), ''), KEY_READ or KEY_WRITE);
  if not ReadBool('__Store', 'Migrated', False) then
  begin
    if FileExists(LegacyFile) then
    begin
      Legacy := TIniFile.Create(LegacyFile);
      try CopyValues(Legacy, Self); finally Legacy.Free; end;
    end;
    WriteBool('__Store', 'Migrated', True);
  end;
end;

function TAppSettings.Snapshot: string;
var Memory: TMemIniFile; Lines: TStringList;
begin
  Memory := TMemIniFile.Create('');
  Lines := TStringList.Create;
  try
    CopyValues(Self, Memory);
    Memory.GetStrings(Lines);
    Result := Lines.Text;
  finally Lines.Free; Memory.Free; end;
end;

procedure TAppSettings.Restore(const Data: string);
var Memory: TMemIniFile; Lines: TStringList;
begin
  Memory := TMemIniFile.Create('');
  Lines := TStringList.Create;
  try
    ReadSections(Lines);
    for var Section in Lines do EraseSection(Section);
    Lines.Text := Data;
    Memory.SetStrings(Lines);
    CopyValues(Memory, Self);
  finally Lines.Free; Memory.Free; end;
end;

end.
