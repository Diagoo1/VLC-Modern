unit PlayerChrome;

interface
uses Vcl.Forms;
procedure ApplyPlayerChrome(Form: TForm; TitleOnlyDrag: Boolean = False);

implementation
uses PlayerLanguage, System.Classes, System.Types, System.Math, System.Generics.Collections,
  System.SysUtils, Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, Winapi.Dwmapi, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, CurvedControls;

type
  TPlayerChrome = class(TComponent)
  private
    Form: TForm;
    Title: TModernTitleBar;
    CloseButton, MaxButton: TModernVectorButton;
    FUpdating: Boolean;
    Surfaces: TList<HWND>;
    PreviousProc: TWndMethod;
    FixedDialog: Boolean;
    FTitleOnlyDrag: Boolean;
    procedure WindowProc(var Msg: TMessage);
    procedure BindSurfaces(Parent: TWinControl);
    procedure CloseClick(Sender: TObject);
    procedure MaxClick(Sender: TObject);
    procedure Layout;
  public
    constructor Create(AOwner: TComponent; TitleOnlyDrag: Boolean); reintroduce;
    destructor Destroy; override;
    procedure Bind;
  end;

function SurfaceProc(Wnd: HWND; Msg: UINT; W: WPARAM; L: LPARAM;
  ID: UINT_PTR; Data: DWORD_PTR): LRESULT; stdcall;
var Chrome: TPlayerChrome;
begin
  if Msg=WM_NCDESTROY then
  begin RemoveWindowSubclass(Wnd,@SurfaceProc,ID); Exit(DefSubclassProc(Wnd,Msg,W,L)); end;
  Chrome:=TPlayerChrome(Data);
  if csDestroying in Chrome.Form.ComponentState then Exit(DefSubclassProc(Wnd,Msg,W,L));
  if (Msg=WM_LBUTTONDOWN) and (Chrome.Form.Parent=nil) and
    IsWindowEnabled(Chrome.Form.Handle) then
  begin
    ReleaseCapture;
    var Cursor := Mouse.CursorPos;
    SendMessage(Chrome.Form.Handle, WM_NCLBUTTONDOWN, HTCAPTION, MakeLParam(Cursor.X, Cursor.Y));
    Exit(0);
  end;
  Result:=DefSubclassProc(Wnd,Msg,W,L);
end;

function ChromeProc(Wnd: HWND; Msg: UINT; W: WPARAM; L: LPARAM;
  ID: UINT_PTR; Data: DWORD_PTR): LRESULT; stdcall;
var Chrome: TPlayerChrome; R: TRect; Current: DWORD_PTR;
    ComposeShow, ComposeResize: Boolean; Cloaked: BOOL;
