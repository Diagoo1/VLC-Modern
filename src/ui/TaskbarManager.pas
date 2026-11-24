unit TaskbarManager;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShlObj, Winapi.ActiveX, System.SysUtils, System.Classes,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

const
  THBN_CLICKED = $1800;
  CMD_THUMB_PREV       = 1;
  CMD_THUMB_REWIND     = 2;
  CMD_THUMB_STOP       = 3;
  CMD_THUMB_PLAYPAUSE  = 4;
  CMD_THUMB_FORWARD    = 5;
  CMD_THUMB_NEXT       = 6;
  CMD_THUMB_FULLSCREEN = 7;

type
  TTaskbarManager = class
  private
    FTaskbarList: ITaskbarList3;
    FButtonsAdded: Boolean;
    FIconPrev: HICON;
    FIconRewind: HICON;
    FIconStop: HICON;
    FIconPlay: HICON;
    FIconPause: HICON;
    FIconForward: HICON;
    FIconNext: HICON;
    FIconFullscreen: HICON;
    FCurrentPlaying: Boolean;
    FStateSent: Boolean;
    procedure CreateIcons;
    procedure DestroyIcons;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InitButtons(HWnd: HWND);
    procedure UpdatePlayState(HWnd: HWND; IsPlaying: Boolean);
    procedure UpdateProgress(HWnd: HWND; CurMs, TotalMs: Int64; Pos: Single = -1.0);
    property ButtonsAdded: Boolean read FButtonsAdded;
  end;

var
  GTaskbarManager: TTaskbarManager = nil;

function TaskbarButtonMsgId: UINT;

implementation

var
  GTaskbarMsgId: UINT = 0;

function TaskbarButtonMsgId: UINT;
begin
  if GTaskbarMsgId = 0 then
    GTaskbarMsgId := RegisterWindowMessage('TaskbarButtonCreated');
  Result := GTaskbarMsgId;
end;

{ TTaskbarManager }

constructor TTaskbarManager.Create;
begin
  inherited Create;
  FButtonsAdded := False;
  FCurrentPlaying := False;
  FIconPrev := 0;
  FIconRewind := 0;
  FIconStop := 0;
  FIconPlay := 0;
  FIconPause := 0;
  FIconForward := 0;
  FIconNext := 0;
  FIconFullscreen := 0;

  try
    CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER, ITaskbarList3, FTaskbarList);
    if FTaskbarList <> nil then
      FTaskbarList.HrInit;
  except
    FTaskbarList := nil;
  end;

  CreateIcons;
end;

destructor TTaskbarManager.Destroy;
begin
  DestroyIcons;
  FTaskbarList := nil;
  inherited Destroy;
end;

