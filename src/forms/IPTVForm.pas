unit IPTVForm;

interface

uses SettingsStore,
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.ShellAPI, System.SysUtils, System.Classes, System.IniFiles,
  System.StrUtils, System.Generics.Collections, System.Types, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.Clipbrd, CurvedControls, PlaylistSource, ProgrammeGuide;

type
  TIPTVLibraryGrid = class(TDrawGrid)
  private
    FWheelDelta: Integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  end;

  TIPTVScrollBar = class(TCustomControl)
  private
    FTopRow, FVisibleRows, FTotalRows: Integer;
    FGrabOffset: Integer;
    FDragging: Boolean;
    FLastDragTick: UInt64;
    FDragTimer: TTimer;
    FOnScroll: TNotifyEvent;
    procedure FlushDrag(Sender: TObject);
    function ThumbRect: TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CaptureChanged(var Msg: TMessage); message WM_CAPTURECHANGED;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateRows(TopRow, VisibleRows, TotalRows: Integer);
  end;

  TIPTVListBox = class(TListBox)
  private
    FScroll: TIPTVScrollBar;
    FUpdatingScroll: Boolean;
    FWheelDelta: Integer;
    FRowBuffer: TBitmap;
    procedure UpdateScroll;
    procedure ScrollChanged(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    destructor Destroy; override;
    procedure InstallScroll;
    procedure ReserveScrollGutter(var Row: TRect);
  end;

  TChannelHealth = (chUnknown, chOnline, chOffline, chChecking);

  TIPTVChannel = class
  public
    Name: string;
    Group: string;
    StreamUrl: string;
    MediaKind: string;
    HistoryKey: string;
    LogoUrl: string;
    TvgId: string;
    IsFavorite: Boolean;
    Health: TChannelHealth;
    HealthLatencyMs: Integer;
    HealthCheckedAt: Cardinal;
  end;

  TFrmIPTV = class(TForm)
    pnlTop: TPanel;
    lblSearch: TLabel;
    lblChannelCount: TLabel;
    edtSearch: TEdit;
    btnSwitchServer: TPlayerTextButton;
    btnAddM3U: TPlayerTextButton;
    btnConnectXtream: TPlayerTextButton;
    btnOpenLocalM3U: TPlayerTextButton;
    btnRefresh: TPlayerTextButton;
    btnExportM3U: TPlayerTextButton;
    pnlCategories: TPanel;
    lblCatTitle: TLabel;
    lstCategories: TIPTVListBox;
    pnlMain: TPanel;
    lstChannels: TIPTVListBox;
    pnlChannelInfo: TPanel;
    lblInfoName: TLabel;
    lblInfoEPG: TLabel;
    lblInfoUrl: TLabel;
    lblInfoBadge: TLabel;
    pnlBottom: TPanel;
    btnWatch: TPlayerTextButton;
    btnFav: TPlayerTextButton;
    btnCopyUrl: TPlayerTextButton;
    btnEPG: TPlayerTextButton;
    btnCheckHealth: TPlayerTextButton;
    btnRecordStream: TPlayerTextButton;
    btnClose: TPlayerTextButton;
    OpenDialogM3U: TOpenDialog;
    SaveDialogExport: TSaveDialog;

    // IPTV Connection Hub / Welcome Portal
    pnlWelcomeHub: TPanel;
    pnlHubCard: TPanel;
    lblHubTitle: TLabel;
    lblHubSubtitle: TLabel;
    grpConnType: TGroupBox;
    rbXtream: TRadioButton;
    rbStalkerMac: TRadioButton;
    rbM3UUrl: TRadioButton;
    rbLocalFile: TRadioButton;
    rbDemo: TRadioButton;
    grpCredentials: TGroupBox;
    lblServerUrl: TLabel;
    edtServerUrl: TEdit;
    btnBrowseFile: TPlayerTextButton;
    lblUsernameOrMac: TLabel;
    edtUsernameOrMac: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    chkRememberPortal: TPlayerCheckBox;
    lblPortalHint: TLabel;
    btnConnectPortal: TPlayerTextButton;
    btnCancelHub: TPlayerTextButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LayoutStudio(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure lstCategoriesClick(Sender: TObject);
    procedure lstChannelsClick(Sender: TObject);
    procedure lstChannelsDblClick(Sender: TObject);
    procedure btnWatchClick(Sender: TObject);
    procedure btnFavClick(Sender: TObject);
    procedure btnCopyUrlClick(Sender: TObject);
    procedure btnEPGClick(Sender: TObject);
    procedure btnCheckHealthClick(Sender: TObject);
    procedure btnRecordStreamClick(Sender: TObject);
    procedure CheckStreamHealth(Channel: TIPTVChannel);
    procedure CheckAllStreamsHealth;
    procedure btnExportM3UClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAddM3UClick(Sender: TObject);
    procedure btnConnectXtreamClick(Sender: TObject);
    procedure btnOpenLocalM3UClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure lstCategoriesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstChannelsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstChannelsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rbConnTypeClick(Sender: TObject);
    procedure btnBrowseFileClick(Sender: TObject);
    procedure btnConnectPortalClick(Sender: TObject);
    procedure btnCancelHubClick(Sender: TObject);
    procedure btnSwitchServerClick(Sender: TObject);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  private
    FChannels: TObjectList<TIPTVChannel>;
    FFilteredChannels: TList<TIPTVChannel>;
    FCategories: TStringList;
    FLastM3USource: string;
    FGuide: TProgrammeGuide;
    FGuideURL: string;
    FLoadingGuide: Boolean;
    FStalkerPortal, FStalkerMAC: string;
    FRequest: IPlaylistRequest;
    FRequestTimer: TTimer;
    FRequestURL: string;
    FCatalogCacheFile, FCachedCatalog, FLastLoadedCacheFile: string;
    FLastCatalogInteraction: UInt64;
    FLogoCache: TObjectDictionary<string, TGPImage>;
    FLogoPending: TDictionary<string, Boolean>;
    FArtworkCleanupStarted: Boolean;
    FLogoWindowAlive: TFunc<Boolean>;
    FCloseLogoWindow: TProc;
    FCategoryCard, FChannelCard: TModernCardPanel;
    FChannelHeading: TLabel;
    FLibraryGrid: TDrawGrid;
    FLibraryRail: TModernCardPanel;
    FLibraryScroll: TIPTVScrollBar;
    FLibrarySections: array[0..4] of TModernVectorButton;
    FGridToggle: TModernVectorButton;
    FRecentChannels: TStringList;
    FHomeHistory: Boolean;
    FHomeFavoritesOnly: Boolean;
    FHomeHero: TModernCardPanel;
    FHeroTitle: TLabel;
    FHomeEmpty: TLabel;
    FHeroPlay, FRecentTab, FFavoriteTab: TPlayerTextButton;
    FFeaturedChannel: TIPTVChannel;
    FHeroArt: TPaintBox;
    FSection: Integer;
    FLastAppliedSection: Integer;
    FLastAppliedCatIndex: Integer;
    FClosingForm: Boolean;
    FConnectingSince: UInt64;
    FConnectionStatus: TLabel;
    procedure ChangeLibrarySection(Sender: TObject);
    procedure ChangeHomeShelf(Sender: TObject);
    procedure PlayFeatured(Sender: TObject);
    procedure PaintFeaturedArt(Sender: TObject);
    procedure PlayChannel(Ch: TIPTVChannel);
    procedure RememberChannel(Channel: TIPTVChannel);
    function RecentRank(Channel: TIPTVChannel): Integer;
    procedure LibraryMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ToggleLibraryView(Sender: TObject);
    procedure LayoutLibrary;
    procedure UpdateLibraryScroll(Sender: TObject);
    procedure ScrollLibrary(Sender: TObject);
    procedure DrawLibraryCell(Sender: TObject; ACol, ARow: Longint;
      Cell: TRect; State: TGridDrawState);
    procedure SelectLibraryCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
    procedure EnsureChannelLogoAsync(const AUrl: string);
    procedure LoadCatalogCache(const SourceKey: string);
    procedure BeginStalker(const Portal, MAC: string);
    procedure DownloadTick(Sender: TObject);
    procedure SetConnecting(Value: Boolean);
    procedure DragWindowSurface(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure ShowConnectionHub(Value: Boolean);
    procedure LoadPortalProfile(const Source: string = '');
    procedure SavePortalProfile;
    procedure LoadDefaultStreams;
    procedure ParseM3UContent(const AContent: string);
    procedure ParseM3UFile(const AFileName: string);
    procedure DownloadAndParseM3U(const AUrl: string);
    procedure RebuildCategories;
    procedure FilterChannels;
    procedure UpdateChannelInfoPanel;
    procedure LoadFavorites;
    procedure SaveFavorites;
    function GetIniPath: string;
    function SelectedChannel: TIPTVChannel;
  protected
    procedure CreateWnd; override;
  public
    procedure AfterConstruction; override;
    procedure SelectConnectionSource(Kind: Integer);
    procedure OpenConnectionSource(Kind: Integer);
  private
    FHubShell: TModernCardPanel;
  end;

var
  FrmIPTV: TFrmIPTV;

implementation

uses Winapi.Dwmapi, PlayerPaths, PlayerDialogs, PlayerLanguage, MainForm, System.Net.HttpClient, System.NetEncoding, System.DateUtils, System.IOUtils, System.RegularExpressions, System.Math, System.Hash, System.Generics.Defaults;

{$R *.dfm}

procedure TIPTVLibraryGrid.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := (Params.Style and not (WS_VSCROLL or WS_HSCROLL)) or WS_CLIPCHILDREN;
end;

procedure TIPTVLibraryGrid.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_ERASEBKGND then
  begin
    Message.Result := 1;
    Exit;
  end;
  if (Message.Msg = WM_MOUSEWHEEL) and (RowCount > 0) then
  begin
    if Owner is TFrmIPTV then TFrmIPTV(Owner).FLastCatalogInteraction := GetTickCount64;
    Inc(FWheelDelta, SmallInt(HiWord(Message.WParam)));
    var Steps := FWheelDelta div WHEEL_DELTA;
    FWheelDelta := FWheelDelta mod WHEEL_DELTA;
    if Steps <> 0 then
    begin
      var VisRows := Max(1, ClientHeight div Max(1, DefaultRowHeight));
      TopRow := EnsureRange(TopRow - Steps, 0, Max(0, RowCount - VisRows));
      if Assigned(OnTopLeftChanged) then OnTopLeftChanged(Self);
      UpdateWindow(Handle);
    end;
    Message.Result := 0;
    Exit;
  end;
  inherited;
end;

constructor TIPTVScrollBar.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse];
  DoubleBuffered := True;
  ParentDoubleBuffered := False;
  FDragTimer := TTimer.Create(Self);
  FDragTimer.Enabled := False;
  FDragTimer.Interval := 16;
  FDragTimer.OnTimer := FlushDrag;
end;

procedure TIPTVScrollBar.FlushDrag(Sender: TObject);
begin
  FDragTimer.Enabled := False;
  if Assigned(FOnScroll) then FOnScroll(Self);
end;

procedure TIPTVScrollBar.UpdateRows(TopRow, VisibleRows, TotalRows: Integer);
begin
  if (FTopRow = TopRow) and (FVisibleRows = VisibleRows) and (FTotalRows = TotalRows) then Exit;
  if not FDragging then FTopRow := TopRow;
  FVisibleRows := VisibleRows;
  FTotalRows := TotalRows;
  Invalidate;
end;

function TIPTVScrollBar.ThumbRect: TRect;
begin
  var Pad := MulDiv(4, CurrentPPI, 96);
  var Span := Max(0, ClientHeight - 2 * Pad);
  var Limit := FTotalRows - FVisibleRows;
  if (Limit <= 0) or (Span = 0) then Exit(TRect.Empty);
  var ThumbHeight := Min(Span, Max(MulDiv(26, CurrentPPI, 96),
    MulDiv(Span, FVisibleRows, FTotalRows)));
  var Y := Pad + MulDiv(EnsureRange(FTopRow, 0, Limit), Span - ThumbHeight, Limit);
  Result := Rect(Pad, Y, ClientWidth - Pad, Y + ThumbHeight);
end;

procedure TIPTVScrollBar.Paint;
begin
  Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(ClientRect);
  var Thumb := ThumbRect;
  if Thumb.IsEmpty then Exit;
  var G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    var Track := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), MulDiv(2, CurrentPPI, 96));
    try
      var Pad := MulDiv(4, CurrentPPI, 96);
      G.DrawLine(Track, ClientWidth / 2, Single(Pad), ClientWidth / 2, ClientHeight - Pad);
    finally
      Track.Free;
    end;
    var ThumbColor := DP_COLOR_SCROLL;
    if FDragging then ThumbColor := DP_COLOR_ACCENT
    else if MouseInClient then ThumbColor := DP_COLOR_MUTED;
    var Pen := TGPPen.Create(MakeGDIColor(ThumbColor), Thumb.Width);
    try
      Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
      G.DrawLine(Pen, ClientWidth / 2, Thumb.Top + Thumb.Width / 2,
        ClientWidth / 2, Thumb.Bottom - Thumb.Width / 2);
    finally
      Pen.Free;
    end;
  finally
    G.Free;
  end;
end;

procedure TIPTVScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button <> mbLeft then Exit;
  var Thumb := ThumbRect;
  if Thumb.IsEmpty then Exit;
  if (Y >= Thumb.Top) and (Y < Thumb.Bottom) then
  begin
    FGrabOffset := Y - Thumb.Top;
    FDragging := True;
    Invalidate;
  end
  else
  begin
    if Y < Thumb.Top then Dec(FTopRow, FVisibleRows)
    else Inc(FTopRow, FVisibleRows);
    FTopRow := EnsureRange(FTopRow, 0, FTotalRows - FVisibleRows);
    if Assigned(FOnScroll) then FOnScroll(Self);
    Invalidate;
  end;
end;

procedure TIPTVScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if not FDragging or not (ssLeft in Shift) then Exit;
  var Pad := MulDiv(4, CurrentPPI, 96);
  var Travel := ClientHeight - 2 * Pad - ThumbRect.Height;
  if Travel <= 0 then Exit;
  var Row := MulDiv(EnsureRange(Y - FGrabOffset - Pad, 0, Travel), FTotalRows - FVisibleRows, Travel);
  if Row = FTopRow then Exit;
  FTopRow := Row;
  Invalidate;
  Update;
  var NowTick := GetTickCount64;
  if NowTick - FLastDragTick >= 16 then
  begin
    FLastDragTick := NowTick;
    FDragTimer.Enabled := False;
    if Assigned(FOnScroll) then FOnScroll(Self);
  end
  else if not FDragTimer.Enabled then
    FDragTimer.Enabled := True;
end;

procedure TIPTVScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FDragging then
  begin
    MouseMove([ssLeft], X, Y);
    if FDragTimer.Enabled then FlushDrag(nil);
    FDragging := False;
    Invalidate;
  end;
  inherited;
end;

procedure TIPTVScrollBar.CaptureChanged(var Msg: TMessage);
begin
  inherited;
  if not FDragging then Exit;
  if FDragTimer.Enabled then FlushDrag(nil);
  FDragging := False;
  Invalidate;
  if Parent <> nil then Parent.Invalidate;
end;

procedure TIPTVScrollBar.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TIPTVScrollBar.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TIPTVListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := (Params.Style and not WS_VSCROLL) or WS_CLIPCHILDREN;
end;

destructor TIPTVListBox.Destroy;
begin
  FreeAndNil(FRowBuffer);
  inherited;
end;

procedure TIPTVListBox.InstallScroll;
begin
  FScroll := TIPTVScrollBar.Create(Self);
  if Parent <> nil then FScroll.Parent := Parent else FScroll.Parent := Self;
  FScroll.FOnScroll := ScrollChanged;
  UpdateScroll;
end;

procedure TIPTVListBox.UpdateScroll;
begin
  if FUpdatingScroll or (FScroll = nil) or not HandleAllocated or
     (csDestroying in ComponentState) then Exit;
  FUpdatingScroll := True;
  try
    if (GetWindowLong(Handle, GWL_STYLE) and WS_VSCROLL) <> 0 then ShowScrollBar(Handle, SB_VERT, False);
    var Rows := Max(1, ClientHeight div Max(1, ItemHeight));
    var Limit := Max(0, Count - Rows);
    var BarWidth := MulDiv(16, CurrentPPI, 96);
    var ShowBar := Visible and (Limit > 0);
    if (FScroll.Parent <> Self) and (Parent <> nil) then
    begin
      var BaseMargin := MulDiv(8, CurrentPPI, 96);
      if ShowBar then
      begin
        if PlayerIsArabic then
        begin
          if Margins.Left <> BaseMargin + BarWidth then Margins.Left := BaseMargin + BarWidth;
        end
        else
        begin
          if Margins.Right <> BaseMargin + BarWidth then Margins.Right := BaseMargin + BarWidth;
        end;
      end
      else
      begin
        if Margins.Left <> BaseMargin then Margins.Left := BaseMargin;
        if Margins.Right <> BaseMargin then Margins.Right := BaseMargin;
      end;
      var BarX := BoundsRect.Right;
      if PlayerIsArabic then BarX := BoundsRect.Left - BarWidth;
      if (FScroll.Left <> BarX) or (FScroll.Top <> Top) or (FScroll.Width <> BarWidth) or (FScroll.Height <> Height) then
        FScroll.SetBounds(BarX, Top, BarWidth, Height);
    end
    else
    begin
      var BarX := ClientWidth - BarWidth;
      if PlayerIsArabic then BarX := 0;
      if (FScroll.Left <> BarX) or (FScroll.Top <> 0) or (FScroll.Width <> BarWidth) or (FScroll.Height <> ClientHeight) then
        FScroll.SetBounds(BarX, 0, BarWidth, ClientHeight);
    end;
    FScroll.UpdateRows(Max(0, TopIndex), Rows, Count);
    if FScroll.Visible <> ShowBar then
    begin
      FScroll.Visible := ShowBar;
      if ShowBar then FScroll.BringToFront;
    end;
  finally
    FUpdatingScroll := False;
  end;
