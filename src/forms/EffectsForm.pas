unit EffectsForm;

interface

uses SettingsStore,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, LibVLC, CurvedControls;

type
  TFrmEffects = class(TForm)
    PageControl1: TPageControl;
    tabAudio: TTabSheet;
    tabVideo: TTabSheet;
    tabSync: TTabSheet;

    // Audio Tab sub-pages
    PageControlAudio: TPageControl;
    tabEQ: TTabSheet;
    tabCompressor: TTabSheet;
    tabSpatializer: TTabSheet;
    tabStereoWidener: TTabSheet;

    // Equalizer Controls
    pnlAudioTop: TPanel;
    chkEnableEQ: TPlayerCheckBox;
    chk2Pass: TPlayerCheckBox;
    lblPreset: TLabel;
    cboPresets: TComboBox;
    btnResetEQ: TPlayerTextButton;
    pnlBands: TPanel;
    lblPreamp: TLabel;
    lblPreampVal: TLabel;
    tbPreamp: TPlayerSlider;
    tbBand0: TPlayerSlider;
    tbBand1: TPlayerSlider;
    tbBand2: TPlayerSlider;
    tbBand3: TPlayerSlider;
    tbBand4: TPlayerSlider;
    tbBand5: TPlayerSlider;
    tbBand6: TPlayerSlider;
    tbBand7: TPlayerSlider;
    tbBand8: TPlayerSlider;
    tbBand9: TPlayerSlider;
    lblBand0: TLabel;
    lblBand1: TLabel;
    lblBand2: TLabel;
    lblBand3: TLabel;
    lblBand4: TLabel;
    lblBand5: TLabel;
    lblBand6: TLabel;
    lblBand7: TLabel;
    lblBand8: TLabel;
    lblBand9: TLabel;

    // Sub-tab toggles
    chkEnableCompressor: TPlayerCheckBox;
    chkEnableSpatializer: TPlayerCheckBox;
    chkEnableWidener: TPlayerCheckBox;

    // Video Tab
    pnlVideoAdjust: TPanel;
    chkEnableAdjust: TPlayerCheckBox;
    lblContrast: TLabel;
    lblContrastVal: TLabel;
    tbContrast: TPlayerSlider;
    lblBrightness: TLabel;
    lblBrightnessVal: TLabel;
    tbBrightness: TPlayerSlider;
    lblHue: TLabel;
    lblHueVal: TLabel;
    tbHue: TPlayerSlider;
    lblSaturation: TLabel;
    lblSaturationVal: TLabel;
    tbSaturation: TPlayerSlider;
    lblGamma: TLabel;
    lblGammaVal: TLabel;
    tbGamma: TPlayerSlider;
    btnResetVideo: TPlayerTextButton;

    // Sync Tab
    pnlSync: TPanel;
    grpAudioSync: TModernCardPanel;
    lblAudioDelay: TLabel;
    lblAudioDelayVal: TLabel;
    tbAudioDelay: TPlayerSlider;
    btnAudioDelayMinus: TPlayerTextButton;
    btnAudioDelayPlus: TPlayerTextButton;
    grpSubSync: TModernCardPanel;
    lblAudioSyncTitle, lblSubSyncTitle: TLabel;
    lblSubDelay: TLabel;
    lblSubDelayVal: TLabel;
    tbSubDelay: TPlayerSlider;
    btnSubDelayMinus: TPlayerTextButton;
    btnSubDelayPlus: TPlayerTextButton;

    pnlBottom: TPanel;
    btnSave: TPlayerTextButton;
    btnClose: TPlayerTextButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkEnableEQClick(Sender: TObject);
    procedure cboPresetsChange(Sender: TObject);
    procedure tbPreampChange(Sender: TObject);
    procedure tbBandChange(Sender: TObject);
    procedure btnResetEQClick(Sender: TObject);

    procedure chkEnableAdjustClick(Sender: TObject);
    procedure tbVideoAdjustChange(Sender: TObject);
    procedure btnResetVideoClick(Sender: TObject);

    procedure tbAudioDelayChange(Sender: TObject);
    procedure btnAudioDelayMinusClick(Sender: TObject);
    procedure btnAudioDelayPlusClick(Sender: TObject);
    procedure tbSubDelayChange(Sender: TObject);
    procedure btnSubDelayMinusClick(Sender: TObject);
    procedure btnSubDelayPlusClick(Sender: TObject);

    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);

    procedure chkEnableCompressorClick(Sender: TObject);
    procedure chkEnableSpatializerClick(Sender: TObject);
    procedure chkEnableWidenerClick(Sender: TObject);
    procedure OnGenericSliderChange(Sender: TObject);

  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    FEqualizer: Plibvlc_equalizer_t;
    FBands: array[0..9] of TPlayerSlider;
    FBandValues: array[0..9] of TLabel;
    FCompressorControls: TList;
    FSpatializerControls: TList;
    FWidenerControls: TList;
    FUpdatingUI: Boolean;
    FLayoutBusy: Boolean;
    FPrepareEmbedded: Boolean;
    FResetNotice: TLabel;
    FResetNoticeTimer: TTimer;
    procedure FrameEffectPage(Page: TTabSheet);
    procedure ShowResetNotice;
    procedure HideResetNotice(Sender: TObject);
    procedure ResetPage(Sender: TObject);
    procedure AddResetActions;
    procedure LayoutEffects(Sender: TObject);
    procedure BuildAudioSubTabs;
    procedure ApplyEqualizer;
    procedure SyncUIFromEqualizer;
    procedure ApplyVideoAdjustments;
    procedure LoadEffects;
  public
    constructor CreateForEmbedding(AOwner: TComponent);
    procedure AfterConstruction; override;
    procedure InitializeWithPlayer;
    procedure PrepareEffectTabs;
    procedure SyncSyncTab;
    procedure ApplyPresetIndex(AIndex: Integer);
  end;

