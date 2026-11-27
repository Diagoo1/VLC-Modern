unit PlayerSettings;

interface

uses SettingsStore, System.SysUtils, LibVLC;

type
  TPlayerSettings = record
    ShowOSD, ShowFilename, WheelVolume, SaveHistory, AutoPlayNext: Boolean;
    SingleClick, DoubleClick, ResumeMode, AfterPlayback: Integer;
    JumpShort, JumpMedium, JumpLong: Integer;
    Hardware, VideoOutput, AudioOutput, Deinterlace, SubtitleSize, Cache: Integer;
    DirectRendering, PreservePitch, Normalize, SubtitleBold, SubtitleAutoLoad, HLSHardware: Boolean;
    SubtitleFont, SubtitleEncoding, UserAgent: string;
    Compressor, Spatializer, Widener, EqualizerTwoPass, Equalizer, VideoAdjust: Boolean;
    ChannelMode, StartupVolume: Integer;
    RememberVolume, EnterFullscreen: Boolean;
    AspectRatio, Crop, AudioLanguage, SubtitleLanguage, AudioDeviceID: string;
    ZoomPercent, SubtitleMargin: Integer;
    OSDDuration, OSDFontSize: Integer;
    RememberWindow, StartFullscreen, BossKeyHide, ShowSpeedOSD: Boolean;
    SkipOpening, SkipEnding: Boolean;
    VoiceClarifier, NightMode, HeadphoneSurround, KaraokeMode, AudioPassthrough: Boolean;
    SkipOpeningSeconds, SkipEndingSeconds: Integer;
    Transform, ReplayGain, ReplayPreamp, ReplayDefault: Integer;
    Sharpen, Deband, VideoProfile, BufferPreset, ScalingMode: Integer;
    Lut3DPath: string;
    ShaderInvert, ShaderSharpen, ShaderEdgeDetect, ShaderFilmGrain: Boolean;
    ShaderDenoise, ShaderSepia, ShaderPosterize, ShaderAnaglyph: Boolean;
    ReplayPeakProtection: Boolean;
    SubtitleColor, SubtitleOutline, SubtitleShadow, SubtitleBackground: Integer;
    CompressorValues: array[0..6] of Integer;
    SpatializerValues: array[0..4] of Integer;
    WidenerValues: array[0..3] of Integer;
    class function Load(const Path: string): TPlayerSettings; static;
    procedure ApplyMedia(Media: Plibvlc_media_t; Network: Boolean; const StreamAgent: string = '');
    function EngineOptions: TArray<UTF8String>;
  end;

implementation

uses System.IniFiles, System.Math, System.Classes;

class function TPlayerSettings.Load(const Path: string): TPlayerSettings;
const ShortSteps: array[0..2] of Integer = (3, 5, 10);
      MediumSteps: array[0..2] of Integer = (10, 30, 60);
      LongSteps: array[0..2] of Integer = (30, 60, 300);
      FontSizes: array[0..3] of Integer = (16, 22, 28, 36);
      Caches: array[0..3] of Integer = (1000, 2000, 3500, 5000);
      Encodings: array[0..4] of string = ('UTF-8', 'Windows-1256', 'Windows-1252', 'Windows-1250', 'Windows-1251');
      CompDefaults: array[0..6] of Integer = (0, 25, 100, -11, 4, 3, 7);
      SpaceDefaults: array[0..4] of Integer = (50, 70, 40, 60, 50);
      WideDefaults: array[0..3] of Integer = (20, 30, 40, 50);
      OSDDurations: array[0..3] of Integer = (1000, 2000, 3500, 5000);
      OSDSizes: array[0..3] of Integer = (14, 18, 24, 32);
