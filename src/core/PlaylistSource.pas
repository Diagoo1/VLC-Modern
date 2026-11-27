unit PlaylistSource;

interface

uses System.SysUtils;

const
  StalkerStreamUserAgent = 'Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 250 Safari/533.3';

type
  IPlaylistRequest = interface
    ['{E356F148-516A-4DB2-A81C-FE8F70712D53}']
    function Finished: Boolean;
    function Content: string;
    function ErrorText: string;
    procedure Execute;
  end;

function DownloadPlaylist(const URL: string): IPlaylistRequest;
function DownloadStalker(const Portal, MAC: string; const Command: string = ''): IPlaylistRequest;

implementation

uses Winapi.Windows, System.Classes, System.SyncObjs, System.Net.HttpClient, System.JSON,
  System.NetEncoding, System.StrUtils, System.Generics.Collections;

type
  TStalkerSession = record
    Token: string;
    ExpiresTick: UInt64;
  end;

var
  GStalkerLock: TCriticalSection = nil;
  GStalkerSessions: TDictionary<string, TStalkerSession> = nil;

function TryGetStalkerToken(const Key: string; out Token: string): Boolean;
var
  Sess: TStalkerSession;
begin
  Result := False;
  Token := '';
  if GStalkerLock = nil then Exit;
  GStalkerLock.Enter;
  try
    if (GStalkerSessions <> nil) and GStalkerSessions.TryGetValue(Key, Sess) and
       (GetTickCount64 < Sess.ExpiresTick) and (Sess.Token <> '') then
    begin
      Token := Sess.Token;
      Result := True;
    end;
  finally
    GStalkerLock.Leave;
  end;
end;

procedure SaveStalkerToken(const Key, Token: string);
var
  Sess: TStalkerSession;
begin
  if (GStalkerLock = nil) or (Token = '') then Exit;
  Sess.Token := Token;
  Sess.ExpiresTick := GetTickCount64 + 10 * 60 * 1000;
  GStalkerLock.Enter;
  try
    if GStalkerSessions = nil then GStalkerSessions := TDictionary<string, TStalkerSession>.Create;
    GStalkerSessions.AddOrSetValue(Key, Sess);
  finally
    GStalkerLock.Leave;
  end;
end;

procedure ClearStalkerToken(const Key: string);
begin
  if GStalkerLock = nil then Exit;
  GStalkerLock.Enter;
  try
    if GStalkerSessions <> nil then GStalkerSessions.Remove(Key);
  finally
    GStalkerLock.Leave;
  end;
end;

type
  TBoundedStream = class(TMemoryStream)
    function Write(const Buffer; Count: Longint): Longint; override;
  end;
  TPlaylistRequest = class(TInterfacedObject, IPlaylistRequest)
  private
    FURL, FContent, FError: string;
    FMAC, FCommand: string;
    FFinished: Integer;
    function StalkerContent(HTTP: THTTPClient): string;
  public
    constructor Create(const URL: string);
    constructor CreateStalker(const Portal, MAC, Command: string);
    function Finished: Boolean;
    function Content: string;
    function ErrorText: string;
    procedure Execute;
  end;

function TBoundedStream.Write(const Buffer; Count: Longint): Longint;
begin
  if Position + Count > 128 * 1024 * 1024 then
    raise EStreamError.Create('The playlist exceeds the 128 MB limit.');
  Result := inherited Write(Buffer, Count);
end;

constructor TPlaylistRequest.Create(const URL: string);
begin
  inherited Create;
  FURL := URL;
end;

constructor TPlaylistRequest.CreateStalker(const Portal, MAC, Command: string);
begin
  Create(Portal);
  FMAC := MAC;
  FCommand := Command;
end;