end;

procedure TIPTVListBox.ScrollChanged(Sender: TObject);
begin
  if FUpdatingScroll then Exit;
  if Owner is TFrmIPTV then TFrmIPTV(Owner).FLastCatalogInteraction := GetTickCount64;
  if TopIndex <> FScroll.FTopRow then
  begin
    TopIndex := FScroll.FTopRow;
    UpdateWindow(Handle);
  end;
end;

procedure TIPTVListBox.ReserveScrollGutter(var Row: TRect);
begin
  if (FScroll = nil) or not FScroll.Visible or (FScroll.Parent <> Self) then Exit;
  if PlayerIsArabic then Inc(Row.Left, FScroll.Width)
  else Dec(Row.Right, FScroll.Width);
end;

procedure TIPTVListBox.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_ERASEBKGND then
  begin
    // Owner draw only fills existing rows. Paint only the uncovered viewport below the last row.
    var ItemH := Max(1, ItemHeight);
    var VisibleRows := Max(0, Count - TopIndex);
    var UncoveredTop := Min(ClientHeight, VisibleRows * ItemH);
    if UncoveredTop < ClientHeight then
    begin
      var Background := CreateSolidBrush(ColorToRGB(DP_COLOR_SURFACE));
      try
        var Bounds := Rect(0, UncoveredTop, ClientWidth, ClientHeight);
        FillRect(HDC(Message.WParam), Bounds, Background);
      finally
        DeleteObject(Background);
      end;
    end;
    Message.Result := 1;
    Exit;
  end;
  if (Message.Msg = WM_STYLECHANGING) and (Message.WParam = WPARAM(GWL_STYLE)) and (Message.LParam <> 0) then
    PStyleStruct(Message.LParam)^.styleNew := PStyleStruct(Message.LParam)^.styleNew and not WS_VSCROLL;
  if (Message.Msg = CN_DRAWITEM) and (Message.LParam <> 0) then
  begin
    var Draw := PDrawItemStruct(Message.LParam);
    var OriginalState := Draw^.itemState;
    var ItemBounds := Draw^.rcItem;
    var TargetDC := Draw^.hDC;
    var Buffer := FRowBuffer;
    Draw^.itemState := OriginalState and not ODS_FOCUS;
    try
      // Keep the native item coordinates for the non-virtual category list.
      if (Style = lbVirtualOwnerDraw) and (TargetDC <> 0) and not ItemBounds.IsEmpty then
      begin
        if Buffer = nil then
        begin
          FRowBuffer := TBitmap.Create;
          Buffer := FRowBuffer;
        end;
        if (Buffer.Width <> ItemBounds.Width) or (Buffer.Height <> ItemBounds.Height) then
          Buffer.SetSize(ItemBounds.Width, ItemBounds.Height);
        Draw^.hDC := Buffer.Canvas.Handle;
        Draw^.rcItem := Rect(0, 0, Buffer.Width, Buffer.Height);
      end;
      inherited;
      if Draw^.hDC <> TargetDC then
        BitBlt(TargetDC, ItemBounds.Left, ItemBounds.Top, Buffer.Width, Buffer.Height,
          Draw^.hDC, 0, 0, SRCCOPY);
    finally
      Draw^.itemState := OriginalState;
      Draw^.hDC := TargetDC;
      Draw^.rcItem := ItemBounds;
    end;
    Exit;
  end;
  if (Message.Msg = WM_MOUSEWHEEL) and (FScroll <> nil) and FScroll.Visible then
  begin
    if Owner is TFrmIPTV then TFrmIPTV(Owner).FLastCatalogInteraction := GetTickCount64;
    Inc(FWheelDelta, SmallInt(HiWord(Message.WParam)));
    var Steps := FWheelDelta div WHEEL_DELTA;
    FWheelDelta := FWheelDelta mod WHEEL_DELTA;
    if Steps <> 0 then
    begin
      TopIndex := EnsureRange(TopIndex - Steps * 3, 0, Max(0, Count - FScroll.FVisibleRows));
      UpdateScroll;
      UpdateWindow(Handle);
    end;
    Message.Result := 0;
    Exit;
  end;
  inherited;
  case Message.Msg of
    WM_SIZE, WM_KEYDOWN, WM_VSCROLL, LB_SETCURSEL:
      UpdateScroll;
    LB_SETTOPINDEX:
      if (FScroll = nil) or not FScroll.FDragging then UpdateScroll;
  end;
end;

procedure TFrmIPTV.CreateWnd;
var
  DisableTransitions: BOOL;
begin
  inherited;
  DisableTransitions := True;
  DwmSetWindowAttribute(Handle, DWMWA_TRANSITIONS_FORCEDISABLED,
    @DisableTransitions, SizeOf(DisableTransitions));
end;

procedure TFrmIPTV.AfterConstruction;
  function MakeListCard(Host: TWinControl): TModernCardPanel;
  begin
    Result := TModernCardPanel.Create(Self);
    Result.Parent := Host;
    Result.AlignWithMargins := True;
    Result.Margins.SetBounds(6, 4, 6, 6);
    Result.Align := alClient;
    Result.CardColor := DP_COLOR_SURFACE;
    Result.BorderColor := DP_COLOR_BORDER;
    Result.CornerRadius := 12;
    Result.OnMouseDown := DragWindowSurface;
  end;
begin
  inherited;
  lstCategories.DoubleBuffered := False;
  lstCategories.ParentDoubleBuffered := False;
  lstChannels.DoubleBuffered := False;
  lstChannels.ParentDoubleBuffered := False;
  pnlTop.ParentBackground := False;
  pnlBottom.ParentBackground := False;
  pnlMain.ParentBackground := False;
  pnlCategories.ParentBackground := False;
  pnlChannelInfo.ParentBackground := False;
  FLastAppliedSection := -1;
  FLastAppliedCatIndex := -1;
  ApplyPlayerAppearance(Self);
  pnlTop.OnMouseDown := DragWindowSurface;
  pnlMain.OnMouseDown := DragWindowSurface;
  pnlBottom.OnMouseDown := DragWindowSurface;
  pnlCategories.OnMouseDown := DragWindowSurface;
  pnlChannelInfo.OnMouseDown := DragWindowSurface;
  pnlWelcomeHub.OnMouseDown := DragWindowSurface;
  pnlHubCard.OnMouseDown := DragWindowSurface;
  FCategoryCard := MakeListCard(pnlCategories);
  FChannelCard := MakeListCard(pnlMain);
  lblCatTitle.Parent := FCategoryCard;
  lstCategories.Parent := FCategoryCard;
  lstCategories.AlignWithMargins := True;
  lstCategories.Margins.SetBounds(8, 37, 8, 8);
  lstCategories.Align := alClient;
  lstChannels.Parent := FChannelCard;
  lstChannels.AlignWithMargins := True;
  lstChannels.Margins.SetBounds(8, 37, 8, 6);
  lstCategories.InstallScroll;
  lstChannels.InstallScroll;
  pnlChannelInfo.Parent := FChannelCard;
  pnlChannelInfo.AlignWithMargins := True;
  pnlChannelInfo.Margins.SetBounds(8, 0, 8, 8);
  FChannelHeading := TLabel.Create(Self);
  FChannelHeading.Parent := FChannelCard;
  FChannelHeading.Caption := Translate('Channels');
  FChannelHeading.Font.Assign(lblCatTitle.Font);
  FChannelHeading.AutoSize := False;
  FChannelHeading.OnMouseDown := DragWindowSurface;
  lblCatTitle.OnMouseDown := DragWindowSurface;
  FLibraryGrid := TIPTVLibraryGrid.Create(Self);
  FLibraryGrid.Parent := FChannelCard;
  FLibraryGrid.Align := alClient;
  FLibraryGrid.AlignWithMargins := True;
  FLibraryGrid.Margins.SetBounds(8, 37, 8, 6);
  FLibraryGrid.FixedCols := 0;
  FLibraryGrid.FixedRows := 0;
  FLibraryGrid.BorderStyle := bsNone;
  FLibraryGrid.Color := DP_COLOR_SURFACE;
  FLibraryGrid.StyleElements := [];
  FLibraryGrid.Options := [];
  FLibraryGrid.ScrollBars := ssNone;
  FLibraryGrid.DoubleBuffered := True;
  FLibraryGrid.DefaultDrawing := False;
  FLibraryGrid.OnDrawCell := DrawLibraryCell;
  FLibraryGrid.OnSelectCell := SelectLibraryCell;
  FLibraryGrid.OnDblClick := lstChannelsDblClick;
  FLibraryGrid.OnMouseUp := LibraryMouseUp;
  FLibraryGrid.OnTopLeftChanged := UpdateLibraryScroll;
  FLibraryGrid.Visible := False;
  FLibraryScroll := TIPTVScrollBar.Create(Self);
  FLibraryScroll.Parent := FChannelCard;
  FLibraryScroll.FOnScroll := ScrollLibrary;
  FGridToggle := TModernVectorButton.Create(Self);
  FGridToggle.Parent := FChannelCard;
  TModernVectorButton(FGridToggle).CaptionPointSize := 8.25;
  FGridToggle.IconKind := ikGrid;
  FGridToggle.Hint := Translate('Grid view');
  FGridToggle.ShowHint := True;
  FGridToggle.OnClick := ToggleLibraryView;
  FLibraryRail := TModernCardPanel.Create(Self);
  FLibraryRail.Visible := not pnlWelcomeHub.Visible;
  FLibraryRail.Parent := Self;
  FLibraryRail.CardColor := DP_COLOR_BG;
  FLibraryRail.BorderColor := DP_COLOR_BORDER;
  FLibraryRail.CornerRadius := 12;
  FLibraryRail.OnMouseDown := DragWindowSurface;
  for var Index := 0 to High(FLibrarySections) do
  begin
    var Button := TModernVectorButton.Create(Self);
    FLibrarySections[Index] := Button;
    Button.Parent := FLibraryRail;
    Button.Tag := Index;
    Button.ShowHint := True;
    TModernVectorButton(Button).CaptionPointSize := 8.25;
    Button.OnClick := ChangeLibrarySection;
  end;
  FLibrarySections[0].Caption := Translate('IPTV Home');
  FLibrarySections[1].Caption := Translate('Live TV');
  FLibrarySections[2].Caption := Translate('Movies / VOD');
  FLibrarySections[3].Caption := Translate('Series');
  FLibrarySections[4].Caption := Translate('Favorites');
  for var Index := 0 to High(FLibrarySections) do
    FLibrarySections[Index].Hint := FLibrarySections[Index].Caption;
  FLibrarySections[0].IconKind := ikHome;
  FLibrarySections[1].IconKind := ikTV;
  FLibrarySections[2].IconKind := ikFilm;
  FLibrarySections[3].IconKind := ikSeries;
  FLibrarySections[4].IconKind := ikStar;
  FHomeHero := MakeListCard(FChannelCard);
  FHomeHero.Align := alNone;
  FHomeHero.CardColor := DP_COLOR_ELEVATED;
  FHomeHero.Visible := False;
  FHeroTitle := TLabel.Create(Self);
  FHeroTitle.Parent := FHomeHero;
  FHeroTitle.AutoSize := False;
  FHeroTitle.ShowAccelChar := False;
  FHeroTitle.EllipsisPosition := epEndEllipsis;
  FHeroTitle.Font.Name := PlayerUIFont;
  FHeroTitle.Font.Size := 15;
  FHeroTitle.Font.Color := DP_COLOR_TEXT;
  FHeroTitle.OnMouseDown := DragWindowSurface;
  FHeroArt := TPaintBox.Create(Self);
  FHeroArt.Parent := FHomeHero;
  FHeroArt.OnPaint := PaintFeaturedArt;
  FHeroArt.OnMouseDown := DragWindowSurface;
  FHeroPlay := TPlayerTextButton.Create(Self);
  FHeroPlay.Parent := FHomeHero;
  FHeroPlay.Caption := Translate('Continue watching');
  FHeroPlay.IsAccent := True;
  FHeroPlay.OnClick := PlayFeatured;
  FRecentTab := TPlayerTextButton.Create(Self);
  FRecentTab.Parent := FChannelCard;
  FRecentTab.Caption := Translate('Recently viewed');
  FRecentTab.OnClick := ChangeHomeShelf;
  FRecentTab.Visible := False;
  FFavoriteTab := TPlayerTextButton.Create(Self);
  FFavoriteTab.Parent := FChannelCard;
  FFavoriteTab.Caption := Translate('Favorites');
  FFavoriteTab.OnClick := ChangeHomeShelf;
  FFavoriteTab.Visible := False;
  FHomeEmpty := TLabel.Create(Self);
  FHomeEmpty.Parent := FChannelCard;
  FHomeEmpty.AutoSize := False;
  FHomeEmpty.Alignment := taCenter;
  FHomeEmpty.Font.Name := PlayerUIFont;
  FHomeEmpty.Font.Size := 10;
  FHomeEmpty.Font.Color := DP_COLOR_TEXT;
  FHomeEmpty.Visible := False;
  TModernVectorButton(FLibrarySections[0]).IsActive := True;
  btnWatch.Caption := Translate('Play');
  btnSwitchServer.Caption := Translate('Sources');
  btnCopyUrl.Caption := Translate('Copy URL');
  btnEPG.Caption := Translate('TV Guide');
  btnCheckHealth.Caption := Translate('Check Stream');
  btnRecordStream.Caption := Translate('Record');
  lblInfoName.AutoSize := False;
  lblInfoName.EllipsisPosition := epEndEllipsis;
  lblInfoEPG.AutoSize := False;
  lblInfoEPG.EllipsisPosition := epEndEllipsis;
  lblInfoUrl.AutoSize := False;
  lblInfoUrl.EllipsisPosition := epEndEllipsis;
  lblInfoBadge.AutoSize := False;
  lblInfoBadge.EllipsisPosition := epEndEllipsis;
  if PlayerIsArabic then
  begin
    FHeroTitle.Alignment := taRightJustify;
    btnAddM3U.Caption := Translate('M3U URL');
    btnConnectXtream.Caption := 'Xtream';
    btnOpenLocalM3U.Caption := Translate('Open File');
    btnExportM3U.Caption := Translate('Export');
    for var ActionButton in TArray<TPlayerTextButton>.Create(btnSwitchServer, btnAddM3U,
      btnConnectXtream, btnOpenLocalM3U, btnRefresh, btnExportM3U, btnWatch,
      btnFav, btnCopyUrl, btnEPG, btnCheckHealth, btnRecordStream, btnClose) do
      ActionButton.Font.Size := 8;
    pnlCategories.Align := alRight;
    lblChannelCount.Alignment := taLeftJustify;
    lblCatTitle.Alignment := taRightJustify;
    FChannelHeading.Alignment := taRightJustify;
    lblInfoName.Alignment := taRightJustify;
    lblInfoEPG.Alignment := taRightJustify;
    lblInfoUrl.Alignment := taRightJustify;
    lblInfoBadge.Alignment := taLeftJustify;
    edtServerUrl.BiDiMode := bdLeftToRight;
    edtUsernameOrMac.BiDiMode := bdLeftToRight;
    edtPassword.BiDiMode := bdLeftToRight;
    lblHubTitle.Alignment := taRightJustify;
    lblHubSubtitle.Alignment := taRightJustify;
    lblServerUrl.Alignment := taRightJustify;
    lblUsernameOrMac.Alignment := taRightJustify;
    lblPassword.Alignment := taRightJustify;
    lblPortalHint.Alignment := taRightJustify;
  end;
  FHubShell:=TModernCardPanel.Create(Self);
  FHubShell.Parent:=pnlWelcomeHub;
  FHubShell.CornerRadius:=14;
  FHubShell.CardColor:=DP_COLOR_SURFACE;
  FHubShell.BorderColor:=DP_COLOR_BORDER;
  pnlHubCard.Parent:=FHubShell;
  pnlHubCard.Align:=alClient;
  pnlHubCard.AlignWithMargins:=True;
  pnlHubCard.Margins.SetBounds(8,8,8,8);
  FConnectionStatus := TLabel.Create(Self);
  FConnectionStatus.Parent := pnlHubCard;
  FConnectionStatus.AutoSize := False;
  FConnectionStatus.Font.Color := DP_COLOR_ACCENT;
  FConnectionStatus.Visible := False;
  rbConnTypeClick(nil);
  Constraints.MinWidth := Max(Width, MulDiv(920, CurrentPPI, 96));
  Constraints.MinHeight := Max(Height, MulDiv(640, CurrentPPI, 96));
  OnResize := LayoutStudio;
  LayoutStudio(nil);
end;

