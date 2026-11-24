unit InstanceBroker;

interface

uses Winapi.Windows;

const PLAYER_OPEN_REQUEST = $564C4301;

function ForwardToRunningPlayer: Boolean;
procedure PublishPlayerWindow(Window: HWND);
procedure UnpublishPlayerWindow(Window: HWND);

implementation

uses System.SysUtils, System.Classes, Winapi.Messages, SettingsStore;

const WindowMarker = 'Orvana.VLCModern.MainWindow';
type PPlayerWindow = ^HWND;
var InstanceMutex: THandle;

function FindPlayer(Window: HWND; Param: LPARAM): BOOL; stdcall;
begin
  Result := True;
  if GetProp(Window, WindowMarker) = 1 then
  begin
    PPlayerWindow(Param)^ := Window;
    Result := False;
  end;
end;

procedure PublishPlayerWindow(Window: HWND);
begin
  if SameText(ExtractFileName(ParamStr(0)), 'VLCModern.exe') then SetProp(Window, WindowMarker, 1);
end;

procedure UnpublishPlayerWindow(Window: HWND);
begin
  RemoveProp(Window, WindowMarker);
end;

function ForwardToRunningPlayer: Boolean;
var Store: TAppSettings; Window: HWND; Deadline: UInt64; Data: TCopyDataStruct;
    Arguments: TStringList; Text: string; Reply: DWORD_PTR; PID: DWORD;
begin
  Result := False;
  Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    if not Store.ReadBool('General', 'SingleInstance', True) then Exit;
  finally Store.Free; end;
  InstanceMutex := CreateMutex(nil, False, PChar('Local\Orvana.VLCModern.' + GetEnvironmentVariable('USERNAME')));
  if (InstanceMutex = 0) or (GetLastError <> ERROR_ALREADY_EXISTS) then Exit;
  Deadline := GetTickCount64 + 2000;
  Window := 0;
  repeat
    EnumWindows(@FindPlayer, LPARAM(@Window));
    if Window <> 0 then Break;
    Sleep(20);
  until GetTickCount64 >= Deadline;
  if Window = 0 then Exit;
  Arguments := TStringList.Create;
  try
    for var I := 1 to ParamCount do
      if FileExists(ParamStr(I)) then Arguments.Add(ExpandFileName(ParamStr(I)))
      else if ParamStr(I).Contains('://') then Arguments.Add(ParamStr(I));
    Text := Arguments.Text;
    Data.dwData := PLAYER_OPEN_REQUEST;
    Data.cbData := (Length(Text) + 1) * SizeOf(Char);
    Data.lpData := PChar(Text);
    GetWindowThreadProcessId(Window, @PID);
    AllowSetForegroundWindow(PID);
    Result := SendMessageTimeout(Window, WM_COPYDATA, 0, LPARAM(@Data), SMTO_ABORTIFHUNG, 1000, @Reply) <> 0;
  finally Arguments.Free; end;
end;

initialization

finalization
  if InstanceMutex <> 0 then CloseHandle(InstanceMutex);

end.
