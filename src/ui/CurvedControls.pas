unit CurvedControls;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.SysUtils,
  System.UITypes, Vcl.Controls, Vcl.Graphics, Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.ExtCtrls,
  Winapi.GDIPAPI, Winapi.GDIPOBJ, System.Math;

type
  TIconKind = (
    ikNone,
    ikPlay,
    ikPause,
    ikStop,
    ikPrev,
    ikNext,
    ikJumpBack,
    ikJumpFwd,
    ikStep,
    ikABRepeat,
    ikVolume,
    ikMute,
    ikEqualizer,
    ikPlaylist,
    ikFullscreen,
    ikRestore,
    ikMinimize,
    ikMaximize,
    ikClose,
    ikAdd,
    ikRemove,
    ikClear,
    ikRepeat,
    ikRepeatOne,
    ikShuffle,
    ikSpeed,
    ikSettings
  );

  // Helper color constants matching DriverPack-Modern "Classic Teal"
const
  DP_COLOR_BG       = $00181818; // #142735 (BGR)
  DP_COLOR_SURFACE  = $00202020; // #1D3646
  DP_COLOR_ELEVATED = $00292929; // #244457
  DP_COLOR_HOVER    = $00343434; // #2F5268
  DP_COLOR_BORDER   = $00383838; // #375263
  DP_COLOR_SCROLL   = $00787878; // #638697
  DP_COLOR_TEXT     = $00ECECEC; // #F3F9FB
  DP_COLOR_MUTED    = $00ABABAB; // #B5C7D2
  DP_COLOR_ACCENT   = $00FFCD60; // #00AFA5
  DP_COLOR_ACCHOVER = $00FFDA85; // #00BDB1
  DP_COLOR_ACCPRESS = $00D8A842; // #00857D
  DP_COLOR_ACCSOFT  = $00383838; // #BDF7EF
  DP_COLOR_HEAD_A   = $00181818; // #075078
  DP_COLOR_HEAD_B   = $00181818; // #08605B

type
  // 1. Modern Vector Button with crisp GDI+ anti-aliased icon rendering
  TModernVectorButton = class(TCustomControl)
  private
    FIsHovered: Boolean;
    FHoverAmount: Single;
    FHoverTimer: TTimer;
    FIsPressed: Boolean;
    FIsAccent: Boolean;
    FIsCircular: Boolean;
    FIsActive: Boolean;
    FCornerRadius: Single;
    FIconKind: TIconKind;
    FBadgeText: string;
    procedure HoverTick(Sender: TObject);
    procedure SetIconKind(const Value: TIconKind);
    procedure SetIsAccent(const Value: Boolean);
    procedure SetIsCircular(const Value: Boolean);
    procedure SetIsActive(const Value: Boolean);
    procedure SetBadgeText(const Value: string);
    procedure SetCornerRadius(const Value: Single);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    function CreateRoundRectPath(X, Y, W, H, Radius: Single): TGPGraphicsPath;
    procedure DrawVectorIcon(G: TGPGraphics; Kind: TIconKind; CX, CY, Size: Single; PenColor, FillColor: TGPColor);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Font;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property ShowHint;
    property Hint;
    property Enabled;
    property Visible;
    property IconKind: TIconKind read FIconKind write SetIconKind default ikNone;
    property IsAccent: Boolean read FIsAccent write SetIsAccent default False;
    property IsCircular: Boolean read FIsCircular write SetIsCircular default False;
    property IsActive: Boolean read FIsActive write SetIsActive default False;
    property CornerRadius: Single read FCornerRadius write SetCornerRadius;
    property BadgeText: string read FBadgeText write SetBadgeText;
  end;

  // 2. Modern Anti-Aliased Seek Bar with glowing accent fill and smooth thumb
  TOnSeekEvent = procedure(Sender: TObject; NewPosition: Single) of object;
  TSeekHoverEvent = procedure(Sender: TObject; Pos: Single; ScreenPt: TPoint) of object;

  TModernSeekBar = class(TCustomControl)
  private
    FPosition: Single;     // 0.0 to 1.0
    FBuffered: Single;     // 0.0 to 1.0
    FTotalTimeMs: Int64;
    FIsDragging: Boolean;
    FIsHovered: Boolean;
    FHoverPos: Single;
    FOnSeek: TOnSeekEvent;
    FOnHover: TSeekHoverEvent;
    FOnLeave: TNotifyEvent;
    procedure SetPosition(const Value: Single);
    procedure SetBuffered(const Value: Single);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    function PosFromX(X: Integer): Single;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Position: Single read FPosition write SetPosition;
    property Buffered: Single read FBuffered write SetBuffered;
    property TotalTimeMs: Int64 read FTotalTimeMs write FTotalTimeMs;
    property IsDragging: Boolean read FIsDragging;
    property OnSeek: TOnSeekEvent read FOnSeek write FOnSeek;
    property OnHover: TSeekHoverEvent read FOnHover write FOnHover;
    property OnLeave: TNotifyEvent read FOnLeave write FOnLeave;
    property ShowHint;
    property Enabled;
    property Visible;
  end;

  // 3. Modern Anti-Aliased Volume Slider
  TOnVolumeChangeEvent = procedure(Sender: TObject; Volume: Integer) of object;

  TModernVolumeSlider = class(TCustomControl)
  private
    FVolume: Integer;      // 0 to 100
    FIsDragging: Boolean;
    FIsHovered: Boolean;
    FOnVolumeChange: TOnVolumeChangeEvent;
    procedure SetVolume(const Value: Integer);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    function VolFromX(X: Integer): Integer;
    procedure ChangeFromPointer(X: Integer);
  protected
    procedure Paint; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Volume: Integer read FVolume write SetVolume default 100;
    property IsDragging: Boolean read FIsDragging;
    property OnVolumeChange: TOnVolumeChangeEvent read FOnVolumeChange write FOnVolumeChange;
    property ShowHint;
    property Enabled;
    property Visible;
  end;

  // 4. Modern Curved Card Panel Container
  TModernCardPanel = class(TCustomControl)
  private
    FCornerRadius: Single;
    FBorderColor: TColor;
    FCardColor: TColor;
    FFlushRight: Boolean;
    procedure SetCornerRadius(const Value: Single);
    procedure SetBorderColor(const Value: TColor);
    procedure SetCardColor(const Value: TColor);
    procedure SetFlushRight(const Value: Boolean);
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure UpdateRegion;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property CornerRadius: Single read FCornerRadius write SetCornerRadius;
    property BorderColor: TColor read FBorderColor write SetBorderColor default DP_COLOR_BORDER;
    property CardColor: TColor read FCardColor write SetCardColor default DP_COLOR_SURFACE;
    property FlushRight: Boolean read FFlushRight write SetFlushRight default False;
    property Visible;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  // 5. Modern Draggable Title Bar with Gradient
  TModernTitleBar = class(TCustomControl)
  private
    FTitleText: string;
    FIconBitmap: TBitmap;
    FAppIconImage: TGPImage;
    procedure SetTitleText(const Value: string);
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure WMNCHitTest(var Msg:TWMNCHitTest); message WM_NCHITTEST;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetIcon(AIcon: TIcon);
    procedure LoadAppIcon(const APath: string);
    procedure LoadAppIconFromResource(const ResName: string = 'APP_ICON_PNG');
  published
    property Align;
    property TitleText: string read FTitleText write SetTitleText;
    property Visible;
  end;

  // 6. Modern Context Menu & Dropdown Styler (DriverPack-Modern Dark Theme)
  TModernMenuStyler = class
  public
    class procedure Apply(AMenu: TPopupMenu); overload;
    class procedure Apply(AMenu: TMainMenu); overload;
    class procedure ApplyToItem(Item: TMenuItem);
    class procedure MeasureMenuItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    class procedure DrawMenuItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
  end;

