unit WatermarkOSD;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Controls, Vcl.Graphics,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  TWatermarkKind = (wkNone, wkPlay, wkPause);

procedure ShowVideoPlayPauseWatermark(TargetControl: TWinControl; IsPlaying: Boolean);
procedure ShowVideoTextOSD(TargetControl: TWinControl; const AText: string);
procedure CloseAllOSDWindows;
procedure MovePlaybackOSD(Owner: HWND; DX, DY: Integer);
procedure HidePlaybackOSD;
procedure ConfigureTextOSD(DurationMs, FontSize: Integer);

implementation

var GTextDuration: Integer = 2000;
    GTextFontSize: Integer = 18;

procedure ConfigureTextOSD(DurationMs, FontSize: Integer);
begin
  GTextDuration := DurationMs;
  GTextFontSize := FontSize;
end;

const
  WATERMARK_CLASS = 'VLCModern_WatermarkOSD_Wnd';
  TEXTOSD_CLASS   = 'VLCModern_TextOSD_Wnd';

type
  // Pure Win32 Layered Window for Center Play/Pause Watermark
  TWin32WatermarkOSD = class
  private
    FHWnd: HWND;
    FAlpha: Byte;
    FKind: TWatermarkKind;
    FSize: Integer;
    FTimerId: UINT_PTR;
    FHoldCount: Integer;
    procedure CreateOSDWindow;
    procedure RenderWatermark(TargetControl: TWinControl);
    procedure OnTimerTick;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Trigger(TargetControl: TWinControl; IsPlaying: Boolean);
    procedure Hide;
  end;

  // Pure Win32 Layered Window for Top-Left HUD Notification Text
  TWin32TextOSD = class
  private
    FHWnd: HWND;
    FAlpha: Byte;
    FText: string;
    FTimerId: UINT_PTR;
    FHoldCount: Integer;
    procedure CreateOSDWindow;
    procedure RenderTextOSD(TargetControl: TWinControl);
    procedure OnTimerTick;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Trigger(TargetControl: TWinControl; const AText: string);
    procedure Hide;
  end;

var
  GWatermarkOSD: TWin32WatermarkOSD = nil;
  GTextOSD: TWin32TextOSD = nil;
  GClassesRegistered: Boolean = False;

function WatermarkWndProc(AHwnd: HWND; Msg: UINT; WParam: WPARAM; LParam: LPARAM): LRESULT; stdcall;
begin
  case Msg of
    WM_NCDESTROY:
      begin
        // Owned popup HWNDs die when Windows recreates the player HWND.
        // The Delphi renderer survives; it must not retain the dead handle.
        if (GWatermarkOSD<>nil) and (AHwnd=GWatermarkOSD.FHWnd) then
        begin GWatermarkOSD.FHWnd:=0; GWatermarkOSD.FTimerId:=0; end;
        if (GTextOSD<>nil) and (AHwnd=GTextOSD.FHWnd) then
        begin GTextOSD.FHWnd:=0; GTextOSD.FTimerId:=0; end;
      end;
    WM_ERASEBKGND:
      Exit(1);
    WM_PAINT:
      begin
        ValidateRect(AHwnd, nil);
        Exit(0);
      end;
    WM_TIMER:
      begin
        if (GWatermarkOSD <> nil) and (AHwnd = GWatermarkOSD.FHWnd) then
          GWatermarkOSD.OnTimerTick
        else if (GTextOSD <> nil) and (AHwnd = GTextOSD.FHWnd) then
          GTextOSD.OnTimerTick;
        Exit(0);
      end;
    WM_NCHITTEST:
      Exit(HTTRANSPARENT);
  end;
  Result := DefWindowProc(AHwnd, Msg, WParam, LParam);
end;

procedure RegisterOSDClasses;
var
  WC: TWndClassEx;