begin
  Chrome := TPlayerChrome(Data);
  if csDestroying in Chrome.Form.ComponentState then Exit(DefSubclassProc(Wnd,Msg,W,L));
  if (Msg = WM_SYSCOMMAND) and ((W and $FFF0) = SC_SIZE) then Exit(0);
  ComposeShow := (Msg = WM_WINDOWPOSCHANGED) and (L <> 0) and
    ((PWindowPos(L)^.flags and SWP_SHOWWINDOW) <> 0);
  ComposeResize := (Msg = WM_SYSCOMMAND) and
    ((W and $FFF0 = SC_MAXIMIZE) or (W and $FFF0 = SC_RESTORE)) and
    IsWindowVisible(Wnd);
  if ComposeResize then
  begin
    Cloaked := True;
    ComposeResize := Succeeded(DwmSetWindowAttribute(Wnd, DWMWA_CLOAK, @Cloaked, SizeOf(Cloaked)));
  end;
  if (Msg = WM_WINDOWPOSCHANGING) and (L <> 0) and
     ((PWindowPos(L)^.flags and SWP_SHOWWINDOW) <> 0) then
  begin
    var DisableTransitions: BOOL := True;
    DwmSetWindowAttribute(Wnd, DWMWA_TRANSITIONS_FORCEDISABLED,
      @DisableTransitions, SizeOf(DisableTransitions));
    Cloaked := True;
    DwmSetWindowAttribute(Wnd, DWMWA_CLOAK, @Cloaked, SizeOf(Cloaked));
    if (Chrome.Form.Parent = nil) and not IsZoomed(Wnd) and not IsIconic(Wnd) and
       GetWindowRect(Wnd, R) then
    begin
      var Position := PWindowPos(L);
      var Work := Screen.MonitorFromWindow(Wnd).WorkareaRect;
      var Width := Min(R.Width, Work.Width);
      var Height := Min(R.Height, Work.Height);
      if (Position^.flags and SWP_NOSIZE) = 0 then
      begin
        Width := Min(Position^.cx, Work.Width);
        Height := Min(Position^.cy, Work.Height);
      end;
      if (Width <> R.Width) or (Height <> R.Height) then
      begin
        Position^.flags := Position^.flags and not SWP_NOSIZE;
        Position^.cx := Width;
        Position^.cy := Height;
      end;
      var X := R.Left;
      var Y := R.Top;
      if (Position^.flags and SWP_NOMOVE) = 0 then
      begin
        X := Position^.x;
        Y := Position^.y;
      end;
      Position^.x := EnsureRange(X, Work.Left, Work.Right - Width);
      Position^.y := EnsureRange(Y, Work.Top, Work.Bottom - Height);
      if (Position^.x <> R.Left) or (Position^.y <> R.Top) then
        Position^.flags := Position^.flags and not SWP_NOMOVE;
    end;
  end;
  if (Chrome.Form.Parent = nil) and (Msg = WM_NCCALCSIZE) then
  begin
    if (W <> 0) and (Chrome.Form.WindowState = wsMaximized) then
      PNCCalcSizeParams(L)^.rgrc[0] := Screen.MonitorFromWindow(Wnd).WorkareaRect;
    Exit(0);
  end;
  if (Msg=WM_LBUTTONDOWN) and (Chrome.Form.Parent=nil) and not Chrome.FTitleOnlyDrag then
  begin
    ReleaseCapture;
    var Cursor := Mouse.CursorPos;
    SendMessage(Wnd, WM_NCLBUTTONDOWN, HTCAPTION, MakeLParam(Cursor.X, Cursor.Y));
    Exit(0);
  end;
  try
    Result := DefSubclassProc(Wnd, Msg, W, L);
    if ComposeResize and IsWindow(Wnd) then Chrome.Layout;
    if ComposeShow and IsWindow(Wnd) then Chrome.BindSurfaces(Chrome.Form);
    if (ComposeShow or ComposeResize) and IsWindow(Wnd) then
      RedrawWindow(Wnd, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW);
  finally
    if (ComposeShow or ComposeResize) and IsWindow(Wnd) then
    begin
      Cloaked := False;
      DwmSetWindowAttribute(Wnd, DWMWA_CLOAK, @Cloaked, SizeOf(Cloaked));
    end;
  end;
  if Msg = WM_NCDESTROY then
  begin RemoveWindowSubclass(Wnd, @ChromeProc, ID); Exit; end;
  if not GetWindowSubclass(Wnd,@ChromeProc,ID,Current) or (Current<>Data) then Exit;
  if (Msg = WM_SIZE) and (W <> SIZE_MINIMIZED) then
  begin
    Chrome.Layout;
  end;
  if (Msg = WM_NCHITTEST) and (Result >= HTLEFT) and (Result <= HTBOTTOMRIGHT) then
    Result := HTCLIENT;
end;