// Utility functions
function MakeGDIColor(DelphiColor: TColor; Alpha: Byte = 255): TGPColor;
procedure PaintMediaSlider(DC: HDC; const Bounds: TRect; Position, Buffered, Zero: Single;
  Vertical, Hovered, Enabled: Boolean; DPI: Integer; Boost: Single = 0);
procedure EnableDwmRoundedCorners(Wnd: HWND);
procedure EnableWindows11DarkMenus(AFormHandle: HWND);


implementation

uses Winapi.ActiveX;

function MakeGDIColor(DelphiColor: TColor; Alpha: Byte = 255): TGPColor;
var
  RGBVal: Longint;
begin
  RGBVal := ColorToRGB(DelphiColor);
  Result := MakeColor(Alpha, GetRValue(RGBVal), GetGValue(RGBVal), GetBValue(RGBVal));
end;

procedure PaintMediaSlider(DC: HDC; const Bounds: TRect; Position, Buffered, Zero: Single;
  Vertical, Hovered, Enabled: Boolean; DPI: Integer; Boost: Single = 0);
var G: TGPGraphics; Pen: TGPPen; Brush: TGPSolidBrush;
    Scale, Padding, Radius, X, Y: Single; Accent, Core: TColor;
  function At(Value: Single): TGPPointF;
  begin
    Value := EnsureRange(Value, 0.0, 1.0);
    if Vertical then
    begin Result.X := (Bounds.Left + Bounds.Right) / 2;
      Result.Y := Bounds.Bottom - Padding - (Bounds.Height - Padding * 2) * Value; end
    else begin Result.X := Bounds.Left + Padding + (Bounds.Width - Padding * 2) * Value;
      Result.Y := (Bounds.Top + Bounds.Bottom) / 2; end;
  end;
  procedure Segment(Color: TColor; First, Last: Single);
  begin
    var A := At(First); var B := At(Last);
    Pen.SetColor(MakeGDIColor(Color));
    if Abs(First - Last) > 0.0001 then G.DrawLine(Pen, A.X, A.Y, B.X, B.Y);
  end;
begin
  Scale := DPI / 96;
  Padding := Round(10 * Scale);
  Radius := 5.5 * Scale;
  var Center := At(Position);
  X := Center.X; Y := Center.Y;
  Accent := DP_COLOR_ACCENT; Core := clWhite;
  Boost := EnsureRange(Boost,0.0,1.0);
  if Boost>0 then Accent := RGB(
    Round(96+(255-96)*Boost), Round(205+(96-205)*Boost), Round(255+(96-255)*Boost));
  if not Enabled then begin Accent := DP_COLOR_SCROLL; Core := DP_COLOR_MUTED; end;
  G := TGPGraphics.Create(DC);
  Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 4 * Scale);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
    Segment(DP_COLOR_BORDER, 0, 1);
    if Buffered > 0 then Segment(DP_COLOR_HOVER, 0, Buffered);
    if (Boost>0) and not Vertical and Enabled then
    begin
      var A:=At(0); var B:=At(Position);
      var GradientStart:=A; GradientStart.X:=GradientStart.X-2*Scale;
      var GradientEnd:=B; GradientEnd.X:=GradientEnd.X+2*Scale;
      var Gradient:=TGPLinearGradientBrush.Create(GradientStart,GradientEnd,MakeGDIColor(DP_COLOR_ACCENT),MakeGDIColor(Accent));
      var GradientPen:=TGPPen.Create(Gradient,4*Scale);
      try
        Gradient.SetWrapMode(WrapModeClamp);
        GradientPen.SetLineCap(LineCapRound,LineCapRound,DashCapRound);
        G.DrawLine(GradientPen,A.X,A.Y,B.X,B.Y);
      finally GradientPen.Free; Gradient.Free; end;
    end
    else if Zero < 0 then Segment(Accent, 0, Position)
    else Segment(Accent, Zero, Position);
    if Hovered and Enabled then
    begin
      Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ACCENT, 24));
      try G.FillEllipse(Brush, X - Radius - 4 * Scale, Y - Radius - 4 * Scale,
        2 * Radius + 8 * Scale, 2 * Radius + 8 * Scale);
      finally Brush.Free; end;
    end;
    Brush := TGPSolidBrush.Create(MakeGDIColor(Core));
    try G.FillEllipse(Brush, X - Radius, Y - Radius, 2 * Radius, 2 * Radius);
    finally Brush.Free; end;
    Pen.SetColor(MakeGDIColor(Accent));
    Pen.SetWidth(2 * Scale);
    G.DrawEllipse(Pen, X - Radius, Y - Radius, 2 * Radius, 2 * Radius);
  finally Pen.Free; G.Free; end;
end;

{ TModernVectorButton }

constructor TModernVectorButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents];
  DoubleBuffered := True;
  FHoverTimer := TTimer.Create(Self);
  FHoverTimer.Enabled := False;
  FHoverTimer.Interval := 16;
  FHoverTimer.OnTimer := HoverTick;
  FCornerRadius := 8;
  FIsAccent := False;
  FIsCircular := False;
  FIsActive := False;
  FIsHovered := False;
  FIsPressed := False;
  FIconKind := ikNone;
  FBadgeText := '';
  Cursor := crHandPoint;
  Width := 38;
  Height := 38;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Font.Color := DP_COLOR_TEXT;
end;

procedure TModernVectorButton.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TModernVectorButton.HoverTick(Sender: TObject);
begin
  if FIsHovered then FHoverAmount := Min(1.0, FHoverAmount + 0.18)
  else FHoverAmount := Max(0.0, FHoverAmount - 0.18);
  FHoverTimer.Enabled := (FHoverAmount > 0) and (FHoverAmount < 1);
  Invalidate;
end;

procedure TModernVectorButton.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  FIsHovered := True;
  FHoverTimer.Enabled := True;
  Invalidate;
end;

procedure TModernVectorButton.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FIsHovered := False;
  FHoverTimer.Enabled := True;
  Invalidate;
end;

procedure TModernVectorButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsPressed := True;
    Invalidate;
  end;
end;

procedure TModernVectorButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TModernVectorButton.SetIconKind(const Value: TIconKind);
begin
  if FIconKind <> Value then
  begin
    FIconKind := Value;
    Invalidate;
  end;
end;

procedure TModernVectorButton.SetIsAccent(const Value: Boolean);
begin
  if FIsAccent <> Value then
  begin
    FIsAccent := Value;
    Invalidate;
  end;
end;

procedure TModernVectorButton.SetIsCircular(const Value: Boolean);
begin
  if FIsCircular <> Value then
  begin
    FIsCircular := Value;
    Invalidate;
  end;
end;

procedure TModernVectorButton.SetIsActive(const Value: Boolean);
begin
  if FIsActive <> Value then
  begin
    FIsActive := Value;
    Invalidate;
  end;
end;

procedure TModernVectorButton.SetBadgeText(const Value: string);
begin
  if FBadgeText <> Value then
  begin
    FBadgeText := Value;
    Invalidate;
  end;
end;

procedure TModernVectorButton.SetCornerRadius(const Value: Single);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    Invalidate;
  end;
end;

