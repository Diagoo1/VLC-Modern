unit SeekPreview;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  Vcl.Graphics, Vcl.ExtCtrls, LibVLC;

type
  TRoundedPreviewImage = class(TImage)
  protected
    procedure Paint; override;
  end;

  // Decoder callbacks only copy pixels. All VCL work stays on the UI thread.
  TSeekPreview = class
  private
    FInstance: Plibvlc_instance_t;
    FPlayer: Plibvlc_media_player_t;
    FMedia: Plibvlc_media_t;
    FGuard: TCriticalSection;
    FPixels, FFrame: TBytes;
    FPlane: Pointer;
    FPath: string;
    FTarget, FRequested: Int64;
    FWaitingForFrame: Boolean;
    FReady: Boolean;
    FTimer: TTimer;
    FImage: TImage;
    FLastSeek: UInt64;
    procedure Tick(Sender: TObject);
  public
    constructor Create(Instance: Plibvlc_instance_t; Image: TImage);
    destructor Destroy; override;
    procedure Request(const Path: string; TimeMs: Int64);
    procedure Suspend;
    function DiagnosticState:string;
  end;

implementation

uses Winapi.GDIPAPI, Winapi.GDIPOBJ, CurvedControls, Vcl.Controls;

type TPreviewGraphicAccess = class(TGraphicControl);

procedure TRoundedPreviewImage.Paint;
var G: TGPGraphics; Bitmap: TGPBitmap; Texture: TGPTextureBrush; Path: TGPGraphicsPath; D: Single;
    PaintCanvas: TCanvas;
begin
  // TImage.Canvas edits Picture.Bitmap and raises OnChange. Painting through
  // it creates a self-invalidating loop and destroys the decoded frame.
  PaintCanvas := TPreviewGraphicAccess(Self).Canvas;
  PaintCanvas.Brush.Color := DP_COLOR_BG;
  PaintCanvas.FillRect(ClientRect);
  if Picture.Graphic = nil then Exit;
  if not (Picture.Graphic is TBitmap) or Picture.Graphic.Empty then Exit;
  Bitmap := TGPBitmap.Create(Picture.Bitmap.Handle, 0);
  G := TGPGraphics.Create(PaintCanvas.Handle);
  Path := TGPGraphicsPath.Create;
  Texture := TGPTextureBrush.Create(Bitmap, WrapModeClamp);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    Texture.ScaleTransform(Width / Picture.Bitmap.Width, Height / Picture.Bitmap.Height);
    D := 16;
    Path.AddArc(0, 0, D, D, 180, 90);
    Path.AddArc(Width - D, 0, D, D, 270, 90);
    Path.AddArc(Width - D, Height - D, D, D, 0, 90);
    Path.AddArc(0, Height - D, D, D, 90, 90);
    Path.CloseFigure;
    G.FillPath(Texture, Path);
  finally Texture.Free; Path.Free; G.Free; Bitmap.Free; end;
end;

type
  TLock = function(Opaque: Pointer; Planes: PPointer): Pointer; cdecl;
  TUnlock = procedure(Opaque, Picture: Pointer; Planes: PPointer); cdecl;
  TDisplay = procedure(Opaque, Picture: Pointer); cdecl;
  TSetCallbacks = procedure(Player: Plibvlc_media_player_t; Lock: TLock;
    Unlock: TUnlock; Display: TDisplay; Opaque: Pointer); cdecl;
  TSetFormat = procedure(Player: Plibvlc_media_player_t; Chroma: PAnsiChar;
    Width, Height, Pitch: Cardinal); cdecl;

function LockFrame(Opaque: Pointer; Planes: PPointer): Pointer; cdecl;
begin
  Planes^ := TSeekPreview(Opaque).FPlane;
  Result := nil;
end;

procedure UnlockFrame(Opaque, Picture: Pointer; Planes: PPointer); cdecl;
var P: TSeekPreview;
begin
  P := TSeekPreview(Opaque);
  P.FGuard.Enter;
  try
    Move(P.FPlane^, P.FFrame[0], Length(P.FFrame));
    P.FReady := True;
  finally P.FGuard.Leave; end;
end;

constructor TSeekPreview.Create(Instance: Plibvlc_instance_t; Image: TImage);
var Callbacks: TSetCallbacks; Format: TSetFormat; Chroma: AnsiString;
begin
  inherited Create;
  FGuard := TCriticalSection.Create;
  FInstance := Instance;
  SetLength(FPixels, 176 * 100 * 4 + 31);
  FPlane := Pointer((NativeUInt(@FPixels[0]) + 31) and not NativeUInt(31));
  SetLength(FFrame, 176 * 100 * 4);
  FImage := Image;
  FRequested := -1;
  FPlayer := libvlc_media_player_new(Instance);
  @Callbacks := GetProcAddress(GetModuleHandle('libvlc.dll'), 'libvlc_video_set_callbacks');
  @Format := GetProcAddress(GetModuleHandle('libvlc.dll'), 'libvlc_video_set_format');
  if (FPlayer = nil) or not Assigned(Callbacks) or not Assigned(Format) then
    raise Exception.Create('Video preview decoder unavailable');
  Callbacks(FPlayer, LockFrame, UnlockFrame, nil, Self);
  Chroma := 'RV32';
  Format(FPlayer, PAnsiChar(Chroma), 176, 100, 176 * 4);
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 50;
  FTimer.OnTimer := Tick;