begin
  if GClassesRegistered then Exit;
  FillChar(WC, SizeOf(WC), 0);
  WC.cbSize := SizeOf(WC);
  WC.style := CS_HREDRAW or CS_VREDRAW;
  WC.lpfnWndProc := @WatermarkWndProc;
  WC.hInstance := HInstance;
  WC.hCursor := LoadCursor(0, IDC_ARROW);
  WC.lpszClassName := WATERMARK_CLASS;
  RegisterClassEx(WC);

  WC.lpszClassName := TEXTOSD_CLASS;
  RegisterClassEx(WC);

  GClassesRegistered := True;
end;

procedure UnregisterOSDClasses;
begin
  if not GClassesRegistered then Exit;
  Winapi.Windows.UnregisterClass(WATERMARK_CLASS, HInstance);
  Winapi.Windows.UnregisterClass(TEXTOSD_CLASS, HInstance);
  GClassesRegistered := False;
end;

{ TWin32WatermarkOSD }

constructor TWin32WatermarkOSD.Create;
begin
  inherited Create;
  FHWnd := 0;
  FAlpha := 0;
  FKind := wkNone;
  FSize := 120;
  FTimerId := 0;
  FHoldCount := 0;
  CreateOSDWindow;
end;

destructor TWin32WatermarkOSD.Destroy;
begin
  Hide;
  if FHWnd <> 0 then
  begin
    DestroyWindow(FHWnd);
    FHWnd := 0;
  end;
  inherited Destroy;
end;

procedure TWin32WatermarkOSD.CreateOSDWindow;
begin
  RegisterOSDClasses;
  FHWnd := CreateWindowEx(
    WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_NOACTIVATE or WS_EX_TOOLWINDOW,
    WATERMARK_CLASS,
    nil,
    WS_POPUP,
    0, 0, FSize, FSize,
    0, 0, HInstance, nil);
end;

procedure TWin32WatermarkOSD.Hide;
begin
  if FTimerId <> 0 then
  begin
    KillTimer(FHWnd, FTimerId);
    FTimerId := 0;
  end;
  if (FHWnd <> 0) and IsWindowVisible(FHWnd) then
    ShowWindow(FHWnd, SW_HIDE);
  FAlpha := 0;
end;

procedure TWin32WatermarkOSD.Trigger(TargetControl: TWinControl; IsPlaying: Boolean);
begin
  if (TargetControl = nil) or not TargetControl.HandleAllocated or not TargetControl.Visible then Exit;
  if not IsWindow(FHWnd) then CreateOSDWindow;
  SetWindowLongPtr(FHWnd, GWLP_HWNDPARENT, GetAncestor(TargetControl.Handle, GA_ROOT));

  if FTimerId <> 0 then
  begin
    KillTimer(FHWnd, FTimerId);
    FTimerId := 0;
  end;

  if IsPlaying then
    FKind := wkPlay
  else
    FKind := wkPause;

  FAlpha := 255;
  FHoldCount := 18; // ~360ms hold time at 20ms ticks
  RenderWatermark(TargetControl);

  FTimerId := SetTimer(FHWnd, 1, 20, nil);
end;

procedure TWin32WatermarkOSD.OnTimerTick;
begin
  if FHoldCount > 0 then
  begin
    Dec(FHoldCount);
    Exit;
  end;

  if FAlpha > 22 then
    Dec(FAlpha, 22)
  else
    FAlpha := 0;

  if FAlpha = 0 then
    Hide
  else
  begin
    // Update alpha via UpdateLayeredWindow
    var Blend: TBLENDFUNCTION;
    Blend.BlendOp := AC_SRC_OVER;
    Blend.BlendFlags := 0;
    Blend.SourceConstantAlpha := FAlpha;
    Blend.AlphaFormat := AC_SRC_ALPHA;
    UpdateLayeredWindow(FHWnd, 0, nil, nil, 0, nil, 0, @Blend, ULW_ALPHA);
  end;
end;

procedure TWin32WatermarkOSD.RenderWatermark(TargetControl: TWinControl);
var
  DC, MemDC: HDC;
  BmpInfo: TBitmapInfo;
  BmpBits: Pointer;
  DIBHandle, OldBmp: HBITMAP;
  Size: TSize;
  PointSrc, PointDest: TPoint;
  Blend: TBLENDFUNCTION;
  GPBmp: TGPBitmap;
  G: TGPGraphics;
  BgBrush, IconBrush, ShadowBrush: TGPSolidBrush;
  RingPen: TGPPen;
  Scale: Single;
  Path: TGPGraphicsPath;
  Pts: array[0..2] of TGPPointF;
  BmpData: TBitmapData;
  LockRect: TGPRect;
  ControlPt: TPoint;
