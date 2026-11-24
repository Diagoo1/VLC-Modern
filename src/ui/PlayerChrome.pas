unit PlayerChrome;

interface
uses Vcl.Forms;
procedure ApplyPlayerChrome(Form: TForm);

implementation
uses System.Classes, System.Types, System.Math, System.Generics.Collections,
  System.SysUtils, Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, CurvedControls;

type
  TPlayerChrome = class(TComponent)
  private
    Form: TForm;
    Title: TModernTitleBar;
    CloseButton, MaxButton: TModernVectorButton;
    FUpdating: Boolean;
    FSizing:Boolean;
    Surfaces: TList<HWND>;
    PreviousProc: TWndMethod;
    FixedDialog: Boolean;
    procedure WindowProc(var Msg: TMessage);
    procedure BindSurfaces(Parent: TWinControl);
    procedure CloseClick(Sender: TObject);
    procedure MaxClick(Sender: TObject);
    procedure Layout;
  public
    constructor Create(AOwner: TComponent); override;
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
    SendMessage(Chrome.Form.Handle,WM_SYSCOMMAND,$F012,0);
    Exit(0);
  end;
  Result:=DefSubclassProc(Wnd,Msg,W,L);
end;

function ChromeProc(Wnd: HWND; Msg: UINT; W: WPARAM; L: LPARAM;
  ID: UINT_PTR; Data: DWORD_PTR): LRESULT; stdcall;
var Chrome: TPlayerChrome; P: TPoint; Edge: Integer; R: TRect; Current: DWORD_PTR;
begin
  Chrome := TPlayerChrome(Data);
  if csDestroying in Chrome.Form.ComponentState then Exit(DefSubclassProc(Wnd,Msg,W,L));
  if (Msg=WM_WINDOWPOSCHANGING) and (L<>0) and
     (Chrome.Form.Parent=nil) then
    PWindowPos(L)^.flags:=PWindowPos(L)^.flags or SWP_NOCOPYBITS;
  if Msg=WM_ENTERSIZEMOVE then
  begin
    Chrome.FSizing:=True;
    SetWindowLong(Wnd,GWL_EXSTYLE,GetWindowLong(Wnd,GWL_EXSTYLE) or WS_EX_COMPOSITED);
  end
  else if (Msg=WM_EXITSIZEMOVE) and Chrome.FSizing then
  begin
    Chrome.FSizing:=False;
    SetWindowLong(Wnd,GWL_EXSTYLE,GetWindowLong(Wnd,GWL_EXSTYLE) and not WS_EX_COMPOSITED);
    RedrawWindow(Wnd,nil,0,RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW);
  end;
  if (Chrome.Form.Parent = nil) and (Msg = WM_NCCALCSIZE) then
  begin
    if (W <> 0) and (Chrome.Form.WindowState = wsMaximized) then
      PNCCalcSizeParams(L)^.rgrc[0] := Screen.MonitorFromWindow(Wnd).WorkareaRect;
    Exit(0);
  end;
  if (Msg=WM_LBUTTONDOWN) and (Chrome.Form.Parent=nil) then
  begin
    ReleaseCapture;
    SendMessage(Wnd,WM_SYSCOMMAND,$F012,0);
    Exit(0);
  end;
  Result := DefSubclassProc(Wnd, Msg, W, L);
  if Msg = WM_NCDESTROY then
  begin RemoveWindowSubclass(Wnd, @ChromeProc, ID); Exit; end;
  if not GetWindowSubclass(Wnd,@ChromeProc,ID,Current) or (Current<>Data) then Exit;
  if Msg = WM_SIZE then Chrome.Layout;
  if (Msg <> WM_NCHITTEST) or (Chrome.Form.Parent <> nil) or
    (Chrome.Form.WindowState = wsMaximized) or (Chrome.Form.BorderStyle <> bsSizeable) then Exit;
  P := Chrome.Form.ScreenToClient(Point(SmallInt(LOWORD(L)), SmallInt(HIWORD(L))));
  Edge := MulDiv(6, Chrome.Form.CurrentPPI, 96);
  R := Chrome.Form.ClientRect;
  if P.Y < Edge then
  begin
    if P.X < Edge then Result := HTTOPLEFT
    else if P.X >= R.Right-Edge then Result := HTTOPRIGHT else Result := HTTOP;
  end
  else if P.Y >= R.Bottom-Edge then
  begin
    if P.X < Edge then Result := HTBOTTOMLEFT
    else if P.X >= R.Right-Edge then Result := HTBOTTOMRIGHT else Result := HTBOTTOM;
  end
  else if P.X < Edge then Result := HTLEFT
  else if P.X >= R.Right-Edge then Result := HTRIGHT;
