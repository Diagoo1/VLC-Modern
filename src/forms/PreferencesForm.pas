unit PreferencesForm;

interface

uses SettingsStore,
  Winapi.Windows, Winapi.Messages, Winapi.ShlObj, System.SysUtils, System.Classes, System.IniFiles, System.Math,
  System.Generics.Collections, System.Win.Registry, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, CurvedControls, AdvancedSettings, SettingsNavigation;

type
  TFrmPreferences = class(TForm)
    pnlLeft: TPanel;
    lblCategoriesTitle: TLabel;
    treeCategories: TTreeView;
    pnlMain: TPanel;
    PageControlPages: TPageControl;
    pnlBottom: TPanel;
    btnReset: TButton;
    btnApply: TButton;
    btnSave: TButton;
    btnCancel: TButton;

    // Tab 0: General
    tabGeneral: TTabSheet;
    grpStartup: TGroupBox;
    chkSingleInstance: TCheckBox;
    lblTheme: TLabel;
    cboTheme: TComboBox;
    chkRememberSize: TCheckBox;
    chkStartFullscreen: TCheckBox;
    chkBossKeyHide: TCheckBox;
    chkCinemaMode: TCheckBox;
    chkShowMenuBar: TCheckBox;
    chkShowTitleBar: TCheckBox;
    grpOSD: TGroupBox;
    chkShowOSD: TCheckBox;
    chkShowFilename: TCheckBox;
    lblOsdDuration: TLabel;
    cboOsdDuration: TComboBox;
    lblOsdSize: TLabel;
    cboOsdSize: TComboBox;
    grpMouse: TGroupBox;
    lblSingleClick: TLabel;
    cboSingleClick: TComboBox;
    lblDblClick: TLabel;
    cboDblClick: TComboBox;
    chkWheelVolume: TCheckBox;

    // Tab 1: Playback
    tabPlayback: TTabSheet;
    grpPlaybackGen: TGroupBox;
    lblResume: TLabel;
    cboResume: TComboBox;
    lblAfterPlayback: TLabel;
    cboAfterPlayback: TComboBox;
    chkSaveHistory: TCheckBox;
    chkAutoPlayNext: TCheckBox;
    grpSpeedJump: TGroupBox;
    lblJumpShort: TLabel;
    cboJumpShort: TComboBox;
    lblJumpMedium: TLabel;
    cboJumpMedium: TComboBox;
    lblJumpLong: TLabel;
    cboJumpLong: TComboBox;
    chkScaletempo: TCheckBox;
    chkShowSpeedOSD: TCheckBox;

    // Tab 2: Video
    tabVideo: TTabSheet;
    grpHardware: TGroupBox;
    lblHwAccel: TLabel;
    cboHwAccel: TComboBox;
    chkZeroCopy: TCheckBox;
    grpVideoOut: TGroupBox;
    lblVout: TLabel;
    cboVout: TComboBox;
    lblDeinterlace: TLabel;
    cboDeinterlace: TComboBox;
    chkAspectAuto: TCheckBox;

    // Tab 3: Audio
    tabAudio: TTabSheet;
    grpAudioOut: TGroupBox;
    lblAout: TLabel;
    cboAout: TComboBox;
    lblChannels: TLabel;
    cboChannels: TComboBox;
    chkRememberVolume: TCheckBox;
    chkNormalizer: TCheckBox;
    grpVolumeDef: TGroupBox;
    lblDefaultVolume: TLabel;
    lblDefVolVal: TLabel;
    tbDefaultVol: TTrackBar;

    // Tab 4: Subtitles
    tabSubtitles: TTabSheet;
    grpSubStyle: TGroupBox;
    lblSubFont: TLabel;
    cboSubFont: TComboBox;
    lblSubSize: TLabel;
    cboSubSize: TComboBox;
    lblSubEncoding: TLabel;
    cboSubEncoding: TComboBox;
    chkSubBold: TCheckBox;
    chkSubAutoLoad: TCheckBox;

    // Tab 5: Network & IPTV
    tabNetwork: TTabSheet;
    grpStreamBuffer: TGroupBox;
    lblNetCache: TLabel;
    cboNetCache: TComboBox;
    lblLiveEdge: TLabel;
    cboLiveEdge: TComboBox;
    chkHlsHardware: TCheckBox;
    grpUserAgent: TGroupBox;
    lblUserAgent: TLabel;
    cboUserAgent: TComboBox;
    chkPassReferer: TCheckBox;

    // Tab 6: Associations
    tabAssociations: TTabSheet;
    grpFileTypes: TGroupBox;
    chkAssocVideo: TCheckBox;
    chkAssocAudio: TCheckBox;
    chkAssocPlaylists: TCheckBox;
    btnRegisterAssoc: TButton;

    procedure FormCreate(Sender: TObject);
    procedure treeCategoriesChange(Sender: TObject; Node: TTreeNode);
    procedure btnResetClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tbDefaultVolChange(Sender: TObject);
    procedure btnRegisterAssocClick(Sender: TObject);
  private
    FNavigation: TSettingsNavigation;
    FRightColumns: TList<TControl>;
    FLayoutBusy: Boolean;
    FEnterFullscreen: TCheckBox;
    FPageHeader: TPanel;
    FPageTitle, FPageHint: TLabel;
    FAdvanced: TAdvancedSettings;
    FPreparingAdvanced: Boolean;
    FPageLoaded: array[0..6] of Boolean;
    FEffectsPage: TTabSheet;
    FEffectsBounds: TRect;
    FEffectsBorder: TFormBorderStyle;
    FEffectsMinWidth, FEffectsMinHeight: Integer;
    procedure PrepareActivePage(Sender:TObject);
    procedure LoadPagePreferences(PageIndex:Integer);
    procedure RememberColumns(Page:TTabSheet);
    procedure NavigationClick(Sender: TObject);
    procedure AttachEffects(Sender: TObject);
    procedure DetachEffects(Sender: TObject);
    procedure LayoutSettings(Sender: TObject);
    function GetIniPath: string;
  public
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure EnsurePage(PageIndex:Integer);
    procedure LoadPreferences;
    procedure SavePreferences;
  end;

