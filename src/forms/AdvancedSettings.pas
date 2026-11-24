unit AdvancedSettings;

interface

uses System.Classes, Vcl.Controls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, SettingsStore;

type
  TAdvancedSettings = class(TComponent)
  private
    Aspect, Crop, Zoom, AudioLanguage, SubLanguage, SubMargin: TComboBox;
    AudioTrack, SubTrack, Device: TComboBox;
    Transform, ReplayGain, ReplayPreamp, ReplayDefault: TComboBox;
    Sharpen, Deband: TComboBox;
    TextColor, OutlineSize, Shadow, Background: TComboBox;
    PeakProtection: TCheckBox;
    DeviceIDs: TStringList;
    FLoading: Boolean;
    FDevicePlayer: Pointer;
    RefreshTimer: TTimer;
    RefreshRemaining: Integer;
    procedure LoadExternal(Sender: TObject);
    procedure RefreshAfterLoad(Sender: TObject);
    procedure SelectRuntime(Sender: TObject);
  public
    constructor CreatePages(AOwner: TComponent; VideoPage, AudioPage, SubtitlePage: TTabSheet);
    destructor Destroy; override;
    procedure Load(Store: TAppSettings);
    procedure Save(Store: TAppSettings);
    procedure RefreshTracks;
    procedure QueueRefresh;
    procedure Reset;
  end;

implementation

uses System.SysUtils, Winapi.Windows, MainForm, LibVLC, Vcl.Dialogs, PlayerDialogs;

constructor TAdvancedSettings.CreatePages(AOwner: TComponent; VideoPage, AudioPage, SubtitlePage: TTabSheet);
  function Group(Page: TTabSheet; const Caption: string; Top, Height: Integer): TGroupBox;
  begin
    Result := TGroupBox.Create(Self);
    Result.Parent := Page;
    Result.Caption := Caption;
    Result.SetBounds(MulDiv(12, Page.CurrentPPI, 96), MulDiv(Top, Page.CurrentPPI, 96),
      MulDiv(546, Page.CurrentPPI, 96), MulDiv(Height, Page.CurrentPPI, 96));
  end;
  function Choice(Parent: TGroupBox; const Caption, Values: string; X, Y: Integer; Editable: Boolean = False): TComboBox;
  var LabelControl: TLabel; D: Integer;
  begin
    D := Parent.CurrentPPI;
    LabelControl := TLabel.Create(Self);
    LabelControl.Parent := Parent;
    LabelControl.Caption := Caption;
    LabelControl.SetBounds(MulDiv(X, D, 96), MulDiv(Y, D, 96), MulDiv(240, D, 96), MulDiv(18, D, 96));
    Result := TComboBox.Create(Self);
    Result.Parent := Parent;
    if Editable then Result.Style := csDropDown else Result.Style := csOwnerDrawFixed;
    Result.Items.Delimiter := '|';
    Result.Items.StrictDelimiter := True;
    Result.Items.DelimitedText := Values;
    Result.SetBounds(MulDiv(X, D, 96), MulDiv(Y + 22, D, 96), MulDiv(240, D, 96), MulDiv(28, D, 96));
    if Result.Items.Count > 0 then Result.ItemIndex := 0;
  end;
  function ExtraPage(const Caption: string): TTabSheet;
  begin
    for var I:=0 to VideoPage.PageControl.PageCount-1 do
      if VideoPage.PageControl.Pages[I].Caption=Caption then Exit(VideoPage.PageControl.Pages[I]);
    Result := TTabSheet.Create(Self);
    Result.PageControl := VideoPage.PageControl;
    Result.Caption := Caption;
  end;
  procedure LoadButton(Parent: TGroupBox; const Caption: string; Audio: Boolean);
  begin
    var Button := TButton.Create(Self);
    Button.Parent := Parent;
    Button.Caption := Caption;
    Button.Tag := Ord(Audio);
    Button.SetBounds(MulDiv(280, Parent.CurrentPPI, 96), MulDiv(48, Parent.CurrentPPI, 96),
      MulDiv(240, Parent.CurrentPPI, 96), MulDiv(30, Parent.CurrentPPI, 96));
    Button.OnClick := LoadExternal;
  end;
