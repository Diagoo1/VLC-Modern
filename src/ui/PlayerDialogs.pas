unit PlayerDialogs;

interface

uses Vcl.Forms, Vcl.StdCtrls;

type
  TOverflowHintLabel = class(TLabel);

procedure PlayerMessage(const Text: string);
function PlayerInput(const Title, Prompt: string; var Value: string): Boolean;
function PlayerResume(const Position: string; out Remember: Boolean): Boolean;
procedure InitializePlayerAppearance;
procedure ApplyPlayerAppearance(Form: TForm);
function PlayerChooseSubtitle(const Items: TArray<string>): Integer;

var
  GAppClosing: Boolean = False;

implementation

uses
  System.Classes, System.Types, System.UITypes, System.SysUtils, System.IOUtils, System.Math, Winapi.Windows, Winapi.Messages,
  Winapi.CommCtrl, Winapi.UxTheme, Winapi.Dwmapi,
  Vcl.Themes, Vcl.Styles, Vcl.AppEvnts,
  System.Win.Registry, Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, Vcl.ComCtrls, CurvedControls, PageTransitions,
  Winapi.GDIPAPI, Winapi.GDIPOBJ, WatermarkOSD, PlayerFlyout, PlayerChrome, ComboMenus, DarkMemo, SettingsStore, CrashTrace;

type
  TPlayerHint = class(THintWindow)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    function MeasureCard(const Text: string; PPI: Integer): TRect;
    procedure ShowCard(const Bounds: TRect; const Text: string; PPI: Integer; OwnerWindow: HWND);
  end;

  TPlayerHintTracker = class(TTimer)
  private
    FPopup: TPlayerHint;
    FLastTarget: HWND;
    FLastControl: TControl;
    FSince: UInt64;
    procedure Track(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TControlAccess = class(TWinControl)
  public
    property Color;
    property Font;
    property ParentBackground;
    property TabOrder;
    property DoubleBuffered;
    procedure PaintChildren(DC: HDC);
  end;

var
  GDarkSurfaceBrush: HBRUSH = 0;
  GDarkElevatedBrush: HBRUSH = 0;

type
  TWheelRouter = class(TComponent)
  private
    HandlingError: Boolean;
  public
    Events: TApplicationEvents;
    constructor Create(AOwner: TComponent); override;
    procedure MessageReceived(var Msg: TMsg; var Handled: Boolean);
    procedure ExceptionRaised(Sender: TObject; E: Exception);
  end;
constructor TWheelRouter.Create(AOwner: TComponent);
begin
  inherited;
  Events := TApplicationEvents.Create(Self);
  Events.OnMessage := MessageReceived;
  Events.OnException := ExceptionRaised;
end;
procedure TWheelRouter.ExceptionRaised(Sender: TObject; E: Exception);
begin
  if HandlingError then Exit;
  HandlingError:=True;
  try
    try
      var Store:=TAppSettings.Create(ExtractFilePath(ParamStr(0))+'VLCModern.ini');
      try Store.WriteString('Diagnostics','LastError',FormatDateTime('yyyy-mm-dd hh:nn:ss',Now)+' '+E.ClassName+': '+E.Message+#13#10+E.StackTrace+#13#10+LatestCrashTrace);
      finally Store.Free; end;
    except
      // Reporting an error must never depend on diagnostics being writable.
    end;
    if GetEnvironmentVariable('VLC_SETTINGS_TEST_ID')<>'' then
    begin
      TFile.AppendAllText('build\tests\reports\smoke-results.txt','FAIL unhandled UI: '+E.ClassName+': '+E.Message+sLineBreak+E.StackTrace+sLineBreak+LatestCrashTrace);
      System.ExitCode:=1; Application.Terminate; Exit;
    end;
    if Application.Terminated or GAppClosing or (Application.MainForm=nil) or
      (csDestroying in Application.ComponentState) or
      (csDestroying in Application.MainForm.ComponentState) then
    begin
      Application.Terminate;
      Exit;
    end;
    PlayerMessage('The action could not be completed.'+#13#10+#13#10+E.Message);
  finally HandlingError:=False; end;
end;
procedure TWheelRouter.MessageReceived(var Msg: TMsg; var Handled: Boolean);
var C: TWinControl; P: TPoint;
begin
  if Handled or (Msg.message<>WM_MOUSEWHEEL) then Exit;
  P := Point(SmallInt(LOWORD(Msg.lParam)),SmallInt(HIWORD(Msg.lParam)));
  C := FindVCLWindow(P);
  if (C=nil) or not C.Enabled then Exit;
  if (C is TTrackBar) or (C is TModernVolumeSlider) then
  begin
    SendMessage(C.Handle,WM_MOUSEWHEEL,Msg.wParam,Msg.lParam);
    Handled := True;
  end;
end;

procedure TControlAccess.PaintChildren(DC: HDC);
begin
  PaintControls(DC, nil);
end;

function GetWindowFont(hWnd: HWND): HFONT;
begin
  Result := HFONT(SendMessage(hWnd, WM_GETFONT, 0, 0));
  if Result = 0 then Result := GetStockObject(DEFAULT_GUI_FONT);
end;

procedure SmoothShape(DC: HDC; const R: TRect; Radius: Single; Fill, Border: TColor; Ellipse: Boolean = False);
var G: TGPGraphics; Path: TGPGraphicsPath; Brush: TGPSolidBrush; Pen: TGPPen; D: Single;
begin
  G := TGPGraphics.Create(DC);
  Path := TGPGraphicsPath.Create;
  Brush := TGPSolidBrush.Create(MakeGDIColor(Fill));
  Pen := TGPPen.Create(MakeGDIColor(Border), 1.0);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    D := Radius * 2;
    if Ellipse then Path.AddEllipse(R.Left + 0.5, R.Top + 0.5, R.Width - 1.0, R.Height - 1.0)
    else
    begin
      Path.AddArc(R.Left + 0.5, R.Top + 0.5, D, D, 180, 90);
      Path.AddArc(R.Right - D - 0.5, R.Top + 0.5, D, D, 270, 90);
      Path.AddArc(R.Right - D - 0.5, R.Bottom - D - 0.5, D, D, 0, 90);
      Path.AddArc(R.Left + 0.5, R.Bottom - D - 0.5, D, D, 90, 90);
      Path.CloseFigure;
    end;
    G.FillPath(Brush, Path);
    G.DrawPath(Pen, Path);
  finally Pen.Free; Brush.Free; Path.Free; G.Free; end;
end;

procedure PaintTab(DC: HDC; R: TRect; const Caption: string; Active: Boolean; Primary: Boolean = False);
var Mark: TRect;
begin
  FillRect(DC, R, GDarkSurfaceBrush);
  InflateRect(R, -3, -3);
  if Primary then
    SmoothShape(DC, R, 7, DP_COLOR_ELEVATED, DP_COLOR_ELEVATED)
  else
  begin
    SmoothShape(DC, R, 4, DP_COLOR_BG, DP_COLOR_BG);
    if Active then SmoothShape(DC, R, 4, DP_COLOR_HOVER, DP_COLOR_BORDER);
  end;
  if Primary and Active then
  begin
    Mark := R;
    Mark.Top := Mark.Bottom - 3;
    InflateRect(Mark, -12, 0);
    SmoothShape(DC, Mark, 1, DP_COLOR_ACCENT, DP_COLOR_ACCENT);
  end;
  SetBkMode(DC, TRANSPARENT);
  if Active and Primary then SetTextColor(DC, ColorToRGB(DP_COLOR_ACCENT))
  else if Active then SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT))
  else SetTextColor(DC, ColorToRGB(DP_COLOR_MUTED));
  DrawText(DC, PChar(Caption), -1, R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

type
  TDarkPainter = function(hWnd: HWND; Msg: UINT; W: WPARAM; L: LPARAM;
    ID: UINT_PTR; Data: DWORD_PTR): LRESULT; stdcall;

function BufferedPaint(Wnd: HWND; Painter: TDarkPainter; ID: UINT_PTR; Data: DWORD_PTR): LRESULT;
var PS: TPaintStruct; DC, BufferDC: HDC; R: TRect;
    Bitmap, Previous: HGDIOBJ;
begin
  DC := BeginPaint(Wnd, PS);
  try
    GetClientRect(Wnd, R);
    if (R.Width > 0) and (R.Height > 0) then
    begin
      BufferDC := CreateCompatibleDC(DC);
      Bitmap := CreateCompatibleBitmap(DC, R.Width, R.Height);
      Previous := SelectObject(BufferDC, Bitmap);
      try
        Painter(Wnd, WM_PRINTCLIENT, WPARAM(BufferDC), PRF_CLIENT, ID, Data);
        GdiFlush;
        BitBlt(DC, 0, 0, R.Width, R.Height, BufferDC, 0, 0, SRCCOPY);
      finally
        SelectObject(BufferDC, Previous);
        DeleteObject(Bitmap);
        DeleteDC(BufferDC);
      end;
    end;
  finally EndPaint(Wnd, PS); end;
  Result := 0;
end;

procedure BeginHover(Wnd: HWND);
var Tracking: TTrackMouseEvent;
begin
  if GetProp(Wnd, 'PlayerTheme.Hover') <> 0 then Exit;
  SetProp(Wnd, 'PlayerTheme.Hover', 1);
  Tracking := Default(TTrackMouseEvent);
  Tracking.cbSize := SizeOf(Tracking);
  Tracking.dwFlags := TME_LEAVE;
  Tracking.hwndTrack := Wnd;
  TrackMouseEvent(Tracking);
  InvalidateRect(Wnd, nil, False);
end;

function DarkButtonSubclass(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  PS: TPaintStruct;
  DC: HDC;
  R, TextR: TRect;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  FillColor: TColor;
  Caption: array[0..255] of Char;
  IsHovered, IsPressed, IsEnabled: Boolean;
  Primary: Boolean;
  Pt: TPoint;
  D: Single;
begin
  if uMsg = WM_PAINT then Exit(BufferedPaint(hWnd, @DarkButtonSubclass, uIdSubclass, dwRefData));
  case uMsg of
    WM_PAINT, WM_PRINTCLIENT:
      begin
        if uMsg = WM_PRINTCLIENT then DC := HDC(wParam)
        else DC := BeginPaint(hWnd, PS);
        try
          GetClientRect(hWnd, R);
          // Paint the corners too; suppressing erase without this leaves stale pixels.
          FillRect(DC, R, GDarkSurfaceBrush);
          GetCursorPos(Pt);
          Winapi.Windows.ScreenToClient(hWnd, Pt);
          IsHovered := PtInRect(R, Pt);
          IsPressed := (GetKeyState(VK_LBUTTON) < 0) and IsHovered;
          IsEnabled := IsWindowEnabled(hWnd);
          Primary := (FindControl(hWnd) is TButton) and
            TButton(FindControl(hWnd)).Default and IsEnabled;

          if not IsEnabled then
            FillColor := DP_COLOR_SURFACE
          else if IsPressed then
            FillColor := DP_COLOR_BORDER
          else if IsHovered then
            FillColor := DP_COLOR_HOVER
          else
            FillColor := DP_COLOR_ELEVATED;
          if Primary then
          begin
            if IsPressed then FillColor := DP_COLOR_ACCPRESS
            else if IsHovered then FillColor := DP_COLOR_ACCHOVER
            else FillColor := DP_COLOR_ACCENT;
          end;

          G := TGPGraphics.Create(DC);
          try
            G.SetSmoothingMode(SmoothingModeAntiAlias);
            Path := TGPGraphicsPath.Create;
            try
              D := MulDiv(12, GetDpiForWindow(hWnd), 96);
              Path.AddArc(1, 1, D, D, 180, 90);
              Path.AddArc(R.Right - D - 1, 1, D, D, 270, 90);
              Path.AddArc(R.Right - D - 1, R.Bottom - D - 1, D, D, 0, 90);
              Path.AddArc(1, R.Bottom - D - 1, D, D, 90, 90);
              Path.CloseFigure;

              Brush := TGPSolidBrush.Create(MakeGDIColor(FillColor));
              try
                G.FillPath(Brush, Path);
              finally
                Brush.Free;
              end;

              Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 1.0);
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

          GetWindowText(hWnd, Caption, 256);
          SetBkMode(DC, TRANSPARENT);
          if Primary and not IsPressed then
            SetTextColor(DC, ColorToRGB(DP_COLOR_BG))
          else if IsEnabled then
            SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT))
          else
            SetTextColor(DC, ColorToRGB(DP_COLOR_SCROLL));

          SelectObject(DC, GetWindowFont(hWnd));
          TextR := R;
          DrawText(DC, Caption, -1, TextR, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
        finally
          if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS);
        end;
        Exit(0);
      end;
    WM_MOUSEMOVE:
      begin
        BeginHover(hWnd);
        Exit(0);
      end;
    WM_MOUSELEAVE:
      begin RemoveProp(hWnd, 'PlayerTheme.Hover'); InvalidateRect(hWnd, nil, False); Exit(0); end;
    WM_ERASEBKGND:
      Exit(1);
    WM_NCDESTROY:
      RemoveWindowSubclass(hWnd, @DarkButtonSubclass, uIdSubclass);
  end;
  case uMsg of
    WM_LBUTTONDOWN, WM_LBUTTONUP, WM_KEYDOWN, WM_KEYUP,
    WM_SETFOCUS, WM_KILLFOCUS, WM_ENABLE, WM_UPDATEUISTATE, BM_SETSTYLE, BM_SETSTATE, BM_CLICK:
      begin
        // Button state changes can paint through the native BUTTON procedure.
        // Keep the state handling, then repaint with the project palette.
        if not IsWindowVisible(hWnd) or (GetProp(hWnd, 'PlayerTheme.ButtonState') <> 0) then
          Exit(DefSubclassProc(hWnd, uMsg, wParam, lParam));
        SetProp(hWnd, 'PlayerTheme.ButtonState', 1);
        DefSubclassProc(hWnd, WM_SETREDRAW, 0, 0);
        try
          Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
        finally
          RemoveProp(hWnd, 'PlayerTheme.ButtonState');
          DefSubclassProc(hWnd, WM_SETREDRAW, 1, 0);
        end;
        InvalidateRect(hWnd, nil, False);
      end;
  else
    Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
  end;