function TModernVectorButton.CreateRoundRectPath(X, Y, W, H, Radius: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := Radius * 2;
  if D > W then D := W;
  if D > H then D := H;

  Result.AddArc(X, Y, D, D, 180, 90);
  Result.AddArc(X + W - D, Y, D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90);
  Result.AddArc(X, Y + H - D, D, D, 90, 90);
  Result.CloseFigure;
end;

procedure TModernVectorButton.DrawVectorIcon(G: TGPGraphics; Kind: TIconKind; CX, CY, Size: Single; PenColor, FillColor: TGPColor);
var
  Glyph: WideChar;
  GlyphStr: WideString;
  FontFamily: TGPFontFamily;
  FontObj: TGPFont;
  StringFormat: TGPStringFormat;
  LayoutRect: TGPRectF;
  Brush: TGPSolidBrush;
  FontSize: Single;
  P: TGPPen;
  B: TGPSolidBrush;
  Path: TGPGraphicsPath;
  R: Single;
  Points: array[0..2] of TGPPointF;
begin
  R := Size * 0.45;
  P := TGPPen.Create(PenColor, Size / 12);
  B := TGPSolidBrush.Create(FillColor);
  try
    P.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
    P.SetLineJoin(LineJoinRound);

    case Kind of
      ikPlay:
      begin
        // Crisp right-pointing equilateral triangle
        Points[0].X := CX - R * 0.65;
        Points[0].Y := CY - R * 0.95;
        Points[1].X := CX + R * 0.95;
        Points[1].Y := CY;
        Points[2].X := CX - R * 0.65;
        Points[2].Y := CY + R * 0.95;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;

      ikPause:
      begin
        // Two vertical rounded pill bars
        Path := TGPGraphicsPath.Create;
        try
          Path.AddArc(CX - R * 0.75, CY - R * 0.9, R * 0.45, R * 0.45, 180, 180);
          Path.AddArc(CX - R * 0.75, CY + R * 0.9 - R * 0.45, R * 0.45, R * 0.45, 0, 180);
          Path.CloseFigure;
          Path.AddArc(CX + R * 0.30, CY - R * 0.9, R * 0.45, R * 0.45, 180, 180);
          Path.AddArc(CX + R * 0.30, CY + R * 0.9 - R * 0.45, R * 0.45, R * 0.45, 0, 180);
          Path.CloseFigure;
          G.FillPath(B, Path);
        finally
          Path.Free;
        end;
      end;

      ikStop:
      begin
        // Rounded square
        Path := TGPGraphicsPath.Create;
        try
          Path.AddArc(CX - R * 0.7, CY - R * 0.7, R * 0.4, R * 0.4, 180, 90);
          Path.AddArc(CX + R * 0.7 - R * 0.4, CY - R * 0.7, R * 0.4, R * 0.4, 270, 90);
          Path.AddArc(CX + R * 0.7 - R * 0.4, CY + R * 0.7 - R * 0.4, R * 0.4, R * 0.4, 0, 90);
          Path.AddArc(CX - R * 0.7, CY + R * 0.7 - R * 0.4, R * 0.4, R * 0.4, 90, 90);
          Path.CloseFigure;
          G.FillPath(B, Path);
        finally
          Path.Free;
        end;
      end;

      ikPrev:
      begin
        // Left vertical bar + left double arrow
        G.DrawLine(P, CX - R * 0.85, CY - R * 0.85, CX - R * 0.85, CY + R * 0.85);
        Points[0].X := CX + R * 0.85;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX - R * 0.05;
        Points[1].Y := CY;
        Points[2].X := CX + R * 0.85;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        Points[0].X := CX + R * 0.05;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX - R * 0.75;
        Points[1].Y := CY;
        Points[2].X := CX + R * 0.05;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;

      ikNext:
      begin
        // Right double arrow + right vertical bar
        Points[0].X := CX - R * 0.85;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX + R * 0.05;
        Points[1].Y := CY;
        Points[2].X := CX - R * 0.85;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        Points[0].X := CX - R * 0.05;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX + R * 0.75;
        Points[1].Y := CY;
        Points[2].X := CX - R * 0.05;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        G.DrawLine(P, CX + R * 0.85, CY - R * 0.85, CX + R * 0.85, CY + R * 0.85);
      end;

      ikJumpBack:
      begin
        // Double solid left arrows (Rewind 10s)
        Points[0].X := CX;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX - R * 0.85;
        Points[1].Y := CY;
        Points[2].X := CX;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        Points[0].X := CX + R * 0.85;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX;
        Points[1].Y := CY;
        Points[2].X := CX + R * 0.85;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;

      ikJumpFwd:
      begin
        // Double solid right arrows (Fast Forward 10s)
        Points[0].X := CX - R * 0.85;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX;
        Points[1].Y := CY;
        Points[2].X := CX - R * 0.85;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        Points[0].X := CX;
        Points[0].Y := CY - R * 0.75;
        Points[1].X := CX + R * 0.85;
        Points[1].Y := CY;
        Points[2].X := CX;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;

      ikVolume:
      begin
        // Clean speaker cone + sound waves
        Points[0].X := CX - R * 0.75;
        Points[0].Y := CY - R * 0.35;
        Points[1].X := CX - R * 0.35;
        Points[1].Y := CY - R * 0.35;
        Points[2].X := CX + R * 0.10;
        Points[2].Y := CY - R * 0.75;
        G.DrawLine(P, CX - R * 0.75, CY - R * 0.35, CX - R * 0.35, CY - R * 0.35);
        G.DrawLine(P, CX - R * 0.35, CY - R * 0.35, CX + R * 0.10, CY - R * 0.75);
        G.DrawLine(P, CX + R * 0.10, CY - R * 0.75, CX + R * 0.10, CY + R * 0.75);
        G.DrawLine(P, CX + R * 0.10, CY + R * 0.75, CX - R * 0.35, CY + R * 0.35);
        G.DrawLine(P, CX - R * 0.35, CY + R * 0.35, CX - R * 0.75, CY + R * 0.35);
        G.DrawLine(P, CX - R * 0.75, CY + R * 0.35, CX - R * 0.75, CY - R * 0.35);

        // Sound arcs
        G.DrawArc(P, CX - R * 0.3, CY - R * 0.45, R * 0.9, R * 0.9, -40, 80);
        G.DrawArc(P, CX - R * 0.25, CY - R * 0.75, R * 1.1, R * 1.5, -45, 90);
      end;

      ikMute:
      begin
        // Speaker cone with diagonal slash
        G.DrawLine(P, CX - R * 0.75, CY - R * 0.35, CX - R * 0.35, CY - R * 0.35);
        G.DrawLine(P, CX - R * 0.35, CY - R * 0.35, CX + R * 0.10, CY - R * 0.75);
        G.DrawLine(P, CX + R * 0.10, CY - R * 0.75, CX + R * 0.10, CY + R * 0.75);
        G.DrawLine(P, CX + R * 0.10, CY + R * 0.75, CX - R * 0.35, CY + R * 0.35);
        G.DrawLine(P, CX - R * 0.35, CY + R * 0.35, CX - R * 0.75, CY + R * 0.35);
        G.DrawLine(P, CX - R * 0.75, CY + R * 0.35, CX - R * 0.75, CY - R * 0.35);

        // 'X' sound waves
        G.DrawLine(P, CX + R * 0.35, CY - R * 0.4, CX + R * 0.85, CY + R * 0.4);
        G.DrawLine(P, CX + R * 0.85, CY - R * 0.4, CX + R * 0.35, CY + R * 0.4);
      end;

      ikEqualizer:
      begin
        // 3 vertical sliders with knob ticks
        // Slider 1
        G.DrawLine(P, CX - R * 0.65, CY - R * 0.8, CX - R * 0.65, CY + R * 0.8);
        G.FillRectangle(B, CX - R * 0.9, CY - R * 0.3, R * 0.5, R * 0.3);
        // Slider 2
        G.DrawLine(P, CX, CY - R * 0.8, CX, CY + R * 0.8);
        G.FillRectangle(B, CX - R * 0.25, CY + R * 0.1, R * 0.5, R * 0.3);
        // Slider 3
        G.DrawLine(P, CX + R * 0.65, CY - R * 0.8, CX + R * 0.65, CY + R * 0.8);
        G.FillRectangle(B, CX + R * 0.4, CY - R * 0.5, R * 0.5, R * 0.3);
      end;

      ikPlaylist:
      begin
        // 3 horizontal lines with left bullets
        G.FillEllipse(B, CX - R * 0.85, CY - R * 0.65, R * 0.3, R * 0.3);
        G.DrawLine(P, CX - R * 0.35, CY - R * 0.5, CX + R * 0.85, CY - R * 0.5);

        G.FillEllipse(B, CX - R * 0.85, CY - R * 0.15, R * 0.3, R * 0.3);
        G.DrawLine(P, CX - R * 0.35, CY, CX + R * 0.85, CY);

        G.FillEllipse(B, CX - R * 0.85, CY + R * 0.35, R * 0.3, R * 0.3);
        G.DrawLine(P, CX - R * 0.35, CY + R * 0.5, CX + R * 0.85, CY + R * 0.5);
      end;

      ikFullscreen:
      begin
        // 4 corner expand brackets
        // Top-Left
        G.DrawLine(P, CX - R * 0.85, CY - R * 0.35, CX - R * 0.85, CY - R * 0.85);
        G.DrawLine(P, CX - R * 0.85, CY - R * 0.85, CX - R * 0.35, CY - R * 0.85);
        // Top-Right
        G.DrawLine(P, CX + R * 0.35, CY - R * 0.85, CX + R * 0.85, CY - R * 0.85);
        G.DrawLine(P, CX + R * 0.85, CY - R * 0.85, CX + R * 0.85, CY - R * 0.35);
        // Bottom-Right
        G.DrawLine(P, CX + R * 0.85, CY + R * 0.35, CX + R * 0.85, CY + R * 0.85);
        G.DrawLine(P, CX + R * 0.85, CY + R * 0.85, CX + R * 0.35, CY + R * 0.85);
        // Bottom-Left
        G.DrawLine(P, CX - R * 0.35, CY + R * 0.85, CX - R * 0.85, CY + R * 0.85);
        G.DrawLine(P, CX - R * 0.85, CY + R * 0.85, CX - R * 0.85, CY + R * 0.35);
      end;

      ikRestore:
      begin
        // 2 overlapping window rectangles
        G.DrawRectangle(P, CX - R * 0.45, CY - R * 0.75, R * 1.0, R * 1.0);
        G.DrawRectangle(P, CX - R * 0.75, CY - R * 0.45, R * 1.0, R * 1.0);
      end;

      ikMinimize:
      begin
        // Horizontal minus line
        G.DrawLine(P, CX - R * 0.75, CY, CX + R * 0.75, CY);
      end;

      ikMaximize:
      begin
        // Single window square
        G.DrawRectangle(P, CX - R * 0.75, CY - R * 0.75, R * 1.5, R * 1.5);
      end;

      ikClose:
      begin
        // Clean diagonal 'X'
        G.DrawLine(P, CX - R * 0.65, CY - R * 0.65, CX + R * 0.65, CY + R * 0.65);
        G.DrawLine(P, CX + R * 0.65, CY - R * 0.65, CX - R * 0.65, CY + R * 0.65);
      end;

      ikAdd:
      begin
        // Clean '+'
        G.DrawLine(P, CX - R * 0.75, CY, CX + R * 0.75, CY);
        G.DrawLine(P, CX, CY - R * 0.75, CX, CY + R * 0.75);
      end;

      ikRemove:
      begin
        // Clean '-'
        G.DrawLine(P, CX - R * 0.75, CY, CX + R * 0.75, CY);
      end;

      ikClear:
      begin
        // Minimalist clean trash can
        G.DrawLine(P, CX - R * 0.7, CY - R * 0.55, CX + R * 0.7, CY - R * 0.55);
        G.DrawLine(P, CX - R * 0.25, CY - R * 0.75, CX + R * 0.25, CY - R * 0.75);
        G.DrawLine(P, CX - R * 0.55, CY - R * 0.55, CX - R * 0.45, CY + R * 0.75);
        G.DrawLine(P, CX - R * 0.45, CY + R * 0.75, CX + R * 0.45, CY + R * 0.75);
        G.DrawLine(P, CX + R * 0.45, CY + R * 0.75, CX + R * 0.55, CY - R * 0.55);
        G.DrawLine(P, CX - R * 0.18, CY - R * 0.35, CX - R * 0.15, CY + R * 0.55);
        G.DrawLine(P, CX + R * 0.18, CY - R * 0.35, CX + R * 0.15, CY + R * 0.55);
      end;

      ikRepeat, ikRepeatOne:
      begin
        // Standard media repeat loop: top arrow right, bottom arrow left
        G.DrawLine(P, CX - R * 0.6, CY - R * 0.5, CX + R * 0.5, CY - R * 0.5);
        G.DrawLine(P, CX + R * 0.5, CY - R * 0.5, CX + R * 0.5, CY + R * 0.1);
        Points[0].X := CX + R * 0.75;
        Points[0].Y := CY - R * 0.5;
        Points[1].X := CX + R * 0.35;
        Points[1].Y := CY - R * 0.8;
        Points[2].X := CX + R * 0.35;
        Points[2].Y := CY - R * 0.2;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        G.DrawLine(P, CX + R * 0.6, CY + R * 0.5, CX - R * 0.5, CY + R * 0.5);
        G.DrawLine(P, CX - R * 0.5, CY + R * 0.5, CX - R * 0.5, CY - R * 0.1);
        Points[0].X := CX - R * 0.75;
        Points[0].Y := CY + R * 0.5;
        Points[1].X := CX - R * 0.35;
        Points[1].Y := CY + R * 0.8;
        Points[2].X := CX - R * 0.35;
        Points[2].Y := CY + R * 0.2;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;

      ikShuffle:
      begin
        // Crossed arrows with arrowheads
        G.DrawLine(P, CX - R * 0.75, CY - R * 0.5, CX - R * 0.25, CY - R * 0.5);
        G.DrawLine(P, CX - R * 0.25, CY - R * 0.5, CX + R * 0.25, CY + R * 0.5);
        G.DrawLine(P, CX + R * 0.25, CY + R * 0.5, CX + R * 0.65, CY + R * 0.5);

        G.DrawLine(P, CX - R * 0.75, CY + R * 0.5, CX - R * 0.25, CY + R * 0.5);
        G.DrawLine(P, CX - R * 0.25, CY + R * 0.5, CX + R * 0.25, CY - R * 0.5);
        G.DrawLine(P, CX + R * 0.25, CY - R * 0.5, CX + R * 0.65, CY - R * 0.5);

        Points[0].X := CX + R * 0.85;
        Points[0].Y := CY - R * 0.5;
        Points[1].X := CX + R * 0.5;
        Points[1].Y := CY - R * 0.75;
        Points[2].X := CX + R * 0.5;
        Points[2].Y := CY - R * 0.25;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);

        Points[0].X := CX + R * 0.85;
        Points[0].Y := CY + R * 0.5;
        Points[1].X := CX + R * 0.5;
        Points[1].Y := CY + R * 0.25;
        Points[2].X := CX + R * 0.5;
        Points[2].Y := CY + R * 0.75;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;

      ikStep:
      begin
        // Step frame: vertical bar + right arrow
        G.DrawLine(P, CX - R * 0.7, CY - R * 0.8, CX - R * 0.7, CY + R * 0.8);
        Points[0].X := CX - R * 0.3;
        Points[0].Y := CY - R * 0.8;
        Points[1].X := CX + R * 0.8;
        Points[1].Y := CY;
        Points[2].X := CX - R * 0.3;
        Points[2].Y := CY + R * 0.8;
        G.FillPolygon(B, PGPPointF(@Points[0]), 3);
      end;
    end;
  finally
    B.Free;
    P.Free;
  end;