var
  FrmEffects: TFrmEffects;

implementation

uses PlayerDialogs, MainForm, System.IniFiles, System.Math, PlayerLanguage;

{$R *.dfm}

constructor TFrmEffects.CreateForEmbedding(AOwner: TComponent);
begin
  FPrepareEmbedded := True;
  inherited Create(AOwner);
end;

procedure TFrmEffects.AfterConstruction;
begin
  inherited;
  DisableAlign;
  try
    LoadEffects;
    BorderStyle := bsSizeable;
    Constraints.MinWidth := MulDiv(720, CurrentPPI, 96);
    Constraints.MinHeight := MulDiv(500, CurrentPPI, 96);
    ClientWidth := MulDiv(760, CurrentPPI, 96);
    ClientHeight := MulDiv(520, CurrentPPI, 96);
    AddResetActions;
    for var Page in [tabEQ, tabCompressor, tabSpatializer, tabStereoWidener, tabVideo] do
      FrameEffectPage(Page);
  finally
    EnableAlign;
  end;
  OnResize := LayoutEffects;
  if not FPrepareEmbedded then
  begin
    ApplyPlayerAppearance(Self);
    PrepareEffectTabs;
    LayoutEffects(nil);
  end;
end;

procedure TFrmEffects.FrameEffectPage(Page: TTabSheet);
begin
  Page.DisableAlign;
  try
    var Card := TModernCardPanel.Create(Self);
    var Body := TPanel.Create(Self);
    Body.BevelOuter := bvNone;
    Body.ParentBackground := False;
    Body.Color := DP_COLOR_SURFACE;
    Body.SetBounds(0, 0, Page.ClientWidth, Page.ClientHeight);
    while Page.ControlCount > 0 do Page.Controls[0].Parent := Body;
    Card.Parent := Page;
    Card.CardColor := DP_COLOR_SURFACE;
    Card.BorderColor := DP_COLOR_BORDER;
    Card.AlignWithMargins := True;
    Card.Margins.SetBounds(10, 8, 10, 8);
    Card.Align := alClient;
    var Heading := TLabel.Create(Self);
    Heading.Parent := Card;
    Heading.AlignWithMargins := True;
    Heading.Margins.SetBounds(16, 7, 16, 0);
    Heading.Align := alTop;
    Heading.Caption := Translate(Page.Caption);
    Heading.Font.Style := [fsBold];
    if PlayerIsArabic then Heading.Alignment := taRightJustify;
    Body.Parent := Card;
    Body.AlignWithMargins := True;
    Body.Margins.SetBounds(5, 0, 5, 5);
    Body.Align := alClient;
  finally
    Page.EnableAlign;
  end;
end;

procedure TFrmEffects.ShowResetNotice;
begin
  if FResetNotice = nil then
  begin
    FResetNotice := TLabel.Create(Self);
    FResetNotice.Parent := Self;
    FResetNotice.Align := alBottom;
    FResetNotice.AutoSize := False;
    FResetNotice.Height := MulDiv(28, CurrentPPI, 96);
    FResetNotice.Alignment := taCenter;
    FResetNotice.Layout := tlCenter;
    FResetNotice.Font.Name := PlayerUIFont;
    FResetNotice.Font.Color := DP_COLOR_ACCENT;
    FResetNoticeTimer := TTimer.Create(Self);
    FResetNoticeTimer.Enabled := False;
    FResetNoticeTimer.Interval := 2200;
    FResetNoticeTimer.OnTimer := HideResetNotice;
  end;
  FResetNotice.Caption := Translate('Defaults restored');
  FResetNotice.Visible := True;
  FResetNoticeTimer.Enabled := False;
  FResetNoticeTimer.Enabled := True;
end;

procedure TFrmEffects.HideResetNotice(Sender: TObject);
begin
  FResetNoticeTimer.Enabled := False;
  FResetNotice.Visible := False;
end;

procedure TFrmEffects.PrepareEffectTabs;
begin
  for var I := 0 to PageControl1.PageCount - 1 do
    PreparePlayerPageAppearance(PageControl1.Pages[I]);
  for var I := 0 to PageControlAudio.PageCount - 1 do
    PreparePlayerPageAppearance(PageControlAudio.Pages[I]);
end;

procedure TFrmEffects.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Parent = nil then Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

