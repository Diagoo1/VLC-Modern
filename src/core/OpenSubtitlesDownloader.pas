unit OpenSubtitlesDownloader;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, System.JSON, System.ZLib,
  System.NetEncoding, System.Net.HttpClient, System.Net.URLClient;

type
  TSubDownloadComplete = reference to procedure(const SubPath: string; Success: Boolean; const ErrorMsg: string);

  TSubtitleCandidate = record
    FileID: Integer;
    Language, ReleaseName: string;
  end;
  TSubtitleSearchComplete = reference to procedure(
    const Matches: TArray<TSubtitleCandidate>; const ErrorMsg: string);

  TOpenSubtitlesDownloader = class
  public
    class function ComputeMovieHash(const AFilePath: string; out AHash: string; out ASize: Int64): Boolean;
    class procedure DownloadSubtitleAsync(
      const AVideoFilePath: string;
      const ALanguages: string = 'ar,en';
      OnComplete: TSubDownloadComplete = nil
    );
    class function EpisodeSearchParameters(const FileName: string): string; static;
    class procedure SearchAsync(const FileName: string; OnComplete: TSubtitleSearchComplete);
    class procedure DownloadCandidateAsync(FileID: Integer; OnComplete: TSubDownloadComplete);
    class procedure TranslateSRTAsync(
      const AInputSRTPath: string;
      const ATargetLang: string = 'ar';
      OnComplete: TSubDownloadComplete = nil
    );
  end;

implementation

uses System.RegularExpressions, System.Generics.Collections, System.StrUtils;

class function TOpenSubtitlesDownloader.ComputeMovieHash(
  const AFilePath: string;
  out AHash: string;
  out ASize: Int64
): Boolean;
var
  Stream: TFileStream;
  Buffer: array[0..8191] of UInt64;
  Hash: UInt64;
  BytesRead, I: Integer;
begin
  Result := False;
  AHash := '';
  ASize := 0;
  if not TFile.Exists(AFilePath) then Exit;

  try
    Stream := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyNone);
    try
      ASize := Stream.Size;
      if ASize < 65536 then Exit;

      Hash := UInt64(ASize);

      // Read first 64 KB
      Stream.Position := 0;
      BytesRead := Stream.Read(Buffer[0], 65536);
      if BytesRead < 65536 then Exit;
      for I := 0 to 8191 do
        Inc(Hash, Buffer[I]);

      // Read last 64 KB
      Stream.Position := Max(0, ASize - 65536);
      BytesRead := Stream.Read(Buffer[0], 65536);
      if BytesRead < 65536 then Exit;
      for I := 0 to 8191 do
        Inc(Hash, Buffer[I]);

      AHash := IntToHex(Int64(Hash), 16).ToLower;
      Result := True;
    finally
      Stream.Free;
    end;
  except
    Result := False;
  end;
end;

const
  OpenSubtitlesURL = 'https://api.opensubtitles.com/api/v1/';
  OpenSubtitlesAgent = 'VLC Modern v0.1.0';

function NewSubtitleClient: THTTPClient;
var Key, Token: string;
begin
  Key := Trim(GetEnvironmentVariable('OPENSUBTITLES_API_KEY'));
  if Key = '' then raise Exception.Create('Set OPENSUBTITLES_API_KEY to enable subtitle downloads');
  Token := Trim(GetEnvironmentVariable('OPENSUBTITLES_TOKEN'));
  Result := THTTPClient.Create;
  Result.HandleRedirects := False;
  Result.ConnectionTimeout := 5000;
  Result.ResponseTimeout := 10000;
  Result.UserAgent := OpenSubtitlesAgent;
  Result.CustomHeaders['Api-Key'] := Key;
  Result.CustomHeaders['Accept'] := 'application/json';
  if Token <> '' then Result.CustomHeaders['Authorization'] := 'Bearer ' + Token;
end;

class function TOpenSubtitlesDownloader.EpisodeSearchParameters(const FileName: string): string;
var
  Name, Title: string;
  Marker, SeasonMarker: TMatch;
  Season, Episode: Integer;