end;

procedure TModernVectorButton.Paint;
var
  R: TRect;
  ParentBgColor: TColor;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  BgColor, PenColor, IconColor: TGPColor;
  CX, CY, IconSize: Single;
  FontFamily: TGPFontFamily;
  FontObj: TGPFont;
  StringFormat: TGPStringFormat;
  LayoutRect: TGPRectF;
  DispText: string;
begin
  R := ClientRect;

  // 1. Fill background with exact Parent background color
  if Parent is TModernCardPanel then
    ParentBgColor := TModernCardPanel(Parent).CardColor
  else if Parent is TPanel then
    ParentBgColor := TPanel(Parent).Color
  else if (Parent <> nil) and (Parent is TCustomForm) then
    ParentBgColor := TCustomForm(Parent).Color
  else
    ParentBgColor := DP_COLOR_BG;

  Canvas.Brush.Color := ParentBgColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(R);

  PenColor := MakeColor(0, 0, 0, 0);
  IconColor := MakeGDIColor(DP_COLOR_TEXT);
  if not Enabled then IconColor := MakeGDIColor(DP_COLOR_SCROLL);
  if FIsAccent then
  begin
    if FIsPressed then BgColor := MakeGDIColor(DP_COLOR_ACCPRESS)
    else if FIsHovered then BgColor := MakeGDIColor(DP_COLOR_ACCHOVER)
    else BgColor := MakeGDIColor(DP_COLOR_ACCENT);
    IconColor := MakeGDIColor(DP_COLOR_BG);
  end
  else if FIsPressed then BgColor := MakeGDIColor(DP_COLOR_ELEVATED)
  else if FIsActive then
  begin
    BgColor := MakeGDIColor(DP_COLOR_HOVER);
    IconColor := MakeGDIColor(DP_COLOR_ACCENT);
  end
  else BgColor := MakeGDIColor(DP_COLOR_HOVER, Round(255 * FHoverAmount));

  // 3. High-Quality Anti-Aliased GDI+ Vector Drawing
  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);

    if FIsCircular then
    begin
      // Perfectly round button (e.g. large center Play button)
      Brush := TGPSolidBrush.Create(BgColor);
      try
        G.FillEllipse(Brush, 2, 2, Width - 4, Height - 4);
      finally
        Brush.Free;
      end;

      Pen := TGPPen.Create(PenColor, 1.5);
      try
        G.DrawEllipse(Pen, 2, 2, Width - 4, Height - 4);
      finally
        Pen.Free;
      end;
    end
    else
    begin
      // Curved pill rectangle
      if (GetAlpha(BgColor) > 0) or (GetAlpha(PenColor) > 0) then
      begin
        Path := CreateRoundRectPath(1, 1, Width - 2, Height - 2, FCornerRadius * CurrentPPI / 96);
        try
          if GetAlpha(BgColor) > 0 then
          begin
            Brush := TGPSolidBrush.Create(BgColor);
            try
              G.FillPath(Brush, Path);
            finally
              Brush.Free;
            end;
          end;

          if GetAlpha(PenColor) > 0 then
          begin
            Pen := TGPPen.Create(PenColor, 1.0);
            try
              G.DrawPath(Pen, Path);
            finally
              Pen.Free;
            end;
          end;
        finally
          Path.Free;
        end;
      end;
    end;

    // 4. Draw Vector Icon
    CX := Width * 0.5;
    CY := Height * 0.5;
    IconSize := Min(Width, Height) * 0.56;

    if FIconKind <> ikNone then
      DrawVectorIcon(G, FIconKind, CX, CY, IconSize, IconColor, IconColor);

    // 5. Render Optional Text / Badge with ClearType (e.g. "10s", "1.0x", "Media", "Playback")
    if (FBadgeText <> '') or ((FIconKind = ikNone) and (Caption <> '')) then
    begin
      DispText := FBadgeText;
      if DispText = '' then DispText := Caption;

      FontFamily := TGPFontFamily.Create('Segoe UI');
      try
        if FIsAccent then
          FontObj := TGPFont.Create(FontFamily, 9.5, FontStyleBold, UnitPoint)
        else
          FontObj := TGPFont.Create(FontFamily, 9.0, FontStyleRegular, UnitPoint);
        try
          StringFormat := TGPStringFormat.Create;
          try
            StringFormat.SetAlignment(StringAlignmentCenter);
            StringFormat.SetLineAlignment(StringAlignmentCenter);
            Brush := TGPSolidBrush.Create(IconColor);
            try
              G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
              LayoutRect.X := 0;
              LayoutRect.Y := 0;
              LayoutRect.Width := Width;
              LayoutRect.Height := Height;
              G.DrawString(PWideChar(DispText), Length(DispText), FontObj, LayoutRect, StringFormat, Brush);
            finally
              Brush.Free;
            end;
          finally
            StringFormat.Free;
          end;
        finally
          FontObj.Free;
        end;
      finally
        FontFamily.Free;
      end;
    end;

  finally
    G.Free;
  end;