var Ini: TAppSettings;
begin
  Result := Default(TPlayerSettings);
  Ini := TAppSettings.Create(Path);
  try
    Result.EnterFullscreen:=Ini.ReadBool('General','EnterFullscreen',True);
    Result.ShowOSD := Ini.ReadBool('General', 'ShowOSD', True);
    Result.OSDDuration := OSDDurations[EnsureRange(Ini.ReadInteger('General', 'OsdDuration', 1), 0, 3)];
    Result.OSDFontSize := OSDSizes[EnsureRange(Ini.ReadInteger('General', 'OsdSize', 1), 0, 3)];
    Result.RememberWindow := Ini.ReadBool('General', 'RememberSize', True);
    Result.StartFullscreen := Ini.ReadBool('General', 'StartFullscreen', False);
    Result.BossKeyHide := Ini.ReadBool('General', 'BossKeyHide', True);
    Result.ShowSpeedOSD := Ini.ReadBool('Playback', 'ShowSpeedOSD', True);
    Result.ShowFilename := Ini.ReadBool('General', 'ShowFilename', True);
    Result.WheelVolume := Ini.ReadBool('General', 'WheelVolume', True);
    Result.SingleClick := EnsureRange(Ini.ReadInteger('General', 'SingleClick', 0), 0, 2);
    Result.DoubleClick := EnsureRange(Ini.ReadInteger('General', 'DblClick', 0), 0, 2);
    Result.SaveHistory := Ini.ReadBool('Playback', 'SaveHistory', True);
    Result.AutoPlayNext := Ini.ReadBool('Playback', 'AutoPlayNext', False);
    Result.ResumeMode := EnsureRange(Ini.ReadInteger('Playback', 'Resume', 0), 0, 2);
    Result.AfterPlayback := EnsureRange(Ini.ReadInteger('Playback', 'AfterPlayback', 0), 0, 4);
    Result.JumpShort := ShortSteps[EnsureRange(Ini.ReadInteger('Playback', 'JumpShort', 2), 0, 2)];
    Result.JumpMedium := MediumSteps[EnsureRange(Ini.ReadInteger('Playback', 'JumpMedium', 1), 0, 2)];
    Result.JumpLong := LongSteps[EnsureRange(Ini.ReadInteger('Playback', 'JumpLong', 1), 0, 2)];
    Result.PreservePitch := Ini.ReadBool('Playback', 'Scaletempo', True);
    Result.SkipOpening := Ini.ReadBool('Playback', 'SkipOpening', False);
    Result.SkipOpeningSeconds := EnsureRange(Ini.ReadInteger('Playback', 'SkipOpeningSeconds', 90), 1, 600);
    Result.SkipEnding := Ini.ReadBool('Playback', 'SkipEnding', False);
    Result.SkipEndingSeconds := EnsureRange(Ini.ReadInteger('Playback', 'SkipEndingSeconds', 60), 1, 600);
    Result.Hardware := EnsureRange(Ini.ReadInteger('Video', 'HwAccel', 0), 0, 3);
    Result.DirectRendering := Ini.ReadBool('Video', 'ZeroCopy', True);
    Result.VideoOutput := EnsureRange(Ini.ReadInteger('Video', 'Vout', 0), 0, 4);
    Result.Deinterlace := EnsureRange(Ini.ReadInteger('Video', 'Deinterlace', 1), 0, 4);
    Result.AudioOutput := EnsureRange(Ini.ReadInteger('Audio', 'Aout', 0), 0, 3);
    // Older versions shared these values with the temporary playback controls.
    Result.AspectRatio := Ini.ReadString('Video', 'DefaultAspectRatio', 'Default');
    Result.Crop := Ini.ReadString('Video', 'DefaultCrop', 'Default');
    Result.ZoomPercent := EnsureRange(Ini.ReadInteger('Video', 'DefaultZoomPercent', 0), 0, 400);
    Result.AudioLanguage := Ini.ReadString('Audio', 'PreferredLanguages', '');
    Result.SubtitleLanguage := Ini.ReadString('Subtitles', 'PreferredLanguages', '');
    Result.AudioDeviceID := Ini.ReadString('Audio', 'DeviceID', '');
    Result.SubtitleMargin := EnsureRange(Ini.ReadInteger('Subtitles', 'Margin', 0), 0, 200);
    Result.ChannelMode := EnsureRange(Ini.ReadInteger('Audio', 'ChannelMode', 0), 0, 5);
    Result.RememberVolume := Ini.ReadBool('Audio', 'RememberVolume', True);
    Result.StartupVolume := EnsureRange(Ini.ReadInteger('Audio', 'DefaultVolume', 100), 0, 200);
    if Result.RememberVolume then Result.StartupVolume := EnsureRange(Ini.ReadInteger('Audio', 'LastVolume', Result.StartupVolume), 0, 200);
    Result.Normalize := Ini.ReadBool('Audio', 'Normalizer', False);
    Result.VoiceClarifier := Ini.ReadBool('Audio', 'VoiceClarifier', False);
    Result.NightMode := Ini.ReadBool('Audio', 'NightMode', False);
    Result.HeadphoneSurround := Ini.ReadBool('Audio', 'HeadphoneSurround', False);
    Result.KaraokeMode := Ini.ReadBool('Audio', 'KaraokeMode', False);
    Result.AudioPassthrough := Ini.ReadBool('Audio', 'AudioPassthrough', False);
    Result.SubtitleFont := Ini.ReadString('Subtitles', 'Font', 'Segoe UI');
    Result.SubtitleSize := FontSizes[EnsureRange(Ini.ReadInteger('Subtitles', 'Size', 1), 0, 3)];
    Result.SubtitleEncoding := Encodings[EnsureRange(Ini.ReadInteger('Subtitles', 'Encoding', 0), 0, 4)];
    Result.SubtitleBold := Ini.ReadBool('Subtitles', 'Bold', True);
    Result.SubtitleAutoLoad := Ini.ReadBool('Subtitles', 'AutoLoad', True);
    Result.Transform := EnsureRange(Ini.ReadInteger('Video', 'Transform', 0), 0, 7);
    Result.VideoProfile := EnsureRange(Ini.ReadInteger('Video', 'VideoProfile', 0), 0, 5);
    Result.ScalingMode := EnsureRange(Ini.ReadInteger('Video', 'ScalingMode', 0), 0, 3);
    Result.Lut3DPath := Ini.ReadString('Video', 'Lut3DPath', '');
    Result.BufferPreset := EnsureRange(Ini.ReadInteger('Network', 'BufferPreset', 1), 0, 3);
    Result.Sharpen := EnsureRange(Ini.ReadInteger('Video', 'Sharpen', 0), 0, 3);
    Result.Deband := EnsureRange(Ini.ReadInteger('Video', 'Deband', 0), 0, 3);
    Result.ShaderInvert := Ini.ReadBool('VideoShaders', 'Invert', False);
    Result.ShaderSharpen := Ini.ReadBool('VideoShaders', 'Sharpen', False);
    Result.ShaderEdgeDetect := Ini.ReadBool('VideoShaders', 'EdgeDetect', False);
    Result.ShaderFilmGrain := Ini.ReadBool('VideoShaders', 'FilmGrain', False);
    Result.ShaderDenoise := Ini.ReadBool('VideoShaders', 'Denoise', False);
    Result.ShaderSepia := Ini.ReadBool('VideoShaders', 'Sepia', False);
    Result.ShaderPosterize := Ini.ReadBool('VideoShaders', 'Posterize', False);
    Result.ShaderAnaglyph := Ini.ReadBool('VideoShaders', 'Anaglyph', False);
    Result.ReplayGain := EnsureRange(Ini.ReadInteger('Audio', 'ReplayGain', 0), 0, 2);
    Result.ReplayPreamp := (EnsureRange(Ini.ReadInteger('Audio', 'ReplayPreamp', 4), 0, 8) - 4) * 3;
    Result.ReplayDefault := (EnsureRange(Ini.ReadInteger('Audio', 'ReplayDefault', 4), 0, 8) - 4) * 3;
    Result.ReplayPeakProtection := Ini.ReadBool('Audio', 'ReplayPeakProtection', True);
    Result.SubtitleColor := EnsureRange(Ini.ReadInteger('Subtitles', 'TextColor', 0), 0, 3);
    Result.SubtitleOutline := EnsureRange(Ini.ReadInteger('Subtitles', 'Outline', 2), 0, 3) * 2;
    Result.SubtitleShadow := EnsureRange(Ini.ReadInteger('Subtitles', 'Shadow', 2), 0, 3);
    Result.SubtitleBackground := EnsureRange(Ini.ReadInteger('Subtitles', 'Background', 0), 0, 4);
    Result.Cache := Caches[EnsureRange(Ini.ReadInteger('Network', 'CacheBuffer', 1), 0, 3)];
    Result.UserAgent := Ini.ReadString('Network', 'UserAgent', 'VLCModern/1.0');
    Result.HLSHardware := Ini.ReadBool('Network', 'HlsHardware', True);
    Result.Compressor := Ini.ReadBool('AudioEffects', 'Compressor', False);
    Result.Spatializer := Ini.ReadBool('AudioEffects', 'Spatializer', False);
    Result.Widener := Ini.ReadBool('AudioEffects', 'Widener', False);
    Result.EqualizerTwoPass := Ini.ReadBool('AudioEffects', 'TwoPass', False);
    Result.Equalizer := Ini.ReadBool('AudioEffects', 'Equalizer', False);
    Result.VideoAdjust := Ini.ReadBool('AudioEffects', 'VideoAdjust', False);
    for var I := 0 to High(Result.CompressorValues) do
      Result.CompressorValues[I] := Ini.ReadInteger('AudioEffects', 'Compressor' + IntToStr(I), CompDefaults[I]);
    for var I := 0 to High(Result.SpatializerValues) do
      Result.SpatializerValues[I] := EnsureRange(Ini.ReadInteger('AudioEffects', 'Spatializer' + IntToStr(I), SpaceDefaults[I]), 0, 100);
    for var I := 0 to High(Result.WidenerValues) do
      Result.WidenerValues[I] := EnsureRange(Ini.ReadInteger('AudioEffects', 'Widener' + IntToStr(I), WideDefaults[I]), 0, 100);
  finally Ini.Free; end;