begin
  Result := '';
  Name := TPath.GetFileNameWithoutExtension(FileName);
  Marker := TRegEx.Match(Name, '(?i)(?:^|[ ._-])s?(\d{1,2})(?:[ ._-]*e|x)(\d{1,3})(?!\d)');
  if Marker.Success then
  begin
    Season := StrToIntDef(Marker.Groups[1].Value, -1);
    Episode := StrToIntDef(Marker.Groups[2].Value, -1);
    Title := Copy(Name, 1, Marker.Index - 1);
  end
  else
  begin
    Marker := TRegEx.Match(Name, '(?i)(?:episode|الحلقة|حلقة)\s*(\d{1,3})(?!\d)');
    if not Marker.Success then Exit;
    Episode := StrToIntDef(Marker.Groups[1].Value, -1);
    SeasonMarker := TRegEx.Match(Name, '(?i)(?:season|الموسم)\s*(\d{1,2})(?!\d)');
    Season := 1;
    if SeasonMarker.Success then Season := StrToIntDef(SeasonMarker.Groups[1].Value, -1);
    Title := Copy(Name, 1, Marker.Index - 1);
    Title := TRegEx.Replace(Title, '(?i)(?:season|الموسم)\s*\d{1,2}', '');
    var LatinTitle := TRegEx.Match(Title, '[A-Za-z][A-Za-z0-9 ._-]*');
    if LatinTitle.Success then Title := LatinTitle.Value;
    Title := TRegEx.Replace(Title, '^مسلسل\s+', '');
  end;
  Title := Trim(TRegEx.Replace(Title, '[ ._-]+', ' '));
  if (Title = '') or (Season < 0) or (Episode < 1) then Exit;
  Result := Format('episode_number=%d&query=%s&season_number=%d', [
    Episode, TNetEncoding.URL.Encode(LowerCase(Title)).Replace('%20','+'), Season]);
end;

function NormalizeSeriesTitle(const Value: string): string;
begin
  Result := Trim(TRegEx.Replace(LowerCase(Value), '[^\p{L}\p{N}]+', ' '));
end;

function ReadCandidates(HTTP: THTTPClient; const Parameters: string;
  const ExpectedSeries: string = ''): TArray<TSubtitleCandidate>;
var
  JSON: TJSONValue;
  Data, Files: TJSONArray;
  Entries: TList<TSubtitleCandidate>;
  Choice: TSubtitleCandidate;
  ParentTitle, PageParameters: string;
  Page, TotalPages: Integer;
begin
  Entries := TList<TSubtitleCandidate>.Create;
  try
    Page := 1;
    repeat
      PageParameters := Parameters;
      if Page > 1 then
        if ExpectedSeries <> '' then
          PageParameters := Parameters.Replace('&query=', '&page=' + IntToStr(Page) + '&query=')
        else
          PageParameters := Parameters + '&page=' + IntToStr(Page);
      var Response := HTTP.Get(OpenSubtitlesURL + 'subtitles?' + PageParameters);
      if Response.StatusCode <> 200 then
        raise Exception.CreateFmt('OpenSubtitles search failed (HTTP %d)', [Response.StatusCode]);
      JSON := TJSONObject.ParseJSONValue(Response.ContentAsString(TEncoding.UTF8));
      try
        if (JSON = nil) or not JSON.TryGetValue<TJSONArray>('data', Data) then
          raise Exception.Create('OpenSubtitles returned an invalid search response');
        TotalPages := 1;
        JSON.TryGetValue<Integer>('total_pages', TotalPages);
        for var Entry in Data do
        begin
          if (ExpectedSeries <> '') and
            (not Entry.TryGetValue<string>('attributes.feature_details.parent_title', ParentTitle) or
             (NormalizeSeriesTitle(ParentTitle) <> ExpectedSeries)) then Continue;
          if not Entry.TryGetValue<TJSONArray>('attributes.files', Files) then Continue;
          for var AFile in Files do
          begin
            Choice := Default(TSubtitleCandidate);
            if not AFile.TryGetValue<Integer>('file_id', Choice.FileID) or (Choice.FileID <= 0) then Continue;
            Entry.TryGetValue<string>('attributes.language', Choice.Language);
            Entry.TryGetValue<string>('attributes.release', Choice.ReleaseName);
            if Choice.ReleaseName = '' then AFile.TryGetValue<string>('file_name', Choice.ReleaseName);
            Entries.Add(Choice);
          end;
        end;
      finally
        JSON.Free;
      end;
      Inc(Page);
    until Page > TotalPages;
    Result := Entries.ToArray;
  finally
    Entries.Free;
  end;