end;

{ TModernSeekBar }

constructor TModernSeekBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents];
  DoubleBuffered := True;
  FPosition := 0.0;
  FBuffered := 0.0;
  FIsDragging := False;
  FIsHovered := False;
  FHoverPos := 0.0;
  Cursor := crHandPoint;
  Height := 24;
  Width := 400;
end;

procedure TModernSeekBar.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TModernSeekBar.CMMouseEnter(var Msg: TMessage);
begin
  FIsHovered := True;
  Invalidate;
end;

procedure TModernSeekBar.CMMouseLeave(var Msg: TMessage);
begin
  FIsHovered := False;
  Invalidate;
  if Assigned(FOnLeave) then
    FOnLeave(Self);
end;

function TModernSeekBar.PosFromX(X: Integer): Single;
var
  TrackW: Single;
begin
  TrackW := Width - 2 * MulDiv(10, CurrentPPI, 96);
  if TrackW <= 0 then
    Result := 0
  else
  begin
    Result := (X - MulDiv(10, CurrentPPI, 96)) / TrackW;
    if Result < 0 then Result := 0;
    if Result > 1 then Result := 1;
  end;
end;

procedure TModernSeekBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsDragging := True;
    FPosition := PosFromX(X);
    Invalidate;
    if Assigned(FOnSeek) then
      FOnSeek(Self, FPosition);
  end;
end;

procedure TModernSeekBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FHoverPos := PosFromX(X);
  if FIsDragging then
  begin
    FPosition := FHoverPos;
    Invalidate;
    if Assigned(FOnSeek) then
      FOnSeek(Self, FPosition);
  end
  else
    Invalidate;

  if Assigned(FOnHover) then
    FOnHover(Self, FHoverPos, ClientToScreen(Point(X, Y)));