procedure TTaskbarManager.CreateIcons;

  function MakeIcon(Kind: Integer): HICON;
  var
    Bmp: TGPBitmap;
    G: TGPGraphics;
    Brush: TGPSolidBrush;
    Pen, WhitePen: TGPPen;
    Pts: array[0..2] of TGPPointF;
    H: HICON;
    Sz: Integer;
    S: Single;
    Path: TGPGraphicsPath;
  begin
    H := 0;
    // Render at 32x32 for crystal-clear, anti-aliased high-DPI thumbnail toolbar icons
    Sz := 32;
    S := Sz / 16.0;

    Bmp := TGPBitmap.Create(Sz, Sz, PixelFormat32bppPARGB);
    try
      G := TGPGraphics.Create(Bmp);
      try
        G.SetSmoothingMode(SmoothingModeAntiAlias);
        G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
        G.Clear(0);

        // Neutral glyphs with transparent backgrounds, matching our toolbar.
        Brush := TGPSolidBrush.Create(MakeColor(255, 245, 248, 250));
        try
          Pen := TGPPen.Create(MakeColor(255, 245, 248, 250), 1.6 * S);
          WhitePen := TGPPen.Create(MakeColor(255, 255, 255, 255), 1.8 * S);
          try
            Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
            WhitePen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);

            case Kind of
              1: // Previous (|<<)
                begin
                  G.FillRectangle(Brush, 2.5 * S, 3.0 * S, 2.0 * S, 10.0 * S);
                  Pts[0].X := 13.5 * S; Pts[0].Y := 3.2 * S;
                  Pts[1].X := 5.5 * S;  Pts[1].Y := 8.0 * S;
                  Pts[2].X := 13.5 * S; Pts[2].Y := 12.8 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                end;

              2: // Rewind 5s (<<)
                begin
                  // Left triangle
                  Pts[0].X := 8.0 * S;  Pts[0].Y := 3.5 * S;
                  Pts[1].X := 2.2 * S;  Pts[1].Y := 8.0 * S;
                  Pts[2].X := 8.0 * S;  Pts[2].Y := 12.5 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                  // Right triangle
                  Pts[0].X := 13.8 * S; Pts[0].Y := 3.5 * S;
                  Pts[1].X := 8.0 * S;  Pts[1].Y := 8.0 * S;
                  Pts[2].X := 13.8 * S; Pts[2].Y := 12.5 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                end;

              3: // Stop (■)
                begin
                  Path := TGPGraphicsPath.Create;
                  try
                    var R: Single := 1.8 * S;
                    Path.AddArc(3.5 * S, 3.5 * S, R * 2, R * 2, 180, 90);
                    Path.AddArc(12.5 * S - R * 2, 3.5 * S, R * 2, R * 2, 270, 90);
                    Path.AddArc(12.5 * S - R * 2, 12.5 * S - R * 2, R * 2, R * 2, 0, 90);
                    Path.AddArc(3.5 * S, 12.5 * S - R * 2, R * 2, R * 2, 90, 90);
                    Path.CloseFigure;
                    G.FillPath(Brush, Path);
                  finally
                    Path.Free;
                  end;
                end;

              4: // Play (▶)
                begin
                  Pts[0].X := 4.8 * S;  Pts[0].Y := 3.2 * S;
                  Pts[1].X := 13.2 * S; Pts[1].Y := 8.0 * S;
                  Pts[2].X := 4.8 * S;  Pts[2].Y := 12.8 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                end;

              5: // Pause (||)
                begin
                  G.FillRectangle(Brush, 4.0 * S, 3.2 * S, 2.8 * S, 9.6 * S);
                  G.FillRectangle(Brush, 9.2 * S, 3.2 * S, 2.8 * S, 9.6 * S);
                end;

              6: // Forward 5s (>>)
                begin
                  // Left triangle
                  Pts[0].X := 2.2 * S;  Pts[0].Y := 3.5 * S;
                  Pts[1].X := 8.0 * S;  Pts[1].Y := 8.0 * S;
                  Pts[2].X := 2.2 * S;  Pts[2].Y := 12.5 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                  // Right triangle
                  Pts[0].X := 8.0 * S;  Pts[0].Y := 3.5 * S;
                  Pts[1].X := 13.8 * S; Pts[1].Y := 8.0 * S;
                  Pts[2].X := 8.0 * S;  Pts[2].Y := 12.5 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                end;

              7: // Next (>>|)
                begin
                  Pts[0].X := 2.5 * S;  Pts[0].Y := 3.2 * S;
                  Pts[1].X := 10.5 * S; Pts[1].Y := 8.0 * S;
                  Pts[2].X := 2.5 * S;  Pts[2].Y := 12.8 * S;
                  G.FillPolygon(Brush, PGPPointF(@Pts[0]), 3);
                  G.FillRectangle(Brush, 11.5 * S, 3.0 * S, 2.0 * S, 10.0 * S);
                end;

              8: // Four-corner fullscreen glyph, matching the main toolbar.
                begin
                  G.DrawLine(WhitePen, 3.0 * S, 6.0 * S, 3.0 * S, 3.0 * S);
                  G.DrawLine(WhitePen, 3.0 * S, 3.0 * S, 6.0 * S, 3.0 * S);
                  G.DrawLine(WhitePen, 10.0 * S, 3.0 * S, 13.0 * S, 3.0 * S);
                  G.DrawLine(WhitePen, 13.0 * S, 3.0 * S, 13.0 * S, 6.0 * S);
                  G.DrawLine(WhitePen, 13.0 * S, 10.0 * S, 13.0 * S, 13.0 * S);
                  G.DrawLine(WhitePen, 13.0 * S, 13.0 * S, 10.0 * S, 13.0 * S);
                  G.DrawLine(WhitePen, 6.0 * S, 13.0 * S, 3.0 * S, 13.0 * S);
                  G.DrawLine(WhitePen, 3.0 * S, 13.0 * S, 3.0 * S, 10.0 * S);
                end;
            end;
          finally
            Pen.Free;
            WhitePen.Free;
          end;
        finally
          Brush.Free;
        end;
      finally
        G.Free;
      end;
      if Bmp.GetHICON(H) = Ok then
        Result := H
      else
        Result := 0;
    finally
      Bmp.Free;
    end;
  end;

