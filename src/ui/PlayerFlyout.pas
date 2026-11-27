unit PlayerFlyout;

interface

uses System.Classes, System.Types, Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls;

type
  TPlayerFlyout = class(TForm)
  private
    Timer: TTimer;
    StartY, TargetY, RestingY: Integer;
    Started: UInt64;
    HideAtEnd: Boolean;
    FRestingBounds: TRect;
    procedure Tick(Sender: TObject);
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure CMShowingChanged(var Msg: TMessage); message CM_SHOWINGCHANGED;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Present(const Bounds: TRect; Animate: Boolean = False);
    procedure Dismiss(Animate: Boolean = False);
    procedure Arrange(const Bounds: TRect);
    property Dismissing: Boolean read HideAtEnd;
    property RestingBounds: TRect read FRestingBounds;
  end;

implementation

uses System.Math, Winapi.Dwmapi, CurvedControls;

constructor TPlayerFlyout.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BorderStyle := bsNone;
  Position := poDesigned;
  PopupMode := pmExplicit;
  if AOwner is TCustomForm then PopupParent := TCustomForm(AOwner);
  Color := DP_COLOR_SURFACE;
  DoubleBuffered := True;
  Timer := TTimer.Create(Self);
  Timer.Enabled := False;
  Timer.Interval := 16;
  Timer.OnTimer := Tick;
end;

procedure TPlayerFlyout.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CAPTION or WS_THICKFRAME;
  Params.ExStyle := (Params.ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE) and not WS_EX_APPWINDOW;
end;

procedure TPlayerFlyout.CreateWnd;
begin
  inherited;
  EnableDwmRoundedCorners(Handle);
  // The dock animates its own position; compositor show/hide effects are independent.
  var DisableTransitions: BOOL := True;
  DwmSetWindowAttribute(Handle, DWMWA_TRANSITIONS_FORCEDISABLED,
    @DisableTransitions, SizeOf(DisableTransitions));
end;

procedure TPlayerFlyout.WMNCCalcSize(var Msg: TWMNCCalcSize);
begin
  Msg.Result := 0;
end;

procedure TPlayerFlyout.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  Msg.Result := HTCLIENT;
end;

procedure TPlayerFlyout.CMShowingChanged(var Msg: TMessage);
begin
  if Showing then ShowWindow(Handle, SW_SHOWNOACTIVATE)
  else ShowWindow(Handle, SW_HIDE);
  Msg.Result := 0;
end;

procedure TPlayerFlyout.WMMouseActivate(var Msg: TWMMouseActivate);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TPlayerFlyout.Present(const Bounds: TRect; Animate: Boolean);
var WasVisible: Boolean;
begin
  WasVisible := Visible;
  Timer.Enabled := False;
  HideAtEnd := False;
  FRestingBounds := Bounds;
  TargetY := Bounds.Top;
  RestingY := TargetY;
  StartY := Top;
  if not WasVisible then StartY := TargetY + 24;
  HandleNeeded;
  SetBounds(Bounds.Left, TargetY, Bounds.Width, Bounds.Height);
  var PresentY := TargetY;
  if Animate then PresentY := StartY;
  if PresentY <> TargetY then Top := PresentY;
  Visible := True;
  SetWindowPos(Handle, HWND_TOP, Bounds.Left, PresentY, Bounds.Width, Bounds.Height,
    SWP_NOACTIVATE or SWP_SHOWWINDOW);
  if Animate and (Top <> TargetY) then
  begin
    Started := GetTickCount64;
    Timer.Enabled := True;
  end;
end;

procedure TPlayerFlyout.Arrange(const Bounds: TRect);
begin
  FRestingBounds := Bounds;
  RestingY := Bounds.Top;
  var NewTop := Bounds.Top;
  if Timer.Enabled then NewTop := Top;
  SetBounds(Bounds.Left, NewTop, Bounds.Width, Bounds.Height);
end;

procedure TPlayerFlyout.Dismiss(Animate: Boolean);
begin
  Timer.Enabled := False;
  if not Animate or not Visible then
  begin Hide; Exit; end;
  StartY := Top;
  TargetY := Monitor.BoundsRect.Bottom + 4;
  HideAtEnd := True;
  Started := GetTickCount64;
  Timer.Enabled := True;
end;

procedure TPlayerFlyout.Tick(Sender: TObject);
var P: Double;
begin
  P := Min(1.0, (GetTickCount64 - Started) / 150.0);
  Top := StartY + Round((TargetY - StartY) * (1 - Power(1 - P, 3)));
  if P >= 1 then
  begin
    Timer.Enabled := False;
    if HideAtEnd then
    begin
      Hide;
      Top := RestingY;
      HideAtEnd := False;
    end;
  end;
end;

end.