end;

function DarkCheckSubclass(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  PS: TPaintStruct;
  DC: HDC;
  R, BoxR: TRect;
  Canvas: TCanvas;
  Caption: array[0..511] of Char;
  Side: Integer;
  IsRadio, Selected, Tile: Boolean;
  Offset: Integer;
  CheckGraphics: TGPGraphics;
  CheckPen: TGPPen;
begin
  if uMsg = WM_PAINT then Exit(BufferedPaint(hWnd, @DarkCheckSubclass, uIdSubclass, dwRefData));
  if (uMsg = WM_MOUSEMOVE) and (wParam and MK_LBUTTON = 0) then Exit(0);
  if uMsg = WM_ERASEBKGND then Exit(1);
  if (uMsg = WM_PAINT) or (uMsg = WM_PRINTCLIENT) then
  begin
    if uMsg = WM_PRINTCLIENT then DC := HDC(wParam) else DC := BeginPaint(hWnd, PS);
    Canvas := TCanvas.Create;
    try
      Canvas.Handle := DC;
      GetClientRect(hWnd, R);
      FillRect(DC, R, GDarkSurfaceBrush);
      Side := MulDiv(14, GetDpiForWindow(hWnd), 96);
      IsRadio := FindControl(hWnd) is TRadioButton;
      Selected := SendMessage(hWnd, BM_GETCHECK, 0, 0) <> BST_UNCHECKED;
      Tile := IsRadio and (R.Bottom >= MulDiv(32, GetDpiForWindow(hWnd), 96));
      Offset := 1;
      if Tile then
      begin
        Offset := MulDiv(12, GetDpiForWindow(hWnd), 96);
        Canvas.Brush.Color := DP_COLOR_ELEVATED;
        Canvas.Pen.Color := DP_COLOR_BORDER;
        if Selected then Canvas.Pen.Color := DP_COLOR_ACCENT;
        SmoothShape(DC, R, MulDiv(7, GetDpiForWindow(hWnd), 96), Canvas.Brush.Color, Canvas.Pen.Color);
      end;
      BoxR := Rect(Offset, (R.Bottom - Side) div 2, Offset + Side, (R.Bottom + Side) div 2);
      Canvas.Brush.Color := DP_COLOR_ELEVATED;
      Canvas.Pen.Color := DP_COLOR_SCROLL;
      if GetFocus = hWnd then Canvas.Pen.Color := DP_COLOR_ACCENT;
      if IsRadio then
        SmoothShape(DC, BoxR, 0, Canvas.Brush.Color, Canvas.Pen.Color, True)
      else SmoothShape(DC, BoxR, 3, Canvas.Brush.Color, Canvas.Pen.Color);
      if Selected then
      begin
        Canvas.Brush.Color := DP_COLOR_ACCENT;
        Canvas.Pen.Color := DP_COLOR_ACCENT;
        if IsRadio then
        begin
          InflateRect(BoxR, -4, -4);
          SmoothShape(DC, BoxR, 0, DP_COLOR_ACCENT, DP_COLOR_ACCENT, True);
        end
        else
        begin
          SmoothShape(DC, BoxR, 3, DP_COLOR_ACCENT, DP_COLOR_ACCENT);
          CheckGraphics := TGPGraphics.Create(DC);
          CheckPen := TGPPen.Create(MakeGDIColor(DP_COLOR_BG), Side / 8);
          try
            CheckGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
            CheckPen.SetStartCap(LineCapRound);
            CheckPen.SetEndCap(LineCapRound);
            CheckGraphics.DrawLine(CheckPen, BoxR.Left + Side * 0.22, BoxR.Top + Side * 0.5,
              BoxR.Left + Side * 0.43, BoxR.Top + Side * 0.72);
            CheckGraphics.DrawLine(CheckPen, BoxR.Left + Side * 0.43, BoxR.Top + Side * 0.72,
              BoxR.Left + Side * 0.79, BoxR.Top + Side * 0.25);
          finally CheckPen.Free; CheckGraphics.Free; end;
        end;
      end;
      GetWindowText(hWnd, Caption, Length(Caption));
      SelectObject(DC, GetWindowFont(hWnd));
      SetBkMode(DC, TRANSPARENT);
      if IsWindowEnabled(hWnd) then SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT))
      else SetTextColor(DC, ColorToRGB(DP_COLOR_SCROLL));
      R.Left := Offset + Side + 8;
      DrawText(DC, Caption, -1, R, DT_VCENTER or DT_SINGLELINE);
      Canvas.Handle := 0;
    finally
      Canvas.Free;
      if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS);
    end;
    Exit(0);
  end;
  if (uMsg = WM_LBUTTONDOWN) or (uMsg = WM_LBUTTONUP) or (uMsg = WM_KEYDOWN) or (uMsg = WM_KEYUP) then
  begin
    DefSubclassProc(hWnd, WM_SETREDRAW, 0, 0);
    try Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
    finally DefSubclassProc(hWnd, WM_SETREDRAW, 1, 0); end;
  end
  else Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
  if (uMsg = BM_SETCHECK) or (uMsg = WM_LBUTTONUP) or (uMsg = WM_KEYUP) or
     (uMsg = WM_SETFOCUS) or (uMsg = WM_KILLFOCUS) or (uMsg = WM_ENABLE) then
    InvalidateRect(hWnd, nil, False);
  if uMsg = WM_NCDESTROY then RemoveWindowSubclass(hWnd, @DarkCheckSubclass, uIdSubclass);
end;

function DarkProgressSubclass(hWnd: HWND; Msg: UINT; W: WPARAM; L: LPARAM;
  ID: UINT_PTR; Data: DWORD_PTR): LRESULT; stdcall;