procedure TFrmEffects.LayoutEffects(Sender: TObject);
  function S(Value: Integer): Integer;
  begin Result := MulDiv(Value, CurrentPPI, 96); end;
  procedure PlaceLabel(L: TLabel; X, Y, W: Integer; IsValue: Boolean = False);
  begin
    L.AutoSize := False;
    if IsValue then L.BiDiMode := bdLeftToRight
    else if PlayerIsArabic then L.Alignment := taRightJustify;
    PlaceLocalized(L, X, Y, W, S(27));
  end;
  procedure SyncCard(Card: TModernCardPanel; Title, NameLabel, ValueLabel: TLabel;
    Slider: TPlayerSlider; MinusButton, PlusButton: TPlayerTextButton; Y: Integer);
  begin
    Card.SetBounds(S(20), S(Y), Max(S(260), pnlSync.ClientWidth-S(40)), S(120));
    Card.CardColor := DP_COLOR_SURFACE;
    Card.BorderColor := DP_COLOR_BORDER;
    Title.Font.Style := [fsBold];
    PlaceLabel(Title, S(18), S(10), Card.ClientWidth-S(36));
    PlaceLabel(NameLabel, S(18), S(42), Card.ClientWidth-S(140));
    PlaceLabel(ValueLabel, Card.ClientWidth-S(120), S(42), S(100), True);
    PlaceLocalized(Slider, S(18), S(72), Card.ClientWidth-S(163), S(32));
    PlaceLocalized(MinusButton, Card.ClientWidth-S(146), S(72), S(62), S(30));
    PlaceLocalized(PlusButton, Card.ClientWidth-S(80), S(72), S(62), S(30));
  end;
  procedure Rows(Items: TList);
  begin
    for var I := 0 to Items.Count div 3 - 1 do
    begin
      var NameLabel := TLabel(Items[I * 3]);
      var Slider := TPlayerSlider(Items[I * 3 + 1]);
      var ValueLabel := TLabel(Items[I * 3 + 2]);
      var RowY := S(66 + I * 42);
      NameLabel.AutoSize := False;
      if PlayerIsArabic then NameLabel.Alignment := taRightJustify;
      PlaceLocalized(NameLabel, S(24), RowY + S(5), S(150), S(24));
      PlaceLocalized(Slider, S(186), RowY, Max(S(120), Slider.Parent.ClientWidth - S(304)), S(32));
      ValueLabel.AutoSize := False;
      ValueLabel.BiDiMode := bdLeftToRight;
      PlaceLocalized(ValueLabel, S(202) + Slider.Width, RowY + S(5), S(86), S(24));
    end;
  end;
begin
  if FLayoutBusy or (FCompressorControls = nil) or (pnlBands = nil) then Exit;
  FLayoutBusy:=True;
  DisableAlign;
  try
  if pnlBottom.Height <> S(56) then pnlBottom.Height := S(56);
  PlaceLocalized(btnClose, pnlBottom.ClientWidth - S(124), S(12), S(108), S(32));
  PlaceLocalized(btnSave, pnlBottom.ClientWidth - S(244), S(12), S(108), S(32));
  if pnlAudioTop.Height <> S(56) then pnlAudioTop.Height := S(56);
  PageControl1.TabHeight := S(36);
  PageControlAudio.TabHeight := S(30);
  if PlayerIsArabic then
  begin
    PlaceLocalized(chkEnableEQ, S(16), S(12), S(64), S(30));
    PlaceLocalized(chk2Pass, S(86), S(12), S(105), S(30));
    lblPreset.AutoSize := False;
    lblPreset.Alignment := taRightJustify;
    PlaceLocalized(lblPreset, S(197), S(16), S(80), S(24));
    PlaceLocalized(cboPresets, S(286), S(12), Max(S(120), pnlAudioTop.ClientWidth - S(430)), S(30));
  end
  else
    cboPresets.SetBounds(S(204), S(12), Max(S(130), pnlAudioTop.ClientWidth - S(350)), S(30));
  PlaceLocalized(btnResetEQ, pnlAudioTop.ClientWidth - S(130), S(12), S(114), S(30));
  var Labels: array[0..10] of TLabel;
  Labels[0] := lblPreamp;
  Labels[1] := lblBand0; Labels[2] := lblBand1; Labels[3] := lblBand2;
  Labels[4] := lblBand3; Labels[5] := lblBand4; Labels[6] := lblBand5;
  Labels[7] := lblBand6; Labels[8] := lblBand7; Labels[9] := lblBand8; Labels[10] := lblBand9;
  var CellWidth := (pnlBands.ClientWidth - S(32)) div 11;
  for var I := 0 to 10 do
  begin
    var Slider := tbPreamp;
    var ValueLabel := lblPreampVal;
    if I > 0 then begin Slider := FBands[I - 1]; ValueLabel := FBandValues[I - 1]; end;
    var Center := S(16) + I * CellWidth + CellWidth div 2;
    if PlayerIsArabic then Center := pnlBands.ClientWidth - Center;
    var BandHeight:=Min(pnlBands.ClientHeight,S(260));
    Slider.SetBounds(Center - S(18), S(40), S(36), Max(S(70), BandHeight - S(86)));
    if PlayerIsArabic then
    begin
      ValueLabel.BiDiMode := bdLeftToRight;
      if I > 0 then Labels[I].BiDiMode := bdLeftToRight;
    end;
    ValueLabel.Parent.SetBounds(Center - S(23), S(10), S(46), S(22));
    Labels[I].AutoSize := False;
    Labels[I].Alignment := taCenter;
    Labels[I].SetBounds(Center - CellWidth div 2, BandHeight - S(30), CellWidth, S(22));
  end;
  Rows(FCompressorControls);
  Rows(FSpatializerControls);
  Rows(FWidenerControls);
  PlaceLocalized(chkEnableAdjust, S(24), S(12), S(230), S(30));
  var VideoLabels := TArray<TLabel>.Create(lblContrast, lblBrightness, lblHue, lblSaturation, lblGamma);
  var VideoValues := TArray<TLabel>.Create(lblContrastVal, lblBrightnessVal, lblHueVal, lblSaturationVal, lblGammaVal);
  var VideoSliders := TArray<TPlayerSlider>.Create(tbContrast, tbBrightness, tbHue, tbSaturation, tbGamma);
  var VideoWidth := Max(S(90), pnlVideoAdjust.ClientWidth-S(300));
  for var I := 0 to High(VideoLabels) do
  begin
    var Y := S(54 + I*40);
    PlaceLabel(VideoLabels[I], S(24), Y+S(3), S(142));
    PlaceLocalized(VideoSliders[I], S(178), Y, VideoWidth, S(32));
    PlaceLabel(VideoValues[I], S(194)+VideoWidth, Y+S(3), S(76), True);
  end;
  PlaceLocalized(btnResetVideo, S(24), S(258), S(120), S(32));
  SyncCard(grpAudioSync, lblAudioSyncTitle, lblAudioDelay, lblAudioDelayVal,
    tbAudioDelay, btnAudioDelayMinus, btnAudioDelayPlus, 16);
  SyncCard(grpSubSync, lblSubSyncTitle, lblSubDelay, lblSubDelayVal,
    tbSubDelay, btnSubDelayMinus, btnSubDelayPlus, 148);
  for var Check in [chkEnableCompressor, chkEnableSpatializer, chkEnableWidener] do
    PlaceLocalized(Check, S(24), S(10), Max(S(100), Check.Parent.ClientWidth - S(180)), S(30));
  finally
    EnableAlign; FLayoutBusy:=False;

  end;