var
  FrmPreferences: TFrmPreferences;

implementation

uses FileAssociations, PlayerDialogs, MainForm, EffectsForm, PageTransitions;

{$R *.dfm}

type TDeferredPageAccess=class(TTabSheet);

procedure SelectStoredChoice(Combo:TComboBox; const Value:string);
begin
  var Index:=Combo.Items.IndexOf(Value);
  if Index<0 then Index:=Combo.Items.Add(Value);
  Combo.ItemIndex:=Index;
end;

procedure TFrmPreferences.AfterConstruction;
begin
  inherited;
  Constraints.MinWidth := MulDiv(880, CurrentPPI, 96);
  Constraints.MinHeight := MulDiv(640, CurrentPPI, 96);
  ClientWidth := MulDiv(960, CurrentPPI, 96);
  ClientHeight := MulDiv(660, CurrentPPI, 96);
  pnlLeft.Width := MulDiv(262, CurrentPPI, 96);
  FEnterFullscreen:=TCheckBox.Create(Self);
  FEnterFullscreen.Parent:=grpMouse;
  FEnterFullscreen.Caption:='Enter toggles fullscreen';
  FEnterFullscreen.SetBounds(280,chkWheelVolume.Top,250,24);
  tabNetwork.Caption := 'Network and TV';
  FPageLoaded[0]:=True;
  for var Caption in ['Video processing','Audio leveling','Subtitle appearance'] do
  begin
    var Page:=TTabSheet.Create(Self); Page.PageControl:=PageControlPages; Page.Caption:=Caption;
  end;
  FEffectsPage := TTabSheet.Create(Self);
  FEffectsPage.PageControl := PageControlPages;
  FEffectsPage.Caption := 'Effects and synchronization';
  for var I := 0 to PageControlPages.PageCount - 1 do PageControlPages.Pages[I].TabVisible := False;
  treeCategories.Visible := False;
  FNavigation := TSettingsNavigation.Create(Self);
  FNavigation.Parent := pnlLeft;
  FNavigation.Font.Size := 10;
  FNavigation.OnClick := NavigationClick;
  for var I := 0 to PageControlPages.PageCount - 2 do
    FNavigation.Items.Add(PageControlPages.Pages[I].Caption);
  FNavigation.Items.Add('Equalizer and audio filters');
  FNavigation.Items.Add('Picture adjustments');
  FNavigation.Items.Add('Audio and subtitle timing');
  FNavigation.ItemIndex := 0;
  PageControlPages.ActivePageIndex := 0;
  lblCategoriesTitle.Visible := False;
  FPageHeader := TPanel.Create(Self);
  FPageHeader.Parent := pnlMain;
  FPageHeader.Align := alTop;
  FPageHeader.Height := MulDiv(68, CurrentPPI, 96);
  FPageHeader.BevelOuter := bvNone;
  FPageTitle := TLabel.Create(Self);
  FPageTitle.Parent := FPageHeader;
  FPageTitle.SetBounds(MulDiv(22, CurrentPPI, 96), MulDiv(16, CurrentPPI, 96), 500, 30);
  FPageTitle.Font.Size := 18;
  FPageTitle.Font.Style := [fsBold];
  FPageTitle.Caption := 'General';
  FPageHint := TLabel.Create(Self);
  FPageHint.Parent := FPageHeader;
  FPageHint.SetBounds(MulDiv(23, CurrentPPI, 96), MulDiv(48, CurrentPPI, 96), 600, 20);
  FPageHint.Caption := 'Make the player feel like yours.';
  OnShow := AttachEffects;
  OnHide := DetachEffects;
  FRightColumns:=TList<TControl>.Create;
  RememberColumns(tabGeneral);
  PageControlPages.OnChange:=PrepareActivePage;
  LoadPagePreferences(0);
  OnResize := LayoutSettings;
  LayoutSettings(nil);
  ApplyPlayerAppearance(Self);
  FNavigation.DoubleBuffered := True;
  FPageHint.Font.Color := DP_COLOR_MUTED;
  lblCategoriesTitle.Font.Color := DP_COLOR_MUTED;