constructor TPlayerChrome.Create(AOwner: TComponent; TitleOnlyDrag: Boolean);
var H: Integer; AbsoluteContent: Boolean;
begin
  inherited Create(AOwner);
  FTitleOnlyDrag := TitleOnlyDrag;
  Name := 'PlayerWindowChrome';
  Form := TForm(AOwner);
  Surfaces:=TList<HWND>.Create;
  FixedDialog:=Form.BorderStyle in [bsDialog,bsSingle];
  if Form.BorderStyle=bsDialog then Form.BorderStyle:=bsSizeable;
  Form.Constraints.MinWidth:=Max(Form.Constraints.MinWidth,Min(Form.Width,MulDiv(480,Form.CurrentPPI,96)));
  Form.Constraints.MinHeight:=Max(Form.Constraints.MinHeight,Form.Height);
  // Keep a real form-owned resize strip outside aligned child HWNDs.
  var Edge:=MulDiv(6,Form.CurrentPPI,96);
  Form.Padding.SetBounds(Edge,0,Edge,Edge);
  H:=MulDiv(36,Form.CurrentPPI,96);
  AbsoluteContent:=False;
  for var I:=0 to Form.ControlCount-1 do
    if Form.Controls[I].Align=alNone then
    begin
      Form.Controls[I].Top:=Form.Controls[I].Top+H;
      AbsoluteContent:=True;
    end;
  if AbsoluteContent then Form.ClientHeight:=Form.ClientHeight+H;
  Title := TModernTitleBar.Create(Self);
  Title.Parent := Form;
  Title.Align := alNone;
  Title.Anchors := [akLeft, akTop, akRight];
  Form.Padding.Top:=H;
  Title.TitleText := Form.Caption;
  Title.SetIcon(Application.Icon);
  Title.LoadAppIconFromResource('APP_ICON_PNG');
  CloseButton := TModernVectorButton.Create(Self);
  CloseButton.Parent := Title;
  CloseButton.IconKind := ikClose;
  CloseButton.Hint := 'Close';
  CloseButton.ShowHint := True;
  CloseButton.OnClick := CloseClick;
  MaxButton := TModernVectorButton.Create(Self);
  MaxButton.Parent := Title;
  MaxButton.IconKind := ikMaximize;
  MaxButton.Hint := 'Maximize or restore';
  MaxButton.ShowHint := True;
  MaxButton.OnClick := MaxClick;
  PreviousProc:=Form.WindowProc;
  Form.WindowProc:=WindowProc;
  Bind;
end;

procedure TPlayerChrome.WindowProc(var Msg: TMessage);
begin
  if csDestroying in Form.ComponentState then begin PreviousProc(Msg); Exit; end;
  if (Form.Parent = nil) and (Msg.Msg = WM_SYSCOMMAND) and
     ((Msg.WParam and $FFF0) = SC_SIZE) then
  begin
    Msg.Result := 0;
    Exit;
  end;
  if (Msg.Msg=WM_NCCALCSIZE) and (Form.Parent=nil) then
  begin Msg.Result:=0; Exit; end;
  PreviousProc(Msg);
  if (Form.Parent = nil) and (Msg.Msg = WM_NCHITTEST) and
     (Msg.Result >= HTLEFT) and (Msg.Result <= HTBOTTOMRIGHT) then
    Msg.Result := HTCLIENT;
  // Popup ownership may recreate HWND on ShowModal. Install the frame during
  // creation, before it becomes visible, rather than reshaping a shown window.
  if (Msg.Msg=WM_CREATE) and not (csDestroying in ComponentState) then Bind;
  if (Msg.Msg=WM_SIZE) and (Msg.WParam<>SIZE_MINIMIZED) then Layout;
end;

destructor TPlayerChrome.Destroy;
var Data: DWORD_PTR;
begin
  Form.WindowProc:=PreviousProc;
  if Form.HandleAllocated then RemoveWindowSubclass(Form.Handle, @ChromeProc, 402);
  for var Wnd in Surfaces do
    if GetWindowSubclass(Wnd,@SurfaceProc,404,Data) and (Data=DWORD_PTR(Self)) then
      RemoveWindowSubclass(Wnd,@SurfaceProc,404);
  Surfaces.Free;
  inherited;
end;

