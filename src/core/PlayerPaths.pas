unit PlayerPaths;

interface

function PlayerDataPath(const Name: string): string;
function PlayerCachePath(const Name: string): string;
function BundledPath(const Name: string): string;
function ComponentPath(const Name: string): string;

implementation

uses System.SysUtils, System.IOUtils, Winapi.Windows, Winapi.ShlObj;

function BundledPath(const Name: string): string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), Name);
end;

function PlayerDataPath(const Name: string): string;
var
  LocalData: array[0..MAX_PATH] of Char;
begin
  if TFile.Exists(BundledPath('VLCModern.installed.ini')) then
  begin
    if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, @LocalData[0]) <> S_OK then
      RaiseLastOSError;
    Result := TPath.Combine(TPath.Combine(string(PChar(@LocalData[0])), 'VLC Modern'), Name);
  end
  else
    Result := BundledPath(Name);
end;

function PlayerCachePath(const Name: string): string;
var
  LocalData: array[0..MAX_PATH] of Char;
begin
  if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, @LocalData[0]) <> S_OK then
    RaiseLastOSError;
  Result := TPath.Combine(TPath.Combine(TPath.Combine(string(PChar(@LocalData[0])), 'VLC Modern'), 'Cache'), Name);
end;

function ComponentPath(const Name: string): string;
begin
  Result := PlayerDataPath(Name);
  if not TFile.Exists(Result) and not TDirectory.Exists(Result) then
    Result := BundledPath(Name);
end;

end.
