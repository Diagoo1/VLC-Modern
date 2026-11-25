unit OnlineVideoSave;

interface

type
  TOnlineVideoSaveResult = reference to procedure(const ErrorMessage: string);

procedure SaveOnlineMP4Async(const URL, UserAgent, Destination: string;
  const OnComplete: TOnlineVideoSaveResult);

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Net.HttpClient;

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

procedure SaveOnlineMP4Async(const URL, UserAgent, Destination: string;
  const OnComplete: TOnlineVideoSaveResult);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      TempName, ErrorMessage: string;
      Client: THTTPClient;
      Output: TFileStream;
    begin
      TempName := Destination + '.' + TGUID.NewGuid.ToString + '.part';
      try
        try
          if FileExists(Destination) then
            raise Exception.Create('A file with that name already exists. Choose a new name.');
          Client := THTTPClient.Create;
          try
            Client.ConnectionTimeout := 10000;
            Client.ResponseTimeout := 30000;
            if UserAgent <> '' then Client.UserAgent := UserAgent;
            Output := TFileStream.Create(TempName, fmCreate or fmShareExclusive);
            try
              var Response := Client.Get(URL, Output);
              if (Response.StatusCode <> 200) or (Response.ContentLength <= 0) or
                 (Response.ContentLength <> Output.Size) then
                raise Exception.Create('The server did not return the complete video. Reopen the video and try again.');
              VerifyMP4(Output);
            finally
              Output.Free;
            end;
          finally
            Client.Free;
          end;
          if not MoveFileEx(PChar(TempName), PChar(Destination), MOVEFILE_WRITE_THROUGH) then
            RaiseLastOSError;
        except
          on E: Exception do ErrorMessage := E.Message;
        end;
      finally
        if FileExists(TempName) then DeleteFile(TempName);
      end;
      if Assigned(OnComplete) then
        TThread.Queue(nil, TThreadProcedure(
          procedure
          begin
            OnComplete(ErrorMessage);
          end));
    end).Start;
end;

end.