end;
procedure TFrmEffects.ResetPage(Sender: TObject);
  procedure ResetControls(Parent: TWinControl);
  begin
    for var I:=0 to Parent.ControlCount-1 do
      if Parent.Controls[I] is TPlayerSlider then TPlayerSlider(Parent.Controls[I]).Position:=Parent.Controls[I].HelpContext
      else if Parent.Controls[I] is TWinControl then ResetControls(TWinControl(Parent.Controls[I]));
  end;
begin
  ResetControls(TControl(Sender).Parent);
  if TControl(Sender).Parent = pnlSync then
  begin
    tbAudioDelayChange(nil);
    tbSubDelayChange(nil);
  end;
  ShowResetNotice;
end;

procedure TFrmEffects.AddResetActions;
begin
  for var I:=0 to ComponentCount-1 do
    if Components[I] is TTabSheet then
    begin
      var Page:=TTabSheet(Components[I]);
      var HasSlider:=False; var HasReset:=False;
      for var J:=0 to Page.ControlCount-1 do
      begin
        HasSlider:=HasSlider or (Page.Controls[J] is TPlayerSlider);
        if Page.Controls[J] is TPlayerTextButton then HasReset:=HasReset or (Pos('Reset',TPlayerTextButton(Page.Controls[J]).Caption)>0);
      end;
      if HasSlider and not HasReset then
      begin
        var Button:=TPlayerTextButton.Create(Self);
        Button.Parent:=Page; Button.Caption:='Reset';
        Button.TabStop := True;
        var W := MulDiv(120, CurrentPPI, 96);
        PlaceLocalized(Button, Page.ClientWidth - W - MulDiv(16, CurrentPPI, 96),
          MulDiv(10, CurrentPPI, 96), W, MulDiv(30, CurrentPPI, 96));
        if PlayerIsArabic then Button.Anchors := [akTop, akLeft]
        else Button.Anchors := [akTop, akRight];
        Button.OnClick:=ResetPage;
      end;
    end;
  var SyncReset := TPlayerTextButton.Create(Self);
  SyncReset.Parent := pnlSync;
  SyncReset.Caption := 'Reset';
  SyncReset.TabStop := True;
  PlaceLocalized(SyncReset, MulDiv(20, CurrentPPI, 96), MulDiv(280, CurrentPPI, 96),
    MulDiv(120, CurrentPPI, 96), MulDiv(32, CurrentPPI, 96));
  if PlayerIsArabic then SyncReset.Anchors := [akTop, akRight];
  SyncReset.OnClick := ResetPage;
end;

procedure TFrmEffects.FormCreate(Sender: TObject);
var
  I, PresetCount: Integer;
  PName: PAnsiChar;
begin
  FBands[0] := tbBand0;
  FBands[1] := tbBand1;
  FBands[2] := tbBand2;
  FBands[3] := tbBand3;
  FBands[4] := tbBand4;
  FBands[5] := tbBand5;
  FBands[6] := tbBand6;
  FBands[7] := tbBand7;
  FBands[8] := tbBand8;
  FBands[9] := tbBand9;

  for I := -1 to 9 do
  begin
    var Slider := tbPreamp;
    if I >= 0 then Slider := FBands[I];
    var Badge := TModernCardPanel.Create(Self);
    Badge.Parent := pnlBands;
    Badge.SetBounds(Slider.Left - MulDiv(5, CurrentPPI, 96),
      Slider.Top - MulDiv(24, CurrentPPI, 96), Slider.Width + MulDiv(10, CurrentPPI, 96), MulDiv(20, CurrentPPI, 96));
    Badge.CornerRadius := 6;
    Badge.CardColor := DP_COLOR_ELEVATED;
    Badge.BorderColor := DP_COLOR_BORDER;
    var ValueLabel := lblPreampVal;
    if I >= 0 then
    begin
      ValueLabel := TLabel.Create(Self);
      FBandValues[I] := ValueLabel;
    end;
    ValueLabel.Parent := Badge;
    ValueLabel.Align := alClient;
    ValueLabel.Alignment := taCenter;
    ValueLabel.Layout := tlCenter;
    ValueLabel.Caption := '0 dB';
    ValueLabel.Font.Color := DP_COLOR_TEXT;
    ValueLabel.Font.Size := 8;
  end;

  FEqualizer := nil;
  FUpdatingUI := False;
  FCompressorControls := TList.Create;
  FSpatializerControls := TList.Create;
  FWidenerControls := TList.Create;

  BuildAudioSubTabs;

  if IsLibVLCLoaded and Assigned(libvlc_audio_equalizer_new) then
  begin
    FEqualizer := libvlc_audio_equalizer_new();
    cboPresets.Items.Clear;
    cboPresets.Items.Add('Flat (Default)');
    PresetCount := libvlc_audio_equalizer_get_preset_count();
    for I := 0 to PresetCount - 1 do
    begin
      PName := libvlc_audio_equalizer_get_preset_name(I);
      if PName <> nil then
        cboPresets.Items.Add(string(PName));
    end;
    cboPresets.ItemIndex := 0;
  end;