begin
  inherited Create(AOwner);
  DeviceIDs := TStringList.Create;
  var Video := Group(VideoPage, 'Framing and zoom', 292, 178);
  Aspect := Choice(Video, 'Aspect ratio', 'Default|16:9|4:3|16:10|1:1|2.21:1|2.35:1|2.39:1', 18, 26);
  Crop := Choice(Video, 'Crop', Aspect.Items.DelimitedText, 280, 26);
  Zoom := Choice(Video, 'Video size', 'Fit window|50%|100%|150%|200%', 18, 100);
  var Audio := Group(AudioPage, 'Language and output device', 282, 102);
  AudioLanguage := Choice(Audio, 'Preferred language codes (next file)', 'Automatic|ara,ar|eng,en|ara,ar,eng,en', 18, 26, False);
  Device := Choice(Audio, 'Audio output device', 'System default', 280, 26);
  Device.OnChange := SelectRuntime;
  var Tracks := Group(AudioPage, 'Current media', 396, 102);
  AudioTrack := Choice(Tracks, 'Audio track', '', 18, 26);
  AudioTrack.OnChange := SelectRuntime;
  LoadButton(Tracks, 'Load external audio...', True);
  var Subtitles := Group(SubtitlePage, 'Language and placement (next file)', 196, 102);
  SubLanguage := Choice(Subtitles, 'Preferred language codes', 'Automatic|ara,ar|eng,en|ara,ar,eng,en', 18, 26, False);
  SubMargin := Choice(Subtitles, 'Raise subtitles above bottom edge', '0 px|20 px|40 px|60 px|80 px|100 px|120 px|140 px|160 px|180 px|200 px', 280, 26);
  var CurrentSub := Group(SubtitlePage, 'Current media', 310, 102);
  SubTrack := Choice(CurrentSub, 'Subtitle track', '', 18, 26);
  SubTrack.OnChange := SelectRuntime;
  LoadButton(CurrentSub, 'Load subtitle file...', False);
  RefreshTimer := TTimer.Create(Self);
  RefreshTimer.Enabled := False;
  RefreshTimer.Interval := 250;
  RefreshTimer.OnTimer := RefreshAfterLoad;
  var Processing := Group(ExtraPage('Video processing'), 'Orientation and detail (next file)', 12, 214);
  Transform := Choice(Processing, 'Rotate or mirror', 'Original|Rotate 90 degrees|Rotate 180 degrees|Rotate 270 degrees|Mirror horizontally|Flip vertically|Transpose|Anti-transpose', 18, 30);
  Sharpen := Choice(Processing, 'Sharpen detail', 'Off|Low|Medium|High', 18, 118);
  Deband := Choice(Processing, 'Smooth color banding', 'Off|Low|Medium|High', 280, 118);
  var Leveling := Group(ExtraPage('Audio leveling'), 'ReplayGain (next file)', 12, 252);
  ReplayGain := Choice(Leveling, 'Loudness metadata', 'Off|Track gain|Album gain', 18, 30);
  ReplayPreamp := Choice(Leveling, 'Preamp for tagged audio', '-12 dB|-9 dB|-6 dB|-3 dB|0 dB|+3 dB|+6 dB|+9 dB|+12 dB', 280, 30);
  ReplayDefault := Choice(Leveling, 'Gain when tags are missing', '-12 dB|-9 dB|-6 dB|-3 dB|0 dB|+3 dB|+6 dB|+9 dB|+12 dB', 18, 112);
  PeakProtection := TCheckBox.Create(Self);
  PeakProtection.Parent := Leveling;
  PeakProtection.Caption := 'Prevent clipping from ReplayGain peaks';
  PeakProtection.SetBounds(MulDiv(18, Leveling.CurrentPPI, 96), MulDiv(206, Leveling.CurrentPPI, 96), MulDiv(490, Leveling.CurrentPPI, 96), MulDiv(24, Leveling.CurrentPPI, 96));
  var Appearance := Group(ExtraPage('Subtitle appearance'), 'Text subtitles (next file; embedded ASS styling may override)', 12, 226);
  TextColor := Choice(Appearance, 'Text color', 'White|Warm yellow|Green|Cyan', 18, 30);
  OutlineSize := Choice(Appearance, 'Black outline', 'None|Thin|Normal|Thick', 280, 30);
  Shadow := Choice(Appearance, 'Black shadow', 'Off|Subtle|Medium|Strong', 18, 118);
  Background := Choice(Appearance, 'Black background opacity', 'Transparent|25%|50%|75%|Opaque', 280, 118);
  var Dual := Group(Appearance.Parent as TTabSheet, 'Dual subtitles (UTF-8 SRT)', 260, 120);
  var DualHint := TLabel.Create(Self);
  DualHint.Parent := Dual;
  DualHint.Caption := 'Load the primary SRT first. The secondary language appears at the top.';
  DualHint.SetBounds(MulDiv(18, Dual.CurrentPPI, 96), MulDiv(28, Dual.CurrentPPI, 96),
    MulDiv(516, Dual.CurrentPPI, 96), MulDiv(22, Dual.CurrentPPI, 96));
  LoadButton(Dual, 'Load secondary SRT...', False);
  TButton(Dual.Controls[Dual.ControlCount - 1]).Tag := 2;
  TButton(Dual.Controls[Dual.ControlCount - 1]).Top := MulDiv(66, Dual.CurrentPPI, 96);