begin
  if (TargetControl = nil) or (FHWnd = 0) then Exit;

  FSize := MulDiv(116, TargetControl.CurrentPPI, 96);
  Size.cx := FSize;
  Size.cy := FSize;

  ControlPt := TargetControl.ClientToScreen(Point(
    (TargetControl.ClientWidth - FSize) div 2,
    (TargetControl.ClientHeight - FSize) div 2));
  PointDest := ControlPt;

  GPBmp := TGPBitmap.Create(Size.cx, Size.cy, PixelFormat32bppPARGB);
  try
    G := TGPGraphics.Create(GPBmp);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHighQuality);

      Scale := FSize / 116.0;

      // Dark translucent circular backdrop (modern YouTube / PotPlayer style)
      BgBrush := TGPSolidBrush.Create(MakeColor(175, 14, 18, 24));
      try
        G.FillEllipse(BgBrush, 4.0 * Scale, 4.0 * Scale, 108.0 * Scale, 108.0 * Scale);
      finally
        BgBrush.Free;
      end;

      // Subtle cyan accent ring around the disc
      RingPen := TGPPen.Create(MakeColor(180, 0, 162, 232), 2.2 * Scale);
      try
        G.DrawEllipse(RingPen, 5.0 * Scale, 5.0 * Scale, 106.0 * Scale, 106.0 * Scale);
      finally
        RingPen.Free;
      end;

      IconBrush := TGPSolidBrush.Create(MakeColor(255, 255, 255, 255));
      try
        if FKind = wkPause then
        begin
          Path := TGPGraphicsPath.Create;
          try
            // Drop shadow
            ShadowBrush := TGPSolidBrush.Create(MakeColor(90, 0, 0, 0));
            try
              Path.AddArc(37.0 * Scale + 1.5, 34.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 180, 90);
              Path.AddArc(49.0 * Scale + 1.5, 34.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 270, 90);
              Path.AddArc(49.0 * Scale + 1.5, 75.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 0, 90);
              Path.AddArc(37.0 * Scale + 1.5, 75.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 90, 90);
              Path.CloseFigure;

              Path.AddArc(60.0 * Scale + 1.5, 34.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 180, 90);
              Path.AddArc(72.0 * Scale + 1.5, 34.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 270, 90);
              Path.AddArc(72.0 * Scale + 1.5, 75.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 0, 90);
              Path.AddArc(60.0 * Scale + 1.5, 75.0 * Scale + 1.5, 7.0 * Scale, 7.0 * Scale, 90, 90);
              Path.CloseFigure;
              G.FillPath(ShadowBrush, Path);
            finally
              ShadowBrush.Free;
            end;

            // Crisp white pause bars
            Path.Reset;
            Path.AddArc(37.0 * Scale, 34.0 * Scale, 7.0 * Scale, 7.0 * Scale, 180, 90);
            Path.AddArc(49.0 * Scale, 34.0 * Scale, 7.0 * Scale, 7.0 * Scale, 270, 90);
            Path.AddArc(49.0 * Scale, 75.0 * Scale, 7.0 * Scale, 7.0 * Scale, 0, 90);
            Path.AddArc(37.0 * Scale, 75.0 * Scale, 7.0 * Scale, 7.0 * Scale, 90, 90);
            Path.CloseFigure;

            Path.AddArc(60.0 * Scale, 34.0 * Scale, 7.0 * Scale, 7.0 * Scale, 180, 90);
            Path.AddArc(72.0 * Scale, 34.0 * Scale, 7.0 * Scale, 7.0 * Scale, 270, 90);
            Path.AddArc(72.0 * Scale, 75.0 * Scale, 7.0 * Scale, 7.0 * Scale, 0, 90);
            Path.AddArc(60.0 * Scale, 75.0 * Scale, 7.0 * Scale, 7.0 * Scale, 90, 90);
            Path.CloseFigure;
            G.FillPath(IconBrush, Path);
          finally
            Path.Free;
          end;
        end
        else if FKind = wkPlay then
        begin
          Path := TGPGraphicsPath.Create;
          try
            // Drop shadow
            ShadowBrush := TGPSolidBrush.Create(MakeColor(90, 0, 0, 0));
            try
              Pts[0].X := 44.0 * Scale + 1.5; Pts[0].Y := 33.0 * Scale + 1.5;
              Pts[1].X := 83.0 * Scale + 1.5; Pts[1].Y := 58.0 * Scale + 1.5;
              Pts[2].X := 44.0 * Scale + 1.5; Pts[2].Y := 83.0 * Scale + 1.5;
              Path.AddPolygon(PGPPointF(@Pts[0]), 3);
              G.FillPath(ShadowBrush, Path);
            finally
              ShadowBrush.Free;
            end;

            // Crisp white play triangle
            Path.Reset;
            Pts[0].X := 44.0 * Scale; Pts[0].Y := 33.0 * Scale;
            Pts[1].X := 83.0 * Scale; Pts[1].Y := 58.0 * Scale;
            Pts[2].X := 44.0 * Scale; Pts[2].Y := 83.0 * Scale;
            Path.AddPolygon(PGPPointF(@Pts[0]), 3);
            G.FillPath(IconBrush, Path);
          finally
            Path.Free;
          end;
        end;
      finally
        IconBrush.Free;
      end;
    finally
      G.Free;
    end;

    // Create 32-bit PARGB DIBSection
    DC := GetDC(0);
    try
      MemDC := CreateCompatibleDC(DC);
      try
        ZeroMemory(@BmpInfo, SizeOf(BmpInfo));
        BmpInfo.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
        BmpInfo.bmiHeader.biWidth := Size.cx;
        BmpInfo.bmiHeader.biHeight := -Size.cy; // top-down
        BmpInfo.bmiHeader.biPlanes := 1;
        BmpInfo.bmiHeader.biBitCount := 32;
        BmpInfo.bmiHeader.biCompression := BI_RGB;

        DIBHandle := CreateDIBSection(DC, BmpInfo, DIB_RGB_COLORS, BmpBits, 0, 0);
        if (DIBHandle <> 0) and (BmpBits <> nil) then
        begin
          OldBmp := SelectObject(MemDC, DIBHandle);
          try
            LockRect.X := 0;
            LockRect.Y := 0;
            LockRect.Width := Size.cx;
            LockRect.Height := Size.cy;
            if GPBmp.LockBits(LockRect, ImageLockModeRead, PixelFormat32bppPARGB, BmpData) = Ok then
            begin
              Move(BmpData.Scan0^, BmpBits^, Size.cx * Size.cy * 4);
              GPBmp.UnlockBits(BmpData);

              PointSrc := Point(0, 0);
              Blend.BlendOp := AC_SRC_OVER;
              Blend.BlendFlags := 0;
              Blend.SourceConstantAlpha := FAlpha;
              Blend.AlphaFormat := AC_SRC_ALPHA;

              UpdateLayeredWindow(FHWnd, DC, @PointDest, @Size, MemDC, @PointSrc, 0, @Blend, ULW_ALPHA);
              SetWindowPos(FHWnd, HWND_TOP, PointDest.X, PointDest.Y, Size.cx, Size.cy,
                SWP_NOACTIVATE or SWP_SHOWWINDOW);
            end;
          finally
            SelectObject(MemDC, OldBmp);
            DeleteObject(DIBHandle);
          end;
        end;
      finally
        DeleteDC(MemDC);
      end;
    finally
      ReleaseDC(0, DC);
    end;
  finally
    GPBmp.Free;
  end;
