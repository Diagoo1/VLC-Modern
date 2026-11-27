unit ThumbnailSheet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.SyncObjs,
  System.IOUtils, Vcl.Graphics, Vcl.Imaging.pngimage, LibVLC;

type
  TThumbnailSheetProgress = reference to procedure(Current, Total: Integer);
  TThumbnailSheetComplete = reference to procedure(const OutputPath: string; Success: Boolean; const ErrorMsg: string);

  TThumbnailSheetGenerator = class
  public
    class function FormatTime(Ms: Int64): string;
    class function FormatFileSize(Bytes: Int64): string;

    class function CompositeAndSaveSheet(
      const AFilePath: string;
      const ADestFolder: string;
      AColumns, ARows: Integer;
      ADurationMs: Int64;
      AFileSize: Int64;
      const AResolution: string;
      const ATileBitmaps: TArray<TBitmap>;
      const ATimestamps: TArray<Int64>
    ): string;

    class procedure GenerateAsync(
      AInstance: Plibvlc_instance_t;
      const AFilePath: string;
      const ADestFolder: string;
      AColumns: Integer = 4;
      ARows: Integer = 3;
      ATotalDurationMs: Int64 = 0;
      OnProgress: TThumbnailSheetProgress = nil;
      OnComplete: TThumbnailSheetComplete = nil
    );
  end;

implementation

type
  TLock = function(Opaque: Pointer; Planes: PPointer): Pointer; cdecl;
  TUnlock = procedure(Opaque, Picture: Pointer; Planes: PPointer); cdecl;
  TDisplay = procedure(Opaque, Picture: Pointer); cdecl;
  TSetCallbacks = procedure(Player: Plibvlc_media_player_t; Lock: TLock;
    Unlock: TUnlock; Display: TDisplay; Opaque: Pointer); cdecl;
  TSetFormat = procedure(Player: Plibvlc_media_player_t; Chroma: PAnsiChar;
    Width, Height, Pitch: Cardinal); cdecl;

  TFrameContext = record
    Plane: Pointer;
    FrameBytes: TBytes;
    Guard: TCriticalSection;
    ReadyEvent: TEvent;
    FrameReady: Boolean;
    Width: Integer;
    Height: Integer;
  end;
  PFrameContext = ^TFrameContext;

function SheetLock(Opaque: Pointer; Planes: PPointer): Pointer; cdecl;
var
  Ctx: PFrameContext;
begin
  Ctx := PFrameContext(Opaque);
  Planes^ := Ctx.Plane;
  Result := nil;
end;

procedure SheetUnlock(Opaque, Picture: Pointer; Planes: PPointer); cdecl;
var
  Ctx: PFrameContext;
begin
  Ctx := PFrameContext(Opaque);
  if (Ctx <> nil) and (Ctx.Guard <> nil) then
  begin
    Ctx.Guard.Enter;
    try
      Ctx.FrameReady := True;
      if Ctx.ReadyEvent <> nil then
        Ctx.ReadyEvent.SetEvent;
    finally
      Ctx.Guard.Leave;
    end;
  end;
end;

class function TThumbnailSheetGenerator.FormatTime(Ms: Int64): string;
var
  TotalSec, H, M, S: Int64;
begin
  if Ms < 0 then Ms := 0;
  TotalSec := Ms div 1000;
  H := TotalSec div 3600;
  M := (TotalSec mod 3600) div 60;
  S := TotalSec mod 60;
  if H > 0 then
    Result := Format('%.2d:%.2d:%.2d', [H, M, S])
  else
    Result := Format('%.2d:%.2d', [M, S]);
end;

class function TThumbnailSheetGenerator.FormatFileSize(Bytes: Int64): string;
const
  KB = 1024;
  MB = KB * 1024;
  GB = MB * 1024;
