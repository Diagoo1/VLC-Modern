unit Lut3D;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math;

type
  TLutRGB = record
    R, G, B: Single;
  end;

  TLut3DProfile = record
    Title: string;
    Size: Integer;
    EntryCount: Integer;
    Contrast: Single;
    Brightness: Single;
    Gamma: Single;
    Saturation: Single;
    Hue: Single;
    LatticeRGBA: TArray<Single>;
    class function LoadFromCube(const AFilePath: string; out AProfile: TLut3DProfile; out AError: string): Boolean; static;
  end;

implementation

class function TLut3DProfile.LoadFromCube(const AFilePath: string; out AProfile: TLut3DProfile; out AError: string): Boolean;
var
  Lines: TStringList;
  I, N, ExpectedCount, MidIdx, RIdx, GIdx, BIdx: Integer;
  Line, UpperLine: string;
  Parts: TArray<string>;
  Entries: TArray<TLutRGB>;
  FS: TFormatSettings;
  ValR, ValG, ValB: Single;
  BlackLuma, WhiteLuma, MidLuma, PrimSat,AvgPrimSat: Single;
  RedCorner, GreenCorner, BlueCorner: TLutRGB;
begin
  Result := False;
  AError := '';
  AProfile := Default(TLut3DProfile);
  AProfile.Contrast := 1.0;
  AProfile.Brightness := 1.0;
  AProfile.Gamma := 1.0;
  AProfile.Saturation := 1.0;
  AProfile.Hue := 0.0;

  if not TFile.Exists(AFilePath) then
  begin
    AError := '3D LUT file not found';
    Exit;
  end;

  FS := TFormatSettings.Invariant;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFilePath, TEncoding.UTF8);
    N := 0;
    SetLength(Entries, 0);

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if (Line = '') or Line.StartsWith('#') then
        Continue;

      UpperLine := UpperCase(Line);
      if UpperLine.StartsWith('TITLE') then
      begin
        AProfile.Title := Trim(Copy(Line, 6, MaxInt)).DeQuotedString('"');
        Continue;
      end;

      if UpperLine.StartsWith('LUT_3D_SIZE') then
      begin
        Parts := Line.Split([' ', #9], TStringSplitOptions.ExcludeEmpty);
        if (Length(Parts) < 2) or not TryStrToInt(Parts[1], N) or (N < 2) or (N > 128) then
        begin
          AError := 'Invalid LUT_3D_SIZE directive';
          Exit;
        end;
        AProfile.Size := N;
        Continue;
      end;

      if UpperLine.StartsWith('DOMAIN_MIN') or UpperLine.StartsWith('DOMAIN_MAX') or
         UpperLine.StartsWith('LUT_1D_SIZE') then
        Continue;

      Parts := Line.Split([' ', #9], TStringSplitOptions.ExcludeEmpty);
      if Length(Parts) >= 3 then
      begin
        if TryStrToFloat(Parts[0], ValR, FS) and
           TryStrToFloat(Parts[1], ValG, FS) and
           TryStrToFloat(Parts[2], ValB, FS) then
        begin
          var Idx := Length(Entries);
          SetLength(Entries, Idx + 1);
          Entries[Idx].R := EnsureRange(ValR, 0.0, 1.0);
          Entries[Idx].G := EnsureRange(ValG, 0.0, 1.0);
          Entries[Idx].B := EnsureRange(ValB, 0.0, 1.0);
        end;
      end;
    end;

    if AProfile.Size < 2 then
    begin
      AError := 'Missing or invalid LUT_3D_SIZE in .cube file';
      Exit;
    end;

    ExpectedCount := AProfile.Size * AProfile.Size * AProfile.Size;
    if Length(Entries) < ExpectedCount then
    begin
      AError := Format('Incomplete .cube data: expected %d entries, found %d', [ExpectedCount, Length(Entries)]);
      Exit;
    end;

    AProfile.EntryCount := Length(Entries);
    SetLength(AProfile.LatticeRGBA, ExpectedCount * 4);
    for I := 0 to ExpectedCount - 1 do
    begin
      AProfile.LatticeRGBA[I * 4 + 0] := Entries[I].R;
      AProfile.LatticeRGBA[I * 4 + 1] := Entries[I].G;
      AProfile.LatticeRGBA[I * 4 + 2] := Entries[I].B;
      AProfile.LatticeRGBA[I * 4 + 3] := 1.0;
    end;
    if AProfile.Title = '' then
      AProfile.Title := TPath.GetFileNameWithoutExtension(AFilePath);

    // .cube indexing: R changes fastest, then G, then B: idx = r + N * (g + N * b)
    BlackLuma := 0.2126 * Entries[0].R + 0.7152 * Entries[0].G + 0.0722 * Entries[0].B;
    WhiteLuma := 0.2126 * Entries[ExpectedCount - 1].R + 0.7152 * Entries[ExpectedCount - 1].G + 0.0722 * Entries[ExpectedCount - 1].B;
    MidIdx := (N div 2) + N * ((N div 2) + N * (N div 2));
    MidLuma := 0.2126 * Entries[MidIdx].R + 0.7152 * Entries[MidIdx].G + 0.0722 * Entries[MidIdx].B;

    // Contrast from black-to-white span, Brightness from black lift + white peak
    AProfile.Contrast := EnsureRange(WhiteLuma - BlackLuma, 0.4, 1.8);
    AProfile.Brightness := EnsureRange(1.0 + (BlackLuma * 0.5) + ((WhiteLuma - 1.0) * 0.3), 0.5, 1.5);

    // Gamma curve from midtone response
    if (MidLuma > 0.05) and (MidLuma < 0.95) then
      AProfile.Gamma := EnsureRange(Ln(0.5) / Ln(MidLuma), 0.5, 2.0)
    else
      AProfile.Gamma := 1.0;

    // Saturation from primary R, G, B corner chroma spread
    RIdx := (N - 1);
    GIdx := N * (N - 1);
    BIdx := N * N * (N - 1);
    RedCorner := Entries[RIdx];
    GreenCorner := Entries[GIdx];
    BlueCorner := Entries[BIdx];

    PrimSat :=
      (MaxValue([RedCorner.R, RedCorner.G, RedCorner.B]) - MinValue([RedCorner.R, RedCorner.G, RedCorner.B])) +
      (MaxValue([GreenCorner.R, GreenCorner.G, GreenCorner.B]) - MinValue([GreenCorner.R, GreenCorner.G, GreenCorner.B])) +
      (MaxValue([BlueCorner.R, BlueCorner.G, BlueCorner.B]) - MinValue([BlueCorner.R, BlueCorner.G, BlueCorner.B]));
    AvgPrimSat := PrimSat / 3.0;
    AProfile.Saturation := EnsureRange(AvgPrimSat, 0.0, 2.2);

    // Subtle warm/cool hue shift from mid-gray tint
    AProfile.Hue := EnsureRange((Entries[MidIdx].R - Entries[MidIdx].B) * 35.0, -45.0, 45.0);

    Result := True;
  finally
    Lines.Free;
  end;
end;

end.
