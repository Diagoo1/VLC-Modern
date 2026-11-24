unit DarkMemo;
interface
uses Vcl.Controls;
procedure StyleDarkMemos(Parent: TWinControl);
implementation
uses System.Classes, System.Types, System.Math, Winapi.Windows, Winapi.Messages,
  Winapi.GDIPAPI, Winapi.GDIPOBJ, Vcl.StdCtrls, Vcl.Graphics, Vcl.Forms, CurvedControls;
type
  TDarkMemoScroll = class(TCustomControl)
  private
    Memo: TMemo;
    Original: TWndMethod;
    Dragging, Updating: Boolean;
    procedure MemoProc(var Msg: TMessage);
    procedure UpdateGeometry;
    procedure MoveTo(Y: Integer);
    procedure Metrics(out First, Maximum, Thumb: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
constructor TDarkMemoScroll.Create(AOwner: TComponent);
begin
  inherited;
  Name:='PlayerMemoScrollbar';
  Memo:=TMemo(AOwner);
  Memo.ScrollBars:=ssNone;
  Memo.BorderStyle:=bsNone;
  Memo.WordWrap:=True;
  Parent:=Memo;
  DoubleBuffered:=True;
  ControlStyle:=ControlStyle+[csOpaque,csCaptureMouse];
  Original:=Memo.WindowProc;
  Memo.WindowProc:=MemoProc;
  Cursor:=crDefault;
  UpdateGeometry;
end;
destructor TDarkMemoScroll.Destroy;
begin
  Memo.WindowProc:=Original;
  inherited;
end;
procedure TDarkMemoScroll.UpdateGeometry;
var R: TRect; Gap: Integer;
begin
  if Updating or (csDestroying in ComponentState) then Exit;
  Updating:=True;
  try
    Gap:=MulDiv(10,CurrentPPI,96);
    SetBounds(Memo.ClientWidth-MulDiv(14,CurrentPPI,96),0,
      MulDiv(14,CurrentPPI,96),Memo.ClientHeight);
    SetWindowLong(Memo.Handle,GWL_STYLE,GetWindowLong(Memo.Handle,GWL_STYLE) or WS_CLIPCHILDREN);
    R:=Rect(Gap,Gap,Left-Gap,Memo.ClientHeight-Gap);
    SendMessage(Memo.Handle,EM_SETRECTNP,0,LPARAM(@R));
    Invalidate;
  finally Updating:=False; end;
end;
procedure TDarkMemoScroll.MemoProc(var Msg: TMessage);
begin
  if Msg.Msg=WM_MOUSEWHEEL then
  begin
    SendMessage(Memo.Handle,EM_LINESCROLL,0,-SmallInt(HIWORD(Msg.WParam)) div WHEEL_DELTA*3);
    Invalidate;
    Msg.Result:=0;
    Exit;
  end;
  Original(Msg);
  case Msg.Msg of
    WM_SIZE,WM_SETTEXT: UpdateGeometry;
    EM_LINESCROLL,WM_KEYUP: Invalidate;
  end;
end;
procedure TDarkMemoScroll.Metrics(out First, Maximum, Thumb: Integer);
var Lines, Rows: Integer;
begin
  Lines:=Max(1,SendMessage(Memo.Handle,EM_GETLINECOUNT,0,0));
  Rows:=Max(1,(Memo.ClientHeight-MulDiv(20,CurrentPPI,96)) div Max(1,Abs(Memo.Font.Height)+2));
  First:=SendMessage(Memo.Handle,EM_GETFIRSTVISIBLELINE,0,0);
  Maximum:=Max(0,Lines-Rows);
  Thumb:=Min(Height,Max(MulDiv(24,CurrentPPI,96),MulDiv(Height,Rows,Lines)));
end;
procedure TDarkMemoScroll.Paint;
var First,Maximum,Thumb,Y: Integer; G: TGPGraphics; Pen: TGPPen;
begin
  Canvas.Brush.Color:=DP_COLOR_SURFACE;
  Canvas.FillRect(ClientRect);
  Metrics(First,Maximum,Thumb);
  if Maximum=0 then Exit;
  Y:=Round((Height-Thumb)*First/Maximum);
  G:=TGPGraphics.Create(Canvas.Handle);
  Pen:=TGPPen.Create(MakeGDIColor(DP_COLOR_SCROLL),MulDiv(5,CurrentPPI,96));
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    Pen.SetLineCap(LineCapRound,LineCapRound,DashCapRound);
    G.DrawLine(Pen,Width/2,Y+3.0,Width/2,Y+Thumb-3.0);
  finally Pen.Free; G.Free; end;
end;
procedure TDarkMemoScroll.MoveTo(Y: Integer);
var First,Maximum,Thumb,Target: Integer;
begin
  Metrics(First,Maximum,Thumb);
  if Height<=Thumb then Exit;
  Target:=Round(EnsureRange((Y-Thumb/2)/(Height-Thumb),0.0,1.0)*Maximum);
  SendMessage(Memo.Handle,EM_LINESCROLL,0,Target-First);
  Invalidate;
end;
procedure TDarkMemoScroll.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin inherited; if Button=mbLeft then begin Dragging:=True; MoveTo(Y); end; end;
procedure TDarkMemoScroll.MouseMove(Shift: TShiftState; X,Y: Integer);
begin inherited; if Dragging then MoveTo(Y); end;
procedure TDarkMemoScroll.MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin inherited; Dragging:=False; end;
function TDarkMemoScroll.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  SendMessage(Memo.Handle,EM_LINESCROLL,0,-Round(WheelDelta/WHEEL_DELTA*3));
  Invalidate;
  Result:=True;
end;
procedure StyleDarkMemos(Parent: TWinControl);
begin
  for var I:=0 to Parent.ControlCount-1 do
    if Parent.Controls[I] is TMemo then
    begin
      var Memo:=TMemo(Parent.Controls[I]);
      if Memo.FindComponent('PlayerMemoScrollbar')=nil then TDarkMemoScroll.Create(Memo);
    end
    else if Parent.Controls[I] is TWinControl then StyleDarkMemos(TWinControl(Parent.Controls[I]));
end;
end.