end;

procedure TFrmEffects.BuildAudioSubTabs;

  function AddParamRow(AParent: TWinControl; AList: TList; const AName: string;
    ATop, AMin, AMax, ADef: Integer; const AUnit: string): TPlayerSlider;
  var
    LblName, LblVal: TLabel;
    TB: TPlayerSlider;
  begin
    LblName := TLabel.Create(Self);
    LblName.Parent := AParent;
    LblName.Left := 24;
    LblName.Top := ATop + 5;
    LblName.Width := 130;
    LblName.Caption := AName;
    LblName.Font.Name := 'Segoe UI';
    LblName.Font.Size := 9;
    AList.Add(LblName);

    TB := TPlayerSlider.Create(Self);
    TB.Parent := AParent;
    TB.Left := 160;
    TB.Top := ATop;
    TB.Width := 290;
    TB.Height := 28;
    TB.Min := AMin;
    TB.Max := AMax;
    TB.HelpContext:=ADef;
    TB.Position := ADef;
    TB.OnChange := OnGenericSliderChange;
    AList.Add(TB);

    LblVal := TLabel.Create(Self);
    LblVal.Parent := AParent;
    LblVal.Left := 460;
    LblVal.Top := ATop + 5;
    LblVal.Width := 75;
    LblVal.Font.Name := 'Segoe UI';
    LblVal.Font.Size := 9;
    LblVal.Caption := Format('%d%s', [ADef, AUnit]);
    TB.Tag := NativeInt(LblVal);
    AList.Add(LblVal);

    Result := TB;
  end;

begin
  // --- 1. Dynamic Range Compressor Controls ---
  chkEnableCompressor.OnClick := chkEnableCompressorClick;
  AddParamRow(tabCompressor, FCompressorControls, 'RMS/Peak:', 42, 0, 100, 0, '%');
  AddParamRow(tabCompressor, FCompressorControls, 'Attack Time:', 72, 1, 400, 25, ' ms');
  AddParamRow(tabCompressor, FCompressorControls, 'Release Time:', 102, 2, 800, 100, ' ms');
  AddParamRow(tabCompressor, FCompressorControls, 'Threshold:', 132, -30, 0, -11, ' dB');
  AddParamRow(tabCompressor, FCompressorControls, 'Ratio:', 162, 1, 20, 4, ':1');
  AddParamRow(tabCompressor, FCompressorControls, 'Knee Radius:', 192, 1, 10, 3, ' dB');
  AddParamRow(tabCompressor, FCompressorControls, 'Makeup Gain:', 222, 0, 24, 7, ' dB');
  chkEnableCompressorClick(chkEnableCompressor);

  // --- 2. Spatializer Controls ---
  chkEnableSpatializer.OnClick := chkEnableSpatializerClick;
  AddParamRow(tabSpatializer, FSpatializerControls, 'Room Size:', 42, 0, 100, 50, '%');
  AddParamRow(tabSpatializer, FSpatializerControls, 'Width:', 72, 0, 100, 70, '%');
  AddParamRow(tabSpatializer, FSpatializerControls, 'Wet Level:', 102, 0, 100, 40, '%');
  AddParamRow(tabSpatializer, FSpatializerControls, 'Dry Level:', 132, 0, 100, 60, '%');
  AddParamRow(tabSpatializer, FSpatializerControls, 'Damping:', 162, 0, 100, 50, '%');
  chkEnableSpatializerClick(chkEnableSpatializer);

  // --- 3. Stereo Widener Controls ---
  chkEnableWidener.OnClick := chkEnableWidenerClick;
  AddParamRow(tabStereoWidener, FWidenerControls, 'Delay Time:', 42, 1, 100, 20, ' ms');
  AddParamRow(tabStereoWidener, FWidenerControls, 'Feedback:', 72, 0, 90, 30, '%');
  AddParamRow(tabStereoWidener, FWidenerControls, 'Crossfeed:', 102, 0, 80, 40, '%');
  AddParamRow(tabStereoWidener, FWidenerControls, 'Dry Mix:', 132, 0, 100, 50, '%');
  chkEnableWidenerClick(chkEnableWidener);
end;

procedure TFrmEffects.OnGenericSliderChange(Sender: TObject);
var
  TB: TPlayerSlider;
  Lbl: TLabel;
  UnitStr: string;
