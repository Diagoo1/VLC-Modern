unit PlayerMenu;

interface

uses System.Classes, System.Types, Vcl.Forms, Vcl.Menus;

procedure ShowPlayerMenu(OwnerForm: TForm; Items: TMenuItem; const Position: TPoint; FieldWidth: Integer = 0; OnDismiss: TNotifyEvent = nil);
procedure ClosePlayerMenus;
function PlayerMenuWindow: TForm;
function PlayerMenuShows(Items: TMenuItem): Boolean;

implementation

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.SysUtils, System.Math,
  System.Generics.Collections, Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls,
  Vcl.AppEvnts, CurvedControls;

type
  TPlayerPopup = class;
  TMenuController = class(TComponent)
  private
    Events: TApplicationEvents;
    Windows: TList<TPlayerPopup>;
    Retiring: TList<TPlayerPopup>;
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure Deactivate(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseFrom(Level: Integer);
  end;

  TPlayerPopup = class(TForm)
  private
    Entries: TList<TMenuItem>;
    HoverTimer: TTimer;
    FadeTimer:TTimer;
    FadeStart:UInt64;
    FadeClosing:Boolean;
    FadeFrom:Integer;
    Selected, First, Level, RowHeight, Padding: Integer;
    SourceItems: TMenuItem;
    Closed: TNotifyEvent;
    IsCombo: Boolean;
    ScrollDragging:Boolean;
    procedure FadeTick(Sender:TObject);
    procedure BeginFade(Close:Boolean);
    procedure ScrollAt(Y:Integer);
    procedure HoverTick(Sender: TObject);
    function RowAt(Y: Integer): Integer;
    function RowTop(Index: Integer): Integer;
    function EntryHeight(Index: Integer): Integer;
    procedure SelectRow(Index: Integer);
    procedure ExecuteRow;
    procedure OpenChild;
    procedure Navigate(Key: Word);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button:TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor CreateMenu(OwnerForm: TForm; Items: TMenuItem; ALevel: Integer; Position: TPoint; FieldWidth: Integer = 0; OnDismiss: TNotifyEvent = nil);
    destructor Destroy; override;
  end;

var
  Controller: TMenuController;

function PlayerMenuShows(Items: TMenuItem): Boolean;
begin
  Result := (Controller <> nil) and (Controller.Windows.Count > 0) and
    (Controller.Windows[0].SourceItems = Items);
end;

constructor TMenuController.Create(AOwner: TComponent);
begin
  inherited;
  Windows := TList<TPlayerPopup>.Create;
  Retiring := TList<TPlayerPopup>.Create;
  Events := TApplicationEvents.Create(Self);
  Events.OnMessage := AppMessage;
  Events.OnDeactivate := Deactivate;
end;

destructor TMenuController.Destroy;
begin
  while Windows.Count>0 do
  begin
    var Popup:=Windows.Last; Windows.Delete(Windows.Count-1);
    Popup.Closed:=nil; Popup.Free;
  end;
  while Retiring.Count>0 do Retiring.Last.Free;
  FreeAndNil(Retiring);
  FreeAndNil(Windows);
  if Controller=Self then Controller:=nil;
  inherited;
end;

procedure TMenuController.CloseFrom(Level: Integer);
begin
  while Windows.Count > Level do
  begin
    var Popup := Windows.Last;
    Windows.Delete(Windows.Count - 1);

    if Assigned(Popup.Closed) then begin var Callback:=Popup.Closed; Popup.Closed:=nil; Callback(Popup); end;
    Popup.HoverTimer.Enabled := False;
    if Popup.IsCombo then begin Retiring.Add(Popup); Popup.BeginFade(True); end
    else begin ShowWindow(Popup.Handle,SW_HIDE); Popup.Release; end;
  end;
  if (Level = 0) and Assigned(Application.MainForm) and Application.MainForm.Enabled then
  begin
    var ForegroundProcess: DWORD;
    GetWindowThreadProcessId(GetForegroundWindow, @ForegroundProcess);
    if ForegroundProcess = GetCurrentProcessId then
      Winapi.Windows.SetFocus(Application.MainForm.Handle);
  end;
end;

procedure TMenuController.Deactivate(Sender: TObject);
begin
  CloseFrom(0);
end;

procedure TMenuController.AppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if Windows.Count = 0 then Exit;
  if Msg.message = WM_MOUSEWHEEL then
  begin
    Windows.Last.DoMouseWheel([], SmallInt(HIWORD(Msg.wParam)), Msg.pt);
    Handled := True;
  end
  else if Msg.message = WM_KEYDOWN then
  begin
    Windows.Last.Navigate(Word(Msg.wParam));
    Handled := True;
  end
  else if (Msg.message = WM_LBUTTONDOWN) or (Msg.message = WM_RBUTTONDOWN) or
    (Msg.message = WM_NCLBUTTONDOWN) then
  begin
    if Windows[0].IsCombo and (Msg.hwnd=HWND(Windows[0].SourceItems.Tag)) then Exit;
    for var Popup in Windows do
      if GetAncestor(Msg.hwnd, GA_ROOT) = Popup.Handle then Exit;
    CloseFrom(0);
  end;
end;

procedure TPlayerPopup.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE or WS_EX_TOOLWINDOW;
  Params.WindowClass.style := Params.WindowClass.style or CS_DROPSHADOW;
end;

constructor TPlayerPopup.CreateMenu(OwnerForm: TForm; Items: TMenuItem; ALevel: Integer; Position: TPoint; FieldWidth: Integer; OnDismiss: TNotifyEvent);
var
  TotalHeight, MenuWidth: Integer;
  Work: TRect;
begin
  inherited CreateNew(OwnerForm);
  BorderStyle := bsNone;
  StyleElements := [];
  Color := DP_COLOR_SURFACE;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Font.Color := DP_COLOR_TEXT;
  Font.Quality := fqClearType;
  DoubleBuffered := True;
  PopupMode := pmExplicit;
  // Component ownership already bounds the popup lifetime. Avoid VCL popup
  // parenting: its teardown can recreate an owner whose form fields are gone.
  PopupParent := nil;
  Level := ALevel;
  SourceItems := Items;
  Closed:=OnDismiss; IsCombo:=FieldWidth>0;
  Selected := -1;
  RowHeight := MulDiv(32, CurrentPPI, 96);
  Padding := MulDiv(8, CurrentPPI, 96);
  Entries := TList<TMenuItem>.Create;
  Canvas.Font.Assign(Font);
  MenuWidth := MulDiv(220, CurrentPPI, 96);
  TotalHeight := Padding * 2;
  for var I := 0 to Items.Count - 1 do
    if Items[I].Visible then
    begin
      Entries.Add(Items[I]);
      Inc(TotalHeight, EntryHeight(Entries.Count - 1));
      MenuWidth := Max(MenuWidth, Canvas.TextWidth(StripHotkey(Items[I].Caption)) +
        Canvas.TextWidth(ShortCutToText(Items[I].ShortCut)) + Padding * 10);
    end;
  Work := Screen.MonitorFromPoint(Position).WorkareaRect;
  if FieldWidth>0 then MenuWidth:=FieldWidth;
  MenuWidth:=Min(MenuWidth,Work.Width-Padding*2);
  ClientWidth := MenuWidth;
  if IsCombo then TotalHeight:=Min(TotalHeight,RowHeight*8+Padding*2);
  ClientHeight := Min(TotalHeight, Work.Height - Padding * 2);
  if Position.X + Width > Work.Right then
  begin
    if (Level > 0) and (Controller.Windows.Count > 0) then
      Position.X := Controller.Windows.Last.Left - Width + Padding
    else Position.X := Work.Right - Width - Padding;
  end;
  Left := Max(Work.Left + Padding, Position.X);
  Top := EnsureRange(Position.Y, Work.Top + Padding, Work.Bottom - ClientHeight - Padding);
  SetBounds(Left, Top, MenuWidth, ClientHeight);
  HoverTimer := TTimer.Create(Self);
  HoverTimer.Enabled := False;
  HoverTimer.Interval := 160;
  HoverTimer.OnTimer := HoverTick;
  Controller.Windows.Add(Self);
  EnableDwmRoundedCorners(Handle);
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, MenuWidth, ClientHeight, SWP_NOACTIVATE);
  if IsCombo then
  begin
    FadeTimer:=TTimer.Create(Self); FadeTimer.Enabled:=False;
    FadeTimer.Interval:=15; FadeTimer.OnTimer:=FadeTick;
    SetWindowLong(Handle,GWL_EXSTYLE,GetWindowLong(Handle,GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(Handle,0,0,LWA_ALPHA);
  end;
  ShowWindow(Handle,SW_SHOWNOACTIVATE);
  if IsCombo then BeginFade(False);
end;

destructor TPlayerPopup.Destroy;
begin
  Closed:=nil;
  if HoverTimer<>nil then HoverTimer.Enabled:=False;
  if (Controller<>nil) and (Controller.Windows<>nil) then Controller.Windows.Remove(Self);
  if (Controller<>nil) and (Controller.Retiring<>nil) then Controller.Retiring.Remove(Self);
  if FadeTimer<>nil then FadeTimer.Enabled:=False;
  Entries.Free;
  inherited;
end;

procedure TPlayerPopup.BeginFade(Close:Boolean);
var Key:COLORREF; Flags:DWORD; Alpha:Byte;
begin
  FadeClosing:=Close; FadeStart:=GetTickCount64;
  Alpha:=0;
  if Close then GetLayeredWindowAttributes(Handle,Key,Alpha,Flags);
  FadeFrom:=Alpha; FadeTimer.Enabled:=True;
end;

procedure TPlayerPopup.FadeTick(Sender:TObject);
var Progress:Double; Alpha:Integer;
begin
  Progress:=Min(1.0,(GetTickCount64-FadeStart)/100.0);
  Progress:=1-Sqr(1-Progress);
  if FadeClosing then Alpha:=Round(FadeFrom*(1-Progress))
  else Alpha:=Round(255*Progress);
  SetLayeredWindowAttributes(Handle,0,Byte(EnsureRange(Alpha,0,255)),LWA_ALPHA);
  if Progress>=1 then
  begin
    FadeTimer.Enabled:=False;
    if FadeClosing then
    begin
      ShowWindow(Handle,SW_HIDE);
      if (Controller<>nil) and (Controller.Retiring<>nil) then Controller.Retiring.Remove(Self);
      Release;
    end;
  end;
end;

function TPlayerPopup.EntryHeight(Index: Integer): Integer;
begin
  if Entries[Index].Caption = '-' then Result := Padding else Result := RowHeight;
end;

function TPlayerPopup.RowTop(Index: Integer): Integer;
begin
  Result := Padding;
  for var I := First to Index - 1 do Inc(Result, EntryHeight(I));
end;

function TPlayerPopup.RowAt(Y: Integer): Integer;
var
  Top: Integer;
begin
  Result := -1;
  Top := Padding;
  for var I := First to Entries.Count - 1 do
  begin
    if (Y >= Top) and (Y < Top + EntryHeight(I)) then Exit(I);
    Inc(Top, EntryHeight(I));
    if Top >= ClientHeight then Break;
  end;
end;

procedure TPlayerPopup.Paint;
var
  R, TextRect, ArrowRect: TRect;
  Item: TMenuItem;
  Caption, Shortcut: string;
begin
  Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.Pen.Color := DP_COLOR_BORDER;
  Canvas.RoundRect(0, 0, ClientWidth, ClientHeight, 10, 10);
  Canvas.Font.Assign(Font);
  for var I := First to Entries.Count - 1 do
  begin
    R := Rect(Padding div 2, RowTop(I), ClientWidth - Padding div 2, RowTop(I) + EntryHeight(I));
    if R.Top >= ClientHeight then Break;
    Item := Entries[I];
    if Item.Caption = '-' then
    begin
      Canvas.Pen.Color := DP_COLOR_BORDER;
      Canvas.MoveTo(Padding * 2, R.Top + Padding div 2);
      Canvas.LineTo(ClientWidth - Padding * 2, R.Top + Padding div 2);
      Continue;
    end;
    Canvas.Brush.Style := bsSolid;
    if (I = Selected) and Item.Enabled then
    begin
      Canvas.Brush.Color := DP_COLOR_HOVER;
      Canvas.Pen.Color := DP_COLOR_HOVER;
      Canvas.RoundRect(R, Padding, Padding);
    end;
    Canvas.Brush.Style := bsClear;
    if Item.Enabled then Canvas.Font.Color := DP_COLOR_TEXT else Canvas.Font.Color := DP_COLOR_SCROLL;
    TextRect := Rect(Padding * 4, R.Top, ClientWidth - Padding * 3, R.Bottom);
    Caption := StripHotkey(Item.Caption);
    Shortcut := ShortCutToText(Item.ShortCut);
    if Shortcut <> '' then Dec(TextRect.Right, Canvas.TextWidth(Shortcut) + Padding * 2);
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), TextRect, DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);
    if Shortcut <> '' then
    begin
      Canvas.Font.Color := DP_COLOR_MUTED;
      TextRect := Rect(Padding * 4, R.Top, ClientWidth - Padding * 3, R.Bottom);
      DrawText(Canvas.Handle, PChar(Shortcut), Length(Shortcut), TextRect, DT_SINGLELINE or DT_VCENTER or DT_RIGHT);
    end;
    Canvas.Pen.Color := DP_COLOR_MUTED;
    Canvas.Pen.Width := Max(1, CurrentPPI div 96);
    if Item.Count > 0 then
    begin
      ArrowRect := Rect(ClientWidth - Padding * 2, R.Top + RowHeight div 2, 0, 0);
      Canvas.MoveTo(ArrowRect.Left - 2, ArrowRect.Top - 3);
      Canvas.LineTo(ArrowRect.Left + 1, ArrowRect.Top);
      Canvas.LineTo(ArrowRect.Left - 2, ArrowRect.Top + 3);
    end;
    if Item.Checked then
    begin
      var G := TGPGraphics.Create(Canvas.Handle);
      try
        G.SetSmoothingMode(SmoothingModeAntiAlias);
        var PenCheck := TGPPen.Create(MakeGDIColor(DP_COLOR_ACCENT), 2.2);
        try
          PenCheck.SetStartCap(LineCapRound);
          PenCheck.SetEndCap(LineCapRound);
          PenCheck.SetLineJoin(LineJoinRound);
          var CX := Single(Padding * 2);
          var CY := Single(R.Top + RowHeight div 2);
          G.DrawLine(PenCheck, CX - 4.5, CY + 0.5, CX - 1.0, CY + 4.0);
          G.DrawLine(PenCheck, CX - 1.0, CY + 4.0, CX + 5.5, CY - 3.5);
        finally
          PenCheck.Free;
        end;
      finally
        G.Free;
      end;
    end;
  end;
  Canvas.Brush.Style := bsSolid;
  if IsCombo and (Entries.Count*RowHeight>ClientHeight-Padding*2) then
  begin
    var VisibleRows:=Max(1,(ClientHeight-Padding*2) div RowHeight);
    var RailHeight:=ClientHeight-Padding*2;
    var ThumbHeight:=Max(24,RailHeight*VisibleRows div Entries.Count);
    var ThumbTop:=Padding+(RailHeight-ThumbHeight)*First div Max(1,Entries.Count-VisibleRows);
    Canvas.Pen.Style:=psClear; Canvas.Brush.Color:=DP_COLOR_SCROLL;
    Canvas.RoundRect(ClientWidth-7,ThumbTop,ClientWidth-3,ThumbTop+ThumbHeight,4,4);
    Canvas.Pen.Style:=psSolid;
  end;