var R: TRect; C: TWinControl; Ratio: Single;
begin
  if Msg=WM_PAINT then Exit(BufferedPaint(hWnd,@DarkProgressSubclass,ID,Data));
  if Msg=WM_PRINTCLIENT then
  begin
    GetClientRect(hWnd,R);
    FillRect(HDC(W),R,GDarkSurfaceBrush);
    InflateRect(R,-1,-1);
    SmoothShape(HDC(W),R,4,DP_COLOR_BORDER,DP_COLOR_BORDER);
    C:=FindControl(hWnd);
    if (C is TProgressBar) and (TProgressBar(C).Max>TProgressBar(C).Min) then
    begin
      Ratio:=(TProgressBar(C).Position-TProgressBar(C).Min)/(TProgressBar(C).Max-TProgressBar(C).Min);
      if Ratio>0 then
      begin
        R.Right:=R.Left+Max(6,Round(R.Width*Ratio));
        SmoothShape(HDC(W),R,4,DP_COLOR_ACCENT,DP_COLOR_ACCENT);
      end;
    end;
    Exit(0);
  end;
  if Msg=WM_ERASEBKGND then Exit(1);
  if Msg=PBM_SETPOS then
  begin
    DefSubclassProc(hWnd,WM_SETREDRAW,0,0);
    try Result:=DefSubclassProc(hWnd,Msg,W,L);
    finally DefSubclassProc(hWnd,WM_SETREDRAW,1,0); end;
    InvalidateRect(hWnd,nil,False);
    Exit;
  end;
  if Msg=WM_NCDESTROY then RemoveWindowSubclass(hWnd,@DarkProgressSubclass,ID);
  Result:=DefSubclassProc(hWnd,Msg,W,L);
end;

function DarkTrackBarSubclass(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
const HoverProperty = 'VLCModernSliderHover';
var PS: TPaintStruct; DC: HDC; R: TRect; TME: TTRACKMOUSEEVENT;
    MinVal, MaxVal, PosVal, NewPos, Coordinate, Padding, Span, DPI: Integer;
    Ratio, Zero: Single; Vertical: Boolean; Ctrl: TWinControl;
begin
  if uMsg = WM_PAINT then Exit(BufferedPaint(hWnd, @DarkTrackBarSubclass, uIdSubclass, dwRefData));
  DPI := GetDpiForWindow(hWnd);
  Padding := MulDiv(10, DPI, 96);
  Vertical := (GetWindowLong(hWnd, GWL_STYLE) and TBS_VERT) <> 0;
  case uMsg of
    WM_MOUSEWHEEL:
      begin
        if not IsWindowEnabled(hWnd) then Exit(0);
        var Delta := NativeInt(GetProp(hWnd, 'PlayerSlider.Wheel')) + SmallInt(HIWORD(wParam));
        var Steps := Delta div WHEEL_DELTA;
        SetProp(hWnd, 'PlayerSlider.Wheel', THandle(NativeInt(Delta mod WHEEL_DELTA)));
        if Steps <> 0 then
        begin
          var Control := FindControl(hWnd);
          if Control is TTrackBar then
            TTrackBar(Control).Position := TTrackBar(Control).Position + Steps * TTrackBar(Control).LineSize;
        end;
        Exit(0);
      end;
    WM_MOUSEMOVE, WM_LBUTTONDOWN:
      begin
        if not IsWindowEnabled(hWnd) then Exit(0);
        if GetProp(hWnd, HoverProperty) = 0 then
        begin
          SetProp(hWnd, HoverProperty, 1);
          TME := Default(TTRACKMOUSEEVENT);
          TME.cbSize := SizeOf(TME);
          TME.dwFlags := TME_LEAVE;
          TME.hwndTrack := hWnd;
          TrackMouseEvent(TME);
          InvalidateRect(hWnd, nil, False);
        end;
        if uMsg = WM_LBUTTONDOWN then begin SetFocus(hWnd); SetCapture(hWnd); end;
        if GetCapture = hWnd then
        begin
          GetClientRect(hWnd, R);
          Coordinate := SmallInt(LOWORD(lParam));
          Span := R.Width - Padding * 2;
          if Vertical then
          begin Coordinate := SmallInt(HIWORD(lParam)); Span := R.Height - Padding * 2; end;
          if Span > 0 then
          begin
            Ratio := (Coordinate - Padding) / Span;
            if Vertical then Ratio := 1 - Ratio;
            if Ratio < 0 then Ratio := 0;
            if Ratio > 1 then Ratio := 1;
            MinVal := SendMessage(hWnd, TBM_GETRANGEMIN, 0, 0);
            MaxVal := SendMessage(hWnd, TBM_GETRANGEMAX, 0, 0);
            PosVal := SendMessage(hWnd, TBM_GETPOS, 0, 0);
            NewPos := Round(MinVal + Ratio * (MaxVal - MinVal));
            if PosVal <> NewPos then
            begin
              Ctrl := FindControl(hWnd);
              if Ctrl is TTrackBar then TTrackBar(Ctrl).Position := NewPos
              else SendMessage(hWnd, TBM_SETPOS, 0, NewPos);
              if Vertical then
                SendMessage(GetParent(hWnd), WM_VSCROLL, MakeWParam(SB_THUMBTRACK, NewPos), hWnd)
              else SendMessage(GetParent(hWnd), WM_HSCROLL, MakeWParam(SB_THUMBTRACK, NewPos), hWnd);
              InvalidateRect(hWnd, nil, False);
            end;
          end;
        end;
        // Native hover/drag drawing must never run over our vector surface.
        Exit(0);
      end;
    WM_LBUTTONUP:
      begin
        if GetCapture = hWnd then
        begin
          ReleaseCapture;
          if Vertical then SendMessage(GetParent(hWnd), WM_VSCROLL, SB_ENDSCROLL, hWnd)
          else SendMessage(GetParent(hWnd), WM_HSCROLL, SB_ENDSCROLL, hWnd);
        end;
        InvalidateRect(hWnd, nil, False);
        Exit(0);
      end;
    WM_MOUSELEAVE:
      begin RemoveProp(hWnd, HoverProperty); InvalidateRect(hWnd, nil, False); Exit(0); end;
    WM_KEYDOWN:
      begin
        if not IsWindowEnabled(hWnd) then Exit(0);
        MinVal := SendMessage(hWnd, TBM_GETRANGEMIN, 0, 0);
        MaxVal := SendMessage(hWnd, TBM_GETRANGEMAX, 0, 0);
        PosVal := SendMessage(hWnd, TBM_GETPOS, 0, 0);
        NewPos := PosVal;
        case wParam of
          VK_UP, VK_RIGHT: Inc(NewPos, SendMessage(hWnd, TBM_GETLINESIZE, 0, 0));
          VK_DOWN, VK_LEFT: Dec(NewPos, SendMessage(hWnd, TBM_GETLINESIZE, 0, 0));
          VK_PRIOR: Inc(NewPos, SendMessage(hWnd, TBM_GETPAGESIZE, 0, 0));
          VK_NEXT: Dec(NewPos, SendMessage(hWnd, TBM_GETPAGESIZE, 0, 0));
          VK_HOME: if Vertical then NewPos := MaxVal else NewPos := MinVal;
          VK_END: if Vertical then NewPos := MinVal else NewPos := MaxVal;
        else Exit(DefSubclassProc(hWnd, uMsg, wParam, lParam)); end;
        if NewPos < MinVal then NewPos := MinVal;
        if NewPos > MaxVal then NewPos := MaxVal;
        Ctrl := FindControl(hWnd);
        if Ctrl is TTrackBar then TTrackBar(Ctrl).Position := NewPos;
        if Vertical then SendMessage(GetParent(hWnd), WM_VSCROLL, MakeWParam(SB_THUMBTRACK, NewPos), hWnd)
        else SendMessage(GetParent(hWnd), WM_HSCROLL, MakeWParam(SB_THUMBTRACK, NewPos), hWnd);
        Exit(0);
      end;
    TBM_SETPOS:
      begin
        Result := DefSubclassProc(hWnd, uMsg, 0, lParam);
        InvalidateRect(hWnd, nil, False);
        Exit;
      end;
    WM_PAINT, WM_PRINTCLIENT:
      begin
        if uMsg = WM_PRINTCLIENT then DC := HDC(wParam) else DC := BeginPaint(hWnd, PS);
        try
          GetClientRect(hWnd, R);
          FillRect(DC, R, GDarkSurfaceBrush);
          MinVal := SendMessage(hWnd, TBM_GETRANGEMIN, 0, 0);
          MaxVal := SendMessage(hWnd, TBM_GETRANGEMAX, 0, 0);
          PosVal := SendMessage(hWnd, TBM_GETPOS, 0, 0);
          Ratio := 0;
          Zero := -1;
          if MaxVal > MinVal then
          begin
            Ratio := (PosVal - MinVal) / (MaxVal - MinVal);
            if (MinVal < 0) and (MaxVal > 0) then Zero := -MinVal / (MaxVal - MinVal);
          end;
          PaintMediaSlider(DC, R, Ratio, 0, Zero, Vertical,
            (GetProp(hWnd, HoverProperty) <> 0) or (GetCapture = hWnd), IsWindowEnabled(hWnd), DPI);
        finally if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS); end;
        Exit(0);
      end;
    WM_ERASEBKGND: Exit(1);
    WM_NCDESTROY:
      begin RemoveProp(hWnd, HoverProperty); RemoveWindowSubclass(hWnd, @DarkTrackBarSubclass, uIdSubclass); end;
  end;
  Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
end;

function StableDialogSurface(Control:TControl):Boolean;
var Host:TCustomForm;
begin
  Host:=GetParentForm(Control,True);
  Result:=(Host<>nil) and (Host<>Application.MainForm);
end;