end;

constructor TPlayerChrome.Create(AOwner: TComponent);
var H: Integer; AbsoluteContent: Boolean;
begin
  inherited;
  Name := 'PlayerWindowChrome';
  Form := TForm(AOwner);
  Surfaces:=TList<HWND>.Create;
  FixedDialog:=Form.BorderStyle=bsDialog;
  if Form.BorderStyle in [bsDialog,bsSingle] then Form.BorderStyle:=bsSizeable;
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
  Form.Padding.Top:=H;
  Title.TitleText := Form.Caption;
  Title.SetIcon(Application.Icon);
  Title.LoadAppIconFromResource('APP_ICON_PNG');
  CloseButton := TModernVectorButton.Create(Self);
  CloseButton.Parent := Title;
  CloseButton.IconKind := ikClose;
  CloseButton.OnClick := CloseClick;
  MaxButton := TModernVectorButton.Create(Self);
  MaxButton.Parent := Title;
  MaxButton.IconKind := ikMaximize;
  MaxButton.OnClick := MaxClick;
  PreviousProc:=Form.WindowProc;
  Form.WindowProc:=WindowProc;
  Bind;
end;

procedure TPlayerChrome.WindowProc(var Msg: TMessage);
begin
  if csDestroying in Form.ComponentState then begin PreviousProc(Msg); Exit; end;
  if (Msg.Msg=WM_NCCALCSIZE) and (Form.Parent=nil) then
  begin Msg.Result:=0; Exit; end;
  PreviousProc(Msg);
  // Popup ownership may recreate HWND on ShowModal. Install the frame during
  // creation, before it becomes visible, rather than reshaping a shown window.
  if (Msg.Msg=WM_CREATE) and not (csDestroying in ComponentState) then Bind;
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
    if not GetWindowSubclass(Form.Handle,@ChromeProc,402,Current) then
    begin
    SetWindowSubclass(Form.Handle, @ChromeProc, 402, DWORD_PTR(Self));
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
      if Child.HandleAllocated and ((Child is TPanel) or (Child is TGroupBox) or
        (Child is TTabSheet) or (Child is TScrollBox) or (Child is TModernCardPanel)) then
      begin
        SetWindowSubclass(Child.Handle,@SurfaceProc,404,DWORD_PTR(Self));
        if not Surfaces.Contains(Child.Handle) then Surfaces.Add(Child.Handle);
      end;
      BindSurfaces(Child);
    end;
end;

procedure TPlayerChrome.Layout;
var H: Integer; ShowTitle: Boolean;
begin
  if FUpdating or (csDestroying in ComponentState) or (csDestroying in Form.ComponentState) then Exit;
  FUpdating := True;
  try
  ShowTitle := Form.Parent = nil;
  if Title.Visible <> ShowTitle then Title.Visible := ShowTitle;
  if not ShowTitle then begin Form.Padding.SetBounds(0,0,0,0); Exit; end;
  var Edge:=MulDiv(6,Form.CurrentPPI,96);
  Form.Padding.SetBounds(Edge,MulDiv(36,Form.CurrentPPI,96),Edge,Edge);
  H := MulDiv(36, Form.CurrentPPI, 96);
  Title.SetBounds(0,0,Form.ClientWidth,H);
  Title.TitleText := Form.Caption;
  CloseButton.SetBounds(Title.Width-H-4, 2, H, H-4);
  MaxButton.Visible := (Form.BorderStyle = bsSizeable) and not FixedDialog;
  MaxButton.SetBounds(CloseButton.Left-H, 2, H, H-4);
  if Form.WindowState = wsMaximized then MaxButton.IconKind := ikRestore
  else MaxButton.IconKind := ikMaximize;
  finally FUpdating := False; end;
end;

procedure TPlayerChrome.CloseClick(Sender: TObject);
begin Form.Close; end;

procedure TPlayerChrome.MaxClick(Sender: TObject);
begin
  if Form.WindowState = wsMaximized then Form.WindowState := wsNormal
  else Form.WindowState := wsMaximized;
end;

procedure ApplyPlayerChrome(Form: TForm);
var Chrome: TPlayerChrome;
begin
  if Form.ClassName = 'TFrmMain' then Exit;
  Chrome := TPlayerChrome(Form.FindComponent('PlayerWindowChrome'));
  if Form.Parent <> nil then
  begin
    if Chrome <> nil then Chrome.Layout;
    Exit;
  end;
  if Chrome = nil then TPlayerChrome.Create(Form) else Chrome.Bind;
end;

end.