end;

{ TWin32TextOSD }

constructor TWin32TextOSD.Create;
begin
  inherited Create;
  FHWnd := 0;
  FAlpha := 0;
  FText := '';
  FTimerId := 0;
  FHoldCount := 0;
  CreateOSDWindow;
end;

destructor TWin32TextOSD.Destroy;
begin
  Hide;
  if FHWnd <> 0 then
  begin
    DestroyWindow(FHWnd);
    FHWnd := 0;
  end;
  inherited Destroy;
end;

procedure TWin32TextOSD.CreateOSDWindow;
begin
  RegisterOSDClasses;
  FHWnd := CreateWindowEx(
    WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_NOACTIVATE or WS_EX_TOOLWINDOW,
    TEXTOSD_CLASS,
    nil,
    WS_POPUP,
    0, 0, 10, 10,
    0, 0, HInstance, nil);
end;

procedure TWin32TextOSD.Hide;
begin
  if FTimerId <> 0 then
  begin
    KillTimer(FHWnd, FTimerId);
    FTimerId := 0;
  end;
  if (FHWnd <> 0) and IsWindowVisible(FHWnd) then
    ShowWindow(FHWnd, SW_HIDE);
  FAlpha := 0;
end;

procedure TWin32TextOSD.Trigger(TargetControl: TWinControl; const AText: string);
begin
  if (TargetControl = nil) or (AText = '') or not TargetControl.HandleAllocated or not TargetControl.Visible then Exit;
  if not IsWindow(FHWnd) then CreateOSDWindow;
  SetWindowLongPtr(FHWnd, GWLP_HWNDPARENT, GetAncestor(TargetControl.Handle, GA_ROOT));

  if FTimerId <> 0 then
  begin
    KillTimer(FHWnd, FTimerId);
    FTimerId := 0;
  end;

  FText := AText;
  SetWindowText(FHWnd,PChar(FText));
  FAlpha := 255;
  FHoldCount := GTextDuration div 20;
  RenderTextOSD(TargetControl);

  FTimerId := SetTimer(FHWnd, 2, 20, nil);
