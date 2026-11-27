unit YtDlpResolver;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.StrUtils,
  System.Net.HttpClient, System.Net.URLClient, System.RegularExpressions;

type
  TYtDlpComplete = reference to procedure(const DirectUrl, VideoTitle, UserAgent, ErrorMsg: string; Success: Boolean);

  TYtDlpResolver = class
  public
    class function IsSupportedSiteUrl(const AUrl: string): Boolean;
    class function FindYtDlpBinary: string;
    class function EnsureYtDlpBinary(out ErrorMsg: string): string;
    class function TryNativeHtmlExtract(const AUrl: string; out DirectUrl, VideoTitle: string): Boolean;
    class procedure ResolveAsync(const AUrl: string; OnComplete: TYtDlpComplete;
      UseBackupRuntime: Boolean = False);
  end;

implementation

uses PlayerPaths, PlayerLanguage;

class function TYtDlpResolver.IsSupportedSiteUrl(const AUrl: string): Boolean;
const
  Domains: array[0..6] of string = ('youtube.com', 'youtu.be', 'twitch.tv',
    'vimeo.com', 'dailymotion.com', 'soundcloud.com', 'tiktok.com');
begin
  Result := False;
  for var C in AUrl do
    if (C <= ' ') or CharInSet(C, ['"', '\']) then Exit;
  try
    var URL := TURI.Create(AUrl);
    if not SameText(URL.Scheme, 'http') and not SameText(URL.Scheme, 'https') then Exit;
    var Host := LowerCase(URL.Host);
    for var Domain in Domains do
      if (Host = Domain) or Host.EndsWith('.' + Domain) then Exit(True);
  except
    on E: ENetURIException do Exit;
  end;
end;

class function TYtDlpResolver.FindYtDlpBinary: string;
var
  AppDir, Candidate, PathEnv, Dir: string;
  Dirs: TArray<string>;
begin
  Result := '';
  AppDir := ExtractFilePath(ParamStr(0));
  for Candidate in [
    TPath.Combine(AppDir, 'yt-dlp.exe'),
    ComponentPath('tools\yt-dlp.exe'),
    TPath.Combine(AppDir, '..\tools\yt-dlp.exe')
  ] do
  begin
    if TFile.Exists(Candidate) then
      Exit(TPath.GetFullPath(Candidate));
  end;

  PathEnv := GetEnvironmentVariable('PATH');
  Dirs := PathEnv.Split([';'], TStringSplitOptions.ExcludeEmpty);
  for Dir in Dirs do
  begin
    Candidate := TPath.Combine(Trim(Dir), 'yt-dlp.exe');
    if TFile.Exists(Candidate) then
      Exit(Candidate);
  end;
end;

class function TYtDlpResolver.EnsureYtDlpBinary(out ErrorMsg: string): string;
const
  YtDlpUrl = 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe';
var
  ToolsDir, DestPath, TmpPath: string;
  HTTP: THTTPClient;
  Resp: IHTTPResponse;
  FS: TFileStream;
begin
  ErrorMsg := '';
  Result := FindYtDlpBinary;
  if Result <> '' then Exit;

  ToolsDir := PlayerDataPath('tools');
  try
    TDirectory.CreateDirectory(ToolsDir);
  except
    on E: Exception do
    begin
      ErrorMsg := Translate('Auto-download failed:') + ' ' + LocalizeExceptionText(E);
      Exit;
    end;
  end;
  DestPath := TPath.Combine(ToolsDir, 'yt-dlp.exe');
  TmpPath := DestPath + '.downloading';

  HTTP := THTTPClient.Create;
  try
    HTTP.UserAgent := 'VLCModern/1.0';
    HTTP.ConnectionTimeout := 8000;
    HTTP.ResponseTimeout := 30000;
    try
      Resp := HTTP.Get(YtDlpUrl);
      if (Resp <> nil) and (Resp.StatusCode = 200) and (Resp.ContentStream.Size > 1024 * 1024) then
      begin
        FS := TFileStream.Create(TmpPath, fmCreate);
        try
          Resp.ContentStream.Position := 0;
          FS.CopyFrom(Resp.ContentStream, 0);
        finally
          FS.Free;
        end;
        if TFile.Exists(DestPath) then TFile.Delete(DestPath);
        TFile.Move(TmpPath, DestPath);
        Result := DestPath;
      end
      else
        ErrorMsg := 'Auto-download of yt-dlp.exe returned invalid response';
    except
      on E: Exception do
      begin
        if TFile.Exists(TmpPath) then TFile.Delete(TmpPath);
        ErrorMsg := Translate('Auto-download failed:') + ' ' + LocalizeExceptionText(E);
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

class function TYtDlpResolver.TryNativeHtmlExtract(const AUrl: string; out DirectUrl, VideoTitle: string): Boolean;
var
  HTTP: THTTPClient;
  Resp: IHTTPResponse;
  Html: string;
  M: TMatch;
begin
  Result := False;
  DirectUrl := '';
  VideoTitle := '';
  HTTP := THTTPClient.Create;
  try
    HTTP.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
    HTTP.ConnectionTimeout := 4000;
    HTTP.ResponseTimeout := 6000;
    try
      Resp := HTTP.Get(AUrl);
      if (Resp = nil) or (Resp.StatusCode <> 200) then Exit;
      Html := Resp.ContentAsString(TEncoding.UTF8);
      M := TRegEx.Match(Html, '<title[^>]*>(.*?)</title>', [roIgnoreCase, roSingleLine]);
      if M.Success then VideoTitle := Trim(M.Groups[1].Value);

      M := TRegEx.Match(Html, '<meta[^>]+property=["'']og:video(?::secure_url)?["''][^>]+content=["'']([^"'']+)["'']', [roIgnoreCase]);
      if not M.Success then
        M := TRegEx.Match(Html, '<video[^>]+src=["''](https?://[^"'']+\.(?:mp4|m3u8|webm)[^"'']*)["'']', [roIgnoreCase]);
      if not M.Success then
        M := TRegEx.Match(Html, '(https?://[^\s"'']+\.(?:mp4|m3u8)(?:\?[^\s"'']*)?)', [roIgnoreCase]);

      if M.Success then
      begin
        DirectUrl := StringReplace(M.Groups[1].Value, '&amp;', '&', [rfReplaceAll]);
        Result := DirectUrl.StartsWith('http');
      end;
    except
      Result := False;
    end;
  finally
    HTTP.Free;
  end;
end;

class procedure TYtDlpResolver.ResolveAsync(const AUrl: string; OnComplete: TYtDlpComplete;
  UseBackupRuntime: Boolean);
begin
  if not IsSupportedSiteUrl(AUrl) then
  begin
    if Assigned(OnComplete) then OnComplete('', '', '', 'Unsupported platform URL', False);
    Exit;
  end;
  TThread.CreateAnonymousThread(
    procedure
    var
      ExePath, CmdLine, OutText, Line, TitleOut, UrlOut, AgentOut, ErrOut, DlErr: string;
      SA: TSecurityAttributes;
      ReadPipe, WritePipe: THandle;
      SI: TStartupInfoW;
      PI: TProcessInformation;
      Buf: array[0..4095] of AnsiChar;
      BytesRead: DWORD;
      RawOut: RawByteString;
      Lines: TStringList;
      Ok: Boolean;
      I: Integer;
    begin
      Ok := False;
      TitleOut := '';
      UrlOut := '';
      ErrOut := '';

      ExePath := EnsureYtDlpBinary(DlErr);
      if ExePath = '' then
      begin
        if TryNativeHtmlExtract(AUrl, UrlOut, TitleOut) then
          Ok := True
        else
          ErrOut := DlErr;
        if Assigned(OnComplete) then
        begin
          var FUrl := UrlOut;
          var FTitle := TitleOut;
          var FAgent := AgentOut;
          var FErr := ErrOut;
          var FOk := Ok;
          TThread.Queue(nil, TThreadProcedure(procedure begin OnComplete(FUrl, FTitle, FAgent, FErr, FOk); end));
        end;
        Exit;
      end;

      SA.nLength := SizeOf(SA);
      SA.bInheritHandle := True;
      SA.lpSecurityDescriptor := nil;
      if not CreatePipe(ReadPipe, WritePipe, @SA, 0) then
      begin
        ErrOut := 'Failed to create pipe for yt-dlp';
        if Assigned(OnComplete) then
          TThread.Queue(nil, TThreadProcedure(procedure begin OnComplete('', '', '', ErrOut, False); end));
        Exit;
      end;

      try
        SetHandleInformation(ReadPipe, HANDLE_FLAG_INHERIT, 0);
        ZeroMemory(@SI, SizeOf(SI));
        SI.cb := SizeOf(SI);
        SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
        SI.wShowWindow := SW_HIDE;
        SI.hStdOutput := WritePipe;
        SI.hStdError := WritePipe;
        ZeroMemory(@PI, SizeOf(PI));

        var PortableNode := ComponentPath('tools\node\node.exe');
        var QuickJS := BundledPath('tools\quickjs-ng\qjs.exe');
        var RuntimeOption := '--no-js-runtimes --js-runtimes node ';
        if not UseBackupRuntime and TFile.Exists(QuickJS) then
          RuntimeOption := '--no-js-runtimes --js-runtimes "quickjs:' + QuickJS + '" '
        else if TFile.Exists(PortableNode) then
          RuntimeOption := '--no-js-runtimes --js-runtimes "node:' + PortableNode + '" ';
        var Host := LowerCase(TURI.Create(AUrl).Host);
        var IsYouTube := (Host = 'youtube.com') or Host.EndsWith('.youtube.com') or
          (Host = 'youtu.be') or Host.EndsWith('.youtu.be');
        var Format := 'best[protocol=https][ext=mp4]/best[ext=mp4]/best';
        if IsYouTube then Format := 'best[protocol=https][ext=mp4]';
        CmdLine := '"' + ExePath + '" -f "' + Format + '" --skip-download ' +
          '--print "VLC_TITLE:%(title)s" --print "VLC_URL:%(url)s" --print "VLC_AGENT:%(http_headers.User-Agent)s" --ignore-config ' +
          '--no-plugin-dirs ' + RuntimeOption + '--socket-timeout 8 --retries 1 --no-playlist -- "' +
          AUrl + '"';
        UniqueString(CmdLine);
        if CreateProcessW(PWideChar(ExePath), PWideChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil, SI, PI) then
        begin
          CloseHandle(WritePipe);
          WritePipe := 0;
          RawOut := '';
          var Deadline := GetTickCount64 + 25000;
          var ExitStatus: DWORD := DWORD(-1);
          try
            repeat
              var Pending: DWORD := 0;
              if not PeekNamedPipe(ReadPipe, nil, 0, nil, @Pending, nil) then Break;
              if Pending > 0 then
              begin
                if not ReadFile(ReadPipe, Buf, SizeOf(Buf), BytesRead, nil) then Break;
                var Chunk: RawByteString;
                SetString(Chunk, Buf, BytesRead);
                RawOut := RawOut + Chunk;
                if Length(RawOut) > 1024 * 1024 then Break;
              end
              else if WaitForSingleObject(PI.hProcess, 25) = WAIT_OBJECT_0 then Break;
            until GetTickCount64 >= Deadline;
            if WaitForSingleObject(PI.hProcess, 0) <> WAIT_OBJECT_0 then
            begin
              TerminateProcess(PI.hProcess, 1);
              WaitForSingleObject(PI.hProcess, 1000);
              ErrOut := 'yt-dlp did not finish within the resolver limit';
            end
            else GetExitCodeProcess(PI.hProcess, ExitStatus);
          finally
            CloseHandle(PI.hProcess);
            CloseHandle(PI.hThread);
          end;

          OutText := UTF8ToString(RawOut);
          Lines := TStringList.Create;
          try
            Lines.Text := OutText;
            for I := 0 to Lines.Count - 1 do
            begin
              Line := Trim(Lines[I]);
              if Line = '' then Continue;
              if Line.StartsWith('VLC_URL:') and (UrlOut = '') then
              begin
                var Candidate := Copy(Line, Length('VLC_URL:') + 1, MaxInt);
                if Candidate.StartsWith('https://') or Candidate.StartsWith('http://') then
                  UrlOut := Candidate;
              end
              else if Line.StartsWith('VLC_AGENT:') and (Line <> 'VLC_AGENT:NA') then
                AgentOut := Copy(Line, Length('VLC_AGENT:') + 1, MaxInt)
              else if Line.StartsWith('VLC_TITLE:') and (TitleOut = '') then
                TitleOut := Copy(Line, Length('VLC_TITLE:') + 1, MaxInt);
            end;
          finally
            Lines.Free;
          end;

          Ok := (ExitStatus = 0) and (UrlOut <> '');
          if not Ok and IsYouTube and not UseBackupRuntime and
             TFile.Exists(QuickJS) and TFile.Exists(PortableNode) then
          begin
            ResolveAsync(AUrl, OnComplete, True);
            Exit;
          end;
          if not Ok then
          begin
            UrlOut := '';
            if ErrOut = '' then
              if IsYouTube then
              begin
                if not TFile.Exists(PortableNode) and ContainsText(OutText, 'JavaScript runtime') then
                  ErrOut := 'This YouTube video needs Node.js. Download it from Settings > Playback Components and try again.'
                else ErrOut := 'Could not prepare YouTube video for playback';
              end
              else ErrOut := 'yt-dlp could not resolve stream URL';
          end;
        end
        else
        begin
          var LaunchError := GetLastError;
          ErrOut := Translate('Failed to launch yt-dlp.exe') + ' ' + LocalizeWindowsError(LaunchError);
        end;
      finally
        if WritePipe <> 0 then CloseHandle(WritePipe);
        CloseHandle(ReadPipe);
      end;

      if Assigned(OnComplete) then
      begin
        var FUrl := UrlOut;
        var FTitle := TitleOut;
        var FAgent := AgentOut;
        var FErr := ErrOut;
        var FOk := Ok;
        TThread.Queue(nil, TThreadProcedure(procedure begin OnComplete(FUrl, FTitle, FAgent, FErr, FOk); end));
      end;
    end).Start;
end;

end.