end;

procedure TModernSeekBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsDragging := False;
    FPosition := PosFromX(X);
    Invalidate;
    if Assigned(FOnSeek) then
      FOnSeek(Self, FPosition);
  end;
end;

procedure TModernSeekBar.SetPosition(const Value: Single);
var
  Clamped: Single;
begin
  Clamped := Value;
  if Clamped < 0.0 then Clamped := 0.0;
  if Clamped > 1.0 then Clamped := 1.0;
  if Abs(FPosition - Clamped) > 0.0005 then
  begin
    FPosition := Clamped;
    Invalidate;
  end;
end;

procedure TModernSeekBar.SetBuffered(const Value: Single);
begin
  if Abs(FBuffered - Value) > 0.01 then
  begin
    FBuffered := Value;
    Invalidate;
  end;
end;

procedure TModernSeekBar.Paint;
begin
  if Parent is TModernCardPanel then Canvas.Brush.Color := TModernCardPanel(Parent).CardColor
  else Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(ClientRect);
  PaintMediaSlider(Canvas.Handle, ClientRect, FPosition, FBuffered, -1, False,
    FIsHovered or FIsDragging, Enabled, CurrentPPI);
end;

{ TModernVolumeSlider }

constructor TModernVolumeSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents];
  DoubleBuffered := True;
  FVolume := 100;
  FIsDragging := False;
  FIsHovered := False;
  Cursor := crHandPoint;
  Height := 24;
  Width := 90;
end;

procedure TModernVolumeSlider.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TModernVolumeSlider.CMMouseEnter(var Msg: TMessage);
begin
  FIsHovered := True;
  Invalidate;
end;

procedure TModernVolumeSlider.CMMouseLeave(var Msg: TMessage);
begin
  FIsHovered := False;
  Invalidate;
end;

function TModernVolumeSlider.VolFromX(X: Integer): Integer;
var
  TrackW: Single;
  Ratio: Single;
begin
  TrackW := Width - 2 * MulDiv(10, CurrentPPI, 96);
  if TrackW <= 0 then
    Result := 0
  else
  begin
    Ratio := (X - MulDiv(10, CurrentPPI, 96)) / TrackW;
    if Ratio < 0 then Ratio := 0;
    if Ratio > 1 then Ratio := 1;
    Result := Round(Ratio * 200);
  end;
end;

procedure TModernVolumeSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsDragging := True;
    ChangeFromPointer(X);
  end;
end;

procedure TModernVolumeSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FIsDragging then
    ChangeFromPointer(X);
end;

procedure TModernVolumeSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FIsDragging := False;
    ChangeFromPointer(X);
  end;
end;

function TModernVolumeSlider.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  Previous: Integer;
begin
  Result := Enabled;
  if not Result then Exit;
  Previous := FVolume;
  SetVolume(FVolume + Round(WheelDelta / WHEEL_DELTA * 5));
  if (FVolume <> Previous) and Assigned(FOnVolumeChange) then FOnVolumeChange(Self,FVolume);
end;

procedure TModernVolumeSlider.ChangeFromPointer(X: Integer);
var
  Value: Integer;
begin
  Value := VolFromX(X);
  if Value = FVolume then Exit;
  SetVolume(Value);
  if Assigned(FOnVolumeChange) then FOnVolumeChange(Self, FVolume);
end;

procedure TModernVolumeSlider.SetVolume(const Value: Integer);
var
  Clamped: Integer;
begin
  Clamped := Value;
  if Clamped < 0 then Clamped := 0;
  if Clamped > 200 then Clamped := 200;
  if FVolume <> Clamped then
  begin
    FVolume := Clamped;
    Invalidate;
  end;
end;

procedure TModernVolumeSlider.Paint;
begin
  if Parent is TModernCardPanel then Canvas.Brush.Color := TModernCardPanel(Parent).CardColor
  else Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(ClientRect);
  PaintMediaSlider(Canvas.Handle, ClientRect, FVolume / 200, 0, -1, False,
    FIsHovered or FIsDragging, Enabled, CurrentPPI, Max(0,(FVolume-100)/100));
end;

{ TModernCardPanel }

constructor TModernCardPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse];
  DoubleBuffered := True;
  FCornerRadius := 14.0;
  FBorderColor := DP_COLOR_BORDER;
  FCardColor := DP_COLOR_SURFACE;
end;

procedure TModernCardPanel.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TModernCardPanel.UpdateRegion;
begin
  // Keep a rectangular HWND and antialias the painted outline.
  // A rounded GDI region clips away antialiased edge pixels.
end;

procedure TModernCardPanel.CreateWnd;
begin
  inherited;
  UpdateRegion;
end;

procedure TModernCardPanel.Resize;
begin
  inherited;
  UpdateRegion;
end;

procedure TModernCardPanel.SetCornerRadius(const Value: Single);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    UpdateRegion;
    Invalidate;
  end;
end;

procedure TModernCardPanel.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TModernCardPanel.SetCardColor(const Value: TColor);
begin
  if FCardColor <> Value then
  begin
    FCardColor := Value;
    Invalidate;
  end;
end;

procedure TModernCardPanel.SetFlushRight(const Value: Boolean);
begin
  if FFlushRight <> Value then
  begin
    FFlushRight := Value;
    Invalidate;
  end;
end;

procedure TModernCardPanel.Paint;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  D: Single;
begin
  if Parent is TModernCardPanel then Canvas.Brush.Color := TModernCardPanel(Parent).CardColor
  else if Parent <> nil then Canvas.Brush.Color := Parent.Brush.Color
  else Canvas.Brush.Color := DP_COLOR_BG;
  Canvas.FillRect(ClientRect);
  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);

    Path := TGPGraphicsPath.Create;
    try
      D := FCornerRadius * 2 * CurrentPPI / 96;
      if D > Width then D := Width;
      if D > Height then D := Height;

      if D <= 0 then Path.AddRectangle(MakeRect(0, 0, Width, Height))
      else if FFlushRight then
      begin
        // Rounded on Left (facing video), Flush and straight on Right
        Path.AddArc(1, 1, D, D, 180, 90);
        Path.AddLine(1 + D, 1, Width, 1);
        Path.AddLine(Width, 1, Width, Height - 1);
        Path.AddLine(Width, Height - 1, 1 + D, Height - 1);
        Path.AddArc(1, Height - 1 - D, D, D, 90, 90);
        Path.CloseFigure;
      end
      else
      begin
        Path.AddArc(1, 1, D, D, 180, 90);
        Path.AddArc(Width - 1 - D, 1, D, D, 270, 90);
        Path.AddArc(Width - 1 - D, Height - 1 - D, D, D, 0, 90);
        Path.AddArc(1, Height - 1 - D, D, D, 90, 90);
        Path.CloseFigure;
      end;

      Brush := TGPSolidBrush.Create(MakeGDIColor(FCardColor));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      Pen := TGPPen.Create(MakeGDIColor(FBorderColor), 1.0);
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;
  finally
    G.Free;
  end;
end;

{ TModernTitleBar }

constructor TModernTitleBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks];
  DoubleBuffered := True;
  Align := alTop;
  Height := 36;
  FTitleText := 'VLC Modern';
  FIconBitmap := TBitmap.Create;
  FAppIconImage := nil;
  LoadAppIconFromResource('APP_ICON_PNG');
end;

destructor TModernTitleBar.Destroy;
begin
  if Assigned(FAppIconImage) then
    FAppIconImage.Free;
  FIconBitmap.Free;
  inherited;