end;

destructor TAdvancedSettings.Destroy;
begin
  DeviceIDs.Free;
  inherited;
end;

procedure TAdvancedSettings.LoadExternal(Sender: TObject);
begin
  if not Assigned(FrmMain) or (FrmMain.CurrentMedia = nil) then
  begin PlayerMessage('Open a video before loading an external track.'); Exit; end;
  var Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Options := [ofFileMustExist, ofPathMustExist, ofEnableSizing];
    if TButton(Sender).Tag = 2 then Dialog.Filter := 'UTF-8 SRT subtitles|*.srt'
    else if TButton(Sender).Tag = 1 then
      Dialog.Filter := 'Audio files|*.aac;*.ac3;*.dts;*.eac3;*.flac;*.m4a;*.mp3;*.ogg;*.opus;*.wav;*.wma|All files|*.*'
    else Dialog.Filter := 'Subtitles|*.srt;*.ass;*.ssa;*.vtt;*.sub;*.idx|All files|*.*';
    if not Dialog.Execute then Exit;
    var Loaded: Boolean;
    if TButton(Sender).Tag = 2 then Loaded := FrmMain.LoadSecondarySubtitleFile(Dialog.FileName)
    else if TButton(Sender).Tag = 1 then Loaded := FrmMain.LoadAudioFile(Dialog.FileName)
    else Loaded := FrmMain.LoadSubtitleFile(Dialog.FileName);
    if not Loaded and (TButton(Sender).Tag = 2) then PlayerMessage('Load a primary UTF-8 SRT subtitle first, then choose a valid secondary SRT.')
    else if not Loaded then PlayerMessage('The external track could not be loaded.')
    else begin RefreshRemaining := 8; RefreshTimer.Enabled := True; end;
  finally Dialog.Free; end;
end;

procedure TAdvancedSettings.QueueRefresh;
begin RefreshRemaining:=1; RefreshTimer.Enabled:=True; end;

procedure TAdvancedSettings.RefreshAfterLoad(Sender: TObject);
begin
  Dec(RefreshRemaining);
  RefreshTimer.Enabled := RefreshRemaining > 0;
  RefreshTracks;
end;

procedure TAdvancedSettings.Reset;
begin
  FLoading := True;
  try
    Aspect.ItemIndex := 0;
    Crop.ItemIndex := 0;
    Zoom.ItemIndex := 0;
    SubMargin.ItemIndex := 0;
    AudioLanguage.Text := 'Automatic';
    SubLanguage.Text := 'Automatic';
    Device.ItemIndex := 0;
    Transform.ItemIndex := 0;
    Sharpen.ItemIndex := 0;
    Deband.ItemIndex := 0;
    ReplayGain.ItemIndex := 0;
    ReplayPreamp.ItemIndex := 4;
    ReplayDefault.ItemIndex := 4;
    PeakProtection.Checked := True;
    TextColor.ItemIndex := 0;
    OutlineSize.ItemIndex := 2;
    Shadow.ItemIndex := 2;
    Background.ItemIndex := 0;
  finally FLoading := False; end;
end;

