unit MediaImport;

interface

uses System.Classes;

type
  IMediaImport = interface
    ['{EF21055A-187E-450B-8BBA-B3AA053D697F}']
    function Finished: Boolean;
    function CopyPaths: TStringList;
    function ErrorText: string;
    procedure Cancel;
    procedure Execute;
  end;

function ImportMedia(const Sources: TStrings): IMediaImport;

implementation

uses System.SysUtils, System.StrUtils, System.IOUtils, System.SyncObjs, Winapi.Windows;

type
  TMediaImport = class(TInterfacedObject, IMediaImport)
  private
    FSources, FPaths: TStringList;
    FDone, FCancelled: Integer;
    FError: string;
    function Stopped: Boolean;
    procedure Add(const Source: string; Explicit: Boolean; Depth: Integer);
    procedure ReadPlaylist(const Path: string; Depth: Integer);
  public
    constructor Create(const Sources: TStrings);
    destructor Destroy; override;
    function Finished: Boolean;
    function CopyPaths: TStringList;
    function ErrorText: string;
    procedure Cancel;
    procedure Execute;
  end;

constructor TMediaImport.Create(const Sources: TStrings);
begin
  inherited Create;
  FSources := TStringList.Create;
  FSources.Assign(Sources);
  FPaths := TStringList.Create;
end;

destructor TMediaImport.Destroy;
begin
  FPaths.Free;
  FSources.Free;
  inherited;
end;

procedure TMediaImport.Cancel;
begin
  TInterlocked.Exchange(FCancelled, 1);
end;

function TMediaImport.Stopped: Boolean;
begin
  Result := (TInterlocked.CompareExchange(FCancelled, 0, 0) <> 0) or (FPaths.Count >= 20000);
  if FPaths.Count >= 20000 then FError := 'Import was limited to 20,000 media items.';
end;

function TMediaImport.Finished: Boolean;
begin
  Result := TInterlocked.CompareExchange(FDone, 0, 0) <> 0;
end;

function TMediaImport.CopyPaths: TStringList;
begin
  Result := TStringList.Create;
  if Finished then Result.Assign(FPaths);
end;

function TMediaImport.ErrorText: string;
begin
  Result := '';
  if Finished then Result := FError;
end;

procedure TMediaImport.ReadPlaylist(const Path: string; Depth: Integer);
var Lines: TStringList; Ext, Line: string; Position: Integer;
begin
  if Depth > 8 then Exit;
  var Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyNone);
  try
    if Stream.Size > 16 * 1024 * 1024 then
      raise EReadError.Create('Playlist exceeds 16 MB.');
  finally Stream.Free; end;
  Lines := TStringList.Create;
  try
    try Lines.LoadFromFile(Path, TEncoding.UTF8);
    except Lines.LoadFromFile(Path); end;
    Ext := LowerCase(ExtractFileExt(Path));
    // HLS is a media source, not a list of independent segments/variants.
    for Line in Lines do
      if StartsText('#EXT-X-', Trim(Line)) then
      begin FPaths.Add(Path); Exit; end;
    for var RawLine in Lines do
    begin
      if Stopped then Exit;
      Line := Trim(RawLine);
      if (Line = '') or StartsText('#', Line) then Continue;
      if Ext = '.pls' then
      begin
        Position := Pos('=', Line);
        if (Position = 0) or not StartsText('File', Line) then Continue;
        Line := Trim(Copy(Line, Position + 1, MaxInt));
      end;
      if not Line.Contains('://') and not TPath.IsPathRooted(Line) then
        Line := TPath.GetFullPath(ExtractFilePath(Path) + Line);
      Add(Line, True, Depth + 1);
    end;
  finally Lines.Free; end;
end;

procedure TMediaImport.Add(const Source: string; Explicit: Boolean; Depth: Integer);
var Search: TSearchRec; Ext: string; Attributes: DWORD;
begin
  if Stopped or (Depth > 32) then Exit;
  if Source.Contains('://') then
  begin FPaths.Add(Source); Exit; end;
  Attributes := GetFileAttributes(PChar(Source));
  if Attributes = INVALID_FILE_ATTRIBUTES then Exit;
  // Junctions and symbolic links cannot recursively send the importer in a loop.
  if Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0 then
  begin
    if (Attributes and FILE_ATTRIBUTE_REPARSE_POINT <> 0) and not Explicit then Exit;
    if System.SysUtils.FindFirst(IncludeTrailingPathDelimiter(Source) + '*', faAnyFile, Search) = 0 then
    try
      repeat
        if Stopped then Exit;
        if (Search.Name <> '.') and (Search.Name <> '..') then
          Add(IncludeTrailingPathDelimiter(Source) + Search.Name, False, Depth + 1);
      until System.SysUtils.FindNext(Search) <> 0;
    finally System.SysUtils.FindClose(Search); end;
    Exit;
  end;
  Ext := LowerCase(ExtractFileExt(Source));
  if MatchText(Ext, ['.srt', '.ass', '.ssa', '.vtt', '.sub', '.idx']) then
  begin
    if Explicit then FPaths.Add(TPath.GetFullPath(Source));
    Exit;
  end;
  if MatchText(Ext, ['.m3u', '.m3u8', '.pls']) then
  begin
    if Explicit then ReadPlaylist(Source, Depth);
    Exit;
  end;
  if MatchText(Ext, ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.ts', '.m2ts', '.vob',
    '.3gp', '.mpg', '.mpeg', '.ogv', '.mp3', '.flac', '.wav', '.aac', '.m4a', '.ogg', '.wma',
    '.opus', '.alac', '.aiff', '.ape']) then FPaths.Add(TPath.GetFullPath(Source));
end;

procedure TMediaImport.Execute;
begin
  try
    try
      for var Source in FSources do
      begin
        if Stopped then Break;
        Add(Source, True, 0);
      end;
    except
      FError := 'Some media sources could not be imported. Check access to the files.';
    end;
  finally TInterlocked.Exchange(FDone, 1); end;
end;

function ImportMedia(const Sources: TStrings): IMediaImport;
var Request: IMediaImport;
begin
  Request := TMediaImport.Create(Sources);
  Result := Request;
  TThread.CreateAnonymousThread(procedure begin Request.Execute; end).Start;
end;

end.