end;

function TPlayerSettings.EngineOptions: TArray<UTF8String>;
const Transforms: array[0..7] of string = ('', '90', '180', '270', 'hflip', 'vflip', 'transpose', 'antitranspose');
      GainModes: array[0..2] of string = ('none', 'track', 'album');
      Colors: array[0..3] of Integer = ($FFFFFF, $FFE08A, $80FF80, $80E8FF);
      Shadows: array[0..3] of Integer = (0, 64, 128, 192);
      Backgrounds: array[0..4] of Integer = (0, 64, 128, 192, 255);
      SharpenValues: array[0..3] of string = ('0', '0.2', '0.6', '1.2');
      DebandValues: array[0..3] of string = ('0', '0.8', '1.2', '2.0');
      SwScaleModes: array[0..3] of Integer = (10, 9, 2, 1);
begin
  Result := ['--quiet', '--no-video-title-show', '--no-snapshot-preview', '--no-mouse-events', '--no-osd', '--ignore-config'];
  var Options := TStringList.Create;
  try
    Options.Add('--swscale-mode=' + IntToStr(SwScaleModes[EnsureRange(ScalingMode, 0, 3)]));
    var Filters := '';
    if Transform > 0 then
    begin
      Filters := 'transform';
      Options.Add('--transform-type=' + Transforms[Transform]);
    end;
    if Sharpen > 0 then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'sharpen';
      Options.Add('--sharpen-sigma=' + SharpenValues[Sharpen]);
    end;
    if Deband > 0 then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'gradfun';
      Options.Add('--gradfun-strength=' + DebandValues[Deband]);
      Options.Add('--gradfun-radius=16');
    end;
    if ShaderInvert then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'invert';
    end;
    if ShaderSharpen then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'sharpen';
      Options.Add('--sharpen-sigma=1.5');
    end;
    if ShaderEdgeDetect then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'edgedetection';
    end;
    if ShaderFilmGrain then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'grain';
      Options.Add('--grain-variance=2.0');
    end;
    if ShaderDenoise then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'hqdn3d';
    end;
    if ShaderSepia then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'sepia';
    end;
    if ShaderPosterize then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'posterize';
    end;
    if ShaderAnaglyph then
    begin
      if Filters <> '' then Filters := Filters + ':';
      Filters := Filters + 'anaglyph';
    end;
    if Filters <> '' then Options.Add('--video-filter=' + Filters);
    Options.Add('--audio-replay-gain-mode=' + GainModes[ReplayGain]);
    Options.Add('--audio-replay-gain-preamp=' + IntToStr(ReplayPreamp));
    Options.Add('--audio-replay-gain-default=' + IntToStr(ReplayDefault));
    if ReplayPeakProtection then Options.Add('--audio-replay-gain-peak-protection')
    else Options.Add('--no-audio-replay-gain-peak-protection');
    if AudioPassthrough then Options.Add('--spdif');
    Options.Add('--freetype-color=' + IntToStr(Colors[SubtitleColor]));
    Options.Add('--freetype-outline-thickness=' + IntToStr(SubtitleOutline));
    Options.Add('--freetype-shadow-opacity=' + IntToStr(Shadows[SubtitleShadow]));
    Options.Add('--freetype-background-opacity=' + IntToStr(Backgrounds[SubtitleBackground]));
    for var Option in Options do Result := Result + [UTF8Encode(Option)];
  finally Options.Free; end;