end;

procedure TModernTitleBar.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TModernTitleBar.SetIcon(AIcon: TIcon);
begin
  if (AIcon <> nil) and (not AIcon.Empty) then
  begin
    FIconBitmap.SetSize(22, 22);
    FIconBitmap.Canvas.Brush.Color := DP_COLOR_BG;
    FIconBitmap.Canvas.FillRect(Rect(0, 0, 22, 22));
    DrawIconEx(FIconBitmap.Canvas.Handle, 0, 0, AIcon.Handle, 22, 22, 0, 0, DI_NORMAL);
    Invalidate;
  end;
end;

procedure TModernTitleBar.LoadAppIconFromResource(const ResName: string);
var
  ResStream: TResourceStream;
  MemHandle: HGLOBAL;
  MemPtr: Pointer;
  Stream: IStream;
  TempBmp: TGPBitmap;
  G: TGPGraphics;
begin
  if FindResource(HInstance, PChar(ResName), RT_RCDATA) = 0 then Exit;
  try
    ResStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
    try
      MemHandle := GlobalAlloc(GMEM_MOVEABLE, ResStream.Size);
      if MemHandle = 0 then Exit;
      MemPtr := GlobalLock(MemHandle);
      if MemPtr <> nil then
      begin
        Move(ResStream.Memory^, MemPtr^, ResStream.Size);
        GlobalUnlock(MemHandle);
      end
      else
      begin
        GlobalFree(MemHandle);
        Exit;
      end;

      if Succeeded(CreateStreamOnHGlobal(MemHandle, True, Stream)) then
      begin
        TempBmp := TGPBitmap.Create(Stream);
        try
          if TempBmp.GetLastStatus = Ok then
          begin
            if Assigned(FAppIconImage) then
            begin
              FAppIconImage.Free;
              FAppIconImage := nil;
            end;
            // Create detached in-memory ARGB bitmap with zero stream dependencies
            FAppIconImage := TGPBitmap.Create(TempBmp.GetWidth, TempBmp.GetHeight, PixelFormat32bppARGB);
            G := TGPGraphics.Create(FAppIconImage);
            try
              G.SetSmoothingMode(SmoothingModeAntiAlias);
              G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
              G.DrawImage(TempBmp, 0, 0, TempBmp.GetWidth, TempBmp.GetHeight);
            finally
              G.Free;
            end;
          end;
        finally
          TempBmp.Free;
          Stream := nil;
        end;
      end
      else GlobalFree(MemHandle);
    finally
      ResStream.Free;
    end;
    Invalidate;
  except
  end;
end;

procedure TModernTitleBar.LoadAppIcon(const APath: string);
var
  TempImg: TGPImage;
  G: TGPGraphics;
begin
  if FileExists(APath) then
  begin
    TempImg := TGPImage.Create(PWideChar(APath));
    try
      if TempImg.GetLastStatus = Ok then
      begin
        if Assigned(FAppIconImage) then
          FAppIconImage.Free;
        FAppIconImage := TGPBitmap.Create(TempImg.GetWidth, TempImg.GetHeight, PixelFormat32bppARGB);
        G := TGPGraphics.Create(FAppIconImage);
        try
          G.SetSmoothingMode(SmoothingModeAntiAlias);
          G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
          G.DrawImage(TempImg, 0, 0, TempImg.GetWidth, TempImg.GetHeight);
        finally
          G.Free;
        end;
      end;
    finally
      TempImg.Free;
    end;
  end
  else
    LoadAppIconFromResource('APP_ICON_PNG');
  Invalidate;
end;

procedure TModernTitleBar.SetTitleText(const Value: string);
begin
  if FTitleText <> Value then
  begin
    FTitleText := Value;
    Invalidate;
  end;
end;

procedure TModernTitleBar.WMNCHitTest(var Msg:TWMNCHitTest);
begin
  inherited;
  var Host:=GetParentForm(Self);
  if Host=nil then Exit;
  var Hit:=SendMessage(Host.Handle,WM_NCHITTEST,0,MakeLParam(Msg.Pos.X,Msg.Pos.Y));
  if Hit in [HTLEFT,HTRIGHT,HTTOP,HTBOTTOM,HTTOPLEFT,HTTOPRIGHT,HTBOTTOMLEFT,HTBOTTOMRIGHT] then Msg.Result:=HTTRANSPARENT;
end;

procedure TModernTitleBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    ReleaseCapture;
    var Host:=GetParentForm(Self);
    if Host=nil then Exit;
    var Pt:=ClientToScreen(Point(X,Y));
    var Hit:=SendMessage(Host.Handle,WM_NCHITTEST,0,MakeLParam(Pt.X,Pt.Y));
    if not (Hit in [HTLEFT,HTRIGHT,HTTOP,HTBOTTOM,HTTOPLEFT,HTTOPRIGHT,HTBOTTOMLEFT,HTBOTTOMRIGHT]) then Hit:=HTCAPTION;
    SendMessage(Host.Handle, WM_NCLBUTTONDOWN, Hit, MakeLParam(Pt.X,Pt.Y));
  end;
end;

procedure TModernTitleBar.DblClick;
begin
  inherited;
  var Host:=GetParentForm(Self);
  if (Host=nil) or (Host.BorderStyle<>bsSizeable) then Exit;
  if Host.WindowState = wsMaximized then Host.WindowState := wsNormal
  else Host.WindowState := wsMaximized;
end;

procedure TModernTitleBar.Paint;
var
  G: TGPGraphics;
  GradBrush: TGPLinearGradientBrush;
  Brush: TGPSolidBrush;
  Pt1, Pt2: TGPPointF;
  FontFamily: TGPFontFamily;
  FontObj: TGPFont;
  StringFormat: TGPStringFormat;
  TitleRect: TGPRectF;
  IconRight: Single;
begin
  G := TGPGraphics.Create(Canvas.Handle);
  try
    Pt1.X := 0; Pt1.Y := 0;
    Pt2.X := Width; Pt2.Y := 0;

    // Classic Teal Header Gradient (#075078 -> #08605B)
    GradBrush := TGPLinearGradientBrush.Create(
      Pt1, Pt2,
      MakeGDIColor(DP_COLOR_BG),
      MakeGDIColor(DP_COLOR_BG)
    );
    try
      G.FillRectangle(GradBrush, 0, 0, Width, Height);
    finally
      GradBrush.Free;
    end;

    // Draw Crisp Glossy App Icon using GDI+ Bicubic Scaling
    IconRight := 8;
    if (FAppIconImage <> nil) and (FAppIconImage.GetLastStatus = Ok) then
    begin
      G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.DrawImage(FAppIconImage, 8, (Height - 22) div 2, 22, 22);
      IconRight := 36;
    end
    else if (FIconBitmap <> nil) and (FIconBitmap.Width > 0) then
    begin
      Canvas.Draw(8, (Height - 22) div 2, FIconBitmap);
      IconRight := 36;
    end;

    // Draw Sharp ClearType Window Title Text
    FontFamily := TGPFontFamily.Create('Segoe UI');
    try
      FontObj := TGPFont.Create(FontFamily, 10.0, FontStyleBold, UnitPoint);
      try
        StringFormat := TGPStringFormat.Create;
        try
          StringFormat.SetLineAlignment(StringAlignmentCenter);
          Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_TEXT));
          try
            G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
            TitleRect.X := IconRight;
            TitleRect.Y := 0;
            TitleRect.Width := Width - IconRight - 110;
            TitleRect.Height := Height;
            G.DrawString(PWideChar(FTitleText), Length(FTitleText), FontObj, TitleRect, StringFormat, Brush);
          finally
            Brush.Free;
          end;
        finally
          StringFormat.Free;
        end;
      finally
        FontObj.Free;
      end;
    finally
      FontFamily.Free;
    end;

  finally
    G.Free;
  end;