procedure TFrmIPTV.DragWindowSurface(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button <> mbLeft) or (WindowState <> wsNormal) then Exit;
  ReleaseCapture;
  SendMessage(Handle, WM_SYSCOMMAND, SC_MOVE or HTCAPTION, 0);
end;

procedure TFrmIPTV.OpenConnectionSource(Kind: Integer);
const
  SourceKeys: array[0..4] of string = ('Xtream', 'StalkerMac', 'M3UUrl', 'LocalFile', 'Demo');
begin
  if not InRange(Kind, Low(SourceKeys), High(SourceKeys)) then Exit;
  LoadPortalProfile(SourceKeys[Kind]);
  SelectConnectionSource(Kind);
  if (Kind = 4) or (chkRememberPortal.Checked and
      (Trim(edtServerUrl.Text) <> '') and (edtServerUrl.Text <> 'http://')) then
    btnConnectPortalClick(nil);
end;

procedure TFrmIPTV.SelectConnectionSource(Kind: Integer);
begin
  case Kind of
    0: rbXtream.Checked:=True;
    1: rbStalkerMac.Checked:=True;
    2: rbM3UUrl.Checked:=True;
    3: rbLocalFile.Checked:=True;
    4: rbDemo.Checked:=True;
  else Exit;
  end;
  ShowConnectionHub(True);
  rbConnTypeClick(nil);
end;

procedure TFrmIPTV.ShowConnectionHub(Value: Boolean);
begin
  pnlCategories.Visible := not Value;
  if Assigned(FLibraryRail) then FLibraryRail.Visible := not Value;
  pnlMain.Visible := not Value;
  pnlTop.Visible := not Value;
  pnlBottom.Visible := not Value;
  pnlWelcomeHub.Visible := Value;
  if Value then pnlWelcomeHub.BringToFront
  else if Assigned(FLibraryRail) then FLibraryRail.BringToFront;
  Realign;
  pnlCategories.Realign;
  pnlMain.Realign;
  LayoutStudio(nil);
end;

procedure TFrmIPTV.LayoutStudio(Sender: TObject);
var SearchField: TControl; Scale, CardW, ColW, FieldW, HubH: Integer;
  procedure Place(C: TControl; X, Y, W, H: Integer);
  begin
    if (C is TEdit) and (C.Parent is TModernCardPanel) then C:=C.Parent;
    if PlayerIsArabic and Assigned(C.Parent) and
       ((C.Parent = grpCredentials) or (C.Parent = grpConnType) or
        (C.Parent = pnlBottom) or (C.Parent = pnlTop) or (C.Parent = pnlHubCard) or
        (C.Parent = pnlChannelInfo)) then
      X := MulDiv(C.Parent.ClientWidth, 96, Scale) - X - W;
    C.SetBounds(MulDiv(X, Scale, 96), MulDiv(Y, Scale, 96),
    MulDiv(W, Scale, 96), MulDiv(H, Scale, 96)); end;
begin
  Scale := CurrentPPI;
  DisableAlign;
  pnlHubCard.DisableAlign;
  try
  if Assigned(FConnectionStatus) then
  begin
    Place(FConnectionStatus, 24, 535, MulDiv(pnlHubCard.ClientWidth, 96, Scale) - 48, 20);
    if PlayerIsArabic then FConnectionStatus.Alignment := taRightJustify;
  end;
  pnlBottom.Height:=MulDiv(56,Scale,96);
  btnClose.SetBounds(pnlBottom.ClientWidth-MulDiv(128,Scale,96),MulDiv(12,Scale,96),MulDiv(104,Scale,96),MulDiv(32,Scale,96));
  if PlayerIsArabic then btnClose.Left := MulDiv(24, Scale, 96);
  Place(btnWatch,16,12,112,32);
  Place(btnFav,140,12,144,32);
  Place(btnCopyUrl,296,12,100,32);
  Place(btnEPG,408,12,92,32);
  Place(btnCheckHealth,512,12,118,32);
  Place(btnRecordStream,642,12,92,32);
  var InfoWidth := MulDiv(pnlChannelInfo.ClientWidth, 96, Scale);
  var BadgeWidth := Min(250, InfoWidth div 2);
  Place(lblInfoName, 14, 8, InfoWidth - BadgeWidth - 38, 22);
  Place(lblInfoBadge, InfoWidth - BadgeWidth - 14, 10, BadgeWidth, 20);
  Place(lblInfoEPG, 14, 30, InfoWidth - 28, 18);
  Place(lblInfoUrl, 14, 49, InfoWidth - 28, 18);
  pnlCategories.Width:=MulDiv(296,Scale,96);
  if Assigned(FCategoryCard) then
  begin
    var RailWidth := MulDiv(46, Scale, 96);
    var CatLeft := MulDiv(6, Scale, 96);
    var CatRight := MulDiv(6, Scale, 96);
    if PlayerIsArabic then CatRight := RailWidth + MulDiv(12, Scale, 96)
    else CatLeft := RailWidth + MulDiv(12, Scale, 96);
    if (FCategoryCard.Margins.Left <> CatLeft) or (FCategoryCard.Margins.Right <> CatRight) then
    begin
      pnlCategories.DisableAlign;
      try
        FCategoryCard.Margins.Left := CatLeft;
        FCategoryCard.Margins.Right := CatRight;
      finally
        pnlCategories.EnableAlign;
      end;
    end;
    var RailX := pnlCategories.Left + MulDiv(6, Scale, 96);
    if PlayerIsArabic then RailX := pnlCategories.Left + pnlCategories.Width - RailWidth - MulDiv(6, Scale, 96);
    if Assigned(FLibraryRail) then
    begin
      var RailTop := pnlCategories.Top + MulDiv(4, Scale, 96);
      var RailHeight := Max(1, pnlCategories.Height - MulDiv(10, Scale, 96));
      if (FLibraryRail.Left <> RailX) or (FLibraryRail.Top <> RailTop) or
         (FLibraryRail.Width <> RailWidth) or (FLibraryRail.Height <> RailHeight) then
        FLibraryRail.SetBounds(RailX, RailTop, RailWidth, RailHeight);
    end;
    lblCatTitle.SetBounds(MulDiv(16,Scale,96),MulDiv(12,Scale,96),
      Max(1, FCategoryCard.ClientWidth - MulDiv(32,Scale,96)),MulDiv(24,Scale,96));
    FChannelHeading.SetBounds(MulDiv(16,Scale,96),MulDiv(12,Scale,96),
      Max(1, FChannelCard.ClientWidth - MulDiv(32,Scale,96)),MulDiv(24,Scale,96));
  end;
  if Assigned(FHomeEmpty) then
  begin
    var HostWidth := FChannelCard.ClientWidth;
    var Edge := MulDiv(12, Scale, 96);
    FHomeHero.SetBounds(Edge, MulDiv(39, Scale, 96), Max(1, HostWidth - Edge * 2),
      MulDiv(112, Scale, 96));
    var ArtWidth := Min(MulDiv(180, Scale, 96), HostWidth div 4);
    var ShelfTop := 39;
    if Assigned(FFeaturedChannel) then ShelfTop := 159;
    PlaceLocalized(FHeroTitle, Edge, MulDiv(15, Scale, 96), Max(1, FHomeHero.Width - Edge * 3 - ArtWidth),
      MulDiv(35, Scale, 96));
    PlaceLocalized(FHeroArt, FHomeHero.Width - Edge - ArtWidth, Edge, ArtWidth, MulDiv(88, Scale, 96));
    PlaceLocalized(FHeroPlay, Edge, MulDiv(58, Scale, 96), MulDiv(156, Scale, 96), MulDiv(34, Scale, 96));
    PlaceLocalized(FRecentTab, Edge, MulDiv(ShelfTop, Scale, 96), MulDiv(128, Scale, 96), MulDiv(30, Scale, 96));
    PlaceLocalized(FFavoriteTab, MulDiv(148, Scale, 96), MulDiv(ShelfTop, Scale, 96),
      MulDiv(112, Scale, 96), MulDiv(30, Scale, 96));
    FHomeEmpty.SetBounds(Edge, MulDiv(ShelfTop + 48, Scale, 96), Max(1, HostWidth - Edge * 2),
      MulDiv(28, Scale, 96));
  end;
  pnlTop.Height := MulDiv(90, Scale, 96);
  SearchField := edtSearch;
  if edtSearch.Parent is TModernCardPanel then SearchField := edtSearch.Parent;
  Place(lblSearch, 16, 18, 44, 20);
  Place(SearchField, 66, 12, 260, 28);
  Place(lblChannelCount, MulDiv(pnlTop.ClientWidth, 96, Scale) - 180, 18, 160, 20);
  Place(btnSwitchServer, 16, 50, 132, 30);
  Place(btnAddM3U, 158, 50, 100, 30);
  Place(btnConnectXtream, 268, 50, 100, 30);
  Place(btnOpenLocalM3U, 378, 50, 100, 30);
  Place(btnRefresh, 488, 50, 90, 30);
  Place(btnExportM3U, 588, 50, 100, 30);
  if Assigned(FGridToggle) then
  begin
    for var Index := 0 to High(FLibrarySections) do
      if Assigned(FLibrarySections[Index]) then
        Place(FLibrarySections[Index], 5, 8 + Index * 44, 36, 36);
    var ToggleX := FChannelCard.ClientWidth - MulDiv(48, Scale, 96);
    if PlayerIsArabic then ToggleX := MulDiv(12, Scale, 96);
    FGridToggle.SetBounds(ToggleX, MulDiv(5, Scale, 96),
      MulDiv(36, Scale, 96), MulDiv(28, Scale, 96));
    LayoutLibrary;
  end;
  Place(lblHubTitle, 24, 18, 592, 30);
  lblHubTitle.Caption := Translate('Connect your TV source');
  lblHubTitle.Font.Size := 17;
  Place(lblHubSubtitle, 24, 56, 592, 32);
  lblHubSubtitle.AutoSize := False;
  lblHubSubtitle.WordWrap := True;
  lblHubSubtitle.Caption := Translate('Choose a source, then enter the details supplied by your provider.');
  grpConnType.Caption := '';
  Place(grpConnType, 24, 100, 592, 100);
  rbXtream.Caption := Translate('Xtream Codes');
  rbStalkerMac.Caption := Translate('Stalker / MAC');
  rbM3UUrl.Caption := Translate('M3U playlist URL');
  rbLocalFile.Caption := Translate('Local playlist');
  rbDemo.Caption := Translate('Playback samples');
  Place(rbXtream, 0, 0, 184, 40);
  Place(rbStalkerMac, 198, 0, 184, 40);
  Place(rbM3UUrl, 396, 0, 184, 40);
  Place(rbLocalFile, 0, 50, 184, 40);
  Place(rbDemo, 198, 50, 184, 40);
  Place(grpCredentials, 24, 216, 592, 220);
  grpCredentials.Caption := Translate('Connection details');
  grpCredentials.Visible := not rbDemo.Checked;
  btnConnectPortal.Caption := Translate('Connect');
  if FRequest <> nil then btnConnectPortal.Caption := Translate('Connecting...');
  if rbDemo.Checked then
  begin
    pnlHubCard.Height := MulDiv(290, Scale, 96);
    Place(btnConnectPortal, 24, 220, 184, 40);
    Place(btnCancelHub, 222, 220, 128, 40);
  end
  else
  begin
    pnlHubCard.Height := MulDiv(552, Scale, 96);
    Place(btnConnectPortal, 24, 492, 184, 36);
    Place(btnCancelHub, 222, 492, 128, 36);
  end;
  if FChannels.Count > 0 then btnCancelHub.Caption := Translate('Back')
  else btnCancelHub.Caption := Translate('Cancel');
  if FHubShell<>nil then
  begin
    if rbDemo.Checked then HubH:=MulDiv(306,Scale,96)
    else HubH:=MulDiv(568,Scale,96);
    CardW:=Min(Max(MulDiv(688,Scale,96), pnlWelcomeHub.ClientWidth * 3 div 4),
      pnlWelcomeHub.ClientWidth-MulDiv(32,Scale,96));
    FHubShell.SetBounds((pnlWelcomeHub.ClientWidth-CardW) div 2,
      Max(MulDiv(12,Scale,96),(pnlWelcomeHub.ClientHeight-HubH) div 2),CardW,HubH);
    CardW:=MulDiv(pnlHubCard.ClientWidth,96,Scale)-48;
    Place(grpConnType, 24, 100, CardW, 100);
    ColW:=(CardW-28) div 3;
    Place(rbXtream,0,0,ColW,40);
    Place(rbStalkerMac,ColW+14,0,ColW,40);
    Place(rbM3UUrl,(ColW+14)*2,0,ColW,40);
    Place(rbLocalFile,0,50,ColW,40);
    Place(rbDemo,ColW+14,50,ColW,40);
    Place(grpCredentials,24,220,CardW,252);
    Place(lblServerUrl,18,24,CardW-36,22);
    FieldW:=CardW-36;
    if rbLocalFile.Checked then Dec(FieldW,108);
    Place(edtServerUrl,18,52,FieldW,32);
    Place(btnBrowseFile,CardW-114,52,96,32);
    Place(lblUsernameOrMac,18,100,CardW-36,22);
    FieldW:=CardW-36;
    if rbXtream.Checked then FieldW:=(CardW-48) div 2;
    Place(edtUsernameOrMac,18,126,FieldW,32);
    Place(lblPassword,CardW div 2+6,100,CardW div 2-24,22);
    Place(edtPassword,CardW div 2+6,126,CardW div 2-24,32);
    Place(chkRememberPortal,18,174,CardW-36,24);
    Place(lblPortalHint,18,206,CardW-36,34);
    lblPortalHint.Font.Color:=DP_COLOR_MUTED;
  end
  else
  begin
    pnlHubCard.Left := Max(12, (pnlWelcomeHub.ClientWidth - pnlHubCard.Width) div 2);
    pnlHubCard.Top := Max(12, (pnlWelcomeHub.ClientHeight - pnlHubCard.Height) div 2);
  end;
  finally
    pnlHubCard.EnableAlign;
    EnableAlign;
  end;
end;

function TFrmIPTV.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'VLCModern_IPTV.ini';
end;

procedure TFrmIPTV.FormCreate(Sender: TObject);
begin
  FRecentChannels := TStringList.Create;
  var History := TAppSettings.Create(GetIniPath);
  try
    FRecentChannels.CommaText := History.ReadString('RecentChannels', 'Keys', '');
  finally
    History.Free;
  end;
  var LogoWindowOpen := True;
  FLogoWindowAlive := function: Boolean begin Result := LogoWindowOpen; end;
  FCloseLogoWindow := procedure begin LogoWindowOpen := False; end;
  FGuide := TProgrammeGuide.Create;
  FChannels := TObjectList<TIPTVChannel>.Create(True);
  FFilteredChannels := TList<TIPTVChannel>.Create;
  FCategories := TStringList.Create;
  FCategories.Duplicates := dupIgnore;
  FCategories.Sorted := True;
  FRequestTimer := TTimer.Create(Self);
  FRequestTimer.Enabled := False;
  FRequestTimer.Interval := 100;
  FRequestTimer.OnTimer := DownloadTick;

  lstCategories.OnDrawItem := lstCategoriesDrawItem;
  lstChannels.OnDrawItem := lstChannelsDrawItem;
  lstChannels.OnKeyDown := lstChannelsKeyDown;
  edtSearch.OnKeyDown := edtSearchKeyDown;

  LoadPortalProfile;
  rbConnTypeClick(nil);
  ShowConnectionHub(True);
  pnlWelcomeHub.BringToFront;
end;

procedure TFrmIPTV.FormDestroy(Sender: TObject);
begin
  OnResize := nil;
  if Assigned(FLibraryGrid) then
  begin
    FLibraryGrid.OnDrawCell := nil;
    FLibraryGrid.OnTopLeftChanged := nil;
    FLibraryGrid.OnSelectCell := nil;
  end;
  if Assigned(FCloseLogoWindow) then FCloseLogoWindow();
  FClosingForm := True;
  DragAcceptFiles(Handle, False);
  FRequestTimer.Enabled := False;
  FRequest := nil;
  if FChannels.Count > 0 then SaveFavorites;
  FFilteredChannels.Free;
  FCategories.Free;
  FChannels.Free;
  FGuide.Free;
  FLogoCache.Free;
  FLogoPending.Free;
  FRecentChannels.Free;
end;

procedure TFrmIPTV.WMDropFiles(var Msg: TWMDropFiles);
var
  Count, Len, I: Integer;
  FileName, Ext: string;
begin
  Count := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  try
    for I := 0 to Count - 1 do
    begin
      Len := DragQueryFile(Msg.Drop, I, nil, 0);
      if Len > 0 then
      begin
        SetLength(FileName, Len);
        DragQueryFile(Msg.Drop, I, PChar(FileName), Len + 1);
        if FileExists(FileName) then
        begin
          Ext := LowerCase(ExtractFileExt(FileName));
          if MatchText(Ext, ['.m3u', '.m3u8', '.pls']) then
          begin
            ParseM3UFile(FileName);
            ShowConnectionHub(False);
            Break;
          end;
        end;
      end;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TFrmIPTV.LoadPortalProfile(const Source: string);
