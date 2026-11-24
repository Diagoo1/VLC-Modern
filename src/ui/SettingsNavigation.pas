unit SettingsNavigation;

interface

uses System.Classes, System.Types, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls;

type
  // One buffered surface owns hover, selection and vector icons. No native
  // listbox painting is mixed into the animation.
  TSettingsNavigation = class(TCustomControl)
  private
    FItems: TStringList;
    FItemIndex, FHot: Integer;
    FHover: array of Single;
    FIndicator: Single;
    FLastTick: UInt64;
    FTimer: TTimer;
    procedure Tick(Sender: TObject);
    procedure SetItemIndex(Value: Integer);
    procedure ItemsChanged(Sender: TObject);
    procedure Animate;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    function RowHeight: Integer;
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Items: TStringList read FItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property OnClick;
    property Font;
    property DoubleBuffered;
  end;

implementation

uses System.Math, Winapi.GDIPAPI, Winapi.GDIPOBJ, CurvedControls;

procedure Rounded(G: TGPGraphics; const R: TRect; Radius: Single; Color: TColor);
var Path: TGPGraphicsPath; Brush: TGPSolidBrush; D: Single;
begin
  Path := TGPGraphicsPath.Create;
  Brush := TGPSolidBrush.Create(MakeGDIColor(Color));
  try
    D := Radius * 2;
    Path.AddArc(R.Left, R.Top, D, D, 180, 90);
    Path.AddArc(R.Right-D, R.Top, D, D, 270, 90);
    Path.AddArc(R.Right-D, R.Bottom-D, D, D, 0, 90);
    Path.AddArc(R.Left, R.Bottom-D, D, D, 90, 90);
    Path.CloseFigure;
    G.FillPath(Brush, Path);
  finally Brush.Free; Path.Free; end;
end;

procedure Icon(G: TGPGraphics; Index: Integer; X, Y, Scale, Motion: Single; Color: TColor);
var Pen: TGPPen; State: GraphicsState;
  procedure L(X1,Y1,X2,Y2: Single);
  begin G.DrawLine(Pen,X1,Y1,X2,Y2); end;
  procedure E(X1,Y1,W,H: Single);
  begin G.DrawEllipse(Pen,X1,Y1,W,H); end;
begin
  State := G.Save;
  Pen := TGPPen.Create(MakeGDIColor(Color),1.6);
  try
    Pen.SetStartCap(LineCapRound);
    Pen.SetEndCap(LineCapRound);
    Pen.SetLineJoin(LineJoinRound);
    G.TranslateTransform(X,Y-Motion*Scale);
    G.ScaleTransform(Scale,Scale);
    if (Index=0) and (Motion<>0) then G.RotateTransform(Motion*18);
    case Index of
      0: begin
        E(-5,-5,10,10); E(-1.5,-1.5,3,3);
        for var I:=0 to 7 do begin
          L(Cos(I*Pi/4)*6,Sin(I*Pi/4)*6,Cos(I*Pi/4)*8,Sin(I*Pi/4)*8);
        end;
      end;
      1: begin L(-4,-7,7,0); L(7,0,-4,7); L(-4,7,-4,-7); end;
      2: begin G.DrawRectangle(Pen,-8,-6,16,11); L(-3,8,3,8); L(0,5,0,8); end;
      3: begin
        L(-8,-3,-4,-3); L(-4,-3,1,-7); L(1,-7,1,7); L(1,7,-4,3);
        L(-4,3,-8,3); L(-8,3,-8,-3);
        G.DrawArc(Pen,0,-5,10,10,-60,120);
        G.DrawArc(Pen,0,-8,16,16,-55,110);
      end;
      4: begin G.DrawRectangle(Pen,-8,-6,16,12); L(-5,0,-1,0); L(2,0,5,0); L(-5,3,5,3); end;
      5: begin E(-8,-8,16,16); G.DrawEllipse(Pen,-4,-8,8,16); L(-7,-3,7,-3); L(-7,3,7,3); end;
      6: begin
        L(-8,-6,-2,-6); L(-2,-6,0,-3); L(0,-3,8,-3); L(8,-3,8,7);
        L(8,7,-8,7); L(-8,7,-8,-6);
      end;
      7: begin
        L(-6,-8,-6,8); L(0,-8,0,8); L(6,-8,6,8);
        E(-8,-4,4,4); E(-2,1,4,4); E(4,-6,4,4);
      end;
      8: begin G.DrawRectangle(Pen,-8,-7,16,14); E(1,-4,3,3); L(-7,5,-2,-1); L(-2,-1,3,5); L(3,5,7,1); end;
      9: begin E(-8,-8,16,16); L(0,-5,0,0); L(0,0,4,2); end;
    end;
  finally Pen.Free; G.Restore(State); end;
end;

constructor TSettingsNavigation.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque,csClickEvents];
  DoubleBuffered := True;
  TabStop := True;
  FItems := TStringList.Create;
  FItems.OnChange := ItemsChanged;
  FItemIndex := -1;
  FHot := -1;
  FIndicator := -1;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 16;
  FTimer.OnTimer := Tick;
end;

destructor TSettingsNavigation.Destroy;
begin
  FTimer.Enabled := False;
  FItems.Free;
  inherited;
end;

function TSettingsNavigation.RowHeight: Integer;
begin
  Result := MulDiv(40,CurrentPPI,96);
  if Items.Count > 0 then Result := Max(1,Min(Result,ClientHeight div Items.Count));
end;

