unit AudioMeter;

interface

uses Winapi.Windows;

type
  IPlayerAudioMeter = interface(IUnknown)
    ['{C02216F6-8C67-4B5B-9D00-D008E73E0064}']
    function GetPeakValue(out Peak: Single): HRESULT; stdcall;
  end;

  TProcessAudioMeter = class
  private
    FMeters: TArray<IPlayerAudioMeter>;
    FNextScan: UInt64;
    FUninitialize: Boolean;
    procedure Scan;
  public
    constructor Create;
    destructor Destroy; override;
    function Sample: Single;
  end;

implementation

uses Winapi.ActiveX, System.SysUtils, System.Math;

type
  IAudioDevice = interface(IUnknown)
    function Activate(const IID: TGUID; Context: DWORD; Params: Pointer; out Obj: IUnknown): HRESULT; stdcall;
  end;
  IAudioDevices = interface(IUnknown)
    function GetCount(out Count: UINT): HRESULT; stdcall;
    function Item(Index: UINT; out Device: IAudioDevice): HRESULT; stdcall;
  end;
  IAudioEnumerator = interface(IUnknown)
    ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
    function EnumAudioEndpoints(Flow: Integer; State: DWORD; out Devices: IAudioDevices): HRESULT; stdcall;
  end;
  ISessionControl = interface(IUnknown)
    function GetState(out State: Integer): HRESULT; stdcall;
    function GetDisplayName(out Name: PWideChar): HRESULT; stdcall;
    function SetDisplayName(Name: PWideChar; Context: Pointer): HRESULT; stdcall;
    function GetIconPath(out Path: PWideChar): HRESULT; stdcall;
    function SetIconPath(Path: PWideChar; Context: Pointer): HRESULT; stdcall;
    function GetGroupingParam(out Group: TGUID): HRESULT; stdcall;
    function SetGroupingParam(const Group: TGUID; Context: Pointer): HRESULT; stdcall;
    function RegisterNotification(Events: Pointer): HRESULT; stdcall;
    function UnregisterNotification(Events: Pointer): HRESULT; stdcall;
  end;
  ISessionControl2 = interface(ISessionControl)
    ['{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}']
    function GetSessionIdentifier(out ID: PWideChar): HRESULT; stdcall;
    function GetSessionInstanceIdentifier(out ID: PWideChar): HRESULT; stdcall;
    function GetProcessID(out PID: DWORD): HRESULT; stdcall;
  end;
  ISessionEnumerator = interface(IUnknown)
    function GetCount(out Count: Integer): HRESULT; stdcall;
    function GetSession(Index: Integer; out Session: ISessionControl): HRESULT; stdcall;
  end;
  ISessionManager = interface(IUnknown)
    ['{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}']
    function GetAudioSessionControl(const ID: TGUID; Flags: DWORD; out Session: ISessionControl): HRESULT; stdcall;
    function GetSimpleAudioVolume(const ID: TGUID; Flags: DWORD; out Volume: IUnknown): HRESULT; stdcall;
    function GetSessionEnumerator(out Sessions: ISessionEnumerator): HRESULT; stdcall;
  end;

const DeviceEnumerator: TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
      SessionManager: TGUID = '{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}';

constructor TProcessAudioMeter.Create;
begin
  inherited;
  FUninitialize := Succeeded(CoInitializeEx(nil, COINIT_APARTMENTTHREADED));
end;

destructor TProcessAudioMeter.Destroy;
begin
  FMeters := nil;
  if FUninitialize then CoUninitialize;
  inherited;
end;

procedure TProcessAudioMeter.Scan;
var Enumerator: IAudioEnumerator; Devices: IAudioDevices; Device: IAudioDevice;
    Obj: IUnknown; Manager: ISessionManager; Sessions: ISessionEnumerator;
    Session: ISessionControl; Control: ISessionControl2; Meter: IPlayerAudioMeter;
    DeviceCount, PID: DWORD; Count: Integer;
begin
  FNextScan := GetTickCount64 + 2000;
  FMeters := nil;
  if Failed(CoCreateInstance(DeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IAudioEnumerator, Enumerator)) then Exit;
  if Failed(Enumerator.EnumAudioEndpoints(0, 1, Devices)) then Exit;
  if Failed(Devices.GetCount(DeviceCount)) then Exit;
  for var D := 0 to Integer(DeviceCount) - 1 do
  begin
    if Failed(Devices.Item(D, Device)) then Continue;
    if Failed(Device.Activate(SessionManager, CLSCTX_ALL, nil, Obj)) then Continue;
    if not Supports(Obj, ISessionManager, Manager) then Continue;
    if Failed(Manager.GetSessionEnumerator(Sessions)) then Continue;
    if Failed(Sessions.GetCount(Count)) then Continue;
    for var I := 0 to Count - 1 do
    begin
      if Failed(Sessions.GetSession(I, Session)) then Continue;
      if not Supports(Session, ISessionControl2, Control) then Continue;
      if Failed(Control.GetProcessID(PID)) or (PID <> GetCurrentProcessId) then Continue;
      if Supports(Session, IPlayerAudioMeter, Meter) then
      begin
        SetLength(FMeters, Length(FMeters) + 1);
        FMeters[High(FMeters)] := Meter;
      end;
    end;
  end;
end;

function TProcessAudioMeter.Sample: Single;
var Peak: Single;
begin
  Result := 0;
  if GetTickCount64 >= FNextScan then Scan;
  for var Meter in FMeters do
    if Succeeded(Meter.GetPeakValue(Peak)) then Result := Max(Result, EnsureRange(Peak, 0.0, 1.0));
end;

end.