procedure TAdvancedSettings.Load(Store: TAppSettings);
const Zooms: array[0..4] of Integer = (0, 50, 100, 150, 200);
begin
  FLoading := True;
  try
    Aspect.ItemIndex := Aspect.Items.IndexOf(Store.ReadString('Video', 'AspectRatio', 'Default'));
    if Store.ReadBool('Video', 'AspectAuto', True) then Aspect.ItemIndex := 0;
    Crop.ItemIndex := Crop.Items.IndexOf(Store.ReadString('Video', 'Crop', 'Default'));
    Zoom.ItemIndex := 0;
    for var I := 0 to High(Zooms) do
      if Zooms[I] = Store.ReadInteger('Video', 'ZoomPercent', 0) then Zoom.ItemIndex := I;
    var AudioLanguageValue:=Store.ReadString('Audio','PreferredLanguages','');
    if AudioLanguageValue='' then AudioLanguageValue:='Automatic';
    var AudioLanguageIndex:=AudioLanguage.Items.IndexOf(AudioLanguageValue);
    if AudioLanguageIndex<0 then AudioLanguageIndex:=AudioLanguage.Items.Add(AudioLanguageValue);
    AudioLanguage.ItemIndex:=AudioLanguageIndex;
    var SubLanguageValue:=Store.ReadString('Subtitles','PreferredLanguages','');
    if SubLanguageValue='' then SubLanguageValue:='Automatic';
    var SubLanguageIndex:=SubLanguage.Items.IndexOf(SubLanguageValue);
    if SubLanguageIndex<0 then SubLanguageIndex:=SubLanguage.Items.Add(SubLanguageValue);
    SubLanguage.ItemIndex:=SubLanguageIndex;
    SubMargin.ItemIndex := Store.ReadInteger('Subtitles', 'Margin', 0) div 20;
    Transform.ItemIndex := Store.ReadInteger('Video', 'Transform', 0);
    Sharpen.ItemIndex := Store.ReadInteger('Video', 'Sharpen', 0);
    Deband.ItemIndex := Store.ReadInteger('Video', 'Deband', 0);
    ReplayGain.ItemIndex := Store.ReadInteger('Audio', 'ReplayGain', 0);
    ReplayPreamp.ItemIndex := Store.ReadInteger('Audio', 'ReplayPreamp', 4);
    ReplayDefault.ItemIndex := Store.ReadInteger('Audio', 'ReplayDefault', 4);
    PeakProtection.Checked := Store.ReadBool('Audio', 'ReplayPeakProtection', True);
    TextColor.ItemIndex := Store.ReadInteger('Subtitles', 'TextColor', 0);
    OutlineSize.ItemIndex := Store.ReadInteger('Subtitles', 'Outline', 2);
    Shadow.ItemIndex := Store.ReadInteger('Subtitles', 'Shadow', 2);
    Background.ItemIndex := Store.ReadInteger('Subtitles', 'Background', 0);
  finally FLoading := False; end;
end;

procedure TAdvancedSettings.Save(Store: TAppSettings);
const Zooms: array[0..4] of Integer = (0, 50, 100, 150, 200);
begin
  if Aspect.ItemIndex >= 0 then
  begin
    Store.WriteString('Video', 'AspectRatio', Aspect.Text);
    Store.WriteBool('Video', 'AspectAuto', Aspect.ItemIndex = 0);
  end;
  if Crop.ItemIndex >= 0 then Store.WriteString('Video', 'Crop', Crop.Text);
  if Zoom.ItemIndex >= 0 then Store.WriteInteger('Video', 'ZoomPercent', Zooms[Zoom.ItemIndex]);
  var Language := AudioLanguage.Text;
  if SameText(Language, 'Automatic') then Language := '';
  Store.WriteString('Audio', 'PreferredLanguages', Language);
  Language := SubLanguage.Text;
  if SameText(Language, 'Automatic') then Language := '';
  Store.WriteString('Subtitles', 'PreferredLanguages', Language);
  if SubMargin.ItemIndex >= 0 then Store.WriteInteger('Subtitles', 'Margin', SubMargin.ItemIndex * 20);
  if (Device.ItemIndex >= 0) and (Device.ItemIndex < DeviceIDs.Count) then
    Store.WriteString('Audio', 'DeviceID', DeviceIDs[Device.ItemIndex]);
  Store.WriteInteger('Video', 'Transform', Transform.ItemIndex);
  Store.WriteInteger('Video', 'Sharpen', Sharpen.ItemIndex);
  Store.WriteInteger('Video', 'Deband', Deband.ItemIndex);
  Store.WriteInteger('Audio', 'ReplayGain', ReplayGain.ItemIndex);
  Store.WriteInteger('Audio', 'ReplayPreamp', ReplayPreamp.ItemIndex);
  Store.WriteInteger('Audio', 'ReplayDefault', ReplayDefault.ItemIndex);
  Store.WriteBool('Audio', 'ReplayPeakProtection', PeakProtection.Checked);
  Store.WriteInteger('Subtitles', 'TextColor', TextColor.ItemIndex);
  Store.WriteInteger('Subtitles', 'Outline', OutlineSize.ItemIndex);
  Store.WriteInteger('Subtitles', 'Shadow', Shadow.ItemIndex);
  Store.WriteInteger('Subtitles', 'Background', Background.ItemIndex);