end;

procedure TPlayerSettings.ApplyMedia(Media: Plibvlc_media_t; Network: Boolean; const StreamAgent: string);
const HW: array[0..3] of string = ('any', 'd3d11va', 'dxva2', 'none');
      VOut: array[0..4] of string = ('', 'direct3d11', 'direct3d9', 'wingdi', 'glwin32');
      Deinterlacers: array[0..4] of string = ('', 'yadif', 'yadif2x', 'bob', 'linear');
      CompNames: array[0..6] of string = ('rms-peak', 'attack', 'release', 'threshold', 'ratio', 'knee', 'makeup-gain');
      SpaceNames: array[0..4] of string = ('roomsize', 'width', 'wet', 'dry', 'damp');
      WideNames: array[0..3] of string = ('delay', 'feedback', 'crossfeed', 'dry-mix');
      Transforms: array[0..7] of string = ('', '90', '180', '270', 'hflip', 'vflip', 'transpose', 'antitranspose');
      GainModes: array[0..2] of string = ('none', 'track', 'album');
      TextColors: array[0..3] of Integer = ($FFFFFF, $FFE08A, $80FF80, $80E8FF);
      ShadowOpacity: array[0..3] of Integer = (0, 64, 128, 192);
      BackgroundOpacity: array[0..4] of Integer = (0, 64, 128, 192, 255);
      BufferValues: array[0..3] of Integer = (300, 1200, 3500, 10000);
      SwScaleModes: array[0..3] of Integer = (10, 9, 2, 1);