end;

procedure TFrmPreferences.NavigationClick(Sender: TObject);
const Hints: array[0..12] of string = (
  'Window behavior, on-screen messages and mouse controls.',
  'Resume playback, choose jump distances and playback behavior.',
  'Decoder, video output and picture framing.',
  'Output, volume, preferred language and audio tracks.',
  'Subtitle fonts, language, placement and tracks.',
  'Stream buffering and network request options.',
  'Choose which media types open with VLC Modern.',
  'Orientation, sharpening and smooth color gradients.',
  'Keep loudness consistent with ReplayGain.',
  'Text colors, outlines and dual subtitles.',
  'Shape the sound with equalization and audio filters.',
  'Adjust the picture to suit your display.',
  'Keep audio and subtitles in time with the video.');
begin
  if FNavigation.ItemIndex < 0 then Exit;
  EnsurePage(FNavigation.ItemIndex);
  if (FNavigation.ItemIndex in [3,4]) and Assigned(FAdvanced) then FAdvanced.QueueRefresh;
  FPageTitle.Caption := FNavigation.Items[FNavigation.ItemIndex];
  if FNavigation.ItemIndex <= High(Hints) then FPageHint.Caption := Hints[FNavigation.ItemIndex];
  if FNavigation.ItemIndex < FEffectsPage.PageIndex then SelectPageAnimated(PageControlPages, FNavigation.ItemIndex)
  else
  begin
    AttachEffects(nil);
    SelectPageAnimated(PageControlPages, FEffectsPage.PageIndex);
    if Assigned(FrmEffects) then SelectPageAnimated(FrmEffects.PageControl1, FNavigation.ItemIndex - FEffectsPage.PageIndex);
  end;
end;

procedure TFrmPreferences.LayoutSettings(Sender: TObject);
var W, H, Gap, Half, Margin: Integer; Group: TGroupBox; Child: TControl;
begin
  if FLayoutBusy or (FRightColumns=nil) then Exit;
  FLayoutBusy:=True;
  DisableAlign;
  try
  W := MulDiv(96, CurrentPPI, 96);
  H := MulDiv(32, CurrentPPI, 96);
  Gap := MulDiv(12, CurrentPPI, 96);
  pnlBottom.Height := H + Gap * 2;
  btnCancel.SetBounds(ClientWidth - W - Gap, Gap, W, H);
  btnSave.SetBounds(btnCancel.Left - W - Gap, Gap, W, H);
  btnApply.SetBounds(btnSave.Left - W - Gap, Gap, W, H);
  btnReset.SetBounds(Gap, Gap, MulDiv(156, CurrentPPI, 96), H);
  if Assigned(FNavigation) then FNavigation.SetBounds(Gap, Gap,
    pnlLeft.ClientWidth - Gap * 2, pnlLeft.ClientHeight - Gap * 2);
  // Keep both columns aligned and use the available page width. Effects owns
  // its own responsive layout and is deliberately excluded here.
  Margin := MulDiv(18, CurrentPPI, 96);
  for var P := 0 to PageControlPages.PageCount - 1 do
    if PageControlPages.Pages[P] <> FEffectsPage then
      for var I := 0 to PageControlPages.Pages[P].ControlCount - 1 do
        if PageControlPages.Pages[P].Controls[I] is TGroupBox then
        begin
          Group := TGroupBox(PageControlPages.Pages[P].Controls[I]);
          Group.Width := System.Math.Min(PageControlPages.Pages[P].ClientWidth - Gap * 3, MulDiv(760, CurrentPPI, 96));
          Half := Group.ClientWidth div 2;
          for var J := 0 to Group.ControlCount - 1 do
          begin
            Child := Group.Controls[J];
            if (Group <> grpSpeedJump) and FRightColumns.Contains(Child) then
              Child.Left := Half + Margin div 2;
            if (Child is TComboBox) and (Group <> grpSpeedJump) then
              if Child = cboUserAgent then
                Child.Width := Group.ClientWidth - Child.Left - Margin
              else Child.Width := Half - Margin * 3 div 2;
          end;
        end;
  chkWheelVolume.Caption:='Mouse wheel adjusts volume';
  chkWheelVolume.Width:=grpMouse.ClientWidth div 2-Margin*2;
  FEnterFullscreen.Left:=grpMouse.ClientWidth div 2+Margin div 2;
  FEnterFullscreen.Width:=grpMouse.ClientWidth div 2-Margin*2;
  if Assigned(tbDefaultVol) then begin
  tbDefaultVol.Width := grpVolumeDef.ClientWidth - Margin * 2 - MulDiv(64, CurrentPPI, 96);
  lblDefVolVal.Left := grpVolumeDef.ClientWidth - Margin - MulDiv(48, CurrentPPI, 96);
  end;
  if Assigned(cboJumpShort) then begin
  // This section has three columns, not the two-column layout used elsewhere.
  W := (grpSpeedJump.ClientWidth - Margin * 2 - Gap * 2) div 3;
  cboJumpShort.SetBounds(Margin, cboJumpShort.Top, W, cboJumpShort.Height);
  cboJumpMedium.SetBounds(Margin + W + Gap, cboJumpMedium.Top, W, cboJumpMedium.Height);
  cboJumpLong.SetBounds(Margin + (W + Gap) * 2, cboJumpLong.Top, W, cboJumpLong.Height);
  lblJumpShort.Left := cboJumpShort.Left;
  lblJumpMedium.Left := cboJumpMedium.Left;
  lblJumpLong.Left := cboJumpLong.Left;
  end;
  finally
    EnableAlign;
    FLayoutBusy:=False;

  end;