end;

procedure TAdvancedSettings.RefreshTracks;
  procedure FillTracks(Combo: TComboBox; Head: Plibvlc_track_description_t; Selected: Integer);
  var Item: Plibvlc_track_description_t;
  begin
    Combo.Items.Clear;
    Item := Head;
    while Item <> nil do
    begin
      var Index := Combo.Items.AddObject(UTF8ToString(Item.psz_name), TObject(NativeInt(Item.i_id)));
      if Item.i_id = Selected then Combo.ItemIndex := Index;
      Item := Item.p_next;
    end;
    if Head <> nil then libvlc_track_description_list_release(Head);
    Combo.Enabled := Combo.Items.Count > 0;
  end;
begin
  if not Assigned(FrmMain) or (FrmMain.MediaPlayer = nil) then Exit;
  FLoading := True;
  try
    FillTracks(AudioTrack, libvlc_audio_get_track_description(FrmMain.MediaPlayer), libvlc_audio_get_track(FrmMain.MediaPlayer));
    FillTracks(SubTrack, libvlc_video_get_spu_description(FrmMain.MediaPlayer), libvlc_video_get_spu(FrmMain.MediaPlayer));
    if (DeviceIDs.Count=0) or (FDevicePlayer<>Pointer(FrmMain.MediaPlayer)) then
    begin
    FDevicePlayer:=Pointer(FrmMain.MediaPlayer);
    Device.Items.Clear;
    DeviceIDs.Clear;
    Device.Items.Add('System default');
    DeviceIDs.Add('');
    var Head := libvlc_audio_output_device_enum(FrmMain.MediaPlayer);
    var Item := Head;
    while Item <> nil do
    begin
      Device.Items.Add(UTF8ToString(Item.psz_description));
      DeviceIDs.Add(UTF8ToString(Item.psz_device));
      Item := Item.p_next;
    end;
    if Head <> nil then libvlc_audio_output_device_list_release(Head);
    end;
    var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
    try Device.ItemIndex := DeviceIDs.IndexOf(Store.ReadString('Audio', 'DeviceID', ''));
    finally Store.Free; end;
    if Device.ItemIndex < 0 then Device.ItemIndex := 0;
  finally FLoading := False; end;
end;

procedure TAdvancedSettings.SelectRuntime(Sender: TObject);
begin
  if FLoading or not Assigned(FrmMain) or (FrmMain.MediaPlayer = nil) then Exit;
  if (Sender = AudioTrack) and (AudioTrack.ItemIndex >= 0) then
    libvlc_audio_set_track(FrmMain.MediaPlayer, Integer(NativeInt(AudioTrack.Items.Objects[AudioTrack.ItemIndex])))
  else if (Sender = SubTrack) and (SubTrack.ItemIndex >= 0) then
    libvlc_video_set_spu(FrmMain.MediaPlayer, Integer(NativeInt(SubTrack.Items.Objects[SubTrack.ItemIndex])))
  else if (Sender = Device) and (Device.ItemIndex >= 0) then
  begin
    var ID := UTF8Encode(DeviceIDs[Device.ItemIndex]);
    if ID = '' then libvlc_audio_output_device_set(FrmMain.MediaPlayer, nil, nil)
    else libvlc_audio_output_device_set(FrmMain.MediaPlayer, nil, PAnsiChar(ID));
  end;
end;

end.