function DarkTabSheetSubclass(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  DC: HDC;
  R: TRect;
  PS: TPaintStruct;
  Page: TPageControl;
  I: Integer;
  TabR: TRect;
  C: TWinControl;
  GroupCanvas: TCanvas;
begin
  if ((uMsg = WM_MOUSEMOVE) or (uMsg = WM_MOUSELEAVE)) and
    (FindControl(hWnd) is TPageControl) then Exit(0);
  C:=FindControl(hWnd);
  if (C<>nil) and StableDialogSurface(C) then
  begin
    if uMsg=WM_ERASEBKGND then Exit(1);
    if uMsg=WM_PAINT then Exit(BufferedPaint(hWnd,@DarkTabSheetSubclass,uIdSubclass,dwRefData));
  end;
  case uMsg of
    WM_PAINT, WM_PRINTCLIENT:
      begin
        C := FindControl(hWnd);
        if (C is TTabSheet) or ((C is TPanel) and StableDialogSurface(C)) then
        begin
          if uMsg = WM_PRINTCLIENT then DC := HDC(wParam)
          else DC := BeginPaint(hWnd, PS);
          try
            GetClientRect(hWnd, R);
            FillRect(DC, R, GDarkSurfaceBrush);
            TControlAccess(C).PaintChildren(DC);
          finally
            if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS);
          end;
          Exit(0);
        end;
        if C is TCustomGroupBox then
        begin
          if uMsg = WM_PRINTCLIENT then DC := HDC(wParam)
        else DC := BeginPaint(hWnd, PS);
          GroupCanvas := TCanvas.Create;
          try
            GroupCanvas.Handle := DC;
            GetClientRect(hWnd, R);
            FillRect(DC, R, GDarkSurfaceBrush);
            GroupCanvas.Font.Assign(TGroupBox(C).Font);
            GroupCanvas.Font.Color := DP_COLOR_TEXT;
            GroupCanvas.Brush.Color := DP_COLOR_SURFACE;
            GroupCanvas.Pen.Color := DP_COLOR_BORDER;
            R.Top := GroupCanvas.TextHeight('Ag') div 2;
            InflateRect(R, -1, -1);
            if TGroupBox(C).Caption <> '' then
            begin
              SmoothShape(DC, R, MulDiv(8, GetDpiForWindow(hWnd), 96), DP_COLOR_SURFACE, DP_COLOR_BORDER);
              GroupCanvas.TextOut(12, 0, ' ' + TGroupBox(C).Caption + ' ');
            end;
            GroupCanvas.Handle := 0;
            TControlAccess(C).PaintChildren(DC);
          finally
            GroupCanvas.Free;
            if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS);
          end;
          Exit(0);
        end;
        if C is TPageControl then
        begin
          Page := TPageControl(C);
          if uMsg = WM_PRINTCLIENT then DC := HDC(wParam)
        else DC := BeginPaint(hWnd, PS);
          try
            GetClientRect(hWnd, R);
            FillRect(DC, R, GDarkSurfaceBrush);
            SelectObject(DC, GetWindowFont(hWnd));
            SetBkMode(DC, TRANSPARENT);
            for I := 0 to Page.PageCount - 1 do
            begin
              if not Page.Pages[I].TabVisible then Continue;
              TabR := Page.TabRect(I);
              PaintTab(DC, TabR, Page.Pages[I].Caption, Page.ActivePage = Page.Pages[I], Page.Parent is TCustomForm);
            end;
          finally if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS); end;
          Exit(0);
        end;
      end;
    WM_ERASEBKGND:
      begin
        DC := HDC(wParam);
        GetClientRect(hWnd, R);
        FillRect(DC, R, GDarkSurfaceBrush);
        Exit(1);
      end;
    WM_CTLCOLORSTATIC, WM_CTLCOLORDLG, WM_CTLCOLORBTN:
      begin
        DC := HDC(wParam);
        SetBkMode(DC, TRANSPARENT);
        SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
        Exit(LRESULT(GDarkSurfaceBrush));
      end;
    WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
      begin
        DC := HDC(wParam);
        SetBkColor(DC, ColorToRGB(DP_COLOR_ELEVATED));
        SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
        Exit(LRESULT(GDarkElevatedBrush));
      end;
    WM_NCDESTROY:
      RemoveWindowSubclass(hWnd, @DarkTabSheetSubclass, uIdSubclass);
  end;
  Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
  // Native tabs invalidate only their old/new rectangles. Our rounded backing
  // extends beyond those rectangles, so repaint the header after selection.
  if ((uMsg = WM_LBUTTONUP) or (uMsg = WM_KEYUP) or
    (uMsg = TCM_SETCURSEL)) and (FindControl(hWnd) is TPageControl) then
    RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE);
end;

