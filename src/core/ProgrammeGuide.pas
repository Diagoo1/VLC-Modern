unit ProgrammeGuide;

interface

uses System.SysUtils, System.Generics.Collections;

type
  TProgramme = record
    StartUTC, EndUTC: TDateTime;
    Title: string;
  end;
  TProgrammeGuide = class
  private
    FChannels: TObjectDictionary<string, TList<TProgramme>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadXML(const Content: string);
    function Describe(const ChannelID: string; NowUTC: TDateTime): string;
  end;

implementation

uses Xml.XMLIntf, Xml.XMLDoc, System.DateUtils;

function XMLTVTime(const Text: string; out Value: TDateTime): Boolean;
var S: string; Offset: Integer;
begin
  Result := False;
  S := Trim(Text);
  if Length(S) < 14 then Exit;
  try
    Value := EncodeDate(StrToInt(Copy(S, 1, 4)), StrToInt(Copy(S, 5, 2)),
      StrToInt(Copy(S, 7, 2))) + EncodeTime(StrToInt(Copy(S, 9, 2)),
      StrToInt(Copy(S, 11, 2)), StrToInt(Copy(S, 13, 2)), 0);
    S := Trim(Copy(S, 15, MaxInt));
    if Length(S) >= 5 then
    begin
      Offset := StrToInt(Copy(S, 2, 2)) * 60 + StrToInt(Copy(S, 4, 2));
      if S[1] = '-' then Offset := -Offset;
      Value := IncMinute(Value, -Offset);
    end;
    Result := True;
  except
    on E: EConvertError do Exit;
  end;
end;

constructor TProgrammeGuide.Create;
begin
  inherited;
  FChannels := TObjectDictionary<string, TList<TProgramme>>.Create([doOwnsValues]);
end;

destructor TProgrammeGuide.Destroy;
begin
  FChannels.Free;
  inherited;
end;

procedure TProgrammeGuide.LoadXML(const Content: string);
var Doc: IXMLDocument; Root, Node, Title: IXMLNode; I: Integer;
    Channel: string; Item: TProgramme; Entries: TList<TProgramme>;
    Parsed: TObjectDictionary<string, TList<TProgramme>>;
begin
  // Do not allow external entities or DTDs supplied by a remote guide.
  if Pos('<!DOCTYPE', UpperCase(Content)) > 0 then
    raise EConvertError.Create('XMLTV documents with a DTD are not supported.');
  Parsed := TObjectDictionary<string, TList<TProgramme>>.Create([doOwnsValues]);
  try
    Doc := LoadXMLData(Content);
    Root := Doc.DocumentElement;
    if (Root = nil) or (Root.NodeName <> 'tv') then
      raise EConvertError.Create('Select a valid XMLTV programme guide.');
    for I := 0 to Root.ChildNodes.Count - 1 do
    begin
      Node := Root.ChildNodes[I];
      if Node.NodeName <> 'programme' then Continue;
      Channel := Node.GetAttribute('channel');
      if (Channel = '') or not XMLTVTime(Node.GetAttribute('start'), Item.StartUTC) or
         not XMLTVTime(Node.GetAttribute('stop'), Item.EndUTC) then Continue;
      Title := Node.ChildNodes.FindNode('title');
      if Title = nil then Continue;
      Item.Title := Title.Text;
      if not Parsed.TryGetValue(Channel, Entries) then
      begin
        Entries := TList<TProgramme>.Create;
        Parsed.Add(Channel, Entries);
      end;
      Entries.Add(Item);
    end;
    FChannels.Free;
    FChannels := Parsed;
    Parsed := nil;
  finally Parsed.Free; end;
end;

function TProgrammeGuide.Describe(const ChannelID: string; NowUTC: TDateTime): string;
var Entries: TList<TProgramme>; Item: TProgramme; Count: Integer;
begin
  Result := '';
  Count := 0;
  if not FChannels.TryGetValue(ChannelID, Entries) then Exit;
  for Item in Entries do
    if Item.EndUTC > NowUTC then
    begin
      Result := Result + FormatDateTime('ddd hh:nn', TTimeZone.Local.ToLocalTime(Item.StartUTC)) +
        '  ' + Item.Title + sLineBreak;
      Inc(Count);
      if Count = 5 then Break;
    end;
end;

end.