end;

procedure TPlayerPopup.SelectRow(Index: Integer);
begin
  if Selected = Index then Exit;
  Selected := Index;
  Controller.CloseFrom(Level + 1);
  HoverTimer.Enabled := False;
  if (Selected >= 0) and Entries[Selected].Enabled and (Entries[Selected].Count > 0) then
    HoverTimer.Enabled := True;
  Invalidate;
end;

procedure TPlayerPopup.ScrollAt(Y:Integer);
begin
  var Rows:=Max(1,(ClientHeight-Padding*2) div RowHeight);
  First:=EnsureRange(Round((Y-Padding)/Max(1,ClientHeight-Padding*2)*Max(0,Entries.Count-Rows)),0,Max(0,Entries.Count-Rows));
  SelectRow(-1); Invalidate;
end;
procedure TPlayerPopup.MouseDown(Button:TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
  inherited;
  if (Button=mbLeft) and IsCombo and (X>ClientWidth-14) and (Entries.Count*RowHeight>ClientHeight-Padding*2) then
  begin ScrollDragging:=True; MouseCapture:=True; ScrollAt(Y); end;
end;

procedure TPlayerPopup.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if ScrollDragging then begin ScrollAt(Y); Exit; end;
  SelectRow(RowAt(Y));
end;

procedure TPlayerPopup.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if ScrollDragging then begin ScrollDragging:=False; MouseCapture:=False; Exit; end;
  if Button = mbLeft then
  begin
    SelectRow(RowAt(Y));
    ExecuteRow;
  end;
end;

procedure TPlayerPopup.ExecuteRow;
var
  Item: TMenuItem;
begin
  if Selected < 0 then Exit;
  Item := Entries[Selected];
  if not Item.Enabled or (Item.Caption = '-') then Exit;
  if Item.Count > 0 then OpenChild
  else
  begin
    ClosePlayerMenus;
    Item.Click;
  end;
end;

procedure TPlayerPopup.OpenChild;
begin
  HoverTimer.Enabled := False;
  if (Selected < 0) or (Entries[Selected].Count = 0) then Exit;
  if (Controller.Windows.Count > Level + 1) and
     (Controller.Windows[Level + 1].SourceItems = Entries[Selected]) then Exit;
  Controller.CloseFrom(Level + 1);
  TPlayerPopup.CreateMenu(TForm(PopupParent), Entries[Selected], Level + 1,
    Point(Left + Width - Padding, Top + RowTop(Selected) - Padding));
end;

procedure TPlayerPopup.HoverTick(Sender: TObject);
begin
  OpenChild;
end;

procedure TPlayerPopup.Navigate(Key: Word);
var
  Index, Step: Integer;
begin
  if Entries.Count = 0 then Exit;
  case Key of
    VK_ESCAPE: ClosePlayerMenus;
    VK_RETURN, VK_SPACE: ExecuteRow;
    VK_RIGHT: OpenChild;
    VK_LEFT: if Level > 0 then Controller.CloseFrom(Level);
    VK_HOME,VK_END:
      begin
        if Key=VK_HOME then Index:=0 else Index:=Entries.Count-1;
        SelectRow(Index);
        if Key=VK_HOME then First:=0 else First:=Max(0,Entries.Count-Max(1,(ClientHeight-Padding*2) div RowHeight));
        Invalidate;
      end;
    VK_DOWN, VK_UP:
      begin
        Step := 1;
        if Key = VK_UP then Step := -1;
        Index := Selected;
        for var I := 0 to Entries.Count - 1 do
        begin
          Index := (Index + Step + Entries.Count) mod Entries.Count;
          if Entries[Index].Enabled and (Entries[Index].Caption <> '-') then Break;
        end;
        SelectRow(Index);
        if Selected < First then First := Selected;
        while (Selected >= 0) and (RowTop(Selected) + RowHeight > Height - Padding) do Inc(First);
        Invalidate;
      end;
  end;
end;

function TPlayerPopup.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  if WheelDelta > 0 then First := Max(0, First - 2)
  else if (Entries.Count > 0) and (RowTop(Entries.Count - 1) + RowHeight > Height - Padding) then
    First := Min(Max(0,Entries.Count-Max(1,(ClientHeight-Padding*2) div RowHeight)), First + 2);
  SelectRow(-1);
  Invalidate;
  Result := True;
end;

procedure ClosePlayerMenus;
begin
  if Controller <> nil then Controller.CloseFrom(0);
end;

procedure ShowPlayerMenu(OwnerForm: TForm; Items: TMenuItem; const Position: TPoint; FieldWidth: Integer; OnDismiss: TNotifyEvent);
begin
  if PlayerMenuShows(Items) then Exit;
  if Controller = nil then Controller := TMenuController.Create(Application);
  ClosePlayerMenus;
  // A rapid reopen must never leave two visible lists in the same field.
  for var Old in Controller.Retiring do begin Old.FadeTimer.Enabled:=False; ShowWindow(Old.Handle,SW_HIDE); Old.Release; end;
  Controller.Retiring.Clear;
  TPlayerPopup.CreateMenu(OwnerForm, Items, 0, Position, FieldWidth, OnDismiss);
end;

function PlayerMenuWindow: TForm;
begin
  Result := nil;
  if (Controller <> nil) and (Controller.Windows.Count > 0) then Result := Controller.Windows.Last;
end;

end.