end;

function DownloadSubtitleFile(HTTP: THTTPClient; FileID: Integer): string;
var
  Link: string;
  Nonce: TGUID;
begin
  var Body := TStringStream.Create(Format('{"file_id":%d,"sub_format":"srt"}', [FileID]), TEncoding.UTF8);
  try
    HTTP.CustomHeaders['Content-Type'] := 'application/json';
    var Response := HTTP.Post(OpenSubtitlesURL + 'download', Body);
    if Response.StatusCode <> 200 then
      raise Exception.CreateFmt('OpenSubtitles download request failed (HTTP %d)', [Response.StatusCode]);
    var Payload := TJSONObject.ParseJSONValue(Response.ContentAsString(TEncoding.UTF8));
    try
      if (Payload = nil) or not Payload.TryGetValue<string>('link', Link) or
        not Link.StartsWith('https://', True) then
        raise Exception.Create('OpenSubtitles returned no HTTPS download link');
    finally
      Payload.Free;
    end;
  finally
    Body.Free;
  end;

  // The signed URL is fetched without API credentials.
  var DownloadHTTP := THTTPClient.Create;
  try
    DownloadHTTP.UserAgent := OpenSubtitlesAgent;
    DownloadHTTP.ConnectionTimeout := 5000;
    DownloadHTTP.ResponseTimeout := 10000;
    var Response := DownloadHTTP.Get(Link);
    if (Response.StatusCode <> 200) or (Response.ContentStream.Size <= 0) or
      (Response.ContentStream.Size > 10 * 1024 * 1024) then
      raise Exception.CreateFmt('Subtitle file download failed (HTTP %d)', [Response.StatusCode]);
    if CreateGUID(Nonce) <> 0 then raise Exception.Create('Could not allocate subtitle file name');
    Result := TPath.Combine(TPath.GetTempPath, 'VLCModern-' + GUIDToString(Nonce) + '.srt');
    try
      var OutFile := TFileStream.Create(Result, fmCreate);
      try
        Response.ContentStream.Position := 0;
        OutFile.CopyFrom(Response.ContentStream, 0);
      finally
        OutFile.Free;
      end;
    except
      System.SysUtils.DeleteFile(Result);
      raise;
    end;
  finally
    DownloadHTTP.Free;
  end;
end;

class procedure TOpenSubtitlesDownloader.SearchAsync(const FileName: string; OnComplete: TSubtitleSearchComplete);
begin
  TThread.CreateAnonymousThread(
    procedure
    var Matches: TArray<TSubtitleCandidate>; ErrorText, Hash, Parameters: string; Size: Int64;
    begin
      try
        if not TFile.Exists(FileName) then raise Exception.Create('Video file not found');
        var HTTP := NewSubtitleClient;
        try
          if ComputeMovieHash(FileName, Hash, Size) then
            Matches := ReadCandidates(HTTP, 'moviehash=' + Hash);
          if Length(Matches) = 0 then
          begin
            Parameters := EpisodeSearchParameters(FileName);
            if Parameters <> '' then
            begin
              var Query := TRegEx.Match(Parameters, '&query=([^&]+)').Groups[1].Value;
              Matches := ReadCandidates(HTTP, Parameters,
                NormalizeSeriesTitle(TNetEncoding.URL.Decode(Query.Replace('+', '%20'))));
            end;
          end;
        finally
          HTTP.Free;
        end;
        if Length(Matches) = 0 then ErrorText := 'No matching subtitles found';
      except
        on E: Exception do ErrorText := E.Message;
      end;
      if Assigned(OnComplete) then TThread.Synchronize(nil,
        procedure begin OnComplete(Matches, ErrorText); end);
    end).Start;
end;