end;

destructor TFrmPreferences.Destroy;
begin
  OnResize:=nil; OnShow:=nil; OnHide:=nil;
  DetachEffects(nil);
  FreeAndNil(FRightColumns);
  inherited;
end;

procedure TFrmPreferences.AttachEffects(Sender: TObject);
begin
  LayoutSettings(nil);
  if (FNavigation=nil) or (FNavigation.ItemIndex<FEffectsPage.PageIndex) then Exit;
  if not Assigned(FrmEffects) then FrmEffects := TFrmEffects.Create(FrmMain);
  if FrmEffects.Parent = FEffectsPage then Exit;
  FEffectsBounds := FrmEffects.BoundsRect;
  FEffectsBorder := FrmEffects.BorderStyle;
  FEffectsMinWidth:=FrmEffects.Constraints.MinWidth; FEffectsMinHeight:=FrmEffects.Constraints.MinHeight;
  FrmEffects.Constraints.MinWidth:=0; FrmEffects.Constraints.MinHeight:=0;
  FrmEffects.Hide;
  FrmEffects.BorderStyle := bsNone;
  FrmEffects.Parent := FEffectsPage;
  FrmEffects.Align := alClient;
  FrmEffects.pnlBottom.Visible := False;
  FrmEffects.Show;
end;

procedure TFrmPreferences.DetachEffects(Sender: TObject);
begin
  if not Assigned(FEffectsPage) or not Assigned(FrmEffects) or (FrmEffects.Parent <> FEffectsPage) then Exit;
  FrmEffects.Hide;
  FrmEffects.Parent := nil;
  FrmEffects.Align := alNone;
  FrmEffects.BorderStyle := FEffectsBorder;
  FrmEffects.Constraints.MinWidth:=FEffectsMinWidth; FrmEffects.Constraints.MinHeight:=FEffectsMinHeight;
  FrmEffects.BoundsRect := FEffectsBounds;
  FrmEffects.pnlBottom.Visible := True;
end;

function TFrmPreferences.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'VLCModern.ini';
end;

procedure TFrmPreferences.RememberColumns(Page:TTabSheet);
begin
  if FRightColumns=nil then Exit;
  for var I:=0 to Page.ControlCount-1 do
    if Page.Controls[I] is TGroupBox then
    begin
      var Group:=TGroupBox(Page.Controls[I]);
      for var J:=0 to Group.ControlCount-1 do
        if (Group.Controls[J].Left>=MulDiv(250,CurrentPPI,96)) and
          not FRightColumns.Contains(Group.Controls[J]) then FRightColumns.Add(Group.Controls[J]);
    end;
end;