function DarkComboBoxSubclass(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  PS: TPaintStruct;
  DC: HDC;
  R, TextR: TRect;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Pt: TPoint;
  IsHovered, IsDropped: Boolean;
  TextBuf: string;
  TextLength: Integer;
  CurSel: Integer;
  ArrowX, ArrowY: Single;
  BgColor: TColor;
begin
  if (uMsg=CB_SHOWDROPDOWN) and (wParam<>0) then Exit(0);
  if (uMsg=WM_LBUTTONDOWN) or (uMsg=WM_LBUTTONDBLCLK) or (((uMsg=WM_KEYDOWN) or (uMsg=WM_SYSKEYDOWN)) and
    ((wParam=VK_F4) or ((wParam=VK_DOWN) and (GetKeyState(VK_MENU)<0)))) then
  begin
    var C:=FindControl(hWnd);
    if C is TComboBox then
    begin
      SetFocus(hWnd);
      if ShowComboMenu(TComboBox(C)) then Exit(0);
    end;
  end;
  if uMsg = WM_PAINT then Exit(BufferedPaint(hWnd, @DarkComboBoxSubclass, uIdSubclass, dwRefData));
  case uMsg of
    WM_PAINT, WM_PRINTCLIENT:
      begin
        if uMsg = WM_PRINTCLIENT then DC := HDC(wParam)
        else DC := BeginPaint(hWnd, PS);
        try
          GetClientRect(hWnd, R);
          GetCursorPos(Pt);
          Winapi.Windows.ScreenToClient(hWnd, Pt);
          IsHovered := PtInRect(R, Pt);
          FillRect(DC, R, GDarkSurfaceBrush);
          IsDropped := SendMessage(hWnd, CB_GETDROPPEDSTATE, 0, 0) <> 0;
          if FindControl(hWnd) is TComboBox then
            IsDropped := IsDropped or ComboMenuOpen(TComboBox(FindControl(hWnd)));

          if IsDropped or IsHovered then
            BgColor := DP_COLOR_HOVER
          else
            BgColor := DP_COLOR_ELEVATED;

          G := TGPGraphics.Create(DC);
          try
            G.SetSmoothingMode(SmoothingModeAntiAlias);

            Path := TGPGraphicsPath.Create;
            try
              Path.AddArc(1, 1, 8, 8, 180, 90);
              Path.AddArc(R.Right - 9, 1, 8, 8, 270, 90);
              Path.AddArc(R.Right - 9, R.Bottom - 9, 8, 8, 0, 90);
              Path.AddArc(1, R.Bottom - 9, 8, 8, 90, 90);
              Path.CloseFigure;

              Brush := TGPSolidBrush.Create(MakeGDIColor(BgColor));
              try
                G.FillPath(Brush, Path);
              finally
                Brush.Free;
              end;

              if IsDropped then
                Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_ACCENT), 1.2)
              else
                Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 1.0);
              try
                G.DrawPath(Pen, Path);
              finally
                Pen.Free;
              end;
            finally
              Path.Free;
            end;

            // Draw crisp chevron arrow
            ArrowX := R.Right - 15;
            ArrowY := (R.Top + R.Bottom) * 0.5 - 2;
            Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_TEXT), 1.5);
            try
              Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
              var Turn:Single:=0;
              if FindControl(hWnd) is TComboBox then Turn:=ComboArrowProgress(TComboBox(FindControl(hWnd)));
              G.TranslateTransform(ArrowX,ArrowY+2);
              G.RotateTransform(-180*Turn);
              G.DrawLine(Pen,Single(-4),Single(-2),Single(0),Single(2));
              G.DrawLine(Pen,Single(0),Single(2),Single(4),Single(-2));
              G.ResetTransform;
            finally
              Pen.Free;
            end;
          finally
            G.Free;
          end;

          CurSel := SendMessage(hWnd, CB_GETCURSEL, 0, 0);
          if CurSel>=0 then
          begin
            TextLength:=SendMessage(hWnd,CB_GETLBTEXTLEN,CurSel,0);
            if TextLength<0 then TextLength:=0;
            SetLength(TextBuf,TextLength+1);
            SendMessage(hWnd,CB_GETLBTEXT,CurSel,NativeInt(PChar(TextBuf)));
          end
          else
          begin
            TextLength:=GetWindowTextLength(hWnd);
            SetLength(TextBuf,TextLength+1);
            GetWindowText(hWnd,PChar(TextBuf),TextLength+1);
          end;
          SetLength(TextBuf,TextLength);

          SetBkMode(DC, TRANSPARENT);
          SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
          SelectObject(DC, GetWindowFont(hWnd));
          TextR := Rect(R.Left + 10, R.Top, R.Right - 26, R.Bottom);
          DrawText(DC, PChar(TextBuf), Length(TextBuf), TextR, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
        finally
          if uMsg <> WM_PRINTCLIENT then EndPaint(hWnd, PS);
        end;
        Exit(0);
      end;
    WM_MOUSEMOVE:
      begin
        BeginHover(hWnd);
        Exit(0);
      end;
    WM_MOUSELEAVE:
      begin RemoveProp(hWnd, 'PlayerTheme.Hover'); InvalidateRect(hWnd, nil, False); Exit(0); end;
    WM_ERASEBKGND:
      Exit(1);
    WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
      begin
        DC := HDC(wParam);
        SetBkColor(DC, ColorToRGB(DP_COLOR_ELEVATED));
        SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
        Exit(LRESULT(GDarkElevatedBrush));
      end;
    WM_NCDESTROY:
      RemoveWindowSubclass(hWnd, @DarkComboBoxSubclass, uIdSubclass);
  end;
  if (uMsg=WM_SETFOCUS) or (uMsg=WM_KILLFOCUS) then
  begin
    DefSubclassProc(hWnd,WM_SETREDRAW,0,0);
    try Result:=DefSubclassProc(hWnd,uMsg,wParam,lParam);
    finally DefSubclassProc(hWnd,WM_SETREDRAW,1,0); end;
    InvalidateRect(hWnd,nil,False);
    Exit;
  end;
  Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
end;

function DarkFormSubclass(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  DC: HDC;
begin
  case uMsg of
    WM_CTLCOLORSTATIC, WM_CTLCOLORDLG, WM_CTLCOLORBTN:
      begin
        DC := HDC(wParam);
        SetBkMode(DC, TRANSPARENT);
        SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
        Exit(LRESULT(GDarkSurfaceBrush));
      end;
    WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
      begin
        DC := HDC(wParam);
        SetBkColor(DC, ColorToRGB(DP_COLOR_ELEVATED));
        SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
        Exit(LRESULT(GDarkElevatedBrush));
      end;
    WM_NCDESTROY:
      RemoveWindowSubclass(hWnd, @DarkFormSubclass, uIdSubclass);
  end;
  Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
end;

type
  TTabDrawer = class
    class procedure GlobalDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
  end;

  TComboDrawer = class
    class procedure GlobalDrawComboItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
  end;

class procedure TComboDrawer.GlobalDrawComboItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Cbo: TCustomComboBox;
  Canvas: TCanvas;
  Text: string;
  TextR: TRect;
begin
  if not (Control is TCustomComboBox) then Exit;
  Cbo := TCustomComboBox(Control);
  Canvas := TComboBox(Cbo).Canvas;

  if (odSelected in State) or (odFocused in State) then
  begin
    Canvas.Brush.Color := DP_COLOR_HOVER;
    Canvas.Font.Color := DP_COLOR_ACCENT;
  end
  else
  begin
    Canvas.Brush.Color := DP_COLOR_ELEVATED;
    Canvas.Font.Color := DP_COLOR_TEXT;
  end;

  Canvas.FillRect(Rect);

  if (Index >= 0) and (Index < Cbo.Items.Count) then
    Text := Cbo.Items[Index]
  else if Control is TComboBox then
    Text := TComboBox(Control).Text
  else
    Text := '';

  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 9;
  TextR := Rect;
  Inc(TextR.Left, 8);
  Canvas.Brush.Style := bsClear;
  DrawText(Canvas.Handle, PChar(Text), Length(Text), TextR, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
end;

class procedure TTabDrawer.GlobalDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
var Caption: string;
begin
  Caption := '';
  if Control is TPageControl then Caption := TPageControl(Control).Pages[TabIndex].Caption;
  Control.Canvas.Font.Assign(TControlAccess(Control).Font);
  PaintTab(Control.Canvas.Handle, Rect, Caption, Active, Control.Parent is TCustomForm);
end;

type
  TPlayerPaintBinding = class(TComponent)
  private
    FControl: TWinControl;
    FOriginalProc: TWndMethod;
    procedure WindowProc(var Msg: TMessage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

constructor TPlayerPaintBinding.Create(AOwner: TComponent);
begin
  inherited;
  Name := 'PlayerPaintBinding';
  FControl := TWinControl(AOwner);
  FOriginalProc := FControl.WindowProc;
  FControl.WindowProc := WindowProc;
end;

destructor TPlayerPaintBinding.Destroy;
begin
  FControl.WindowProc := FOriginalProc;
  inherited;
end;

procedure TPlayerPaintBinding.WindowProc(var Msg: TMessage);
var PaintMsg: TMessage;
begin
  if (csDestroying in FControl.ComponentState) and ((Msg.Msg=WM_PAINT) or (Msg.Msg=WM_PRINTCLIENT) or (Msg.Msg=WM_ERASEBKGND)) then
  begin
    if FControl.HandleAllocated then ValidateRect(FControl.Handle,nil);
    Msg.Result:=0; Exit;
  end;
  if (Msg.Msg=CN_DRAWITEM) and (FControl is TCustomComboBox) and (Msg.LParam<>0) then
    PDrawItemStruct(Msg.LParam)^.itemState:=PDrawItemStruct(Msg.LParam)^.itemState and not ODS_FOCUS;
  // VCL PaintTo sends WM_PAINT with the destination HDC in WParam. BeginPaint
  // ignores that HDC and leaves snapshots white, including transition frames.
  if (Msg.Msg = WM_PAINT) and (Msg.WParam <> 0) then
  begin
    PaintMsg := Msg;
    PaintMsg.Msg := WM_PRINTCLIENT;
    WindowProc(PaintMsg);
    Msg.Result := PaintMsg.Result;
    Exit;
  end;
  if Msg.Msg = WM_ERASEBKGND then
  begin
    Msg.Result := 1;
    Exit;
  end;
  if (Msg.Msg = WM_PAINT) or (Msg.Msg = WM_PRINTCLIENT) then
  begin
    if FControl is TButton then
      Msg.Result := DarkButtonSubclass(FControl.Handle, Msg.Msg, Msg.WParam, Msg.LParam, 0, 0)
    else if (FControl is TCustomCheckBox) or (FControl is TRadioButton) then
      Msg.Result := DarkCheckSubclass(FControl.Handle, Msg.Msg, Msg.WParam, Msg.LParam, 0, 0)
    else if FControl is TProgressBar then
      Msg.Result := DarkProgressSubclass(FControl.Handle, Msg.Msg, Msg.WParam, Msg.LParam, 0, 0)
    else if FControl is TTrackBar then
      Msg.Result := DarkTrackBarSubclass(FControl.Handle, Msg.Msg, Msg.WParam, Msg.LParam, 0, 0)
    else if FControl is TCustomComboBox then
      Msg.Result := DarkComboBoxSubclass(FControl.Handle, Msg.Msg, Msg.WParam, Msg.LParam, 0, 0)
    else if (FControl is TCustomGroupBox) or (FControl is TPageControl) or (FControl is TTabSheet) then
      Msg.Result := DarkTabSheetSubclass(FControl.Handle, Msg.Msg, Msg.WParam, Msg.LParam, 0, 0)
    else
    begin
      FOriginalProc(Msg);
      Exit;
    end;
    Exit;
  end;
  FOriginalProc(Msg);
end;

procedure ThemeControl(Control: TControl); forward;
type
  TPageAppearanceBinding=class(TComponent)
  private
    Page:TPageControl; BeforeChange:TTabChangingEvent; AfterChange:TNotifyEvent;
    procedure Changing(Sender:TObject; var AllowChange:Boolean);
    procedure Changed(Sender:TObject);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  end;
constructor TPageAppearanceBinding.Create(AOwner:TComponent);
begin
  inherited; Name:='PlayerPageAppearance'; Page:=TPageControl(AOwner);
  BeforeChange:=Page.OnChanging; AfterChange:=Page.OnChange;
  Page.OnChanging:=Changing; Page.OnChange:=Changed;
end;
destructor TPageAppearanceBinding.Destroy;
begin Page.OnChanging:=BeforeChange; Page.OnChange:=AfterChange; inherited; end;
procedure TPageAppearanceBinding.Changing(Sender:TObject; var AllowChange:Boolean);
begin
  if Assigned(BeforeChange) then BeforeChange(Sender,AllowChange);
  if AllowChange and Page.Showing then SendMessage(Page.Handle,WM_SETREDRAW,0,0);
end;
procedure TPageAppearanceBinding.Changed(Sender:TObject);
begin
  try
    // Prepare deferred content while the page is still covered by the redraw transaction.
    if Assigned(AfterChange) then AfterChange(Sender);
    if (Page.ActivePage<>nil) and (Page.ActivePage.FindComponent('PlayerPageReady')=nil) then
    begin
      ThemeControl(Page.ActivePage);
      var Ready:=TComponent.Create(Page.ActivePage); Ready.Name:='PlayerPageReady';
    end;
    var Host:=GetParentForm(Page,True);
    if (Host is TForm) and not (csDestroying in Host.ComponentState) then ApplyPlayerChrome(TForm(Host));
  finally
    if Page.HandleAllocated then begin SendMessage(Page.Handle,WM_SETREDRAW,1,0); RedrawWindow(Page.Handle,nil,0,RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW); end;
  end;
end;

procedure ThemeControl(Control: TControl);
var
  Children: TArray<TControl>;
  Frame: TModernCardPanel;
  Edit: TEdit;
begin
  if Control is TWinControl then
  begin
    if ((Control is TButton) or (Control is TCustomCheckBox) or
        (Control is TRadioButton) or (Control is TTrackBar) or (Control is TProgressBar) or
        (Control is TCustomComboBox) or (Control is TCustomGroupBox) or
        (Control is TPageControl) or (Control is TTabSheet)) and
       (Control.FindComponent('PlayerPaintBinding') = nil) then
      TPlayerPaintBinding.Create(Control);
    if StableDialogSurface(Control) and ((Control is TPanel) or (Control is TTabSheet) or
      (Control is TPageControl) or (Control is TCustomGroupBox)) then
      SetWindowLong(TWinControl(Control).Handle,GWL_STYLE,
        GetWindowLong(TWinControl(Control).Handle,GWL_STYLE) or WS_CLIPCHILDREN);
    // Native children render themselves. Buffering every child causes VCL to
    // ask them to WM_PRINTCLIENT, which otherwise bypasses custom dark paint.
    TControlAccess(Control).DoubleBuffered := Control is TCustomForm;
    TControlAccess(Control).Font.Color := DP_COLOR_TEXT;
    TControlAccess(Control).Font.Quality := fqClearTypeNatural;
    TControlAccess(Control).Color := DP_COLOR_SURFACE;

    if Control is TCustomEdit then
    begin
      Control.StyleElements := [];
      TControlAccess(Control).Color := DP_COLOR_ELEVATED;
    end;

    if Control is TCustomComboBox then
    begin
      Control.StyleElements := [];
      if Control is TComboBox then
      begin
        var Combo:=TComboBox(Control);
        if Combo.FindComponent('PlayerComboMenu')=nil then ConfigureComboMenu(Combo,Combo.Style=csDropDown);
        var Value:=Combo.Text;
        Combo.Style:=csOwnerDrawFixed;
        Combo.OnDrawItem:=TComboDrawer.GlobalDrawComboItem;
        var Index:=Combo.Items.IndexOf(Value);
        if (Index<0) and (Value<>'') then Index:=Combo.Items.Add(Value);
        Combo.ItemIndex:=Index;
        TComboBox(Control).ItemHeight := MulDiv(24, TComboBox(Control).CurrentPPI, 96);
      end;
      TControlAccess(Control).Color := DP_COLOR_ELEVATED;
      TControlAccess(Control).Font.Color := DP_COLOR_TEXT;
      SetWindowSubclass(TWinControl(Control).Handle, @DarkComboBoxSubclass, 5, 0);
    end;

    if Control is TButton then
    begin
      if SameText(Control.Name, 'btnClose') then TButton(Control).Cancel := True;
      SetWindowTheme(TButton(Control).Handle, '', '');
      SetWindowSubclass(TButton(Control).Handle, @DarkButtonSubclass, 1, 0);
    end;

    if Control is TTrackBar then
    begin
      SetWindowSubclass(TTrackBar(Control).Handle, @DarkTrackBarSubclass, 2, 0);
    end;
    if Control is TProgressBar then
      SetWindowSubclass(TWinControl(Control).Handle, @DarkProgressSubclass, 10, 0);

    if Control is TListBox then
      TListBox(Control).BorderStyle := bsNone;

    if Control is TPanel then
    begin
      Control.StyleElements := [];
      TPanel(Control).ParentBackground := False;
      TPanel(Control).BevelOuter := bvNone;
      TPanel(Control).Color := DP_COLOR_SURFACE;
      SetWindowSubclass(TPanel(Control).Handle, @DarkTabSheetSubclass, 5, 0);
    end;

    if Control is TPageControl then
    begin
      Control.StyleElements := [];
      TPageControl(Control).OwnerDraw := True;
      TPageControl(Control).TabHeight := MulDiv(32, TPageControl(Control).CurrentPPI, 96);
      TPageControl(Control).TabWidth := MulDiv(120, TPageControl(Control).CurrentPPI, 96);
      TPageControl(Control).OnDrawTab := TTabDrawer.GlobalDrawTab;
      EnablePageTransitions(TPageControl(Control));
      if Control.FindComponent('PlayerPageAppearance')=nil then TPageAppearanceBinding.Create(Control);
      SetWindowTheme(TPageControl(Control).Handle, '', '');
      SetWindowSubclass(TPageControl(Control).Handle, @DarkTabSheetSubclass, 4, 0);
    end;

    if Control is TTabSheet then
    begin
      Control.StyleElements := [];
      TControlAccess(Control).ParentBackground := False;
      TControlAccess(Control).Color := DP_COLOR_SURFACE;
      SetWindowTheme(TTabSheet(Control).Handle, '', '');
      SetWindowSubclass(TTabSheet(Control).Handle, @DarkTabSheetSubclass, 3, 0);
    end;

    if (Control is TCustomCheckBox) or (Control is TRadioButton) then
    begin
      Control.StyleElements := [];
      TControlAccess(Control).Font.Color := DP_COLOR_TEXT;
      TControlAccess(Control).Color := DP_COLOR_SURFACE;
      SetWindowTheme(TWinControl(Control).Handle, '', '');
      SetWindowSubclass(TWinControl(Control).Handle, @DarkCheckSubclass, 9, 0);
    end;

    if Control is TCustomGroupBox then
    begin
      Control.StyleElements := [];
      TControlAccess(Control).ParentBackground := False;
      TControlAccess(Control).Font.Color := DP_COLOR_TEXT;
      TControlAccess(Control).Color := DP_COLOR_SURFACE;
      SetWindowTheme(TGroupBox(Control).Handle, '', '');
      SetWindowSubclass(TGroupBox(Control).Handle, @DarkTabSheetSubclass, 6, 0);
    end;

    SetLength(Children, TWinControl(Control).ControlCount);
    for var I := 0 to High(Children) do Children[I] := TWinControl(Control).Controls[I];
    for var Child in Children do
    begin
      if (Child is TTabSheet) and (TTabSheet(Child).PageControl<>nil) and
        (TTabSheet(Child).PageControl.ActivePage<>Child) then Continue;
      ThemeControl(Child);
      if (Child is TTabSheet) and (Child.FindComponent('PlayerPageReady')=nil) then
      begin var Ready:=TComponent.Create(Child); Ready.Name:='PlayerPageReady'; end;
    end;

    if (Control is TEdit) and not (Control.Parent is TModernCardPanel) then
    begin
      Edit := TEdit(Control);
      Frame := TModernCardPanel.Create(Edit.Owner);
      Frame.Parent := Edit.Parent;
      Frame.StyleElements := [];
      Frame.CardColor := DP_COLOR_ELEVATED;
      Frame.BorderColor := DP_COLOR_BORDER;
      Frame.CornerRadius := 6;
      Frame.Anchors := Edit.Anchors;
      Frame.BoundsRect := Edit.BoundsRect;
      TControlAccess(Frame).TabOrder := Edit.TabOrder;
      Edit.Parent := Frame;
      Edit.BorderStyle := bsNone;
      Edit.AutoSize := False;
      Edit.AlignWithMargins := True;
      Edit.Margins.SetBounds(MulDiv(7, Edit.CurrentPPI, 96), MulDiv(3, Edit.CurrentPPI, 96),
        MulDiv(7, Edit.CurrentPPI, 96), MulDiv(3, Edit.CurrentPPI, 96));
      Edit.Align := alClient;
    end;
  end
  else if Control is TLabel then
  begin
    Control.StyleElements := [];
    TLabel(Control).Font.Color := DP_COLOR_TEXT;
    TLabel(Control).Font.Quality := fqClearTypeNatural;
    TLabel(Control).Transparent := True;
  end;
end;

procedure RehookControl(Control: TControl);
var I: Integer; W: TWinControl; Existing: DWORD_PTR; Ready: Boolean;
begin
  if not (Control is TWinControl) then Exit;
  W := TWinControl(Control);
  if (Control is TTabSheet) and (TTabSheet(Control).PageControl<>nil) and
    (TTabSheet(Control).PageControl.ActivePage<>Control) then Exit;
  Ready:=False;
  if Control is TButton then Ready:=GetWindowSubclass(W.Handle,@DarkButtonSubclass,1,Existing)
  else if (Control is TCustomCheckBox) or (Control is TRadioButton) then Ready:=GetWindowSubclass(W.Handle,@DarkCheckSubclass,9,Existing)
  else if Control is TTrackBar then Ready:=GetWindowSubclass(W.Handle,@DarkTrackBarSubclass,2,Existing)
  else if Control is TPageControl then Ready:=GetWindowSubclass(W.Handle,@DarkTabSheetSubclass,4,Existing);
  if not Ready and ((Control is TButton) or (Control is TCustomCheckBox) or
     (Control is TRadioButton) or (Control is TTrackBar) or (Control is TPageControl)) then
    SetWindowTheme(W.Handle, '', '');
  if Control is TButton then SetWindowSubclass(W.Handle, @DarkButtonSubclass, 1, 0)
  else if (Control is TCustomCheckBox) or (Control is TRadioButton) then
    SetWindowSubclass(W.Handle, @DarkCheckSubclass, 9, 0)
  else if Control is TProgressBar then SetWindowSubclass(W.Handle, @DarkProgressSubclass, 10, 0)
  else if Control is TTrackBar then SetWindowSubclass(W.Handle, @DarkTrackBarSubclass, 2, 0)
  else if Control is TCustomComboBox then SetWindowSubclass(W.Handle, @DarkComboBoxSubclass, 5, 0)
  else if (Control is TPanel) or (Control is TTabSheet) or
    (Control is TPageControl) or (Control is TCustomGroupBox) then
    SetWindowSubclass(W.Handle, @DarkTabSheetSubclass, 4, 0);
  for I := 0 to W.ControlCount - 1 do RehookControl(W.Controls[I]);
end;

type
  TPlayerThemeBinding = class(TComponent)
  private
    FPreviousShow: TNotifyEvent;
    procedure Shown(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TPlayerThemeBinding.Create(AOwner: TComponent);
begin
  inherited;
  Name := 'PlayerAppearanceBinding';
  FPreviousShow := TForm(AOwner).OnShow;
  TForm(AOwner).OnShow := Shown;
end;

procedure TPlayerThemeBinding.Shown(Sender: TObject);
var Form: TForm; DarkMode: Integer; Existing: DWORD_PTR; NeedsBind: Boolean;
begin
  if csDestroying in Owner.ComponentState then Exit;
  if Assigned(FPreviousShow) then FPreviousShow(Sender);
  Form := TForm(Owner);
  if (Form <> Application.MainForm) and (Form.Parent = nil) then
  begin
    HidePlaybackOSD;
    if Assigned(Application.MainForm) then
      for var I := 0 to Application.MainForm.ComponentCount - 1 do
        if Application.MainForm.Components[I] is TPlayerFlyout then
          TPlayerFlyout(Application.MainForm.Components[I]).Dismiss;
  end;
  DarkMode := Ord(not PlayerLightTheme);
  DwmSetWindowAttribute(Form.Handle, 20, @DarkMode, SizeOf(DarkMode));
  EnableDwmRoundedCorners(Form.Handle);
  NeedsBind:=not GetWindowSubclass(Form.Handle,@DarkFormSubclass,100,Existing);
  SetWindowSubclass(Form.Handle, @DarkFormSubclass, 100, 0);
  // ShowModal can recreate every HWND when assigning its popup owner. Rebind
  // paint handlers after that, without reparenting or rebuilding any controls.
  if NeedsBind then RehookControl(Form);
  ApplyPlayerChrome(Form);
end;

procedure ApplyPlayerAppearance(Form: TForm);
var
  DarkMode: Integer;
begin
  if Form.PopupMode<>pmExplicit then Form.PopupMode := pmAuto;
  DarkMode := Ord(not PlayerLightTheme);
  // DWMWA_USE_IMMERSIVE_DARK_MODE = 20
  DwmSetWindowAttribute(Form.Handle, 20, @DarkMode, SizeOf(DarkMode));
  EnableDwmRoundedCorners(Form.Handle);
  SetWindowSubclass(Form.Handle, @DarkFormSubclass, 100, 0);

  Form.StyleElements := [];
  Form.Color := DP_COLOR_SURFACE;
  Form.Font.Name := 'Segoe UI';
  Form.Font.Quality := fqClearTypeNatural;
  Form.Font.Color := DP_COLOR_TEXT;
  ThemeControl(Form);
  StyleDarkMemos(Form);
  if Form.FindComponent('PlayerAppearanceBinding') = nil then
    TPlayerThemeBinding.Create(Form);
  ApplyPlayerChrome(Form);
end;

procedure TPlayerHint.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not WS_BORDER;
  Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE or WS_EX_TRANSPARENT or WS_EX_LAYERED;
  Params.WindowClass.Style := Params.WindowClass.Style and not CS_DROPSHADOW;
end;

function CreateHintFont(PPI: Integer): HFONT;
begin
  Result := CreateFont(-MulDiv(13, PPI, 96), 0, 0, 0, FW_NORMAL, 0, 0, 0,
    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_NATURAL_QUALITY,
    DEFAULT_PITCH or FF_DONTCARE, 'Segoe UI');
end;

function TPlayerHint.MeasureCard(const Text: string; PPI: Integer): TRect;
var
  Font: HFONT;
  DC: HDC;
  Previous: HGDIOBJ;
begin
  DC := CreateCompatibleDC(0);
  Font := CreateHintFont(PPI);
  Previous := SelectObject(DC, Font);
  try
    Result := Rect(0, 0, MulDiv(320, PPI, 96), 0);
    DrawText(DC, PChar(Text), Length(Text), Result, DT_CALCRECT or DT_NOPREFIX or DT_WORDBREAK);
    Inc(Result.Right, MulDiv(24, PPI, 96));
    Inc(Result.Bottom, MulDiv(12, PPI, 96));
  finally
    SelectObject(DC, Previous);
    DeleteObject(Font);
    DeleteDC(DC);
  end;
end;

procedure TPlayerHint.ShowCard(const Bounds: TRect; const Text: string; PPI: Integer; OwnerWindow: HWND);
var
  Info: TBitmapInfo;
  Bits: Pointer;
  DC: HDC;
  DIB, Previous: HGDIOBJ;
  Bitmap: TGPBitmap;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Fill: TGPSolidBrush;
  Font: HFONT;
  PreviousFont: HGDIOBJ;
  TextBounds, Measured: TRect;
  Pixel: PCardinal;
  Blend: TBlendFunction;
  Dest, Origin: TPoint;
  Size: TSize;
  W, H, D: Single;
begin
  Size.cx := Bounds.Width;
  Size.cy := Bounds.Height;
  ZeroMemory(@Info, SizeOf(Info));
  Info.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  Info.bmiHeader.biWidth := Size.cx;
  Info.bmiHeader.biHeight := -Size.cy;
  Info.bmiHeader.biPlanes := 1;
  Info.bmiHeader.biBitCount := 32;
  DC := CreateCompatibleDC(0);
  if DC = 0 then Exit;
  try
    DIB := CreateDIBSection(DC, Info, DIB_RGB_COLORS, Bits, 0, 0);
    if DIB = 0 then Exit;
    try
      Previous := SelectObject(DC, DIB);
      Bitmap := TGPBitmap.Create(Size.cx, Size.cy, Size.cx * 4, PixelFormat32bppPARGB, Bits);
      try
        G := TGPGraphics.Create(Bitmap);
        Path := TGPGraphicsPath.Create;
        Fill := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_BORDER));
        try
          G.Clear(0);
          G.SetSmoothingMode(SmoothingModeAntiAlias);
          W := Size.cx - 1;
          H := Size.cy - 1;
          D := 16 * PPI / 96;
          Path.AddArc(0.5, 0.5, D, D, 180, 90);
          Path.AddArc(W - D + 0.5, 0.5, D, D, 270, 90);
          Path.AddArc(W - D + 0.5, H - D + 0.5, D, D, 0, 90);
          Path.AddArc(0.5, H - D + 0.5, D, D, 90, 90);
          Path.CloseFigure;
          var Edge := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 1);
          try
            Fill.SetColor(MakeGDIColor(DP_COLOR_ELEVATED));
            G.FillPath(Fill, Path);
            G.DrawPath(Edge, Path);
          finally Edge.Free; end;
        finally
          Fill.Free;
          Path.Free;
          G.Free;
        end;
      finally Bitmap.Free; end;
      Font := CreateHintFont(PPI);
      PreviousFont := SelectObject(DC, Font);
      try
        SetBkMode(DC, TRANSPARENT);
        SetTextColor(DC, ColorToRGB(DP_COLOR_TEXT));
        TextBounds := Rect(MulDiv(10, PPI, 96), 0,
          Size.cx - MulDiv(10, PPI, 96), Size.cy);
        Measured := TextBounds;
        DrawText(DC, PChar(Text), Length(Text), Measured, DT_CALCRECT or DT_NOPREFIX or DT_WORDBREAK);
        TextBounds.Top := Max(2, (Size.cy - Measured.Height) div 2);
        TextBounds.Bottom := Min(Size.cy - 2, TextBounds.Top + Measured.Height);
        DrawText(DC, PChar(Text), Length(Text), TextBounds, DT_CENTER or DT_NOPREFIX or DT_WORDBREAK);
        GdiFlush;
        // GDI text may clear alpha. Restore it only within the opaque interior.
        for var Y := TextBounds.Top to TextBounds.Bottom - 1 do
        begin
          Pixel := PCardinal(NativeUInt(Bits) + NativeUInt(Y * Size.cx + TextBounds.Left) * SizeOf(Cardinal));
          for var X := TextBounds.Left to TextBounds.Right - 1 do
          begin
            Pixel^ := Pixel^ or $FF000000;
            Inc(Pixel);
          end;
        end;
      finally
        SelectObject(DC, PreviousFont);
        DeleteObject(Font);
      end;
      Caption := Text;
      SetWindowLongPtr(Handle, GWLP_HWNDPARENT, LONG_PTR(OwnerWindow));
      Dest := Bounds.TopLeft;
      Origin := Point(0, 0);
      Blend.BlendOp := AC_SRC_OVER;
      Blend.BlendFlags := 0;
      Blend.SourceConstantAlpha := 255;
      Blend.AlphaFormat := AC_SRC_ALPHA;
      if UpdateLayeredWindow(Handle, 0, @Dest, @Size, DC, @Origin, 0, @Blend, ULW_ALPHA) then
        SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
      SelectObject(DC, Previous);
    finally DeleteObject(DIB); end;
  finally DeleteDC(DC); end;
end;

constructor TPlayerHintTracker.Create(AOwner: TComponent);
begin
  inherited;
  FPopup := TPlayerHint.Create(Self);
  FPopup.Font.Name := 'Segoe UI';
  Interval := 25;
  OnTimer := Track;
end;

procedure TPlayerHintTracker.Track(Sender: TObject);
var
  Cursor, Anchor: TPoint;
  Hit: TControl;
  Wnd: HWND;
  R, Work: TRect;
  Gap: Integer;
  HintText: string;
begin
  Hit := nil;
  Wnd := 0;
  if not GAppClosing and (GetAsyncKeyState(VK_LBUTTON) >= 0) and
    (GetAsyncKeyState(VK_RBUTTON) >= 0) and GetCursorPos(Cursor) then
  begin
    Wnd := WindowFromPoint(Cursor);
    if (GetWindowThreadProcessId(GetForegroundWindow, nil) = GetCurrentThreadId) and
      IsWindowEnabled(GetAncestor(Wnd, GA_ROOT)) then
      Hit := FindDragTarget(Cursor, False);
    if (Hit <> nil) and (not Hit.ShowHint or (Hit.Hint = '')) then Hit := nil;
    if Hit is TOverflowHintLabel then
    begin
      var LabelControl := TOverflowHintLabel(Hit);
      var TextBounds := Rect(0, 0, Hit.Width, 0);
      LabelControl.Canvas.Font.Assign(LabelControl.Font);
      DrawText(LabelControl.Canvas.Handle, PChar(LabelControl.Caption), -1, TextBounds,
        DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
      if (TextBounds.Height <= Hit.Height) and (TextBounds.Width <= Hit.Width) then
        Hit := nil;
    end;
    if Hit = nil then Wnd := 0;
  end;
  if (Wnd <> FLastTarget) or (Hit <> FLastControl) then
  begin
    FLastTarget := Wnd;
    FLastControl := Hit;
    FSince := GetTickCount64;
    FPopup.ReleaseHandle;
  end;
  if (Hit = nil) or FPopup.HandleAllocated or (GetTickCount64 - FSince < 100) then Exit;
  Work := Screen.MonitorFromPoint(Cursor).WorkareaRect;
  var PPI := Hit.CurrentPPI;
  Gap := MulDiv(6, PPI, 96);
  HintText := GetShortHint(Hit.Hint);
  R := FPopup.MeasureCard(HintText, PPI);
  if Hit is TOverflowHintLabel then
    Anchor := Point(Cursor.X + Gap, Cursor.Y + 2 * Gap)
  else
    Anchor := Hit.ClientToScreen(Point(0, Hit.Height + Gap));
  Anchor.X := EnsureRange(Anchor.X, Work.Left, Max(Work.Left, Work.Right - R.Width));
  if Anchor.Y + R.Height > Work.Bottom then
    if Hit is TOverflowHintLabel then
      Anchor.Y := Cursor.Y - R.Height - Gap
    else
      Anchor.Y := Hit.ClientToScreen(Point(0, 0)).Y - R.Height - Gap;
  OffsetRect(R, Anchor.X, Max(Anchor.Y, Work.Top));
  FPopup.ShowCard(R, HintText, PPI, GetAncestor(Wnd, GA_ROOT));
end;

procedure LoadPlayerPalette;
var
  Settings: TAppSettings;
  Registry: TRegistry;
  Theme: Integer;
begin
  Settings := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Theme := Settings.ReadInteger('Interface', 'Theme', 0);
  finally
    Settings.Free;
  end;
  PlayerLightTheme := Theme = 1;
  if Theme <> 2 then
    if Theme <> 1 then
    begin
      Registry := TRegistry.Create(KEY_READ);
      try
        Registry.RootKey := HKEY_CURRENT_USER;
        if Registry.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') and
          (Registry.GetDataType('AppsUseLightTheme') = rdInteger) then
          PlayerLightTheme := Registry.ReadInteger('AppsUseLightTheme') <> 0
        else
          PlayerLightTheme := ColorToRGB(clWindow) = clWhite;
      finally
        Registry.Free;
      end;
    end;
  if not PlayerLightTheme then Exit;

  DP_COLOR_BG := $00F5F3F1;
  DP_COLOR_SURFACE := $00FCFAF8;
  DP_COLOR_ELEVATED := $00FFFFFF;
  DP_COLOR_HOVER := $00F9EDE1;
  DP_COLOR_BORDER := $00D8D1C9;
  DP_COLOR_SCROLL := $00857A70;
  DP_COLOR_TEXT := $00261D16;
  DP_COLOR_MUTED := $0062564C;
  DP_COLOR_ACCENT := $00A06200;
  DP_COLOR_ACCHOVER := $00945600;
  DP_COLOR_ACCPRESS := $00854B00;
  DP_COLOR_ACCSOFT := $00F9E7D5;
  DP_COLOR_HEAD_A := DP_COLOR_BG;
  DP_COLOR_HEAD_B := DP_COLOR_BG;
  DeleteObject(GDarkSurfaceBrush);
  DeleteObject(GDarkElevatedBrush);
  GDarkSurfaceBrush := CreateSolidBrush(ColorToRGB(DP_COLOR_SURFACE));
  GDarkElevatedBrush := CreateSolidBrush(ColorToRGB(DP_COLOR_ELEVATED));
end;

procedure InitializePlayerAppearance;
begin
  LoadPlayerPalette;
  TStyleManager.FormBorderStyle := fbsSystemStyle;
  TStyleManager.SystemHooks := [];
  Application.ShowHint := False;
  if Application.FindComponent('PlayerHintTracker') = nil then
    TPlayerHintTracker.Create(Application).Name := 'PlayerHintTracker';
  TStyleManager.AnimationOnControls := False;
  if Application.FindComponent('PlayerWheelRouter')=nil then
    TWheelRouter.Create(Application).Name := 'PlayerWheelRouter';
end;

procedure PlayerMessage(const Text: string);
var
  Dialog: TForm;
  Body: TLabel;
  Button: TButton;
  Scale: Integer;
begin
  Dialog := TForm.CreateNew(Application);
  try
    Dialog.Caption := 'VLC Modern';
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poMainFormCenter;
    Dialog.Font.Name := 'Segoe UI';
    Dialog.Font.Size := 10;
    Dialog.Color := DP_COLOR_SURFACE;
    Scale := Dialog.CurrentPPI;
    if Length(Text)>500 then Dialog.ClientWidth:=Min(Screen.WorkAreaWidth-MulDiv(80,Scale,96),MulDiv(620,Scale,96))
    else Dialog.ClientWidth := MulDiv(380, Scale, 96);
    Dialog.ClientHeight := MulDiv(200, Scale, 96);

    Body := TLabel.Create(Dialog);
    Body.Parent := Dialog;
    Body.AutoSize := False;
    Body.Left := MulDiv(24, Scale, 96);
    Body.Top := MulDiv(24, Scale, 96);
    Body.Width := Dialog.ClientWidth - MulDiv(48, Scale, 96);
    Body.Height := MulDiv(100, Scale, 96);
    Body.WordWrap := True;
    Body.Font.Color := DP_COLOR_TEXT;
    Body.Caption := Text;
    Dialog.Canvas.Font.Assign(Body.Font);
    var TextBounds:=Rect(0,0,Body.Width,0);
    DrawText(Dialog.Canvas.Handle,PChar(Text),Length(Text),TextBounds,DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
    Body.Height:=Max(MulDiv(36,Scale,96),TextBounds.Height+MulDiv(8,Scale,96));
    Dialog.ClientHeight:=Body.Top+Body.Height+MulDiv(78,Scale,96);

    Button := TButton.Create(Dialog);
    Button.Parent := Dialog;
    Button.Caption := 'OK';
    Button.Default := True;
    Button.ModalResult := mrOk;
    Button.Width := MulDiv(88, Scale, 96);
    Button.Height := MulDiv(30, Scale, 96);
    Button.Left := Dialog.ClientWidth - Button.Width - MulDiv(24, Scale, 96);
    Button.Top := Dialog.ClientHeight - Button.Height - MulDiv(18, Scale, 96);

    ApplyPlayerAppearance(Dialog);
    Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

function PlayerInput(const Title, Prompt: string; var Value: string): Boolean;
var Dialog: TForm; Body: TLabel; Edit: TEdit; Accept, Cancel: TButton; D: Integer;
begin
  Dialog := TForm.CreateNew(Application);
  try
    Dialog.Caption := Title;
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poMainFormCenter;
    Dialog.Font.Size := 10;
    D := Dialog.CurrentPPI;
    Dialog.ClientWidth := MulDiv(420, D, 96);
    Dialog.ClientHeight := MulDiv(184, D, 96);
    Body := TLabel.Create(Dialog);
    Body.Parent := Dialog;
    Body.Caption := Prompt;
    Body.SetBounds(MulDiv(24, D, 96), MulDiv(24, D, 96), MulDiv(372, D, 96), MulDiv(24, D, 96));
    Edit := TEdit.Create(Dialog);
    Edit.Parent := Dialog;
    Edit.SetBounds(MulDiv(24, D, 96), MulDiv(60, D, 96), MulDiv(372, D, 96), MulDiv(30, D, 96));
    Edit.Text := Value;
    Accept := TButton.Create(Dialog);
    Accept.Parent := Dialog;
    Accept.Caption := 'Add';
    Accept.Default := True;
    Accept.ModalResult := mrOk;
    Accept.SetBounds(MulDiv(192, D, 96), MulDiv(128, D, 96), MulDiv(96, D, 96), MulDiv(32, D, 96));
    Cancel := TButton.Create(Dialog);
    Cancel.Parent := Dialog;
    Cancel.Caption := 'Cancel';
    Cancel.Cancel := True;
    Cancel.ModalResult := mrCancel;
    Cancel.SetBounds(MulDiv(300, D, 96), MulDiv(128, D, 96), MulDiv(96, D, 96), MulDiv(32, D, 96));
    ApplyPlayerAppearance(Dialog);
    Dialog.ActiveControl := Edit;
    Result := Dialog.ShowModal = mrOk;
    if Result then Value := Edit.Text;
  finally Dialog.Free; end;
end;

function PlayerChooseSubtitle(const Items: TArray<string>): Integer;
var Dialog: TForm; Body: TLabel; Choices: TComboBox; Accept, Cancel: TButton; D: Integer;
begin
  Dialog := TForm.CreateNew(Application);
  try
    Dialog.Caption := 'OpenSubtitles';
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poMainFormCenter;
    Dialog.Font.Size := 10;
    D := Dialog.CurrentPPI;
    Dialog.ClientWidth := MulDiv(620, D, 96);
    Dialog.ClientHeight := MulDiv(184, D, 96);
    Body := TLabel.Create(Dialog);
    Body.Parent := Dialog;
    Body.Caption := 'Choose a subtitle by language and release';
    Body.SetBounds(MulDiv(24, D, 96), MulDiv(24, D, 96), MulDiv(572, D, 96), MulDiv(24, D, 96));
    Choices := TComboBox.Create(Dialog);
    Choices.Parent := Dialog;
    Choices.Style := csDropDownList;
    Choices.SetBounds(MulDiv(24, D, 96), MulDiv(60, D, 96), MulDiv(572, D, 96), MulDiv(30, D, 96));
    Choices.Items.AddStrings(Items);
    Choices.ItemIndex := 0;
    Accept := TButton.Create(Dialog);
    Accept.Parent := Dialog;
    Accept.Caption := 'Download';
    Accept.Default := True;
    Accept.ModalResult := mrOk;
    Accept.SetBounds(MulDiv(392, D, 96), MulDiv(128, D, 96), MulDiv(96, D, 96), MulDiv(32, D, 96));
    Cancel := TButton.Create(Dialog);
    Cancel.Parent := Dialog;
    Cancel.Caption := 'Cancel';
    Cancel.Cancel := True;
    Cancel.ModalResult := mrCancel;
    Cancel.SetBounds(MulDiv(500, D, 96), MulDiv(128, D, 96), MulDiv(96, D, 96), MulDiv(32, D, 96));
    ApplyPlayerAppearance(Dialog);
    Dialog.ActiveControl := Choices;
    Result := -1;
    if Dialog.ShowModal = mrOk then Result := Choices.ItemIndex;
  finally Dialog.Free; end;
end;

function PlayerResume(const Position: string; out Remember: Boolean): Boolean;
var Dialog: TForm; Text: TLabel; Check: TCheckBox; Resume, Restart: TButton; D: Integer;
begin
  Remember:=False;
  Dialog:=TForm.CreateNew(Application);
  try
    Dialog.Caption:='Continue watching';
    Dialog.Position:=poMainFormCenter;
    D:=Dialog.CurrentPPI;
    Dialog.ClientWidth:=MulDiv(440,D,96);
    Dialog.ClientHeight:=MulDiv(220,D,96);
    Text:=TLabel.Create(Dialog);
    Text.Parent:=Dialog;
    Text.AutoSize:=False;
    Text.WordWrap:=True;
    Text.Caption:='Continue from '+Position+' or start from the beginning?';
    Text.SetBounds(MulDiv(24,D,96),MulDiv(54,D,96),MulDiv(392,D,96),MulDiv(56,D,96));
    Check:=TCheckBox.Create(Dialog);
    Check.Parent:=Dialog;
    Check.Caption:='Always use this choice';
    Check.SetBounds(MulDiv(24,D,96),MulDiv(122,D,96),MulDiv(360,D,96),MulDiv(24,D,96));
    Resume:=TButton.Create(Dialog);
    Resume.Parent:=Dialog;
    Resume.Caption:='Resume'; Resume.Default:=True; Resume.ModalResult:=mrYes;
    Resume.SetBounds(MulDiv(178,D,96),MulDiv(170,D,96),MulDiv(112,D,96),MulDiv(32,D,96));
    Restart:=TButton.Create(Dialog);
    Restart.Parent:=Dialog;
    Restart.Caption:='Start over'; Restart.ModalResult:=mrNo; Restart.Cancel:=True;
    Restart.SetBounds(MulDiv(302,D,96),MulDiv(170,D,96),MulDiv(112,D,96),MulDiv(32,D,96));
    ApplyPlayerAppearance(Dialog);
    Result:=Dialog.ShowModal=mrYes;
    Remember:=Check.Checked;
  finally Dialog.Free; end;
end;

initialization
  GDarkSurfaceBrush := CreateSolidBrush(ColorToRGB(DP_COLOR_SURFACE));
  GDarkElevatedBrush := CreateSolidBrush(ColorToRGB(DP_COLOR_ELEVATED));

finalization
  if GDarkSurfaceBrush <> 0 then DeleteObject(GDarkSurfaceBrush);
  if GDarkElevatedBrush <> 0 then DeleteObject(GDarkElevatedBrush);

end.