end;

destructor TSeekPreview.Destroy;
begin
  if FTimer <> nil then
  begin
    FTimer.Enabled := False;
    FTimer.Free;
    FTimer := nil;
  end;
  if FPlayer <> nil then
  begin
    try
      libvlc_media_player_stop(FPlayer);
      libvlc_media_player_release(FPlayer);
    except
    end;
    FPlayer := nil;
  end;
  if FMedia <> nil then
  begin
    try
      libvlc_media_release(FMedia);
    except
    end;
    FMedia := nil;
  end;
  FGuard.Free;
  inherited;
end;

procedure TSeekPreview.Request(const Path: string; TimeMs: Int64);
var Encoded, Option: UTF8String;
begin
  // Live streams cannot seek; do not create a second network connection.
  if not FileExists(Path) then Exit;
  if FPath <> Path then
  begin
    FImage.Picture.Assign(nil);
    if FPlayer <> nil then libvlc_media_player_stop(FPlayer);
    if FMedia <> nil then
    begin
      libvlc_media_release(FMedia);
      FMedia := nil;
    end;
    Encoded := UTF8Encode(Path);
    FMedia := libvlc_media_new_path(FInstance, PAnsiChar(Encoded));
    if FMedia = nil then Exit;
    Option := ':no-audio';
    libvlc_media_add_option(FMedia, PAnsiChar(Option));
    Option := ':no-sub-autodetect-file';
    libvlc_media_add_option(FMedia, PAnsiChar(Option));
    Option := ':no-osd';
    libvlc_media_add_option(FMedia, PAnsiChar(Option));
    Option := ':no-spu';
    libvlc_media_add_option(FMedia, PAnsiChar(Option));
    Option := ':avcodec-hw=none';
    libvlc_media_add_option(FMedia, PAnsiChar(Option));
    libvlc_media_player_set_media(FPlayer, FMedia);
    FPath := Path;
    FRequested := -1;
    FWaitingForFrame := False;
    FReady := False;
    libvlc_media_player_play(FPlayer);
  end;
  FTarget := TimeMs;
  if FTimer <> nil then FTimer.Enabled := True;
end;

procedure TSeekPreview.Suspend;
begin
  if FTimer <> nil then FTimer.Enabled := False;
  if FPlayer <> nil then libvlc_media_player_set_pause(FPlayer, 1);
  if FWaitingForFrame then FRequested := -1;
  FWaitingForFrame := False;
end;

function TSeekPreview.DiagnosticState:string;
begin
  Result:=Format('target=%d requested=%d time=%d ready=%s visible=%s state=%d',[FTarget,FRequested,libvlc_media_player_get_time(FPlayer),BoolToStr(FReady,True),BoolToStr(FImage.Parent.Visible,True),Ord(libvlc_media_player_get_state(FPlayer))]);
end;

procedure TSeekPreview.Tick(Sender: TObject);
var Bmp: TBitmap; Row: Integer;
begin
  if (FImage = nil) or (FImage.Parent = nil) or not FImage.Parent.Showing then
  begin
    Suspend;
    Exit;
  end;
  if (FTarget <> FRequested) and
     (GetTickCount64 - FLastSeek >= 100) and
     (not FWaitingForFrame or (GetTickCount64 - FLastSeek >= 250)) and
     (libvlc_media_player_is_seekable(FPlayer) <> 0) then
  begin
    FGuard.Enter;
    try
      FReady := False;
    finally FGuard.Leave; end;
    FRequested := FTarget;
    FWaitingForFrame := True;
    FLastSeek := GetTickCount64;
    libvlc_media_player_set_time(FPlayer, FRequested);
    libvlc_media_player_set_pause(FPlayer, 0);
  end;
  if not FWaitingForFrame or (FRequested < 0) or
     (Abs(libvlc_media_player_get_time(FPlayer) - FRequested) > 700) then Exit;
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf32bit;
    Bmp.SetSize(176, 100);
    FGuard.Enter;
    try
      if not FReady then Exit;
      for Row := 0 to 99 do
        Move(FFrame[Row * 176 * 4], Bmp.ScanLine[Row]^, 176 * 4);
      FReady := False;
    finally FGuard.Leave; end;
    FWaitingForFrame := False;
    FImage.Picture.Assign(Bmp);
    FImage.Visible := True;
  finally Bmp.Free; end;
  libvlc_media_player_set_pause(FPlayer, 1);
end;

end.