begin
  FIconPrev       := MakeIcon(1);
  FIconRewind     := MakeIcon(2);
  FIconStop       := MakeIcon(3);
  FIconPlay       := MakeIcon(4);
  FIconPause      := MakeIcon(5);
  FIconForward    := MakeIcon(6);
  FIconNext       := MakeIcon(7);
  FIconFullscreen := MakeIcon(8);
end;

procedure TTaskbarManager.DestroyIcons;
begin
  if FIconPrev <> 0 then begin DestroyIcon(FIconPrev); FIconPrev := 0; end;
  if FIconRewind <> 0 then begin DestroyIcon(FIconRewind); FIconRewind := 0; end;
  if FIconStop <> 0 then begin DestroyIcon(FIconStop); FIconStop := 0; end;
  if FIconPlay <> 0 then begin DestroyIcon(FIconPlay); FIconPlay := 0; end;
  if FIconPause <> 0 then begin DestroyIcon(FIconPause); FIconPause := 0; end;
  if FIconForward <> 0 then begin DestroyIcon(FIconForward); FIconForward := 0; end;
  if FIconNext <> 0 then begin DestroyIcon(FIconNext); FIconNext := 0; end;
  if FIconFullscreen <> 0 then begin DestroyIcon(FIconFullscreen); FIconFullscreen := 0; end;
end;

procedure TTaskbarManager.InitButtons(HWnd: HWND);
var
  Btns: array[0..6] of THUMBBUTTON;
  HR: HRESULT;