class procedure TOpenSubtitlesDownloader.DownloadCandidateAsync(FileID: Integer; OnComplete: TSubDownloadComplete);
begin
  TThread.CreateAnonymousThread(
    procedure
    var Path, ErrorText: string;
    begin
      try
        var HTTP := NewSubtitleClient;
        try Path := DownloadSubtitleFile(HTTP, FileID); finally HTTP.Free; end;
      except on E: Exception do ErrorText := E.Message; end;
      if Assigned(OnComplete) then TThread.Synchronize(nil,
        procedure begin OnComplete(Path, Path <> '', ErrorText); end);
    end).Start;
end;

class procedure TOpenSubtitlesDownloader.DownloadSubtitleAsync(
  const AVideoFilePath, ALanguages: string; OnComplete: TSubDownloadComplete);
begin
  SearchAsync(AVideoFilePath,
    procedure(const Matches: TArray<TSubtitleCandidate>; const ErrorMsg: string)
    begin
      if ErrorMsg <> '' then
      begin
        if Assigned(OnComplete) then OnComplete('', False, ErrorMsg);
        Exit;
      end;
      for var Choice in Matches do
        if (ALanguages = '') or MatchText(Choice.Language, ALanguages.Split([',', ';', ' '])) then
        begin
          DownloadCandidateAsync(Choice.FileID, OnComplete);
          Exit;
        end;
      if Assigned(OnComplete) then OnComplete('', False, 'No subtitle in the requested languages');
    end);
end;

class procedure TOpenSubtitlesDownloader.TranslateSRTAsync(
  const AInputSRTPath: string;
  const ATargetLang: string;
  OnComplete: TSubDownloadComplete
);
begin
  if not TFile.Exists(AInputSRTPath) then
  begin
    if Assigned(OnComplete) then
      OnComplete('', False, 'Source subtitle file not found');
    Exit;
  end;

  TThread.CreateAnonymousThread(
    procedure
    var
      Lines, OutLines: TStringList;
      I, ArrowPos: Integer;
      Line, OutPath, EncodedText, URL, RespStr: string;
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
    begin
      OutPath := TPath.ChangeExtension(AInputSRTPath, '.' + ATargetLang + '.translated.srt');
      Lines := TStringList.Create;
      OutLines := TStringList.Create;
      HTTP := THTTPClient.Create;
      try
        HTTP.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
        HTTP.ConnectionTimeout := 4000;
        HTTP.ResponseTimeout := 6000;
        Lines.LoadFromFile(AInputSRTPath, TEncoding.UTF8);

        I := 0;
        while I < Lines.Count do
        begin
          Line := Lines[I];
          ArrowPos := Pos('-->', Line);

          // If numeric cue or timestamp, copy as-is
          if (Trim(Line) = '') or (ArrowPos > 0) or (StrToIntDef(Trim(Line), -1) >= 0) then
          begin
            OutLines.Add(Line);
          end
          else
          begin
            // Subtitle text line - translate via HTTP
            try
              EncodedText := TNetEncoding.URL.Encode(Trim(Line));
              URL := Format('https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&q=%s',
                [ATargetLang, EncodedText]);
              Resp := HTTP.Get(URL);
              if (Resp <> nil) and (Resp.StatusCode = 200) then
              begin
                RespStr := Resp.ContentAsString(TEncoding.UTF8);
                // Parse simple JSON [[["translated","orig",...]]]
                if Pos('[[["', RespStr) = 1 then
                begin
                  var FirstQuote := 5;
                  var EndQuote := Pos('","', RespStr);
                  if EndQuote > FirstQuote then
                    Line := Copy(RespStr, FirstQuote, EndQuote - FirstQuote);
                end;
              end;
            except
              // Fallback to original line on error/timeout
            end;
            OutLines.Add(Line);
          end;
          Inc(I);
        end;

        OutLines.SaveToFile(OutPath, TEncoding.UTF8);

        if Assigned(OnComplete) then
          TThread.Synchronize(nil,
            TThreadProcedure(
              procedure
              begin
                OnComplete(OutPath, True, '');
              end
            )
          );
      except
        on E: Exception do
        begin
          if Assigned(OnComplete) then
            TThread.Synchronize(nil,
              TThreadProcedure(
                procedure
                begin
                  OnComplete('', False, E.Message);
                end
              )
            );
        end;
      end;
      HTTP.Free;
      Lines.Free;
      OutLines.Free;
    end
  ).Start;
end;

end.