function TPlaylistRequest.StalkerContent(HTTP: THTTPClient): string;
var Endpoint, Base, Token, GroupName, ID, Name, Command: string;
    Root, Profile, Genres, Channels, Link: TJSONValue;
    GenreArray, ChannelArray: TJSONArray; Obj: TJSONValue;
    Groups: TDictionary<string, string>; Output: TStringBuilder;
  function Fetch(const Query: string): TJSONValue;
  var Data: TBoundedStream; Response: IHTTPResponse; Bytes: UTF8String;
  begin
    Data := TBoundedStream.Create;
    try
      Response := HTTP.Get(Endpoint + '?' + Query + '&JsHttpRequest=1-xml', Data);
      if Response.StatusCode <> 200 then
        raise EConvertError.Create('The portal request failed.');
      SetString(Bytes, PAnsiChar(Data.Memory), Data.Size);
      Result := TJSONObject.ParseJSONValue(UTF8ToString(Bytes));
      if Result = nil then raise EConvertError.Create('The portal returned an invalid response.');
    finally Data.Free; end;
  end;
  function Clean(const Text: string): string;
  begin
    Result := Text.Replace('"', '''').Replace(#13, ' ').Replace(#10, ' ');
  end;
begin
  Base := FURL.TrimRight(['/']);
  if EndsText('/c', Base) then Delete(Base, Length(Base) - 1, 2);
  if EndsText('.php', Base) then Endpoint := Base
  else Endpoint := Base + '/server/load.php';
  HTTP.UserAgent := StalkerStreamUserAgent;
  HTTP.CustomHeaders['X-User-Agent'] := 'Model: MAG250; Link: WiFi';
  HTTP.CustomHeaders['Cookie'] := 'mac=' + TNetEncoding.URL.Encode(Trim(FMAC)) +
    '; stb_lang=en; timezone=UTC';
  HTTP.CustomHeaders['Referer'] := Base + '/c/';

  Root := Fetch('type=stb&action=handshake&token=&prehash=');
  try Token := Root.GetValue<string>('js.token', ''); finally Root.Free; end;
  if Token = '' then raise EConvertError.Create('The portal did not authorize this device.');
  HTTP.CustomHeaders['Authorization'] := 'Bearer ' + Token;
  Profile := Fetch('type=stb&action=get_profile');
  try
    if (Profile.FindValue('js') = nil) or
       (Profile.GetValue<string>('js.error', '') <> '') then
      raise EConvertError.Create('The portal rejected the device profile.');
  finally Profile.Free; end;
  if FCommand <> '' then
  begin
    Link := Fetch('type=itv&action=create_link&cmd=' + TNetEncoding.URL.Encode(FCommand));
    try
      Result := Link.GetValue<string>('js.cmd', '').Trim;
      if StartsText('ffmpeg ', Result) then Delete(Result, 1, 7);
      if StartsText('ffrt ', Result) then Delete(Result, 1, 5);
      // Some Stalker portals return &stream=& (empty) from create_link when cmd already contains stream=<id>.
      if (Pos('stream=&', Result) > 0) or EndsText('stream=', Result) then
      begin
        var SP := Pos('stream=', FCommand);
        if SP > 0 then
        begin
          var ValStart := SP + 7;
          var ValEnd := PosEx('&', FCommand, ValStart);
          if ValEnd = 0 then ValEnd := Length(FCommand) + 1;
          var StreamVal := Copy(FCommand, ValStart, ValEnd - ValStart);
          if StreamVal <> '' then
          begin
            if Pos('stream=&', Result) > 0 then
              Result := StringReplace(Result, 'stream=&', 'stream=' + StreamVal + '&', [])
            else if EndsText('stream=', Result) then
              Result := Result + StreamVal;
          end;
        end;
      end;
      if not StartsText('http://', Result) and not StartsText('https://', Result) then
        raise EConvertError.Create('The portal did not provide a playable stream.');
    finally Link.Free; end;
    Exit;
  end;
  Groups := TDictionary<string, string>.Create;
  Output := TStringBuilder.Create;
  Genres := nil;
  Channels := nil;
  try
    Genres := Fetch('type=itv&action=get_genres');
    GenreArray := Genres.FindValue('js') as TJSONArray;
    if GenreArray <> nil then
      for Obj in GenreArray do
        Groups.AddOrSetValue(Obj.GetValue<string>('id', ''), Obj.GetValue<string>('title', 'General'));
    Channels := Fetch('type=itv&action=get_all_channels');
    ChannelArray := Channels.FindValue('js.data') as TJSONArray;
    if ChannelArray = nil then raise EConvertError.Create('The portal returned no channel catalogue.');
    Output.AppendLine('#EXTM3U');
    for Obj in ChannelArray do
    begin
      Name := Obj.GetValue<string>('name', 'Channel');
      ID := Obj.GetValue<string>('tv_genre_id', '');
      if not Groups.TryGetValue(ID, GroupName) then GroupName := 'General';
      Command := Obj.GetValue<string>('cmd', '');
      if Command = '' then Continue;
      Output.AppendLine('#EXTINF:-1 tvg-id="' + Clean(Obj.GetValue<string>('xmltv_id', '')) +
        '" tvg-logo="' + Clean(Obj.GetValue<string>('logo', '')) +
        '" group-title="' + Clean(GroupName) + '",' + Clean(Name));
      Output.AppendLine('stalker-cmd://' + TNetEncoding.URL.Encode(Command));
    end;
    Result := Output.ToString;
  finally
    Channels.Free;
    Genres.Free;
    Output.Free;
    Groups.Free;
  end;
end;

function TPlaylistRequest.Finished: Boolean;
begin
  Result := TInterlocked.CompareExchange(FFinished, 0, 0) <> 0;
end;

function TPlaylistRequest.Content: string;
begin
  Result := FContent;
end;

function TPlaylistRequest.ErrorText: string;
begin
  Result := FError;
end;

procedure TPlaylistRequest.Execute;
var HTTP: THTTPClient; Response: IHTTPResponse; Data: TBoundedStream; Bytes: UTF8String;
begin
  HTTP := THTTPClient.Create;
  Data := TBoundedStream.Create;
  try
    try
      HTTP.ConnectionTimeout := 8000;
      HTTP.ResponseTimeout := 45000;
      if FMAC <> '' then
      begin
        FContent := StalkerContent(HTTP);
        Exit;
      end;
      Response := HTTP.Get(FURL, Data);
      if Response.StatusCode <> 200 then
        FError := Format('The server returned HTTP %d.', [Response.StatusCode])
      else
      begin
        SetString(Bytes, PAnsiChar(Data.Memory), Data.Size);
        FContent := UTF8ToString(Bytes);
      end;
    except
      // URLs can contain provider credentials. Never echo them in error dialogs.
      on E: Exception do FError := 'Unable to load the playlist. Check the address and connection.';
    end;
  finally
    Data.Free;
    HTTP.Free;
    TInterlocked.Exchange(FFinished, 1);
  end;
end;

function DownloadStalker(const Portal, MAC, Command: string): IPlaylistRequest;
var Work: IPlaylistRequest;
begin
  Work := TPlaylistRequest.CreateStalker(Portal, MAC, Command);
  Result := Work;
  TThread.CreateAnonymousThread(procedure begin Work.Execute; end).Start;
end;

function DownloadPlaylist(const URL: string): IPlaylistRequest;
var Work: IPlaylistRequest;
begin
  Work := TPlaylistRequest.Create(URL);
  Result := Work;
  // The worker owns its request, never the form; closing a window cannot leave
  // queued callbacks referring to freed controls.
  TThread.CreateAnonymousThread(
    procedure
    begin
      Work.Execute;
    end).Start;
end;

initialization
  GStalkerLock := TCriticalSection.Create;

finalization
  FreeAndNil(GStalkerSessions);
  FreeAndNil(GStalkerLock);

end.