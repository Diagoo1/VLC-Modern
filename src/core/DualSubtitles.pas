unit DualSubtitles;

interface

function BuildDualSRT(const Primary, Secondary, Destination, FontName: string): Boolean;

implementation

uses System.SysUtils, System.Classes, System.IOUtils, System.RegularExpressions;

function Timestamp(const Value: string; out Milliseconds: Int64): Boolean;
begin
  Result := False;
  var Parts := Trim(Value).Replace(',', ':').Replace('.', ':').Split([':']);
  if Length(Parts) <> 4 then Exit;
  var H, M, S, MS: Integer;
  if not TryStrToInt(Parts[0], H) or not TryStrToInt(Parts[1], M) or
     not TryStrToInt(Parts[2], S) or not TryStrToInt(Parts[3], MS) then Exit;
  if (H < 0) or (H > 999) or (M < 0) or (M > 59) or (S < 0) or
     (S > 59) or (MS < 0) or (MS > 999) then Exit;
  Milliseconds := ((Int64(H) * 60 + M) * 60 + S) * 1000 + MS;
  Result := True;
end;

function ASSTime(Value: Int64): string;
begin
  Result := Format('%d:%.2d:%.2d.%.2d',
    [Value div 3600000, (Value div 60000) mod 60, (Value div 1000) mod 60, (Value div 10) mod 100]);
end;

function BuildDualSRT(const Primary, Secondary, Destination, FontName: string): Boolean;
var Output: TStringList;
  function AppendSRT(const Path, Style: string): Integer;
  var Lines: TStringList; I, Separator: Integer; StartTime, EndTime: Int64; Text, Line: string;
  begin
    Result := 0;
    var Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyNone);
    try
      if Stream.Size > 4 * 1024 * 1024 then Exit;
    finally Stream.Free; end;
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(Path, TEncoding.UTF8);
      I := 0;
      while I < Lines.Count do
      begin
        Separator := Pos('-->', Lines[I]);
        if (Separator = 0) or not Timestamp(Copy(Lines[I], 1, Separator - 1), StartTime) or
          not Timestamp(Copy(Trim(Copy(Lines[I], Separator + 3, MaxInt)), 1, 12), EndTime) or
          (EndTime <= StartTime) then begin Inc(I); Continue; end;
        Inc(I);
        Text := '';
        while (I < Lines.Count) and (Trim(Lines[I]) <> '') do
        begin
          Line := TRegEx.Replace(Lines[I], '</?(?:b|i|u|font)(?:\s[^>]*)?>', '', [roIgnoreCase]);
          // Text from SRT is never interpreted as ASS drawing/override commands.
          Line := Line.Replace('\', #$FF3C).Replace('{', #$FF5B).Replace('}', #$FF5D);
          if Text <> '' then Text := Text + '\N';
          Text := Text + Line;
          Inc(I);
        end;
        if Text <> '' then
        begin
          Output.Add('Dialogue: 0,' + ASSTime(StartTime) + ',' + ASSTime(EndTime) + ',' + Style + ',,0,0,0,,' + Text);
          Inc(Result);
          if Result >= 50000 then raise EReadError.Create('Subtitle cue limit exceeded.');
        end;
      end;
    finally Lines.Free; end;
  end;
begin
  Result := False;
  if not FileExists(Primary) or not FileExists(Secondary) then Exit;
  Output := TStringList.Create;
  try
    Output.Add('[Script Info]');
    Output.Add('ScriptType: v4.00+');
    Output.Add('PlayResX: 1920');
    Output.Add('PlayResY: 1080');
    Output.Add('WrapStyle: 0');
    Output.Add('[V4+ Styles]');
    Output.Add('Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding');
    var Font := FontName.Replace(',', ' ').Replace(#13, '').Replace(#10, '');
    if Font = '' then Font := 'Segoe UI';
    Output.Add('Style: Primary,' + Font + ',44,&H00FFFFFF,&H00FFFFFF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,2,1,2,48,48,48,1');
    Output.Add('Style: Secondary,' + Font + ',44,&H00FFFFFF,&H00FFFFFF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,2,1,8,48,48,48,1');
    Output.Add('[Events]');
    Output.Add('Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text');
    if (AppendSRT(Primary, 'Primary') = 0) or (AppendSRT(Secondary, 'Secondary') = 0) then Exit;
    Output.SaveToFile(Destination, TEncoding.UTF8);
    Result := True;
  finally Output.Free; end;
end;

end.