procedure TFrmPreferences.EnsurePage(PageIndex:Integer);
var Resource:TResourceStream; Binary:TMemoryStream; Reader:TReader; Store:TAppSettings;
begin
  if (PageIndex>=1) and (PageIndex<=6) and not FPageLoaded[PageIndex] then
  begin
    var Page:=PageControlPages.Pages[PageIndex];
    Resource:=TResourceStream.Create(HInstance,'PREF_'+UpperCase(Page.Name),RT_RCDATA);
    Binary:=TMemoryStream.Create;
    try
      ObjectTextToBinary(Resource,Binary); Binary.Position:=0;
      Reader:=TReader.Create(Binary,4096);
      try
        Reader.Root:=Self; Reader.Owner:=Self; Reader.Parent:=PageControlPages;
        Reader.BeginReferences;
        try Reader.ReadSignature; Reader.ReadComponent(Page); Reader.FixupReferences;
        finally Reader.EndReferences; end;
      finally Reader.Free; end;
    finally Binary.Free; Resource.Free; end;
    // Streamed fragments contain 96-DPI design coordinates. Their parent page
    // already has the monitor PPI, so VCL does not scale these late children.
    TDeferredPageAccess(Page).ScaleControls(CurrentPPI,96);
    FPageLoaded[PageIndex]:=True;
    if PageIndex=1 then begin
      cboResume.Items[0]:='Resume automatically'; cboResume.Items[1]:='Ask before resuming';
      cboResume.Items[2]:='Always start from the beginning';
    end;
    RememberColumns(Page); LoadPagePreferences(PageIndex); LayoutSettings(nil);
  end;
  if (PageIndex in [2,3,4,7,8,9]) and (FAdvanced=nil) and not FPreparingAdvanced then
  begin
    FPreparingAdvanced:=True;
    try
      EnsurePage(2); EnsurePage(3); EnsurePage(4);
      FAdvanced:=TAdvancedSettings.CreatePages(Self,tabVideo,tabAudio,tabSubtitles);
      chkAspectAuto.Visible:=False;
      Store:=TAppSettings.Create(GetIniPath);
      try FAdvanced.Load(Store); finally Store.Free; end;
      for var I:=2 to 9 do RememberColumns(PageControlPages.Pages[I]);
      LayoutSettings(nil);
    finally FPreparingAdvanced:=False; end;
  end;
end;

procedure TFrmPreferences.PrepareActivePage(Sender:TObject);
begin EnsurePage(PageControlPages.ActivePageIndex); end;

procedure TFrmPreferences.LoadPreferences;
begin
  LoadPagePreferences(-1);
  if Assigned(FAdvanced) then begin
    var Store:=TAppSettings.Create(GetIniPath);
    try FAdvanced.Load(Store); finally Store.Free; end;
  end;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
begin
  LoadPreferences;
end;

procedure TFrmPreferences.treeCategoriesChange(Sender: TObject; Node: TTreeNode);
var
  PageIdx: Integer;
begin
  if Node = nil then Exit;
  PageIdx := Integer(Node.Data);
  if (PageIdx >= 7) and Assigned(FEffectsPage) then
  begin
    PageControlPages.ActivePage := FEffectsPage;
    if Assigned(FrmEffects) then FrmEffects.PageControl1.ActivePageIndex := PageIdx - 7;
    Exit;
  end;
  if (PageIdx >= 0) and (PageIdx < PageControlPages.PageCount) then
    PageControlPages.ActivePageIndex := PageIdx;
end;

procedure TFrmPreferences.tbDefaultVolChange(Sender: TObject);
begin
  lblDefVolVal.Caption := Format('%d%%', [tbDefaultVol.Position]);
end;

