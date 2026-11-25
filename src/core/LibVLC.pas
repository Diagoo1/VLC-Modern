unit LibVLC;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  Winapi.Windows, System.SysUtils;

type
  Plibvlc_instance_t = Pointer;
  Plibvlc_media_t = Pointer;
  Plibvlc_media_player_t = Pointer;
  Plibvlc_equalizer_t = Pointer;
  Plibvlc_renderer_discoverer_t = Pointer;
  Plibvlc_renderer_item_t = Pointer;
  Plibvlc_event_manager_t = Pointer;

  Plibvlc_event_t = ^libvlc_event_t;
  libvlc_event_t = record
    i_type: Integer;
    p_obj: Pointer;
    u_ptr: Pointer;
  end;
  libvlc_callback_t = procedure(p_event: Plibvlc_event_t; p_user_data: Pointer); cdecl;

  Plibvlc_audio_track_t = ^libvlc_audio_track_t;
  libvlc_audio_track_t = record
    i_channels: Cardinal;
    i_rate: Cardinal;
  end;

  Plibvlc_video_track_t = ^libvlc_video_track_t;
  libvlc_video_track_t = record
    i_height: Cardinal;
    i_width: Cardinal;
    i_sar_num: Cardinal;
    i_sar_den: Cardinal;
    i_frame_rate_num: Cardinal;
    i_frame_rate_den: Cardinal;
  end;

  Plibvlc_media_track_t = ^libvlc_media_track_t;
  PPlibvlc_media_track_t = ^Plibvlc_media_track_t;
  PPPlibvlc_media_track_t = ^PPlibvlc_media_track_t;
  libvlc_media_track_t = record
    i_codec: Cardinal;
    i_original_fourcc: Cardinal;
    i_id: Integer;
    i_type: Integer; // 0=audio, 1=video, 2=text in libvlc_track_type_t (actually 0=unknown, 0=audio? Wait: unknown=-1, audio=0, video=1, text=2)
    i_profile: Integer;
    i_level: Integer;
    u_track: Pointer;
    i_bitrate: Cardinal;
    psz_language: PAnsiChar;
    psz_description: PAnsiChar;
  end;
  TLibVLCMediaStats = record
    ReadBytes: Integer;
    InputBitrate: Single;
    DemuxReadBytes: Integer;
    DemuxBitrate: Single;
    DemuxCorrupted, DemuxDiscontinuity: Integer;
    DecodedVideo, DecodedAudio: Integer;
    DisplayedPictures, LostPictures: Integer;
    PlayedAudioBuffers, LostAudioBuffers: Integer;
    SentPackets, SentBytes: Integer;
    SendBitrate: Single;
  end;
  PLibVLCMediaStats = ^TLibVLCMediaStats;

  libvlc_state_t = (
    libvlc_NothingSpecial = 0,
    libvlc_Opening = 1,
    libvlc_Buffering = 2,
    libvlc_Playing = 3,
    libvlc_Paused = 4,
    libvlc_Stopped = 5,
    libvlc_Ended = 6,
    libvlc_Error = 7
  );

  libvlc_meta_t = (
    libvlc_meta_Title = 0,
    libvlc_meta_Artist = 1,
    libvlc_meta_Genre = 2,
    libvlc_meta_Copyright = 3,
    libvlc_meta_Album = 4,
    libvlc_meta_TrackNumber = 5,
    libvlc_meta_Description = 6,
    libvlc_meta_Rating = 7,
    libvlc_meta_Date = 8,
    libvlc_meta_Setting = 9,
    libvlc_meta_URL = 10,
    libvlc_meta_Language = 11,
    libvlc_meta_NowPlaying = 12,
    libvlc_meta_Publisher = 13,
    libvlc_meta_EncodedBy = 14,
    libvlc_meta_ArtworkURL = 15,
    libvlc_meta_TrackID = 16,
    libvlc_meta_TrackTotal = 17,
    libvlc_meta_Director = 18,
    libvlc_meta_Season = 19,
    libvlc_meta_Episode = 20,
    libvlc_meta_ShowName = 21,
    libvlc_meta_Actors = 22,
    libvlc_meta_AlbumArtist = 23,
    libvlc_meta_DiscNumber = 24,
    libvlc_meta_DiscTotal = 25
  );

  Plibvlc_track_description_t = ^libvlc_track_description_t;
  libvlc_track_description_t = record
    i_id: Integer;
    psz_name: PAnsiChar;
    p_next: Plibvlc_track_description_t;
  end;

  Plibvlc_audio_output_device_t = ^libvlc_audio_output_device_t;
  libvlc_audio_output_device_t = record
    p_next: Plibvlc_audio_output_device_t;
    psz_device: PAnsiChar;
    psz_description: PAnsiChar;
  end;