begin
  if not (Sender is TPlayerSlider) then Exit;
  TB := TPlayerSlider(Sender);
  Lbl := TLabel(TB.Tag);
  if Assigned(Lbl) then
  begin
    UnitStr := '';
    if Pos('ms', Lbl.Caption) > 0 then UnitStr := ' ms'
    else if Pos('dB', Lbl.Caption) > 0 then UnitStr := ' dB'
    else if Pos(':', Lbl.Caption) > 0 then UnitStr := ':1'
    else if Pos('%', Lbl.Caption) > 0 then UnitStr := '%';
    Lbl.Caption := Format('%d%s', [TB.Position, UnitStr]);
  end;
end;

procedure TFrmEffects.chkEnableCompressorClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FCompressorControls.Count - 1 do
    if TControl(FCompressorControls[I]) is TLabel then TControl(FCompressorControls[I]).Enabled := True
    else TControl(FCompressorControls[I]).Enabled := chkEnableCompressor.Checked;
end;

procedure TFrmEffects.chkEnableSpatializerClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FSpatializerControls.Count - 1 do
    if TControl(FSpatializerControls[I]) is TLabel then TControl(FSpatializerControls[I]).Enabled := True
    else TControl(FSpatializerControls[I]).Enabled := chkEnableSpatializer.Checked;
end;

procedure TFrmEffects.chkEnableWidenerClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FWidenerControls.Count - 1 do
    if TControl(FWidenerControls[I]) is TLabel then TControl(FWidenerControls[I]).Enabled := True
    else TControl(FWidenerControls[I]).Enabled := chkEnableWidener.Checked;
end;

procedure TFrmEffects.FormDestroy(Sender: TObject);
begin
  OnResize:=nil;
  FreeAndNil(FCompressorControls);
  FreeAndNil(FSpatializerControls);
  FreeAndNil(FWidenerControls);
  if FEqualizer <> nil then
  begin
    libvlc_audio_equalizer_release(FEqualizer);
    FEqualizer := nil;
  end;
end;

procedure TFrmEffects.InitializeWithPlayer;
begin
  ApplyEqualizer;
  ApplyVideoAdjustments;
  SyncSyncTab;
end;

procedure TFrmEffects.chkEnableEQClick(Sender: TObject);
var
  I: Integer;
begin
  tbPreamp.Enabled := chkEnableEQ.Checked;
  cboPresets.Enabled := chkEnableEQ.Checked;
  for I := 0 to 9 do
    if Assigned(FBands[I]) then
      FBands[I].Enabled := chkEnableEQ.Checked;
  ApplyEqualizer;
end;

procedure TFrmEffects.ApplyEqualizer;
begin
  if not Assigned(FrmMain) or (FrmMain.MediaPlayer = nil) or not Assigned(libvlc_media_player_set_equalizer) then
    Exit;

  if chkEnableEQ.Checked and (FEqualizer <> nil) then
    libvlc_media_player_set_equalizer(FrmMain.MediaPlayer, FEqualizer)
  else
    libvlc_media_player_set_equalizer(FrmMain.MediaPlayer, nil);
end;

procedure TFrmEffects.SyncUIFromEqualizer;
var
  I: Integer;
  Amp, Pre: Single;
begin
  if FEqualizer = nil then Exit;
  FUpdatingUI := True;
  try
    Pre := libvlc_audio_equalizer_get_preamp(FEqualizer);
    tbPreamp.Position := Round(Pre);
    lblPreampVal.Caption := Format('%d dB', [tbPreamp.Position]);

    for I := 0 to 9 do
    begin
      Amp := libvlc_audio_equalizer_get_amp_at_index(FEqualizer, I);
      FBands[I].Position := Round(Amp);
      FBandValues[I].Caption := Format('%d dB', [FBands[I].Position]);
    end;
  finally
    FUpdatingUI := False;
  end;
end;

procedure TFrmEffects.cboPresetsChange(Sender: TObject);
var
  Idx: Integer;
begin
  if not IsLibVLCLoaded then Exit;
  Idx := cboPresets.ItemIndex;
  if Idx <= 0 then
  begin
    btnResetEQClick(nil);
    Exit;
  end;

  if FEqualizer <> nil then
    libvlc_audio_equalizer_release(FEqualizer);

  FEqualizer := libvlc_audio_equalizer_new_from_preset(Idx - 1);
  SyncUIFromEqualizer;
  ApplyEqualizer;
end;

procedure TFrmEffects.ApplyPresetIndex(AIndex: Integer);
begin
  if not IsLibVLCLoaded then Exit;
  chkEnableEQ.Checked := True;
  if AIndex < 0 then Exit;
  if (cboPresets <> nil) and (AIndex < cboPresets.Items.Count) then
    cboPresets.ItemIndex := AIndex;

  if AIndex = 0 then
  begin
    btnResetEQClick(nil);
    Exit;
  end;

  if FEqualizer <> nil then
    libvlc_audio_equalizer_release(FEqualizer);

  FEqualizer := libvlc_audio_equalizer_new_from_preset(AIndex - 1);
  SyncUIFromEqualizer;
  ApplyEqualizer;
end;

procedure TFrmEffects.tbPreampChange(Sender: TObject);
begin
  lblPreampVal.Caption := Format('%d dB', [tbPreamp.Position]);
  if FUpdatingUI or (FEqualizer = nil) then Exit;
  libvlc_audio_equalizer_set_preamp(FEqualizer, tbPreamp.Position);
  ApplyEqualizer;
end;

procedure TFrmEffects.tbBandChange(Sender: TObject);
var
  TB: TPlayerSlider;
  BandIdx: Integer;
