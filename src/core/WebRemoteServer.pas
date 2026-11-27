unit WebRemoteServer;

interface

uses
  Winapi.Windows, Winapi.WinSock2, System.SysUtils, System.Classes, System.StrUtils, System.SyncObjs;

type
  TWebRemoteCommandProc = reference to procedure(const Cmd: string);

  TWebRemoteServer = class
  private
    FPort: Word;
    FToken: string;
    FRunning: Boolean;
    FListenSock: TSocket;
    FThread: TThread;
    FCritSec: TCriticalSection;
    FCachedTitle, FCachedState: string;
    FCachedPosMs, FCachedDurMs: Int64;
    FCachedVol: Integer;
    FCachedMuted: Boolean;
    FOnCommand: TWebRemoteCommandProc;
    procedure ServerLoop;
    procedure HandleClient(ClientSock: TSocket);
    function BuildHtmlPage: UTF8String;
    function BuildStatusJson: UTF8String;
  public
    constructor Create(APort: Word = 8080);
    destructor Destroy; override;
    function Start(AOnCommand: TWebRemoteCommandProc): Boolean;
    procedure UpdateStatus(const Title, State: string; PosMs, DurMs: Int64; Vol: Integer; Muted: Boolean);
    procedure Stop;
    property Running: Boolean read FRunning;
    property Port: Word read FPort write FPort;
  end;

implementation

constructor TWebRemoteServer.Create(APort: Word);
begin
  inherited Create;
  FPort := APort;
  FListenSock := INVALID_SOCKET;
  FRunning := False;
  FCritSec := TCriticalSection.Create;
  FCachedTitle := 'VLC Modern (Idle)';
  FCachedState := 'Stopped';
  FCachedVol := 100;
end;

destructor TWebRemoteServer.Destroy;
begin
  Stop;
  FreeAndNil(FCritSec);
  inherited Destroy;
end;

procedure TWebRemoteServer.UpdateStatus(const Title, State: string; PosMs, DurMs: Int64; Vol: Integer; Muted: Boolean);
begin
  FCritSec.Enter;
  try
    FCachedTitle := Title;
    FCachedState := State;
    FCachedPosMs := PosMs;
    FCachedDurMs := DurMs;
    FCachedVol := Vol;
    FCachedMuted := Muted;
  finally
    FCritSec.Leave;
  end;
end;

function TWebRemoteServer.Start(AOnCommand: TWebRemoteCommandProc): Boolean;
var
  WSA: TWSAData;
  Addr: TSockAddrIn;
  Opt: Integer;
  Nonce: TGUID;
begin
  Result := False;
  if FRunning then Exit(True);

  if CreateGUID(Nonce) <> S_OK then Exit;
  FToken := GUIDToString(Nonce);
  FOnCommand := AOnCommand;

  if WSAStartup($0202, WSA) <> 0 then Exit;

  FListenSock := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if FListenSock = INVALID_SOCKET then begin WSACleanup; Exit; end;

  Opt := 1;
  setsockopt(FListenSock, SOL_SOCKET, not Integer(SO_REUSEADDR), PAnsiChar(@Opt), SizeOf(Opt));

  ZeroMemory(@Addr, SizeOf(Addr));
  Addr.sin_family := AF_INET;
  Addr.sin_addr.s_addr := inet_addr('127.0.0.1');
  Addr.sin_port := htons(FPort);

  if bind(FListenSock, PSockAddr(@Addr)^, SizeOf(Addr)) = SOCKET_ERROR then
  begin
    closesocket(FListenSock);
    FListenSock := INVALID_SOCKET;
    WSACleanup;
    Exit;
  end;

  if listen(FListenSock, 8) = SOCKET_ERROR then
  begin
    closesocket(FListenSock);
    FListenSock := INVALID_SOCKET;
    WSACleanup;
    Exit;
  end;

  FRunning := True;
  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      ServerLoop;
    end);
  FThread.FreeOnTerminate := False;
  FThread.Start;
  Result := True;