procedure TFrmPreferences.LoadPagePreferences(PageIndex:Integer);
var
  Ini: TAppSettings;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    // General
    if ((PageIndex<0) or (PageIndex=0)) and FPageLoaded[0] then begin
    cboTheme.ItemIndex := EnsureRange(Ini.ReadInteger('Interface', 'Theme', 0), 0, 2);
    chkSingleInstance.Checked := Ini.ReadBool('General', 'SingleInstance', True);
    chkRememberSize.Checked := Ini.ReadBool('General', 'RememberSize', True);
    chkStartFullscreen.Checked := Ini.ReadBool('General', 'StartFullscreen', False);
    chkBossKeyHide.Checked := Ini.ReadBool('General', 'BossKeyHide', True);
    chkShowMenuBar.Checked := Ini.ReadBool('Interface', 'ShowMenuBar', True);
    chkShowTitleBar.Checked := Ini.ReadBool('Interface', 'ShowTitleBar', True);
    if Assigned(FrmMain) then
    begin
      chkCinemaMode.Checked := FrmMain.IsBorderless;
    end
    else
      chkCinemaMode.Checked := False;
    chkShowOSD.Checked := Ini.ReadBool('General', 'ShowOSD', True);
    chkShowFilename.Checked := Ini.ReadBool('General', 'ShowFilename', True);
    cboOsdDuration.ItemIndex := Ini.ReadInteger('General', 'OsdDuration', 1);
    cboOsdSize.ItemIndex := Ini.ReadInteger('General', 'OsdSize', 1);
    cboSingleClick.ItemIndex := Ini.ReadInteger('General', 'SingleClick', 0);
    cboDblClick.ItemIndex := Ini.ReadInteger('General', 'DblClick', 0);
    chkWheelVolume.Checked := Ini.ReadBool('General', 'WheelVolume', True);
    if FEnterFullscreen<>nil then FEnterFullscreen.Checked:=Ini.ReadBool('General','EnterFullscreen',True);

    end;
    // Playback
    if ((PageIndex<0) or (PageIndex=1)) and FPageLoaded[1] then begin
    cboResume.ItemIndex := Ini.ReadInteger('Playback', 'Resume', 0);
    cboAfterPlayback.ItemIndex := Ini.ReadInteger('Playback', 'AfterPlayback', 0);
    chkSaveHistory.Checked := Ini.ReadBool('Playback', 'SaveHistory', True);
    chkAutoPlayNext.Checked := Ini.ReadBool('Playback', 'AutoPlayNext', False);
    cboJumpShort.ItemIndex := Ini.ReadInteger('Playback', 'JumpShort', 1);
    cboJumpMedium.ItemIndex := Ini.ReadInteger('Playback', 'JumpMedium', 1);
    cboJumpLong.ItemIndex := Ini.ReadInteger('Playback', 'JumpLong', 1);
    chkScaletempo.Checked := Ini.ReadBool('Playback', 'Scaletempo', True);
    chkShowSpeedOSD.Checked := Ini.ReadBool('Playback', 'ShowSpeedOSD', True);

    end;
    // Video
    if ((PageIndex<0) or (PageIndex=2)) and FPageLoaded[2] then begin
    cboHwAccel.ItemIndex := Ini.ReadInteger('Video', 'HwAccel', 0);
    chkZeroCopy.Checked := Ini.ReadBool('Video', 'ZeroCopy', True);
    cboVout.ItemIndex := Ini.ReadInteger('Video', 'Vout', 0);
    cboDeinterlace.ItemIndex := Ini.ReadInteger('Video', 'Deinterlace', 1);
    chkAspectAuto.Checked := Ini.ReadBool('Video', 'AspectAuto', True);

    end;
    // Audio
    if ((PageIndex<0) or (PageIndex=3)) and FPageLoaded[3] then begin
    cboAout.ItemIndex := Ini.ReadInteger('Audio', 'Aout', 0);
    cboChannels.ItemIndex := Ini.ReadInteger('Audio', 'ChannelMode', 0);
    chkRememberVolume.Checked := Ini.ReadBool('Audio', 'RememberVolume', True);
    chkNormalizer.Checked := Ini.ReadBool('Audio', 'Normalizer', False);
    tbDefaultVol.Position := Ini.ReadInteger('Audio', 'DefaultVolume', 100);
    lblDefVolVal.Caption := Format('%d%%', [tbDefaultVol.Position]);

    end;
    // Subtitles
    if ((PageIndex<0) or (PageIndex=4)) and FPageLoaded[4] then begin
    SelectStoredChoice(cboSubFont,Ini.ReadString('Subtitles', 'Font', 'Segoe UI'));
    cboSubSize.ItemIndex := Ini.ReadInteger('Subtitles', 'Size', 1);
    cboSubEncoding.ItemIndex := Ini.ReadInteger('Subtitles', 'Encoding', 0);
    chkSubBold.Checked := Ini.ReadBool('Subtitles', 'Bold', True);
    chkSubAutoLoad.Checked := Ini.ReadBool('Subtitles', 'AutoLoad', True);

    end;
    // Network & IPTV
    if ((PageIndex<0) or (PageIndex=5)) and FPageLoaded[5] then begin
    cboNetCache.ItemIndex := Ini.ReadInteger('Network', 'CacheBuffer', 1);
    cboLiveEdge.ItemIndex := Ini.ReadInteger('Network', 'LiveEdge', 0);
    chkHlsHardware.Checked := Ini.ReadBool('Network', 'HlsHardware', True);
    SelectStoredChoice(cboUserAgent,Ini.ReadString('Network', 'UserAgent', 'VLC/3.0.18 LibVLC/3.0.18'));
    chkPassReferer.Checked := Ini.ReadBool('Network', 'PassReferer', True);

    end;
    // Associations
    if ((PageIndex<0) or (PageIndex=6)) and FPageLoaded[6] then begin
    chkAssocVideo.Checked := Ini.ReadBool('Associations', 'Video', True);
    chkAssocAudio.Checked := Ini.ReadBool('Associations', 'Audio', True);
    chkAssocPlaylists.Checked := Ini.ReadBool('Associations', 'Playlists', True);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TFrmPreferences.SavePreferences;