var
  Ini: TAppSettings;
  PType, Section: string;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    PType := Ini.ReadString('Portal', 'LastType', 'Xtream');
    if Source <> '' then
      Section := 'Portal_' + Source
    else
      Section := 'Portal_' + PType;
    if not Ini.SectionExists(Section) and ((Source = '') or SameText(Source, PType)) then
      Section := 'Portal';
    edtServerUrl.Text := Ini.ReadString(Section, 'ServerUrl', 'http://');
    edtUsernameOrMac.Text := Ini.ReadString(Section, 'UsernameOrMac', '');
    edtPassword.Text := Ini.ReadString(Section, 'Password', '');
    chkRememberPortal.Checked := Ini.ReadBool(Section, 'Remember', True);

    if Source <> '' then Exit;
    if SameText(PType, 'StalkerMac') then rbStalkerMac.Checked := True
    else if SameText(PType, 'M3UUrl') then rbM3UUrl.Checked := True
    else if SameText(PType, 'LocalFile') then rbLocalFile.Checked := True
    else if SameText(PType, 'Demo') then rbDemo.Checked := True
    else rbXtream.Checked := True;
  finally
    Ini.Free;
  end;
end;

procedure TFrmIPTV.SavePortalProfile;
var
  Ini: TAppSettings;
  PType, Section: string;
begin
  if not chkRememberPortal.Checked then Exit;
  Ini := TAppSettings.Create(GetIniPath);
  try
    if rbStalkerMac.Checked then PType := 'StalkerMac'
    else if rbM3UUrl.Checked then PType := 'M3UUrl'
    else if rbLocalFile.Checked then PType := 'LocalFile'
    else if rbDemo.Checked then PType := 'Demo'
    else PType := 'Xtream';

    Section := 'Portal_' + PType;
    Ini.WriteString('Portal', 'LastType', PType);
    Ini.WriteString(Section, 'ServerUrl', edtServerUrl.Text);
    Ini.WriteString(Section, 'UsernameOrMac', edtUsernameOrMac.Text);
    Ini.WriteString(Section, 'Password', edtPassword.Text);
    Ini.WriteBool(Section, 'Remember', True);
  finally
    Ini.Free;
  end;
end;

procedure TFrmIPTV.rbConnTypeClick(Sender: TObject);
  procedure FieldVisible(Edit: TEdit; Value: Boolean);
  begin
    Edit.Visible := Value;
    if Edit.Parent is TModernCardPanel then Edit.Parent.Visible := Value;
  end;
begin
  pnlHubCard.DisableAlign;
  grpCredentials.DisableAlign;
  try
  btnBrowseFile.Visible := rbLocalFile.Checked;
  lblPassword.Visible := rbXtream.Checked;
  FieldVisible(edtPassword, rbXtream.Checked);

  if rbXtream.Checked then
  begin
    lblServerUrl.Caption := Translate('Xtream Server URL (e.g. http://server:8080):');
    lblUsernameOrMac.Visible := True;
    FieldVisible(edtUsernameOrMac, True);
    lblUsernameOrMac.Caption := Translate('Username:');
    if edtServerUrl.Text = '' then edtServerUrl.Text := 'http://';
    lblPortalHint.Caption := Translate('Xtream Codes API: imports the provider''s live channel playlist.');
  end
  else if rbStalkerMac.Checked then
  begin
    lblServerUrl.Caption := Translate('Stalker Portal URL (e.g. http://server:8080/c/):');
    lblUsernameOrMac.Visible := True;
    FieldVisible(edtUsernameOrMac, True);
    lblUsernameOrMac.Caption := Translate('MAC Address (e.g. 00:1A:79:XX:XX:XX):');
    if edtServerUrl.Text = '' then edtServerUrl.Text := 'http://';
    lblPortalHint.Caption := Translate('Stalker MAG Portal: authenticate with your registered MAC address (00:1A:79:XX) to load live channels directly.');
  end
  else if rbM3UUrl.Checked then
  begin
    lblServerUrl.Caption := Translate('Remote M3U / M3U8 Playlist URL:');
    lblUsernameOrMac.Visible := True;
    FieldVisible(edtUsernameOrMac, True);
    lblUsernameOrMac.Caption := Translate('Playlist Name / Label (Optional):');
    if edtServerUrl.Text = '' then edtServerUrl.Text := 'https://';
    lblPortalHint.Caption := Translate('M3U / M3U8 Direct Link: imports a channel list with names and category groups.');
  end
  else if rbLocalFile.Checked then
  begin
    lblServerUrl.Caption := Translate('Local Playlist File Path:');
    lblUsernameOrMac.Visible := False;
    FieldVisible(edtUsernameOrMac, False);
    lblPortalHint.Caption := Translate('Local File: select any .m3u or .m3u8 playlist file saved on your computer.');
  end
  else if rbDemo.Checked then
  begin
    lblServerUrl.Caption := Translate('Demo Global Channels (No setup required):');
    lblUsernameOrMac.Visible := False;
    FieldVisible(edtUsernameOrMac, False);
    lblPortalHint.Caption := Translate('Public HLS and bundled MP4 samples for checking playback.');
  end;
  if Assigned(FRequestTimer) then LayoutStudio(nil);
  finally
    grpCredentials.EnableAlign;
    pnlHubCard.EnableAlign;
  end;
end;

procedure TFrmIPTV.btnBrowseFileClick(Sender: TObject);
begin
  if OpenDialogM3U.Execute then
    edtServerUrl.Text := OpenDialogM3U.FileName;
end;

procedure TFrmIPTV.btnConnectPortalClick(Sender: TObject);
var
  SUrl, Mac, User, Pass: string;
begin
  if FRequest <> nil then Exit;
  SUrl := Trim(edtServerUrl.Text);
  User := Trim(edtUsernameOrMac.Text);
  Pass := Trim(edtPassword.Text);

  if rbDemo.Checked then
  begin
    FChannels.Clear;
    LoadDefaultStreams;
    LoadFavorites;
    RebuildCategories;
    FilterChannels;
    UpdateChannelInfoPanel;
    SavePortalProfile;
    ShowConnectionHub(False);
    Exit;
  end;

  if rbLocalFile.Checked then
  begin
    if (SUrl = '') or not FileExists(SUrl) then
    begin
      PlayerMessage('Please select a valid local .m3u / .m3u8 file.');
      Exit;
    end;
    ParseM3UFile(SUrl);
    if FChannels.Count > 0 then
    begin
      SavePortalProfile;
      ShowConnectionHub(False);
    end;
    Exit;
  end;

  if (SUrl = '') or (SUrl = 'http://') or (SUrl = 'https://') then
  begin
    PlayerMessage('Please enter a valid Server or Playlist URL.');
    Exit;
  end;

  if rbXtream.Checked then
  begin
    if (User = '') or (Pass = '') then
    begin
      PlayerMessage('Please enter both Username and Password for Xtream Codes.');
      Exit;
    end;
    while EndsText('/', SUrl) do SetLength(SUrl, Length(SUrl) - 1);
    SUrl := SUrl + '/get.php?username=' + TNetEncoding.URL.Encode(User) + '&password=' + TNetEncoding.URL.Encode(Pass) + '&type=m3u_plus&output=ts';
    DownloadAndParseM3U(SUrl);
  end
  else if rbStalkerMac.Checked then
  begin
    Mac := Trim(edtUsernameOrMac.Text);
    if Mac = '' then
    begin
      PlayerMessage('Please enter your device MAC Address (e.g. 00:1A:79:B1:C2:D3).');
      Exit;
    end;
    if not TRegEx.IsMatch(Mac, '^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$') then
    begin
      PlayerMessage('Enter the MAC address registered with your provider.');
      Exit;
    end;
    FStalkerPortal := SUrl;
    FStalkerMAC := UpperCase(Mac);
    BeginStalker(FStalkerPortal, FStalkerMAC);
  end
  else if rbM3UUrl.Checked then
  begin
    DownloadAndParseM3U(SUrl);
  end;

  if FChannels.Count > 0 then
  begin
    ShowConnectionHub(False);
    UpdateChannelInfoPanel;
  end;
end;

procedure TFrmIPTV.btnSwitchServerClick(Sender: TObject);
begin
  ShowConnectionHub(True);
  pnlWelcomeHub.BringToFront;
end;

procedure TFrmIPTV.btnCancelHubClick(Sender: TObject);
begin
  if FChannels.Count > 0 then
    ShowConnectionHub(False)
  else
    Close;
end;

procedure TFrmIPTV.LoadDefaultStreams;
  procedure AddStream(const AName, AGroup, AUrl: string);
  var
    Ch: TIPTVChannel;
  begin
    Ch := TIPTVChannel.Create;
    Ch.Name := AName;
    Ch.Group := AGroup;
    Ch.StreamUrl := AUrl;
    Ch.IsFavorite := False;
    FChannels.Add(Ch);
  end;
begin
  AddStream('HLS playback sample', 'Playback samples', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8');
  if FileExists(ExtractFilePath(ParamStr(0)) + 'sample.mp4') then
    AddStream('Local video sample', 'Playback samples', ExtractFilePath(ParamStr(0)) + 'sample.mp4');
end;

procedure TFrmIPTV.ParseM3UContent(const AContent: string);
var
  Lines: TStringList;
  I, P, J: Integer;
  Quoted: Boolean;
  Line, NextLine, ExtInf: string;
  Ch: TIPTVChannel;
  function ExtractAttr(const Tag, AttrName: string): string;
  var
    Key: string;
    KPos, VStart, VEnd: Integer;
  begin
    Result := '';
    Key := AttrName + '="';
    KPos := Pos(Key, Tag);
    if KPos > 0 then
    begin
      VStart := KPos + Length(Key);
      VEnd := PosEx('"', Tag, VStart);
      if VEnd > VStart then
        Result := Copy(Tag, VStart, VEnd - VStart);
    end;
  end;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := AContent;
    if Lines.Count > 0 then
    begin
      FGuideURL := ExtractAttr(Lines[0], 'url-tvg');
      if FGuideURL = '' then FGuideURL := ExtractAttr(Lines[0], 'x-tvg-url');
    end;
    FFilteredChannels.Clear;
    FChannels.Clear;

    I := 0;
    while I < Lines.Count do
    begin
      Line := Trim(Lines[I]);
      if StartsText('#EXTINF:', Line) then
      begin
        ExtInf := Line;
        Inc(I);
        while (I < Lines.Count) and ((Trim(Lines[I]) = '') or StartsText('#', Trim(Lines[I]))) do
        begin
          if StartsText('#EXTVLCOPT:', Trim(Lines[I])) then ; // Ignore VLC options
          Inc(I);
        end;

        if I < Lines.Count then
        begin
          NextLine := Trim(Lines[I]);
          if NextLine <> '' then
          begin
            Ch := TIPTVChannel.Create;
            Ch.StreamUrl := NextLine;

            // Extract group-title
            Ch.Group := ExtractAttr(ExtInf, 'group-title');
            if Ch.Group = '' then Ch.Group := 'General';

            // Extract tvg-logo
            Ch.LogoUrl := ExtractAttr(ExtInf, 'tvg-logo');

            // Extract tvg-id
            Ch.TvgId := ExtractAttr(ExtInf, 'tvg-id');

            // Extract Channel Name (after last comma)
            P := 0;
            Quoted := False;
            for J := 1 to Length(ExtInf) do
              if ExtInf[J] = '"' then Quoted := not Quoted
              else if (ExtInf[J] = ',') and not Quoted then
              begin P := J; Break; end;
            if P > 0 then
              Ch.Name := Trim(Copy(ExtInf, P + 1, MaxInt))
            else
            begin
              Ch.Name := ExtractAttr(ExtInf, 'tvg-name');
              if Ch.Name = '' then Ch.Name := 'Channel ' + IntToStr(FChannels.Count + 1);
            end;

            Ch.IsFavorite := False;
            FChannels.Add(Ch);
          end;
        end;
      end;
      Inc(I);
    end;
  finally
    Lines.Free;
  end;

  LoadFavorites;
  RebuildCategories;
  FilterChannels;
end;

procedure TFrmIPTV.ParseM3UFile(const AFileName: string);
var
  S: TStringList;
begin
  if not FileExists(AFileName) then Exit;
  S := TStringList.Create;
  try
    S.LoadFromFile(AFileName, TEncoding.UTF8);
    ParseM3UContent(S.Text);
    FLastM3USource := AFileName;
  finally
    S.Free;
  end;
end;

type
  TCatalogBlob = record
    Size: DWORD;
    Data: PByte;
  end;

function CryptProtectData(var Input: TCatalogBlob; Description: PWideChar;
  Entropy, Reserved, Prompt: Pointer; Flags: DWORD; var Output: TCatalogBlob): BOOL;
  stdcall; external 'crypt32.dll';
function CryptUnprotectData(var Input: TCatalogBlob; Description, Entropy,
  Reserved, Prompt: Pointer; Flags: DWORD; var Output: TCatalogBlob): BOOL;
  stdcall; external 'crypt32.dll';

function TransformCatalog(const Bytes: TBytes; Protect: Boolean): TBytes;
begin
  Result := nil;
  if Length(Bytes) = 0 then Exit;
  var Input: TCatalogBlob;
  var Output: TCatalogBlob := Default(TCatalogBlob);
  Input.Size := Length(Bytes);
  Input.Data := @Bytes[0];
  var Success: BOOL;
  if Protect then
    Success := CryptProtectData(Input, nil, nil, nil, nil, 1, Output)
  else
    Success := CryptUnprotectData(Input, nil, nil, nil, nil, 1, Output);
  if not Success then Exit;
  try
    SetLength(Result, Output.Size);
    if Output.Size > 0 then Move(Output.Data^, Result[0], Output.Size);
  finally
    LocalFree(HLOCAL(Output.Data));
  end;
end;

procedure SaveCatalogCache(const FileName, Content: string);
begin
  if FileName = '' then Exit;
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        var Bytes := TransformCatalog(TEncoding.UTF8.GetBytes(Content), True);
        if Length(Bytes) = 0 then Exit;
        var CacheDirectory := ExtractFileDir(FileName);
        TDirectory.CreateDirectory(CacheDirectory);
        var Expiration := TTimeZone.Local.ToUniversalTime(Now) - 7;
        for var OldFile in TDirectory.GetFiles(CacheDirectory, '*.cache') do
          try
            if (OldFile <> FileName) and (TFile.GetLastWriteTimeUtc(OldFile) < Expiration) then
              Winapi.Windows.DeleteFile(PChar(OldFile));
          except
            // Another window may have replaced this entry.
          end;
        var TempFile := FileName + '.' + TPath.GetRandomFileName;
        try
          TFile.WriteAllBytes(TempFile, Bytes);
          MoveFileEx(PChar(TempFile), PChar(FileName), MOVEFILE_REPLACE_EXISTING);
        finally
          Winapi.Windows.DeleteFile(PChar(TempFile));
        end;
      except
        // A failed cache write does not affect the current catalog.
      end;
    end).Start;
end;

procedure TFrmIPTV.LoadCatalogCache(const SourceKey: string);
begin
  FCatalogCacheFile := '';
  FCachedCatalog := '';
  if not chkRememberPortal.Checked then Exit;
  try
    FCatalogCacheFile := TPath.Combine(PlayerCachePath('iptv-catalog'),
      THashSHA2.GetHashString(SourceKey) + '.cache');
    if (FChannels.Count > 0) and SameText(FLastLoadedCacheFile, FCatalogCacheFile) then
    begin
      FCachedCatalog := '#LOADED#';
      FLastM3USource := FRequestURL;
      ShowConnectionHub(False);
      Exit;
    end;
    if not pnlWelcomeHub.Visible or not TFile.Exists(FCatalogCacheFile) then Exit;
    if TFile.GetLastWriteTimeUtc(FCatalogCacheFile) <
       TTimeZone.Local.ToUniversalTime(Now) - 7 then Exit;
    FCachedCatalog := TEncoding.UTF8.GetString(
      TransformCatalog(TFile.ReadAllBytes(FCatalogCacheFile), False));
    if FCachedCatalog = '' then Exit;
    ParseM3UContent(FCachedCatalog);
    if FChannels.Count = 0 then
    begin
      FCachedCatalog := '';
      Exit;
    end;
    FLastLoadedCacheFile := FCatalogCacheFile;
    FLastM3USource := FRequestURL;
    ShowConnectionHub(False);
  except
    FCachedCatalog := '';
  end;
end;

procedure TFrmIPTV.BeginStalker(const Portal, MAC: string);
begin
  if FRequest <> nil then Exit;
  if not StartsText('http://', Portal) and not StartsText('https://', Portal) then
  begin
    PlayerMessage('Enter an HTTP or HTTPS portal address.');
    Exit;
  end;
  FRequestURL := Portal;
  FRequest := DownloadStalker(Portal, MAC);
  SetConnecting(True);
  LoadCatalogCache('stalker:' + Portal + ':' + MAC);
  if FCachedCatalog = '' then lblChannelCount.Caption := Translate('Connecting...');
  btnConnectPortal.Enabled := False;
  btnConnectPortal.Caption := Translate('Connecting...');
  btnRefresh.Enabled := False;
  FRequestTimer.Enabled := True;
end;

