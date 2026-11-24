unit VideoInput;

interface

uses
  Winapi.Windows;

procedure AttachVideoInput(MainWindow, VideoWindow: HWND);
procedure RefreshVideoInput;
procedure DetachVideoInput;
function VideoInputHookCount: Integer;

implementation

var
  MainWnd, VideoWnd: HWND;
  LastScan: UInt64 = 0;

function DisableVideoChild(ChildWnd: HWND; Param: LPARAM): BOOL; stdcall;
begin
  if IsWindow(ChildWnd) and IsWindowEnabled(ChildWnd) then
    EnableWindow(ChildWnd, False);
  Result := True;
end;

procedure DetachVideoInput;
begin
  MainWnd := 0;
  VideoWnd := 0;
  LastScan := 0;
end;

procedure AttachVideoInput(MainWindow, VideoWindow: HWND);
begin
  DetachVideoInput;
  MainWnd := MainWindow;
  VideoWnd := VideoWindow;
  RefreshVideoInput;
end;

procedure RefreshVideoInput;
var
  NowTick: UInt64;
begin
  if VideoWnd = 0 then Exit;
  NowTick := GetTickCount64;
  if NowTick - LastScan < 400 then Exit;
  LastScan := NowTick;

  // By disabling the LibVLC Direct3D HWND, Direct3D continues to render at 100% full speed,
  // while Windows routes all mouse clicks, moves, double clicks, and wheel events directly
  // to the Delphi parent control (pnlVideo) on the UI thread without any invasive WH_MOUSE hooks.
  EnumChildWindows(VideoWnd, @DisableVideoChild, 0);
end;

function VideoInputHookCount: Integer;
begin
  Result := 0;
end;

initialization

finalization
  DetachVideoInput;

end.