end;

procedure TWin32TextOSD.OnTimerTick;
begin
  if FHoldCount > 0 then
  begin
    Dec(FHoldCount);
    Exit;
  end;

  if FAlpha > 18 then
    Dec(FAlpha, 18)
  else
    FAlpha := 0;

  if FAlpha = 0 then
    Hide
  else
  begin
    var Blend: TBLENDFUNCTION;
    Blend.BlendOp := AC_SRC_OVER;
    Blend.BlendFlags := 0;
    Blend.SourceConstantAlpha := FAlpha;
    Blend.AlphaFormat := AC_SRC_ALPHA;
    UpdateLayeredWindow(FHWnd, 0, nil, nil, 0, nil, 0, @Blend, ULW_ALPHA);
  end;
end;

procedure TWin32TextOSD.RenderTextOSD(TargetControl: TWinControl);
var
  DC, MemDC: HDC;
  BmpInfo: TBitmapInfo;
  BmpBits: Pointer;
  DIBHandle, OldBmp: HBITMAP;
  Size: TSize;
  PointSrc, PointDest: TPoint;
  Blend: TBLENDFUNCTION;
  GPBmp: TGPBitmap;
  G: TGPGraphics;
  FontFam: TGPFontFamily;
  Font: TGPFont;
  LayoutRect, BoundRect, TextRect: TGPRectF;
  BgBrush, TextBrush: TGPSolidBrush;
  BorderPen: TGPPen;
  Format: TGPStringFormat;
  Path: TGPGraphicsPath;
  W, H, PadX, PadY: Integer;
  R: Single;
  BmpData: TBitmapData;
  LockRect: TGPRect;
  ControlPt: TPoint;