begin
  if (FTaskbarList = nil) or (HWnd = 0) then Exit;

  FillChar(Btns, SizeOf(Btns), 0);

  // Button 0: Previous Track (|<<)
  Btns[0].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[0].iId := CMD_THUMB_PREV;
  Btns[0].hIcon := FIconPrev;
  Btns[0].dwFlags := THBF_ENABLED;
  StringToWideChar('Previous track (P)', Btns[0].szTip, 260);

  // Button 1: Rewind 5s (<<)
  Btns[1].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[1].iId := CMD_THUMB_REWIND;
  Btns[1].hIcon := FIconRewind;
  Btns[1].dwFlags := THBF_ENABLED;
  StringToWideChar('Back 10 seconds', Btns[1].szTip, 260);

  // Button 2: Stop (■)
  Btns[2].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[2].iId := CMD_THUMB_STOP;
  Btns[2].hIcon := FIconStop;
  Btns[2].dwFlags := THBF_ENABLED;
  StringToWideChar('Stop (S)', Btns[2].szTip, 260);

  // Button 3: Play / Pause (▶ / ||)
  Btns[3].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[3].iId := CMD_THUMB_PLAYPAUSE;
  if FCurrentPlaying then
  begin
    Btns[3].hIcon := FIconPause;
    StringToWideChar('Pause (Space)', Btns[3].szTip, 260);
  end
  else
  begin
    Btns[3].hIcon := FIconPlay;
    StringToWideChar('Play (Space)', Btns[3].szTip, 260);
  end;
  Btns[3].dwFlags := THBF_ENABLED;

  // Button 4: Forward 5s (>>)
  Btns[4].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[4].iId := CMD_THUMB_FORWARD;
  Btns[4].hIcon := FIconForward;
  Btns[4].dwFlags := THBF_ENABLED;
  StringToWideChar('Forward 10 seconds', Btns[4].szTip, 260);

  // Button 5: Next Track (>>|)
  Btns[5].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[5].iId := CMD_THUMB_NEXT;
  Btns[5].hIcon := FIconNext;
  Btns[5].dwFlags := THBF_ENABLED;
  StringToWideChar('Next track (N)', Btns[5].szTip, 260);

  // Button 6: Fullscreen Toggle (⛶)
  Btns[6].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[6].iId := CMD_THUMB_FULLSCREEN;
  Btns[6].hIcon := FIconFullscreen;
  Btns[6].dwFlags := THBF_ENABLED;
  StringToWideChar('Fullscreen (F)', Btns[6].szTip, 260);

  HR := FTaskbarList.ThumbBarAddButtons(HWnd, 7, @Btns[0]);
  if Succeeded(HR) then
  begin
    FButtonsAdded := True;
    FStateSent := False;
  end;
end;

procedure TTaskbarManager.UpdatePlayState(HWnd: HWND; IsPlaying: Boolean);
var
  Btn: THUMBBUTTON;
begin
  if FStateSent and (FCurrentPlaying = IsPlaying) then Exit;
  FCurrentPlaying := IsPlaying;
  if (FTaskbarList = nil) or (HWnd = 0) or not FButtonsAdded then Exit;

  FillChar(Btn, SizeOf(Btn), 0);
  Btn.dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btn.iId := CMD_THUMB_PLAYPAUSE;
  Btn.dwFlags := THBF_ENABLED;

  if IsPlaying then
  begin
    Btn.hIcon := FIconPause;
    StringToWideChar('Pause (Space)', Btn.szTip, 260);
  end
  else
  begin
    Btn.hIcon := FIconPlay;
    StringToWideChar('Play (Space)', Btn.szTip, 260);
  end;

  FStateSent := Succeeded(FTaskbarList.ThumbBarUpdateButtons(HWnd, 1, @Btn));
end;

procedure TTaskbarManager.UpdateProgress(HWnd: HWND; CurMs, TotalMs: Int64; Pos: Single = -1.0);
var
  SafeCur, SafeTotal: UInt64;
begin
  if (FTaskbarList = nil) or (HWnd = 0) then Exit;

  if (TotalMs > 0) and (CurMs >= 0) then
  begin
    SafeTotal := TotalMs;
    if CurMs > TotalMs then
      SafeCur := SafeTotal
    else
      SafeCur := CurMs;

    if FCurrentPlaying then FTaskbarList.SetProgressState(HWnd, TBPF_NORMAL)
    else FTaskbarList.SetProgressState(HWnd, TBPF_PAUSED);
    FTaskbarList.SetProgressValue(HWnd, SafeCur, SafeTotal);
  end
  else if (Pos >= 0.0) and (Pos <= 1.0) then
  begin
    if FCurrentPlaying then FTaskbarList.SetProgressState(HWnd, TBPF_NORMAL)
    else FTaskbarList.SetProgressState(HWnd, TBPF_PAUSED);
    FTaskbarList.SetProgressValue(HWnd, Round(Pos * 1000.0), 1000);
  end
  else
  begin
    FTaskbarList.SetProgressState(HWnd, TBPF_NOPROGRESS);
  end;
end;

initialization

finalization
  if GTaskbarManager <> nil then
  begin
    var M := GTaskbarManager;
    GTaskbarManager := nil;
    M.Free;
  end;

end.