const
  libvlc_adjust_Enable     = 0;
  libvlc_adjust_Contrast   = 1;
  libvlc_adjust_Brightness = 2;
  libvlc_adjust_Hue        = 3;
  libvlc_adjust_Saturation = 4;
  libvlc_adjust_Gamma      = 5;

  libvlc_AudioChannel_Error   = -1;
  libvlc_AudioChannel_Stereo  = 1;
  libvlc_AudioChannel_RStereo = 2;
  libvlc_AudioChannel_Left    = 3;
  libvlc_AudioChannel_Right   = 4;
  libvlc_AudioChannel_Dolbys  = 5;

  libvlc_track_unknown = -1;
  libvlc_track_audio   = 0;
  libvlc_track_video   = 1;
  libvlc_track_text    = 2;

  libvlc_RendererDiscovererItemAdded   = $502;
  libvlc_RendererDiscovererItemDeleted = $503;

var
  libvlc_video_set_mouse_input: procedure(p_mi: Plibvlc_media_player_t; on_: Cardinal); cdecl;
  libvlc_video_set_key_input: procedure(p_mi: Plibvlc_media_player_t; on_: Cardinal); cdecl;
  libvlc_video_set_callbacks: procedure(p_mi: Plibvlc_media_player_t;
    Lock, Unlock, Display, Opaque: Pointer); cdecl;
  libvlc_video_set_format_callbacks: procedure(p_mi: Plibvlc_media_player_t;
    Setup, Cleanup: Pointer); cdecl;
  // Core Functions
  libvlc_new: function(argc: Integer; argv: PPAnsiChar): Plibvlc_instance_t; cdecl;
  libvlc_release: procedure(p_instance: Plibvlc_instance_t); cdecl;
  libvlc_get_version: function: PAnsiChar; cdecl;
  libvlc_errmsg: function: PAnsiChar; cdecl;
  libvlc_clearerr: procedure; cdecl;
  libvlc_free: procedure(ptr: Pointer); cdecl;
  libvlc_media_player_is_seekable: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_get_stats: function(p_md: Plibvlc_media_t; Stats: PLibVLCMediaStats): Integer; cdecl;

  // Media
  libvlc_media_new_path: function(p_instance: Plibvlc_instance_t; path: PAnsiChar): Plibvlc_media_t; cdecl;
  libvlc_media_new_location: function(p_instance: Plibvlc_instance_t; mrl: PAnsiChar): Plibvlc_media_t; cdecl;
  libvlc_media_release: procedure(p_md: Plibvlc_media_t); cdecl;
  libvlc_media_get_duration: function(p_md: Plibvlc_media_t): Int64; cdecl;
  libvlc_media_parse: procedure(p_md: Plibvlc_media_t); cdecl;
  libvlc_media_parse_with_options: function(p_md: Plibvlc_media_t; parse_flag: Cardinal; timeout: Integer): Integer; cdecl;
  libvlc_media_get_meta: function(p_md: Plibvlc_media_t; e_meta: Integer): PAnsiChar; cdecl;
  libvlc_media_add_option: procedure(p_md: Plibvlc_media_t; psz_options: PAnsiChar); cdecl;
  libvlc_media_add_option_flag: procedure(p_md: Plibvlc_media_t; psz_options: PAnsiChar; i_flags: Cardinal); cdecl;

  // Media Player
  libvlc_media_player_new: function(p_instance: Plibvlc_instance_t): Plibvlc_media_player_t; cdecl;
  libvlc_media_player_new_from_media: function(p_md: Plibvlc_media_t): Plibvlc_media_player_t; cdecl;
  libvlc_media_player_release: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_set_media: procedure(p_mi: Plibvlc_media_player_t; p_md: Plibvlc_media_t); cdecl;
  libvlc_media_player_get_media: function(p_mi: Plibvlc_media_player_t): Plibvlc_media_t; cdecl;
  libvlc_media_player_set_hwnd: procedure(p_mi: Plibvlc_media_player_t; drawable: Pointer); cdecl;
  libvlc_media_player_get_hwnd: function(p_mi: Plibvlc_media_player_t): Pointer; cdecl;
  libvlc_media_player_play: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_player_pause: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_set_pause: procedure(p_mi: Plibvlc_media_player_t; do_pause: Integer); cdecl;
  libvlc_media_player_stop: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_is_playing: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_player_get_state: function(p_mi: Plibvlc_media_player_t): libvlc_state_t; cdecl;
  libvlc_media_player_get_length: function(p_mi: Plibvlc_media_player_t): Int64; cdecl;
  libvlc_media_player_get_time: function(p_mi: Plibvlc_media_player_t): Int64; cdecl;
  libvlc_media_player_set_time: procedure(p_mi: Plibvlc_media_player_t; i_time: Int64); cdecl;
  libvlc_media_player_get_position: function(p_mi: Plibvlc_media_player_t): Single; cdecl;
  libvlc_media_player_set_position: procedure(p_mi: Plibvlc_media_player_t; f_pos: Single); cdecl;
  libvlc_media_player_get_rate: function(p_mi: Plibvlc_media_player_t): Single; cdecl;
  libvlc_media_player_set_rate: function(p_mi: Plibvlc_media_player_t; rate: Single): Integer; cdecl;
  libvlc_media_player_next_frame: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_get_fps: function(p_mi: Plibvlc_media_player_t): Single; cdecl;
  libvlc_media_get_mrl: function(p_md: Plibvlc_media_t): PAnsiChar; cdecl;
  libvlc_media_player_add_slave: function(p_mi: Plibvlc_media_player_t; i_type: Integer; psz_uri: PAnsiChar; b_select: Boolean): Integer; cdecl;
  libvlc_media_player_get_chapter: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_player_get_chapter_count: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_player_set_chapter: procedure(p_mi: Plibvlc_media_player_t; i_chapter: Integer); cdecl;
  libvlc_media_player_next_chapter: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_previous_chapter: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_get_title: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_player_get_title_count: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_media_player_set_title: procedure(p_mi: Plibvlc_media_player_t; i_title: Integer); cdecl;

  // Video
  libvlc_video_get_size: function(p_mi: Plibvlc_media_player_t; num: Cardinal; px, py: PCardinal): Integer; cdecl;
  libvlc_video_get_aspect_ratio: function(p_mi: Plibvlc_media_player_t): PAnsiChar; cdecl;
  libvlc_video_set_aspect_ratio: procedure(p_mi: Plibvlc_media_player_t; psz_aspect: PAnsiChar); cdecl;
  libvlc_video_get_scale: function(p_mi: Plibvlc_media_player_t): Single; cdecl;
  libvlc_video_set_scale: procedure(p_mi: Plibvlc_media_player_t; f_factor: Single); cdecl;
  libvlc_video_take_snapshot: function(p_mi: Plibvlc_media_player_t; num: Cardinal; psz_filepath: PAnsiChar; i_width, i_height: Cardinal): Integer; cdecl;
  libvlc_video_set_deinterlace: procedure(p_mi: Plibvlc_media_player_t; psz_mode: PAnsiChar); cdecl;
  libvlc_video_get_spu_count: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_video_get_spu_description: function(p_mi: Plibvlc_media_player_t): Plibvlc_track_description_t; cdecl;
  libvlc_video_get_spu: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_video_set_spu: function(p_mi: Plibvlc_media_player_t; i_spu: Integer): Integer; cdecl;
  libvlc_video_set_subtitle_file: function(p_mi: Plibvlc_media_player_t; psz_subtitle: PAnsiChar): Integer; cdecl;
  libvlc_video_get_spu_delay: function(p_mi: Plibvlc_media_player_t): Int64; cdecl;
  libvlc_video_set_spu_delay: function(p_mi: Plibvlc_media_player_t; i_delay: Int64): Integer; cdecl;

  // Video Adjustments (Contrast, Brightness, Hue, Saturation, Gamma)
  libvlc_video_get_adjust_int: function(p_mi: Plibvlc_media_player_t; u_option: Cardinal): Integer; cdecl;
  libvlc_video_set_adjust_int: procedure(p_mi: Plibvlc_media_player_t; u_option: Cardinal; i_value: Integer); cdecl;
  libvlc_video_get_adjust_float: function(p_mi: Plibvlc_media_player_t; u_option: Cardinal): Single; cdecl;
  libvlc_video_set_adjust_float: procedure(p_mi: Plibvlc_media_player_t; u_option: Cardinal; f_value: Single); cdecl;
  libvlc_video_get_crop_geometry: function(p_mi: Plibvlc_media_player_t): PAnsiChar; cdecl;
  libvlc_video_set_crop_geometry: procedure(p_mi: Plibvlc_media_player_t; psz_geometry: PAnsiChar); cdecl;

  // Audio Channels (Stereo, Left, Right, Reverse)
  libvlc_audio_get_channel: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_audio_set_channel: function(p_mi: Plibvlc_media_player_t; channel: Integer): Integer; cdecl;
  libvlc_audio_output_set: function(p_mi: Plibvlc_media_player_t; name: PAnsiChar): Integer; cdecl;

  // Audio
  libvlc_audio_get_volume: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_audio_set_volume: function(p_mi: Plibvlc_media_player_t; i_volume: Integer): Integer; cdecl;
  libvlc_audio_get_mute: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_audio_set_mute: procedure(p_mi: Plibvlc_media_player_t; status: Integer); cdecl;
  libvlc_audio_toggle_mute: procedure(p_mi: Plibvlc_media_player_t); cdecl;
  libvlc_audio_get_track_count: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_audio_get_track_description: function(p_mi: Plibvlc_media_player_t): Plibvlc_track_description_t; cdecl;
  libvlc_audio_get_track: function(p_mi: Plibvlc_media_player_t): Integer; cdecl;
  libvlc_audio_set_track: function(p_mi: Plibvlc_media_player_t; i_track: Integer): Integer; cdecl;
  libvlc_audio_get_delay: function(p_mi: Plibvlc_media_player_t): Int64; cdecl;
  libvlc_audio_set_delay: function(p_mi: Plibvlc_media_player_t; i_delay: Int64): Integer; cdecl;
  libvlc_audio_output_device_enum: function(p_mi: Plibvlc_media_player_t): Plibvlc_audio_output_device_t; cdecl;
  libvlc_audio_output_device_list_release: procedure(p_list: Plibvlc_audio_output_device_t); cdecl;
  libvlc_audio_output_device_set: procedure(p_mi: Plibvlc_media_player_t; psz_audio_output: PAnsiChar; psz_device_id: PAnsiChar); cdecl;

  // Equalizer
  libvlc_audio_equalizer_get_preset_count: function: Cardinal; cdecl;
  libvlc_audio_equalizer_get_preset_name: function(u_index: Cardinal): PAnsiChar; cdecl;
  libvlc_audio_equalizer_new_from_preset: function(u_index: Cardinal): Plibvlc_equalizer_t; cdecl;
  libvlc_audio_equalizer_new: function: Plibvlc_equalizer_t; cdecl;
  libvlc_audio_equalizer_release: procedure(p_equalizer: Plibvlc_equalizer_t); cdecl;
  libvlc_audio_equalizer_get_band_count: function: Cardinal; cdecl;
  libvlc_audio_equalizer_get_band_frequency: function(u_index: Cardinal): Single; cdecl;
  libvlc_audio_equalizer_set_preamp: function(p_equalizer: Plibvlc_equalizer_t; f_preamp: Single): Integer; cdecl;
  libvlc_audio_equalizer_get_preamp: function(p_equalizer: Plibvlc_equalizer_t): Single; cdecl;
  libvlc_audio_equalizer_set_amp_at_index: function(p_equalizer: Plibvlc_equalizer_t; f_amp: Single; u_band: Cardinal): Integer; cdecl;
  libvlc_audio_equalizer_get_amp_at_index: function(p_equalizer: Plibvlc_equalizer_t; u_band: Cardinal): Single; cdecl;
  libvlc_media_player_set_equalizer: function(p_mi: Plibvlc_media_player_t; p_equalizer: Plibvlc_equalizer_t): Integer; cdecl;

  // Track description release
  libvlc_track_description_list_release: procedure(p_td: Plibvlc_track_description_t); cdecl;

  // Renderer Discoverer (Chromecast / DLNA) & Events / Tracks
  libvlc_renderer_discoverer_new: function(p_inst: Plibvlc_instance_t; psz_name: PAnsiChar): Plibvlc_renderer_discoverer_t; cdecl;
  libvlc_renderer_discoverer_release: procedure(p_rd: Plibvlc_renderer_discoverer_t); cdecl;
  libvlc_renderer_discoverer_start: function(p_rd: Plibvlc_renderer_discoverer_t): Integer; cdecl;
  libvlc_renderer_discoverer_stop: procedure(p_rd: Plibvlc_renderer_discoverer_t); cdecl;
  libvlc_renderer_discoverer_event_manager: function(p_rd: Plibvlc_renderer_discoverer_t): Plibvlc_event_manager_t; cdecl;
  libvlc_renderer_item_name: function(p_item: Plibvlc_renderer_item_t): PAnsiChar; cdecl;
  libvlc_renderer_item_type: function(p_item: Plibvlc_renderer_item_t): PAnsiChar; cdecl;
  libvlc_renderer_item_hold: function(p_item: Plibvlc_renderer_item_t): Plibvlc_renderer_item_t; cdecl;
  libvlc_renderer_item_release: procedure(p_item: Plibvlc_renderer_item_t); cdecl;
  libvlc_media_player_set_renderer: function(p_mi: Plibvlc_media_player_t; p_item: Plibvlc_renderer_item_t): Integer; cdecl;
  libvlc_event_attach: function(p_event_manager: Plibvlc_event_manager_t; i_event_type: Integer; f_callback: libvlc_callback_t; p_user_data: Pointer): Integer; cdecl;
  libvlc_event_detach: procedure(p_event_manager: Plibvlc_event_manager_t; i_event_type: Integer; f_callback: libvlc_callback_t; p_user_data: Pointer); cdecl;
  libvlc_media_tracks_get: function(p_md: Plibvlc_media_t; tracks: PPPlibvlc_media_track_t): Cardinal; cdecl;
  libvlc_media_tracks_release: procedure(p_tracks: PPlibvlc_media_track_t; i_count: Cardinal); cdecl;
  libvlc_media_get_codec_description: function(i_type: Integer; i_codec: Cardinal): PAnsiChar; cdecl;