begin
  if Bytes >= GB then
    Result := Format('%.2f GB', [Bytes / GB])
  else if Bytes >= MB then
    Result := Format('%.2f MB', [Bytes / MB])
  else if Bytes >= KB then
    Result := Format('%.2f KB', [Bytes / KB])
  else
    Result := Format('%d B', [Bytes]);
end;

class function TThumbnailSheetGenerator.CompositeAndSaveSheet(
  const AFilePath: string;
  const ADestFolder: string;
  AColumns, ARows: Integer;
  ADurationMs: Int64;
  AFileSize: Int64;
  const AResolution: string;
  const ATileBitmaps: TArray<TBitmap>;
  const ATimestamps: TArray<Int64>
): string;
var
  SheetW, HeaderH, Margins, Gutters, DrawTileW, DrawTileH, SheetH: Integer;
  SheetBmp: TBitmap;
  Png: TPngImage;
  Row, Col, I, X, Y: Integer;
  TotalTiles: Integer;
  TimeStr, OutFile, TruncName, MetaText: string;
  TextSz: TSize;
  BadgeR: TRect;
begin
  Result := '';
  SheetW := 1600;
  HeaderH := 105;
  Margins := 18;
  Gutters := 12;

  if AColumns < 1 then AColumns := 4;
  if ARows < 1 then ARows := 3;
  TotalTiles := AColumns * ARows;

  DrawTileW := (SheetW - (Margins * 2) - ((AColumns - 1) * Gutters)) div AColumns;
  DrawTileH := (DrawTileW * 9) div 16;
  SheetH := HeaderH + Margins + (ARows * DrawTileH) + ((ARows - 1) * Gutters) + Margins;

  SheetBmp := TBitmap.Create;
  try
    SheetBmp.PixelFormat := pf32bit;
    SheetBmp.SetSize(SheetW, SheetH);

    // Background
    SheetBmp.Canvas.Brush.Color := $151210; // Dark slate background (#101215)
    SheetBmp.Canvas.FillRect(Rect(0, 0, SheetW, SheetH));

    // Header Background
    SheetBmp.Canvas.Brush.Color := $241E1A; // #1A1E24
    SheetBmp.Canvas.FillRect(Rect(0, 0, SheetW, HeaderH));

    // Accent Line at bottom of header
    SheetBmp.Canvas.Pen.Color := $D200; // Cyan $00D2FF in BGR: $00, $D2, $FF
    SheetBmp.Canvas.Pen.Width := 2;
    SheetBmp.Canvas.MoveTo(0, HeaderH - 1);
    SheetBmp.Canvas.LineTo(SheetW, HeaderH - 1);

    // Header Title (File Name)
    SheetBmp.Canvas.Font.Name := 'Segoe UI';
    SheetBmp.Canvas.Font.Size := 14;
    SheetBmp.Canvas.Font.Style := [fsBold];
    SheetBmp.Canvas.Font.Color := clWhite;
    TruncName := ExtractFileName(AFilePath);
    if Length(TruncName) > 65 then TruncName := Copy(TruncName, 1, 62) + '...';
    SheetBmp.Canvas.TextOut(Margins, 18, TruncName);

    // Header Metadata
    SheetBmp.Canvas.Font.Size := 10;
    SheetBmp.Canvas.Font.Style := [];
    SheetBmp.Canvas.Font.Color := $B8A394; // Slate gray (#94A3B8 in BGR)
    MetaText := Format('File size: %s  |  Resolution: %s  |  Duration: %s  |  VLC Modern',
      [FormatFileSize(AFileSize), AResolution, FormatTime(ADurationMs)]);
    SheetBmp.Canvas.TextOut(Margins, 52, MetaText);

    // Top-Right Player Badge
    SheetBmp.Canvas.Font.Size := 9;
    SheetBmp.Canvas.Font.Style := [fsBold];
    SheetBmp.Canvas.Font.Color := $FFD200; // Cyan
    var BadgeRect := Rect(SheetW - Margins - 120, 24, SheetW - Margins, 56);
    SheetBmp.Canvas.Pen.Color := $FFD200;
    SheetBmp.Canvas.Pen.Width := 1;
    SheetBmp.Canvas.Brush.Color := $302620;
    SheetBmp.Canvas.RoundRect(BadgeRect.Left, BadgeRect.Top, BadgeRect.Right, BadgeRect.Bottom, 8, 8);
    SheetBmp.Canvas.TextOut(BadgeRect.Left + 18, BadgeRect.Top + 6, 'VLC Modern');

    // Draw Tiles
    for Row := 0 to ARows - 1 do
    begin
      for Col := 0 to AColumns - 1 do
      begin
        I := Row * AColumns + Col;
        if I >= TotalTiles then Break;

        X := Margins + Col * (DrawTileW + Gutters);
        Y := HeaderH + Margins + Row * (DrawTileH + Gutters);
        var DestR := Rect(X, Y, X + DrawTileW, Y + DrawTileH);

        // Draw image stretched to cell
        if (I < Length(ATileBitmaps)) and (ATileBitmaps[I] <> nil) and not ATileBitmaps[I].Empty then
        begin
          SetStretchBltMode(SheetBmp.Canvas.Handle, HALFTONE);
          SheetBmp.Canvas.StretchDraw(DestR, ATileBitmaps[I]);
        end
        else
        begin
          SheetBmp.Canvas.Brush.Color := $201C18;
          SheetBmp.Canvas.FillRect(DestR);
        end;

        // Draw Tile Border
        SheetBmp.Canvas.Pen.Color := $3D2F2A; // #2A2F3D
        SheetBmp.Canvas.Pen.Width := 1;
        SheetBmp.Canvas.Brush.Style := bsClear;
        SheetBmp.Canvas.Rectangle(DestR);

        // Draw Timestamp Badge in lower right corner
        if I < Length(ATimestamps) then
          TimeStr := FormatTime(ATimestamps[I])
        else
          TimeStr := '00:00';

        SheetBmp.Canvas.Font.Name := 'Segoe UI';
        SheetBmp.Canvas.Font.Size := 9;
        SheetBmp.Canvas.Font.Style := [fsBold];
        SheetBmp.Canvas.Font.Color := clWhite;
        TextSz := SheetBmp.Canvas.TextExtent(TimeStr);

        BadgeR := Rect(DestR.Right - TextSz.cx - 14, DestR.Bottom - TextSz.cy - 8,
                       DestR.Right - 4, DestR.Bottom - 4);

        SheetBmp.Canvas.Brush.Style := bsSolid;
        SheetBmp.Canvas.Brush.Color := $0A0806; // Deep black
        SheetBmp.Canvas.Pen.Color := $25201C;
        SheetBmp.Canvas.RoundRect(BadgeR.Left, BadgeR.Top, BadgeR.Right, BadgeR.Bottom, 6, 6);
        SheetBmp.Canvas.TextOut(BadgeR.Left + 5, BadgeR.Top + 2, TimeStr);
      end;
    end;

    // Save to PNG
    ForceDirectories(ADestFolder);
    var CleanName := TPath.GetFileNameWithoutExtension(AFilePath);
    if CleanName = '' then CleanName := 'Media';
    for var C in ['\', '/', ':', '*', '?', '"', '<', '>', '|'] do
      CleanName := StringReplace(CleanName, C, '_', [rfReplaceAll]);

    OutFile := IncludeTrailingPathDelimiter(ADestFolder) +
      Format('ContactSheet_%s_%s.png', [CleanName, FormatDateTime('yyyymmdd_hhnnss', Now)]);

    Png := TPngImage.Create;
    try
      Png.Assign(SheetBmp);
      Png.SaveToFile(OutFile);
      Result := OutFile;
    finally
      Png.Free;
    end;
  finally
    SheetBmp.Free;
  end;
end;

class procedure TThumbnailSheetGenerator.GenerateAsync(
  AInstance: Plibvlc_instance_t;
  const AFilePath: string;
  const ADestFolder: string;
  AColumns: Integer;
  ARows: Integer;
  ATotalDurationMs: Int64;
  OnProgress: TThumbnailSheetProgress;
  OnComplete: TThumbnailSheetComplete
);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      Player: Plibvlc_media_player_t;
      Media: Plibvlc_media_t;
      Callbacks: TSetCallbacks;
      FormatFunc: TSetFormat;
      HLib: HMODULE;
      RawPixels: TBytes;
      Ctx: TFrameContext;
      TotalTiles: Integer;
      Duration: Int64;
      FileSize: Int64;
      TileW, TileH: Integer;
      TileBitmaps: TArray<TBitmap>;
      TileTimestamps: TArray<Int64>;
      I, Row: Integer;
      TargetMs: Int64;
      Opt: UTF8String;
      VidW, VidH: Cardinal;
      ResText: string;
      OutFile: string;
    begin
      Player := nil;
      Media := nil;
      Ctx.Guard := nil;
      Ctx.ReadyEvent := nil;

      try
        if not FileExists(AFilePath) then
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete('', False, 'File not found'); end);
          Exit;
        end;

        HLib := GetModuleHandle('libvlc.dll');
        if HLib = 0 then
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete('', False, 'libvlc.dll not loaded'); end);
          Exit;
        end;

        @Callbacks := GetProcAddress(HLib, 'libvlc_video_set_callbacks');
        @FormatFunc := GetProcAddress(HLib, 'libvlc_video_set_format');
        if not Assigned(Callbacks) or not Assigned(FormatFunc) or (AInstance = nil) then
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete('', False, 'VLC video callbacks not available'); end);
          Exit;
        end;

        // Determine File Size
        FileSize := 0;
        try
          var FS := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyNone);
          try
            FileSize := FS.Size;
          finally
            FS.Free;
          end;
        except
        end;

        Duration := ATotalDurationMs;

        // Tile buffer settings (384x216 is standard 16:9 for crisp tiles)
        TileW := 384;
        TileH := 216;
        SetLength(RawPixels, TileW * TileH * 4 + 64);
        Ctx.Plane := Pointer((NativeUInt(@RawPixels[0]) + 31) and not NativeUInt(31));
        SetLength(Ctx.FrameBytes, TileW * TileH * 4);
        Ctx.Guard := TCriticalSection.Create;
        Ctx.ReadyEvent := TSimpleEvent.Create(nil, True, False, '');
        Ctx.Width := TileW;
        Ctx.Height := TileH;
        Ctx.FrameReady := False;

        // Create player and media
        Player := libvlc_media_player_new(AInstance);
        if Player = nil then
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete('', False, 'Failed to create secondary player'); end);
          Exit;
        end;

        Media := libvlc_media_new_path(AInstance, PAnsiChar(UTF8Encode(AFilePath)));
        if Media = nil then
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete('', False, 'Failed to open media'); end);
          Exit;
        end;

        // Apply fast decoding options
        Opt := ':no-audio'; libvlc_media_add_option(Media, PAnsiChar(Opt));
        Opt := ':no-sub-autodetect-file'; libvlc_media_add_option(Media, PAnsiChar(Opt));
        Opt := ':no-osd'; libvlc_media_add_option(Media, PAnsiChar(Opt));
        Opt := ':no-spu'; libvlc_media_add_option(Media, PAnsiChar(Opt));
        Opt := ':avcodec-hw=none'; libvlc_media_add_option(Media, PAnsiChar(Opt));

        libvlc_media_player_set_media(Player, Media);
        Callbacks(Player, SheetLock, SheetUnlock, nil, @Ctx);
        FormatFunc(Player, 'RV32', TileW, TileH, TileW * 4);

        // Start decoding
        libvlc_media_player_play(Player);

        // Wait up to 1 second for stream to open and report duration if needed
        for I := 1 to 20 do
        begin
          Sleep(50);
          if (Duration <= 0) and Assigned(libvlc_media_player_get_length) then
            Duration := libvlc_media_player_get_length(Player);
          if Duration > 0 then Break;
        end;

        if Duration <= 0 then
          Duration := 60000; // Fallback 1 minute if length is unknown

        // Query video dimensions if available
        VidW := 0; VidH := 0;
        if Assigned(libvlc_video_get_size) then
          libvlc_video_get_size(Player, 0, @VidW, @VidH);

        if (VidW > 0) and (VidH > 0) then
          ResText := Format('%dx%d', [VidW, VidH])
        else
          ResText := '1920x1080';

        TotalTiles := AColumns * ARows;
        if TotalTiles < 1 then TotalTiles := 12;
        SetLength(TileBitmaps, TotalTiles);
        SetLength(TileTimestamps, TotalTiles);

        // Extract frames across intervals
        for I := 0 to TotalTiles - 1 do
        begin
          TargetMs := (Duration * Int64(I + 1)) div Int64(TotalTiles + 1);
          TileTimestamps[I] := TargetMs;

          Ctx.Guard.Enter;
          try
            Ctx.FrameReady := False;
            Ctx.ReadyEvent.ResetEvent;
          finally
            Ctx.Guard.Leave;
          end;

          libvlc_media_player_set_time(Player, TargetMs);

          // Wait for frame unlock (timeout 800ms)
          Ctx.ReadyEvent.WaitFor(800);

          // Allocate and fill tile bitmap
          TileBitmaps[I] := TBitmap.Create;
          TileBitmaps[I].PixelFormat := pf32bit;
          TileBitmaps[I].SetSize(TileW, TileH);

          Ctx.Guard.Enter;
          try
            for Row := 0 to TileH - 1 do
              Move(PByte(Ctx.Plane)[Row * TileW * 4], TileBitmaps[I].ScanLine[Row]^, TileW * 4);
          finally
            Ctx.Guard.Leave;
          end;

          if Assigned(OnProgress) then
          begin
            var CurrIdx := I + 1;
            var TotCount := TotalTiles;
            TThread.Queue(nil, procedure begin OnProgress(CurrIdx, TotCount); end);
          end;
        end;

        // Cleanup VLC player now that all frames are in memory
        try
          libvlc_media_player_stop(Player);
          libvlc_media_player_release(Player);
          Player := nil;
          libvlc_media_release(Media);
          Media := nil;
        except
        end;

        // Composite and Save Contact Sheet
        OutFile := CompositeAndSaveSheet(
          AFilePath,
          ADestFolder,
          AColumns,
          ARows,
          Duration,
          FileSize,
          ResText,
          TileBitmaps,
          TileTimestamps
        );

        // Free tile bitmaps
        for I := 0 to High(TileBitmaps) do
          if TileBitmaps[I] <> nil then TileBitmaps[I].Free;

        if (OutFile <> '') and FileExists(OutFile) then
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete(OutFile, True, ''); end);
        end
        else
        begin
          if Assigned(OnComplete) then
            TThread.Queue(nil, procedure begin OnComplete('', False, 'Failed to save composite sheet'); end);
        end;

      except
        on E: Exception do
        begin
          if Assigned(OnComplete) then
          begin
            var Msg := E.Message;
            TThread.Queue(nil, procedure begin OnComplete('', False, Msg); end);
          end;
        end;
      end;

      // Final cleanup
      if Player <> nil then
      try
        libvlc_media_player_stop(Player);
        libvlc_media_player_release(Player);
      except
      end;

      if Media <> nil then
      try
        libvlc_media_release(Media);
      except
      end;

      if Ctx.Guard <> nil then Ctx.Guard.Free;
      if Ctx.ReadyEvent <> nil then Ctx.ReadyEvent.Free;
    end
  ).Start;
end;

end.