procedure TFrmIPTV.DownloadAndParseM3U(const AUrl: string);
begin
  if FRequest <> nil then Exit;
  if not StartsText('http://', AUrl) and not StartsText('https://', AUrl) then
  begin
    PlayerMessage('Enter an HTTP or HTTPS playlist address.');
    Exit;
  end;
  if not FLoadingGuide then
  begin
    FStalkerPortal := '';
    FStalkerMAC := '';
  end;
  FRequestURL := AUrl;
  FRequest := DownloadPlaylist(AUrl);
  SetConnecting(True);
  FCatalogCacheFile := '';
  FCachedCatalog := '';
  if not FLoadingGuide then LoadCatalogCache('playlist:' + AUrl);
  if FCachedCatalog = '' then lblChannelCount.Caption := Translate('Loading...');
  btnConnectPortal.Enabled := False;
  btnConnectPortal.Caption := Translate('Connecting...');
  btnRefresh.Enabled := False;
  FRequestTimer.Enabled := True;
end;

procedure TFrmIPTV.DownloadTick(Sender: TObject);
var Request: IPlaylistRequest;
begin
  if FRequest = nil then Exit;
  if not FRequest.Finished then
  begin
    if Assigned(FConnectionStatus) then
      FConnectionStatus.Caption := Format(Translate('Connecting to source (%d s)'),
        [(GetTickCount64 - FConnectingSince) div 1000]);
    Exit;
  end;
  if (FCachedCatalog <> '') and
     (lstChannels.FScroll.FDragging or lstCategories.FScroll.FDragging or
      FLibraryScroll.FDragging or (GetTickCount64 - FLastCatalogInteraction < 450)) then Exit;
  FRequestTimer.Enabled := False;
  Request := FRequest;
  FRequest := nil;
  SetConnecting(False);
  btnConnectPortal.Enabled := True;
  btnConnectPortal.Caption := Translate('Connect');
  btnRefresh.Enabled := True;
  if Request.ErrorText <> '' then
  begin
    if FCachedCatalog <> '' then
    begin
      FCachedCatalog := '';
      Exit;
    end;
    FLoadingGuide := False;
    lblChannelCount.Caption := Translate('Connection failed');
    if pnlWelcomeHub.Visible then
      PlayerMessage(Translate('Could not connect. Check the source details and try again.') +
        sLineBreak + Request.ErrorText)
    else
      PlayerMessage(Request.ErrorText);
    Exit;
  end;
  if FLoadingGuide then
  begin
    FLoadingGuide := False;
    try
      FGuide.LoadXML(Request.Content);
      var Ch := SelectedChannel;
      if Ch <> nil then
      begin
        var Text := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
        if Text = '' then Text := 'No current programmes match this channel ID.';
        PlayerMessage(Ch.Name + sLineBreak + sLineBreak + Text);
      end;
    except on E: Exception do PlayerMessage('The programme guide could not be read. Select a valid XMLTV file.'); end;
    Exit;
  end;
  var UsedCache := FCachedCatalog <> '';
  var Unchanged := UsedCache and (FCachedCatalog = Request.Content);
  var CategoryID: NativeInt := 2;
  var CategoryGroup := '';
  if UsedCache and (lstCategories.ItemIndex >= 0) then
  begin
    CategoryID := NativeInt(lstCategories.Items.Objects[lstCategories.ItemIndex]);
    if CategoryID >= 6 then CategoryGroup := FCategories[CategoryID - 6];
  end;
  var ChannelTop := lstChannels.TopIndex;
  var GridTop := FLibraryGrid.TopRow;
  if UsedCache and (FChannels.Count > 0) then
    Unchanged := True
  else if not Unchanged then
  begin
    ParseM3UContent(Request.Content);
    if UsedCache and (FChannels.Count = 0) then
    begin
      ParseM3UContent(FCachedCatalog);
      Unchanged := True;
    end;
    if UsedCache and (CategoryID <> 2) then
    begin
      if CategoryGroup <> '' then
      begin
        var GroupIndex := FCategories.IndexOf(CategoryGroup);
        if GroupIndex >= 0 then CategoryID := GroupIndex + 6
        else CategoryID := 2;
      end;
      var CategoryIndex := lstCategories.Items.IndexOfObject(TObject(CategoryID));
      if CategoryIndex >= 0 then
      begin
        lstCategories.ItemIndex := CategoryIndex;
        FilterChannels;
      end;
    end;
    if UsedCache and (lstChannels.Count > 0) then
    begin
      lstChannels.TopIndex := EnsureRange(ChannelTop, 0, Max(0, lstChannels.Count - lstChannels.FScroll.FVisibleRows));
      FLibraryGrid.TopRow := EnsureRange(GridTop, 0, Max(0, FLibraryGrid.RowCount - FLibraryGrid.VisibleRowCount));
    end;
  end;
  if (FChannels.Count > 0) and (not Unchanged or (FCachedCatalog = Request.Content)) then
    SaveCatalogCache(FCatalogCacheFile, Request.Content);
  FCachedCatalog := '';
  if FChannels.Count = 0 then
  begin
    PlayerMessage('The source contains no channels. Select an M3U channel playlist.');
    Exit;
  end;
  FLastM3USource := FRequestURL;
  if pnlWelcomeHub.Visible then
  begin
    SavePortalProfile;
    ShowConnectionHub(False);
  end;
  UpdateChannelInfoPanel;
end;

procedure TFrmIPTV.SetConnecting(Value: Boolean);
begin
  if Value then FConnectingSince := GetTickCount64;
  if Assigned(FConnectionStatus) then
  begin
    FConnectionStatus.Caption := Translate('Connecting to source');
    FConnectionStatus.Visible := Value;
  end;
  grpCredentials.Enabled := not Value;
  grpConnType.Enabled := not Value;
end;

function ClassifyMediaKind(Ch: TIPTVChannel): string;
var
  LowerUrl, LowerGroup: string;
begin
  if Ch = nil then Exit('Live TV');
  if Ch.MediaKind <> '' then Exit(Ch.MediaKind);
  LowerUrl := LowerCase(Ch.StreamUrl.Split(['?', '#'], 2)[0]);
  LowerGroup := LowerCase(Ch.Group);
  if ContainsText(LowerUrl, '/series/') or ContainsText(LowerGroup, 'series') or
     TRegEx.IsMatch(Ch.Name, 'S\d{1,2}\s*E\d{1,2}', [roIgnoreCase]) then
    Result := 'Series'
  else if ContainsText(LowerUrl, '/movie/') or EndsText('.mp4', LowerUrl) or
          EndsText('.mkv', LowerUrl) or EndsText('.avi', LowerUrl) or
          ContainsText(LowerGroup, 'vod') or ContainsText(LowerGroup, 'movie') then
    Result := 'Movies / VOD'
  else
    Result := 'Live TV';
  Ch.MediaKind := Result;
end;

procedure TFrmIPTV.RebuildCategories;
var
  Ch: TIPTVChannel;
  I, FavCount, LiveCount, VodCount, SeriesCount: Integer;
  Kind: string;
  CatMap: TDictionary<string, Integer>;
  GroupIndex: Integer;
begin
  FCategories.Clear;
  FavCount := 0;
  LiveCount := 0;
  VodCount := 0;
  SeriesCount := 0;
  CatMap := TDictionary<string, Integer>.Create(TIStringComparer.Ordinal);
  try
    for I := 0 to FChannels.Count - 1 do
    begin
      Ch := FChannels[I];
      if Ch.IsFavorite then Inc(FavCount);
      Kind := ClassifyMediaKind(Ch);
      if Kind = 'Series' then Inc(SeriesCount)
      else if Kind = 'Movies / VOD' then Inc(VodCount)
      else Inc(LiveCount);
      if Ch.Group <> '' then
      begin
        if not CatMap.TryGetValue(Ch.Group, GroupIndex) then
        begin
          GroupIndex := FCategories.AddObject(Ch.Group, TObject(1));
          CatMap.Add(Ch.Group, GroupIndex);
        end
        else
          FCategories.Objects[GroupIndex] := TObject(NativeInt(FCategories.Objects[GroupIndex]) + 1);
      end;
    end;
  finally
    CatMap.Free;
  end;

  lstCategories.Items.BeginUpdate;
  try
    lstCategories.Items.Clear;
    lstCategories.Items.AddObject(Format(Translate('Favorites (%d)'), [FavCount]), TObject(1));
    lstCategories.Items.AddObject(Format(Translate('All Channels (%d)'), [FChannels.Count]), TObject(2));
    if LiveCount > 0 then lstCategories.Items.AddObject(Format(Translate('Live TV (%d)'), [LiveCount]), TObject(3));
    if VodCount > 0 then lstCategories.Items.AddObject(Format(Translate('Movies / VOD (%d)'), [VodCount]), TObject(4));
    if SeriesCount > 0 then lstCategories.Items.AddObject(Format(Translate('Series (%d)'), [SeriesCount]), TObject(5));
    for I := 0 to FCategories.Count - 1 do
    begin
      var CatName := FCategories[I];
      var CatCount := NativeInt(FCategories.Objects[I]);
      // A provider group may have the same caption as a built-in category.
      // Keep it when it represents a distinct subset of the catalog.
      var BuiltInKind := '';
      var BuiltInCount := 0;
      if SameText(CatName, 'Live TV') or SameText(CatName, Translate('Live TV')) then
      begin
        BuiltInKind := 'Live TV';
        BuiltInCount := LiveCount;
      end
      else if SameText(CatName, 'Series') or SameText(CatName, Translate('Series')) then
      begin
        BuiltInKind := 'Series';
        BuiltInCount := SeriesCount;
      end
      else if SameText(CatName, 'Movies / VOD') or SameText(CatName, Translate('Movies / VOD')) then
      begin
        BuiltInKind := 'Movies / VOD';
        BuiltInCount := VodCount;
      end;
      if (BuiltInKind <> '') and (CatCount = BuiltInCount) then
      begin
        var Equivalent := True;
        for Ch in FChannels do
          if SameText(Ch.Group, CatName) and (ClassifyMediaKind(Ch) <> BuiltInKind) then
          begin
            Equivalent := False;
            Break;
          end;
        if Equivalent then Continue;
      end;
      lstCategories.Items.AddObject(Format('%s (%d)', [CatName, CatCount]), TObject(NativeInt(I + 6)));
    end;
  finally
    lstCategories.Items.EndUpdate;
    lstCategories.UpdateScroll;
  end;

  if lstCategories.Items.Count > 1 then
    lstCategories.ItemIndex := 1; // Default to 'All Channels'
end;

function TFrmIPTV.RecentRank(Channel: TIPTVChannel): Integer;
begin
  if Channel.HistoryKey = '' then
    Channel.HistoryKey := THashSHA2.GetHashString(Channel.StreamUrl);
  Result := FRecentChannels.IndexOf(Channel.HistoryKey);
  if Result < 0 then Result := MaxInt;
end;

procedure TFrmIPTV.FilterChannels;
var
  I: Integer;
  Ch: TIPTVChannel;
  SearchQuery: string;
  Category: NativeInt;
  MatchesCat, MatchesSearch: Boolean;
begin
  Category := 2;
  if lstCategories.ItemIndex >= 0 then
    Category := NativeInt(lstCategories.Items.Objects[lstCategories.ItemIndex]);

  SearchQuery := LowerCase(Trim(edtSearch.Text));

  FFilteredChannels.Clear;
  for I := 0 to FChannels.Count - 1 do
  begin
    Ch := FChannels[I];

    case Category of
      1: MatchesCat := Ch.IsFavorite;
      2: MatchesCat := True;
      3: MatchesCat := SameText(ClassifyMediaKind(Ch), 'Live TV');
      4: MatchesCat := SameText(ClassifyMediaKind(Ch), 'Movies / VOD');
      5: MatchesCat := SameText(ClassifyMediaKind(Ch), 'Series');
    else
      MatchesCat := (Category >= 6) and (Category - 6 < FCategories.Count) and
        SameText(Ch.Group, FCategories[Category - 6]);
    end;
    if MatchesCat then
      case FSection of
        1: MatchesCat := ClassifyMediaKind(Ch) = 'Live TV';
        2: MatchesCat := ClassifyMediaKind(Ch) = 'Movies / VOD';
        3: MatchesCat := ClassifyMediaKind(Ch) = 'Series';
        4: MatchesCat := Ch.IsFavorite;
      end;

    if MatchesCat then
    begin
      if SearchQuery = '' then
        MatchesSearch := True
      else
        MatchesSearch := (Pos(SearchQuery, LowerCase(Ch.Name)) > 0) or
                         (Pos(SearchQuery, LowerCase(Ch.Group)) > 0);

      if MatchesSearch then
      begin
        FFilteredChannels.Add(Ch);
      end;
    end;
  end;
  FHomeHistory := (FChannels.Count > 0) and (FSection = 0) and
    (Category = 2) and (SearchQuery = '');
  var PrevFeatured := FFeaturedChannel;
  FFeaturedChannel := nil;
  if FHomeHistory then
  begin
    var HomeItems := TList<TIPTVChannel>.Create;
    var RecentMap := TDictionary<string, Integer>.Create;
    try
      for I := 0 to FRecentChannels.Count - 1 do
        if not RecentMap.ContainsKey(FRecentChannels[I]) then
          RecentMap.Add(FRecentChannels[I], I);
      var BestRank := MaxInt;
      for Ch in FFilteredChannels do
      begin
        var Rank := MaxInt;
        if RecentMap.Count > 0 then
        begin
          if Ch.HistoryKey = '' then
            Ch.HistoryKey := THashSHA2.GetHashString(Ch.StreamUrl);
          if not RecentMap.TryGetValue(Ch.HistoryKey, Rank) then
            Rank := MaxInt;
        end;
        if Rank < BestRank then
        begin
          BestRank := Rank;
          FFeaturedChannel := Ch;
        end;

        if (FHomeFavoritesOnly and Ch.IsFavorite) or
           (not FHomeFavoritesOnly and (Rank <> MaxInt)) then
          HomeItems.Add(Ch);
      end;
      if RecentMap.Count > 0 then
        HomeItems.Sort(TComparer<TIPTVChannel>.Construct(
          function(const Left, Right: TIPTVChannel): Integer
          var
            LRank, RRank: Integer;
          begin
            if not RecentMap.TryGetValue(Left.HistoryKey, LRank) then LRank := MaxInt;
            if not RecentMap.TryGetValue(Right.HistoryKey, RRank) then RRank := MaxInt;
            Result := CompareValue(LRank, RRank);
          end));
      FFilteredChannels.Clear;
      FFilteredChannels.AddRange(HomeItems);
    finally
      RecentMap.Free;
      HomeItems.Free;
    end;
  end;

  FLastAppliedSection := FSection;
  FLastAppliedCatIndex := lstCategories.ItemIndex;

  if FHomeHistory then
    lblChannelCount.Caption := Format(Translate('%d Channels'), [FChannels.Count])
  else
    lblChannelCount.Caption := Format(Translate('%d Channels'), [FFilteredChannels.Count]);
  if (FSection = 0) and Assigned(FChannelHeading) then
    FChannelHeading.Caption := Translate('IPTV Home');

  if Assigned(FChannelCard) then FChannelCard.DisableAlign;
  try
    lstChannels.Count := FFilteredChannels.Count;
    if lstChannels.Count > 0 then
      lstChannels.ItemIndex := 0;
    if lstChannels.Visible then
    begin
      if (lstChannels.Count > 0) and (lstChannels.TopIndex <> 0) then
        lstChannels.TopIndex := 0;
      lstChannels.UpdateScroll;
      lstChannels.Invalidate;
    end;

    if Assigned(FHomeHero) then
    begin
      var WasHeroVis := FHomeHero.Visible;
      var WasHomeVis := FRecentTab.Visible;
      var WasEmptyVis := FHomeEmpty.Visible;
      FHomeHero.Visible := FHomeHistory and Assigned(FFeaturedChannel);
      FRecentTab.Visible := FHomeHistory;
      FFavoriteTab.Visible := FHomeHistory;
      FHeroPlay.Visible := Assigned(FFeaturedChannel);
      FHeroArt.Visible := Assigned(FFeaturedChannel);
      if FHeroArt.Visible and (PrevFeatured <> FFeaturedChannel) then FHeroArt.Invalidate;
      FHomeEmpty.Visible := FHomeHistory and (FFilteredChannels.Count = 0);
      if FHomeFavoritesOnly then FHomeEmpty.Caption := Translate('No favorites yet')
      else FHomeEmpty.Caption := Translate('No recently viewed channels');
      FRecentTab.IsAccent := not FHomeFavoritesOnly;
      FFavoriteTab.IsAccent := FHomeFavoritesOnly;
      if (WasHeroVis <> FHomeHero.Visible) or (WasHomeVis <> FRecentTab.Visible) then
        LayoutStudio(nil);
      if Assigned(FFeaturedChannel) then FHeroTitle.Caption := FFeaturedChannel.Name
      else FHeroTitle.Caption := Translate('No recently viewed channels');
      var ContentTop := 37;
      if FHomeHistory then
      begin
        if Assigned(FFeaturedChannel) then ContentTop := 198 else ContentTop := 78;
        if FHomeEmpty.Visible then Inc(ContentTop, 52);
      end;
      var NewTop := MulDiv(ContentTop, CurrentPPI, 96);
      if FLibraryGrid.Margins.Top <> NewTop then FLibraryGrid.Margins.Top := NewTop;
      if lstChannels.Margins.Top <> NewTop then lstChannels.Margins.Top := NewTop;
      if FHomeHistory and ((not WasHomeVis) or (not WasHeroVis and FHomeHero.Visible)) then
      begin
        FHomeHero.BringToFront;
        FRecentTab.BringToFront;
        FFavoriteTab.BringToFront;
      end;
      if FHomeEmpty.Visible and not WasEmptyVis then
        FHomeEmpty.BringToFront;
    end;
    UpdateChannelInfoPanel;
  finally
    if Assigned(FChannelCard) then FChannelCard.EnableAlign;
  end;
  if Assigned(FLibraryGrid) and FLibraryGrid.Visible then
  begin
    if FLibraryGrid.TopRow <> 0 then
      FLibraryGrid.TopRow := 0;
    LayoutLibrary;
    FLibraryGrid.Invalidate;
  end;
