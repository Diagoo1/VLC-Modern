unit OnlineVideoSave;

interface

type
  IOnlineVideoSave = interface
    procedure Cancel;
  end;
  TOnlineVideoSaveProgress = reference to procedure(Percent, RemainingSeconds: Integer);
  TOnlineVideoSaveResult = reference to procedure(const ErrorMessage: string; Cancelled, Interrupted: Boolean);

function SaveOnlineMP4Async(const URL, UserAgent, Destination: string;
  const OnProgress: TOnlineVideoSaveProgress;
  const OnComplete: TOnlineVideoSaveResult): IOnlineVideoSave;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Net.HttpClient, System.SyncObjs,
  System.Math, System.Net.URLClient, PlayerLanguage;

type
  TOnlineVideoSave = class(TInterfacedObject, IOnlineVideoSave)
  private
    FState: Integer;
    FStarted, FLastProgress: UInt64;
    FOnProgress: TOnlineVideoSaveProgress;
    function IsCancelled: Boolean;
    procedure Receive(const Sender: TObject; TotalBytes, ReadBytes: Int64; var Abort: Boolean);
    procedure PublishProgress(Percent, RemainingSeconds: Integer);
  public
    procedure Cancel;
  end;

procedure TOnlineVideoSave.Cancel;
begin
  TInterlocked.CompareExchange(FState, 1, 0);
end;

function TOnlineVideoSave.IsCancelled: Boolean;
begin
  Result := TInterlocked.CompareExchange(FState, 0, 0) = 1;
end;

procedure TOnlineVideoSave.PublishProgress(Percent, RemainingSeconds: Integer);
begin
  if Assigned(FOnProgress) then
    TThread.Queue(nil, TThreadProcedure(
      procedure begin FOnProgress(Percent, RemainingSeconds); end));
end;

procedure TOnlineVideoSave.Receive(const Sender: TObject; TotalBytes, ReadBytes: Int64;
  var Abort: Boolean);
var
  NowTick: UInt64;
  Percent, ETA: Integer;
begin
  Abort := Abort or IsCancelled;
  if Abort then Exit;
  NowTick := GetTickCount64;
  if ReadBytes = 0 then
  begin
    FStarted := NowTick;
    Exit;
  end;
  if (NowTick - FLastProgress < 200) and (ReadBytes <> TotalBytes) then Exit;
  FLastProgress := NowTick;
  Percent := -1;
  ETA := -1;
  if TotalBytes > 0 then
  begin
    Percent := EnsureRange(Trunc(100.0 * ReadBytes / TotalBytes), 0, 99);
    if (NowTick - FStarted >= 500) and (ReadBytes < TotalBytes) then
      ETA := Ceil(Min(359999.0, (TotalBytes - ReadBytes) / ReadBytes *
        (NowTick - FStarted) / 1000.0));
  end;
  PublishProgress(Percent, ETA);
end;

function ReadBigEndian(Stream: TStream; Count: Integer): UInt64;
var
  B: Byte;
begin
  Result := 0;
  for var I := 1 to Count do
  begin
    Stream.ReadBuffer(B, SizeOf(B));
    Result := (Result shl 8) or B;
  end;
end;

procedure VerifyMP4(Stream: TStream);
var
  Start, BoxSize: UInt64;
  BoxType: array[0..3] of AnsiChar;
  HasMovie, HasMedia, HasType: Boolean;
begin
  Stream.Position := 0;
  HasMovie := False;
  HasMedia := False;
  HasType := False;
  while Stream.Position < Stream.Size do
  begin
    Start := UInt64(Stream.Position);
    BoxSize := ReadBigEndian(Stream, 4);
    Stream.ReadBuffer(BoxType, SizeOf(BoxType));
    if BoxSize = 1 then BoxSize := ReadBigEndian(Stream, 8)
    else if BoxSize = 0 then BoxSize := UInt64(Stream.Size) - Start;
    if (BoxSize < UInt64(Stream.Position) - Start) or
       (BoxSize > UInt64(Stream.Size) - Start) then
      raise Exception.Create('The downloaded MP4 is incomplete.');
    if BoxType = 'ftyp' then HasType := True;
    if BoxType = 'moov' then HasMovie := True;
    if (BoxType = 'mdat') and (BoxSize > UInt64(Stream.Position) - Start) then HasMedia := True;
    Stream.Position := Int64(Start + BoxSize);
  end;
  if not (HasType and HasMovie and HasMedia) then
    raise Exception.Create('The downloaded file is not a complete MP4.');
end;

function SaveOnlineMP4Async(const URL, UserAgent, Destination: string;
  const OnProgress: TOnlineVideoSaveProgress;
  const OnComplete: TOnlineVideoSaveResult): IOnlineVideoSave;
var
  Task: TOnlineVideoSave;
  KeepAlive: IOnlineVideoSave;
begin
  Task := TOnlineVideoSave.Create;
  KeepAlive := Task;
  Result := KeepAlive;
  Task.FOnProgress := OnProgress;
  TThread.CreateAnonymousThread(
    procedure
    var
      TempName, ErrorMessage: string;
      Client: THTTPClient;
      Output: TFileStream;
      Cancelled, Interrupted: Boolean;
    begin
      Interrupted := False;
      TempName := Destination + '.' + TGUID.NewGuid.ToString + '.part';
      try
        if Task.IsCancelled then Abort;
        if FileExists(Destination) then
          raise Exception.Create('A file with that name already exists. Choose a new name.');
        Client := THTTPClient.Create;
        try
          Client.ConnectionTimeout := 10000;
          Client.ResponseTimeout := 30000;
          if UserAgent <> '' then Client.UserAgent := UserAgent;
          Task.FStarted := GetTickCount64;
          Client.OnReceiveData := Task.Receive;
          Output := TFileStream.Create(TempName, fmCreate or fmShareExclusive);
          try
            var Response: IHTTPResponse;
            try
              Response := Client.Get(URL, Output);
            except
              on E: ENetException do
              begin
                Interrupted := True;
                raise;
              end;
            end;
            if Task.IsCancelled then Abort;
            if (Response.StatusCode = 200) and (Response.ContentLength > Output.Size) then
              Interrupted := True;
            if (Response.StatusCode <> 200) or (Response.ContentLength <= 0) or
               (Response.ContentLength <> Output.Size) then
              raise Exception.Create('The server did not return the complete video. Reopen the video and try again.');
            Task.PublishProgress(100, 0);
            VerifyMP4(Output);
          finally
            Output.Free;
          end;
        finally
          Client.Free;
        end;
        // Claim the final rename only if cancellation did not win.
        if TInterlocked.CompareExchange(Task.FState, 2, 0) <> 0 then Abort;
        if not MoveFileEx(PChar(TempName), PChar(Destination), MOVEFILE_WRITE_THROUGH) then
          RaiseLastOSError;
      except
        on E: Exception do ErrorMessage := LocalizeExceptionText(E);
      end;
      Cancelled := Task.IsCancelled;
      if FileExists(TempName) and not System.SysUtils.DeleteFile(TempName) then
      begin
        ErrorMessage := 'Could not remove the temporary file: ' + TempName;
        Cancelled := False;
        Interrupted := False;
      end;
      TThread.Queue(nil, TThreadProcedure(
        procedure
        begin
          if KeepAlive <> nil then
            if Assigned(OnComplete) then OnComplete(ErrorMessage, Cancelled, Interrupted and not Cancelled);
        end));
    end).Start;
end;

end.