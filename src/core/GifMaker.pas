unit GifMaker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.SyncObjs,
  System.IOUtils, System.Types, System.Math, Vcl.Graphics, Vcl.Imaging.GIFImg, LibVLC;

type
  TGifProgress = reference to procedure(Current, Total: Integer);
  TGifComplete = reference to procedure(const OutputPath: string; Success: Boolean; const ErrorMsg: string);

  TGifMaker = class
  public
    class function BuildAndSaveGif(
      const ADestFolder: string;
      const ABaseName: string;
      const AFrames: TArray<TBitmap>;
      AFps: Integer
    ): string;

    class procedure GenerateGifAsync(
      AInstance: Plibvlc_instance_t;
      const AFilePath: string;
      const ADestFolder: string;
      AStartMs: Int64;
      ADurationMs: Int64;
      AFps: Integer = 10;
      AWidth: Integer = 480;
      OnProgress: TGifProgress = nil;
      OnComplete: TGifComplete = nil
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

  TGifFrameContext = record
    Plane: Pointer;
    FrameBytes: TBytes;
    Guard: TCriticalSection;
    ReadyEvent: TEvent;
    FrameReady: Boolean;
    Width: Integer;
    Height: Integer;
  end;
  PGifFrameContext = ^TGifFrameContext;

function GifLock(Opaque: Pointer; Planes: PPointer): Pointer; cdecl;
var
  Ctx: PGifFrameContext;
begin
  Ctx := PGifFrameContext(Opaque);
  Planes^ := Ctx.Plane;
  Result := nil;
end;

procedure GifUnlock(Opaque, Picture: Pointer; Planes: PPointer); cdecl;
var
  Ctx: PGifFrameContext;
begin
  Ctx := PGifFrameContext(Opaque);
  if (Ctx <> nil) and (Ctx.Guard <> nil) then
  begin
    Ctx.Guard.Enter;
    try
      Move(Ctx.Plane^, Ctx.FrameBytes[0], Ctx.Width * Ctx.Height * 4);
      Ctx.FrameReady := True;
      if Ctx.ReadyEvent <> nil then Ctx.ReadyEvent.SetEvent;
    finally
      Ctx.Guard.Leave;
    end;
  end;
end;

procedure GifDisplay(Opaque, Picture: Pointer); cdecl;
begin
end;

class function TGifMaker.BuildAndSaveGif(
  const ADestFolder: string;
  const ABaseName: string;
  const AFrames: TArray<TBitmap>;
  AFps: Integer
): string;
var
  Gif: TGIFImage;
  GCE: TGIFGraphicControlExtension;
  LoopExt: TGIFAppExtNSLoop;
  I, DelayVal: Integer;
  OutFileName, OutPath: string;
begin
  Result := '';
  if Length(AFrames) = 0 then Exit;

  if not TDirectory.Exists(ADestFolder) then
    TDirectory.CreateDirectory(ADestFolder);

  OutFileName := Format('Animation_%s_%s.gif', [
    TPath.GetFileNameWithoutExtension(ABaseName),
    FormatDateTime('yyyymmdd_hhnnss', Now)
  ]);
  OutPath := TPath.Combine(ADestFolder, OutFileName);

  Gif := TGIFImage.Create;
  try
    DelayVal := EnsureRange(Round(100 / Max(1, AFps)), 1, 100);

    for I := 0 to High(AFrames) do
    begin
      Gif.Add(AFrames[I]);
      GCE := TGIFGraphicControlExtension.Create(Gif.Images[I]);
      GCE.Delay := DelayVal;
      GCE.Disposal := dmNone;
      Gif.Images[I].Extensions.Add(GCE);
    end;

    // Infinite looping extension
    LoopExt := TGIFAppExtNSLoop.Create(Gif.Images[0]);
    LoopExt.Loops := 0; // 0 = Loop continuously
    Gif.Images[0].Extensions.Add(LoopExt);

    Gif.OptimizeColorMap;
    Gif.SaveToFile(OutPath);
    Result := OutPath;
  finally
    Gif.Free;
  end;
end;

class procedure TGifMaker.GenerateGifAsync(
  AInstance: Plibvlc_instance_t;
  const AFilePath: string;
  const ADestFolder: string;
  AStartMs: Int64;
  ADurationMs: Int64;
  AFps: Integer;
  AWidth: Integer;
  OnProgress: TGifProgress;
  OnComplete: TGifComplete
);
begin
  if (AInstance = nil) or not TFile.Exists(AFilePath) then
  begin
    if Assigned(OnComplete) then
      OnComplete('', False, 'Media file or LibVLC instance not available');
    Exit;
  end;

  TThread.CreateAnonymousThread(
    procedure
    var
      VlcLib: HMODULE;
      SetCallbacks: TSetCallbacks;
      SetFormat: TSetFormat;
      Media: Plibvlc_media_t;
      Player: Plibvlc_media_player_t;
      Context: TGifFrameContext;
      Opt: UTF8String;
      TotalMs, StepMs, TargetTime: Int64;
      FrameCount, FrameW, FrameH, I: Integer;
      Frames: TArray<TBitmap>;
      Bmp: TBitmap;
      FinalGifPath: string;
      Success: Boolean;
      ErrStr: string;
      VidW, VidH: Cardinal;
    begin
      Success := False;
      ErrStr := '';
      FinalGifPath := '';
      VlcLib := GetModuleHandle('libvlc.dll');
      if VlcLib = 0 then
      begin
        if Assigned(OnComplete) then
          TThread.Synchronize(nil, TThreadProcedure(procedure begin OnComplete('', False, 'libvlc.dll not loaded'); end));
        Exit;
      end;

      @SetCallbacks := GetProcAddress(VlcLib, 'libvlc_video_set_callbacks');
      @SetFormat := GetProcAddress(VlcLib, 'libvlc_video_set_format');
      if not Assigned(SetCallbacks) or not Assigned(SetFormat) then
      begin
        if Assigned(OnComplete) then
          TThread.Synchronize(nil, TThreadProcedure(procedure begin OnComplete('', False, 'Callback APIs unavailable'); end));
        Exit;
      end;

      FrameCount := EnsureRange(Round((ADurationMs / 1000) * AFps), 4, 60);
      StepMs := Max(50, ADurationMs div FrameCount);

      Player := libvlc_media_player_new(AInstance);
      if Player = nil then
      begin
        if Assigned(OnComplete) then
          TThread.Synchronize(nil, TThreadProcedure(procedure begin OnComplete('', False, 'Failed to create player'); end));
        Exit;
      end;

      try
        Media := libvlc_media_new_path(AInstance, PAnsiChar(UTF8Encode(AFilePath)));
        if Media = nil then
        begin
          if Assigned(OnComplete) then
            TThread.Synchronize(nil, TThreadProcedure(procedure begin OnComplete('', False, 'Failed to open media'); end));
          Exit;
        end;

        try
          Opt := ':no-audio'; libvlc_media_add_option(Media, PAnsiChar(Opt));
          Opt := ':no-sub-autodetect-file'; libvlc_media_add_option(Media, PAnsiChar(Opt));
          Opt := ':no-osd'; libvlc_media_add_option(Media, PAnsiChar(Opt));
          Opt := ':no-spu'; libvlc_media_add_option(Media, PAnsiChar(Opt));
          Opt := ':avcodec-hw=none'; libvlc_media_add_option(Media, PAnsiChar(Opt));

          libvlc_media_player_set_media(Player, Media);

          FrameW := AWidth;
          FrameH := Round(AWidth * (9.0 / 16.0));

          Context.Width := FrameW;
          Context.Height := FrameH;
          Context.Guard := TCriticalSection.Create;
          Context.ReadyEvent := TEvent.Create(nil, False, False, '');
          Context.Plane := AllocMem(FrameW * FrameH * 4);
          SetLength(Context.FrameBytes, FrameW * FrameH * 4);
          Context.FrameReady := False;

          try
            SetCallbacks(Player, GifLock, GifUnlock, nil, @Context);
            SetFormat(Player, 'RV32', FrameW, FrameH, FrameW * 4);

            libvlc_media_player_play(Player);

            // Wait up to 1 second for length
            TotalMs := 0;
            for I := 1 to 20 do
            begin
              Sleep(50);
              if Assigned(libvlc_media_player_get_length) then
                TotalMs := libvlc_media_player_get_length(Player);
              if TotalMs > 0 then Break;
            end;
            if TotalMs <= 0 then TotalMs := AStartMs + ADurationMs;

            if Assigned(libvlc_video_get_size) then
            begin
              VidW := 0; VidH := 0;
              if (libvlc_video_get_size(Player, 0, @VidW, @VidH) = 0) and (VidW > 0) and (VidH > 0) then
                FrameH := Max(100, Round(AWidth * (VidH / VidW)));
            end;

            SetLength(Frames, FrameCount);
            for I := 0 to FrameCount - 1 do
            begin
              TargetTime := AStartMs + (I * StepMs);
              if TargetTime >= TotalMs then TargetTime := TotalMs - 100;
              if TargetTime < 0 then TargetTime := 0;

              Context.Guard.Enter;
              try
                Context.FrameReady := False;
                Context.ReadyEvent.ResetEvent;
              finally
                Context.Guard.Leave;
              end;

              libvlc_media_player_set_time(Player, TargetTime);

              if Context.ReadyEvent.WaitFor(800) = wrSignaled then
              begin
                Bmp := TBitmap.Create;
                Bmp.PixelFormat := pf32bit;
                Bmp.SetSize(FrameW, FrameH);

                Context.Guard.Enter;
                try
                  for var Y := 0 to FrameH - 1 do
                  begin
                    var SrcRow := @Context.FrameBytes[Y * FrameW * 4];
                    var DstRow := Bmp.ScanLine[Y];
                    Move(SrcRow^, DstRow^, FrameW * 4);
                  end;
                finally
                  Context.Guard.Leave;
                end;

                Frames[I] := Bmp;
              end
              else
              begin
                Bmp := TBitmap.Create;
                Bmp.PixelFormat := pf32bit;
                Bmp.SetSize(FrameW, FrameH);
                Bmp.Canvas.Brush.Color := RGB(20, 20, 20);
                Bmp.Canvas.FillRect(Rect(0, 0, FrameW, FrameH));
                Frames[I] := Bmp;
              end;

              if Assigned(OnProgress) then
              begin
                var CurIdx := I + 1;
                TThread.Synchronize(nil, TThreadProcedure(procedure begin OnProgress(CurIdx, FrameCount); end));
              end;
            end;

            libvlc_media_player_stop(Player);

            // Assemble into animated GIF
            FinalGifPath := TGifMaker.BuildAndSaveGif(ADestFolder, AFilePath, Frames, AFps);
            Success := (FinalGifPath <> '') and TFile.Exists(FinalGifPath);
            if not Success then ErrStr := 'Failed to write animated GIF file';

            for var F := 0 to High(Frames) do
              Frames[F].Free;

          finally
            FreeMem(Context.Plane);
            Context.ReadyEvent.Free;
            Context.Guard.Free;
          end;

        finally
          libvlc_media_release(Media);
        end;

      finally
        libvlc_media_player_release(Player);
      end;

      if Assigned(OnComplete) then
      begin
        var ResPath := FinalGifPath;
        var ResSuccess := Success;
        var ResErr := ErrStr;
        TThread.Synchronize(nil,
          TThreadProcedure(
            procedure
            begin
              OnComplete(ResPath, ResSuccess, ResErr);
            end
          )
        );
      end;
    end
  ).Start;
end;

end.