end;

procedure TFrmIPTV.ChangeLibrarySection(Sender: TObject);
var
  TargetSection: Integer;
  TargetCatID: NativeInt;
  CatIdx: Integer;
begin
  TargetSection := TControl(Sender).Tag;
  case TargetSection of
    1: TargetCatID := 3; // Live TV
    2: TargetCatID := 4; // Movies / VOD
    3: TargetCatID := 5; // Series
    4: TargetCatID := 1; // Favorites
  else
    TargetCatID := 2;    // Home / All Channels
  end;
  CatIdx := lstCategories.Items.IndexOfObject(TObject(TargetCatID));
  if (CatIdx < 0) and (lstCategories.Items.Count > 1) then
    CatIdx := 1;
  if (TargetSection = FSection) and (lstCategories.ItemIndex = CatIdx) and
     ((FSection = 0) or FLibraryGrid.Visible) then
    Exit;

  FSection := TargetSection;
  for var Index := 0 to High(FLibrarySections) do
    TModernVectorButton(FLibrarySections[Index]).IsActive := Index = FSection;
  if CatIdx >= 0 then lstCategories.ItemIndex := CatIdx;
  FChannelHeading.Caption := FLibrarySections[FSection].Caption;
  if not FLibraryGrid.Visible then
  begin
    FLibraryGrid.Visible := True;
    lstChannels.Visible := False;
    lstChannels.UpdateScroll;
    if Assigned(FLibraryScroll) then FLibraryScroll.BringToFront;
    FGridToggle.IconKind := ikPlaylist;
    FGridToggle.Hint := Translate('List view');
  end;
  FilterChannels;
end;

procedure TFrmIPTV.ChangeHomeShelf(Sender: TObject);
var
  WantFav: Boolean;
begin
  WantFav := Sender = FFavoriteTab;
  if WantFav = FHomeFavoritesOnly then Exit;
  FHomeFavoritesOnly := WantFav;
  FilterChannels;
end;

procedure TFrmIPTV.PlayFeatured(Sender: TObject);
begin
  PlayChannel(FFeaturedChannel);
end;

procedure TFrmIPTV.PaintFeaturedArt(Sender: TObject);
begin
  if FClosingForm or not Assigned(FFeaturedChannel) then Exit;
  var Logo: TGPImage := nil;
  var URL := FFeaturedChannel.LogoUrl;
  if Assigned(FLogoCache) then FLogoCache.TryGetValue(URL, Logo);
  var Edge := MulDiv(8, CurrentPPI, 96);
  var CenterX: Single := FHeroArt.Width / 2;
  var CenterY: Single := FHeroArt.Height / 2;
  var Radius: Single := Min(CenterX, CenterY) - Edge;
  if Radius <= 0 then Exit;
  var G := TGPGraphics.Create(FHeroArt.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    var Halo := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ACCENT, 28));
    try
      G.FillEllipse(Halo, CenterX - Radius, CenterY - Radius, Radius * 2, Radius * 2);
    finally Halo.Free; end;
    if Assigned(Logo) and (Logo.GetWidth > 0) and (Logo.GetHeight > 0) then
    begin
      var Scale := Min((FHeroArt.Width - Edge * 2) / Logo.GetWidth, (Radius * 1.55) / Logo.GetHeight);
      var W := Round(Logo.GetWidth * Scale);
      var H := Round(Logo.GetHeight * Scale);
      G.DrawImage(Logo, Round(CenterX - W / 2), Round(CenterY - H / 2), W, H);
    end
    else
    begin
      EnsureChannelLogoAsync(URL);
      var Stroke := TGPPen.Create(MakeGDIColor(DP_COLOR_ACCENT), MulDiv(2, CurrentPPI, 96));
      try
        Stroke.SetLineJoin(LineJoinRound);
        G.DrawRectangle(Stroke, CenterX - Radius * 0.48, CenterY - Radius * 0.38,
          Radius * 0.96, Radius * 0.67);
        G.DrawLine(Stroke, CenterX - Radius * 0.22, CenterY + Radius * 0.48,
          CenterX + Radius * 0.22, CenterY + Radius * 0.48);
      finally Stroke.Free; end;
    end;
  finally G.Free; end;
end;

procedure TFrmIPTV.ToggleLibraryView(Sender: TObject);
begin
  FLibraryGrid.Visible := not FLibraryGrid.Visible;
  lstChannels.Visible := not FLibraryGrid.Visible;
  lstChannels.UpdateScroll;
  if Assigned(FLibraryScroll) then
  begin
    if FLibraryGrid.Visible then FLibraryScroll.BringToFront
    else FLibraryScroll.Visible := False;
  end;
  if FLibraryGrid.Visible then
  begin
    FGridToggle.IconKind := ikPlaylist;
    FGridToggle.Hint := Translate('List view');
  end
  else
  begin
    FGridToggle.IconKind := ikGrid;
    FGridToggle.Hint := Translate('Grid view');
  end;
  LayoutLibrary;
  if FLibraryGrid.Visible and (lstChannels.ItemIndex >= 0) then
  begin
    var Index := lstChannels.ItemIndex;
    var Column := Index mod FLibraryGrid.ColCount;
    if PlayerIsArabic then Column := FLibraryGrid.ColCount - Column - 1;
    FLibraryGrid.Row := Index div FLibraryGrid.ColCount;
    FLibraryGrid.Col := Column;
  end;
end;

procedure TFrmIPTV.RememberChannel(Channel: TIPTVChannel);
begin
  if Channel.HistoryKey = '' then Channel.HistoryKey := THashSHA2.GetHashString(Channel.StreamUrl);
  var Existing := FRecentChannels.IndexOf(Channel.HistoryKey);
  if Existing >= 0 then FRecentChannels.Delete(Existing);
  FRecentChannels.Insert(0, Channel.HistoryKey);
  if FRecentChannels.Count > 24 then FRecentChannels.Delete(FRecentChannels.Count - 1);
  var History := TAppSettings.Create(GetIniPath);
  try
    History.WriteString('RecentChannels', 'Keys', FRecentChannels.CommaText);
  finally History.Free; end;
end;

procedure TFrmIPTV.LibraryMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then Exit;
  var Column, Row: Longint;
  FLibraryGrid.MouseToCell(X, Y, Column, Row);
  if (Column < 0) or (Row < 0) then Exit;
  var Cell := FLibraryGrid.CellRect(Column, Row);
  var Pad := MulDiv(7, CurrentPPI, 96);
  var StarSize := MulDiv(30, CurrentPPI, 96);
  var StarX := Cell.Right - Pad - StarSize;
  if PlayerIsArabic then StarX := Cell.Left + Pad;
  if not PtInRect(Rect(StarX, Cell.Top + Pad, StarX + StarSize, Cell.Top + Pad + StarSize),
    Point(X, Y)) then Exit;
  var CanSelect: Boolean;
  SelectLibraryCell(Sender, Column, Row, CanSelect);
  if CanSelect then btnFavClick(nil);
end;

procedure TFrmIPTV.LayoutLibrary;
begin
  if not Assigned(FLibraryGrid) or not FLibraryGrid.Visible then Exit;
  if Assigned(FChannelCard) and (FLibraryGrid.ClientWidth <= 320) and (FChannelCard.ClientWidth > 400) then
    FChannelCard.Realign;
  var Width := Max(1, FLibraryGrid.ClientWidth - MulDiv(20, CurrentPPI, 96));
  var Columns := Max(1, Width div Max(1, MulDiv(158, CurrentPPI, 96)));
  var ColW := Max(1, Width div Columns);
  var RowHeight := 132;
  if FSection in [2, 3] then RowHeight := 218;
  var RowH := MulDiv(RowHeight, CurrentPPI, 96);
  var NewRows := Max(1, (FFilteredChannels.Count + Columns - 1) div Columns);
  if FLibraryGrid.ColCount <> Columns then FLibraryGrid.ColCount := Columns;
  if FLibraryGrid.DefaultColWidth <> ColW then FLibraryGrid.DefaultColWidth := ColW;
  if FLibraryGrid.DefaultRowHeight <> RowH then FLibraryGrid.DefaultRowHeight := RowH;
  if FLibraryGrid.RowCount <> NewRows then FLibraryGrid.RowCount := NewRows;
  UpdateLibraryScroll(nil);
  var AfterWidth := Max(1, FLibraryGrid.ClientWidth - MulDiv(20, CurrentPPI, 96));
  if AfterWidth <> Width then
  begin
    Columns := Max(1, AfterWidth div Max(1, MulDiv(158, CurrentPPI, 96)));
    ColW := Max(1, AfterWidth div Columns);
    NewRows := Max(1, (FFilteredChannels.Count + Columns - 1) div Columns);
    if FLibraryGrid.ColCount <> Columns then FLibraryGrid.ColCount := Columns;
    if FLibraryGrid.DefaultColWidth <> ColW then FLibraryGrid.DefaultColWidth := ColW;
    if FLibraryGrid.RowCount <> NewRows then FLibraryGrid.RowCount := NewRows;
    UpdateLibraryScroll(nil);
  end;
end;

procedure TFrmIPTV.UpdateLibraryScroll(Sender: TObject);
begin
  if not Assigned(FLibraryScroll) or not FLibraryGrid.Visible then Exit;
  if (GetWindowLong(FLibraryGrid.Handle, GWL_STYLE) and (WS_VSCROLL or WS_HSCROLL)) <> 0 then ShowScrollBar(FLibraryGrid.Handle, SB_BOTH, False);
  var Rows := Max(1, FLibraryGrid.ClientHeight div Max(1, FLibraryGrid.DefaultRowHeight));
  var BarWidth := MulDiv(16, CurrentPPI, 96);
  var ShowBar := FLibraryGrid.RowCount > Rows;
  var BaseMargin := MulDiv(8, CurrentPPI, 96);
  if ShowBar then
  begin
    if PlayerIsArabic then
    begin
      if FLibraryGrid.Margins.Left <> BaseMargin + BarWidth then FLibraryGrid.Margins.Left := BaseMargin + BarWidth;
    end
    else
    begin
      if FLibraryGrid.Margins.Right <> BaseMargin + BarWidth then FLibraryGrid.Margins.Right := BaseMargin + BarWidth;
    end;
  end
  else
  begin
    if FLibraryGrid.Margins.Left <> BaseMargin then FLibraryGrid.Margins.Left := BaseMargin;
    if FLibraryGrid.Margins.Right <> BaseMargin then FLibraryGrid.Margins.Right := BaseMargin;
  end;
  var BarX := FLibraryGrid.BoundsRect.Right;
  if PlayerIsArabic then BarX := FLibraryGrid.BoundsRect.Left - BarWidth;
  if (FLibraryScroll.Left <> BarX) or (FLibraryScroll.Top <> FLibraryGrid.Top) or
     (FLibraryScroll.Width <> BarWidth) or (FLibraryScroll.Height <> FLibraryGrid.Height) then
    FLibraryScroll.SetBounds(BarX, FLibraryGrid.Top, BarWidth, FLibraryGrid.Height);
  FLibraryScroll.UpdateRows(FLibraryGrid.TopRow, Rows, FLibraryGrid.RowCount);
  if FLibraryScroll.Visible <> ShowBar then
  begin
    FLibraryScroll.Visible := ShowBar;
    if ShowBar then FLibraryScroll.BringToFront;
  end;
end;

procedure TFrmIPTV.ScrollLibrary(Sender: TObject);
begin
  FLastCatalogInteraction := GetTickCount64;
  FLibraryGrid.TopRow := FLibraryScroll.FTopRow;
end;

procedure TFrmIPTV.SelectLibraryCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
begin
  if PlayerIsArabic then ACol := FLibraryGrid.ColCount - ACol - 1;
  var Index := ARow * FLibraryGrid.ColCount + ACol;
  CanSelect := Index < FFilteredChannels.Count;
  if CanSelect then
  begin
    lstChannels.ItemIndex := Index;
    UpdateChannelInfoPanel;
  end;
end;

procedure TFrmIPTV.DrawLibraryCell(Sender: TObject; ACol, ARow: Longint;
  Cell: TRect; State: TGridDrawState);