begin
  if (TargetControl = nil) or (FHWnd = 0) or (FText = '') then Exit;

  // Measure text
  DC := GetDC(0);
  try
    G := TGPGraphics.Create(DC);
    try
      FontFam := TGPFontFamily.Create('Segoe UI');
      try
        Font := TGPFont.Create(FontFam, GTextFontSize * 0.88 * TargetControl.CurrentPPI / 96, FontStyleRegular, UnitPoint);
        try
          LayoutRect.X := 0; LayoutRect.Y := 0;
          LayoutRect.Width := 800; LayoutRect.Height := 200;
          Format := TGPStringFormat.Create;
          try
            Format.SetAlignment(StringAlignmentNear);
            Format.SetLineAlignment(StringAlignmentCenter);
            G.MeasureString(FText, Length(FText), Font, LayoutRect, Format, BoundRect);
          finally
            Format.Free;
          end;
        finally
          Font.Free;
        end;
      finally
        FontFam.Free;
      end;
    finally
      G.Free;
    end;
  finally
    ReleaseDC(0, DC);
  end;

  PadX := MulDiv(18, TargetControl.CurrentPPI, 96);
  PadY := MulDiv(8, TargetControl.CurrentPPI, 96);
  W := Round(BoundRect.Width) + PadX * 2;
  H := Round(BoundRect.Height) + PadY * 2;
  if W < MulDiv(70, TargetControl.CurrentPPI, 96) then
    W := MulDiv(70, TargetControl.CurrentPPI, 96);
  if H < MulDiv(34, TargetControl.CurrentPPI, 96) then
    H := MulDiv(34, TargetControl.CurrentPPI, 96);

  Size.cx := W;
  Size.cy := H;

  // Position at top-left inside TargetControl (20px margin)
  ControlPt := TargetControl.ClientToScreen(Point(
    MulDiv(20, TargetControl.CurrentPPI, 96),
    MulDiv(20, TargetControl.CurrentPPI, 96)));
  PointDest := ControlPt;

  GPBmp := TGPBitmap.Create(Size.cx, Size.cy, PixelFormat32bppPARGB);
  try
    G := TGPGraphics.Create(GPBmp);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      G.SetPixelOffsetMode(PixelOffsetModeHighQuality);

      R := MulDiv(10, TargetControl.CurrentPPI, 96);
      Path := TGPGraphicsPath.Create;
      try
        Path.AddArc(1.0, 1.0, R * 2, R * 2, 180, 90);
        Path.AddArc(W - 2.0 - R * 2, 1.0, R * 2, R * 2, 270, 90);
        Path.AddArc(W - 2.0 - R * 2, H - 2.0 - R * 2, R * 2, R * 2, 0, 90);
        Path.AddArc(1.0, H - 2.0 - R * 2, R * 2, R * 2, 90, 90);
        Path.CloseFigure;

        // Dark pill background (translucent dark slate)
        BgBrush := TGPSolidBrush.Create(MakeColor(200, 15, 20, 26));
        try
          G.FillPath(BgBrush, Path);
        finally
          BgBrush.Free;
        end;

        // Subtle accent border
        BorderPen := TGPPen.Create(MakeColor(140, 0, 162, 232), 1.2);
        try
          G.DrawPath(BorderPen, Path);
        finally
          BorderPen.Free;
        end;
      finally
        Path.Free;
      end;

      // Draw crisp bold text
      FontFam := TGPFontFamily.Create('Segoe UI');
      try
        Font := TGPFont.Create(FontFam, GTextFontSize * 0.88 * TargetControl.CurrentPPI / 96, FontStyleRegular, UnitPoint);
        try
          Format := TGPStringFormat.Create;
          try
            Format.SetAlignment(StringAlignmentCenter);
            Format.SetLineAlignment(StringAlignmentCenter);
            TextRect.X := 0;
            TextRect.Y := 0;
            TextRect.Width := Size.cx;
            TextRect.Height := Size.cy;
            TextBrush := TGPSolidBrush.Create(MakeColor(255, 255, 255, 255));
            try
              G.DrawString(FText, Length(FText), Font, TextRect, Format, TextBrush);
            finally
              TextBrush.Free;
            end;
          finally
            Format.Free;
          end;
        finally
          Font.Free;
        end;
      finally
        FontFam.Free;
      end;
    finally
      G.Free;
    end;

    // Create 32-bit PARGB DIBSection
    DC := GetDC(0);
    try
      MemDC := CreateCompatibleDC(DC);
      try
        ZeroMemory(@BmpInfo, SizeOf(BmpInfo));
        BmpInfo.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
        BmpInfo.bmiHeader.biWidth := Size.cx;
        BmpInfo.bmiHeader.biHeight := -Size.cy; // top-down
        BmpInfo.bmiHeader.biPlanes := 1;
        BmpInfo.bmiHeader.biBitCount := 32;
        BmpInfo.bmiHeader.biCompression := BI_RGB;

        DIBHandle := CreateDIBSection(DC, BmpInfo, DIB_RGB_COLORS, BmpBits, 0, 0);
        if (DIBHandle <> 0) and (BmpBits <> nil) then
        begin
          OldBmp := SelectObject(MemDC, DIBHandle);
          try
            LockRect.X := 0;
            LockRect.Y := 0;
            LockRect.Width := Size.cx;
            LockRect.Height := Size.cy;
            if GPBmp.LockBits(LockRect, ImageLockModeRead, PixelFormat32bppPARGB, BmpData) = Ok then
            begin
              Move(BmpData.Scan0^, BmpBits^, Size.cx * Size.cy * 4);
              GPBmp.UnlockBits(BmpData);

              PointSrc := Point(0, 0);
              Blend.BlendOp := AC_SRC_OVER;
              Blend.BlendFlags := 0;
              Blend.SourceConstantAlpha := FAlpha;
              Blend.AlphaFormat := AC_SRC_ALPHA;

              UpdateLayeredWindow(FHWnd, DC, @PointDest, @Size, MemDC, @PointSrc, 0, @Blend, ULW_ALPHA);
              SetWindowPos(FHWnd, HWND_TOP, PointDest.X, PointDest.Y, Size.cx, Size.cy,
                SWP_NOACTIVATE or SWP_SHOWWINDOW);
            end;
          finally
            SelectObject(MemDC, OldBmp);
            DeleteObject(DIBHandle);
          end;
        end;
      finally
        DeleteDC(MemDC);
      end;
    finally
      ReleaseDC(0, DC);
    end;
  finally
    GPBmp.Free;
  end;