end;

procedure TWebRemoteServer.Stop;
begin
  if not FRunning and (FListenSock = INVALID_SOCKET) then Exit;
  FRunning := False;
  if FListenSock <> INVALID_SOCKET then
  begin
    closesocket(FListenSock);
    FListenSock := INVALID_SOCKET;
  end;
  if FThread <> nil then
  begin
    FThread.WaitFor;
    TThread.RemoveQueuedEvents(FThread);
    FreeAndNil(FThread);
  end;
  WSACleanup;
end;

procedure TWebRemoteServer.ServerLoop;
var
  ClientSock: TSocket;
  Timeout: Integer;
begin
  while FRunning do
  begin
    ClientSock := accept(FListenSock, nil, nil);
    if ClientSock = INVALID_SOCKET then Break;
    try
      Timeout := 350;
      setsockopt(ClientSock, SOL_SOCKET, SO_RCVTIMEO, PAnsiChar(@Timeout), SizeOf(Timeout));
      setsockopt(ClientSock, SOL_SOCKET, SO_SNDTIMEO, PAnsiChar(@Timeout), SizeOf(Timeout));
      if FRunning then HandleClient(ClientSock);
    finally
      closesocket(ClientSock);
    end;
  end;
end;

function JsonEscape(const S: string): string;
begin
  Result := S.Replace('\', '\\').Replace('"', '\"').Replace(#13, '').Replace(#10, ' ');
end;

function TWebRemoteServer.BuildStatusJson: UTF8String;
var
  Title, State: string;
  PosMs, DurMs: Int64;
  Vol: Integer;
  Muted: Boolean;
begin
  FCritSec.Enter;
  try
    Title := FCachedTitle;
    State := FCachedState;
    PosMs := FCachedPosMs;
    DurMs := FCachedDurMs;
    Vol := FCachedVol;
    Muted := FCachedMuted;
  finally
    FCritSec.Leave;
  end;

  Result := UTF8Encode(Format(
    '{"title":"%s","state":"%s","position":%d,"duration":%d,"volume":%d,"muted":%s}',
    [JsonEscape(Title), JsonEscape(State), PosMs, DurMs, Vol, LowerCase(BoolToStr(Muted, True))]
  ));
end;

function TWebRemoteServer.BuildHtmlPage: UTF8String;
begin
  Result := UTF8Encode(
    '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' +
    '<title>VLC Modern Remote</title><style>' +
    'body{margin:0;font-family:Segoe UI,sans-serif;background:#111827;color:#f3f4f6;display:flex;flex-direction:column;align-items:center;padding:24px;}' +
    '.card{background:#1f2937;border:1px solid #374151;border-radius:16px;padding:20px;max-width:420px;width:100%;box-shadow:0 10px 25px rgba(0,0,0,.4);}' +
    'h1{margin:0 0 6px;font-size:20px;color:#38bdf8;text-align:center;}' +
    '#title{text-align:center;font-size:14px;color:#d1d5db;margin-bottom:16px;word-break:break-word;}' +
    '.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;}' +
    'button{background:#374151;color:#fff;border:none;border-radius:10px;padding:14px 8px;font-size:15px;font-weight:600;cursor:pointer;}' +
    'button:active{background:#0284c7;} .primary{background:#0284c7;grid-column:span 3;}' +
    '</style></head><body><div class="card"><h1>VLC Modern Remote</h1>' +
    '<div id="title">Connecting...</div><div class="grid">' +
    '<button class="primary" onclick="cmd(''playpause'')">Play / Pause</button>' +
    '<button onclick="cmd(''prev'')">Prev</button><button onclick="cmd(''stop'')">Stop</button><button onclick="cmd(''next'')">Next</button>' +
    '<button onclick="cmd(''back10'')">-10s</button><button onclick="cmd(''fullscreen'')">Fullscreen</button><button onclick="cmd(''fwd10'')">+10s</button>' +
    '<button onclick="cmd(''voldown'')">Vol -</button><button onclick="cmd(''mute'')">Mute</button><button onclick="cmd(''volup'')">Vol +</button>' +
    '</div></div><script>' +
    'function cmd(c){fetch(''/api/cmd?c=''+c,{method:''POST'',headers:{''X-VLC-Remote'':'''+FToken+'''}}).then(refresh);}' +
    'function refresh(){fetch(''/api/status'').then(r=>r.json()).then(d=>{document.getElementById(''title'').textContent=d.title+'' (''+d.state+'' | Vol ''+d.volume+''%)'';}).catch(()=>{});}' +
    'refresh();setInterval(refresh,1500);</script></body></html>'
  );
end;

procedure TWebRemoteServer.HandleClient(ClientSock: TSocket);
var
  Buf: array[0..2047] of AnsiChar;
  Len, QPos: Integer;
  Req, FirstLine, Path, Cmd, ContentType: string;
  Body, Resp: UTF8String;
begin
  Req := '';
  var Deadline := GetTickCount64 + 350;
  repeat
    Len := recv(ClientSock, Buf, SizeOf(Buf) - 1, 0);
    if Len <= 0 then Exit;
    Buf[Len] := #0;
    Req := Req + string(AnsiString(Buf));
    if (Length(Req) > 8192) or (GetTickCount64 > Deadline) then Exit;
  until Pos(#13#10#13#10, Req) > 0;
  Req := Copy(Req, 1, Pos(#13#10#13#10, Req) - 1);
  FirstLine := Req.Split([#13#10, #10])[0];
  var Parts := FirstLine.Split([' ']);
  if Length(Parts) <> 3 then Exit;
  Path := Parts[1];
  var Host := '';
  var Token := '';
  for var Line in Req.Split([#13#10]) do
  begin
    if StartsText('Host:', Line) then Host := Trim(Copy(Line, 6, MaxInt));
    if StartsText('X-VLC-Remote:', Line) then Token := Trim(Copy(Line, 14, MaxInt));
  end;
  if (Host <> '127.0.0.1:' + IntToStr(FPort)) and
     (Host <> 'localhost:' + IntToStr(FPort)) then Exit;

  var Status := '200 OK';
  if (Parts[0] = 'GET') and (Path = '/api/status') then
  begin
    ContentType := 'application/json; charset=utf-8';
    Body := BuildStatusJson;
  end
  else if (Parts[0] = 'POST') and Path.StartsWith('/api/cmd?c=') and (Token = FToken) then
  begin
    QPos := Pos('?c=', Path);
    if QPos > 0 then
    begin
      Cmd := Copy(Path, QPos + 3, MaxInt);
      if Assigned(FOnCommand) then
      begin
        var ExecCmd := Cmd;
        TThread.Queue(FThread, TThreadProcedure(procedure
          begin
            if FRunning and Assigned(FOnCommand) then FOnCommand(ExecCmd);
          end));
      end;
    end;
    ContentType := 'application/json; charset=utf-8';
    Body := '{"ok":true}';
  end
  else if (Parts[0] = 'GET') and (Path = '/') then
  begin
    ContentType := 'text/html; charset=utf-8';
    Body := BuildHtmlPage;
  end
  else
  begin
    Status := '403 Forbidden';
    ContentType := 'application/json; charset=utf-8';
    Body := '{"ok":false}';
  end;

  Resp := UTF8Encode(
    'HTTP/1.1 ' + Status + #13#10 +
    'Content-Type: ' + ContentType + #13#10 +
    'Content-Length: ' + IntToStr(Length(Body)) + #13#10 +
    'Cache-Control: no-store'#13#10 +
    'Connection: close'#13#10#13#10
  ) + Body;

  send(ClientSock, PAnsiChar(Resp)^, Length(Resp), 0);
end;

end.