var Filters: string;
  procedure Add(const Option: string);
  var Bytes: UTF8String;
  begin
    Bytes := UTF8Encode(':' + Option);
    libvlc_media_add_option(Media, PAnsiChar(Bytes));
  end;
  procedure AddFilter(const Name: string);
  begin
    if Filters <> '' then Filters := Filters + ':';
    Filters := Filters + Name;
  end;
  function Decimal(Value: Double): string;
  begin
    Result := FloatToStr(Value, TFormatSettings.Invariant);
  end;
begin
  if Media = nil then Exit;
  if Network and not HLSHardware then Add('avcodec-hw=none')
  else Add('avcodec-hw=' + HW[Hardware]);
  if DirectRendering then Add('avcodec-dr') else Add('no-avcodec-dr');
  Add('swscale-mode=' + IntToStr(SwScaleModes[EnsureRange(ScalingMode, 0, 3)]));
  if VideoOutput <> 0 then Add('vout=' + VOut[VideoOutput]);
  if Deinterlace = 0 then Add('deinterlace=0')
  else if Deinterlace = 1 then Add('deinterlace=-1')
  else Add('deinterlace=1');
  if Deinterlace > 0 then Add('deinterlace-mode=' + Deinterlacers[Deinterlace]);
  var VidFilters := '';
  if Transform > 0 then
  begin
    VidFilters := 'transform';
    Add('transform-type=' + Transforms[Transform]);
  end;
  if ShaderInvert then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'invert';
  end;
  if ShaderSharpen then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'sharpen';
    Add('sharpen-sigma=1.5');
  end;
  if ShaderEdgeDetect then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'edgedetection';
  end;
  if ShaderFilmGrain then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'grain';
    Add('grain-variance=2.0');
  end;
  if ShaderDenoise then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'hqdn3d';
  end;
  if ShaderSepia then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'sepia';
  end;
  if ShaderPosterize then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'posterize';
  end;
  if ShaderAnaglyph then
  begin
    if VidFilters <> '' then VidFilters := VidFilters + ':';
    VidFilters := VidFilters + 'anaglyph';
  end;
  if VidFilters <> '' then Add('video-filter=' + VidFilters);
  Add('freetype-font=' + SubtitleFont);
  Add('freetype-fontsize=' + IntToStr(SubtitleSize));
  Add('subsdec-encoding=' + SubtitleEncoding);
  Add('sub-margin=' + IntToStr(SubtitleMargin));
  Add('freetype-color=' + IntToStr(TextColors[SubtitleColor]));
  Add('freetype-outline-thickness=' + IntToStr(SubtitleOutline));
  Add('freetype-outline-color=0');
  Add('freetype-shadow-opacity=' + IntToStr(ShadowOpacity[SubtitleShadow]));
  Add('freetype-shadow-color=0');
  Add('freetype-background-opacity=' + IntToStr(BackgroundOpacity[SubtitleBackground]));
  Add('freetype-background-color=0');
  Add('audio-replay-gain-mode=' + GainModes[ReplayGain]);
  Add('audio-replay-gain-preamp=' + IntToStr(ReplayPreamp));
  Add('audio-replay-gain-default=' + IntToStr(ReplayDefault));
  if ReplayPeakProtection then Add('audio-replay-gain-peak-protection') else Add('no-audio-replay-gain-peak-protection');
  if AudioLanguage <> '' then Add('audio-language=' + AudioLanguage);
  if SubtitleLanguage <> '' then Add('sub-language=' + SubtitleLanguage);
  if SubtitleBold then Add('freetype-bold') else Add('no-freetype-bold');
  if SubtitleAutoLoad then Add('sub-autodetect-file') else Add('no-sub-autodetect-file');
  Filters := '';
  if PreservePitch then Filters := 'scaletempo';
  if Normalize then
  begin
    if Filters <> '' then Filters := Filters + ':';
    Filters := Filters + 'normvol';
  end;
  if Compressor then
  begin
    AddFilter('compressor');
    for var I := 0 to High(CompNames) do
      if I = 0 then Add('compressor-' + CompNames[I] + '=' + Decimal(EnsureRange(CompressorValues[I], 0, 100) / 100))
      else Add('compressor-' + CompNames[I] + '=' + IntToStr(CompressorValues[I]));
  end;
  if Spatializer then
  begin
    AddFilter('spatializer');
    for var I := 0 to High(SpaceNames) do
      Add('spatializer-' + SpaceNames[I] + '=' + Decimal(SpatializerValues[I] / 100));
  end;
  if Widener then
  begin
    AddFilter('stereowiden');
    Add('stereowiden-delay=' + IntToStr(Max(1, WidenerValues[0])));
    Add('stereowiden-feedback=' + Decimal(Min(90, WidenerValues[1]) / 100));
    Add('stereowiden-crossfeed=' + Decimal(Min(80, WidenerValues[2]) / 100));
    Add('stereowiden-dry-mix=' + Decimal(WidenerValues[3] / 100));
  end;
  if EqualizerTwoPass then Add('equalizer-2pass') else Add('no-equalizer-2pass');
  if AudioPassthrough then Add('spdif');
  if KaraokeMode then AddFilter('karaoke');
  if HeadphoneSurround then
  begin
    AddFilter('headphone');
    Add('headphone-dim=2');
    Add('headphone-compensate');
  end;
  if VoiceClarifier then
  begin
    AddFilter('param_eq');
    Add('param-eq-f1=2000');
    Add('param-eq-gain1=6.0');
    Add('param-eq-q1=1.2');
  end;
  if NightMode then
  begin
    AddFilter('compressor');
    Add('compressor-rms-peak=0.2');
    Add('compressor-attack=15');
    Add('compressor-release=300');
    Add('compressor-threshold=-24');
    Add('compressor-ratio=5');
    Add('compressor-knee=3');
    Add('compressor-makeup-gain=6');
    AddFilter('normvol');
  end;
  if Filters <> '' then Add('audio-filter=' + Filters);
  var BufMs := BufferValues[EnsureRange(BufferPreset, 0, 3)];
  Add('network-caching=' + IntToStr(BufMs));
  Add('file-caching=' + IntToStr(BufMs));
  Add('live-caching=' + IntToStr(BufMs));
  Add('disc-caching=' + IntToStr(BufMs));
  if Network then
    Add('http-user-agent=' + UserAgent);
end;

end.