procedure SetLibVLCPluginPath(const Directory: string);
function LoadLibVLC(const ADllPath: string = ''): Boolean;
procedure UnloadLibVLC;
function IsLibVLCLoaded: Boolean;

implementation

var
  hLibVLC: HMODULE = 0;
  hLibVLCCore: HMODULE = 0;

function GetProc(const AProcName: AnsiString): Pointer;
begin
  Result := GetProcAddress(hLibVLC, PAnsiChar(AProcName));
end;

function PutVLCEnvironment(Value: PAnsiChar): Integer; cdecl;
  external 'msvcrt.dll' name '_putenv';

procedure SetLibVLCPluginPath(const Directory: string);
begin
  // LibVLC 3 reads the C runtime environment, which is cached separately.
  PutVLCEnvironment(PAnsiChar(UTF8Encode('VLC_PLUGIN_PATH=' + Directory)));
  SetEnvironmentVariable('VLC_PLUGIN_PATH', PChar(Directory));
end;

function LoadLibVLC(const ADllPath: string): Boolean;
var
  BaseDir, DllFile, CoreFile: string;
begin
  if hLibVLC <> 0 then
  begin
    Result := True;
    Exit;
  end;

  if ADllPath <> '' then
    BaseDir := IncludeTrailingPathDelimiter(ADllPath)
  else
    BaseDir := ExtractFilePath(ParamStr(0));

  DllFile := BaseDir + 'libvlc.dll';
  CoreFile := BaseDir + 'libvlccore.dll';

  if FileExists(CoreFile) then
    hLibVLCCore := LoadLibraryW(PWideChar(CoreFile));

  if FileExists(DllFile) then
    hLibVLC := LoadLibraryW(PWideChar(DllFile))
  else
    hLibVLC := LoadLibraryW('libvlc.dll');

  if hLibVLC = 0 then
  begin
    Result := False;
    Exit;
  end;

  @libvlc_new := GetProc('libvlc_new');
  @libvlc_free := GetProc('libvlc_free');
  @libvlc_media_player_is_seekable := GetProc('libvlc_media_player_is_seekable');
  @libvlc_media_get_stats := GetProc('libvlc_media_get_stats');
  @libvlc_video_set_mouse_input := GetProc('libvlc_video_set_mouse_input');
  @libvlc_video_set_key_input := GetProc('libvlc_video_set_key_input');
  @libvlc_video_set_callbacks := GetProc('libvlc_video_set_callbacks');
  @libvlc_video_set_format_callbacks := GetProc('libvlc_video_set_format_callbacks');
  @libvlc_release := GetProc('libvlc_release');
  @libvlc_get_version := GetProc('libvlc_get_version');
  @libvlc_errmsg := GetProc('libvlc_errmsg');
  @libvlc_clearerr := GetProc('libvlc_clearerr');

  @libvlc_media_new_path := GetProc('libvlc_media_new_path');
  @libvlc_media_new_location := GetProc('libvlc_media_new_location');
  @libvlc_media_release := GetProc('libvlc_media_release');
  @libvlc_media_get_duration := GetProc('libvlc_media_get_duration');
  @libvlc_media_parse := GetProc('libvlc_media_parse');
  @libvlc_media_parse_with_options := GetProc('libvlc_media_parse_with_options');
  @libvlc_media_get_meta := GetProc('libvlc_media_get_meta');
  @libvlc_media_add_option := GetProc('libvlc_media_add_option');
  @libvlc_media_add_option_flag := GetProc('libvlc_media_add_option_flag');

  @libvlc_media_player_new := GetProc('libvlc_media_player_new');
  @libvlc_media_player_new_from_media := GetProc('libvlc_media_player_new_from_media');
  @libvlc_media_player_release := GetProc('libvlc_media_player_release');
  @libvlc_media_player_set_media := GetProc('libvlc_media_player_set_media');
  @libvlc_media_player_get_media := GetProc('libvlc_media_player_get_media');
  @libvlc_media_player_set_hwnd := GetProc('libvlc_media_player_set_hwnd');
  @libvlc_media_player_get_hwnd := GetProc('libvlc_media_player_get_hwnd');
  @libvlc_media_player_play := GetProc('libvlc_media_player_play');
  @libvlc_media_player_pause := GetProc('libvlc_media_player_pause');
  @libvlc_media_player_set_pause := GetProc('libvlc_media_player_set_pause');
  @libvlc_media_player_stop := GetProc('libvlc_media_player_stop');
  @libvlc_media_player_is_playing := GetProc('libvlc_media_player_is_playing');
  @libvlc_media_player_get_state := GetProc('libvlc_media_player_get_state');
  @libvlc_media_player_get_length := GetProc('libvlc_media_player_get_length');
  @libvlc_media_player_get_time := GetProc('libvlc_media_player_get_time');
  @libvlc_media_player_set_time := GetProc('libvlc_media_player_set_time');
  @libvlc_media_player_get_position := GetProc('libvlc_media_player_get_position');
  @libvlc_media_player_set_position := GetProc('libvlc_media_player_set_position');
  @libvlc_media_player_get_rate := GetProc('libvlc_media_player_get_rate');
  @libvlc_media_player_set_rate := GetProc('libvlc_media_player_set_rate');
  @libvlc_media_player_next_frame := GetProc('libvlc_media_player_next_frame');
  @libvlc_media_player_get_fps := GetProc('libvlc_media_player_get_fps');
  @libvlc_media_get_mrl := GetProc('libvlc_media_get_mrl');
  @libvlc_media_player_add_slave := GetProc('libvlc_media_player_add_slave');
  @libvlc_media_player_get_chapter := GetProc('libvlc_media_player_get_chapter');
  @libvlc_media_player_get_chapter_count := GetProc('libvlc_media_player_get_chapter_count');
  @libvlc_media_player_set_chapter := GetProc('libvlc_media_player_set_chapter');
  @libvlc_media_player_next_chapter := GetProc('libvlc_media_player_next_chapter');
  @libvlc_media_player_previous_chapter := GetProc('libvlc_media_player_previous_chapter');
  @libvlc_media_player_get_title := GetProc('libvlc_media_player_get_title');
  @libvlc_media_player_get_title_count := GetProc('libvlc_media_player_get_title_count');
  @libvlc_media_player_set_title := GetProc('libvlc_media_player_set_title');

  @libvlc_video_get_size := GetProc('libvlc_video_get_size');
  @libvlc_video_get_aspect_ratio := GetProc('libvlc_video_get_aspect_ratio');
  @libvlc_video_set_aspect_ratio := GetProc('libvlc_video_set_aspect_ratio');
  @libvlc_video_get_scale := GetProc('libvlc_video_get_scale');
  @libvlc_video_set_scale := GetProc('libvlc_video_set_scale');
  @libvlc_video_take_snapshot := GetProc('libvlc_video_take_snapshot');
  @libvlc_video_set_deinterlace := GetProc('libvlc_video_set_deinterlace');
  @libvlc_video_get_spu_count := GetProc('libvlc_video_get_spu_count');
  @libvlc_video_get_spu_description := GetProc('libvlc_video_get_spu_description');
  @libvlc_video_get_spu := GetProc('libvlc_video_get_spu');
  @libvlc_video_set_spu := GetProc('libvlc_video_set_spu');
  @libvlc_video_set_subtitle_file := GetProc('libvlc_video_set_subtitle_file');
  @libvlc_video_get_spu_delay := GetProc('libvlc_video_get_spu_delay');
  @libvlc_video_set_spu_delay := GetProc('libvlc_video_set_spu_delay');

  @libvlc_video_get_adjust_int := GetProc('libvlc_video_get_adjust_int');
  @libvlc_video_set_adjust_int := GetProc('libvlc_video_set_adjust_int');
  @libvlc_video_get_adjust_float := GetProc('libvlc_video_get_adjust_float');
  @libvlc_video_set_adjust_float := GetProc('libvlc_video_set_adjust_float');
  @libvlc_video_get_crop_geometry := GetProc('libvlc_video_get_crop_geometry');
  @libvlc_video_set_crop_geometry := GetProc('libvlc_video_set_crop_geometry');

  @libvlc_audio_get_channel := GetProc('libvlc_audio_get_channel');
  @libvlc_audio_set_channel := GetProc('libvlc_audio_set_channel');
  @libvlc_audio_output_set := GetProc('libvlc_audio_output_set');

  @libvlc_audio_get_volume := GetProc('libvlc_audio_get_volume');
  @libvlc_audio_set_volume := GetProc('libvlc_audio_set_volume');
  @libvlc_audio_get_mute := GetProc('libvlc_audio_get_mute');
  @libvlc_audio_set_mute := GetProc('libvlc_audio_set_mute');
  @libvlc_audio_toggle_mute := GetProc('libvlc_audio_toggle_mute');
  @libvlc_audio_get_track_count := GetProc('libvlc_audio_get_track_count');
  @libvlc_audio_get_track_description := GetProc('libvlc_audio_get_track_description');
  @libvlc_audio_get_track := GetProc('libvlc_audio_get_track');
  @libvlc_audio_set_track := GetProc('libvlc_audio_set_track');
  @libvlc_audio_get_delay := GetProc('libvlc_audio_get_delay');
  @libvlc_audio_set_delay := GetProc('libvlc_audio_set_delay');
  @libvlc_audio_output_device_enum := GetProc('libvlc_audio_output_device_enum');
  @libvlc_audio_output_device_list_release := GetProc('libvlc_audio_output_device_list_release');
  @libvlc_audio_output_device_set := GetProc('libvlc_audio_output_device_set');

  @libvlc_audio_equalizer_get_preset_count := GetProc('libvlc_audio_equalizer_get_preset_count');
  @libvlc_audio_equalizer_get_preset_name := GetProc('libvlc_audio_equalizer_get_preset_name');
  @libvlc_audio_equalizer_new_from_preset := GetProc('libvlc_audio_equalizer_new_from_preset');
  @libvlc_audio_equalizer_new := GetProc('libvlc_audio_equalizer_new');
  @libvlc_audio_equalizer_release := GetProc('libvlc_audio_equalizer_release');
  @libvlc_audio_equalizer_get_band_count := GetProc('libvlc_audio_equalizer_get_band_count');
  @libvlc_audio_equalizer_get_band_frequency := GetProc('libvlc_audio_equalizer_get_band_frequency');
  @libvlc_audio_equalizer_set_preamp := GetProc('libvlc_audio_equalizer_set_preamp');
  @libvlc_audio_equalizer_get_preamp := GetProc('libvlc_audio_equalizer_get_preamp');
  @libvlc_audio_equalizer_set_amp_at_index := GetProc('libvlc_audio_equalizer_set_amp_at_index');
  @libvlc_audio_equalizer_get_amp_at_index := GetProc('libvlc_audio_equalizer_get_amp_at_index');
  @libvlc_media_player_set_equalizer := GetProc('libvlc_media_player_set_equalizer');

  @libvlc_track_description_list_release := GetProc('libvlc_track_description_list_release');

  @libvlc_renderer_discoverer_new := GetProc('libvlc_renderer_discoverer_new');
  @libvlc_renderer_discoverer_release := GetProc('libvlc_renderer_discoverer_release');
  @libvlc_renderer_discoverer_start := GetProc('libvlc_renderer_discoverer_start');
  @libvlc_renderer_discoverer_stop := GetProc('libvlc_renderer_discoverer_stop');
  @libvlc_renderer_discoverer_event_manager := GetProc('libvlc_renderer_discoverer_event_manager');
  @libvlc_renderer_item_name := GetProc('libvlc_renderer_item_name');
  @libvlc_renderer_item_type := GetProc('libvlc_renderer_item_type');
  @libvlc_renderer_item_hold := GetProc('libvlc_renderer_item_hold');
  @libvlc_renderer_item_release := GetProc('libvlc_renderer_item_release');
  @libvlc_media_player_set_renderer := GetProc('libvlc_media_player_set_renderer');
  @libvlc_event_attach := GetProc('libvlc_event_attach');
  @libvlc_event_detach := GetProc('libvlc_event_detach');
  @libvlc_media_tracks_get := GetProc('libvlc_media_tracks_get');
  @libvlc_media_tracks_release := GetProc('libvlc_media_tracks_release');
  @libvlc_media_get_codec_description := GetProc('libvlc_media_get_codec_description');

  Result := Assigned(libvlc_new) and Assigned(libvlc_media_player_new);
end;

procedure UnloadLibVLC;
begin
  // Call only after all players, preview decoders and instances are released.
  if hLibVLC<>0 then begin FreeLibrary(hLibVLC); hLibVLC:=0; end;
  if hLibVLCCore<>0 then begin FreeLibrary(hLibVLCCore); hLibVLCCore:=0; end;
end;

function IsLibVLCLoaded: Boolean;
begin
  Result := (hLibVLC <> 0) and Assigned(libvlc_new);
end;

initialization

finalization
  UnloadLibVLC;

end.