procedure TPlayerChrome.Bind;
var Current: DWORD_PTR;
begin
  if csDestroying in Form.ComponentState then Exit;
  if Form.Parent = nil then
  begin
    Form.DoubleBuffered := True;
    if not GetWindowSubclass(Form.Handle,@ChromeProc,402,Current) then
    begin
    SetWindowSubclass(Form.Handle, @ChromeProc, 402, DWORD_PTR(Self));
    SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) and not WS_THICKFRAME);
    SetWindowPos(Form.Handle, 0, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED);
    EnableDwmRoundedCorners(Form.Handle);
    end;
  end;
  Layout;
  BindSurfaces(Form);
end;

procedure TPlayerChrome.BindSurfaces(Parent: TWinControl);
begin
  for var I:=0 to Parent.ControlCount-1 do
    if Parent.Controls[I] is TWinControl then
    begin
      var Child:=TWinControl(Parent.Controls[I]);
      if (Child is TPanel) or (Child is TGroupBox) or
        (Child is TTabSheet) or (Child is TScrollBox) or (Child is TModernCardPanel) then
        Child.DoubleBuffered := True;
      if not FTitleOnlyDrag and Child.HandleAllocated and ((Child is TPanel) or (Child is TGroupBox) or
        (Child is TTabSheet) or (Child is TScrollBox) or (Child is TModernCardPanel)) then
      begin
        SetWindowSubclass(Child.Handle,@SurfaceProc,404,DWORD_PTR(Self));
        if not Surfaces.Contains(Child.Handle) then Surfaces.Add(Child.Handle);
      end;
      BindSurfaces(Child);
    end;
end;

procedure TPlayerChrome.Layout;
var H: Integer; ShowTitle: Boolean; Bounds: TRect;
begin
  if FUpdating or (csDestroying in ComponentState) or (csDestroying in Form.ComponentState) then Exit;
  FUpdating := True;
  try
  ShowTitle := Form.Parent = nil;
  if Title.Visible <> ShowTitle then Title.Visible := ShowTitle;
  if not ShowTitle then
  begin
    if (Form.Padding.Left <> 0) or (Form.Padding.Top <> 0) or
       (Form.Padding.Right <> 0) or (Form.Padding.Bottom <> 0) then
      Form.Padding.SetBounds(0,0,0,0);
    Exit;
  end;
  var Edge:=MulDiv(6,Form.CurrentPPI,96);
  H := MulDiv(36, Form.CurrentPPI, 96);
  if (Form.Padding.Left <> Edge) or (Form.Padding.Top <> H) or
     (Form.Padding.Right <> Edge) or (Form.Padding.Bottom <> Edge) then
    Form.Padding.SetBounds(Edge,H,Edge,Edge);
  if GetClientRect(Form.Handle, Bounds) then
    Title.SetBounds(0,0,Bounds.Width,H);
  Title.TitleText := Form.Caption;
  PlaceLocalized(CloseButton, Title.Width-H-4, 2, H, H-4);
  MaxButton.Visible := (Form.BorderStyle = bsSizeable) and not FixedDialog;
  PlaceLocalized(MaxButton, Title.Width-2*H-4, 2, H, H-4);
  if Form.WindowState = wsMaximized then MaxButton.IconKind := ikRestore
  else MaxButton.IconKind := ikMaximize;
  finally FUpdating := False; end;
end;

procedure TPlayerChrome.CloseClick(Sender: TObject);
begin Form.Close; end;

procedure TPlayerChrome.MaxClick(Sender: TObject);
begin
  if Form.WindowState = wsMaximized then SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
  else SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  Layout;
  Title.Invalidate;
end;

procedure ApplyPlayerChrome(Form: TForm; TitleOnlyDrag: Boolean);
var Chrome: TPlayerChrome;
begin
  if Form.ClassName = 'TFrmMain' then Exit;
  Chrome := TPlayerChrome(Form.FindComponent('PlayerWindowChrome'));
  if Form.Parent <> nil then
  begin
    if Chrome <> nil then Chrome.Layout;
    Exit;
  end;
  if Chrome = nil then TPlayerChrome.Create(Form, TitleOnlyDrag) else Chrome.Bind;
end;

end.