end;

{ TModernMenuStyler }

class procedure TModernMenuStyler.ApplyToItem(Item: TMenuItem);
begin
  if Item = nil then Exit;
  Item.OnMeasureItem := MeasureMenuItem;
  Item.OnAdvancedDrawItem := DrawMenuItem;
  for var I := 0 to Item.Count - 1 do ApplyToItem(Item.Items[I]);
end;

class procedure TModernMenuStyler.Apply(AMenu: TPopupMenu);
begin
  if AMenu = nil then Exit;
  AMenu.OwnerDraw := True;
  ApplyToItem(AMenu.Items);
end;

class procedure TModernMenuStyler.Apply(AMenu: TMainMenu);
begin
  if AMenu = nil then Exit;
  AMenu.OwnerDraw := True;
  ApplyToItem(AMenu.Items);
end;

class procedure TModernMenuStyler.MeasureMenuItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
  Item: TMenuItem;
  CapText: string;
begin
  if not (Sender is TMenuItem) then Exit;
  Item := TMenuItem(Sender);
  if Item.Caption = '-' then
  begin
    Height := 7;
    Width := 140;
  end
  else
  begin
    Height := 28;
    CapText := StripHotkey(Item.Caption);
    ACanvas.Font.Name := 'Segoe UI';
    ACanvas.Font.Size := 9;
    Width := ACanvas.TextWidth(CapText) + 75;
    if Item.ShortCut <> 0 then
      Width := Width + ACanvas.TextWidth(ShortCutToText(Item.ShortCut)) + 25;
    if Width < 170 then Width := 170;
  end;
end;

class procedure TModernMenuStyler.DrawMenuItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var
  Item: TMenuItem;
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Path: TGPGraphicsPath;
  CapText, ScText: string;
  TextR: TRect;
  IsSel, IsDis: Boolean;
begin
  if not (Sender is TMenuItem) then Exit;
  Item := TMenuItem(Sender);
  IsSel := odSelected in State;
  IsDis := odDisabled in State;

  G := TGPGraphics.Create(ACanvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    // 1. Menu background (#1D3646)
    Brush := TGPSolidBrush.Create(MakeColor(255, $1D, $36, $46));
    try
      G.FillRectangle(Brush, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
    finally
      Brush.Free;
    end;

    // 2. Separator
    if Item.Caption = '-' then
    begin
      Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 1.0);
      try
        G.DrawLine(Pen, ARect.Left + 12, ARect.Top + 3, ARect.Right - 12, ARect.Top + 3);
      finally
        Pen.Free;
      end;
      Exit;
    end;

    // 3. Selection Pill
    if IsSel and not IsDis then
    begin
      Path := TGPGraphicsPath.Create;
      try
        Path.AddArc(ARect.Left + 4, ARect.Top + 2, 8, 8, 180, 90);
        Path.AddArc(ARect.Right - 12, ARect.Top + 2, 8, 8, 270, 90);
        Path.AddArc(ARect.Right - 12, ARect.Bottom - 10, 8, 8, 0, 90);
        Path.AddArc(ARect.Left + 4, ARect.Bottom - 10, 8, 8, 90, 90);
        Path.CloseFigure;

        Brush := TGPSolidBrush.Create(MakeColor(255, $2F, $52, $68));
        try
          G.FillPath(Brush, Path);
        finally
          Brush.Free;
        end;

        Pen := TGPPen.Create(MakeColor(255, $00, $AF, $A5), 1.0);
        try
          G.DrawPath(Pen, Path);
        finally
          Pen.Free;
        end;
      finally
        Path.Free;
      end;
    end;

    // 4. Checkmark / Radio Dot
    if Item.Checked then
    begin
      Brush := TGPSolidBrush.Create(MakeColor(255, $00, $AF, $A5));
      try
        if Item.RadioItem then
          G.FillEllipse(Brush, ARect.Left + 10, ARect.Top + (ARect.Bottom - ARect.Top - 8) div 2, 8, 8)
        else
        begin
          Pen := TGPPen.Create(MakeColor(255, $00, $AF, $A5), 2.0);
          try
            G.DrawLine(Pen, ARect.Left + 9, ARect.Top + 14, ARect.Left + 13, ARect.Top + 18);
            G.DrawLine(Pen, ARect.Left + 13, ARect.Top + 18, ARect.Left + 19, ARect.Top + 10);
          finally
            Pen.Free;
          end;
        end;
      finally
        Brush.Free;
      end;
    end;
  finally
    G.Free;
  end;

  // 5. Draw Caption
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Name := 'Segoe UI';
  ACanvas.Font.Size := 9;
  if IsDis then
    ACanvas.Font.Color := $00978663
  else
    ACanvas.Font.Color := $00FBF9F3;

  CapText := StripHotkey(Item.Caption);
  TextR := Rect(ARect.Left + 30, ARect.Top, ARect.Right - 18, ARect.Bottom);
  if Item.ShortCut <> 0 then TextR.Right := ARect.Right - 95;
  DrawTextW(ACanvas.Handle, PWideChar(CapText), Length(CapText), TextR,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE);

  // 6. Draw Shortcut Text
  if Item.ShortCut <> 0 then
  begin
    ScText := ShortCutToText(Item.ShortCut);
    ACanvas.Font.Color := $00D2C7B5;
    TextR := Rect(ARect.Right - 80, ARect.Top, ARect.Right - 12, ARect.Bottom);
    DrawTextW(ACanvas.Handle, PWideChar(ScText), Length(ScText), TextR,
      DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure EnableDwmRoundedCorners(Wnd: HWND);
type
  TDwmSetWindowAttribute = function(hwnd: HWND; dwAttribute: DWORD; pvAttribute: LPCVOID; cbAttribute: DWORD): HRESULT; stdcall;
var
  DwmDll: HMODULE;
  DwmSetWindowAttribute: TDwmSetWindowAttribute;
  CornerPref: DWORD;
  BorderClr: DWORD;
  DarkMode: BOOL;
begin
  DwmDll := LoadLibrary('dwmapi.dll');
  if DwmDll <> 0 then
  begin
    @DwmSetWindowAttribute := GetProcAddress(DwmDll, 'DwmSetWindowAttribute');
    if Assigned(DwmSetWindowAttribute) then
    begin
      DarkMode := True;
      DwmSetWindowAttribute(Wnd, 20, @DarkMode, SizeOf(DarkMode));
      DwmSetWindowAttribute(Wnd, 19, @DarkMode, SizeOf(DarkMode));

      CornerPref := 2; // DWMWCP_ROUND (Smooth native Windows 11 rounded corners)
      DwmSetWindowAttribute(Wnd, 33, @CornerPref, SizeOf(CornerPref));
      BorderClr := ColorToRGB(DP_COLOR_BORDER); // #375263
      DwmSetWindowAttribute(Wnd, 34, @BorderClr, SizeOf(BorderClr));
    end;
    FreeLibrary(DwmDll);
  end;
end;

procedure EnableWindows11DarkMenus(AFormHandle: HWND);
begin
  // Use documented DWM attributes only; menu rendering is owned by VCL.
  if AFormHandle <> 0 then EnableDwmRoundedCorners(AFormHandle);
end;

end.