var
  Ini: TAppSettings;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    // General
    if FPageLoaded[0] then begin
    Ini.WriteInteger('Interface', 'Theme', cboTheme.ItemIndex);
    Ini.WriteBool('General', 'SingleInstance', chkSingleInstance.Checked);
    Ini.WriteBool('General', 'RememberSize', chkRememberSize.Checked);
    Ini.WriteBool('General', 'StartFullscreen', chkStartFullscreen.Checked);
    Ini.WriteBool('General', 'BossKeyHide', chkBossKeyHide.Checked);
    Ini.WriteBool('Interface', 'ShowMenuBar', chkShowMenuBar.Checked);
    Ini.WriteBool('Interface', 'ShowTitleBar', chkShowTitleBar.Checked);

    if Assigned(FrmMain) then
    begin
      FrmMain.IsBorderless := chkCinemaMode.Checked;
      FrmMain.MenuBarVisible := chkShowMenuBar.Checked;
      FrmMain.TitleBarVisible := chkShowTitleBar.Checked;
    end;
    Ini.WriteBool('General', 'ShowOSD', chkShowOSD.Checked);
    Ini.WriteBool('General', 'ShowFilename', chkShowFilename.Checked);
    Ini.WriteInteger('General', 'OsdDuration', cboOsdDuration.ItemIndex);
    Ini.WriteInteger('General', 'OsdSize', cboOsdSize.ItemIndex);
    Ini.WriteInteger('General', 'SingleClick', cboSingleClick.ItemIndex);
    Ini.WriteInteger('General', 'DblClick', cboDblClick.ItemIndex);
    Ini.WriteBool('General', 'WheelVolume', chkWheelVolume.Checked);
    Ini.WriteBool('General','EnterFullscreen',FEnterFullscreen.Checked);

    end;
    // Playback
    if FPageLoaded[1] then begin
    Ini.WriteInteger('Playback', 'Resume', cboResume.ItemIndex);
    Ini.WriteInteger('Playback', 'AfterPlayback', cboAfterPlayback.ItemIndex);
    Ini.WriteBool('Playback', 'SaveHistory', chkSaveHistory.Checked);
    Ini.WriteBool('Playback', 'AutoPlayNext', chkAutoPlayNext.Checked);
    Ini.WriteInteger('Playback', 'JumpShort', cboJumpShort.ItemIndex);
    Ini.WriteInteger('Playback', 'JumpMedium', cboJumpMedium.ItemIndex);
    Ini.WriteInteger('Playback', 'JumpLong', cboJumpLong.ItemIndex);
    Ini.WriteBool('Playback', 'Scaletempo', chkScaletempo.Checked);
    Ini.WriteBool('Playback', 'ShowSpeedOSD', chkShowSpeedOSD.Checked);

    end;
    // Video
    if FPageLoaded[2] then begin
    Ini.WriteInteger('Video', 'HwAccel', cboHwAccel.ItemIndex);
    Ini.WriteBool('Video', 'ZeroCopy', chkZeroCopy.Checked);
    Ini.WriteInteger('Video', 'Vout', cboVout.ItemIndex);
    Ini.WriteInteger('Video', 'Deinterlace', cboDeinterlace.ItemIndex);
    Ini.WriteBool('Video', 'AspectAuto', chkAspectAuto.Checked);

    end;
    // Audio
    if FPageLoaded[3] then begin
    Ini.WriteInteger('Audio', 'Aout', cboAout.ItemIndex);
    Ini.WriteInteger('Audio', 'ChannelMode', cboChannels.ItemIndex);
    Ini.WriteBool('Audio', 'RememberVolume', chkRememberVolume.Checked);
    Ini.WriteBool('Audio', 'Normalizer', chkNormalizer.Checked);
    Ini.WriteInteger('Audio', 'DefaultVolume', tbDefaultVol.Position);

    end;
    // Subtitles
    if FPageLoaded[4] then begin
    Ini.WriteString('Subtitles', 'Font', cboSubFont.Text);
    Ini.WriteInteger('Subtitles', 'Size', cboSubSize.ItemIndex);
    Ini.WriteInteger('Subtitles', 'Encoding', cboSubEncoding.ItemIndex);
    Ini.WriteBool('Subtitles', 'Bold', chkSubBold.Checked);
    Ini.WriteBool('Subtitles', 'AutoLoad', chkSubAutoLoad.Checked);

    end;
    // Network & IPTV
    if FPageLoaded[5] then begin
    Ini.WriteInteger('Network', 'CacheBuffer', cboNetCache.ItemIndex);
    Ini.WriteInteger('Network', 'LiveEdge', cboLiveEdge.ItemIndex);
    Ini.WriteBool('Network', 'HlsHardware', chkHlsHardware.Checked);
    Ini.WriteString('Network', 'UserAgent', cboUserAgent.Text);
    Ini.WriteBool('Network', 'PassReferer', chkPassReferer.Checked);

    end;
    // Associations
    if FPageLoaded[6] then begin
    Ini.WriteBool('Associations', 'Video', chkAssocVideo.Checked);
    Ini.WriteBool('Associations', 'Audio', chkAssocAudio.Checked);
    Ini.WriteBool('Associations', 'Playlists', chkAssocPlaylists.Checked);
    end;
    if Assigned(FAdvanced) then FAdvanced.Save(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TFrmPreferences.btnApplyClick(Sender: TObject);
begin
  SavePreferences;
  if Assigned(FrmEffects) and (FrmEffects.Parent = FEffectsPage) then FrmEffects.btnSaveClick(nil);
  if Assigned(FrmMain) then FrmMain.ReloadPlayerPreferences;
  if Assigned(FrmMain) then
    FrmMain.ShowOSD('Preferences saved; media settings apply on next open');
end;

procedure TFrmPreferences.btnSaveClick(Sender: TObject);
begin
  SavePreferences;
  if Assigned(FrmEffects) and (FrmEffects.Parent = FEffectsPage) then FrmEffects.btnSaveClick(nil);
  if Assigned(FrmMain) then FrmMain.ReloadPlayerPreferences;
  ModalResult := mrOk;
end;

procedure TFrmPreferences.btnCancelClick(Sender: TObject);
begin
  LoadPreferences;
  ModalResult := mrCancel;
end;

procedure TFrmPreferences.btnResetClick(Sender: TObject);
begin
  for var I:=1 to 9 do EnsurePage(I);
  FEnterFullscreen.Checked:=True;
  cboTheme.ItemIndex := 0;
  chkSingleInstance.Checked := True;
  chkRememberSize.Checked := True;
  chkStartFullscreen.Checked := False;
  chkBossKeyHide.Checked := True;
  chkCinemaMode.Checked := False;
  chkShowMenuBar.Checked := True;
  chkShowTitleBar.Checked := True;

  if Assigned(FrmMain) then
    FrmMain.ResetInterfaceDefaults;
  chkShowOSD.Checked := True;
  chkShowFilename.Checked := True;
  cboOsdDuration.ItemIndex := 1;
  cboOsdSize.ItemIndex := 1;
  cboSingleClick.ItemIndex := 0;
  cboDblClick.ItemIndex := 0;
  chkWheelVolume.Checked := True;

  cboResume.ItemIndex := 0;
  cboAfterPlayback.ItemIndex := 0;
  chkSaveHistory.Checked := True;
  chkAutoPlayNext.Checked := False;
  cboJumpShort.ItemIndex := 1;
  cboJumpMedium.ItemIndex := 1;
  cboJumpLong.ItemIndex := 1;
  chkScaletempo.Checked := True;
  chkShowSpeedOSD.Checked := True;

  cboHwAccel.ItemIndex := 0;
  chkZeroCopy.Checked := True;
  cboVout.ItemIndex := 0;
  cboDeinterlace.ItemIndex := 1;
  chkAspectAuto.Checked := True;

  cboAout.ItemIndex := 0;
  cboChannels.ItemIndex := 0;
  chkRememberVolume.Checked := True;
  chkNormalizer.Checked := False;
  tbDefaultVol.Position := 100;
  lblDefVolVal.Caption := '100%';

  SelectStoredChoice(cboSubFont,'Segoe UI');
  cboSubSize.ItemIndex := 1;
  cboSubEncoding.ItemIndex := 0;
  chkSubBold.Checked := True;
  chkSubAutoLoad.Checked := True;

  cboNetCache.ItemIndex := 1;
  cboLiveEdge.ItemIndex := 0;
  chkHlsHardware.Checked := True;
  SelectStoredChoice(cboUserAgent,'VLC/3.0.18 LibVLC/3.0.18');
  chkPassReferer.Checked := True;

  if Assigned(FAdvanced) then FAdvanced.Reset;
  PlayerMessage('Default settings restored. Select Apply or OK to save.');
end;

procedure TFrmPreferences.btnRegisterAssocClick(Sender:TObject);
begin
  var Count:=RegisterPlayerAssociations(ParamStr(0),chkAssocVideo.Checked,chkAssocAudio.Checked,chkAssocPlaylists.Checked);
  if Count=0 then PlayerMessage('Select at least one media group to register.')
  else PlayerMessage('VLC Modern is available in Open with. Choose your default player in Windows Settings.');
end;

end.