begin
  var Surface := FLibraryGrid.Canvas;
  Surface.Brush.Color := DP_COLOR_SURFACE;
  Surface.FillRect(Cell);
  if PlayerIsArabic then ACol := FLibraryGrid.ColCount - ACol - 1;
  var Index := ARow * FLibraryGrid.ColCount + ACol;
  if Index >= FFilteredChannels.Count then Exit;
  var Channel := FFilteredChannels[Index];
  var Pad := MulDiv(7, CurrentPPI, 96);
  InflateRect(Cell, -Pad, -Pad);
  Surface.Brush.Color := DP_COLOR_ELEVATED;
  Surface.Pen.Color := DP_COLOR_BORDER;
  if Index = lstChannels.ItemIndex then Surface.Pen.Color := DP_COLOR_ACCENT;
  Surface.RoundRect(Cell.Left, Cell.Top, Cell.Right, Cell.Bottom, 18, 18);
  var Art := Rect(Cell.Left + Pad, Cell.Top + Pad, Cell.Right - Pad,
    Cell.Bottom - MulDiv(46, CurrentPPI, 96));
  Surface.Brush.Color := DP_COLOR_BG;
  Surface.FillRect(Art);
  var Logo: TGPImage := nil;
  if Assigned(FLogoCache) then FLogoCache.TryGetValue(Channel.LogoUrl, Logo);
  if Assigned(Logo) and (Logo.GetWidth > 0) and (Logo.GetHeight > 0) then
  begin
    var Ratio := Min(Art.Width / Logo.GetWidth, Art.Height / Logo.GetHeight);
    var W := Round(Logo.GetWidth * Ratio);
    var H := Round(Logo.GetHeight * Ratio);
    var Graphic := TGPGraphics.Create(Surface.Handle);
    try
      Graphic.DrawImage(Logo, Art.Left + (Art.Width - W) div 2,
        Art.Top + (Art.Height - H) div 2, W, H);
    finally Graphic.Free; end;
  end
  else
  begin
    EnsureChannelLogoAsync(Channel.LogoUrl);
    Surface.Brush.Style := bsClear;
    Surface.Font.Name := PlayerUIFont;
    Surface.Font.Size := 10;
    Surface.Font.Color := DP_COLOR_MUTED;
    var Kind := Translate(ClassifyMediaKind(Channel));
    DrawText(Surface.Handle, PChar(Kind), Length(Kind), Art,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
  end;
  Surface.Brush.Style := bsClear;
  Surface.Font.Name := PlayerUIFont;
  Surface.Font.Size := 9;
  Surface.Font.Style := [];
  Surface.Font.Color := DP_COLOR_TEXT;
  var TextRect := Rect(Cell.Left + Pad, Art.Bottom + Pad, Cell.Right - Pad, Cell.Bottom - Pad);
  var Flags := DT_WORDBREAK or DT_END_ELLIPSIS or DT_NOPREFIX;
  if PlayerIsArabic then Flags := Flags or DT_RIGHT or DT_RTLREADING;
  DrawText(Surface.Handle, PChar(Channel.Name), Length(Channel.Name), TextRect, Flags);
  var StarSize := MulDiv(30, CurrentPPI, 96);
  var StarX := Cell.Right - StarSize;
  if PlayerIsArabic then StarX := Cell.Left;
  var StarRect := Rect(StarX, Cell.Top, StarX + StarSize, Cell.Top + StarSize);
  Surface.Font.Name := 'Segoe UI Symbol';
  Surface.Font.Size := 12;
  Surface.Font.Color := DP_COLOR_MUTED;
  var StarText := WideChar($2606);
  if Channel.IsFavorite then
  begin
    StarText := WideChar($2605);
    Surface.Font.Color := DP_COLOR_ACCENT;
  end;
  DrawText(Surface.Handle, @StarText, 1, StarRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

procedure TFrmIPTV.LoadFavorites;
var
  Ini: TAppSettings;
  FavList: TStringList;
  I, J: Integer;
begin
  Ini := TAppSettings.Create(GetIniPath);
  FavList := TStringList.Create;
  var FavSet := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  try
    Ini.ReadSection('Favorites', FavList);
    for J := 0 to FavList.Count - 1 do
      FavSet.AddOrSetValue(FavList[J], True);
    if FavSet.Count > 0 then
      for I := 0 to FChannels.Count - 1 do
        if FavSet.ContainsKey(FChannels[I].StreamUrl) or FavSet.ContainsKey(FChannels[I].Name) then
          FChannels[I].IsFavorite := True;
  finally
    FavSet.Free;
    FavList.Free;
    Ini.Free;
  end;
end;

procedure TFrmIPTV.SaveFavorites;
var
  Ini: TAppSettings;
  I: Integer;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    Ini.EraseSection('Favorites');
    for I := 0 to FChannels.Count - 1 do
    begin
      if FChannels[I].IsFavorite then
        Ini.WriteString('Favorites', FChannels[I].StreamUrl, FChannels[I].Name);
    end;
  finally
    Ini.Free;
  end;
end;

function TFrmIPTV.SelectedChannel: TIPTVChannel;
begin
  Result := nil;
  if (lstChannels.ItemIndex >= 0) and (lstChannels.ItemIndex < FFilteredChannels.Count) then
    Result := FFilteredChannels[lstChannels.ItemIndex];
end;

procedure TFrmIPTV.edtSearchChange(Sender: TObject);
begin
  FilterChannels;
end;

procedure TFrmIPTV.edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    edtSearch.Text := '';
    Key := 0;
  end
  else if (Key = VK_DOWN) and (lstChannels.Count > 0) then
  begin
    lstChannels.SetFocus;
    if lstChannels.ItemIndex < 0 then
      lstChannels.ItemIndex := 0;
    Key := 0;
  end;
end;

procedure TFrmIPTV.lstChannelsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
    begin
      btnWatchClick(nil);
      Key := 0;
    end;
    VK_SPACE, Ord('F'):
    begin
      btnFavClick(nil);
      Key := 0;
    end;
    Ord('H'), Ord('C'):
    begin
      btnCheckHealthClick(nil);
      Key := 0;
    end;
  end;
end;

procedure TFrmIPTV.lstCategoriesClick(Sender: TObject);
var
  CatID: NativeInt;
  NextSection: Integer;
begin
  if lstCategories.ItemIndex >= 0 then
  begin
    CatID := NativeInt(lstCategories.Items.Objects[lstCategories.ItemIndex]);
    NextSection := FSection;
    case CatID of
      1: NextSection := 4; // Favorites
      2: NextSection := 0; // Home / All Channels
      3: NextSection := 1; // Live TV
      4: NextSection := 2; // Movies / VOD
      5: NextSection := 3; // Series
    else
      if NextSection = 4 then NextSection := 0;
    end;
    if (lstCategories.ItemIndex = FLastAppliedCatIndex) and (NextSection = FLastAppliedSection) then
      Exit;
    FSection := NextSection;
    for var Index := 0 to High(FLibrarySections) do
      TModernVectorButton(FLibrarySections[Index]).IsActive := Index = FSection;
    if (FSection >= 0) and (FSection <= High(FLibrarySections)) then
      FChannelHeading.Caption := FLibrarySections[FSection].Caption;
  end;
  FilterChannels;
end;

procedure TFrmIPTV.lstChannelsClick(Sender: TObject);
begin
  UpdateChannelInfoPanel;
end;

procedure TFrmIPTV.UpdateChannelInfoPanel;
var
  Ch: TIPTVChannel;
  FmtBadge, HealthStr: string;
begin
  Ch := SelectedChannel;
  if Ch = nil then
  begin
    lblInfoName.Caption := Translate('Select a Channel...');
    lblInfoEPG.Caption := Translate('EPG: No channel selected');
    lblInfoUrl.Caption := '';
    lblInfoBadge.Caption := '';
    btnFav.Caption := Translate('Add to Favorites');
    Exit;
  end;

  lblInfoName.Caption := Ch.Name;

  // EPG Program Info (IPTVnator)
  if (FGuide <> nil) and (Ch.TvgId <> '') then
  begin
    var CurProg := FGuide.GetCurrentProgram(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
    if CurProg.HasProgram then
    begin
      var ProgStr := Format(Translate('NOW: %s (%s - %s) [%d%%]'), [
        CurProg.CurrentTitle,
        FormatDateTime('hh:nn', CurProg.CurrentStartLocal),
        FormatDateTime('hh:nn', CurProg.CurrentEndLocal),
        CurProg.ProgressPercent
      ]);
      if CurProg.NextTitle <> '' then
        ProgStr := ProgStr + '  |  ' + Format(Translate('NEXT: %s (%s)'), [
          CurProg.NextTitle,
          FormatDateTime('hh:nn', CurProg.NextStartLocal)
        ]);
      lblInfoEPG.Caption := ProgStr;
    end
    else
    begin
      var Desc := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
      if Desc <> '' then
        lblInfoEPG.Caption := Translate('UPCOMING:') + ' ' + StringReplace(Trim(Desc), sLineBreak, '  |  ', [rfReplaceAll])
      else
        lblInfoEPG.Caption := Format(Translate('Category: %s | EPG ID: %s'), [Ch.Group, Ch.TvgId]);
    end;
  end
  else if Ch.Group <> '' then
    lblInfoEPG.Caption := Format(Translate('Category: %s | EPG ID: %s'), [Ch.Group, Ch.TvgId])
  else
    lblInfoEPG.Caption := Translate('No programme guide loaded');

  lblInfoUrl.Caption := Ch.Group;

  if ClassifyMediaKind(Ch) = 'Series' then
    FmtBadge := Translate('Series')
  else if Pos('.m3u8', LowerCase(Ch.StreamUrl)) > 0 then
    FmtBadge := Translate('[HLS Live Stream]')
  else if Pos('.ts', LowerCase(Ch.StreamUrl)) > 0 then
    FmtBadge := Translate('[MPEG-TS Live Stream]')
  else if Pos('.mp4', LowerCase(Ch.StreamUrl)) > 0 then
    FmtBadge := Translate('[VOD Movie MP4]')
  else
    FmtBadge := Translate(ClassifyMediaKind(Ch));

  case Ch.Health of
    chOnline:   HealthStr := Format(Translate('ONLINE (%dms)'), [Ch.HealthLatencyMs]);
    chOffline:  HealthStr := Translate('OFFLINE (Broken Stream)');
    chChecking: HealthStr := Translate('CHECKING...');
  else
    HealthStr := Translate('Stream Health: Untested');
  end;

  lblInfoBadge.Caption := Format('%s  |  %s', [HealthStr, FmtBadge]);

  if Ch.IsFavorite then
    btnFav.Caption := Translate('Remove Favorite')
  else
    btnFav.Caption := Translate('Add to Favorites');
end;

procedure TFrmIPTV.lstChannelsDblClick(Sender: TObject);
begin
  btnWatchClick(Sender);
end;

procedure TFrmIPTV.btnWatchClick(Sender: TObject);
begin
  PlayChannel(SelectedChannel);
end;

procedure TFrmIPTV.PlayChannel(Ch: TIPTVChannel);
var
  Opts: TStringList;
begin
  if Ch = nil then Exit;

  if StartsText('stalker-cmd://', Ch.StreamUrl) then
  begin
    if (FStalkerPortal = '') or (FStalkerMAC = '') then
    begin
      PlayerMessage('Reconnect to the portal before playing this channel.');
      Exit;
    end;
    if Assigned(FrmMain) then
    begin
      RememberChannel(Ch);
      FrmMain.WatchStalkerChannel(FStalkerPortal, FStalkerMAC,
        TNetEncoding.URL.Decode(Copy(Ch.StreamUrl, Length('stalker-cmd://') + 1, MaxInt)), Ch.Name);
      Close;
    end;
    Exit;
  end;

  if Assigned(FrmMain) then
  begin
    RememberChannel(Ch);
    Opts := TStringList.Create;
    try
      Opts.Add(':network-caching=1500');
      FrmMain.WatchPlaylistStream(Ch.StreamUrl, Ch.Name, Opts);
    finally
      Opts.Free;
    end;
    FrmMain.ShowOSD('IPTV Live: ' + Ch.Name);
    Close;
  end;
end;

procedure TFrmIPTV.btnRecordStreamClick(Sender: TObject);
var
  Ch: TIPTVChannel;
  Opts: TStringList;
  RecDir, RecFile: string;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;

  if Assigned(FrmMain) then
  begin
    RecDir := PlayerDataPath('recordings');
    System.SysUtils.ForceDirectories(RecDir);
    RecFile := TPath.Combine(RecDir, Format('IPTV_%s_%s.ts', [
      TRegEx.Replace(Ch.Name, '[^\w\-]', '_'),
      FormatDateTime('yyyymmdd_hhnnss', Now)
    ]));

    Opts := TStringList.Create;
    try
      Opts.Add(':network-caching=3000');
      Opts.Add(':http-user-agent=IPTVSmartersPlayer');
      Opts.Add(Format(':sout=#duplicate{dst=display,dst=std{access=file,mux=ts,dst=''%s''}}', [RecFile]));
      FrmMain.PlayFile(Ch.StreamUrl, Opts);
    finally
      Opts.Free;
    end;
    FrmMain.ShowOSD('Recording IPTV Live: ' + ExtractFileName(RecFile));
    Close;
  end;
end;

procedure TFrmIPTV.btnEPGClick(Sender: TObject);
var Ch: TIPTVChannel; Text: string; Dialog: TOpenDialog;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;
  Text := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
  if Text <> '' then
  begin
    PlayerMessage(Ch.Name + sLineBreak + sLineBreak + Text);
    Exit;
  end;
  if (FGuideURL <> '') and (FRequest = nil) then
  begin
    FLoadingGuide := True;
    DownloadAndParseM3U(FGuideURL);
    FGuideURL := '';
    Exit;
  end;
  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Title := 'Import an XMLTV programme guide';
    Dialog.Filter := 'XMLTV guide (*.xml)|*.xml';
    if not Dialog.Execute then Exit;
    try
      FGuide.LoadXML(TFile.ReadAllText(Dialog.FileName, TEncoding.UTF8));
      Text := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
      if Text = '' then Text := 'No current programmes match this channel ID in the selected guide.';
      PlayerMessage(Ch.Name + sLineBreak + sLineBreak + Text);
    except on E: Exception do PlayerMessage('The programme guide could not be read. Select a valid XMLTV file.'); end;
  finally Dialog.Free; end;
end;

procedure TFrmIPTV.CheckStreamHealth(Channel: TIPTVChannel);
begin
  if (Channel = nil) or (Channel.StreamUrl = '') then Exit;
  Channel.Health := chChecking;
  lstChannels.Invalidate;
  UpdateChannelInfoPanel;

  var TargetUrl := Channel.StreamUrl;
  TThread.CreateAnonymousThread(
    procedure
    var
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
      TStart: Cardinal;
      IsOnline: Boolean;
      Latency: Integer;
    begin
      IsOnline := False;
      Latency := 0;
      HTTP := THTTPClient.Create;
      try
        HTTP.ConnectionTimeout := 3000;
        HTTP.ResponseTimeout := 3500;
        HTTP.UserAgent := 'VLC Modern IPTV Engine/1.0';
        TStart := GetTickCount;
        try
          Resp := HTTP.Head(TargetUrl);
          if (Resp = nil) or (Resp.StatusCode = 405) then
            Resp := HTTP.Get(TargetUrl);
          if (Resp <> nil) and ((Resp.StatusCode = 200) or (Resp.StatusCode = 206) or
             ((Resp.StatusCode >= 300) and (Resp.StatusCode < 400))) then
          begin
            IsOnline := True;
            Latency := GetTickCount - TStart;
          end;
        except
          IsOnline := False;
        end;
      finally
        HTTP.Free;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          if IsOnline then
          begin
            Channel.Health := chOnline;
            Channel.HealthLatencyMs := Latency;
          end
          else
          begin
            Channel.Health := chOffline;
            Channel.HealthLatencyMs := 0;
          end;
          Channel.HealthCheckedAt := GetTickCount;
          lstChannels.Invalidate;
          UpdateChannelInfoPanel;
        end
      );
    end
  ).Start;
end;

procedure TFrmIPTV.CheckAllStreamsHealth;
var
  I: Integer;
begin
  if FFilteredChannels.Count = 0 then Exit;
  if Assigned(FrmMain) then
    FrmMain.ShowOSD(Format(Translate('Probing %d IPTV channels health...'), [FFilteredChannels.Count]));

  for I := 0 to FFilteredChannels.Count - 1 do
    FFilteredChannels[I].Health := chChecking;
  lstChannels.Invalidate;

  TThread.CreateAnonymousThread(
    procedure
    var
      I: Integer;
      Ch: TIPTVChannel;
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
      TStart: Cardinal;
      IsOnline: Boolean;
      Latency: Integer;
    begin
      HTTP := THTTPClient.Create;
      try
        HTTP.ConnectionTimeout := 2500;
        HTTP.ResponseTimeout := 3000;
        HTTP.UserAgent := 'VLC Modern IPTV Engine/1.0';

        for I := 0 to FFilteredChannels.Count - 1 do
        begin
          Ch := FFilteredChannels[I];
          if Ch = nil then Continue;
          IsOnline := False;
          Latency := 0;
          TStart := GetTickCount;
          try
            Resp := HTTP.Head(Ch.StreamUrl);
            if (Resp = nil) or (Resp.StatusCode = 405) then
              Resp := HTTP.Get(Ch.StreamUrl);
            if (Resp <> nil) and ((Resp.StatusCode = 200) or (Resp.StatusCode = 206) or
               ((Resp.StatusCode >= 300) and (Resp.StatusCode < 400))) then
            begin
              IsOnline := True;
              Latency := GetTickCount - TStart;
            end;
          except
            IsOnline := False;
          end;

          TThread.Synchronize(nil,
            procedure
            begin
              if IsOnline then
              begin
                Ch.Health := chOnline;
                Ch.HealthLatencyMs := Latency;
              end
              else
              begin
                Ch.Health := chOffline;
                Ch.HealthLatencyMs := 0;
              end;
              Ch.HealthCheckedAt := GetTickCount;
              lstChannels.Invalidate;
            end
          );
        end;
      finally
        HTTP.Free;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          if Assigned(FrmMain) then
            FrmMain.ShowOSD('Channel health check completed');
          UpdateChannelInfoPanel;
        end
      );
    end
  ).Start;
end;

procedure TFrmIPTV.btnCheckHealthClick(Sender: TObject);
begin
  if (SelectedChannel <> nil) and not (GetKeyState(VK_SHIFT) < 0) then
    CheckStreamHealth(SelectedChannel)
  else
    CheckAllStreamsHealth;
end;

procedure TFrmIPTV.btnExportM3UClick(Sender: TObject);
var
  S: TStringList;
  I: Integer;
  Ch: TIPTVChannel;
begin
  if SaveDialogExport.Execute then
  begin
    S := TStringList.Create;
    try
      S.Add('#EXTM3U');
      for I := 0 to FFilteredChannels.Count - 1 do
      begin
        Ch := FFilteredChannels[I];
        S.Add(Format('#EXTINF:-1 tvg-id="%s" tvg-name="%s" group-title="%s" tvg-logo="%s",%s',
          [Ch.TvgId, Ch.Name, Ch.Group, Ch.LogoUrl, Ch.Name]));
        S.Add(Ch.StreamUrl);
      end;
      S.SaveToFile(SaveDialogExport.FileName, TEncoding.UTF8);
      if Assigned(FrmMain) then
        FrmMain.ShowOSD(Format(Translate('Exported %d channels to M3U.'), [FFilteredChannels.Count]));
    finally
      S.Free;
    end;
  end;
end;

procedure TFrmIPTV.btnFavClick(Sender: TObject);
var
  Ch: TIPTVChannel;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;

  Ch.IsFavorite := not Ch.IsFavorite;
  SaveFavorites;
  RebuildCategories;
  lstChannels.Invalidate;
  FLibraryGrid.Invalidate;
  if (FSection = 4) or FHomeHistory then FilterChannels;
  UpdateChannelInfoPanel;
  if Assigned(FrmMain) then
  begin
    if Ch.IsFavorite then
      FrmMain.ShowOSD('Added to Favorites: ' + Ch.Name)
    else
      FrmMain.ShowOSD('Removed from Favorites: ' + Ch.Name);
  end;
end;

procedure TFrmIPTV.btnCopyUrlClick(Sender: TObject);
var
  Ch: TIPTVChannel;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;
  Clipboard.AsText := Ch.StreamUrl;
  if Assigned(FrmMain) then FrmMain.ShowOSD('Stream URL copied to clipboard.');
end;

procedure TFrmIPTV.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmIPTV.btnAddM3UClick(Sender: TObject);
begin
  rbM3UUrl.Checked := True;
  rbConnTypeClick(nil);
  btnSwitchServerClick(nil);
end;

procedure TFrmIPTV.btnConnectXtreamClick(Sender: TObject);
begin
  rbXtream.Checked := True;
  rbConnTypeClick(nil);
  btnSwitchServerClick(nil);
end;

procedure TFrmIPTV.btnOpenLocalM3UClick(Sender: TObject);
begin
  if OpenDialogM3U.Execute then
    ParseM3UFile(OpenDialogM3U.FileName);
end;

procedure TFrmIPTV.btnRefreshClick(Sender: TObject);
begin
  if FStalkerPortal <> '' then
  begin
    BeginStalker(FStalkerPortal, FStalkerMAC);
    Exit;
  end;
  if FLastM3USource <> '' then
  begin
    if StartsText('http://', FLastM3USource) or StartsText('https://', FLastM3USource) then
      DownloadAndParseM3U(FLastM3USource)
    else
      ParseM3UFile(FLastM3USource);
  end
  else
  begin
    FChannels.Clear;
    LoadDefaultStreams;
    LoadFavorites;
    RebuildCategories;
    FilterChannels;
  end;
end;

function IPTVSkinColor(LightColor: TColor; DarkColor: ARGB): ARGB;
begin
  if PlayerLightTheme then Result := MakeGDIColor(LightColor)
  else Result := DarkColor;
end;

procedure TFrmIPTV.lstCategoriesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Canvas: TCanvas;
  Text, LabelText, CountText: string;
  TextR, PillR: TRect;
  IsSel, HasCount: Boolean;
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Path: TGPGraphicsPath;
  R: TRect;
  OpenPos, I, Pad, PillW, PillH: Integer;
begin
  if (Index < 0) or (Index >= lstCategories.Items.Count) then Exit;
  Canvas := lstCategories.Canvas;
  IsSel := (odSelected in State) or (odFocused in State);

  Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(Rect);

  R := Rect;
  lstCategories.ReserveScrollGutter(R);
  InflateRect(R, -4, -2);

  Text := lstCategories.Items[Index];
  LabelText := Text;
  CountText := '';
  HasCount := False;
  if EndsText(')', Text) then
  begin
    OpenPos := LastDelimiter('(', Text);
    if (OpenPos > 2) and (Text[OpenPos - 1] = ' ') then
    begin
      var Candidate := Copy(Text, OpenPos + 1, Length(Text) - OpenPos - 1);
      if Candidate <> '' then
      begin
        HasCount := True;
        for I := 1 to Length(Candidate) do
          if not CharInSet(Candidate[I], ['0'..'9']) then
          begin
            HasCount := False;
            Break;
          end;
        if HasCount then
        begin
          LabelText := Copy(Text, 1, OpenPos - 2);
          CountText := Candidate;
        end;
      end;
    end;
  end;

  Pad := MulDiv(8, CurrentPPI, 96);
  PillR := System.Types.Rect(0, 0, 0, 0);
  if HasCount then
  begin
    Canvas.Font.Name := PlayerUIFont;
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [fsBold];
    PillW := Max(MulDiv(28, CurrentPPI, 96), Canvas.TextWidth(CountText) + MulDiv(14, CurrentPPI, 96));
    PillH := MulDiv(20, CurrentPPI, 96);
    var PillTop := R.Top + (R.Height - PillH) div 2;
    if PlayerIsArabic then
      PillR := System.Types.Rect(R.Left + Pad, PillTop, R.Left + Pad + PillW, PillTop + PillH)
    else
      PillR := System.Types.Rect(R.Right - Pad - PillW, PillTop, R.Right - Pad, PillTop + PillH);
  end;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(R.Left, R.Top, 6, 6, 180, 90);
      Path.AddArc(R.Right - 6, R.Top, 6, 6, 270, 90);
      Path.AddArc(R.Right - 6, R.Bottom - 6, 6, 6, 0, 90);
      Path.AddArc(R.Left, R.Bottom - 6, 6, 6, 90, 90);
      Path.CloseFigure;

      if IsSel then
        Brush := TGPSolidBrush.Create(IPTVSkinColor(DP_COLOR_ACCSOFT, MakeColor(255, 30, 58, 74)))
      else
        Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ELEVATED));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      if IsSel then
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

    if HasCount then
    begin
      var PillRadius := PillR.Height;
      var PillPath := TGPGraphicsPath.Create;
      try
        PillPath.AddArc(PillR.Left, PillR.Top, PillRadius, PillRadius, 90, 180);
        PillPath.AddArc(PillR.Right - PillRadius, PillR.Top, PillRadius, PillRadius, 270, 180);
        PillPath.CloseFigure;
        if IsSel then
          Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ACCENT, 45))
        else
          Brush := TGPSolidBrush.Create(IPTVSkinColor(DP_COLOR_BORDER, MakeColor(255, 50, 54, 62)));
        try
          G.FillPath(Brush, PillPath);
        finally
          Brush.Free;
        end;
      finally
        PillPath.Free;
      end;
    end;
  finally
    G.Free;
  end;

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := PlayerUIFont;
  if HasCount then
  begin
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [];
    if IsSel then Canvas.Font.Color := DP_COLOR_ACCENT
    else Canvas.Font.Color := DP_COLOR_MUTED;
    DrawText(Canvas.Handle, PChar(CountText), Length(CountText), PillR,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
  end;

  Canvas.Font.Size := 9;
  if IsSel then
  begin
    Canvas.Font.Color := DP_COLOR_ACCENT;
    Canvas.Font.Style := [fsBold];
  end
  else
  begin
    Canvas.Font.Color := DP_COLOR_TEXT;
    Canvas.Font.Style := [];
  end;

  TextR := R;
  Inc(TextR.Left, MulDiv(10, CurrentPPI, 96));
  Dec(TextR.Right, MulDiv(10, CurrentPPI, 96));
  if HasCount then
  begin
    if PlayerIsArabic then TextR.Left := PillR.Right + MulDiv(8, CurrentPPI, 96)
    else TextR.Right := PillR.Left - MulDiv(8, CurrentPPI, 96);
  end;
  var TextFlags := DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX;
  if PlayerIsArabic then TextFlags := TextFlags or DT_RIGHT or DT_RTLREADING;
  DrawText(Canvas.Handle, PChar(LabelText), Length(LabelText), TextR, TextFlags);
end;

procedure TFrmIPTV.lstChannelsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Canvas: TCanvas;
  Ch: TIPTVChannel;
  TextR, BadgeR, NumR: TRect;
  IsSel: Boolean;
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Path: TGPGraphicsPath;
  LogoImg: TGPImage;
  R: TRect;
  NumStr, FmtBadge: string;
  RTL: Boolean;
  function RowX(Offset, Width: Integer): Integer;
  begin
    if RTL then Result := R.Right - Offset - Width
    else Result := R.Left + Offset;
  end;
begin
  if (Index < 0) or (Index >= FFilteredChannels.Count) then Exit;
  Ch := FFilteredChannels[Index];
  LogoImg := nil;
  Canvas := lstChannels.Canvas;
  IsSel := (odSelected in State) or (odFocused in State);

  Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(Rect);

  R := Rect;
  lstChannels.ReserveScrollGutter(R);
  InflateRect(R, -4, -3);
  RTL := PlayerIsArabic;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(R.Left, R.Top, 8, 8, 180, 90);
      Path.AddArc(R.Right - 8, R.Top, 8, 8, 270, 90);
      Path.AddArc(R.Right - 8, R.Bottom - 8, 8, 8, 0, 90);
      Path.AddArc(R.Left, R.Bottom - 8, 8, 8, 90, 90);
      Path.CloseFigure;

      if IsSel then
        Brush := TGPSolidBrush.Create(IPTVSkinColor(DP_COLOR_ACCSOFT, MakeColor(255, 35, 45, 55)))
      else
        Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ELEVATED));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      if IsSel then
        Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_ACCENT), 1.5)
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

    if IsSel then
    begin
      Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ACCENT));
      try
        G.FillRectangle(Brush, Single(RowX(2, 4)), Single(R.Top + 6), 4.0, Single(R.Height - 12));
      finally
        Brush.Free;
      end;
    end;

    // Stream Health status dot (IPTVnator)
    case Ch.Health of
      chOnline:   Brush := TGPSolidBrush.Create(MakeColor(255, 16, 185, 129)); // Vibrant Green
      chOffline:  Brush := TGPSolidBrush.Create(MakeColor(255, 239, 68, 68));  // Red
      chChecking: Brush := TGPSolidBrush.Create(MakeColor(255, 245, 158, 11)); // Amber
    else
      Brush := TGPSolidBrush.Create(MakeColor(255, 100, 116, 139)); // Slate Gray
    end;
    try
      G.FillEllipse(Brush, Single(RowX(12, 8)), Single(R.Top + (R.Height div 2) - 4), 8.0, 8.0);
    finally
      Brush.Free;
    end;

    FmtBadge := Translate(ClassifyMediaKind(Ch));
    var BadgeWidth := Max(MulDiv(76, CurrentPPI, 96), Canvas.TextWidth(FmtBadge) + 24);
    BadgeR := System.Types.Rect(R.Right - BadgeWidth - 10, R.Top + 7, R.Right - 10, R.Bottom - 7);
    if RTL then OffsetRect(BadgeR, R.Left + 10 - BadgeR.Left, 0);
    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(BadgeR.Left, BadgeR.Top, 6, 6, 180, 90);
      Path.AddArc(BadgeR.Right - 6, BadgeR.Top, 6, 6, 270, 90);
      Path.AddArc(BadgeR.Right - 6, BadgeR.Bottom - 6, 6, 6, 0, 90);
      Path.AddArc(BadgeR.Left, BadgeR.Bottom - 6, 6, 6, 90, 90);
      Path.CloseFigure;

      Brush := TGPSolidBrush.Create(IPTVSkinColor(DP_COLOR_ACCSOFT, MakeColor(255, 24, 34, 44)));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      Pen := TGPPen.Create(IPTVSkinColor(DP_COLOR_BORDER, MakeColor(255, 45, 75, 100)), 1.0);
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

    // Render cached tvg-logo image if available, or trigger async download
    if Ch.LogoUrl <> '' then
    begin
      LogoImg := nil;
      if (FLogoCache <> nil) and FLogoCache.TryGetValue(Ch.LogoUrl, LogoImg) and (LogoImg <> nil) then
        G.DrawImage(LogoImg, Single(RowX(76, 22)), Single(R.Top + (R.Height - 22) div 2), 22.0, 22.0)
      else
        EnsureChannelLogoAsync(Ch.LogoUrl);
    end;
  finally
    G.Free;
  end;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Name := PlayerUIFont;
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := DP_COLOR_ACCENT;
  DrawText(Canvas.Handle, PChar(FmtBadge), Length(FmtBadge), BadgeR, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

  NumStr := Format('%02d', [Index + 1]);
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [];
  Canvas.Font.Color := DP_COLOR_MUTED;
  var NumberX := RowX(20, 39);
  NumR := System.Types.Rect(NumberX, R.Top, NumberX + 39, R.Bottom);
  var NumberFlags := DT_VCENTER or DT_SINGLELINE;
  if RTL then NumberFlags := NumberFlags or DT_RIGHT;
  DrawText(Canvas.Handle, PChar(NumStr), Length(NumStr), NumR, NumberFlags);

  if Ch.IsFavorite then
  begin
    Canvas.Font.Size := 10;
    Canvas.Font.Color := RGB(255, 204, 0);
    Canvas.TextOut(RowX(61, Canvas.TextWidth('★')), R.Top + (R.Height - Canvas.TextHeight('★')) div 2, '★');
  end;

  Canvas.Font.Size := 10;
  if IsSel then
  begin
    Canvas.Font.Color := DP_COLOR_ACCENT;
    Canvas.Font.Style := [fsBold];
  end
  else
  begin
    Canvas.Font.Color := DP_COLOR_TEXT;
    Canvas.Font.Style := [];
  end;

  TextR := System.Types.Rect(R.Left + 108, R.Top, BadgeR.Left - 10, R.Bottom);
  if LogoImg = nil then
  begin
    Canvas.Font.Size := 7;
    Canvas.Font.Color := DP_COLOR_MUTED;
    Canvas.Font.Style := [fsBold];
    Canvas.TextOut(RowX(80, Canvas.TextWidth('TV')), R.Top + (R.Height - Canvas.TextHeight('TV')) div 2, 'TV');
    Canvas.Font.Size := 10;
    if IsSel then Canvas.Font.Color := DP_COLOR_ACCENT
    else Canvas.Font.Color := DP_COLOR_TEXT;
    if not IsSel then Canvas.Font.Style := [];
  end;
  var NameFlags := DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX;
  if RTL then
  begin
    TextR.Right := R.Right - (TextR.Left - R.Left);
    TextR.Left := BadgeR.Right + 10;
    NameFlags := NameFlags or DT_RIGHT or DT_RTLREADING;
  end;
  DrawText(Canvas.Handle, PChar(Ch.Name), Length(Ch.Name), TextR, NameFlags);
end;

procedure TFrmIPTV.EnsureChannelLogoAsync(const AUrl: string);
begin
  if FClosingForm or (AUrl = '') then Exit;
  if (Assigned(lstChannels.FScroll) and lstChannels.FScroll.FDragging) or
     (Assigned(FLibraryScroll) and FLibraryScroll.FDragging) or
     (GetTickCount64 - FLastCatalogInteraction < 300) then Exit;
  if FLogoCache = nil then FLogoCache := TObjectDictionary<string, TGPImage>.Create([doOwnsValues]);
  if FLogoPending = nil then FLogoPending := TDictionary<string, Boolean>.Create;
  if FLogoCache.ContainsKey(AUrl) or FLogoPending.ContainsKey(AUrl) then Exit;
  if FLogoPending.Count >= 6 then Exit;

  FLogoPending.Add(AUrl, True);
  var CleanArtwork := not FArtworkCleanupStarted;
  FArtworkCleanupStarted := True;
  var WindowAlive: TFunc<Boolean> := FLogoWindowAlive;
  TThread.CreateAnonymousThread(
    procedure
    var
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
      MS: TMemoryStream;
      SA: IStream;
      Img: TGPImage;
    begin
      Img := nil;
      var CacheDirectory := PlayerCachePath('iptv-artwork');
      var CacheFile := TPath.Combine(CacheDirectory, THashSHA2.GetHashString(AUrl) + '.img');
      var Expiration := TTimeZone.Local.ToUniversalTime(Now) - 7;
      if CleanArtwork then
        try
          if TDirectory.Exists(CacheDirectory) then
            for var FileName in TDirectory.GetFiles(CacheDirectory, '*.img') do
              if TFile.GetLastWriteTimeUtc(FileName) <= Expiration then
                Winapi.Windows.DeleteFile(PChar(FileName));
        except
          // Cleanup is opportunistic.
        end;
      try
        if TFile.Exists(CacheFile) and
           (TFile.GetLastWriteTimeUtc(CacheFile) > Expiration) then
        begin

          var CachedBytes := TFile.ReadAllBytes(CacheFile);
          if (Length(CachedBytes) > 0) and (Length(CachedBytes) < 512 * 1024) then
          begin
            MS := TMemoryStream.Create;
            SA := TStreamAdapter.Create(MS, soOwned);
            MS.WriteBuffer(CachedBytes[0], Length(CachedBytes));
            MS.Position := 0;
            Img := TGPImage.Create(SA);
            if Img.GetLastStatus <> Ok then FreeAndNil(Img);
          end;
        end;
      except
        FreeAndNil(Img);
      end;

      if Img = nil then
      begin
        HTTP := THTTPClient.Create;
        try
          HTTP.ConnectionTimeout := 2500;
          HTTP.ResponseTimeout := 3500;
          HTTP.UserAgent := 'VLCModern/1.0';
          try
            Resp := HTTP.Get(AUrl);
            if (Resp <> nil) and (Resp.StatusCode = 200) and
               (Resp.ContentStream.Size > 0) and (Resp.ContentStream.Size < 512 * 1024) then
            begin
              MS := TMemoryStream.Create;
              SA := TStreamAdapter.Create(MS, soOwned);
              Resp.ContentStream.Position := 0;
              MS.CopyFrom(Resp.ContentStream, 0);
              MS.Position := 0;
              Img := TGPImage.Create(SA);
              if Img.GetLastStatus <> Ok then FreeAndNil(Img)
              else
                try
                  TDirectory.CreateDirectory(ExtractFileDir(CacheFile));
                  var TempFile := CacheFile + '.' + TPath.GetRandomFileName;
                  try
                    MS.SaveToFile(TempFile);
                    MoveFileEx(PChar(TempFile), PChar(CacheFile), MOVEFILE_REPLACE_EXISTING);
                  finally
                    if TFile.Exists(TempFile) then TFile.Delete(TempFile);
                  end;
                except
                  // A cache write failure does not prevent displaying the artwork.
                end;
            end;
          except
            FreeAndNil(Img);
          end;
        finally
          HTTP.Free;
        end;
      end;

      TThread.Queue(nil,
        TThreadProcedure(procedure
        begin
          if WindowAlive() then
          begin
            if not FLogoCache.ContainsKey(AUrl) then
              FLogoCache.Add(AUrl, Img)
            else
              FreeAndNil(Img);
            FLogoPending.Remove(AUrl);
            if Img <> nil then
            begin
              if Assigned(FFeaturedChannel) and (FFeaturedChannel.LogoUrl = AUrl) then FHeroArt.Invalidate;
              if FLibraryGrid.Visible and not FLibraryScroll.FDragging then
              begin
                var Columns := FLibraryGrid.ColCount;
                var FirstRow := FLibraryGrid.TopRow;
                var LastRow := Min(FLibraryGrid.RowCount - 1,
                  FirstRow + FLibraryGrid.VisibleRowCount);
                for var GridIndex := FirstRow * Columns to
                    Min(FFilteredChannels.Count - 1, (LastRow + 1) * Columns - 1) do
                  if FFilteredChannels[GridIndex].LogoUrl = AUrl then
                  begin
                    FLibraryGrid.Invalidate;
                    Break;
                  end;
              end;
              if not lstChannels.Visible or lstChannels.FScroll.FDragging then Exit;
              var First := Max(0, lstChannels.TopIndex);
              var Last := Min(FFilteredChannels.Count - 1, First +
                lstChannels.ClientHeight div Max(1, lstChannels.ItemHeight));
              for var Index := First to Last do
                if FFilteredChannels[Index].LogoUrl = AUrl then
                begin
                  var Row := lstChannels.ItemRect(Index);
                  InvalidateRect(lstChannels.Handle, @Row, False);
                end;
            end;
          end
          else
            Img.Free;
        end));
    end).Start;
end;

initialization
  RegisterClass(TIPTVListBox);

end.