begin
  if Sender is TPlayerSlider then
  begin
    var Index := TPlayerSlider(Sender).Tag;
    if (Index >= 0) and (Index <= 9) and Assigned(FBandValues[Index]) then
      FBandValues[Index].Caption := Format('%d dB', [TPlayerSlider(Sender).Position]);
  end;
  if FUpdatingUI or (FEqualizer = nil) or not (Sender is TPlayerSlider) then Exit;
  TB := TPlayerSlider(Sender);
  BandIdx := TB.Tag;
  if (BandIdx >= 0) and (BandIdx <= 9) then
  begin
    libvlc_audio_equalizer_set_amp_at_index(FEqualizer, TB.Position, BandIdx);
    ApplyEqualizer;
  end;
end;

procedure TFrmEffects.btnResetEQClick(Sender: TObject);
var
  I: Integer;
begin
  if FEqualizer = nil then Exit;
  FUpdatingUI := True;
  try
    tbPreamp.Position := 0;
    lblPreampVal.Caption := '0 dB';
    libvlc_audio_equalizer_set_preamp(FEqualizer, 0.0);
    for I := 0 to 9 do
    begin
      FBands[I].Position := 0;
      FBandValues[I].Caption := '0 dB';
      libvlc_audio_equalizer_set_amp_at_index(FEqualizer, 0.0, I);
    end;
    cboPresets.ItemIndex := 0;
  finally
    FUpdatingUI := False;
  end;
  ApplyEqualizer;
  if Sender <> nil then ShowResetNotice;
end;

// ==================== VIDEO ADJUSTMENTS ====================

procedure TFrmEffects.chkEnableAdjustClick(Sender: TObject);
begin
  for var Slider in [tbContrast, tbBrightness, tbHue, tbSaturation, tbGamma] do
    Slider.Enabled := chkEnableAdjust.Checked;
  ApplyVideoAdjustments;
end;

procedure TFrmEffects.ApplyVideoAdjustments;
var
  P: Plibvlc_media_player_t;
begin
  if not Assigned(FrmMain) or (FrmMain.MediaPlayer = nil) or not Assigned(libvlc_video_set_adjust_int) then
    Exit;

  P := FrmMain.MediaPlayer;

  if chkEnableAdjust.Checked then
  begin
    libvlc_video_set_adjust_int(P, libvlc_adjust_Enable, 1);
    libvlc_video_set_adjust_float(P, libvlc_adjust_Contrast, tbContrast.Position / 100.0);
    libvlc_video_set_adjust_float(P, libvlc_adjust_Brightness, tbBrightness.Position / 100.0);
    libvlc_video_set_adjust_float(P, libvlc_adjust_Hue, tbHue.Position);
    libvlc_video_set_adjust_float(P, libvlc_adjust_Saturation, tbSaturation.Position / 100.0);
    libvlc_video_set_adjust_float(P, libvlc_adjust_Gamma, tbGamma.Position / 100.0);
  end
  else
  begin
    if libvlc_video_get_adjust_int(P, libvlc_adjust_Enable) > 0 then
      libvlc_video_set_adjust_int(P, libvlc_adjust_Enable, 0);
  end;
end;

procedure TFrmEffects.tbVideoAdjustChange(Sender: TObject);
begin
  lblContrastVal.Caption := Format('%.2f', [tbContrast.Position / 100.0]);
  lblBrightnessVal.Caption := Format('%.2f', [tbBrightness.Position / 100.0]);
  lblHueVal.Caption := Format('%d deg', [tbHue.Position]);
  lblSaturationVal.Caption := Format('%.2f', [tbSaturation.Position / 100.0]);
  lblGammaVal.Caption := Format('%.2f', [tbGamma.Position / 100.0]);

  if chkEnableAdjust.Checked then
    ApplyVideoAdjustments;
end;

procedure TFrmEffects.btnResetVideoClick(Sender: TObject);
begin
  FUpdatingUI := True;
  try
    tbContrast.Position := 100;
    tbBrightness.Position := 100;
    tbHue.Position := 0;
    tbSaturation.Position := 100;
    tbGamma.Position := 100;
    tbVideoAdjustChange(nil);
  finally
    FUpdatingUI := False;
  end;
  ApplyVideoAdjustments;
  if Sender <> nil then ShowResetNotice;
end;

// ==================== SYNCHRONIZATION ====================

procedure TFrmEffects.SyncSyncTab;
var
  AudDelay, SubDelay: Int64;
begin
  if not Assigned(FrmMain) or (FrmMain.MediaPlayer = nil) then Exit;
  AudDelay := libvlc_audio_get_delay(FrmMain.MediaPlayer) div 1000;
  SubDelay := libvlc_video_get_spu_delay(FrmMain.MediaPlayer) div 1000;

  tbAudioDelay.Position := AudDelay;
  lblAudioDelayVal.Caption := Format('%d ms', [AudDelay]);

  tbSubDelay.Position := SubDelay;
  lblSubDelayVal.Caption := Format('%d ms', [SubDelay]);
end;

procedure TFrmEffects.tbAudioDelayChange(Sender: TObject);
begin
  lblAudioDelayVal.Caption := Format('%d ms', [tbAudioDelay.Position]);
  if Assigned(FrmMain) and (FrmMain.MediaPlayer <> nil) then
    libvlc_audio_set_delay(FrmMain.MediaPlayer, Int64(tbAudioDelay.Position) * 1000);
end;