procedure TSettingsNavigation.ItemsChanged(Sender: TObject);
begin SetLength(FHover,FItems.Count); Invalidate; end;

procedure TSettingsNavigation.Animate;
begin
  if not FTimer.Enabled then FLastTick := GetTickCount64;
  FTimer.Enabled := True;
end;

procedure TSettingsNavigation.SetItemIndex(Value: Integer);
begin
  Value := EnsureRange(Value,-1,FItems.Count-1);
  if Value=FItemIndex then Exit;
  FItemIndex := Value;
  if FIndicator<0 then FIndicator := Value;
  Animate;
end;

procedure TSettingsNavigation.Tick(Sender: TObject);
var Target, Factor: Single; Moving: Boolean; Now: UInt64;
begin
  Now := GetTickCount64;
  // Convert before negating: UInt64 clock arithmetic would otherwise wrap
  // the negative exponent and poison animation coordinates with infinity.
  Factor := 1-Exp(-Single(Min(UInt64(64),Now-FLastTick))/42);
  FLastTick := Now;
  Moving := False;
  for var I:=0 to High(FHover) do
  begin
    if I=FHot then Target:=1 else Target:=0;
    FHover[I]:=FHover[I]+(Target-FHover[I])*Factor;
    if Abs(FHover[I]-Target)<0.005 then FHover[I]:=Target else Moving:=True;
  end;
  FIndicator := FIndicator+(FItemIndex-FIndicator)*Factor;
  if Abs(FIndicator-FItemIndex)<0.005 then FIndicator:=FItemIndex else Moving:=True;
  Invalidate;
  FTimer.Enabled := Moving;
end;

procedure TSettingsNavigation.MouseMove(Shift: TShiftState; X,Y: Integer);
var Hot: Integer;
begin
  inherited;
  Hot := Y div RowHeight;
  if (Hot>=FItems.Count) or (Y<0) then Hot:=-1;
  if Hot=FHot then Exit;
  FHot:=Hot;
  Animate;
end;

procedure TSettingsNavigation.CMMouseLeave(var Msg: TMessage);
begin inherited; FHot:=-1; Animate; end;

procedure TSettingsNavigation.Click;
begin
  inherited;
  // A first visit may initialize native page controls. Keep that work out
  // of the indicator clock so the next frame does not jump ahead.
  FLastTick:=GetTickCount64;
end;

procedure TSettingsNavigation.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var Index: Integer;
begin
  inherited;
  if Button<>mbLeft then Exit;
  SetFocus;
  Index:=Y div RowHeight;
  if (Index<0) or (Index>=FItems.Count) then Exit;
  ItemIndex:=Index;
end;

procedure TSettingsNavigation.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin Msg.Result:=DLGC_WANTARROWS; end;

procedure TSettingsNavigation.KeyDown(var Key: Word; Shift: TShiftState);
var Index: Integer;
begin
  inherited;
  Index:=ItemIndex;
  case Key of
    VK_UP: Dec(Index);
    VK_DOWN: Inc(Index);
    VK_HOME: Index:=0;
    VK_END: Index:=Items.Count-1;
  else Exit;
  end;
  ItemIndex:=EnsureRange(Index,0,Items.Count-1);
  Click;
  Key:=0;
end;

procedure TSettingsNavigation.Paint;
var G: TGPGraphics; R, TextRect: TRect; S: Single; C: TColor;
begin
  Canvas.Brush.Color:=DP_COLOR_SURFACE;
  Canvas.FillRect(ClientRect);
  Canvas.Font.Assign(Font);
  G:=TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    S:=CurrentPPI/96;
    Rounded(G,ClientRect,10*S,DP_COLOR_BG);
    for var I:=0 to FItems.Count-1 do
    begin
      R:=Rect(0,I*RowHeight,Width,(I+1)*RowHeight);
      InflateRect(R,-2,-3);
      if I=FItemIndex then Rounded(G,R,6*S,DP_COLOR_ELEVATED)
      else if FHover[I]>0 then
        Rounded(G,R,6*S,RGB(24+Round(10*FHover[I]),24+Round(10*FHover[I]),24+Round(10*FHover[I])));
      if (I=FItemIndex) or (FHover[I]>0.1) then C:=DP_COLOR_ACCENT else C:=DP_COLOR_MUTED;
      var Kind:=I;
      case I of
        7,11: Kind:=8;
        8,10: Kind:=7;
        9: Kind:=4;
        12: Kind:=9;
      end;
      Icon(G,Kind,25*S,(I+0.5)*RowHeight,S,FHover[I],C);
    end;
    if FItemIndex>=0 then
    begin
      R:=Rect(Round(2*S),Round((FIndicator+0.5)*RowHeight-9*S),Round(5*S),Round((FIndicator+0.5)*RowHeight+9*S));
      Rounded(G,R,1.5*S,DP_COLOR_ACCENT);
    end;
  finally G.Free; end;
  // Finish GDI+ before touching the same DC through VCL/GDI text APIs.
  // Mixing the two in the drawing loop can discard pending vector strokes.
  Canvas.Brush.Style:=bsClear;
  Canvas.Font.Color:=DP_COLOR_TEXT;
  for var I:=0 to FItems.Count-1 do
  begin
    TextRect:=Rect(Round(48*S),I*RowHeight,Width-Round(10*S),(I+1)*RowHeight);
    DrawText(Canvas.Handle,PChar(FItems[I]),-1,TextRect,DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);
  end;
  Canvas.Brush.Style:=bsSolid;
end;

end.