end;

procedure ShowVideoPlayPauseWatermark(TargetControl: TWinControl; IsPlaying: Boolean);
begin
  if TargetControl = nil then Exit;
  if not IsWindowEnabled(GetAncestor(TargetControl.Handle, GA_ROOT)) then Exit;
  if GWatermarkOSD = nil then
    GWatermarkOSD := TWin32WatermarkOSD.Create;
  GWatermarkOSD.Trigger(TargetControl, IsPlaying);
end;

procedure MovePlaybackOSD(Owner: HWND; DX, DY: Integer);
  procedure MoveOverlay(Window: HWND);
  var Bounds: TRect;
  begin
    if (Window <> 0) and (GetWindow(Window, GW_OWNER) = Owner) and
       IsWindowVisible(Window) and GetWindowRect(Window, Bounds) then
      SetWindowPos(Window, 0, Bounds.Left + DX, Bounds.Top + DY, 0, 0,
        SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
  end;
begin
  if (DX = 0) and (DY = 0) then Exit;
  if GWatermarkOSD <> nil then MoveOverlay(GWatermarkOSD.FHWnd);
  if GTextOSD <> nil then MoveOverlay(GTextOSD.FHWnd);
end;

procedure HidePlaybackOSD;
begin
  if GWatermarkOSD <> nil then GWatermarkOSD.Hide;
  if GTextOSD <> nil then GTextOSD.Hide;
end;

procedure ShowVideoTextOSD(TargetControl: TWinControl; const AText: string);
begin
  if (TargetControl = nil) or (AText = '') then Exit;
  if not IsWindowEnabled(GetAncestor(TargetControl.Handle, GA_ROOT)) then Exit;
  if GTextOSD = nil then
    GTextOSD := TWin32TextOSD.Create;
  GTextOSD.Trigger(TargetControl, AText);
end;

procedure CloseAllOSDWindows;
begin
  if GWatermarkOSD <> nil then
  begin
    var W := GWatermarkOSD;
    GWatermarkOSD := nil;
    W.Free;
  end;
  if GTextOSD <> nil then
  begin
    var T := GTextOSD;
    GTextOSD := nil;
    T.Free;
  end;
  UnregisterOSDClasses;
end;

initialization

finalization
  CloseAllOSDWindows;

end.