procedure TFrmEffects.btnAudioDelayMinusClick(Sender: TObject);
begin
  tbAudioDelay.Position := tbAudioDelay.Position - 50;
end;

procedure TFrmEffects.btnAudioDelayPlusClick(Sender: TObject);
begin
  tbAudioDelay.Position := tbAudioDelay.Position + 50;
end;

procedure TFrmEffects.tbSubDelayChange(Sender: TObject);
begin
  lblSubDelayVal.Caption := Format('%d ms', [tbSubDelay.Position]);
  if Assigned(FrmMain) and (FrmMain.MediaPlayer <> nil) then
    libvlc_video_set_spu_delay(FrmMain.MediaPlayer, Int64(tbSubDelay.Position) * 1000);
end;

procedure TFrmEffects.btnSubDelayMinusClick(Sender: TObject);
begin
  tbSubDelay.Position := tbSubDelay.Position - 50;
end;

procedure TFrmEffects.btnSubDelayPlusClick(Sender: TObject);
begin
  tbSubDelay.Position := tbSubDelay.Position + 50;
end;

procedure TFrmEffects.LoadEffects;
var Ini: TAppSettings;
  procedure LoadRows(List: TList; const Prefix: string);
  begin
    for var I := 0 to List.Count div 3 - 1 do
    begin
      var Slider := TPlayerSlider(List[I * 3 + 1]);
      Slider.Position := Ini.ReadInteger('AudioEffects', Prefix + IntToStr(I), Slider.Position);
      OnGenericSliderChange(Slider);
    end;
  end;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    LoadRows(FCompressorControls, 'Compressor');
    LoadRows(FSpatializerControls, 'Spatializer');
    LoadRows(FWidenerControls, 'Widener');
    chkEnableCompressor.Checked := Ini.ReadBool('AudioEffects', 'Compressor', False);
    chkEnableSpatializer.Checked := Ini.ReadBool('AudioEffects', 'Spatializer', False);
    chkEnableWidener.Checked := Ini.ReadBool('AudioEffects', 'Widener', False);
    chk2Pass.Checked := Ini.ReadBool('AudioEffects', 'TwoPass', False);
    for var I := 0 to ComponentCount - 1 do
      if Components[I] is TPlayerSlider then
      begin
        var Slider := TPlayerSlider(Components[I]);
        if Slider.Name <> '' then Slider.Position := Ini.ReadInteger('EffectsValues', Slider.Name, Slider.Position);
      end;
    chkEnableEQ.Checked := Ini.ReadBool('AudioEffects', 'Equalizer', True);
    chkEnableEQClick(nil);
    chkEnableAdjust.Checked := Ini.ReadBool('AudioEffects', 'VideoAdjust', False);
    chkEnableAdjustClick(nil);
    if FEqualizer <> nil then
    begin
      libvlc_audio_equalizer_set_preamp(FEqualizer, tbPreamp.Position);
      for var I := 0 to 9 do libvlc_audio_equalizer_set_amp_at_index(FEqualizer, FBands[I].Position, I);
    end;
  finally Ini.Free; end;
end;

procedure TFrmEffects.btnSaveClick(Sender: TObject);
var Ini: TAppSettings; Before, After: string; RestartFilters: Boolean;
  procedure SaveRows(List: TList; const Prefix: string);
  begin
    for var I := 0 to List.Count div 3 - 1 do
      Ini.WriteInteger('AudioEffects', Prefix + IntToStr(I), TPlayerSlider(List[I * 3 + 1]).Position);
  end;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Before := Ini.Snapshot;
    RestartFilters := chkEnableCompressor.Checked or chkEnableSpatializer.Checked or chkEnableWidener.Checked or
      Ini.ReadBool('AudioEffects', 'Compressor', False) or Ini.ReadBool('AudioEffects', 'Spatializer', False) or
      Ini.ReadBool('AudioEffects', 'Widener', False) or (Ini.ReadBool('AudioEffects', 'TwoPass', False) <> chk2Pass.Checked);
    SaveRows(FCompressorControls, 'Compressor');
    SaveRows(FSpatializerControls, 'Spatializer');
    SaveRows(FWidenerControls, 'Widener');
    Ini.WriteBool('AudioEffects', 'Compressor', chkEnableCompressor.Checked);
    Ini.WriteBool('AudioEffects', 'Spatializer', chkEnableSpatializer.Checked);
    Ini.WriteBool('AudioEffects', 'Widener', chkEnableWidener.Checked);
    Ini.WriteBool('AudioEffects', 'TwoPass', chk2Pass.Checked);
    Ini.WriteBool('AudioEffects', 'Equalizer', chkEnableEQ.Checked);
    Ini.WriteBool('AudioEffects', 'VideoAdjust', chkEnableAdjust.Checked);
    for var I := 0 to ComponentCount - 1 do
      if (Components[I] is TPlayerSlider) and (Components[I].Name <> '') then
        Ini.WriteInteger('EffectsValues', Components[I].Name, TPlayerSlider(Components[I]).Position);
    After := Ini.Snapshot;
  finally Ini.Free; end;
  if Assigned(FrmMain) then
    if RestartFilters and (Before <> After) then FrmMain.ApplyAudioEffects
    else FrmMain.ReloadPlayerPreferences;
  ApplyEqualizer;
  ApplyVideoAdjustments;
  if Assigned(FrmMain) then
    FrmMain.ShowOSD('Audio and video effects applied');
end;

procedure TFrmEffects.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
