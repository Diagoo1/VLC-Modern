unit MainForm;

interface

uses SettingsStore,
  Winapi.Windows, Winapi.Messages, Winapi.UxTheme, System.SysUtils, System.Classes, System.Types, System.Math,
  System.UITypes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Themes, Vcl.FileCtrl,
  Winapi.ShellAPI, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ, LibVLC, Lut3D, D3D11ShaderRenderer, CurvedControls, TaskbarManager, SeekPreview, PlayerSettings, PlayerFlyout, AudioMeter, MediaImport, OpenSubtitlesDownloader, PlaybackResumeStore, WebRemoteServer, YtDlpResolver;

const
  WM_USER_VIDEO_RIGHTCLICK = WM_USER + 101;
  WM_USER_VIDEO_LEFTCLICK  = WM_USER + 102;
  WM_USER_VIDEO_DBLCLICK   = WM_USER + 103;
  WM_USER_VIDEO_WHEEL      = WM_USER + 104;
  WM_USER_VIDEO_MOUSEMOVE  = WM_USER + 105;

type
  TLoopMode = (lmOff, lmLoopAll, lmLoopOne);
  TShaderFilter = (sfInvert, sfSharpen, sfEdgeDetect, sfFilmGrain, sfDenoise, sfSepia, sfPosterize, sfAnaglyph);

  TFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    mnuMedia: TMenuItem;
    mnuOpenFile: TMenuItem;
    mnuOpenMultiple: TMenuItem;
    mnuOpenFolder: TMenuItem;
    mnuOpenDisc: TMenuItem;
    mnuOpenURL: TMenuItem;
    mnuOpenCapture: TMenuItem;
    mnuScreenCapture: TMenuItem;
    mnuOpenClipboard: TMenuItem;
    mnuRecentMedia: TMenuItem;
    mnuSep1: TMenuItem;
    mnuSavePlaylist: TMenuItem;
    mnuConvert: TMenuItem;
    mnuStream: TMenuItem;
    mnuSepMedia2: TMenuItem;
    mnuQuitAtEnd: TMenuItem;
    mnuQuit: TMenuItem;
    mnuPlayback: TMenuItem;
    mnuTitle: TMenuItem;
    mnuChapters: TMenuItem;
    mnuProgram: TMenuItem;
    mnuBookmarks: TMenuItem;
    mnuSleepTimer: TMenuItem;
    mnuSleepOff: TMenuItem;
    mnuSleep15: TMenuItem;
    mnuSleep30: TMenuItem;
    mnuSleep60: TMenuItem;
    mnuSleep90: TMenuItem;
    mnuRenderer: TMenuItem;
    mnuSpeed: TMenuItem;
    mnuSpeed025: TMenuItem;
    mnuSpeed05: TMenuItem;
    mnuSpeed075: TMenuItem;
    mnuSpeed10: TMenuItem;
    mnuSpeed125: TMenuItem;
    mnuSpeed15: TMenuItem;
    mnuSpeed20: TMenuItem;
    mnuSpeed30: TMenuItem;
    mnuSpeed40: TMenuItem;
    mnuSep2: TMenuItem;
    mnuJumpFwd: TMenuItem;
    mnuJumpBack: TMenuItem;
    mnuJumpTime: TMenuItem;
    mnuSkipOpening: TMenuItem;
    mnuSkipEnding: TMenuItem;
    mnuSepPlay2: TMenuItem;
    mnuPlayPause: TMenuItem;
    mnuStop: TMenuItem;
    mnuPrevious: TMenuItem;
    mnuNext: TMenuItem;
    mnuRecord: TMenuItem;
    mnuAudio: TMenuItem;
    mnuAudioTrack: TMenuItem;
    mnuAudioDevice: TMenuItem;
    mnuCycleAudioDevice: TMenuItem;
    mnuAudioChannel: TMenuItem;
    mnuEQPresets: TMenuItem;
    mnuChannelStereo: TMenuItem;
    mnuChannelRStereo: TMenuItem;
    mnuChannelLeft: TMenuItem;
    mnuChannelRight: TMenuItem;
    mnuChannelDolby: TMenuItem;
    mnuVolUp: TMenuItem;
    mnuVolDown: TMenuItem;
    mnuMute: TMenuItem;
    mnuAudioDelayPlus: TMenuItem;
    mnuAudioDelayMinus: TMenuItem;
    mnuSepAudioFilters: TMenuItem;
    mnuVoiceClarifier: TMenuItem;
    mnuNightMode: TMenuItem;
    mnuHeadphoneSurround: TMenuItem;
    mnuKaraokeMode: TMenuItem;
    mnuAudioPassthrough: TMenuItem;
    mnuAudioRecord: TMenuItem;
    mnuSep3: TMenuItem;
    mnuAudioEqualizer: TMenuItem;
    mnuVideo: TMenuItem;
    mnuFullscreen: TMenuItem;
    mnuAlwaysOnTop: TMenuItem;
    mnuSep4: TMenuItem;
    mnuAspect: TMenuItem;
    mnuAspectDef: TMenuItem;
    mnuAspect169: TMenuItem;
    mnuAspect43: TMenuItem;
    mnuAspect1610: TMenuItem;
    mnuAspect11: TMenuItem;
    mnuAspect235: TMenuItem;
    mnuCrop: TMenuItem;
    mnuCropDef: TMenuItem;
    mnuCrop169: TMenuItem;
    mnuCrop43: TMenuItem;
    mnuCrop1610: TMenuItem;
    mnuCrop11: TMenuItem;
    mnuDeinterlace: TMenuItem;
    mnuDeinterlaceAuto: TMenuItem;
    mnuDeinterlaceOn: TMenuItem;
    mnuDeinterlaceOff: TMenuItem;
    mnuSep5: TMenuItem;
    mnuSnapshot: TMenuItem;
    mnuCleanSnapshot: TMenuItem;
    mnuThumbnailSheet: TMenuItem;
    mnuAnimatedGif: TMenuItem;
    mnuRecordVideoMP4: TMenuItem;
    mnuVideoPresets: TMenuItem;
    mnuProfileDefault: TMenuItem;
    mnuProfileCinema: TMenuItem;
    mnuProfileAnime: TMenuItem;
    mnuProfileEyeComfort: TMenuItem;
    mnuProfileNoir: TMenuItem;
    mnuProfileSports: TMenuItem;
    mnuShaders: TMenuItem;
    mnuShaderInvert: TMenuItem;
    mnuShaderSharpen: TMenuItem;
    mnuShaderDenoise: TMenuItem;
    mnuShaderFilmGrain: TMenuItem;
    mnuShaderEdgeDetect: TMenuItem;
    mnuShaderSepia: TMenuItem;
    mnuShaderPosterize: TMenuItem;
    mnuShaderAnaglyph: TMenuItem;
    mnuSepShader: TMenuItem;
    mnuShaderReset: TMenuItem;
    mnuPanScan: TMenuItem;
    mnuPanReset: TMenuItem;
    mnuPanZoomIn: TMenuItem;
    mnuPanZoomOut: TMenuItem;
    mnuPanLeft: TMenuItem;
    mnuPanRight: TMenuItem;
    mnuPanUp: TMenuItem;
    mnuPanDown: TMenuItem;
    mnuPanScale169: TMenuItem;
    mnuPanScale43: TMenuItem;
    mnuLoad3DLUT: TMenuItem;
    mnuGPUShaders: TMenuItem;
    mnuGPUAnime4K: TMenuItem;
    mnuGPUCAS: TMenuItem;
    mnuGPUDeband: TMenuItem;
    mnuGPUACES: TMenuItem;
    mnuGPUCRT: TMenuItem;
    mnuGPULevels: TMenuItem;
    mnuGPUBT601: TMenuItem;
    mnuSepGPULoad: TMenuItem;
    mnuGPULoadHLSL: TMenuItem;
    mnuGPUDisable: TMenuItem;
    mnu3DMode: TMenuItem;
    mnu3DNormal: TMenuItem;
    mnu3DSBS: TMenuItem;
    mnu3DTAB: TMenuItem;
    mnuScaling: TMenuItem;
    mnuScaleSpline36: TMenuItem;
    mnuScaleLanczos: TMenuItem;
    mnuScaleBicubic: TMenuItem;
    mnuScaleBilinear: TMenuItem;
    mnuSubtitle: TMenuItem;
    mnuAddSub: TMenuItem;
    mnuAddSecondarySub: TMenuItem;
    mnuSubTrack: TMenuItem;
    mnuSubDelayPlus: TMenuItem;
    mnuSubDelayMinus: TMenuItem;
    mnuSubSizePlus: TMenuItem;
    mnuSubSizeMinus: TMenuItem;
    mnuSubMoveUp: TMenuItem;
    mnuSubMoveDown: TMenuItem;
    mnuDownloadOnlineSub: TMenuItem;
    mnuTranslateSub: TMenuItem;
    mnuTools: TMenuItem;
    mnuEffects: TMenuItem;
    mnuTrackSync: TMenuItem;
    mnuMediaInfo: TMenuItem;
    mnuCodecInfo: TMenuItem;
    mnuVLM: TMenuItem;
    mnuProgramGuide: TMenuItem;
    mnuMessages: TMenuItem;
    mnuPlugins: TMenuItem;
    mnuThemes: TMenuItem;
    mnuWebRemote: TMenuItem;
    mnuSepTools: TMenuItem;
    mnuCustomizeInterface: TMenuItem;
    mnuPreferences: TMenuItem;
    mnuView: TMenuItem;
    mnuViewPlaylist: TMenuItem;
    mnuDockedPlaylist: TMenuItem;
    mnuSepView1: TMenuItem;
    mnuViewAlwaysOnTop: TMenuItem;
    mnuMinimal: TMenuItem;
    mnuViewFullscreen: TMenuItem;
    mnuAdvancedControls: TMenuItem;
    mnuStatusBar: TMenuItem;
    mnuBorderless: TMenuItem;
    mnuStatsHUD: TMenuItem;
    mnuSepView2: TMenuItem;
    mnuAddInterface: TMenuItem;
    mnuVLSub: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHotkeys: TMenuItem;
    mnuAbout: TMenuItem;

    PopupMenuVideo: TPopupMenu;
    popPlayPause: TMenuItem;
    popStop: TMenuItem;
    popNext: TMenuItem;
    popPrevious: TMenuItem;
    popJumpFwd: TMenuItem;
    popJumpBack: TMenuItem;
    popJumpTime: TMenuItem;
    popABRepeat: TMenuItem;
    popNextFrame: TMenuItem;
    popSep1: TMenuItem;
    popVideo: TMenuItem;
    popFullscreen: TMenuItem;
    popAlwaysOnTop: TMenuItem;
    popAspect: TMenuItem;
    popAspectDef: TMenuItem;
    popAspect169: TMenuItem;
    popAspect43: TMenuItem;
    popAspect1610: TMenuItem;
    popAspect11: TMenuItem;
    popAspect235: TMenuItem;
    popCrop: TMenuItem;
    popCropDef: TMenuItem;
    popCrop169: TMenuItem;
    popCrop43: TMenuItem;
    popCrop1610: TMenuItem;
    popCrop11: TMenuItem;
    popDeinterlace: TMenuItem;
    popDeinterlaceAuto: TMenuItem;
    popDeinterlaceOn: TMenuItem;
    popDeinterlaceOff: TMenuItem;
    popSnapshot: TMenuItem;
    popAudio: TMenuItem;
    popAudioTrack: TMenuItem;
    popAudioChannel: TMenuItem;
    popChanStereo: TMenuItem;
    popChanRStereo: TMenuItem;
    popChanLeft: TMenuItem;
    popChanRight: TMenuItem;
    popChanDolby: TMenuItem;
    popVolUp: TMenuItem;
    popVolDown: TMenuItem;
    popMute: TMenuItem;
    popAudioDelayPlus: TMenuItem;
    popAudioDelayMinus: TMenuItem;
    popSepAudioFilters: TMenuItem;
    popVoiceClarifier: TMenuItem;
    popNightMode: TMenuItem;
    popHeadphoneSurround: TMenuItem;
    popKaraokeMode: TMenuItem;
    popAudioPassthrough: TMenuItem;
    popEQPresets: TMenuItem;
    popEffects: TMenuItem;
    popSubtitle: TMenuItem;
    popAddSub: TMenuItem;
    popAddSecondarySub: TMenuItem;
    popSubTrack: TMenuItem;
    popSubDelayPlus: TMenuItem;
    popSubDelayMinus: TMenuItem;
    popSpeed: TMenuItem;
    popSpeed025: TMenuItem;
    popSpeed05: TMenuItem;
    popSpeed075: TMenuItem;
    popSpeed10: TMenuItem;
    popSpeed125: TMenuItem;
    popSpeed15: TMenuItem;
    popSpeed20: TMenuItem;
    popSpeed30: TMenuItem;
    popSpeed40: TMenuItem;
    popSep2: TMenuItem;
    popMediaInfo: TMenuItem;
    popPlaylist: TMenuItem;
    popOpenFile: TMenuItem;
    popOpenURL: TMenuItem;
    popSep3: TMenuItem;
    popThemes: TMenuItem;
    popBookmarks: TMenuItem;
    popStatsHUD: TMenuItem;
    popPreferences: TMenuItem;
    popExit: TMenuItem;

    pnlRoot: TPanel;
    pnlVideoContainer: TPanel;
    pnlVideo: TPanel;
    lblOSD: TLabel;
    lblStatsHUD: TLabel;

    pnlPlaylist: TPanel;
    pnlPlaylistHeader: TPanel;
    lblPlaylistTitle: TLabel;
    btnHidePlaylist: TButton;
    lstPlaylist: TListBox;
    pnlPlaylistBottom: TPanel;

    pnlBottom: TPanel;
    pnlProgressRow: TPanel;
    tbProgress: TTrackBar;
    lblTime: TLabel;

    pnlControlsRow: TPanel;
    pnlTransport: TPanel;
    pnlVolume: TPanel;
    tbVolume: TTrackBar;
    lblVolPct: TLabel;
    pnlRightControls: TPanel;
    cboAspect: TComboBox;
    cboSpeed: TComboBox;

    tmrUpdate: TTimer;
    tmrOSD: TTimer;
    OpenDialog1: TOpenDialog;
    OpenDialogSub: TOpenDialog;
    SaveDialogPlaylist: TSaveDialog;
    OpenDialogPlaylist: TOpenDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure mnuOpenFileClick(Sender: TObject);
    procedure mnuOpenMultipleClick(Sender: TObject);
    procedure mnuOpenFolderClick(Sender: TObject);
    procedure mnuOpenDiscClick(Sender: TObject);
    procedure mnuOpenURLClick(Sender: TObject);
    procedure mnuIPTVClick(Sender: TObject);
    procedure mnuOpenCaptureClick(Sender: TObject);
    procedure mnuOpenClipboardClick(Sender: TObject);
    procedure mnuConvertClick(Sender: TObject);
    procedure mnuStreamClick(Sender: TObject);
    procedure mnuBookmarksClick(Sender: TObject);
    procedure mnuPreferencesClick(Sender: TObject);
    procedure OnBookmarkJump(ATimeMs: Int64);
    procedure mnuSavePlaylistClick(Sender: TObject);
    procedure mnuLoadPlaylistClick(Sender: TObject);
    procedure mnuQuitAtEndClick(Sender: TObject);
    procedure mnuRecordClick(Sender: TObject);
    procedure mnuTrackSyncClick(Sender: TObject);
    procedure mnuCodecInfoClick(Sender: TObject);
    procedure mnuMessagesClick(Sender: TObject);
    procedure mnuCustomizeInterfaceClick(Sender: TObject);
    procedure mnuProgramGuideClick(Sender: TObject);
    procedure mnuPluginsClick(Sender: TObject);
    procedure mnuThemesClick(Sender: TObject);
    procedure mnuAdvancedControlsClick(Sender: TObject);
    procedure mnuStatusBarClick(Sender: TObject);
    procedure mnuAddInterfaceClick(Sender: TObject);
    procedure mnuVLSubClick(Sender: TObject);
    procedure mnuDockedPlaylistClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);

    procedure mnuPlayPauseClick(Sender: TObject);
    procedure mnuStopClick(Sender: TObject);
    procedure mnuPreviousClick(Sender: TObject);
    procedure mnuNextClick(Sender: TObject);
    procedure mnuJumpFwdClick(Sender: TObject);
    procedure mnuJumpBackClick(Sender: TObject);
    procedure mnuJumpTimeClick(Sender: TObject);
    procedure mnuABRepeatClick(Sender: TObject);
    procedure mnuNextFrameClick(Sender: TObject);
    procedure mnuPrevFrameClick(Sender: TObject);
    procedure mnuSpeedItemClick(Sender: TObject);

    procedure mnuAudioClick(Sender: TObject);
    procedure mnuAudioChannelClick(Sender: TObject);
    procedure mnuSubtitleClick(Sender: TObject);
    procedure mnuAddSecondarySubClick(Sender: TObject);
    procedure mnuPlaybackClick(Sender: TObject);
    procedure mnuVolUpClick(Sender: TObject);
    procedure mnuVolDownClick(Sender: TObject);
    procedure mnuMuteClick(Sender: TObject);
    procedure mnuAudioDelayPlusClick(Sender: TObject);
    procedure mnuAudioDelayMinusClick(Sender: TObject);

    procedure mnuFullscreenClick(Sender: TObject);
    procedure mnuAlwaysOnTopClick(Sender: TObject);
    procedure mnuAspectItemClick(Sender: TObject);
    procedure mnuCropClick(Sender: TObject);
    procedure mnuDeinterlaceClick(Sender: TObject);
    procedure mnuSnapshotClick(Sender: TObject);
    procedure mnuCleanSnapshotClick(Sender: TObject);
    procedure mnuThumbnailSheetClick(Sender: TObject);
    procedure mnuSkipOpeningClick(Sender: TObject);
    procedure mnuSkipEndingClick(Sender: TObject);
    procedure OpenScreenCapture;
    procedure GenerateAnimatedGif;
    procedure RecordAudioStream;
    procedure mnuScreenCaptureClick(Sender: TObject);
    procedure mnuAudioRecordClick(Sender: TObject);
    procedure mnuAnimatedGifClick(Sender: TObject);
    procedure mnuRecordVideoMP4Click(Sender: TObject);
    procedure mnuWebRemoteClick(Sender: TObject);
    procedure ToggleVoiceClarifier;
    procedure ToggleNightMode;
    procedure ToggleHeadphoneSurround;
    procedure ToggleKaraokeMode;
    procedure ToggleAudioPassthrough;
    procedure ApplyVideoProfile(AProfile: Integer);
    procedure CycleVideoProfile;
    procedure ApplyBufferPreset(APreset: Integer);
    procedure CycleBufferPreset;
    procedure ApplyLayoutPreset(APreset: Integer);
    procedure ToggleShader(AShader: TShaderFilter);
    procedure ResetAllShaders;
    procedure mnuProfileItemClick(Sender: TObject);
    procedure mnuShaderItemClick(Sender: TObject);
    procedure mnuResetShadersClick(Sender: TObject);
    procedure mnuVoiceClarifierClick(Sender: TObject);
    procedure mnuNightModeClick(Sender: TObject);
    procedure mnuHeadphoneSurroundClick(Sender: TObject);
    procedure mnuKaraokeModeClick(Sender: TObject);
    procedure mnuAudioPassthroughClick(Sender: TObject);
    procedure mnuPanScanItemClick(Sender: TObject);
    procedure mnuWindowSizeItemClick(Sender: TObject);
    procedure mnuBorderlessClick(Sender: TObject);
    procedure mnuStatsHUDClick(Sender: TObject);
    procedure mnuBossKeyClick(Sender: TObject);
    procedure mnuAfterPlaybackItemClick(Sender: TObject);
    procedure OnChapterItemClick(Sender: TObject);
    procedure OnAudioDeviceSelect(Sender: TObject);

    procedure mnuAddSubClick(Sender: TObject);
    procedure mnuSubDelayPlusClick(Sender: TObject);
    procedure mnuSubDelayMinusClick(Sender: TObject);
    procedure mnuDownloadOnlineSubClick(Sender: TObject);
    procedure mnuTranslateSubClick(Sender: TObject);

    procedure mnuMediaInfoClick(Sender: TObject);
    procedure mnuEffectsClick(Sender: TObject);
    procedure mnuViewPlaylistClick(Sender: TObject);
    procedure mnuMinimalClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuHotkeysClick(Sender: TObject);
    procedure mnuLoad3DLUTClick(Sender: TObject);
    procedure mnuGPUShaderItemClick(Sender: TObject);
    procedure mnuGPULoadHLSLClick(Sender: TObject);
    procedure mnuGPUDisableClick(Sender: TObject);
    procedure mnu3DModeItemClick(Sender: TObject);
    procedure mnuSleepTimerItemClick(Sender: TObject);
    procedure mnuCycleAudioDeviceClick(Sender: TObject);
    procedure mnuSubSizePlusClick(Sender: TObject);
    procedure mnuSubSizeMinusClick(Sender: TObject);
    procedure mnuSubMoveUpClick(Sender: TObject);
    procedure mnuSubMoveDownClick(Sender: TObject);
    procedure mnuScalingItemClick(Sender: TObject);
    procedure mnuRendererClick(Sender: TObject);
    procedure OnRendererSelect(Sender: TObject);
    procedure OnScanRenderersClick(Sender: TObject);
    procedure UpdateRendererMenu(AMenu: TMenuItem);
    procedure StopAudioRecording;
    procedure ReleaseRenderers;
    procedure LoadCustomHotkeys;
    function TryHandleCustomHotkey(Key: Word; Shift: TShiftState): Boolean;

    procedure pnlVideoDblClick(Sender: TObject);
    procedure pnlVideoClick(Sender: TObject);
    procedure pnlVideoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlVideoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlVideoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    procedure tbProgressChange(Sender: TObject);
    procedure tbVolumeChange(Sender: TObject);

    procedure cboAspectChange(Sender: TObject);
    procedure cboSpeedChange(Sender: TObject);

    procedure lstPlaylistDblClick(Sender: TObject);
    procedure btnAddMediaClick(Sender: TObject);
    procedure btnRemoveMediaClick(Sender: TObject);
    procedure btnClearPlaylistClick(Sender: TObject);
    procedure btnLoopModeClick(Sender: TObject);
    procedure btnShuffleClick(Sender: TObject);

    procedure tmrUpdateTimer(Sender: TObject);
    procedure tmrOSDTimer(Sender: TObject);
    procedure PopupMenuVideoPopup(Sender: TObject);
    procedure lstPlaylistDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);

  private
    FVlcInstance: Plibvlc_instance_t;
    FEngineOptionsKey: string;
    FMediaPlayer: Plibvlc_media_player_t;
    FCurrentMedia: Plibvlc_media_t;
    FCurrentFile: string;
    FPrimarySubtitlePath: string;
    FGeneratedSubtitles: TStringList;
    FLoadingCombinedSubtitles: Boolean;
    FPlaylistPaths: TStringList;
    FPlatformCacheFiles: TStringList;
    FPlatformRequest: Cardinal;
    FPlaylistOptions: TObjectDictionary<string, TStringList>;
    FCurrentPlaylistIndex: Integer;
    FUpdatingTrackBar: Boolean;
    FIsFullscreen: Boolean;
    FLoopMode: TLoopMode;
    FOldWindowState: TWindowState;
    FOldBounds: TRect;
    FMinimalMode: Boolean;
    FATime: Int64;
    FBTime: Int64;
    FShownOnce: Boolean;
    FUIReady: Boolean;
    FClosing: Boolean;
    FQuitAtEnd: Boolean;
    FPendingResume: Int64;
    FPendingVolume: Integer;
    FPendingSeek: Int64;
    FSeekRequestedAt, FSeekSentAt: UInt64;
    FPlaybackStarted, FPlaybackFailed: Boolean;
    FOpeningSkipped, FEndingSkipped: Boolean;
    FWasPlaylistVisible: Boolean;
    FWasBottomVisible: Boolean;
    FPlaylistTimer: TTimer;
    FPlaylistAnimating, FPlaylistTarget: Boolean;
    FPlaylistStartWidth: Integer;
    FPlaylistStartTick: UInt64;
    FPanScanZoom: Single;
    FPanScanX: Integer;
    FPanScanY: Integer;
    FAfterPlayback: Integer;
    FIsBossHidden: Boolean;
    FIsBorderless: Boolean;
    FPreBossMuted: Boolean;
    FPreBossPlaying: Boolean;
    FPreBossWindowState: TWindowState;
    FMuted: Boolean;
    FVideoDownPt: TPoint;
    FVideoDragging: Boolean;

    // DriverPack-Modern Vector Controls
    modernTitleBar: TModernTitleBar;
    btnTitleMin: TModernVectorButton;
    btnTitleMax: TModernVectorButton;
    btnTitleClose: TModernVectorButton;

    cardBottomDock: TModernCardPanel;
    modernSeekBar: TModernSeekBar;
    modernVolumeSlider: TModernVolumeSlider;
    lblTimeDisplay: TLabel;
    lblVolPctDisplay: TLabel;

    btnPlay: TModernVectorButton;
    btnPrev: TModernVectorButton;
    btnNext: TModernVectorButton;
    btnStop: TModernVectorButton;
    btnJumpBack: TModernVectorButton;
    btnJumpFwd: TModernVectorButton;
    btnMute: TModernVectorButton;
    btnSpeed: TModernVectorButton;
    btnEqualizer: TModernVectorButton;
    btnPlaylistToggle: TModernVectorButton;
    btnFullscreen: TModernVectorButton;

    FPreviewWindow, FDockWindow: TPlayerFlyout;
    cardSeekPreview: TModernCardPanel;
    imgSeekPreview: TImage;
    lblSeekPreviewTime: TLabel;
    FSeekDecoder: TSeekPreview;
    FLastPlayPauseTick: UInt64;
    tmrFullscreenHide: TTimer;
    FFullscreenMouseTimer: TTimer;
    FShowRemainingTime: Boolean;
    FImports: TQueue<IMediaImport>;
    FManualSubtitles: TStringList;
    FSplashBitmap: TGPBitmap;

    // Real Audio Stream Recorder & DLNA/Chromecast Renderer Discovery
    FAudioRecorderPlayer: Plibvlc_media_player_t;
    FAudioRecordPath: string;
    FAudioRecording: Boolean;
    FRendererDiscoverer: Plibvlc_renderer_discoverer_t;
    FRendererItems: TList<Plibvlc_renderer_item_t>;
    FRendererNames: TStringList;
    FActiveRendererIndex: Integer;
    FCustomHotkeys: TDictionary<string, TShortCut>;
    FVideoRecorderPlayer: Plibvlc_media_player_t;
    FVideoRecorderInstance: Plibvlc_instance_t;
    FVideoExportTimer: TTimer;
    FVideoExporting: Boolean;
    FClipExportProcess: THandle;
    FLocalRecordingFile: string;
    FLocalRecordingStart: Int64;
    FVideoRecordPath: string;
    FVideoRecording: Boolean;
    FWebRemote: TWebRemoteServer;
    FGPUShader: TD3D11ShaderRenderer;
    FGPUShaderActive: Boolean;
    FSleepExpireTick: UInt64;
    F3DStereoMode: Integer;

    // Taskbar Thumbnail Toolbar
    FTaskbarMgr: TTaskbarManager;
    FWMTaskbarCreated: UINT;

    // Audio Mode UI Controls
    cardAudioMode: TModernCardPanel;
    cardAlbumArt: TModernCardPanel;
    imgAlbumArt: TImage;
    lblAudioTitle: TLabel;
    lblAudioArtist: TLabel;
    lblAudioAlbum: TLabel;
    pbVisualizer: TPaintBox;
    FIsAudioOnly: Boolean;
    FAudioMeter: TProcessAudioMeter;
    FVisualTimer: TTimer;
    FVisualLevels: array[0..21] of Single;
    FSignalLevel: Single;
    FOldVideoWidth: Integer;
    FOldVideoHeight: Integer;

    // Modern Top Menu Bar Controls
    pnlMenuBar: TPanel;
    btnMenuMedia: TModernVectorButton;
    btnMenuPlayback: TModernVectorButton;
    btnMenuAudio: TModernVectorButton;
    btnMenuVideo: TModernVectorButton;
    btnMenuSubtitle: TModernVectorButton;
    btnMenuTools: TModernVectorButton;
    btnMenuView: TModernVectorButton;
    btnMenuHelp: TModernVectorButton;
    btnMenuIPTV: TModernVectorButton;

    // Modern Playlist Card Controls
    cardPlaylist: TModernCardPanel;
    lblPlaylistHeading: TLabel;
    btnClosePlaylist: TModernVectorButton;
    btnAddMedia: TModernVectorButton;
    btnRemoveMedia: TModernVectorButton;
    btnClearPlaylist: TModernVectorButton;
    btnRepeat: TModernVectorButton;
    btnShuffle: TModernVectorButton;

    FTopPopups: array[0..7] of TPopupMenu;
    FSettings: TPlayerSettings;
    FLastFullscreenMouse: TPoint;
    FHasFullscreenMouse: Boolean;
    FAudioPreferencesApplied: Boolean;
    FVideoPreferencesApplied: Boolean;
    FClickActionTick: UInt64;
    FClickActionApplied: Boolean;
    tmrClickPause: TTimer;
    FOldVideoWndProc: TWndMethod;
    FOldContainerWndProc: TWndMethod;
    FOldPlaylistWndProc: TWndMethod;
    FOldRootWndProc: TWndMethod;
    FSuppressTransientOSD: Boolean;
    FPreferencesWarmup:TTimer;
    FPreferencesOpenStarted: Int64;
    FPreferencesOpenProbe: TTimer;
    FPreferencesDirty:Boolean;
    FPreferencesStamp:string;
    FSeekGestureActive: Boolean;
    FSeekGestureStart: Int64;
    FClickWasPlaying, FClickWasFullscreen: Boolean;
    procedure ProcessMediaImports;
    procedure PlaylistTick(Sender: TObject);
    procedure SetPlaylistVisible(Visible, Animate: Boolean);
    procedure OnClickPauseTimer(Sender: TObject);
    procedure ExecuteVideoDoubleAction(Sender: TObject);
    procedure VisualizerTick(Sender: TObject);
    procedure CopySnapshotToClipboard;

    procedure WMUserVideoRightClick(var Msg: TMessage); message WM_USER_VIDEO_RIGHTCLICK;
    procedure WMUserVideoLeftClick(var Msg: TMessage); message WM_USER_VIDEO_LEFTCLICK;
    procedure WMUserVideoDblClick(var Msg: TMessage); message WM_USER_VIDEO_DBLCLICK;
    procedure WMUserVideoWheel(var Msg: TMessage); message WM_USER_VIDEO_WHEEL;
    procedure WMUserVideoDrag(var Msg: TMessage); message WM_USER + 106;
    procedure WMUserVideoMouseMove(var Msg: TMessage); message WM_USER_VIDEO_MOUSEMOVE;

    procedure OnFullscreenHideTimer(Sender: TObject);
    procedure WatchFullscreenMouse(Sender: TObject);
    procedure TriggerFullscreenControls;
    procedure OnTimeDisplayClick(Sender: TObject);
    procedure LoadSplashScreen;
    procedure PaintVideoSplashScreen(DC: HDC; const ClientRect: TRect);
    procedure VideoDropWndProc(var Msg: TMessage);
    procedure ContainerDropWndProc(var Msg: TMessage);
    procedure PlaylistDropWndProc(var Msg: TMessage);
    procedure RootDropWndProc(var Msg: TMessage);

    procedure OnTopMenuItemClick(Sender: TObject);
    procedure OnTopMenuItemMouseEnter(Sender: TObject);
    procedure BuildContextMenu;
    procedure InitModernPlayerUI;
    procedure OnLiveTVMenu(Sender: TObject);
    procedure OnLiveTVSource(Sender: TObject);
    procedure RepositionModernControls;
    procedure OnModernSeek(Sender: TObject; NewPosition: Single);
    procedure OnSeekBarHover(Sender: TObject; Pos: Single; ScreenPt: TPoint);
    procedure OnSeekBarLeave(Sender: TObject);
    procedure OnModernVolumeChange(Sender: TObject; NewVolume: Integer);
    procedure OnModernPlayClick(Sender: TObject);
    procedure mnuOpenVltSkinClick(Sender: TObject);
    procedure OnModernMuteClick(Sender: TObject);
    procedure OnModernSpeedClick(Sender: TObject);
    procedure OnModernPlaylistToggle(Sender: TObject);
    procedure OnModernRepeatClick(Sender: TObject);
    procedure OnTitleMinClick(Sender: TObject);
    procedure OnTitleMaxClick(Sender: TObject);
    procedure OnTitleCloseClick(Sender: TObject);
    procedure AdjustVolume(Delta: Integer);

    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure OnDockMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure PlayerActivated(Sender: TObject);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure UpdateAudioTracksMenu(AMenu: TMenuItem);
    procedure UpdateAudioDevicesMenu(AMenu: TMenuItem);
    procedure UpdateSubtitleTracksMenu(AMenu: TMenuItem);
    procedure UpdateChaptersMenu;
    procedure UpdateTitlesMenu;
    procedure OnTitleItemClick(Sender: TObject);
    procedure InitEQPresetsMenu;
    procedure OnEQPresetItemClick(Sender: TObject);
    procedure UpdatePanScan;
    procedure ToggleBossKey;
    procedure OnAudioTrackSelect(Sender: TObject);
    procedure OnSubtitleTrackSelect(Sender: TObject);
    procedure OnThemeSelect(Sender: TObject);
    procedure PopulateThemesMenu(AMenu: TMenuItem);
    procedure ApplyAspectRatio(const ARatio: string);
    procedure PlayMediaAtIndex(AIndex: Integer; AOptions: TStrings = nil);
    procedure SavePlaybackPosition;
    function FormatTime(AMilliseconds: Int64): string;
    procedure AddRecentMedia(const APath: string);
    procedure UpdateRecentMediaMenu;
    procedure OnRecentMediaItemClick(Sender: TObject);
    procedure OnClearRecentMediaClick(Sender: TObject);
    procedure AdjustSpeed(Delta: Single);
    procedure SetABPointA;
    procedure SetABPointB;
    procedure ClearABLoop;

    procedure InitAudioModeUI;
    procedure SwitchToAudioMode(const AFilePath: string);
    procedure SwitchToVideoMode;
    procedure RenderVectorMusicArt;
    procedure OnVisualizerPaint(Sender: TObject);
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;

  public
    property Settings: TPlayerSettings read FSettings;
    procedure NextChapter;
    procedure PreviousChapter;
    procedure EnsureVideoAdjustEnabled;
    procedure CycleAudioTrack;
    procedure CycleAudioChannel;
    procedure CycleSubtitleTrack;
    procedure CycleAspectRatio;
    procedure CycleVideoRotation;
    procedure ToggleVideoFlipHorizontal;
    procedure ToggleDeinterlace;
    procedure ToggleSkipOpening;
    procedure ToggleSkipEnding;
    procedure GenerateThumbnailSheet;
    procedure TakeCleanSnapshot;
    procedure DownloadSubtitlesOnline;
    procedure TranslateCurrentSubtitle;
    procedure SavePlaybackResume;
    procedure ScanForRenderers;
    procedure Load3DLUTFile(const ALutPath: string);
    procedure SetScalingAlgorithm(AMode: Integer);
    procedure ShowHotkeysReference;
    procedure RecordVideoStream;
    function StartPreciseClip(const Source, Destination: string; ClipStart, ClipEnd: Int64): Boolean;
    procedure VideoExportTick(Sender: TObject);
    procedure StopVideoRecording;
    procedure ToggleWebRemoteServer(APort: Word = 8080);
    property WebRemote: TWebRemoteServer read FWebRemote;
    function EnsureGPUShaderPipeline: Boolean;
    procedure DisableGPUShaderPipeline;
    procedure ToggleGPUShader(AFlag: TGPUShaderFlag);
    procedure LoadCustomHLSLShader(const APath: string);
    property GPUShader: TD3D11ShaderRenderer read FGPUShader;
    procedure Set3DStereoMode(AMode: Integer);
    procedure SetSleepTimerMinutes(AMinutes: Integer);
    procedure CycleAudioOutputDevice;
    procedure AdjustSubtitleSize(Delta: Integer);
    procedure AdjustSubtitleMargin(Delta: Integer);
    property SleepExpireTick: UInt64 read FSleepExpireTick;
    property Stereo3DMode: Integer read F3DStereoMode;
    procedure CycleCropGeometry;
    procedure UpdateStatsHUD;
    procedure PlayNextFileInFolder;
    procedure PlayPrevFileInFolder;
    procedure ReopenLastClosedFile;
    procedure DefaultHandler(var Message); override;
    procedure WMWindowPosChanging(var Msg:TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMGetMinMaxInfo(var Msg:TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure MeasurePreferencesOpen(Sender: TObject);
    procedure WarmPreferences(Sender:TObject);
    procedure ShowOSD(const AText: string);
    function SeekPreviewStatus:string;
    procedure QueueMediaFiles(const Sources: TStrings);
    procedure ReloadPlayerPreferences;
    procedure ApplyAudioEffects;
    function EnsurePlaybackEngine: Boolean;
    procedure JumpSeconds(Seconds: Integer);
    function LoadSubtitleFile(const Path: string): Boolean;
    function LoadAudioFile(const Path: string): Boolean;
    function LoadSecondarySubtitleFile(const Path: string): Boolean;
    procedure SeekTo(TimeMs: Int64);
    procedure PlayFile(const AFilePath: string; AOptions: TStrings = nil;
      const SourceURL: string = '');
    procedure ApplyInterfaceCustomization;
    procedure ResetInterfaceDefaults;
    function GetMenuBarVisible: Boolean;
    procedure SetMenuBarVisible(const Value: Boolean);
    function GetTitleBarVisible: Boolean;
    procedure SetTitleBarVisible(const Value: Boolean);
    procedure SetIsBorderless(const Value: Boolean);
    property IsBorderless: Boolean read FIsBorderless write SetIsBorderless;
    property MenuBarVisible: Boolean read GetMenuBarVisible write SetMenuBarVisible;
    property TitleBarVisible: Boolean read GetTitleBarVisible write SetTitleBarVisible;
    property MediaPlayer: Plibvlc_media_player_t read FMediaPlayer;
    property CurrentMedia: Plibvlc_media_t read FCurrentMedia;
    property CurrentFile: string read FCurrentFile;
    property FullscreenDock: TPlayerFlyout read FDockWindow;
    property SeekPreviewImage: TImage read imgSeekPreview;
    property AudioSignalLevel: Single read FSignalLevel;
    property PlaybackFailed: Boolean read FPlaybackFailed;
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  EffectsForm, MediaInfoForm, JumpTimeForm, PreferencesForm, BookmarksForm, OpenMediaForm, ConvertForm, IPTVForm, MessagesForm, CustomizeForm, AboutForm, System.IniFiles, System.StrUtils, PlayerDialogs, VideoInput, PlayerMenu, Vcl.Clipbrd, Vcl.Imaging.pngimage, Winapi.Dwmapi, WatermarkOSD, InstanceBroker, DualSubtitles, System.IOUtils, ThumbnailSheet, GifMaker, RuntimeComponents, PlayerPaths, System.Hash, Winapi.CommCtrl;

{$R *.dfm}

procedure TFrmMain.WMCopyData(var Msg: TWMCopyData);
var Sources: TStringList; Text: string; First: Integer;
begin
  Msg.Result := 0;
  if FClosing or not FUIReady or (Msg.CopyDataStruct = nil) then Exit;
  if Msg.CopyDataStruct.dwData <> PLAYER_OPEN_REQUEST then Exit;
  if (Msg.CopyDataStruct.lpData = nil) or (Msg.CopyDataStruct.cbData < 2) or
     (Msg.CopyDataStruct.cbData > 1024 * 1024) or (Msg.CopyDataStruct.cbData mod 2 <> 0) then Exit;
  SetString(Text, PChar(Msg.CopyDataStruct.lpData), Msg.CopyDataStruct.cbData div SizeOf(Char) - 1);
  Sources := TStringList.Create;
  try
    Sources.Text := Text;
    First := FPlaylistPaths.Count;
    for var Source in Sources do
      if FileExists(Source) or Source.Contains('://') then
      begin
        FPlaylistPaths.Add(Source);
        lstPlaylist.Items.Add(ExtractFileName(Source));
      end;
    if FIsBossHidden then ToggleBossKey;
    Show;
    if IsIconic(Handle) then ShowWindow(Handle, SW_RESTORE);
    SetForegroundWindow(GetLastActivePopup(Handle));
    if FPlaylistPaths.Count > First then PlayMediaAtIndex(First);
    Msg.Result := 1;
  finally Sources.Free; end;
end;

procedure TFrmMain.OnClickPauseTimer(Sender: TObject);
begin
  if Assigned(tmrClickPause) then
    tmrClickPause.Enabled := False;
  case FSettings.SingleClick of
    0: mnuPlayPauseClick(nil);
    1: mnuFullscreenClick(nil);
  end;
end;

procedure TFrmMain.WMUserVideoLeftClick(var Msg: TMessage);
begin
  if not Enabled or not IsWindowEnabled(Handle) then Exit;
  if PlayerMenuWindow <> nil then
  begin
    ClosePlayerMenus;
    Exit;
  end;
  FClickActionTick := GetTickCount64;
  FClickWasPlaying := (FMediaPlayer <> nil) and (libvlc_media_player_is_playing(FMediaPlayer) = 1);
  FClickWasFullscreen := FIsFullscreen;
  FClickActionApplied := FSettings.SingleClick <> 2;
  OnClickPauseTimer(nil);
end;

procedure TFrmMain.WMUserVideoDblClick(var Msg: TMessage);
begin
  if PlayerMenuWindow <> nil then
  begin
    ClosePlayerMenus;
    Exit;
  end;
  if Assigned(tmrClickPause) then
    tmrClickPause.Enabled := False;
  // First click responds immediately. Undo its toggle once when Windows
  // recognizes a double click, then execute the configured double action.
  if FClickActionApplied and (GetTickCount64 - FClickActionTick <= GetDoubleClickTime) then
  begin
    FClickActionApplied := False;
    if ((FSettings.SingleClick = 0) and (FSettings.DoubleClick = 1)) or
       ((FSettings.SingleClick = 1) and (FSettings.DoubleClick = 0)) then Exit;
    FSuppressTransientOSD := True;
    try
      if (FSettings.SingleClick = 0) and (FMediaPlayer <> nil) then
      begin
        libvlc_media_player_set_pause(FMediaPlayer, Ord(not FClickWasPlaying));
        if Assigned(btnPlay) then
          if FClickWasPlaying then btnPlay.IconKind := ikPause else btnPlay.IconKind := ikPlay;
        if Assigned(FTaskbarMgr) then FTaskbarMgr.UpdatePlayState(Handle, FClickWasPlaying);
      end
      else if (FSettings.SingleClick = 1) and (FIsFullscreen <> FClickWasFullscreen) then
        mnuFullscreenClick(nil);
    finally FSuppressTransientOSD := False; end;
    HidePlaybackOSD;
  end;
  ExecuteVideoDoubleAction(pnlVideo);
end;

procedure TFrmMain.WMUserVideoRightClick(var Msg: TMessage);
begin
  if Assigned(PopupMenuVideo) then
  begin
    ClosePlayerMenus;
    PopupMenuVideoPopup(PopupMenuVideo);
    ShowPlayerMenu(Self, PopupMenuVideo.Items, Point(Msg.WParam, Msg.LParam));
  end;
end;

procedure TFrmMain.WMUserVideoWheel(var Msg: TMessage);
var
  Delta: SmallInt;
begin
  if (PlayerMenuWindow <> nil) or not FSettings.WheelVolume then Exit;
  Delta := SmallInt(Msg.WParam);
  if Delta > 0 then
    AdjustVolume(5)
  else
    AdjustVolume(-5);
end;

procedure TFrmMain.BuildContextMenu;
var
  Playback, Media, Tools: TMenuItem;
  procedure SafeAdd(Target, Item: TMenuItem);
  begin
    if (Target = nil) or (Item = nil) then Exit;
    try
      if Item.Parent <> nil then
        Item.Parent.Remove(Item);
      Target.Add(Item);
    except
      on E: Exception do ;
    end;
  end;
  function Group(const Title: string): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := Title;
  end;
begin
  if PopupMenuVideo = nil then Exit;
  while PopupMenuVideo.Items.Count > 0 do
    PopupMenuVideo.Items.Remove(PopupMenuVideo.Items[0]);

  Playback := Group('Playback');
  Media := Group('Open media');
  Tools := Group('Tools');

  SafeAdd(Playback, popPrevious); SafeAdd(Playback, popNext);
  SafeAdd(Playback, popJumpBack); SafeAdd(Playback, popJumpFwd);
  SafeAdd(Playback, popJumpTime); SafeAdd(Playback, popABRepeat);
  SafeAdd(Playback, popNextFrame); SafeAdd(Playback, popSpeed);

  SafeAdd(Media, popOpenFile); SafeAdd(Media, popOpenURL);

  SafeAdd(Tools, popMediaInfo); SafeAdd(Tools, popBookmarks);
  SafeAdd(Tools, popStatsHUD); SafeAdd(Tools, popPreferences); SafeAdd(Tools, popThemes);

  SafeAdd(PopupMenuVideo.Items, popPlayPause);
  SafeAdd(PopupMenuVideo.Items, popStop);
  SafeAdd(PopupMenuVideo.Items, popSep1);
  SafeAdd(PopupMenuVideo.Items, Media);
  SafeAdd(PopupMenuVideo.Items, Playback);
  SafeAdd(PopupMenuVideo.Items, popVideo);
  SafeAdd(PopupMenuVideo.Items, popAudio);
  SafeAdd(PopupMenuVideo.Items, popSubtitle);
  SafeAdd(PopupMenuVideo.Items, popSep2);
  SafeAdd(PopupMenuVideo.Items, popPlaylist);
  SafeAdd(PopupMenuVideo.Items, Tools);
  SafeAdd(PopupMenuVideo.Items, popSep3);
  SafeAdd(PopupMenuVideo.Items, popExit);
end;

procedure TFrmMain.InitModernPlayerUI;
var
  I: Integer;
  TopItem, ChildItem: TMenuItem;
begin
  Color := DP_COLOR_BG;
  BorderStyle := bsSizeable;
  Menu := nil;

  // 1. Custom Title Bar
  if modernTitleBar = nil then
  begin
    modernTitleBar := TModernTitleBar.Create(Self);
    modernTitleBar.Parent := Self;
    modernTitleBar.Align := alTop;
    modernTitleBar.Height := 36;
    modernTitleBar.TitleText := 'VLC Modern';

    // Embedded App Icon (Vector-derived multi-res ICO + high-res PNG embedded in resources)
    modernTitleBar.LoadAppIconFromResource('APP_ICON_PNG');
    try
      if Icon.Empty then
        Icon.Handle := LoadIcon(HInstance, 'MAINICON');
      if (Application.Icon.Handle = 0) or Application.Icon.Empty then
        Application.Icon.Handle := LoadIcon(HInstance, 'MAINICON');
    except
    end;

    btnTitleClose := TModernVectorButton.Create(Self);
    btnTitleClose.Parent := modernTitleBar;
    btnTitleClose.IconKind := ikClose;
    btnTitleClose.CornerRadius := 6;
    btnTitleClose.Width := 30;
    btnTitleClose.Height := 26;
    btnTitleClose.Hint := 'Close';
    btnTitleClose.ShowHint := True;
    btnTitleClose.OnClick := OnTitleCloseClick;

    btnTitleMax := TModernVectorButton.Create(Self);
    btnTitleMax.Parent := modernTitleBar;
    btnTitleMax.IconKind := ikMaximize;
    btnTitleMax.CornerRadius := 6;
    btnTitleMax.Width := 30;
    btnTitleMax.Height := 26;
    btnTitleMax.Hint := 'Maximize / Restore';
    btnTitleMax.ShowHint := True;
    btnTitleMax.OnClick := OnTitleMaxClick;

    btnTitleMin := TModernVectorButton.Create(Self);
    btnTitleMin.Parent := modernTitleBar;
    btnTitleMin.IconKind := ikMinimize;
    btnTitleMin.CornerRadius := 6;
    btnTitleMin.Width := 30;
    btnTitleMin.Height := 26;
    btnTitleMin.Hint := 'Minimize';
    btnTitleMin.ShowHint := True;
    btnTitleMin.OnClick := OnTitleMinClick;
  end;

  // 1.1 Sleek Modern Top Menu Bar (Media, Playback, Audio, Video, Subtitle, Tools, View, Help)
  if pnlMenuBar = nil then
  begin
    pnlMenuBar := TPanel.Create(Self);
    pnlMenuBar.Parent := Self;
    pnlMenuBar.Align := alTop;
    pnlMenuBar.Height := 26;
    pnlMenuBar.Color := DP_COLOR_BG;
    pnlMenuBar.BevelOuter := bvNone;
    pnlMenuBar.ParentBackground := False;

    btnMenuMedia := TModernVectorButton.Create(Self);
    btnMenuMedia.Parent := pnlMenuBar;
    btnMenuMedia.Caption := 'Media';
    btnMenuMedia.Tag := 0;
    btnMenuMedia.Width := 54;
    btnMenuMedia.Height := 22;
    btnMenuMedia.CornerRadius := 4;
    btnMenuMedia.OnClick := OnTopMenuItemClick;
    btnMenuMedia.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuPlayback := TModernVectorButton.Create(Self);
    btnMenuPlayback.Parent := pnlMenuBar;
    btnMenuPlayback.Caption := 'Playback';
    btnMenuPlayback.Tag := 1;
    btnMenuPlayback.Width := 66;
    btnMenuPlayback.Height := 22;
    btnMenuPlayback.CornerRadius := 4;
    btnMenuPlayback.OnClick := OnTopMenuItemClick;
    btnMenuPlayback.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuAudio := TModernVectorButton.Create(Self);
    btnMenuAudio.Parent := pnlMenuBar;
    btnMenuAudio.Caption := 'Audio';
    btnMenuAudio.Tag := 2;
    btnMenuAudio.Width := 50;
    btnMenuAudio.Height := 22;
    btnMenuAudio.CornerRadius := 4;
    btnMenuAudio.OnClick := OnTopMenuItemClick;
    btnMenuAudio.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuVideo := TModernVectorButton.Create(Self);
    btnMenuVideo.Parent := pnlMenuBar;
    btnMenuVideo.Caption := 'Video';
    btnMenuVideo.Tag := 3;
    btnMenuVideo.Width := 50;
    btnMenuVideo.Height := 22;
    btnMenuVideo.CornerRadius := 4;
    btnMenuVideo.OnClick := OnTopMenuItemClick;
    btnMenuVideo.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuSubtitle := TModernVectorButton.Create(Self);
    btnMenuSubtitle.Parent := pnlMenuBar;
    btnMenuSubtitle.Caption := 'Subtitle';
    btnMenuSubtitle.Tag := 4;
    btnMenuSubtitle.Width := 62;
    btnMenuSubtitle.Height := 22;
    btnMenuSubtitle.CornerRadius := 4;
    btnMenuSubtitle.OnClick := OnTopMenuItemClick;
    btnMenuSubtitle.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuTools := TModernVectorButton.Create(Self);
    btnMenuTools.Parent := pnlMenuBar;
    btnMenuTools.Caption := 'Tools';
    btnMenuTools.Tag := 5;
    btnMenuTools.Width := 50;
    btnMenuTools.Height := 22;
    btnMenuTools.CornerRadius := 4;
    btnMenuTools.OnClick := OnTopMenuItemClick;
    btnMenuTools.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuView := TModernVectorButton.Create(Self);
    btnMenuView.Parent := pnlMenuBar;
    btnMenuView.Caption := 'View';
    btnMenuView.Tag := 6;
    btnMenuView.Width := 48;
    btnMenuView.Height := 22;
    btnMenuView.CornerRadius := 4;
    btnMenuView.OnClick := OnTopMenuItemClick;
    btnMenuView.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuHelp := TModernVectorButton.Create(Self);
    btnMenuHelp.Parent := pnlMenuBar;
    btnMenuHelp.Caption := 'Help';
    btnMenuHelp.Tag := 7;
    btnMenuHelp.Width := 48;
    btnMenuHelp.Height := 22;
    btnMenuHelp.CornerRadius := 4;
    btnMenuHelp.OnClick := OnTopMenuItemClick;
    btnMenuHelp.OnMouseEnter := OnTopMenuItemMouseEnter;

    btnMenuIPTV := TModernVectorButton.Create(Self);
    btnMenuIPTV.Parent := pnlMenuBar;
    btnMenuIPTV.Caption := 'Live TV';
    btnMenuIPTV.Hint := 'IPTV & Live Stream Studio (F8)';
    btnMenuIPTV.ShowHint := True;
    btnMenuIPTV.Width := 58;
    btnMenuIPTV.Height := 22;
    btnMenuIPTV.CornerRadius := 4;
    btnMenuIPTV.OnClick := OnLiveTVMenu;
    btnMenuIPTV.OnMouseEnter := OnTopMenuItemMouseEnter;
  end;

  // Enforce strict vertical order: Title Bar at Top=0, Menu Bar directly below at Top=36
  modernTitleBar.Top := 0;
  pnlMenuBar.Top := 36;

  // Enable Windows 11 Native Fluent Dark Menus with rounded corners
  EnableWindows11DarkMenus(Handle);

  BuildContextMenu;
  OnActivate := PlayerActivated;

  // 2. Video area configuration
  pnlRoot.Color := DP_COLOR_BG;
  pnlVideoContainer.Color := clBlack;
  pnlVideo.Color := clBlack;

  PopupMenu := nil;
  pnlVideoContainer.PopupMenu := nil;
  pnlVideoContainer.OnClick := pnlVideoClick;
  pnlVideoContainer.OnDblClick := pnlVideoDblClick;
  pnlVideoContainer.OnMouseDown := pnlVideoMouseDown;
  pnlVideoContainer.OnMouseMove := pnlVideoMouseMove;
  pnlVideoContainer.OnMouseUp := pnlVideoMouseUp;
  pnlVideo.PopupMenu := nil;
  pnlVideo.OnClick := pnlVideoClick;
  pnlVideo.OnDblClick := pnlVideoDblClick;
  pnlVideo.OnMouseDown := pnlVideoMouseDown;
  pnlVideo.OnMouseMove := pnlVideoMouseMove;
  pnlVideo.OnMouseUp := pnlVideoMouseUp;

  // Initialize modern Audio Mode card in video container
  InitAudioModeUI;
  FVisualTimer := TTimer.Create(Self);
  FVisualTimer.Interval := 40;
  FVisualTimer.OnTimer := VisualizerTick;

  // Initialize Windows 10/11 Taskbar Thumbnail Toolbar Manager
  FTaskbarMgr := TTaskbarManager.Create;
  FWMTaskbarCreated := TaskbarButtonMsgId;

  // 3. Floating/Docked Bottom Deck Container
  pnlBottom.Align := alBottom;
  pnlBottom.Height := 94;
  pnlBottom.Color := DP_COLOR_BG;
  pnlBottom.ParentBackground := False;
  pnlRoot.Align := alClient;
  pnlProgressRow.Visible := False;
  pnlControlsRow.Visible := False;

  if cardBottomDock = nil then
  begin
    cardBottomDock := TModernCardPanel.Create(Self);
    cardBottomDock.Parent := pnlBottom;
    cardBottomDock.CornerRadius := 14;
    cardBottomDock.CardColor := DP_COLOR_SURFACE;
    cardBottomDock.BorderColor := DP_COLOR_BORDER;
    cardBottomDock.OnMouseDown := OnDockMouseDown;
    pnlBottom.OnMouseDown := OnDockMouseDown;
    pnlMenuBar.OnMouseDown := OnDockMouseDown;

    // Modern Glowing Seek Bar
    modernSeekBar := TModernSeekBar.Create(Self);
    modernSeekBar.Parent := cardBottomDock;
    modernSeekBar.Height := 24;
    modernSeekBar.OnSeek := OnModernSeek;
    modernSeekBar.OnHover := OnSeekBarHover;
    modernSeekBar.OnLeave := OnSeekBarLeave;

    FLastPlayPauseTick := 0;

    tmrFullscreenHide := TTimer.Create(Self);
    tmrFullscreenHide.Interval := 3000;
    tmrFullscreenHide.Enabled := False;
    tmrFullscreenHide.OnTimer := OnFullscreenHideTimer;
    FFullscreenMouseTimer := TTimer.Create(Self);
    FFullscreenMouseTimer.Enabled := False;
    FFullscreenMouseTimer.Interval := 50;
    FFullscreenMouseTimer.OnTimer := WatchFullscreenMouse;

    FDockWindow := TPlayerFlyout.Create(Self);
    FPreviewWindow := TPlayerFlyout.Create(Self);
    FDockWindow.KeyPreview := True;
    FDockWindow.OnKeyDown := FormKeyDown;
    FPreviewWindow.KeyPreview := True;
    FPreviewWindow.OnKeyDown := FormKeyDown;

    // Floating YouTube-Style Thumbnail Preview Card
    cardSeekPreview := TModernCardPanel.Create(Self);
    cardSeekPreview.Parent := FPreviewWindow;
    cardSeekPreview.Align := alClient;
    cardSeekPreview.Visible := False;
    cardSeekPreview.Width := 192;
    cardSeekPreview.Height := 148;
    cardSeekPreview.CornerRadius := 0;
    cardSeekPreview.CardColor := $00181818;
    FPreviewWindow.Color := cardSeekPreview.CardColor;
    cardSeekPreview.BorderColor := $003C3C3C;

    imgSeekPreview := TRoundedPreviewImage.Create(cardSeekPreview);
    imgSeekPreview.Parent := cardSeekPreview;
    imgSeekPreview.Left := 8;
    imgSeekPreview.Top := 8;
    imgSeekPreview.Width := 176;
    imgSeekPreview.Height := 99;
    imgSeekPreview.Proportional := True;
    imgSeekPreview.Stretch := True;
    imgSeekPreview.Visible := False;

    lblSeekPreviewTime := TLabel.Create(cardSeekPreview);
    lblSeekPreviewTime.Parent := cardSeekPreview;
    lblSeekPreviewTime.Left := 0;
    lblSeekPreviewTime.Top := 114;
    lblSeekPreviewTime.Width := 192;
    lblSeekPreviewTime.Height := 22;
    lblSeekPreviewTime.Alignment := taCenter;
    lblSeekPreviewTime.Font.Name := 'Segoe UI';
    lblSeekPreviewTime.Font.Size := 11;
    lblSeekPreviewTime.Font.Style := [fsBold];
    lblSeekPreviewTime.Font.Color := clWhite;
    lblSeekPreviewTime.Transparent := True;

    // Time Label (Click toggles Remaining / Total duration - VLC / MPC-HC style)
    lblTimeDisplay := TLabel.Create(Self);
    lblTimeDisplay.Parent := cardBottomDock;
    lblTimeDisplay.AutoSize := False;
    lblTimeDisplay.Alignment := taRightJustify;
    lblTimeDisplay.Font.Name := 'Segoe UI';
    lblTimeDisplay.Font.Size := 10;
    lblTimeDisplay.Font.Color := DP_COLOR_MUTED;
    lblTimeDisplay.Caption := '00:00 / 00:00';
    lblTimeDisplay.Transparent := True;
    lblTimeDisplay.Cursor := crHandPoint;
    lblTimeDisplay.Hint := 'Click to toggle Remaining / Total Time';
    lblTimeDisplay.ShowHint := True;
    lblTimeDisplay.OnClick := OnTimeDisplayClick;

    // Left: Volume
    btnMute := TModernVectorButton.Create(Self);
    btnMute.Parent := cardBottomDock;
    btnMute.IconKind := ikVolume;
    btnMute.Width := 36;
    btnMute.Height := 36;
    btnMute.CornerRadius := 10;
    btnMute.Hint := 'Mute / Unmute (M)';
    btnMute.ShowHint := True;
    btnMute.OnClick := OnModernMuteClick;

    modernVolumeSlider := TModernVolumeSlider.Create(Self);
    modernVolumeSlider.Parent := cardBottomDock;
    modernVolumeSlider.Width := 80;
    modernVolumeSlider.Height := 24;
    modernVolumeSlider.Volume := 100;
    modernVolumeSlider.OnVolumeChange := OnModernVolumeChange;

    lblVolPctDisplay := TLabel.Create(Self);
    lblVolPctDisplay.Parent := cardBottomDock;
    lblVolPctDisplay.AutoSize := True;
    lblVolPctDisplay.Font.Name := 'Segoe UI';
    lblVolPctDisplay.Font.Size := 9;
    lblVolPctDisplay.Font.Color := DP_COLOR_MUTED;
    lblVolPctDisplay.Caption := '100%';
    lblVolPctDisplay.Transparent := True;

    // Center Transport
    btnPrev := TModernVectorButton.Create(Self);
    btnPrev.Parent := cardBottomDock;
    btnPrev.IconKind := ikPrev;
    btnPrev.Width := 36;
    btnPrev.Height := 36;
    btnPrev.CornerRadius := 10;
    btnPrev.Hint := 'Previous';
    btnPrev.ShowHint := True;
    btnPrev.OnClick := mnuPreviousClick;

    btnJumpBack := TModernVectorButton.Create(Self);
    btnJumpBack.Parent := cardBottomDock;
    btnJumpBack.IconKind := ikJumpBack;
    btnJumpBack.Width := 36;
    btnJumpBack.Height := 36;
    btnJumpBack.CornerRadius := 10;
    btnJumpBack.Hint := 'Rewind 10s (Left Arrow)';
    btnJumpBack.ShowHint := True;
    btnJumpBack.OnClick := mnuJumpBackClick;

    btnPlay := TModernVectorButton.Create(Self);
    btnPlay.Parent := cardBottomDock;
    btnPlay.IconKind := ikPlay;
    btnPlay.Width := 46;
    btnPlay.Height := 46;
    btnPlay.IsCircular := True;
    btnPlay.IsAccent := True;
    btnPlay.CornerRadius := 23;
    btnPlay.Hint := 'Play / Pause (Space)';
    btnPlay.ShowHint := True;
    btnPlay.OnClick := OnModernPlayClick;

    btnJumpFwd := TModernVectorButton.Create(Self);
    btnJumpFwd.Parent := cardBottomDock;
    btnJumpFwd.IconKind := ikJumpFwd;
    btnJumpFwd.Width := 36;
    btnJumpFwd.Height := 36;
    btnJumpFwd.CornerRadius := 10;
    btnJumpFwd.Hint := 'Forward 10s (Right Arrow)';
    btnJumpFwd.ShowHint := True;
    btnJumpFwd.OnClick := mnuJumpFwdClick;

    btnNext := TModernVectorButton.Create(Self);
    btnNext.Parent := cardBottomDock;
    btnNext.IconKind := ikNext;
    btnNext.Width := 36;
    btnNext.Height := 36;
    btnNext.CornerRadius := 10;
    btnNext.Hint := 'Next';
    btnNext.ShowHint := True;
    btnNext.OnClick := mnuNextClick;

    btnStop := TModernVectorButton.Create(Self);
    btnStop.Parent := cardBottomDock;
    btnStop.IconKind := ikStop;
    btnStop.Width := 36;
    btnStop.Height := 36;
    btnStop.CornerRadius := 10;
    btnStop.Hint := 'Stop (S)';
    btnStop.ShowHint := True;
    btnStop.OnClick := mnuStopClick;

    // Right Features
    btnSpeed := TModernVectorButton.Create(Self);
    btnSpeed.Parent := cardBottomDock;
    btnSpeed.IconKind := ikNone;
    btnSpeed.BadgeText := '1.0x';
    btnSpeed.Width := 44;
    btnSpeed.Height := 32;
    btnSpeed.CornerRadius := 8;
    btnSpeed.Hint := 'Speed: Click to cycle speed';
    btnSpeed.ShowHint := True;
    btnSpeed.OnClick := OnModernSpeedClick;

    btnEqualizer := TModernVectorButton.Create(Self);
    btnEqualizer.Parent := cardBottomDock;
    btnEqualizer.IconKind := ikEqualizer;
    btnEqualizer.Width := 36;
    btnEqualizer.Height := 36;
    btnEqualizer.CornerRadius := 10;
    btnEqualizer.Hint := 'Equalizer & Audio Effects';
    btnEqualizer.ShowHint := True;
    btnEqualizer.OnClick := mnuEffectsClick;

    btnPlaylistToggle := TModernVectorButton.Create(Self);
    btnPlaylistToggle.Parent := cardBottomDock;
    btnPlaylistToggle.IconKind := ikPlaylist;
    btnPlaylistToggle.Width := 36;
    btnPlaylistToggle.Height := 36;
    btnPlaylistToggle.CornerRadius := 10;
    btnPlaylistToggle.Hint := 'Toggle Playlist Panel';
    btnPlaylistToggle.ShowHint := True;
    btnPlaylistToggle.OnClick := OnModernPlaylistToggle;

    btnFullscreen := TModernVectorButton.Create(Self);
    btnFullscreen.Parent := cardBottomDock;
    btnFullscreen.IconKind := ikFullscreen;
    btnFullscreen.Width := 36;
    btnFullscreen.Height := 36;
    btnFullscreen.CornerRadius := 10;
    btnFullscreen.Hint := 'Toggle Fullscreen (F / DblClick)';
    btnFullscreen.ShowHint := True;
    btnFullscreen.OnClick := mnuFullscreenClick;
  end;

  // 4. Modern Playlist Card
  pnlPlaylist.Width := 280;
  pnlPlaylist.Color := clBlack;
  pnlPlaylist.ParentBackground := False;
  pnlPlaylistHeader.Visible := False;
  pnlPlaylistBottom.Visible := False;

  if cardPlaylist = nil then
  begin
    cardPlaylist := TModernCardPanel.Create(Self);
    cardPlaylist.Parent := pnlPlaylist;
    cardPlaylist.CornerRadius := 16;
    cardPlaylist.FlushRight := True;
    cardPlaylist.CardColor := DP_COLOR_SURFACE;
    cardPlaylist.BorderColor := DP_COLOR_BORDER;

    lblPlaylistHeading := TLabel.Create(Self);
    lblPlaylistHeading.Parent := cardPlaylist;
    lblPlaylistHeading.Caption := 'PLAYLIST';
    lblPlaylistHeading.Transparent := True;
    lblPlaylistHeading.Font.Name := 'Segoe UI';
    lblPlaylistHeading.Font.Size := 11;
    lblPlaylistHeading.Font.Style := [fsBold];
    lblPlaylistHeading.Font.Color := DP_COLOR_TEXT;

    btnClosePlaylist := TModernVectorButton.Create(Self);
    btnClosePlaylist.Parent := cardPlaylist;
    btnClosePlaylist.IconKind := ikClose;
    btnClosePlaylist.CornerRadius := 6;
    btnClosePlaylist.Width := 26;
    btnClosePlaylist.Height := 26;
    btnClosePlaylist.Hint := 'Close Playlist';
    btnClosePlaylist.ShowHint := True;
    btnClosePlaylist.OnClick := OnModernPlaylistToggle;

    lstPlaylist.Parent := cardPlaylist;
    lstPlaylist.Align := alNone;
    lstPlaylist.Color := DP_COLOR_SURFACE;
    lstPlaylist.Style := lbOwnerDrawFixed;
    lstPlaylist.ItemHeight := 34;
    lstPlaylist.OnDrawItem := lstPlaylistDrawItem;

    btnAddMedia := TModernVectorButton.Create(Self);
    btnAddMedia.Parent := cardPlaylist;
    btnAddMedia.IconKind := ikAdd;
    btnAddMedia.CornerRadius := 8;
    btnAddMedia.Width := 46;
    btnAddMedia.Height := 30;
    btnAddMedia.Hint := 'Add Media File';
    btnAddMedia.ShowHint := True;
    btnAddMedia.OnClick := mnuOpenFileClick;

    btnRemoveMedia := TModernVectorButton.Create(Self);
    btnRemoveMedia.Parent := cardPlaylist;
    btnRemoveMedia.IconKind := ikRemove;
    btnRemoveMedia.CornerRadius := 8;
    btnRemoveMedia.Width := 46;
    btnRemoveMedia.Height := 30;
    btnRemoveMedia.Hint := 'Remove Selected Track';
    btnRemoveMedia.ShowHint := True;
    btnRemoveMedia.OnClick := btnRemoveMediaClick;

    btnClearPlaylist := TModernVectorButton.Create(Self);
    btnClearPlaylist.Parent := cardPlaylist;
    btnClearPlaylist.IconKind := ikClear;
    btnClearPlaylist.CornerRadius := 8;
    btnClearPlaylist.Width := 46;
    btnClearPlaylist.Height := 30;
    btnClearPlaylist.Hint := 'Clear Playlist';
    btnClearPlaylist.ShowHint := True;
    btnClearPlaylist.OnClick := btnClearPlaylistClick;

    btnRepeat := TModernVectorButton.Create(Self);
    btnRepeat.Parent := cardPlaylist;
    btnRepeat.IconKind := ikRepeat;
    btnRepeat.CornerRadius := 8;
    btnRepeat.Width := 46;
    btnRepeat.Height := 30;
    btnRepeat.Hint := 'Repeat Mode';
    btnRepeat.ShowHint := True;
    btnRepeat.OnClick := OnModernRepeatClick;

    btnShuffle := TModernVectorButton.Create(Self);
    btnShuffle.Parent := cardPlaylist;
    btnShuffle.IconKind := ikShuffle;
    btnShuffle.CornerRadius := 8;
    btnShuffle.Width := 46;
    btnShuffle.Height := 30;
    btnShuffle.Hint := 'Shuffle Playlist';
    btnShuffle.ShowHint := True;
    btnShuffle.OnClick := btnShuffleClick;
  end;

  RepositionModernControls;
end;

procedure TFrmMain.RepositionModernControls;
var
  DockW, CenterX, StartX, CurX: Integer;
  function Logical(Value: Integer): Integer;
  begin
    Result := MulDiv(Value, 96, CurrentPPI);
  end;
  procedure Place(Control: TControl; X, Y, W, H: Integer);
  begin
    Control.SetBounds(MulDiv(X, CurrentPPI, 96), MulDiv(Y, CurrentPPI, 96),
      MulDiv(W, CurrentPPI, 96), MulDiv(H, CurrentPPI, 96));
  end;
begin
  if not FUIReady or FClosing then Exit;
  // Leave a real client edge owned by the form. Child video/playlist HWNDs
  // must not cover the resize hit-test area of the custom window frame.
  pnlRoot.Margins.Left := MulDiv(6, CurrentPPI, 96);
  pnlRoot.Margins.Right := MulDiv(6, CurrentPPI, 96);
  pnlRoot.Margins.Top := 0;
  pnlRoot.Margins.Bottom := 0;
  pnlRoot.AlignWithMargins := not FIsFullscreen;
  pnlBottom.Margins.Left := MulDiv(6, CurrentPPI, 96);
  pnlBottom.Margins.Right := MulDiv(6, CurrentPPI, 96);
  pnlBottom.Margins.Top := 0;
  pnlBottom.Margins.Bottom := MulDiv(6, CurrentPPI, 96);
  pnlBottom.AlignWithMargins := not FIsFullscreen;
  if FIsFullscreen then
  begin
    pnlBottom.Align := alNone;
    pnlBottom.SetBounds(0, ClientHeight - MulDiv(94, CurrentPPI, 96), ClientWidth, MulDiv(94, CurrentPPI, 96));
    pnlVideoContainer.SetBounds(0, 0, ClientWidth, ClientHeight);
  end
  else
  begin
    pnlBottom.Align := alBottom;
    pnlBottom.Height := MulDiv(94, CurrentPPI, 96);
  end;
  // Resize the existing host HWND; the playlist reserves its own space.
  pnlPlaylist.Align := alNone;
  if not FPlaylistAnimating then
    pnlPlaylist.SetBounds(pnlPlaylist.Parent.ClientWidth - MulDiv(280, CurrentPPI, 96),
      0, MulDiv(280, CurrentPPI, 96), pnlPlaylist.Parent.ClientHeight);
  if pnlPlaylist.Visible then pnlPlaylist.BringToFront;
  pnlVideoContainer.Align := alNone;
  if pnlPlaylist.Visible then
    pnlVideoContainer.SetBounds(0, 0, Max(1, pnlPlaylist.Left), pnlRoot.ClientHeight)
  else
    pnlVideoContainer.SetBounds(0, 0, pnlRoot.ClientWidth, pnlRoot.ClientHeight);
  if modernTitleBar <> nil then
  begin
    modernTitleBar.Top := 0;
    modernTitleBar.Height := MulDiv(36, CurrentPPI, 96);
    Place(btnTitleClose, Logical(modernTitleBar.Width) - 36, 5, 30, 26);
    Place(btnTitleMax, Logical(modernTitleBar.Width) - 70, 5, 30, 26);
    Place(btnTitleMin, Logical(modernTitleBar.Width) - 104, 5, 30, 26);
  end;

  if pnlMenuBar <> nil then
  begin
    pnlMenuBar.Top := MulDiv(36, CurrentPPI, 96);
    pnlMenuBar.Height := MulDiv(26, CurrentPPI, 96);
    CurX := 12;
    Place(btnMenuMedia, CurX, 2, 54, 22); Inc(CurX, 58);
    Place(btnMenuPlayback, CurX, 2, 66, 22); Inc(CurX, 70);
    Place(btnMenuAudio, CurX, 2, 50, 22); Inc(CurX, 54);
    Place(btnMenuVideo, CurX, 2, 50, 22); Inc(CurX, 54);
    Place(btnMenuSubtitle, CurX, 2, 62, 22); Inc(CurX, 66);
    Place(btnMenuTools, CurX, 2, 50, 22); Inc(CurX, 54);
    Place(btnMenuView, CurX, 2, 48, 22); Inc(CurX, 52);
    if btnMenuIPTV <> nil then begin Place(btnMenuIPTV, CurX, 2, 58, 22); Inc(CurX, 62); end;
    Place(btnMenuHelp, CurX, 2, 48, 22);
  end;

  if cardBottomDock <> nil then
  begin
    if FIsFullscreen then
    begin
      pnlBottom.Parent := FDockWindow;
      pnlBottom.Align := alClient;
      var AvailableWidth := pnlVideoContainer.ClientWidth;
      DockW := Min(MulDiv(1160, CurrentPPI, 96), AvailableWidth - MulDiv(48, CurrentPPI, 96));
      var DockOrigin := pnlVideoContainer.ClientToScreen(Point((AvailableWidth - DockW) div 2,
        pnlVideoContainer.ClientHeight - MulDiv(98, CurrentPPI, 96)));
      FDockWindow.Arrange(Rect(DockOrigin.X, DockOrigin.Y, DockOrigin.X + DockW,
        DockOrigin.Y + MulDiv(82, CurrentPPI, 96)));
      cardBottomDock.Align := alClient;
      cardBottomDock.CornerRadius := 0;
      // Reparenting defers alignment; size the content before placing children.
      pnlBottom.SetBounds(0, 0, FDockWindow.ClientWidth, FDockWindow.ClientHeight);
      cardBottomDock.SetBounds(0, 0, pnlBottom.ClientWidth, pnlBottom.ClientHeight);
    end
    else
    begin
      pnlBottom.Parent := Self;
      cardBottomDock.Align := alNone;
      cardBottomDock.CornerRadius := 14;
      Place(cardBottomDock, 10, 6, Logical(pnlBottom.ClientWidth) - 20, Logical(pnlBottom.ClientHeight) - 12);
    end;
    DockW := Logical(cardBottomDock.Width);

    // Top Seek Row
    Place(modernSeekBar, 14, 8, DockW - 160, 24);
    Place(lblTimeDisplay, DockW - 140, 10, 126, 20);

    // Left Volume Group
    Place(btnMute, 14, 36, 36, 36);
    Place(modernVolumeSlider, 54, 42, 80, 24);
    Place(lblVolPctDisplay, 138, 46, 36, 18);

    // Center Transport Group
    CenterX := DockW div 2;
    StartX := CenterX - 128;
    Place(btnPrev, StartX, 36, 36, 36);
    Place(btnJumpBack, StartX + 42, 36, 36, 36);
    Place(btnPlay, StartX + 84, 31, 46, 46);
    Place(btnJumpFwd, StartX + 136, 36, 36, 36);
    Place(btnNext, StartX + 178, 36, 36, 36);
    Place(btnStop, StartX + 220, 36, 36, 36);

    // Right Features Group
    Place(btnFullscreen, DockW - 46, 36, 36, 36);
    Place(btnPlaylistToggle, DockW - 88, 36, 36, 36);
    Place(btnEqualizer, DockW - 130, 36, 36, 36);
    Place(btnSpeed, DockW - 180, 38, 44, 32);
  end;

  if (cardPlaylist <> nil) and pnlPlaylist.Visible then
  begin
    Place(cardPlaylist, 0, 0, Logical(pnlPlaylist.ClientWidth), Logical(pnlPlaylist.ClientHeight));
    Place(lblPlaylistHeading, 16, 12, 120, 20);
    Place(btnClosePlaylist, Logical(cardPlaylist.Width) - 34, 10, 24, 24);
    Place(lstPlaylist, 10, 42, Logical(cardPlaylist.Width) - 18, Logical(cardPlaylist.Height) - 88);

    Place(btnAddMedia, 10, Logical(cardPlaylist.Height) - 38, 44, 30);
    Place(btnRemoveMedia, 60, Logical(cardPlaylist.Height) - 38, 44, 30);
    Place(btnClearPlaylist, 110, Logical(cardPlaylist.Height) - 38, 44, 30);
    Place(btnRepeat, 160, Logical(cardPlaylist.Height) - 38, 44, 30);
    Place(btnShuffle, 210, Logical(cardPlaylist.Height) - 38, 44, 30);
  end;

  if Assigned(cardAudioMode) and cardAudioMode.Visible then
  begin
    var AudioWidth:=pnlVideoContainer.ClientWidth;
    cardAudioMode.Width:=Min(MulDiv(520,CurrentPPI,96),Max(MulDiv(260,CurrentPPI,96),AudioWidth-MulDiv(32,CurrentPPI,96)));
    cardAudioMode.Left:=Max(0,(AudioWidth-cardAudioMode.Width) div 2);
    cardAudioMode.Top:=Max(10,(pnlVideoContainer.ClientHeight-cardAudioMode.Height) div 2);
    cardAlbumArt.Left:=(cardAudioMode.Width-cardAlbumArt.Width) div 2;
    lblAudioTitle.Width:=cardAudioMode.Width-40;
    lblAudioArtist.Width:=cardAudioMode.Width-40;
    lblAudioAlbum.Width:=cardAudioMode.Width-40;
    pbVisualizer.Width:=cardAudioMode.Width-40;
  end;
end;

procedure TFrmMain.OnTopMenuItemClick(Sender: TObject);
var
  Btn: TModernVectorButton;
  Pt: TPoint;
  MnuIdx: Integer;
begin
  if not (Sender is TModernVectorButton) then Exit;
  Btn := TModernVectorButton(Sender);
  MnuIdx := Btn.Tag;
  if (MnuIdx >= 0) and (MnuIdx < MainMenu1.Items.Count) then
  begin
    if not PlayerMenuShows(MainMenu1.Items[MnuIdx]) then ClosePlayerMenus;
    if MnuIdx = 2 then
    begin
      UpdateAudioTracksMenu(mnuAudioTrack);
      UpdateAudioDevicesMenu(mnuAudioDevice);
    end;
    if MnuIdx = 4 then UpdateSubtitleTracksMenu(mnuSubTrack);
    Pt := Btn.ClientToScreen(Point(0, Btn.Height + 2));
    ShowPlayerMenu(Self, MainMenu1.Items[MnuIdx], Pt);
  end;
end;

procedure TFrmMain.OnTopMenuItemMouseEnter(Sender: TObject);
begin
  if PlayerMenuWindow=nil then Exit;
  if Sender=btnMenuIPTV then
  begin
    var LiveMenu:=TPopupMenu(FindComponent('LiveTVQuickMenu'));
    if (LiveMenu=nil) or not PlayerMenuShows(LiveMenu.Items) then OnLiveTVMenu(Sender);
    Exit;
  end;
  if (Sender is TModernVectorButton) and
     not PlayerMenuShows(MainMenu1.Items[TModernVectorButton(Sender).Tag]) then
  begin
    OnTopMenuItemClick(Sender);
  end;
end;

procedure TFrmMain.SeekTo(TimeMs: Int64);
var
  Duration: Int64;
begin
  FLocalRecordingFile := '';
  if (FMediaPlayer = nil) or (FCurrentMedia = nil) then Exit;
  if FIsFullscreen then TriggerFullscreenControls;
  Duration := libvlc_media_player_get_length(FMediaPlayer);
  TimeMs := Max(Int64(0), TimeMs);
  if Duration > 0 then TimeMs := Min(TimeMs, Duration - 1);
  FPendingSeek := TimeMs;
  FSeekRequestedAt := GetTickCount64;
  FSeekSentAt := 0;
  if Assigned(libvlc_media_player_is_seekable) and
    (libvlc_media_player_is_seekable(FMediaPlayer) <> 0) then
  begin
    libvlc_media_player_set_time(FMediaPlayer, TimeMs);
    FSeekSentAt := GetTickCount64;
  end;
end;

procedure TFrmMain.OnModernSeek(Sender: TObject; NewPosition: Single);
var
  Duration, TargetTime, PreviousTime: Int64;
  Pct: Integer;
begin
  if (FMediaPlayer = nil) or (FCurrentMedia = nil) then Exit;
  Duration := libvlc_media_player_get_length(FMediaPlayer);
  if Duration > 0 then
  begin
    TargetTime := Round(Duration * NewPosition);
    Pct := Round(NewPosition * 100);
    if FPendingSeek>=0 then PreviousTime:=FPendingSeek
    else PreviousTime:=Max(Int64(0),libvlc_media_player_get_time(FMediaPlayer));
    if not FSeekGestureActive then FSeekGestureStart:=PreviousTime;
    PreviousTime:=FSeekGestureStart;
    FSeekGestureActive:=(Sender is TModernSeekBar) and TModernSeekBar(Sender).IsDragging;
    SeekTo(TargetTime);
    ShowOSD(Format('%s%d s   %s   (%d%%)', [IfThen(TargetTime>=PreviousTime,'+',''),
      (TargetTime-PreviousTime) div 1000,FormatTime(TargetTime),Pct]));
  end
  else
    libvlc_media_player_set_position(FMediaPlayer, NewPosition);
end;

procedure TFrmMain.OnSeekBarHover(Sender: TObject; Pos: Single; ScreenPt: TPoint);
var
  TargetMs, TotalLen: Int64;
  ClientPt: TPoint;
  CardW, CardH, HalfW: Integer;
  ThumbLoaded: Boolean;
begin
  if (cardSeekPreview = nil) or (FMediaPlayer = nil) then Exit;
  TotalLen := libvlc_media_player_get_length(FMediaPlayer);
  if TotalLen <= 0 then Exit;

  TargetMs := Round(Pos * TotalLen);
  lblSeekPreviewTime.Caption := FormatTime(TargetMs);

  if not FIsAudioOnly and FileExists(FCurrentFile) then
  begin
    if FSeekDecoder = nil then FSeekDecoder := TSeekPreview.Create(FVlcInstance, imgSeekPreview);
    FSeekDecoder.Request(FCurrentFile, TargetMs);
  end;
  ThumbLoaded := not FIsAudioOnly and FileExists(FCurrentFile);
  if ThumbLoaded then
  begin
    imgSeekPreview.Visible := True;
    CardW := 192;
    CardH := 148;
    imgSeekPreview.SetBounds(8, 8, 176, 99);
    lblSeekPreviewTime.SetBounds(0, 114, 192, 22);
  end
  else
  begin
    imgSeekPreview.Visible := False;
    CardW := 92;
    CardH := 32;
    lblSeekPreviewTime.SetBounds(0, 5, 92, 22);
  end;

  cardSeekPreview.Width := CardW;
  cardSeekPreview.Height := CardH;
  ClientPt := ScreenToClient(ScreenPt);
  HalfW := CardW div 2;
  var PreviewOrigin := ClientToScreen(Point(EnsureRange(ClientPt.X - HalfW, 10, ClientWidth - CardW - 10), 0));
  var DockTop := pnlBottom.ClientToScreen(Point(0, 0)).Y;
  var PreviewTop := Max(ClientToScreen(Point(0, 10)).Y, DockTop - CardH - 12);
  cardSeekPreview.Visible := True;
  FPreviewWindow.Present(Rect(PreviewOrigin.X, PreviewTop, PreviewOrigin.X + CardW, PreviewTop + CardH));
end;

procedure TFrmMain.OnSeekBarLeave(Sender: TObject);
begin
  if Assigned(cardSeekPreview) then cardSeekPreview.Visible := False;
  if Assigned(FPreviewWindow) then FPreviewWindow.Dismiss;
  if Assigned(FSeekDecoder) then FSeekDecoder.Suspend;
end;

procedure TFrmMain.InitAudioModeUI;
begin
  cardAudioMode := TModernCardPanel.Create(Self);
  cardAudioMode.Name:='AudioModeCard';
  cardAudioMode.Parent := pnlVideoContainer;
  cardAudioMode.Width := 520;
  cardAudioMode.Height := 420;
  cardAudioMode.CornerRadius := 20;
  cardAudioMode.CardColor := DP_COLOR_SURFACE;
  cardAudioMode.BorderColor := DP_COLOR_BORDER;
  cardAudioMode.Visible := False;

  // Center Album Artwork Frame
  cardAlbumArt := TModernCardPanel.Create(cardAudioMode);
  cardAlbumArt.Parent := cardAudioMode;
  cardAlbumArt.Left := (cardAudioMode.Width - 170) div 2;
  cardAlbumArt.Top := 22;
  cardAlbumArt.Width := 170;
  cardAlbumArt.Height := 170;
  cardAlbumArt.CornerRadius := 16;
  cardAlbumArt.CardColor := DP_COLOR_ELEVATED;
  cardAlbumArt.BorderColor := DP_COLOR_ACCENT;

  imgAlbumArt := TImage.Create(cardAlbumArt);
  imgAlbumArt.Parent := cardAlbumArt;
  imgAlbumArt.Align := alClient;
  imgAlbumArt.Proportional := True;
  imgAlbumArt.Center := True;

  // Title Label - with WordWrap and multi-line support
  lblAudioTitle := TLabel.Create(cardAudioMode);
  lblAudioTitle.Parent := cardAudioMode;
  lblAudioTitle.Left := 20;
  lblAudioTitle.Top := 204;
  lblAudioTitle.Width := cardAudioMode.Width - 40;
  lblAudioTitle.Height := 46;
  lblAudioTitle.Alignment := taCenter;
  lblAudioTitle.AutoSize := False;
  lblAudioTitle.WordWrap := True;
  lblAudioTitle.ShowAccelChar := False;
  lblAudioTitle.Font.Name := 'Segoe UI';
  lblAudioTitle.Font.Size := 13;
  lblAudioTitle.Font.Style := [fsBold];
  lblAudioTitle.Font.Color := clWhite;
  lblAudioTitle.Caption := 'Music Track';
  lblAudioTitle.Transparent := True;

  // Artist Label
  lblAudioArtist := TLabel.Create(cardAudioMode);
  lblAudioArtist.Parent := cardAudioMode;
  lblAudioArtist.Left := 20;
  lblAudioArtist.Top := 254;
  lblAudioArtist.Width := cardAudioMode.Width - 40;
  lblAudioArtist.Height := 20;
  lblAudioArtist.Alignment := taCenter;
  lblAudioArtist.AutoSize := False;
  lblAudioArtist.ShowAccelChar := False;
  lblAudioArtist.Font.Name := 'Segoe UI';
  lblAudioArtist.Font.Size := 11;
  lblAudioArtist.Font.Style := [fsBold];
  lblAudioArtist.Font.Color := DP_COLOR_ACCENT;
  lblAudioArtist.Caption := 'Audio Track';
  lblAudioArtist.Transparent := True;

  // Album Label
  lblAudioAlbum := TLabel.Create(cardAudioMode);
  lblAudioAlbum.Parent := cardAudioMode;
  lblAudioAlbum.Left := 20;
  lblAudioAlbum.Top := 276;
  lblAudioAlbum.Width := cardAudioMode.Width - 40;
  lblAudioAlbum.Height := 20;
  lblAudioAlbum.Alignment := taCenter;
  lblAudioAlbum.AutoSize := False;
  lblAudioAlbum.ShowAccelChar := False;
  lblAudioAlbum.Font.Name := 'Segoe UI';
  lblAudioAlbum.Font.Size := 10;
  lblAudioAlbum.Font.Color := clMedGray;
  lblAudioAlbum.Caption := 'Music Collection';
  lblAudioAlbum.Transparent := True;

  // Modern Audio Spectrum Visualizer
  pbVisualizer := TPaintBox.Create(cardAudioMode);
  pbVisualizer.Parent := cardAudioMode;
  pbVisualizer.Left := 24;
  pbVisualizer.Top := 310;
  pbVisualizer.Width := cardAudioMode.Width - 48;
  pbVisualizer.Height := 74;
  pbVisualizer.OnPaint := OnVisualizerPaint;
end;

procedure TFrmMain.RenderVectorMusicArt;
var
  Bmp: TBitmap;
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Size: Integer;
begin
  Size := 170;
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(Size, Size);
    Bmp.PixelFormat := pf32bit;

    G := TGPGraphics.Create(Bmp.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHighQuality);

      Brush := TGPSolidBrush.Create(MakeColor(255, 20, 24, 32));
      try
        G.FillRectangle(Brush, 0, 0, Size, Size);
      finally
        Brush.Free;
      end;

      Brush := TGPSolidBrush.Create(MakeColor(35, 0, 162, 237));
      try
        G.FillEllipse(Brush, 25.0, 25.0, 120.0, 120.0);
      finally
        Brush.Free;
      end;

      Brush := TGPSolidBrush.Create(MakeColor(240, 0, 162, 237));
      try
        Pen := TGPPen.Create(MakeColor(240, 0, 162, 237), 6.0);
        try
          Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);

          G.FillEllipse(Brush, 45.0, 105.0, 28.0, 22.0);
          G.FillEllipse(Brush, 98.0, 92.0, 28.0, 22.0);
          G.DrawLine(Pen, 70.0, 114.0, 70.0, 52.0);
          G.DrawLine(Pen, 123.0, 101.0, 123.0, 39.0);

          Pen.SetWidth(9.0);
          G.DrawLine(Pen, 68.0, 50.0, 125.0, 37.0);
        finally
          Pen.Free;
        end;
      finally
        Brush.Free;
      end;
    finally
      G.Free;
    end;

    imgAlbumArt.Picture.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

procedure TFrmMain.VisualizerTick(Sender: TObject);
var Level: Single;
begin
  if not FIsAudioOnly or not Assigned(cardAudioMode) or not cardAudioMode.Visible then Exit;
  Level := 0;
  if (FMediaPlayer <> nil) and (libvlc_media_player_is_playing(FMediaPlayer) = 1) and
     (libvlc_audio_get_mute(FMediaPlayer) <> 1) then
  begin
    if FAudioMeter = nil then FAudioMeter := TProcessAudioMeter.Create;
    Level := FAudioMeter.Sample;
  end;
  FSignalLevel := Level;
  if (FMediaPlayer<>nil) and (libvlc_media_player_is_playing(FMediaPlayer)=1) then
  begin
    for var I := 0 to High(FVisualLevels) - 1 do FVisualLevels[I] := FVisualLevels[I + 1];
    FVisualLevels[High(FVisualLevels)] := Level;
  end
  else
    for var I:=0 to High(FVisualLevels) do
    begin
      FVisualLevels[I]:=FVisualLevels[I]*0.86;
      if FVisualLevels[I]<0.0001 then FVisualLevels[I]:=0;
    end;
  pbVisualizer.Invalidate;
end;

procedure TFrmMain.OnVisualizerPaint(Sender: TObject);
var
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  I, BarCount, BarW, Gap, TotalW, StartX, BaseY: Integer;
  BarH, MaxH: Single;
  Alpha, RCol, GCol, BCol: Byte;
  D, TopY: Single;
  Path: TGPGraphicsPath;
begin
  if pbVisualizer = nil then Exit;
  G := TGPGraphics.Create(pbVisualizer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    BarCount := 22;
    BarW := 10;
    Gap := 5;
    TotalW := BarCount * (BarW + Gap) - Gap;
    StartX := (pbVisualizer.Width - TotalW) div 2;
    BaseY := pbVisualizer.Height - 6;
    MaxH := pbVisualizer.Height - 12;

    for I := 0 to BarCount - 1 do
    begin
      BarH := 4.0 + Sqrt(FVisualLevels[I]) * (MaxH - 4.0);

      Alpha := Round(180 + 75 * (I / BarCount));
      RCol := Round(0 + 90 * (I / BarCount));
      GCol := Round(162 - 40 * (I / BarCount));
      BCol := 245;

      Brush := TGPSolidBrush.Create(MakeColor(Alpha, RCol, GCol, BCol));
      try
        Path := TGPGraphicsPath.Create;
        try
          D := BarW;
          TopY := BaseY - BarH;
          Path.AddArc(StartX + I * (BarW + Gap), TopY, D, D, 180, 180);
          Path.AddLine(StartX + I * (BarW + Gap) + BarW, TopY + D / 2, StartX + I * (BarW + Gap) + BarW, BaseY);
          Path.AddLine(StartX + I * (BarW + Gap) + BarW, BaseY, StartX + I * (BarW + Gap), BaseY);
          Path.CloseFigure;
          G.FillPath(Brush, Path);
        finally
          Path.Free;
        end;
      finally
        Brush.Free;
      end;
    end;
  finally
    G.Free;
  end;
end;

procedure TFrmMain.SwitchToAudioMode(const AFilePath: string);
var
  Title, Artist, Album, ArtPath, Dir: string;
  P: PAnsiChar;
  ArtLoaded: Boolean;
begin
  FIsAudioOnly := True;
  if not Assigned(cardAudioMode) then Exit;

  Title := '';
  Artist := '';
  Album := '';
  ArtPath := '';

  if (FCurrentMedia <> nil) and Assigned(libvlc_media_get_meta) then
  begin
    P := libvlc_media_get_meta(FCurrentMedia, 0);
    if P <> nil then Title := UTF8ToString(P);
    P := libvlc_media_get_meta(FCurrentMedia, 1);
    if P <> nil then Artist := UTF8ToString(P);
    P := libvlc_media_get_meta(FCurrentMedia, 4);
    if P <> nil then Album := UTF8ToString(P);
    P := libvlc_media_get_meta(FCurrentMedia, 15);
    if P <> nil then ArtPath := UTF8ToString(P);
  end;

  if Title = '' then Title := ChangeFileExt(ExtractFileName(AFilePath), '');
  var LowTitle := LowerCase(Title);
  if LowTitle.EndsWith('.mp3') or LowTitle.EndsWith('.flac') or LowTitle.EndsWith('.wav') or
     LowTitle.EndsWith('.m4a') or LowTitle.EndsWith('.aac') or LowTitle.EndsWith('.ogg') then
    Title := ChangeFileExt(Title, '');
  if Artist = '' then Artist := 'Audio Track';
  if Album = '' then Album := 'Music Collection';

  lblAudioTitle.Caption := Title;
  lblAudioTitle.Hint := Title;
  lblAudioTitle.ShowHint := True;
  lblAudioArtist.Caption := Artist;
  lblAudioAlbum.Caption := Album;

  ArtLoaded := False;
  if ArtPath.StartsWith('file:///') then
    ArtPath := StringReplace(Copy(ArtPath, 9, MaxInt), '/', '\', [rfReplaceAll])
  else if ArtPath.StartsWith('file://') then
    ArtPath := StringReplace(Copy(ArtPath, 8, MaxInt), '/', '\', [rfReplaceAll]);

  if (ArtPath <> '') and FileExists(ArtPath) then
  begin
    try
      imgAlbumArt.Picture.LoadFromFile(ArtPath);
      ArtLoaded := True;
    except
    end;
  end;

  if not ArtLoaded then
  begin
    Dir := ExtractFilePath(AFilePath);
    if FileExists(Dir + 'cover.jpg') then ArtPath := Dir + 'cover.jpg'
    else if FileExists(Dir + 'folder.jpg') then ArtPath := Dir + 'folder.jpg'
    else if FileExists(Dir + 'album.jpg') then ArtPath := Dir + 'album.jpg'
    else if FileExists(Dir + 'cover.png') then ArtPath := Dir + 'cover.png'
    else if FileExists(Dir + 'front.jpg') then ArtPath := Dir + 'front.jpg';

    if (ArtPath <> '') and FileExists(ArtPath) then
    begin
      try
        imgAlbumArt.Picture.LoadFromFile(ArtPath);
        ArtLoaded := True;
      except
      end;
    end;
  end;

  if not ArtLoaded then
    RenderVectorMusicArt;

  pnlVideo.Visible := False;
  cardAudioMode.Visible := True;
  cardAudioMode.BringToFront;

  if (WindowState = wsNormal) and not FIsFullscreen then
  begin
    if FOldVideoWidth = 0 then
    begin
      FOldVideoWidth := Width;
      FOldVideoHeight := Height;
    end;
    if Width < 740 then Width := 740;
    if Height < 580 then Height := 580;
  end;

  RepositionModernControls;
end;

procedure TFrmMain.SwitchToVideoMode;
begin
  if not FIsAudioOnly then Exit;
  FIsAudioOnly := False;
  if Assigned(cardAudioMode) then
    cardAudioMode.Visible := False;

  pnlVideo.Visible := True;
  pnlVideo.BringToFront;

  if (WindowState = wsNormal) and not FIsFullscreen and (FOldVideoWidth > 0) then
  begin
    Width := FOldVideoWidth;
    Height := FOldVideoHeight;
    FOldVideoWidth := 0;
    FOldVideoHeight := 0;
  end;

  RepositionModernControls;
end;

procedure TFrmMain.WMCommand(var Msg: TWMCommand);
begin
  if Msg.NotifyCode = THBN_CLICKED then
  begin
    case Msg.ItemID of
      CMD_THUMB_PREV:       mnuPreviousClick(nil);
      CMD_THUMB_REWIND:     mnuJumpBackClick(nil);
      CMD_THUMB_STOP:       mnuStopClick(nil);
      CMD_THUMB_PLAYPAUSE:  mnuPlayPauseClick(nil);
      CMD_THUMB_FORWARD:    mnuJumpFwdClick(nil);
      CMD_THUMB_NEXT:       mnuNextClick(nil);
      CMD_THUMB_FULLSCREEN: mnuFullscreenClick(nil);
    end;
    Msg.Result := 0;
    Exit;
  end;
  inherited;
end;

procedure TFrmMain.DefaultHandler(var Message);
begin
  if (FWMTaskbarCreated <> 0) and (TMessage(Message).Msg = FWMTaskbarCreated) then
  begin
    if Assigned(FTaskbarMgr) then
      FTaskbarMgr.InitButtons(Handle);
    TMessage(Message).Result := 0;
    Exit;
  end;
  inherited DefaultHandler(Message);
end;

procedure TFrmMain.OnModernVolumeChange(Sender: TObject; NewVolume: Integer);
begin
  if FMediaPlayer = nil then Exit;
  try
    FPendingVolume := NewVolume;
    libvlc_audio_set_volume(FMediaPlayer, NewVolume);
    if NewVolume > 0 then libvlc_audio_set_mute(FMediaPlayer, 0);
    if Assigned(lblVolPctDisplay) then
    begin
      lblVolPctDisplay.Caption := Format('%d%%', [NewVolume]);
      if NewVolume > 100 then
        lblVolPctDisplay.Font.Color := RGB($E7, $4C, $3C)
      else
        lblVolPctDisplay.Font.Color := DP_COLOR_MUTED;
    end;
    if Assigned(btnMute) then
    begin
      if NewVolume = 0 then
      begin
        btnMute.IconKind := ikMute;
        btnMute.IsActive := True;
      end
      else
      begin
        btnMute.IconKind := ikVolume;
        btnMute.IsActive := False;
      end;
    end;
    ShowOSD(Format('Volume: %d%%', [NewVolume]));
  except
  end;
end;

procedure TFrmMain.OnModernPlayClick(Sender: TObject);
begin
  mnuPlayPauseClick(Sender);
end;

procedure TFrmMain.OnModernMuteClick(Sender: TObject);
begin
  FMuted := not FMuted;
  if Assigned(btnMute) then
  begin
    btnMute.IsActive := FMuted;
    if FMuted then
      btnMute.IconKind := ikMute
    else
      btnMute.IconKind := ikVolume;
    btnMute.Invalidate;
  end;
  if Assigned(lblVolPctDisplay) then
  begin
    if FMuted then
      lblVolPctDisplay.Caption := 'MUTE'
    else
      lblVolPctDisplay.Caption := Format('%d%%', [modernVolumeSlider.Volume]);
  end;
  if FMuted then
    ShowOSD('Muted')
  else
    ShowOSD('Unmuted');

  if FMediaPlayer <> nil then
  begin
    try
      libvlc_audio_set_mute(FMediaPlayer, Ord(FMuted));
    except
    end;
  end;
end;

procedure TFrmMain.OnModernSpeedClick(Sender: TObject);
var
  CurRate, NewRate: Single;
begin
  if FMediaPlayer = nil then Exit;
  CurRate := libvlc_media_player_get_rate(FMediaPlayer);
  if CurRate < 0.70 then NewRate := 0.75
  else if CurRate < 0.90 then NewRate := 1.00
  else if CurRate < 1.15 then NewRate := 1.25
  else if CurRate < 1.40 then NewRate := 1.50
  else if CurRate < 1.80 then NewRate := 2.00
  else if CurRate < 2.50 then NewRate := 0.50
  else NewRate := 1.00;

  libvlc_media_player_set_rate(FMediaPlayer, NewRate);
  if Assigned(btnSpeed) then
    btnSpeed.BadgeText := Format('%.2gx', [NewRate]);
  ShowOSD(Format('Speed: %.2gx', [NewRate]));
end;

procedure TFrmMain.SetPlaylistVisible(Visible, Animate: Boolean);
begin
  FPlaylistTarget := Visible;
  mnuViewPlaylist.Checked := Visible;
  popPlaylist.Checked := Visible;
  btnPlaylistToggle.IsActive := Visible;
  if not Animate then
  begin
    FPlaylistAnimating := False;
    if Assigned(FPlaylistTimer) then FPlaylistTimer.Enabled := False;
    pnlPlaylist.Visible := Visible;
    RepositionModernControls;
    Exit;
  end;
  if not Assigned(FPlaylistTimer) then
  begin
    FPlaylistTimer := TTimer.Create(Self);
    FPlaylistTimer.Enabled := False;
    FPlaylistTimer.Interval := 16;
    FPlaylistTimer.OnTimer := PlaylistTick;
  end;
  if not pnlPlaylist.Visible then
  begin
    FPlaylistAnimating := True;
    pnlPlaylist.Left := pnlPlaylist.Parent.ClientWidth;
    pnlPlaylist.Visible := True;
  end;
  FPlaylistStartWidth := pnlPlaylist.Parent.ClientWidth - pnlPlaylist.Left;
  FPlaylistStartTick := GetTickCount64;
  FPlaylistAnimating := True;
  FPlaylistTimer.Enabled := True;
end;

procedure TFrmMain.PlaylistTick(Sender: TObject);
var
  Progress, Eased: Double;
  TargetWidth: Integer;
begin
  Progress := Min(1.0, (GetTickCount64 - FPlaylistStartTick) / 180.0);
  Eased := 1 - Power(1 - Progress, 3);
  if FPlaylistTarget then TargetWidth := MulDiv(280, CurrentPPI, 96) else TargetWidth := 0;
  pnlPlaylist.Left := pnlPlaylist.Parent.ClientWidth -
    Round(FPlaylistStartWidth + (TargetWidth - FPlaylistStartWidth) * Eased);
  pnlVideoContainer.Width := Max(1, pnlPlaylist.Left);
  if FIsFullscreen then RepositionModernControls;
  pnlPlaylist.BringToFront;
  if Progress >= 1 then
  begin
    FPlaylistTimer.Enabled := False;
    FPlaylistAnimating := False;
    pnlPlaylist.Visible := FPlaylistTarget;
    RepositionModernControls;
  end;
end;

procedure TFrmMain.OnModernPlaylistToggle(Sender: TObject);
begin
  SetPlaylistVisible(not FPlaylistTarget, True);
end;

procedure TFrmMain.OnModernRepeatClick(Sender: TObject);
begin
  case FLoopMode of
    lmOff:
    begin
      FLoopMode := lmLoopAll;
      if Assigned(btnRepeat) then
      begin
        btnRepeat.IconKind := ikRepeat;
        btnRepeat.IsActive := True;
        btnRepeat.Hint := 'Repeat: All';
      end;
      ShowOSD('Repeat: All');
    end;
    lmLoopAll:
    begin
      FLoopMode := lmLoopOne;
      if Assigned(btnRepeat) then
      begin
        btnRepeat.IconKind := ikRepeatOne;
        btnRepeat.IsActive := True;
        btnRepeat.Hint := 'Repeat: Current Track';
      end;
      ShowOSD('Repeat: Current Track');
    end;
    lmLoopOne:
    begin
      FLoopMode := lmOff;
      if Assigned(btnRepeat) then
      begin
        btnRepeat.IconKind := ikRepeat;
        btnRepeat.IsActive := False;
        btnRepeat.Hint := 'Repeat: Off';
      end;
      ShowOSD('Repeat: Off');
    end;
  end;
end;

procedure TFrmMain.OnTitleMinClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFrmMain.OnTitleMaxClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
  begin
    WindowState := wsNormal;
    if Assigned(btnTitleMax) then
      btnTitleMax.IconKind := ikMaximize;
  end
  else
  begin
    WindowState := wsMaximized;
    if Assigned(btnTitleMax) then
      btnTitleMax.IconKind := ikRestore;
  end;
  RepositionModernControls;
end;

procedure TFrmMain.OnTitleCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.AdjustVolume(Delta: Integer);
var
  NewVol: Integer;
begin
  if FPendingVolume >= 0 then NewVol := FPendingVolume
  else if FMediaPlayer <> nil then
    NewVol := libvlc_audio_get_volume(FMediaPlayer)
  else if modernVolumeSlider <> nil then
    NewVol := modernVolumeSlider.Volume
  else
    NewVol := 100;
  if NewVol < 0 then
    if Assigned(modernVolumeSlider) then NewVol := modernVolumeSlider.Volume else NewVol := 100;
  Inc(NewVol, Delta);

  if NewVol < 0 then NewVol := 0;
  if NewVol > 200 then NewVol := 200;

  if modernVolumeSlider <> nil then
    modernVolumeSlider.Volume := NewVol;

  OnModernVolumeChange(Self, NewVol);
end;

procedure TFrmMain.lstPlaylistDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  BgColor, PenColor: TGPColor;
  ItemText: string;
  TextRect: TRect;
  IsCurrent: Boolean;
begin
  ListBox := Control as TListBox;
  IsCurrent := (Index = FCurrentPlaylistIndex);

  ListBox.Canvas.Brush.Color := DP_COLOR_SURFACE;
  ListBox.Canvas.FillRect(Rect);

  G := TGPGraphics.Create(ListBox.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    if (odSelected in State) or (odFocused in State) then
    begin
      BgColor := MakeGDIColor(DP_COLOR_HOVER);     // Elevated #244457
      PenColor := MakeGDIColor(DP_COLOR_BORDER);     // Accent border #00AFA5
    end
    else
    begin
      BgColor := MakeGDIColor(DP_COLOR_SURFACE);     // Surface #1D3646
      PenColor := MakeGDIColor(DP_COLOR_SURFACE);    // Border #375263
    end;

    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(Rect.Left + 4, Rect.Top + 2, 8, 8, 180, 90);
      Path.AddArc(Rect.Right - 12, Rect.Top + 2, 8, 8, 270, 90);
      Path.AddArc(Rect.Right - 12, Rect.Bottom - 10, 8, 8, 0, 90);
      Path.AddArc(Rect.Left + 4, Rect.Bottom - 10, 8, 8, 90, 90);
      Path.CloseFigure;

      Brush := TGPSolidBrush.Create(BgColor);
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      Pen := TGPPen.Create(PenColor, 1.0);
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

    if IsCurrent then
    begin
      Brush := TGPSolidBrush.Create(MakeColor(255, 0, $AF, $A5));
      try
        G.FillEllipse(Brush, Rect.Left + 12, Rect.Top + (Rect.Height - 8) div 2, 8, 8);
      finally
        Brush.Free;
      end;
    end;

  finally
    G.Free;
  end;

  ListBox.Canvas.Brush.Style := bsClear;
  ListBox.Canvas.Font.Name := 'Segoe UI';
  ListBox.Canvas.Font.Size := 9;
  if IsCurrent then
  begin
    ListBox.Canvas.Font.Color := DP_COLOR_ACCENT;
    ListBox.Canvas.Font.Style := [fsBold];
  end
  else
  begin
    ListBox.Canvas.Font.Color := DP_COLOR_TEXT;
    ListBox.Canvas.Font.Style := [];
  end;

  TextRect := Rect;
  TextRect.Left := Rect.Left + 28;
  TextRect.Right := Rect.Right - 8;
  ItemText := ListBox.Items[Index];
  DrawTextW(ListBox.Canvas.Handle, PWideChar(ItemText), Length(ItemText), TextRect,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
end;

procedure UsePlayerColors(Control: TControl);
begin
  Control.StyleElements := [];
  if Control is TWinControl then
    for var I := 0 to TWinControl(Control).ControlCount - 1 do
      UsePlayerColors(TWinControl(Control).Controls[I]);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  PluginsDir: string;
begin
  GAppClosing:=False;
  ReloadPlayerPreferences;
  EnableDwmRoundedCorners(Handle);

  DragAcceptFiles(Handle, True);
  if Assigned(pnlVideo) then
  begin
    DragAcceptFiles(pnlVideo.Handle, True);
    FOldVideoWndProc := pnlVideo.WindowProc;
    pnlVideo.WindowProc := VideoDropWndProc;
  end;
  if Assigned(pnlVideoContainer) then
  begin
    DragAcceptFiles(pnlVideoContainer.Handle, True);
    FOldContainerWndProc := pnlVideoContainer.WindowProc;
    pnlVideoContainer.WindowProc := ContainerDropWndProc;
  end;
  if Assigned(lstPlaylist) then
  begin
    DragAcceptFiles(lstPlaylist.Handle, True);
    FOldPlaylistWndProc := lstPlaylist.WindowProc;
    lstPlaylist.WindowProc := PlaylistDropWndProc;
  end;
  if Assigned(pnlRoot) then
  begin
    DragAcceptFiles(pnlRoot.Handle, True);
    FOldRootWndProc := pnlRoot.WindowProc;
    pnlRoot.WindowProc := RootDropWndProc;
  end;
  FPlaylistPaths := TStringList.Create;
  FImports := TQueue<IMediaImport>.Create;
  FManualSubtitles := TStringList.Create;
  FGeneratedSubtitles := TStringList.Create;
  FPlaylistOptions := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);
  FCurrentPlaylistIndex := -1;
  FPendingVolume := -1;
  FPendingSeek := -1;
  FUpdatingTrackBar := False;
  FIsFullscreen := False;
  FLoopMode := lmOff;
  FMinimalMode := False;
  FATime := -1;
  FBTime := -1;
  FShownOnce := False;
  FPanScanZoom := 1.0;
  FPanScanX := 0;
  FPanScanY := 0;
  FAfterPlayback := FSettings.AfterPlayback;
  FIsBossHidden := False;
  FIsBorderless := False;
  FPreBossMuted := False;

  lblOSD.Visible := False;

  // Initialize Modern Interface
  InitModernPlayerUI;
  UsePlayerColors(Self);
  try
    Icon.Handle := LoadIcon(HInstance, 'MAINICON');
  except
  end;
  LoadSplashScreen;
  pnlRoot.ParentBackground := False;
  pnlVideoContainer.ParentBackground := False;
  pnlVideo.ParentBackground := False;
  pnlPlaylist.Visible := False;
  FPlaylistTarget := False;
  btnPlaylistToggle.IsActive := False;
  mnuViewPlaylist.Checked := False;
  popPlaylist.Checked := False;
  FUIReady := True;
  Constraints.MinWidth := MulDiv(900, CurrentPPI, 96);
  Constraints.MinHeight := MulDiv(480, CurrentPPI, 96);
  OnResize := FormResize;
  RepositionModernControls;
  UpdateRecentMediaMenu;

  try
    ApplyPendingComponents;
  except
    on E: Exception do PlayerMessage('Could not activate playback plugins: ' + E.Message);
  end;
  // Setup LibVLC
  PluginsDir := PlaybackPluginsPath;
  SetLibVLCPluginPath(PluginsDir);

  if not LoadLibVLC('') then
  begin
    PlayerMessage('Failed to load libvlc.dll! Make sure libvlc.dll, libvlccore.dll and plugins folder are next to the executable.');
    Exit;
  end;

  if PlaybackPluginsInstalled and not EnsurePlaybackEngine then
    ShowOSD('Playback could not start. Check Settings > Playback Components.');
  FPendingVolume := FSettings.StartupVolume;
  modernVolumeSlider.Volume := FSettings.StartupVolume;
  tbVolume.Position := FSettings.StartupVolume;

  PopulateThemesMenu(mnuThemes);
  PopulateThemesMenu(popThemes);
  InitEQPresetsMenu;

  if FSettings.RememberWindow then
  begin
    var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
    try
      var W := Store.ReadInteger('Window', 'Width', 0);
      var H := Store.ReadInteger('Window', 'Height', 0);
      var DPI := Max(96, Store.ReadInteger('Window', 'PPI', 96));
      W := MulDiv(W, CurrentPPI, DPI);
      H := MulDiv(H, CurrentPPI, DPI);
      if (W >= Constraints.MinWidth) and (H >= Constraints.MinHeight) and (W < 16000) and (H < 16000) then
      begin
        var X := Store.ReadInteger('Window', 'Left', Left);
        var Y := Store.ReadInteger('Window', 'Top', Top);
        var Work := Screen.MonitorFromRect(Rect(X, Y, X + W, Y + H)).WorkareaRect;
        Position := poDesigned;
        W:=Min(W,Work.Width); H:=Min(H,Work.Height);
        SetBounds(EnsureRange(X,Work.Left,Work.Right-W),EnsureRange(Y,Work.Top,Work.Bottom-H),W,H);
      end;
      if Store.ReadBool('Window', 'Maximized', False) then WindowState := wsMaximized;
    finally Store.Free; end;
  end;

  for var I := 1 to ParamCount do
  begin
    var P := ParamStr(I);
    if SameText(P, '/fullscreen') or SameText(P, '-fs') or SameText(P, '--fullscreen') then
      FSettings.StartFullscreen := True
    else if SameText(P, '/compact') or SameText(P, '/min') then
      ApplyLayoutPreset(1)
    else if SameText(P, '/pure') or SameText(P, '/minimal') then
      ApplyLayoutPreset(2)
    else if SameText(P, '/cap') or SameText(P, '/screen') then
      OpenScreenCapture
    else if StartsText('/volume=', P) then
    begin
      tbVolume.Position := EnsureRange(StrToIntDef(Copy(P, 9, MaxInt), 100), 0, 200);
      if FMediaPlayer <> nil then libvlc_audio_set_volume(FMediaPlayer, tbVolume.Position);
    end
    else if StartsText('/seek=', P) then
      FPendingResume := StrToInt64Def(Copy(P, 7, MaxInt), 0) * 1000
    else if StartsText('/sub=', P) then
    begin
      var SubPath := Trim(Copy(P, 6, MaxInt));
      if StartsStr('"', SubPath) and EndsStr('"', SubPath) then
        SubPath := Copy(SubPath, 2, Length(SubPath) - 2);
      if FileExists(SubPath) and (FMediaPlayer <> nil) then
        libvlc_video_set_subtitle_file(FMediaPlayer, PAnsiChar(UTF8Encode(SubPath)));
    end
    else if FileExists(P) or P.Contains('://') then
    begin
      FPlaylistPaths.Add(P);
      lstPlaylist.Items.Add(ExtractFileName(P));
    end;
  end;

  tmrUpdate.Enabled := True;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  PublishPlayerWindow(Handle);
  if not FShownOnce then
  begin
    FShownOnce := True;
    if not PlaybackPluginsInstalled and not TDirectory.Exists(
      PlayerDataPath('plugins.pending')) then
    begin
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try
        var Key := 'Prompted-' + THashSHA2.GetHashString(LowerCase(ExtractFilePath(ParamStr(0))));
        if not Store.ReadBool('RuntimeComponents', Key, False) then
        begin
          Store.WriteBool('RuntimeComponents', Key, True);
          TThread.ForceQueue(nil,
            procedure
            begin
              if not GAppClosing then ShowRuntimeComponents(Self);
            end);
        end;
      finally Store.Free; end;
    end;

    if Assigned(FTaskbarMgr) and not FTaskbarMgr.ButtonsAdded then
      FTaskbarMgr.InitButtons(Handle);

    // Attach HWND safely after window is fully rendered
    if (FMediaPlayer <> nil) and pnlVideo.HandleAllocated then
    begin
      try
        libvlc_media_player_set_hwnd(FMediaPlayer, Pointer(pnlVideo.Handle));
      except
      end;
    end;

    if FPlaylistPaths.Count > 0 then
      PlayMediaAtIndex(0);
    if FSettings.StartFullscreen then mnuFullscreenClick(nil);

    if not Assigned(FPreferencesWarmup) then
    begin
      FPreferencesWarmup := TTimer.Create(Self);
      FPreferencesWarmup.Interval := 100;
      FPreferencesWarmup.OnTimer := WarmPreferences;
      FPreferencesWarmup.Enabled := True;
    end;
  end;
end;


procedure TFrmMain.CopySnapshotToClipboard;
var
  TempDir, TempFile: string;
  Utf8Temp: UTF8String;
  Bmp: TBitmap;
  Png: TPngImage;
begin
  if FMediaPlayer = nil then Exit;
  TempDir := IncludeTrailingPathDelimiter(TPath.GetTempPath);
  TempFile := TempDir + Format('vlc_snap_%d_%d.png', [GetCurrentProcessId, GetTickCount]);
  Utf8Temp := UTF8Encode(TempFile);

  if libvlc_video_take_snapshot(FMediaPlayer, 0, PAnsiChar(Utf8Temp), 0, 0) = 0 then
  begin
    if FileExists(TempFile) then
    begin
      try
        Png := TPngImage.Create;
        try
          Png.LoadFromFile(TempFile);
          Bmp := TBitmap.Create;
          try
            Bmp.Assign(Png);
            Vcl.Clipbrd.Clipboard.Assign(Bmp);
            ShowOSD('Frame Copied to Clipboard');
          finally
            Bmp.Free;
          end;
        finally
          Png.Free;
        end;
      finally
        System.SysUtils.DeleteFile(TempFile);
      end;
    end
    else
      ShowOSD('Snapshot copy failed');
  end
  else
    ShowOSD('Snapshot copy failed');
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FClosing then
  begin
    CanClose := True;
    Exit;
  end;
  FClosing := True;
  GAppClosing := True;
  FUIReady := False;

  // 1. Immediately disable all active timers
  if Assigned(tmrUpdate) then tmrUpdate.Enabled := False;
  if Assigned(tmrOSD) then tmrOSD.Enabled := False;
  if Assigned(FPlaylistTimer) then FPlaylistTimer.Enabled := False;
  if Assigned(FPreferencesWarmup) then FPreferencesWarmup.Enabled := False;
  if Assigned(FVisualTimer) then FVisualTimer.Enabled := False;
  if Assigned(tmrClickPause) then tmrClickPause.Enabled := False;
  if Assigned(FFullscreenMouseTimer) then FFullscreenMouseTimer.Enabled := False;
  OnResize := nil;

  // 2. Detach video input and save playback / window state
  DetachVideoInput;
  SavePlaybackPosition;

  if FSettings.RememberWindow then
  begin
    var WindowStore := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
    try
      var SavedBounds := BoundsRect;
      var Maximized := WindowState = wsMaximized;
      if Maximized then
      begin
        var Placement: TWindowPlacement;
        Placement.length := SizeOf(Placement);
        if GetWindowPlacement(Handle, @Placement) then SavedBounds := Placement.rcNormalPosition;
      end;
      if FIsFullscreen then
      begin
        SavedBounds := FOldBounds;
        Maximized := FOldWindowState = wsMaximized;
      end;
      WindowStore.WriteInteger('Window', 'Left', SavedBounds.Left);
      WindowStore.WriteInteger('Window', 'Top', SavedBounds.Top);
      WindowStore.WriteInteger('Window', 'Width', SavedBounds.Width);
      WindowStore.WriteInteger('Window', 'Height', SavedBounds.Height);
      WindowStore.WriteInteger('Window', 'PPI', CurrentPPI);
      WindowStore.WriteBool('Window', 'Maximized', Maximized);
    finally WindowStore.Free; end;
  end;

  if FSettings.RememberVolume and Assigned(modernVolumeSlider) then
  begin
    var VolumeIni := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
    try VolumeIni.WriteInteger('Audio', 'LastVolume', modernVolumeSlider.Volume);
    finally VolumeIni.Free; end;
  end;

  FreeAndNil(FSeekDecoder);
  // 3. Stop LibVLC playback while windows are completely intact
  if FMediaPlayer <> nil then
  begin
    try
      libvlc_media_player_set_hwnd(FMediaPlayer, nil);
      libvlc_media_player_stop(FMediaPlayer);
      libvlc_media_player_release(FMediaPlayer);
    except
    end;
    FMediaPlayer := nil;
  end;

  if FCurrentMedia <> nil then
  begin
    try
      libvlc_media_release(FCurrentMedia);
    except
    end;
    FCurrentMedia := nil;
  end;

  if FVlcInstance <> nil then
  begin
    try
      libvlc_release(FVlcInstance);
    except
    end;
    FVlcInstance := nil;
  end;

  // 4. Detach drop file WindowProcs
  DragAcceptFiles(Handle, False);
  if Assigned(pnlVideo) then
  begin
    DragAcceptFiles(pnlVideo.Handle, False);
    if Assigned(FOldVideoWndProc) then
    begin
      pnlVideo.WindowProc := FOldVideoWndProc;
      FOldVideoWndProc := nil;
    end;
  end;
  if Assigned(pnlVideoContainer) then
  begin
    DragAcceptFiles(pnlVideoContainer.Handle, False);
    if Assigned(FOldContainerWndProc) then
    begin
      pnlVideoContainer.WindowProc := FOldContainerWndProc;
      FOldContainerWndProc := nil;
    end;
  end;
  if Assigned(lstPlaylist) then
  begin
    DragAcceptFiles(lstPlaylist.Handle, False);
    if Assigned(FOldPlaylistWndProc) then
    begin
      lstPlaylist.WindowProc := FOldPlaylistWndProc;
      FOldPlaylistWndProc := nil;
    end;
  end;
  if Assigned(pnlRoot) then
  begin
    DragAcceptFiles(pnlRoot.Handle, False);
    if Assigned(FOldRootWndProc) then
    begin
      pnlRoot.WindowProc := FOldRootWndProc;
      FOldRootWndProc := nil;
    end;
  end;

  ClosePlayerMenus;
  CloseAllOSDWindows;

  // 6. Safely release secondary dialogs while main form handle is still alive
  if Assigned(FrmEffects) then
  begin
    FrmEffects.Parent := nil;
    FreeAndNil(FrmEffects);
  end;
  FreeAndNil(FrmConvert);
  FreeAndNil(FrmMediaInfo);
  FreeAndNil(FrmBookmarks);
  FreeAndNil(FrmJumpTime);
  FreeAndNil(FrmPreferences);
  FreeAndNil(FrmOpenMedia);

  CanClose := True;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SavePlaybackResume;
  Action := caFree;
  Application.Terminate;
end;

procedure TFrmMain.WndProc(var Message: TMessage);
begin
  if FClosing or GAppClosing then
  begin
    case Message.Msg of
      WM_PAINT: begin ValidateRect(Handle, nil); Message.Result := 0; Exit; end;
      WM_NCPAINT, WM_NCACTIVATE, WM_ERASEBKGND, WM_SETTEXT,
      WM_ACTIVATE, WM_ACTIVATEAPP, WM_WINDOWPOSCHANGED, WM_WINDOWPOSCHANGING,
      WM_DWMCOMPOSITIONCHANGED, WM_DWMNCRENDERINGCHANGED, WM_DWMCOLORIZATIONCOLORCHANGED,
      CM_VISIBLECHANGED, CM_INVALIDATE, CM_COLORCHANGED:
      begin
        Message.Result := 0;
        Exit;
      end;
      WM_CLOSE, WM_DESTROY: ;
      else
      begin
        if (Message.Msg >= $0300) and (Message.Msg <= $0350) then
        begin
          Message.Result := 0;
          Exit;
        end;
      end;
    end;
  end;
  inherited WndProc(Message);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FClosing := True;
  GAppClosing := True;
  FUIReady := False;
  UnpublishPlayerWindow(Handle);

  if Assigned(FOldVideoWndProc) and Assigned(pnlVideo) then
  begin
    pnlVideo.WindowProc := FOldVideoWndProc;
    FOldVideoWndProc := nil;
  end;
  if Assigned(FOldContainerWndProc) and Assigned(pnlVideoContainer) then
  begin
    pnlVideoContainer.WindowProc := FOldContainerWndProc;
    FOldContainerWndProc := nil;
  end;
  if Assigned(FOldPlaylistWndProc) and Assigned(lstPlaylist) then
  begin
    lstPlaylist.WindowProc := FOldPlaylistWndProc;
    FOldPlaylistWndProc := nil;
  end;
  if Assigned(FOldRootWndProc) and Assigned(pnlRoot) then
  begin
    pnlRoot.WindowProc := FOldRootWndProc;
    FOldRootWndProc := nil;
  end;

  if Assigned(FVisualTimer) then FVisualTimer.Enabled := False;
  StopAudioRecording;
  StopVideoRecording;
  FreeAndNil(FWebRemote);
  FGPUShaderActive := False;
  ReleaseRenderers;
  FreeAndNil(FCustomHotkeys);
  FreeAndNil(FAudioMeter);
  FreeAndNil(FSeekDecoder);
  FreeAndNil(FTaskbarMgr);
  ClosePlayerMenus;
  CloseAllOSDWindows;

  FreeAndNil(FrmEffects);
  FreeAndNil(FrmConvert);
  FreeAndNil(FrmMediaInfo);
  FreeAndNil(FrmBookmarks);
  FreeAndNil(FrmJumpTime);
  FreeAndNil(FrmPreferences);
  FreeAndNil(FrmOpenMedia);

  if FMediaPlayer <> nil then
  begin
    try
      libvlc_media_player_stop(FMediaPlayer);
      libvlc_media_player_set_hwnd(FMediaPlayer, nil);
      libvlc_media_player_release(FMediaPlayer);
    except
    end;
    FMediaPlayer := nil;
  end;

  FreeAndNil(FGPUShader);

  if FCurrentMedia <> nil then
  begin
    try
      libvlc_media_release(FCurrentMedia);
    except
    end;
    FCurrentMedia := nil;
  end;

  if FVlcInstance <> nil then
  begin
    try
      libvlc_release(FVlcInstance);
    except
    end;
    FVlcInstance := nil;
  end;

  if Assigned(FImports) then
  begin
    for var Request in FImports do Request.Cancel;
    FImports.Free;
    FImports := nil;
  end;
  FreeAndNil(FManualSubtitles);
  if Assigned(FGeneratedSubtitles) then
  begin
    for var GeneratedPath in FGeneratedSubtitles do System.SysUtils.DeleteFile(GeneratedPath);
    FreeAndNil(FGeneratedSubtitles);
  end;
  FreeAndNil(FPlaylistPaths);
  FreeAndNil(FPlaylistOptions);
  if Assigned(FPlatformCacheFiles) then
  begin
    for var CachedFile in FPlatformCacheFiles do System.SysUtils.DeleteFile(CachedFile);
    FreeAndNil(FPlatformCacheFiles);
  end;
  UnloadLibVLC;
  if Assigned(FSplashBitmap) then
  begin
    FSplashBitmap.Free;
    FSplashBitmap := nil;
  end;
  PostQuitMessage(0);
end;

procedure TFrmMain.LoadSplashScreen;
var
  ResStream: TResourceStream;
  MemHandle: HGLOBAL;
  MemPtr: Pointer;
  Stream: IStream;
  TempBmp: TGPBitmap;
  G: TGPGraphics;
begin
  if Assigned(FSplashBitmap) then
  begin
    FSplashBitmap.Free;
    FSplashBitmap := nil;
  end;

  if FindResource(HInstance, PChar('SPLASH_SCREEN'), RT_RCDATA) = 0 then Exit;
  try
    ResStream := TResourceStream.Create(HInstance, 'SPLASH_SCREEN', RT_RCDATA);
    try
      MemHandle := GlobalAlloc(GMEM_MOVEABLE, ResStream.Size);
      if MemHandle = 0 then Exit;
      MemPtr := GlobalLock(MemHandle);
      if MemPtr <> nil then
      begin
        Move(ResStream.Memory^, MemPtr^, ResStream.Size);
        GlobalUnlock(MemHandle);
      end
      else
      begin
        GlobalFree(MemHandle);
        Exit;
      end;

      if Succeeded(CreateStreamOnHGlobal(MemHandle, True, Stream)) then
      begin
        TempBmp := TGPBitmap.Create(Stream);
        try
          if TempBmp.GetLastStatus = Ok then
          begin
            FSplashBitmap := TGPBitmap.Create(TempBmp.GetWidth, TempBmp.GetHeight, PixelFormat32bppARGB);
            G := TGPGraphics.Create(FSplashBitmap);
            try
              G.SetSmoothingMode(SmoothingModeAntiAlias);
              G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
              G.DrawImage(TempBmp, 0, 0, TempBmp.GetWidth, TempBmp.GetHeight);
            finally
              G.Free;
            end;
          end;
        finally
          TempBmp.Free;
          Stream := nil;
        end;
      end
      else GlobalFree(MemHandle);
    finally
      ResStream.Free;
    end;
  except
    on E: Exception do
      FSplashBitmap := nil;
  end;
end;

procedure TFrmMain.PaintVideoSplashScreen(DC: HDC; const ClientRect: TRect);
var
  W, H: Integer;
  MemDC: HDC;
  MemBmp, OldBmp: HBITMAP;
  G: TGPGraphics;
  SolidBrush: TGPSolidBrush;
  ImgW, ImgH, Scale, DrawW, DrawH, DrawX, DrawY: Single;
begin
  W := ClientRect.Right - ClientRect.Left;
  H := ClientRect.Bottom - ClientRect.Top;
  if (W <= 0) or (H <= 0) then Exit;

  MemDC := CreateCompatibleDC(DC);
  MemBmp := CreateCompatibleBitmap(DC, W, H);
  OldBmp := SelectObject(MemDC, MemBmp);
  try
    G := TGPGraphics.Create(MemDC);
    try
      SolidBrush := TGPSolidBrush.Create(MakeColor(255, 4, 18, 36));
      try
        G.FillRectangle(SolidBrush, 0, 0, W, H);
      finally
        SolidBrush.Free;
      end;

      if Assigned(FSplashBitmap) and (FSplashBitmap.GetLastStatus = Ok) then
      begin
        ImgW := FSplashBitmap.GetWidth;
        ImgH := FSplashBitmap.GetHeight;
        if (ImgW > 0) and (ImgH > 0) then
        begin
          Scale := Max(W / ImgW, H / ImgH);
          DrawW := ImgW * Scale;
          DrawH := ImgH * Scale;
          DrawX := (W - DrawW) / 2;
          DrawY := (H - DrawH) / 2;

          G.SetSmoothingMode(SmoothingModeAntiAlias);
          G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
          G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
          G.DrawImage(FSplashBitmap, DrawX, DrawY, DrawW, DrawH);
        end;
      end;
    finally
      G.Free;
    end;

    BitBlt(DC, 0, 0, W, H, MemDC, 0, 0, SRCCOPY);
  finally
    SelectObject(MemDC, OldBmp);
    DeleteObject(MemBmp);
    DeleteDC(MemDC);
  end;
end;

procedure TFrmMain.VideoDropWndProc(var Msg: TMessage);
var
  PS: TPaintStruct;
  PaintDC: HDC;
  IsPlaying: Boolean;
  State: libvlc_state_t;
begin
  if Msg.Msg = WM_DROPFILES then
  begin
    WMDropFiles(TWMDropFiles(Msg));
    Exit;
  end;

  IsPlaying := False;
  if (FMediaPlayer <> nil) and Assigned(libvlc_media_player_get_state) then
  begin
    State := libvlc_media_player_get_state(FMediaPlayer);
    IsPlaying := State in [libvlc_Opening, libvlc_Buffering, libvlc_Playing, libvlc_Paused];
  end;

  if (not IsPlaying) and (not FIsAudioOnly) and (FSplashBitmap <> nil) then
  begin
    if Msg.Msg = WM_ERASEBKGND then
    begin
      Msg.Result := 1;
      Exit;
    end
    else if Msg.Msg = WM_PAINT then
    begin
      PaintDC := BeginPaint(pnlVideo.Handle, PS);
      try
        PaintVideoSplashScreen(PaintDC, pnlVideo.ClientRect);
      finally
        EndPaint(pnlVideo.Handle, PS);
      end;
      Msg.Result := 0;
      Exit;
    end;
  end;

  if Assigned(FOldVideoWndProc) then
    FOldVideoWndProc(Msg);
end;

procedure TFrmMain.RootDropWndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_DROPFILES then WMDropFiles(TWMDropFiles(Msg))
  else if Assigned(FOldRootWndProc) then FOldRootWndProc(Msg);
end;

procedure TFrmMain.ContainerDropWndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_DROPFILES then
    WMDropFiles(TWMDropFiles(Msg))
  else if Assigned(FOldContainerWndProc) then
    FOldContainerWndProc(Msg);
end;

procedure TFrmMain.PlaylistDropWndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_DROPFILES then
    WMDropFiles(TWMDropFiles(Msg))
  else if Assigned(FOldPlaylistWndProc) then
    FOldPlaylistWndProc(Msg);
end;

procedure TFrmMain.OnTimeDisplayClick(Sender: TObject);
begin
  FShowRemainingTime := not FShowRemainingTime;
  if (FMediaPlayer <> nil) and Assigned(libvlc_media_player_get_time) and Assigned(libvlc_media_player_get_length) then
  begin
    var CurTime := libvlc_media_player_get_time(FMediaPlayer);
    var TotalLen := libvlc_media_player_get_length(FMediaPlayer);
    if Assigned(lblTimeDisplay) then
    begin
      if FShowRemainingTime and (TotalLen > CurTime) then
        lblTimeDisplay.Caption := Format('%s / -%s', [FormatTime(CurTime), FormatTime(TotalLen - CurTime)])
      else
        lblTimeDisplay.Caption := Format('%s / %s', [FormatTime(CurTime), FormatTime(TotalLen)]);
    end;
  end;
end;


procedure TFrmMain.NextChapter;
var
  Count, Cur: Integer;
begin
  if (FMediaPlayer = nil) or not Assigned(libvlc_media_player_get_chapter_count) then
  begin
    mnuNextClick(nil);
    Exit;
  end;
  Count := libvlc_media_player_get_chapter_count(FMediaPlayer);
  if Count > 0 then
  begin
    Cur := -1;
    if Assigned(libvlc_media_player_get_chapter) then
      Cur := libvlc_media_player_get_chapter(FMediaPlayer);
    if (Cur + 1 < Count) and Assigned(libvlc_media_player_next_chapter) then
    begin
      libvlc_media_player_next_chapter(FMediaPlayer);
      ShowOSD(Format('Next Chapter (%d / %d)', [Cur + 2, Count]));
    end
    else
      mnuNextClick(nil);
  end
  else
    mnuNextClick(nil);
end;

procedure TFrmMain.PreviousChapter;
var
  Count, Cur: Integer;
begin
  if (FMediaPlayer = nil) or not Assigned(libvlc_media_player_get_chapter_count) then
  begin
    mnuPreviousClick(nil);
    Exit;
  end;
  Count := libvlc_media_player_get_chapter_count(FMediaPlayer);
  if Count > 0 then
  begin
    Cur := -1;
    if Assigned(libvlc_media_player_get_chapter) then
      Cur := libvlc_media_player_get_chapter(FMediaPlayer);
    if (Cur > 0) and Assigned(libvlc_media_player_previous_chapter) then
    begin
      libvlc_media_player_previous_chapter(FMediaPlayer);
      ShowOSD(Format('Previous Chapter (%d / %d)', [Cur, Count]));
    end
    else
      mnuPreviousClick(nil);
  end
  else
    mnuPreviousClick(nil);
end;

procedure TFrmMain.EnsureVideoAdjustEnabled;
begin
  if (FMediaPlayer <> nil) and Assigned(libvlc_video_get_adjust_int) and Assigned(libvlc_video_set_adjust_int) then
  begin
    if libvlc_video_get_adjust_int(FMediaPlayer, libvlc_adjust_Enable) = 0 then
      libvlc_video_set_adjust_int(FMediaPlayer, libvlc_adjust_Enable, 1);
  end;
end;

procedure TFrmMain.PlayNextFileInFolder;
var
  Dir, CurName, Ext: string;
  Files: TStringList;
  SearchRec: TSearchRec;
  Idx: Integer;
begin
  if (FCurrentFile = '') or (Pos('://', FCurrentFile) > 0) or not FileExists(FCurrentFile) then Exit;
  Dir := IncludeTrailingPathDelimiter(ExtractFilePath(FCurrentFile));
  CurName := ExtractFileName(FCurrentFile);
  Files := TStringList.Create;
  try
    Files.Sorted := True;
    Files.Duplicates := dupIgnore;
    if FindFirst(Dir + '*.*', faAnyFile and not faDirectory, SearchRec) = 0 then
    begin
      try
        repeat
          Ext := LowerCase(ExtractFileExt(SearchRec.Name));
          if MatchText(Ext, ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.ts', '.m2ts', '.vob',
                             '.3gp', '.mpg', '.mpeg', '.ogv', '.mp3', '.flac', '.wav', '.aac', '.m4a', '.ogg',
                             '.wma', '.opus', '.alac', '.aiff', '.ape']) then
            Files.Add(SearchRec.Name);
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;

    Idx := Files.IndexOf(CurName);
    if (Idx >= 0) and (Idx < Files.Count - 1) then
    begin
      PlayFile(Dir + Files[Idx + 1]);
      ShowOSD('Next File: ' + Files[Idx + 1]);
    end
    else if Idx = Files.Count - 1 then
      ShowOSD('End of folder');
  finally
    Files.Free;
  end;
end;

procedure TFrmMain.PlayPrevFileInFolder;
var
  Dir, CurName, Ext: string;
  Files: TStringList;
  SearchRec: TSearchRec;
  Idx: Integer;
begin
  if (FCurrentFile = '') or (Pos('://', FCurrentFile) > 0) or not FileExists(FCurrentFile) then Exit;
  Dir := IncludeTrailingPathDelimiter(ExtractFilePath(FCurrentFile));
  CurName := ExtractFileName(FCurrentFile);
  Files := TStringList.Create;
  try
    Files.Sorted := True;
    Files.Duplicates := dupIgnore;
    if FindFirst(Dir + '*.*', faAnyFile and not faDirectory, SearchRec) = 0 then
    begin
      try
        repeat
          Ext := LowerCase(ExtractFileExt(SearchRec.Name));
          if MatchText(Ext, ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.ts', '.m2ts', '.vob',
                             '.3gp', '.mpg', '.mpeg', '.ogv', '.mp3', '.flac', '.wav', '.aac', '.m4a', '.ogg',
                             '.wma', '.opus', '.alac', '.aiff', '.ape']) then
            Files.Add(SearchRec.Name);
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;

    Idx := Files.IndexOf(CurName);
    if Idx > 0 then
    begin
      PlayFile(Dir + Files[Idx - 1]);
      ShowOSD('Previous File: ' + Files[Idx - 1]);
    end
    else if Idx = 0 then
      ShowOSD('Start of folder');
  finally
    Files.Free;
  end;
end;

procedure TFrmMain.ReopenLastClosedFile;
var
  Ini: TAppSettings;
  List: TStringList;
  Path: string;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  List := TStringList.Create;
  try
    Ini.ReadSectionValues('RecentMedia', List);
    if List.Count > 0 then
    begin
      Path := List.ValueFromIndex[0];
      if (Path <> '') and (FileExists(Path) or (Pos('://', Path) > 0)) then
      begin
        PlayFile(Path);
        ShowOSD('Reopened: ' + ExtractFileName(Path));
      end;
    end
    else
      ShowOSD('No recent media to reopen');
  finally
    List.Free;
    Ini.Free;
  end;
end;

procedure TFrmMain.CycleAudioTrack;
var
  Tracks, Cur: Plibvlc_track_description_t;
  CurId, NextId, FirstId: Integer;
  FoundCurrent: Boolean;
  TrackName: string;
begin
  if (FMediaPlayer = nil) or not Assigned(libvlc_audio_get_track_description) or not Assigned(libvlc_audio_set_track) then Exit;
  CurId := -1;
  if Assigned(libvlc_audio_get_track) then
    CurId := libvlc_audio_get_track(FMediaPlayer);
  Tracks := libvlc_audio_get_track_description(FMediaPlayer);
  if Tracks = nil then Exit;
  try
    Cur := Tracks;
    FirstId := -1;
    NextId := -1;
    FoundCurrent := False;
    TrackName := '';
    while Cur <> nil do
    begin
      if FirstId = -1 then FirstId := Cur^.i_id;
      if FoundCurrent then
      begin
        NextId := Cur^.i_id;
        if Cur^.psz_name <> nil then TrackName := UTF8ToString(Cur^.psz_name);
        Break;
      end;
      if Cur^.i_id = CurId then
        FoundCurrent := True;
      Cur := Cur^.p_next;
    end;
    if NextId = -1 then
    begin
      NextId := FirstId;
      if (Tracks <> nil) and (Tracks^.psz_name <> nil) then
        TrackName := UTF8ToString(Tracks^.psz_name);
    end;
    if NextId <> -1 then
    begin
      libvlc_audio_set_track(FMediaPlayer, NextId);
      if TrackName = '' then TrackName := Format('Track %d', [NextId]);
      ShowOSD('Audio Track: ' + TrackName);
    end;
  finally
    if Assigned(libvlc_track_description_list_release) then
      libvlc_track_description_list_release(Tracks);
  end;
end;

procedure TFrmMain.CycleAudioChannel;
const
  ChannelNames: array[1..5] of string = ('Stereo', 'Reverse Stereo', 'Left Only', 'Right Only', 'Dolby Surround');
var
  Cur, NextCh: Integer;
  Store: TAppSettings;
begin
  if FMediaPlayer = nil then Exit;
  Cur := FSettings.ChannelMode;
  if (Cur < 1) or (Cur > 5) then
  begin
    if Assigned(libvlc_audio_get_channel) then
      Cur := libvlc_audio_get_channel(FMediaPlayer)
    else
      Cur := 1;
  end;
  NextCh := Cur + 1;
  if (NextCh < 1) or (NextCh > 5) then NextCh := 1;

  FSettings.ChannelMode := NextCh;
  Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteInteger('Audio', 'ChannelMode', NextCh);
  finally
    Store.Free;
  end;

  if Assigned(libvlc_audio_set_channel) then
  begin
    if libvlc_audio_set_channel(FMediaPlayer, NextCh) = 0 then
      FAudioPreferencesApplied := True;
  end;
  ShowOSD('Audio Channel: ' + ChannelNames[NextCh]);
end;

procedure TFrmMain.CycleSubtitleTrack;
var
  Tracks, Cur: Plibvlc_track_description_t;
  CurId, NextId, FirstId: Integer;
  FoundCurrent: Boolean;
  SubName: string;
begin
  if (FMediaPlayer = nil) or not Assigned(libvlc_video_get_spu_description) or not Assigned(libvlc_video_set_spu) then Exit;
  CurId := -1;
  if Assigned(libvlc_video_get_spu) then
    CurId := libvlc_video_get_spu(FMediaPlayer);
  Tracks := libvlc_video_get_spu_description(FMediaPlayer);
  if Tracks = nil then Exit;
  try
    Cur := Tracks;
    FirstId := -1;
    NextId := -1;
    FoundCurrent := False;
    SubName := '';
    while Cur <> nil do
    begin
      if FirstId = -1 then FirstId := Cur^.i_id;
      if FoundCurrent then
      begin
        NextId := Cur^.i_id;
        if Cur^.psz_name <> nil then SubName := UTF8ToString(Cur^.psz_name);
        Break;
      end;
      if Cur^.i_id = CurId then
        FoundCurrent := True;
      Cur := Cur^.p_next;
    end;
    if NextId = -1 then
    begin
      NextId := FirstId;
      if (Tracks <> nil) and (Tracks^.psz_name <> nil) then
        SubName := UTF8ToString(Tracks^.psz_name);
    end;
    if NextId <> -1 then
    begin
      libvlc_video_set_spu(FMediaPlayer, NextId);
      if SubName = '' then SubName := Format('Subtitle %d', [NextId]);
      ShowOSD('Subtitle: ' + SubName);
    end;
  finally
    if Assigned(libvlc_track_description_list_release) then
      libvlc_track_description_list_release(Tracks);
  end;
end;

procedure TFrmMain.CycleAspectRatio;
const
  Ratios: array[0..7] of string = ('Default', '16:9', '4:3', '16:10', '21:9', '2.35:1', '2.39:1', '1:1');
var
  CurRatio: string;
  I, NextIdx: Integer;
begin
  CurRatio := FSettings.AspectRatio;
  if CurRatio = '' then CurRatio := 'Default';
  NextIdx := 0;
  for I := 0 to High(Ratios) do
  begin
    if SameText(Ratios[I], CurRatio) then
    begin
      NextIdx := (I + 1) mod Length(Ratios);
      Break;
    end;
  end;
  ApplyAspectRatio(Ratios[NextIdx]);
  if Assigned(cboAspect) then cboAspect.Text := Ratios[NextIdx];
end;

procedure TFrmMain.ToggleDeinterlace;
const
  Modes: array[0..4] of string = ('', 'yadif', 'yadif2x', 'bob', 'linear');
  ModeLabels: array[0..4] of string = ('OFF', 'yadif (1x)', 'yadif2x', 'bob', 'linear');
var
  CurMode, NextMode: Integer;
  Store: TAppSettings;
begin
  if FMediaPlayer = nil then Exit;
  CurMode := FSettings.Deinterlace;
  if (CurMode < 0) or (CurMode > 4) then CurMode := 0;
  NextMode := (CurMode + 1) mod 5;
  FSettings.Deinterlace := NextMode;

  if NextMode = 0 then
    libvlc_video_set_deinterlace(FMediaPlayer, nil)
  else
    libvlc_video_set_deinterlace(FMediaPlayer, PAnsiChar(AnsiString(Modes[NextMode])));

  ShowOSD('Deinterlace: ' + ModeLabels[NextMode]);

  Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteInteger('Video', 'Deinterlace', NextMode);
  finally
    Store.Free;
  end;
end;

procedure TFrmMain.CycleCropGeometry;
const
  Crops: array[0..5] of string = ('Default', '16:9', '4:3', '16:10', '2.21:1', '2.35:1');
var
  CurCrop: string;
  I, NextIdx: Integer;
  Store: TAppSettings;
begin
  if FMediaPlayer = nil then Exit;
  CurCrop := FSettings.Crop;
  if CurCrop = '' then CurCrop := 'Default';
  NextIdx := 0;
  for I := 0 to High(Crops) do
  begin
    if SameText(Crops[I], CurCrop) then
    begin
      NextIdx := (I + 1) mod Length(Crops);
      Break;
    end;
  end;
  FSettings.Crop := Crops[NextIdx];
  Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteString('Video', 'Crop', FSettings.Crop);
  finally
    Store.Free;
  end;
  if Crops[NextIdx] = 'Default' then
    libvlc_video_set_crop_geometry(FMediaPlayer, nil)
  else
    libvlc_video_set_crop_geometry(FMediaPlayer, PAnsiChar(AnsiString(Crops[NextIdx])));
  ShowOSD('Crop: ' + Crops[NextIdx]);
end;

procedure TFrmMain.QueueMediaFiles(const Sources: TStrings);
begin
  if not FClosing and Assigned(FImports) and (Sources.Count > 0) then FImports.Enqueue(ImportMedia(Sources));
end;

procedure TFrmMain.ProcessMediaImports;
var Paths, Subtitles: TStringList;
begin
  if not Assigned(FImports) then Exit;
  while (FImports.Count > 0) and FImports.Peek.Finished do
  begin
    var Request := FImports.Dequeue;
    Paths := Request.CopyPaths;
    Subtitles := TStringList.Create;
    try
      var First := FPlaylistPaths.Count;
      lstPlaylist.Items.BeginUpdate;
      try
        for var Path in Paths do
          if MatchText(LowerCase(ExtractFileExt(Path)), ['.srt', '.ass', '.ssa', '.vtt', '.sub', '.idx']) then
            Subtitles.Add(Path)
          else
          begin
            FPlaylistPaths.Add(Path);
            lstPlaylist.Items.Add(ExtractFileName(Path));
          end;
      finally lstPlaylist.Items.EndUpdate; end;
      if (FPlaylistPaths.Count > First) and ((FCurrentPlaylistIndex < 0) or
          not (libvlc_media_player_get_state(FMediaPlayer) in [libvlc_Playing, libvlc_Paused])) then
        PlayMediaAtIndex(First);
      FManualSubtitles.AddStrings(Subtitles);
      if Request.ErrorText <> '' then ShowOSD(Request.ErrorText)
      else if Paths.Count = 0 then ShowOSD('No playable media found in the dropped source.');
    finally Subtitles.Free; Paths.Free; end;
  end;
end;

procedure TFrmMain.WMDropFiles(var Msg: TWMDropFiles);
var Sources: TStringList; Path: string; Len: Integer;
begin
  Sources := TStringList.Create;
  try
    try
      for var I := 0 to Integer(DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0)) - 1 do
      begin
        Len := DragQueryFile(Msg.Drop, I, nil, 0);
        if Len = 0 then Continue;
        SetLength(Path, Len);
        DragQueryFile(Msg.Drop, I, PChar(Path), Len + 1);
        Sources.Add(Path);
      end;
    finally DragFinish(Msg.Drop); end;
    QueueMediaFiles(Sources);
  finally Sources.Free; end;
end;

function TFrmMain.SeekPreviewStatus:string;
begin
  if FSeekDecoder=nil then Result:='no decoder' else Result:=FSeekDecoder.DiagnosticState;
end;

procedure TFrmMain.ShowOSD(const AText: string);
begin
  if (AText = '') or FClosing or not FSettings.ShowOSD or FSuppressTransientOSD then Exit;
  if not FSettings.ShowSpeedOSD and StartsText('Speed:', AText) then Exit;
  ShowVideoTextOSD(pnlVideo, AText);
  if Assigned(lblOSD) then lblOSD.Visible := False;
end;

function PreferencesStamp:string;
const Sections:array[0..7] of string=('General','Interface','Playback','Video','Audio','Subtitles','Network','Associations');
var Store:TAppSettings; Values:TStringList;
begin
  Result:=''; Store:=TAppSettings.Create(ExtractFilePath(ParamStr(0))+'VLCModern.ini');
  Values:=TStringList.Create;
  try
    for var Section in Sections do
    begin
      Values.Clear; Store.ReadSectionValues(Section,Values); Values.Sort;
      Result:=Result+Section+#10+Values.Text;
    end;
  finally Values.Free; Store.Free; end;
end;

procedure TFrmMain.ReloadPlayerPreferences;
begin
  FSettings := TPlayerSettings.Load(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  FPreferencesDirty:=FPreferencesStamp<>PreferencesStamp;
  if FPreferencesDirty and (FPreferencesWarmup<>nil) then FPreferencesWarmup.Enabled:=True;
  ConfigureTextOSD(FSettings.OSDDuration, FSettings.OSDFontSize);
  FVideoPreferencesApplied := False;
  FAudioPreferencesApplied := False;
  FAfterPlayback := FSettings.AfterPlayback;
end;

function TFrmMain.EnsurePlaybackEngine: Boolean;
var Args: TArray<PAnsiChar>; Key: string; NewInstance: Plibvlc_instance_t;
    NewPlayer: Plibvlc_media_player_t; Volume, Muted: Integer;
begin
  var Options := FSettings.EngineOptions;
  Key := '';
  SetLength(Args, Length(Options));
  for var I := 0 to High(Options) do
  begin
    Args[I] := PAnsiChar(Options[I]);
    Key := Key + UTF8ToString(Options[I]) + #10;
  end;
  if (FMediaPlayer <> nil) and (Key = FEngineOptionsKey) then Exit(True);
  Result := False;
  NewInstance := libvlc_new(Length(Args), @Args[0]);
  if NewInstance = nil then Exit;
  NewPlayer := libvlc_media_player_new(NewInstance);
  if NewPlayer = nil then
  begin libvlc_release(NewInstance); Exit; end;
  Volume := FSettings.StartupVolume;
  Muted := 0;
  if FMediaPlayer <> nil then
  begin
    Volume := libvlc_audio_get_volume(FMediaPlayer);
    if Volume < 0 then Volume := FSettings.StartupVolume;
    Muted := libvlc_audio_get_mute(FMediaPlayer);
  end;
  FreeAndNil(FSeekDecoder);
  if FMediaPlayer <> nil then libvlc_media_player_release(FMediaPlayer);
  if FVlcInstance <> nil then libvlc_release(FVlcInstance);
  FVlcInstance := NewInstance;
  FMediaPlayer := NewPlayer;
  if FGPUShaderActive and Assigned(FGPUShader) then FGPUShader.AttachToPlayer(FMediaPlayer);
  FEngineOptionsKey := Key;
  libvlc_video_set_mouse_input(FMediaPlayer, 0);
  libvlc_video_set_key_input(FMediaPlayer, 0);
  libvlc_audio_set_mute(FMediaPlayer, Ord(Muted = 1));
  FPendingVolume := Volume;
  Result := True;
end;

procedure TFrmMain.ApplyAudioEffects;
var
  Time: Int64;
  Paused: Boolean;
  Source: string;
begin
  ReloadPlayerPreferences;
  if (FMediaPlayer = nil) or (FCurrentMedia = nil) then Exit;
  if not (libvlc_media_player_get_state(FMediaPlayer) in [libvlc_Playing, libvlc_Paused]) then Exit;
  Time := libvlc_media_player_get_time(FMediaPlayer);
  Paused := libvlc_media_player_get_state(FMediaPlayer) = libvlc_Paused;
  Source := FCurrentFile;
  PlayFile(Source);
  FPendingResume := 0;
  if (Time > 0) and not Source.Contains('://') then SeekTo(Time);
  if Paused then libvlc_media_player_set_pause(FMediaPlayer, 1);
end;

procedure TFrmMain.JumpSeconds(Seconds: Integer);
var Current, Target, Duration: Int64;
begin
  if FMediaPlayer = nil then Exit;
  if FPendingSeek >= 0 then Current := FPendingSeek
  else Current := Max(Int64(0), libvlc_media_player_get_time(FMediaPlayer));
  Target := Max(Int64(0), Current + Int64(Seconds) * 1000);
  Duration := libvlc_media_player_get_length(FMediaPlayer);
  if Duration > 0 then Target := Min(Target, Duration);
  SeekTo(Target);
  ShowOSD(Format('%s%d s   %s', [IfThen(Target >= Current, '+', ''), (Target - Current) div 1000, FormatTime(Target)]));
end;

procedure TFrmMain.tmrOSDTimer(Sender: TObject);
begin
  tmrOSD.Enabled := False;
  lblOSD.Visible := False;
end;

function TFrmMain.FormatTime(AMilliseconds: Int64): string;
var
  TotalSec, H, M, S: Int64;
begin
  if AMilliseconds < 0 then AMilliseconds := 0;
  TotalSec := AMilliseconds div 1000;
  H := TotalSec div 3600;
  M := (TotalSec mod 3600) div 60;
  S := TotalSec mod 60;
  if H > 0 then
    Result := Format('%.2d:%.2d:%.2d', [H, M, S])
  else
    Result := Format('%.2d:%.2d', [M, S]);
end;

procedure TFrmMain.PlayFile(const AFilePath: string; AOptions: TStrings;
  const SourceURL: string);
var
  Utf8Path: UTF8String;
  Ini: TAppSettings;
  SavedTime: Int64;
  ResumeMode: Integer;
  StoredOptions: TStringList;
begin
  if not SameText(AFilePath, FCurrentFile) then FLocalRecordingFile := '';
  if not PlaybackPluginsInstalled then
  begin
    ShowOSD('Install playback plugins in Settings > Playback Components.');
    Exit;
  end;
  if not EnsurePlaybackEngine then
  begin
    ShowOSD('Playback could not start. Check Settings > Playback Components.');
    Exit;
  end;

  if (Pos('://', AFilePath) = 0) and not FileExists(AFilePath) then
  begin
    ShowOSD('File not found: ' + ExtractFileName(AFilePath));
    Exit;
  end;
  Inc(FPlatformRequest);
  if (SourceURL = '') and TYtDlpResolver.IsSupportedSiteUrl(AFilePath) then
  begin
    var Request := FPlatformRequest;
    ShowOSD('Preparing video via yt-dlp...');
    var OrigUrl := AFilePath;
    TYtDlpResolver.ResolveAsync(OrigUrl,
      procedure(const DirectUrl, VideoTitle, UserAgent, ErrorMsg: string; Success: Boolean)
      begin
        var IsCached := Success and FileExists(DirectUrl);
        if GAppClosing or (Request <> FPlatformRequest) then
        begin
          if IsCached then System.SysUtils.DeleteFile(DirectUrl);
          Exit;
        end;
        if Success and (DirectUrl <> '') then
        begin
          if IsCached then
          begin
            if FPlatformCacheFiles = nil then FPlatformCacheFiles := TStringList.Create;
            FPlatformCacheFiles.Add(DirectUrl);
            AddRecentMedia(OrigUrl);
          end;
          var StreamOptions := TStringList.Create;
          try
            if UserAgent <> '' then StreamOptions.Add(':http-user-agent=' + UserAgent);
            PlayFile(DirectUrl, StreamOptions, OrigUrl);
          finally
            StreamOptions.Free;
          end;
          if VideoTitle <> '' then
          begin
            if Assigned(modernTitleBar) then
              modernTitleBar.TitleText := 'VLC Modern - ' + VideoTitle;
            Caption := 'VLC Modern - ' + VideoTitle;
            ShowOSD('Playing: ' + VideoTitle);
          end;
        end
        else
          ShowOSD('yt-dlp: ' + ErrorMsg);
      end);
    Exit;
  end;
  OnSeekBarLeave(nil);
  FManualSubtitles.Clear;
  if AOptions <> nil then
  begin
    StoredOptions := TStringList.Create;
    StoredOptions.Assign(AOptions);
    FPlaylistOptions.AddOrSetValue(AFilePath, StoredOptions);
  end;
  SavePlaybackPosition;
  AttachVideoInput(Handle, pnlVideo.Handle);

  if FCurrentMedia <> nil then
  begin
    try
      libvlc_media_player_stop(FMediaPlayer);
      libvlc_media_release(FCurrentMedia);
    except
    end;
    FCurrentMedia := nil;
  end;

  if Assigned(FPlatformCacheFiles) and not SameText(FCurrentFile, AFilePath) then
  begin
    var CacheIndex := FPlatformCacheFiles.IndexOf(FCurrentFile);
    if (CacheIndex >= 0) and System.SysUtils.DeleteFile(FCurrentFile) then
      FPlatformCacheFiles.Delete(CacheIndex);
  end;

  FPendingResume := 0;
  FPendingSeek := -1;
  if not EnsurePlaybackEngine then
  begin
    ShowOSD('The selected playback settings could not initialize.');
    Exit;
  end;
  FPlaybackStarted := False;
  FOpeningSkipped := False;
  FEndingSkipped := False;
  FAudioPreferencesApplied := False;
  FPlaybackFailed := False;
  FVideoPreferencesApplied := False;
  if not SameText(FCurrentFile, AFilePath) then FPrimarySubtitlePath := '';
  FCurrentFile := AFilePath;
  var DisplayPath := AFilePath;
  if SourceURL <> '' then DisplayPath := SourceURL;
  AddRecentMedia(DisplayPath);
  GlobalLog('Playback started: ' + DisplayPath);
  FATime := -1;
  FBTime := -1;

  Utf8Path := UTF8Encode(AFilePath);

  if Pos('://', AFilePath) > 0 then
    FCurrentMedia := libvlc_media_new_location(FVlcInstance, PAnsiChar(Utf8Path))
  else
    FCurrentMedia := libvlc_media_new_path(FVlcInstance, PAnsiChar(Utf8Path));

  if FCurrentMedia <> nil then
  begin
    try
      // Re-verify HWND is cleanly attached before playback
      if pnlVideo.HandleAllocated and not FGPUShaderActive then
        libvlc_media_player_set_hwnd(FMediaPlayer, Pointer(pnlVideo.Handle));

      if not Assigned(FrmEffects) and (FSettings.Equalizer or FSettings.VideoAdjust) then
        FrmEffects := TFrmEffects.Create(Self);
      var StreamAgent := '';
      if FPlaylistOptions.TryGetValue(AFilePath, StoredOptions) then
        for var Option in StoredOptions do
          if Option.StartsWith(':http-user-agent=') then
            StreamAgent := Copy(Option, Length(':http-user-agent=') + 1, MaxInt);
      FSettings.ApplyMedia(FCurrentMedia, AFilePath.Contains('://'), StreamAgent);
      case FSettings.AudioOutput of
        0, 1: libvlc_audio_output_set(FMediaPlayer, 'mmdevice');
        2: libvlc_audio_output_set(FMediaPlayer, 'directsound');
        3: libvlc_audio_output_set(FMediaPlayer, 'waveout');
      end;

      if FPlaylistOptions.TryGetValue(AFilePath, StoredOptions) then
        for var Option in StoredOptions do
        begin
          if Option.StartsWith(':http-user-agent=') then Continue;
          var Utf8Option := UTF8Encode(Option);
          libvlc_media_add_option(FCurrentMedia, PAnsiChar(Utf8Option));
        end;
      libvlc_media_player_set_media(FMediaPlayer, FCurrentMedia);
      if FSettings.AudioDeviceID <> '' then
      begin
        var DeviceID := UTF8Encode(FSettings.AudioDeviceID);
        libvlc_audio_output_device_set(FMediaPlayer, nil, PAnsiChar(DeviceID));
      end;
      if libvlc_media_player_play(FMediaPlayer) <> 0 then
      begin
        FPlaybackFailed := True;
        ShowOSD('Unable to play this media. Check the file or stream address.');
        Exit;
      end;

      if Assigned(FrmEffects) then
        FrmEffects.InitializeWithPlayer;

      var Ext := LowerCase(ExtractFileExt(AFilePath));
      var IsAudio := (Ext = '.mp3') or (Ext = '.flac') or (Ext = '.wav') or
                     (Ext = '.ogg') or (Ext = '.m4a') or (Ext = '.aac') or
                     (Ext = '.wma') or (Ext = '.opus') or (Ext = '.alac') or
                     (Ext = '.aiff') or (Ext = '.ape') or (Ext = '.mid');
      if IsAudio then
        SwitchToAudioMode(AFilePath)
      else
        SwitchToVideoMode;


      if Assigned(FTaskbarMgr) then
        FTaskbarMgr.UpdatePlayState(Handle, True);

      if Assigned(btnPlay) then
      begin
        btnPlay.IconKind := ikPause;
        btnPlay.Hint := 'Pause (Space)';
      end;
      if Assigned(modernTitleBar) then
        modernTitleBar.TitleText := 'VLC Modern - ' + ExtractFileName(AFilePath);
      Caption := 'VLC Modern - ' + ExtractFileName(AFilePath);
      if FSettings.ShowFilename then ShowOSD('Playing: ' + ExtractFileName(AFilePath));

      // Resume playback check
      if not AFilePath.Contains('://') then
      begin
        var ResumeState: TFilePlaybackState;
        if ResumeStore.LoadState(AFilePath, ResumeState) and (ResumeState.Position > 15000) and (FSettings.ResumeMode <> 2) then
        begin
          if FSettings.ResumeMode = 0 then
            FPendingResume := ResumeState.Position
          else
            FPendingResume := -ResumeState.Position;
        end
        else
        begin
          Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
          try
            ResumeMode := FSettings.ResumeMode;
            SavedTime := Ini.ReadInteger('Positions', ExtractFileName(AFilePath), 0);
            if (SavedTime > 15000) and (ResumeMode <> 2) then
            begin
              if ResumeMode = 0 then
                FPendingResume := SavedTime
              else
                FPendingResume := -SavedTime;
            end;
          finally
            Ini.Free;
          end;
        end;
      end;
    except
      on E: Exception do
        ShowOSD('Playback error: ' + E.Message);
    end;
  end
  else
  begin
    FPlaybackFailed := True;
    ShowOSD('Error loading: ' + ExtractFileName(AFilePath));
  end;
end;

procedure TFrmMain.PlayMediaAtIndex(AIndex: Integer; AOptions: TStrings);
begin
  if (AIndex >= 0) and (AIndex < FPlaylistPaths.Count) then
  begin
    FCurrentPlaylistIndex := AIndex;
    lstPlaylist.ItemIndex := AIndex;
    PlayFile(FPlaylistPaths[AIndex], AOptions);
  end;
end;

procedure TFrmMain.mnuOpenFileClick(Sender: TObject);
var
  Dialog: TFileOpenDialog;
begin
  Dialog := TFileOpenDialog.Create(Self);
  try
    Dialog.Title := 'Open media';
    Dialog.Options := [fdoFileMustExist, fdoPathMustExist, fdoAllowMultiSelect];
    with Dialog.FileTypes.Add do
    begin
      DisplayName := 'Media files';
      FileMask := '*.mp4;*.mkv;*.avi;*.mov;*.webm;*.mp3;*.flac;*.wav;*.ogg;*.m4a;*.ts;*.m4v';
    end;
    with Dialog.FileTypes.Add do
    begin
      DisplayName := 'All files';
      FileMask := '*.*';
    end;
    if Dialog.Execute(Handle) then
    begin
      var FirstIndex := FPlaylistPaths.Count;
      for var Path in Dialog.Files do
      begin
        FPlaylistPaths.Add(Path);
        lstPlaylist.Items.Add(ExtractFileName(Path));
      end;
      PlayMediaAtIndex(FirstIndex);
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TFrmMain.mnuOpenMultipleClick(Sender: TObject);
begin
  mnuOpenFileClick(Sender);
end;

procedure TFrmMain.mnuOpenClipboardClick(Sender: TObject);
var
  ClipText: string;
begin
  ClipText := Trim(Vcl.Clipbrd.Clipboard.AsText);
  if ClipText <> '' then
  begin
    FPlaylistPaths.Add(ClipText);
    lstPlaylist.Items.Add(ExtractFileName(ClipText));
    PlayMediaAtIndex(FPlaylistPaths.Count - 1);
  end;
end;

procedure TFrmMain.mnuQuitAtEndClick(Sender: TObject);
begin
  FQuitAtEnd := not FQuitAtEnd;
  mnuQuitAtEnd.Checked := FQuitAtEnd;
  ShowOSD('Quit at end of playlist: ' + BoolToStr(FQuitAtEnd, True));
end;

procedure TFrmMain.mnuStreamClick(Sender: TObject);
begin
  mnuConvertClick(Sender);
end;

procedure TFrmMain.mnuRecordClick(Sender: TObject);
var
  CapDir, CapFile: string;
begin
  CapDir := PlayerDataPath('Captures\');
  System.SysUtils.ForceDirectories(CapDir);
  CapFile := Format('%sCapture_%s.png', [CapDir, FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now)]);
  if (FMediaPlayer <> nil) and Assigned(libvlc_video_take_snapshot) then
  begin
    libvlc_video_take_snapshot(FMediaPlayer, 0, PAnsiChar(AnsiString(CapFile)), 0, 0);
    ShowOSD('Captured to ' + ExtractFileName(CapFile));
    GlobalLog('Stream Capture saved: ' + CapFile);
  end
  else
    ShowOSD('No active video to capture.');
end;

procedure TFrmMain.mnuTrackSyncClick(Sender: TObject);
begin
  if not Assigned(FrmEffects) then FrmEffects := TFrmEffects.Create(Application);
  FrmEffects.PageControl1.ActivePage := FrmEffects.tabSync;
  HidePlaybackOSD;
  FrmEffects.ShowModal;
end;

procedure TFrmMain.mnuCodecInfoClick(Sender: TObject);
begin
  mnuMediaInfoClick(Sender);
end;

procedure TFrmMain.mnuMessagesClick(Sender: TObject);
var
  Dlg: TFrmMessages;
begin
  Dlg := TFrmMessages.Create(Self);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuCustomizeInterfaceClick(Sender: TObject);
var
  Dlg: TFrmCustomize;
begin
  Dlg := TFrmCustomize.Create(Self);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuProgramGuideClick(Sender: TObject);
begin
  mnuIPTVClick(Sender);
end;

procedure TFrmMain.mnuPluginsClick(Sender: TObject);
begin
  ShowRuntimeComponents(Self);
end;

procedure TFrmMain.mnuThemesClick(Sender: TObject);
begin
  mnuCustomizeInterfaceClick(Sender);
end;

procedure TFrmMain.mnuAdvancedControlsClick(Sender: TObject);
begin
  mnuAdvancedControls.Checked := not mnuAdvancedControls.Checked;
  btnPrev.Visible := mnuAdvancedControls.Checked;
  btnNext.Visible := mnuAdvancedControls.Checked;
  RepositionModernControls;
  ShowOSD('Advanced Controls: ' + BoolToStr(mnuAdvancedControls.Checked, True));
end;

procedure TFrmMain.mnuStatusBarClick(Sender: TObject);
begin
  mnuStatusBar.Checked := not mnuStatusBar.Checked;
  ShowOSD('Status Bar: ' + BoolToStr(mnuStatusBar.Checked, True));
end;

procedure TFrmMain.mnuAddInterfaceClick(Sender: TObject);
begin
  PlayerMessage('A remote control server is not configured in this build.');
end;

procedure TFrmMain.mnuVLSubClick(Sender: TObject);
begin
  mnuAddSubClick(Sender);
end;

procedure TFrmMain.mnuDockedPlaylistClick(Sender: TObject);
begin
  mnuViewPlaylistClick(Sender);
end;

procedure TFrmMain.ApplyInterfaceCustomization;
var
  Ini: TAppSettings;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    if pnlMenuBar <> nil then
      pnlMenuBar.Visible := Ini.ReadBool('Interface', 'ShowMenuBar', True);
    if btnMenuIPTV <> nil then
      btnMenuIPTV.Visible := Ini.ReadBool('Interface', 'ShowLiveTVBtn', True);
    if modernSeekBar <> nil then
      modernSeekBar.Visible := Ini.ReadBool('Interface', 'ShowSeekBar', True);
    if lblTimeDisplay <> nil then
      lblTimeDisplay.Visible := Ini.ReadBool('Interface', 'ShowTime', True);
    if btnSpeed <> nil then
      btnSpeed.Visible := Ini.ReadBool('Interface', 'ShowSpeedBtn', True);
    if btnEqualizer <> nil then
      btnEqualizer.Visible := Ini.ReadBool('Interface', 'ShowEqualizerBtn', True);
    if btnFullscreen <> nil then
      btnFullscreen.Visible := Ini.ReadBool('Interface', 'ShowFullscreenBtn', True);
  finally
    Ini.Free;
  end;
  RepositionModernControls;
  ShowOSD('Interface Customized');
end;

function TFrmMain.GetMenuBarVisible: Boolean;
begin
  Result := (pnlMenuBar <> nil) and pnlMenuBar.Visible;
end;

procedure TFrmMain.SetMenuBarVisible(const Value: Boolean);
begin
  if pnlMenuBar <> nil then
  begin
    pnlMenuBar.Visible := Value and (not FIsBorderless) and (not FIsFullscreen);
    RepositionModernControls;
  end;
end;

function TFrmMain.GetTitleBarVisible: Boolean;
begin
  Result := (modernTitleBar <> nil) and modernTitleBar.Visible;
end;

procedure TFrmMain.SetTitleBarVisible(const Value: Boolean);
begin
  if modernTitleBar <> nil then
  begin
    modernTitleBar.Visible := Value and (not FIsBorderless) and (not FIsFullscreen);
    RepositionModernControls;
  end;
end;

procedure TFrmMain.SetIsBorderless(const Value: Boolean);
begin
  if FIsBorderless <> Value then
    mnuBorderlessClick(nil);
end;

procedure TFrmMain.ResetInterfaceDefaults;
begin
  if FIsBorderless then
    mnuBorderlessClick(nil);
  if modernTitleBar <> nil then modernTitleBar.Visible := True;
  if pnlMenuBar <> nil then pnlMenuBar.Visible := True;
  RepositionModernControls;
end;

procedure TFrmMain.SavePlaybackPosition;
var
  Ini: TAppSettings;
  CurTime, TotalLen: Int64;
  State: TFilePlaybackState;
begin
  if not FSettings.SaveHistory then Exit;
  if (FMediaPlayer <> nil) and (FCurrentFile <> '') and not FCurrentFile.Contains('://') then
  begin
    CurTime := libvlc_media_player_get_time(FMediaPlayer);
    TotalLen := libvlc_media_player_get_length(FMediaPlayer);
    if CurTime > 15000 then
    begin
      Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try
        Ini.WriteInteger('Positions', ExtractFileName(FCurrentFile), CurTime);
      finally
        Ini.Free;
      end;

      State.Position := CurTime;
      State.AudioTrack := -1;
      if Assigned(libvlc_audio_get_track) then
        State.AudioTrack := libvlc_audio_get_track(FMediaPlayer);
      State.SubtitleTrack := -1;
      if Assigned(libvlc_video_get_spu) then
        State.SubtitleTrack := libvlc_video_get_spu(FMediaPlayer);
      State.Volume := -1;
      if Assigned(libvlc_audio_get_volume) then
        State.Volume := libvlc_audio_get_volume(FMediaPlayer);
      State.LastPlayed := Now;
      ResumeStore.SaveState(FCurrentFile, State);
    end
    else if (TotalLen > 0) and (CurTime >= TotalLen - 10000) then
    begin
      ResumeStore.DeleteState(FCurrentFile);
    end;
  end;
end;

procedure TFrmMain.SavePlaybackResume;
begin
  SavePlaybackPosition;
end;

procedure TFrmMain.mnuOpenURLClick(Sender: TObject);
var
  Dlg: TFrmOpenMedia;
begin
  Dlg := TFrmOpenMedia.Create(Self);
  try
    Dlg.PageControl1.ActivePage := Dlg.tabNetwork;
    if Dlg.ShowModal = mrOk then
    begin
      FPlaylistPaths.Add(Dlg.SelectedMRL);
      lstPlaylist.Items.Add(Dlg.SelectedMRL);
      PlayMediaAtIndex(FPlaylistPaths.Count - 1, Dlg.Options);
    end;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuIPTVClick(Sender: TObject);
var
  Dlg: TFrmIPTV;
begin
  Dlg := TFrmIPTV.Create(Self);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.OnLiveTVSource(Sender: TObject);
var Dialog: TFrmIPTV;
begin
  Dialog:=TFrmIPTV.Create(Self);
  try
    Dialog.SelectConnectionSource(TMenuItem(Sender).Tag);
    Dialog.ShowModal;
  finally Dialog.Free; end;
end;

procedure TFrmMain.OnLiveTVMenu(Sender: TObject);
const Names: array[0..4] of string = ('Xtream Codes...','Stalker / MAC...',
  'M3U playlist URL...','Local playlist...','Playback samples...');
var Menu: TPopupMenu; Item: TMenuItem;
begin
  Menu:=TPopupMenu(FindComponent('LiveTVQuickMenu'));
  if Menu=nil then
  begin
    Menu:=TPopupMenu.Create(Self);
    Menu.Name:='LiveTVQuickMenu';
    for var I:=1 to High(Names) do
    begin
      Item:=TMenuItem.Create(Menu);
      Item.Caption:=Names[I]; Item.Tag:=I; Item.OnClick:=OnLiveTVSource;
      Menu.Items.Add(Item);
    end;
    Item:=TMenuItem.Create(Menu); Item.Caption:='-'; Menu.Items.Add(Item);
    Item:=TMenuItem.Create(Menu); Item.Caption:='Open Live TV and IPTV...';
    Item.OnClick:=mnuIPTVClick; Menu.Items.Add(Item);
  end;
  ShowPlayerMenu(Self,Menu.Items,btnMenuIPTV.ClientToScreen(Point(0,btnMenuIPTV.Height+4)));
end;

procedure TFrmMain.mnuOpenDiscClick(Sender: TObject);
var
  Dlg: TFrmOpenMedia;
begin
  Dlg := TFrmOpenMedia.Create(Self);
  try
    Dlg.PageControl1.ActivePage := Dlg.tabDisc;
    if Dlg.ShowModal = mrOk then
    begin
      FPlaylistPaths.Add(Dlg.SelectedMRL);
      lstPlaylist.Items.Add(Dlg.SelectedMRL);
      PlayMediaAtIndex(FPlaylistPaths.Count - 1, Dlg.Options);
    end;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuOpenCaptureClick(Sender: TObject);
var
  Dlg: TFrmOpenMedia;
begin
  Dlg := TFrmOpenMedia.Create(Self);
  try
    Dlg.PageControl1.ActivePage := Dlg.tabCapture;
    if Dlg.ShowModal = mrOk then
    begin
      FPlaylistPaths.Add(Dlg.SelectedMRL);
      lstPlaylist.Items.Add(Dlg.SelectedMRL);
      PlayMediaAtIndex(FPlaylistPaths.Count - 1, Dlg.Options);
    end;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuConvertClick(Sender: TObject);
var
  Dlg: TFrmConvert;
begin
  Dlg := TFrmConvert.Create(Self);
  try
    Dlg.SetSourceFile(FCurrentFile);
    Dlg.ShowModal;
  finally
    Dlg.Free;
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuBookmarksClick(Sender: TObject);
begin
  if FrmBookmarks = nil then
    FrmBookmarks := TFrmBookmarks.Create(Self);
  if FMediaPlayer <> nil then
    FrmBookmarks.CurrentTimeMs := libvlc_media_player_get_time(FMediaPlayer);
  FrmBookmarks.OnJumpToTime := OnBookmarkJump;
  HidePlaybackOSD;
  FrmBookmarks.ShowModal;
end;

procedure TFrmMain.OnBookmarkJump(ATimeMs: Int64);
begin
  if FMediaPlayer <> nil then
  begin
    SeekTo(ATimeMs);
    ShowOSD('Jump to Bookmark: ' + FormatTime(ATimeMs));
  end;
end;

procedure TFrmMain.WarmPreferences(Sender:TObject);
begin
  if FClosing then Exit;
  if FPreferencesWarmup<>nil then FPreferencesWarmup.Enabled:=False;
  if FrmPreferences=nil then FrmPreferences:=TFrmPreferences.Create(Self)
  else if FPreferencesDirty and not FrmPreferences.Showing then FrmPreferences.LoadPreferences;
  FPreferencesStamp:=PreferencesStamp; FPreferencesDirty:=False;
  if (FPreferencesWarmup <> nil) and (Sender = FPreferencesWarmup) and FrmPreferences.PrepareNextPage then
    FPreferencesWarmup.Enabled := True;
end;

procedure TFrmMain.MeasurePreferencesOpen(Sender: TObject);
var
  Finished, Frequency: Int64;
begin
  if (FrmPreferences = nil) or not FrmPreferences.Showing then Exit;
  FPreferencesOpenProbe.Enabled := False;
  RedrawWindow(FrmPreferences.Handle, nil, 0, RDW_UPDATENOW or RDW_ALLCHILDREN);
  DwmFlush;
  QueryPerformanceCounter(Finished);
  QueryPerformanceFrequency(Frequency);
  TFile.AppendAllText(GetEnvironmentVariable('VLC_PREFERENCES_TIMING_LOG'),
    Format('Preferences command to first composed frame: %.2f ms', [
      1000.0 * (Finished - FPreferencesOpenStarted) / Frequency]) + sLineBreak);
end;

procedure TFrmMain.mnuPreferencesClick(Sender: TObject);
var
  Dlg: TFrmPreferences;

begin
  QueryPerformanceCounter(FPreferencesOpenStarted);
  if FrmPreferences = nil then WarmPreferences(nil);
  Dlg := FrmPreferences;
  if FPreferencesDirty then begin
    Dlg.LoadPreferences; FPreferencesStamp:=PreferencesStamp; FPreferencesDirty:=False; end;
  try
    EnableDwmRoundedCorners(Dlg.Handle);
    if GetEnvironmentVariable('VLC_PREFERENCES_TIMING_LOG') <> '' then
    begin
      FPreferencesOpenProbe := TTimer.Create(Self);
      FPreferencesOpenProbe.Interval := 1;
      FPreferencesOpenProbe.OnTimer := MeasurePreferencesOpen;
    end;
    if Dlg.ShowModal = mrOk then
      ShowOSD('Preferences saved successfully.');
  finally
    FreeAndNil(FPreferencesOpenProbe);
    if Enabled and not FClosing then Winapi.Windows.SetFocus(Handle);
  end;
end;

procedure TFrmMain.mnuOpenFolderClick(Sender: TObject);
var
  Dir: string;
  FRec: TSearchRec;
  Ext: string;
begin
  if SelectDirectory('Select Media Directory', '', Dir) then
  begin
    if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*.*', faAnyFile, FRec) = 0 then
    begin
      try
        repeat
          Ext := LowerCase(ExtractFileExt(FRec.Name));
          if (Ext = '.mp4') or (Ext = '.mkv') or (Ext = '.avi') or (Ext = '.mov') or
             (Ext = '.flv') or (Ext = '.ts') or (Ext = '.mp3') or (Ext = '.wav') or
             (Ext = '.m4a') or (Ext = '.wmv') or (Ext = '.webm') then
          begin
            FPlaylistPaths.Add(IncludeTrailingPathDelimiter(Dir) + FRec.Name);
            lstPlaylist.Items.Add(FRec.Name);
          end;
        until FindNext(FRec) <> 0;
      finally
        FindClose(FRec);
      end;
    end;
    if (FCurrentPlaylistIndex < 0) and (FPlaylistPaths.Count > 0) then
      PlayMediaAtIndex(0);
  end;
end;

procedure TFrmMain.mnuSavePlaylistClick(Sender: TObject);
begin
  if SaveDialogPlaylist.Execute then
  begin
    FPlaylistPaths.SaveToFile(SaveDialogPlaylist.FileName, TEncoding.UTF8);
    ShowOSD('Playlist Saved: ' + ExtractFileName(SaveDialogPlaylist.FileName));
  end;
end;

procedure TFrmMain.mnuLoadPlaylistClick(Sender: TObject);
var
  Lines: TStringList;
  I: Integer;
  Line: string;
begin
  if OpenDialogPlaylist.Execute then
  begin
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(OpenDialogPlaylist.FileName, TEncoding.UTF8);
      for I := 0 to Lines.Count - 1 do
      begin
        Line := Trim(Lines[I]);
        if (Line <> '') and not Line.StartsWith('#') and FileExists(Line) then
        begin
          FPlaylistPaths.Add(Line);
          lstPlaylist.Items.Add(ExtractFileName(Line));
        end;
      end;
      if (FCurrentPlaylistIndex < 0) and (FPlaylistPaths.Count > 0) then
        PlayMediaAtIndex(0);
    finally
      Lines.Free;
    end;
  end;
end;

procedure TFrmMain.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.mnuPlayPauseClick(Sender: TObject);
var
  NowTick: UInt64;
begin
  if not Enabled or not IsWindowEnabled(Handle) or (FMediaPlayer = nil) then Exit;

  NowTick := GetTickCount64;
  FLastPlayPauseTick := NowTick;

  if (FCurrentMedia = nil) and (FPlaylistPaths.Count = 0) then
  begin
    mnuOpenFileClick(nil);
    Exit;
  end;

  if libvlc_media_player_is_playing(FMediaPlayer) = 1 then
  begin
    libvlc_media_player_pause(FMediaPlayer);
    if Assigned(btnPlay) then
    begin
      btnPlay.IconKind := ikPlay;
      btnPlay.Hint := 'Play (Space)';
    end;
    if FSettings.ShowOSD and not FSuppressTransientOSD then ShowVideoPlayPauseWatermark(pnlVideo, False);
    if Assigned(FTaskbarMgr) then FTaskbarMgr.UpdatePlayState(Handle, False);
    ShowOSD('Paused');
  end
  else
  begin
    if (FCurrentMedia = nil) and (FPlaylistPaths.Count > 0) then
      PlayMediaAtIndex(0)
    else
    begin
      libvlc_media_player_play(FMediaPlayer);
      if Assigned(btnPlay) then
      begin
        btnPlay.IconKind := ikPause;
        btnPlay.Hint := 'Pause (Space)';
      end;
      if FSettings.ShowOSD and not FSuppressTransientOSD then ShowVideoPlayPauseWatermark(pnlVideo, True);
      if Assigned(FTaskbarMgr) then FTaskbarMgr.UpdatePlayState(Handle, True);
      ShowOSD('Playing');
    end;
  end;
end;

procedure TFrmMain.mnuStopClick(Sender: TObject);
begin
  HidePlaybackOSD;
  if FMediaPlayer = nil then Exit;
  OnSeekBarLeave(nil);
  SavePlaybackPosition;
  DetachVideoInput;
  FPendingSeek := -1;
  FPendingResume := 0;
  try
    libvlc_media_player_stop(FMediaPlayer);
  except
  end;
  if Assigned(btnPlay) then
  begin
    btnPlay.IconKind := ikPlay;
    btnPlay.Hint := 'Play (Space)';
  end;
  if Assigned(modernSeekBar) then modernSeekBar.Position := 0.0;
  if Assigned(lblTimeDisplay) then lblTimeDisplay.Caption := '00:00 / 00:00';
  lblTime.Caption := '00:00 / 00:00';
  FATime := -1;
  FBTime := -1;
  if Assigned(FTaskbarMgr) then
  begin
    FTaskbarMgr.UpdatePlayState(Handle, False);
    FTaskbarMgr.UpdateProgress(Handle, 0, 0);
  end;
  if Assigned(pnlVideo) then
    pnlVideo.Invalidate;
  ShowOSD('Stopped');
end;

procedure TFrmMain.mnuPreviousClick(Sender: TObject);
begin
  if FPlaylistPaths.Count = 0 then Exit;
  if FCurrentPlaylistIndex > 0 then
    PlayMediaAtIndex(FCurrentPlaylistIndex - 1)
  else
    PlayMediaAtIndex(FPlaylistPaths.Count - 1);
end;

procedure TFrmMain.mnuNextClick(Sender: TObject);
begin
  if FPlaylistPaths.Count = 0 then Exit;
  if FCurrentPlaylistIndex < FPlaylistPaths.Count - 1 then
    PlayMediaAtIndex(FCurrentPlaylistIndex + 1)
  else
    PlayMediaAtIndex(0);
end;

procedure TFrmMain.mnuJumpFwdClick(Sender: TObject);
var
  CurTime, NewTime, TotalDur: Int64;
  Pct: Integer;
begin
  if FMediaPlayer = nil then Exit;
  if FPendingSeek >= 0 then CurTime := FPendingSeek
  else CurTime := Max(Int64(0), libvlc_media_player_get_time(FMediaPlayer));
  NewTime := CurTime + 10000;
  TotalDur := libvlc_media_player_get_length(FMediaPlayer);
  if TotalDur > 0 then
  begin
    NewTime := Min(NewTime, TotalDur);
    Pct := Round((NewTime / TotalDur) * 100);
    SeekTo(NewTime);
    ShowOSD(Format('%s%d s   %s   (%d%%)', [IfThen(NewTime >= CurTime, '+', ''), (NewTime - CurTime) div 1000, FormatTime(NewTime), Pct]));
  end
  else
  begin
    SeekTo(NewTime);
    ShowOSD('+10s');
  end;
end;

procedure TFrmMain.mnuJumpBackClick(Sender: TObject);
var
  CurTime, NewTime, TotalDur: Int64;
  Pct: Integer;
begin
  if FMediaPlayer = nil then Exit;
  if FPendingSeek >= 0 then CurTime := FPendingSeek
  else CurTime := Max(Int64(0), libvlc_media_player_get_time(FMediaPlayer));
  NewTime := Max(Int64(0), CurTime - 10000);
  TotalDur := libvlc_media_player_get_length(FMediaPlayer);
  if TotalDur > 0 then
  begin
    Pct := Round((NewTime / TotalDur) * 100);
    SeekTo(NewTime);
    ShowOSD(Format('%s%d s   %s   (%d%%)', [IfThen(NewTime >= CurTime, '+', ''), (NewTime - CurTime) div 1000, FormatTime(NewTime), Pct]));
  end
  else
  begin
    SeekTo(NewTime);
    ShowOSD('-10s');
  end;
end;

procedure TFrmMain.mnuJumpTimeClick(Sender: TObject);
begin
  if not Assigned(FrmJumpTime) then
    FrmJumpTime := TFrmJumpTime.Create(Self);
  FrmJumpTime.ShowModal;
end;

procedure TFrmMain.mnuABRepeatClick(Sender: TObject);
var
  CurTime: Int64;
begin
  if FMediaPlayer = nil then Exit;
  CurTime := libvlc_media_player_get_time(FMediaPlayer);

  if FATime < 0 then
  begin
    FATime := CurTime;
    FBTime := -1;
    ShowOSD('A-B: Point A Set (' + FormatTime(FATime) + ')');
  end
  else if (FATime >= 0) and (FBTime < 0) then
  begin
    if CurTime > FATime then
    begin
      FBTime := CurTime;
      ShowOSD('A-B: Looping ' + FormatTime(FATime) + ' -> ' + FormatTime(FBTime));
    end
    else
      ShowOSD('Point B must be after Point A!');
  end
  else
  begin
    FATime := -1;
    FBTime := -1;
    ShowOSD('A-B: Repeat Cleared');
  end;
end;

procedure TFrmMain.mnuNextFrameClick(Sender: TObject);
begin
  if FMediaPlayer = nil then Exit;
  libvlc_media_player_next_frame(FMediaPlayer);
  ShowOSD('Next Frame');
end;

procedure TFrmMain.mnuPrevFrameClick(Sender: TObject);
var
  CurTime: Int64;
  Fps: Single;
  FrameMs: Int64;
begin
  if FMediaPlayer = nil then Exit;
  if libvlc_media_player_is_playing(FMediaPlayer) = 1 then
    libvlc_media_player_pause(FMediaPlayer);
  Fps := 0;
  if Assigned(libvlc_media_player_get_fps) then
    Fps := libvlc_media_player_get_fps(FMediaPlayer);
  if Fps <= 1.0 then Fps := 24.0;
  FrameMs := Round(1000.0 / Fps);
  CurTime := libvlc_media_player_get_time(FMediaPlayer);
  if CurTime >= FrameMs then
    libvlc_media_player_set_time(FMediaPlayer, CurTime - FrameMs)
  else
    libvlc_media_player_set_time(FMediaPlayer, 0);
  ShowOSD('Previous Frame');
end;

procedure TFrmMain.CycleVideoRotation;
var
  CurPos: Int64;
  NextTransform: Integer;
begin
  if (FMediaPlayer = nil) or (FCurrentFile = '') then Exit;
  // Transforms: 0: none, 1: 90, 2: 180, 3: 270
  case FSettings.Transform of
    0: NextTransform := 1;
    1: NextTransform := 2;
    2: NextTransform := 3;
    else NextTransform := 0;
  end;
  FSettings.Transform := NextTransform;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteInteger('Video', 'Transform', NextTransform); finally Store.Free; end;

  CurPos := libvlc_media_player_get_time(FMediaPlayer);
  PlayFile(FCurrentFile);
  if CurPos > 0 then SeekTo(CurPos);

  case NextTransform of
    0: ShowOSD('Rotation: 0° (Original)');
    1: ShowOSD('Rotation: 90° Clockwise');
    2: ShowOSD('Rotation: 180°');
    3: ShowOSD('Rotation: 270°');
  end;
end;

procedure TFrmMain.ToggleVideoFlipHorizontal;
var
  CurPos: Int64;
  NextTransform: Integer;
begin
  if (FMediaPlayer = nil) or (FCurrentFile = '') then Exit;
  // 4: hflip
  if FSettings.Transform = 4 then
    NextTransform := 0
  else
    NextTransform := 4;
  FSettings.Transform := NextTransform;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteInteger('Video', 'Transform', NextTransform); finally Store.Free; end;

  CurPos := libvlc_media_player_get_time(FMediaPlayer);
  PlayFile(FCurrentFile);
  if CurPos > 0 then SeekTo(CurPos);

  if NextTransform = 4 then
    ShowOSD('Mirror: Horizontal Flip ON')
  else
    ShowOSD('Mirror: Normal');
end;

procedure TFrmMain.ToggleSkipOpening;
begin
  FSettings.SkipOpening := not FSettings.SkipOpening;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteBool('Playback', 'SkipOpening', FSettings.SkipOpening);
  finally
    Store.Free;
  end;

  if Assigned(mnuSkipOpening) then
    mnuSkipOpening.Checked := FSettings.SkipOpening;

  if FSettings.SkipOpening then
    ShowOSD(Format('Skip Opening: ON (%ds)', [FSettings.SkipOpeningSeconds]))
  else
    ShowOSD('Skip Opening: OFF');
end;

procedure TFrmMain.ToggleSkipEnding;
begin
  FSettings.SkipEnding := not FSettings.SkipEnding;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteBool('Playback', 'SkipEnding', FSettings.SkipEnding);
  finally
    Store.Free;
  end;

  if Assigned(mnuSkipEnding) then
    mnuSkipEnding.Checked := FSettings.SkipEnding;

  if FSettings.SkipEnding then
    ShowOSD(Format('Skip Ending: ON (%ds)', [FSettings.SkipEndingSeconds]))
  else
    ShowOSD('Skip Ending: OFF');
end;

procedure TFrmMain.GenerateThumbnailSheet;
begin
  if (FMediaPlayer = nil) or (FCurrentFile = '') or not FileExists(FCurrentFile) then
  begin
    ShowOSD('No media file loaded for thumbnail sheet');
    Exit;
  end;

  var TotalLen := libvlc_media_player_get_length(FMediaPlayer);
  if TotalLen <= 1000 then
  begin
    ShowOSD('Video duration too short for thumbnail sheet');
    Exit;
  end;

  ShowOSD('Generating thumbnail sheet (12 frames)...');
  TThumbnailSheetGenerator.GenerateAsync(
    FVlcInstance,
    FCurrentFile,
    PlayerDataPath('snapshots'),
    4, 3,
    TotalLen,
    nil,
    procedure(const OutFile: string; Success: Boolean; const Err: string)
    begin
      if Success then
        ShowOSD('Thumbnail sheet saved: ' + ExtractFileName(OutFile))
      else
        ShowOSD('Failed to generate thumbnail sheet: ' + Err);
    end
  );
end;

procedure TFrmMain.mnuSkipOpeningClick(Sender: TObject);
begin
  ToggleSkipOpening;
end;

procedure TFrmMain.mnuSkipEndingClick(Sender: TObject);
begin
  ToggleSkipEnding;
end;

procedure TFrmMain.mnuThumbnailSheetClick(Sender: TObject);
begin
  GenerateThumbnailSheet;
end;

procedure TFrmMain.OpenScreenCapture;
var
  Options: TStringList;
begin
  Options := TStringList.Create;
  try
    Options.Add(':screen-fps=30');
    FPlaylistPaths.Add('screen://');
    lstPlaylist.Items.Add('Desktop Screen');
    PlayMediaAtIndex(FPlaylistPaths.Count - 1, Options);
    ShowOSD('Screen Capture: Desktop (30 FPS)');
  finally
    Options.Free;
  end;
end;

procedure TFrmMain.GenerateAnimatedGif;
var
  CurPos: Int64;
begin
  if (FMediaPlayer = nil) or (FCurrentFile = '') or not FileExists(FCurrentFile) then
  begin
    ShowOSD('No media file loaded for GIF creation');
    Exit;
  end;

  CurPos := libvlc_media_player_get_time(FMediaPlayer);
  if CurPos < 0 then CurPos := 0;

  ShowOSD('Creating Animated GIF (3s at 10 FPS)...');
  TGifMaker.GenerateGifAsync(
    FVlcInstance,
    FCurrentFile,
    PlayerDataPath('snapshots'),
    CurPos,
    3000,
    10,
    480,
    nil,
    procedure(const OutFile: string; Success: Boolean; const Err: string)
    begin
      if Success then
        ShowOSD('Animated GIF saved: ' + ExtractFileName(OutFile))
      else
        ShowOSD('Failed to create GIF: ' + Err);
    end
  );
end;

procedure TFrmMain.StopAudioRecording;
begin
  if FAudioRecorderPlayer <> nil then
  begin
    try
      if Assigned(libvlc_media_player_stop) then
        libvlc_media_player_stop(FAudioRecorderPlayer);
      if Assigned(libvlc_media_player_release) then
        libvlc_media_player_release(FAudioRecorderPlayer);
    except
    end;
    FAudioRecorderPlayer := nil;
  end;
  if FAudioRecording then
  begin
    FAudioRecording := False;
    if (FAudioRecordPath <> '') and TFile.Exists(FAudioRecordPath) then
      ShowOSD(Format('Audio Recording Saved: %s (%d KB)',
        [ExtractFileName(FAudioRecordPath), TFile.GetSize(FAudioRecordPath) div 1024]))
    else
      ShowOSD('Audio Recording Stopped');
  end;
end;

procedure TFrmMain.RecordAudioStream;
var
  DestDir, DestFile, BaseName, SoutOpt, StartOpt: string;
  RecMedia: Plibvlc_media_t;
  Utf8Path, Utf8Opt: UTF8String;
  CurSec: Double;
begin
  if FAudioRecording then
  begin
    StopAudioRecording;
    Exit;
  end;

  if (FMediaPlayer = nil) or (FVlcInstance = nil) or (FCurrentFile = '') then
  begin
    ShowOSD('No active media to record audio');
    Exit;
  end;

  DestDir := PlayerDataPath('snapshots');
  if not TDirectory.Exists(DestDir) then TDirectory.CreateDirectory(DestDir);

  if Pos('://', FCurrentFile) = 0 then
    BaseName := TPath.GetFileNameWithoutExtension(FCurrentFile)
  else
    BaseName := 'LiveStream';

  DestFile := TPath.Combine(DestDir, Format('Audio_%s_%s.wav', [
    BaseName,
    FormatDateTime('yyyymmdd_hhnnss', Now)
  ]));

  Utf8Path := UTF8Encode(FCurrentFile);
  if Pos('://', FCurrentFile) > 0 then
    RecMedia := libvlc_media_new_location(FVlcInstance, PAnsiChar(Utf8Path))
  else
    RecMedia := libvlc_media_new_path(FVlcInstance, PAnsiChar(Utf8Path));

  if RecMedia = nil then
  begin
    ShowOSD('Audio Record: Could not open source stream');
    Exit;
  end;

  try
    SoutOpt := Format(':sout=#transcode{acodec=s16l,channels=2,samplerate=44100}:std{access=file,mux=wav,dst="%s"}', [DestFile]);
    Utf8Opt := UTF8Encode(SoutOpt);
    libvlc_media_add_option(RecMedia, PAnsiChar(Utf8Opt));
    libvlc_media_add_option(RecMedia, ':no-video');

    if (Pos('://', FCurrentFile) = 0) and Assigned(libvlc_media_player_get_time) then
    begin
      CurSec := Max(0.0, libvlc_media_player_get_time(FMediaPlayer) / 1000.0);
      if CurSec > 0.5 then
      begin
        StartOpt := Format(':start-time=%.2f', [CurSec], TFormatSettings.Invariant);
        Utf8Opt := UTF8Encode(StartOpt);
        libvlc_media_add_option(RecMedia, PAnsiChar(Utf8Opt));
      end;
    end;

    FAudioRecorderPlayer := libvlc_media_player_new_from_media(RecMedia);
  finally
    libvlc_media_release(RecMedia);
  end;

  if (FAudioRecorderPlayer <> nil) and (libvlc_media_player_play(FAudioRecorderPlayer) = 0) then
  begin
    FAudioRecordPath := DestFile;
    FAudioRecording := True;
    ShowOSD('Recording Audio -> ' + ExtractFileName(DestFile) + ' (Press Ctrl+Shift+R to stop)');
  end
  else
  begin
    StopAudioRecording;
    ShowOSD('Audio Record: Failed to start WAV capture');
  end;
end;

procedure TFrmMain.mnuScreenCaptureClick(Sender: TObject);
begin
  OpenScreenCapture;
end;

procedure TFrmMain.mnuAudioRecordClick(Sender: TObject);
begin
  RecordAudioStream;
end;

procedure TFrmMain.mnuAnimatedGifClick(Sender: TObject);
begin
  GenerateAnimatedGif;
end;

procedure TFrmMain.mnuRecordVideoMP4Click(Sender: TObject);
begin
  RecordVideoStream;
end;

function TFrmMain.StartPreciseClip(const Source, Destination: string;
  ClipStart, ClipEnd: Int64): Boolean;
var
  Encoder, Command: string;
  Startup: TStartupInfoW;
  Process: TProcessInformation;
begin
  Result := False;
  Encoder := ComponentPath('tools\ffmpeg.exe');
  if not TFile.Exists(Encoder) then Exit;
  Command := Format('"%s" -nostdin -v error -n -ss %.3f -i "%s" -t %.3f ' +
    '-map 0:v:0 -map 0:a:0? -c:v libx264 -preset veryfast -c:a aac -movflags +faststart "%s"',
    [Encoder, ClipStart / 1000, Source, (ClipEnd - ClipStart) / 1000,
     Destination + '.part.mp4'], TFormatSettings.Invariant);
  UniqueString(Command);
  ZeroMemory(@Startup, SizeOf(Startup));
  Startup.cb := SizeOf(Startup);
  if not CreateProcessW(PWideChar(Encoder), PWideChar(Command), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, Startup, Process) then Exit;
  CloseHandle(Process.hThread);
  FClipExportProcess := Process.hProcess;
  Result := True;
end;

procedure TFrmMain.VideoExportTick(Sender: TObject);
begin
  if FClipExportProcess <> 0 then
  begin
    if WaitForSingleObject(FClipExportProcess, 0) = WAIT_TIMEOUT then Exit;
    var Status: DWORD;
    var Output := FVideoRecordPath + '.part.mp4';
    var Saved := GetExitCodeProcess(FClipExportProcess, Status) and (Status = 0) and
      MoveFileEx(PChar(Output), PChar(FVideoRecordPath), 0);
    CloseHandle(FClipExportProcess);
    FClipExportProcess := 0;
    StopVideoRecording;
    if not Saved then
    begin
      System.SysUtils.DeleteFile(Output);
      ShowOSD('Could not save precise MP4 clip');
    end;
    Exit;
  end;
  if FVideoRecorderPlayer = nil then Exit;
  case libvlc_media_player_get_state(FVideoRecorderPlayer) of
    libvlc_Ended: StopVideoRecording;
    libvlc_Error:
      begin
        var FailedPath := FVideoRecordPath;
        FVideoRecordPath := '';
        StopVideoRecording;
        if FailedPath <> '' then System.SysUtils.DeleteFile(FailedPath);
        ShowOSD('Could not save MP4 clip');
      end;
  end;
end;

procedure TFrmMain.StopVideoRecording;
begin
  if FClipExportProcess <> 0 then
  begin
    TerminateProcess(FClipExportProcess, 1);
    WaitForSingleObject(FClipExportProcess, 2000);
    CloseHandle(FClipExportProcess);
    FClipExportProcess := 0;
    System.SysUtils.DeleteFile(FVideoRecordPath + '.part.mp4');
  end;
  FLocalRecordingFile := '';
  if Assigned(FVideoExportTimer) then FVideoExportTimer.Enabled := False;
  FVideoExporting := False;
  if FVideoRecorderPlayer <> nil then
  begin
    try
      if Assigned(libvlc_media_player_stop) then
        libvlc_media_player_stop(FVideoRecorderPlayer);
      if Assigned(libvlc_media_player_release) then
        libvlc_media_player_release(FVideoRecorderPlayer);
    except
    end;
    FVideoRecorderPlayer := nil;
  end;
  if FVideoRecorderInstance <> nil then
  begin
    libvlc_release(FVideoRecorderInstance);
    FVideoRecorderInstance := nil;
  end;
  if FVideoRecording then
  begin
    FVideoRecording := False;
    if (FVideoRecordPath <> '') and TFile.Exists(FVideoRecordPath) then
      ShowOSD(Format('MP4 Recording Saved: %s (%d KB)',
        [ExtractFileName(FVideoRecordPath), TFile.GetSize(FVideoRecordPath) div 1024]))
    else
      ShowOSD('MP4 Recording Stopped');
  end;
end;

procedure TFrmMain.RecordVideoStream;
const
  RecorderOptions: array[0..3] of PAnsiChar =
    ('--quiet', '--ignore-config', '--avcodec-hw=none', '--sout-mux-caching=3000');
var
  DestDir, DestFile, BaseName, SoutOpt, StartOpt: string;
  RecMedia: Plibvlc_media_t;
  Utf8Path, Utf8Opt: UTF8String;
  Tracks, Track: PPlibvlc_media_track_t;
  TrackCount: Cardinal;
  HasH264, Compatible, HasAudio, ExportClip: Boolean;
  ClipStart, ClipEnd: Int64;
begin
  if FVideoExporting then
  begin
    ShowOSD('Finishing the previous MP4 clip');
    Exit;
  end;
  if FVideoRecording then
  begin
    StopVideoRecording;
    Exit;
  end;

  if (FMediaPlayer = nil) or (FVlcInstance = nil) or (FCurrentFile = '') then
  begin
    ShowOSD('No active media to record MP4 video');
    Exit;
  end;

  ExportClip := not FCurrentFile.Contains('://');
  ClipStart := 0;
  ClipEnd := 0;
  if ExportClip then
  begin
    ClipEnd := libvlc_media_player_get_time(FMediaPlayer);
    if ClipEnd < 0 then
    begin
      FLocalRecordingFile := '';
      ShowOSD('Start playback before recording');
      Exit;
    end;
    if not SameText(FLocalRecordingFile, FCurrentFile) then
    begin
      FLocalRecordingFile := FCurrentFile;
      FLocalRecordingStart := ClipEnd;
      ShowOSD('Recording clip. Press Alt+C to finish');
      Exit;
    end;
    ClipStart := FLocalRecordingStart;
    FLocalRecordingFile := '';
    if ClipEnd - ClipStart < 250 then
    begin
      ShowOSD('Record at least a quarter second of playback');
      Exit;
    end;
  end;

  DestDir := PlayerDataPath('recordings');
  if not TDirectory.Exists(DestDir) then TDirectory.CreateDirectory(DestDir);

  if Pos('://', FCurrentFile) = 0 then
    BaseName := TPath.GetFileNameWithoutExtension(FCurrentFile)
  else
    BaseName := 'LiveVideo';

  DestFile := TPath.Combine(DestDir, Format('Video_%s_%s.mp4', [
    BaseName,
    FormatDateTime('yyyymmdd_hhnnss', Now)
  ]));

  if ExportClip and StartPreciseClip(FCurrentFile, DestFile, ClipStart, ClipEnd) then
  begin
    FVideoRecordPath := DestFile;
    FVideoRecording := True;
    FVideoExporting := True;
    if FVideoExportTimer = nil then
    begin
      FVideoExportTimer := TTimer.Create(Self);
      FVideoExportTimer.Interval := 150;
      FVideoExportTimer.OnTimer := VideoExportTick;
    end;
    FVideoExportTimer.Enabled := True;
    ShowOSD('Saving MP4 clip...');
    Exit;
  end;

  // The recorder must decode both streams independently of the display
  // engine, whose hardware surfaces can delay the first encoded frame.
  FVideoRecorderInstance := libvlc_new(Length(RecorderOptions), @RecorderOptions[0]);
  if FVideoRecorderInstance = nil then
  begin
    ShowOSD('MP4 Record: Could not initialize the recorder');
    Exit;
  end;

  Utf8Path := UTF8Encode(FCurrentFile);
  if Pos('://', FCurrentFile) > 0 then
    RecMedia := libvlc_media_new_location(FVideoRecorderInstance, PAnsiChar(Utf8Path))
  else
    RecMedia := libvlc_media_new_path(FVideoRecorderInstance, PAnsiChar(Utf8Path));

  if RecMedia = nil then
  begin
    StopVideoRecording;
    ShowOSD('MP4 Record: Could not open source media');
    Exit;
  end;

  try
    HasH264 := False;
    HasAudio := False;
    Compatible := False;
    Tracks := nil;
    if (FCurrentMedia <> nil) and Assigned(libvlc_media_tracks_get) and
      Assigned(libvlc_media_tracks_release) then
    begin
      TrackCount := libvlc_media_tracks_get(FCurrentMedia, @Tracks);
      if (Tracks <> nil) and (TrackCount > 0) then
      try
        Compatible := True;
        Track := Tracks;
        for var I := 1 to TrackCount do
        begin
          if Track^ <> nil then
            case Track^^.i_type of
              libvlc_track_video:
                if Track^^.i_codec = $34363268 { h264 } then HasH264 := True
                else Compatible := False;
              libvlc_track_audio:
                if Track^^.i_codec = $6134706D { mp4a } then HasAudio := True
                else Compatible := False;
            end;
          Inc(Track);
        end;
      finally
        libvlc_media_tracks_release(Tracks, TrackCount);
      end;
    end;
    if Compatible and HasH264 and HasAudio then
      SoutOpt := Format(':sout=#std{access=file,mux=mp4,dst="%s"}', [DestFile])
    else
      // Avformat normalizes timestamps from the transcoded streams.
      SoutOpt := Format(':sout=#transcode{vcodec=h264,venc=x264{preset=ultrafast,tune=zerolatency},vb=2500,acodec=mp4a,ab=128}:std{access=file,mux=avformat{mux=mp4},dst="%s"}', [DestFile]);
    Utf8Opt := UTF8Encode(SoutOpt);
    libvlc_media_add_option(RecMedia, PAnsiChar(Utf8Opt));

    if ExportClip then
    begin
      StartOpt := Format(':start-time=%.3f', [ClipStart / 1000], TFormatSettings.Invariant);
      Utf8Opt := UTF8Encode(StartOpt);
      libvlc_media_add_option(RecMedia, PAnsiChar(Utf8Opt));
      Utf8Opt := UTF8Encode(Format(':stop-time=%.3f', [ClipEnd / 1000], TFormatSettings.Invariant));
      libvlc_media_add_option(RecMedia, PAnsiChar(Utf8Opt));
    end;

    FVideoRecorderPlayer := libvlc_media_player_new_from_media(RecMedia);
  finally
    libvlc_media_release(RecMedia);
  end;

  if (FVideoRecorderPlayer <> nil) and (libvlc_media_player_play(FVideoRecorderPlayer) = 0) then
  begin
    FVideoRecordPath := DestFile;
    FVideoRecording := True;
    FVideoExporting := ExportClip;
    if ExportClip then
    begin
      if FVideoExportTimer = nil then
      begin
        FVideoExportTimer := TTimer.Create(Self);
        FVideoExportTimer.Interval := 150;
        FVideoExportTimer.OnTimer := VideoExportTick;
      end;
      FVideoExportTimer.Enabled := True;
      ShowOSD('Saving MP4 clip...');
    end
    else
      ShowOSD('Recording MP4 -> ' + ExtractFileName(DestFile) + ' (Press Alt+C to stop)');
  end
  else
  begin
    StopVideoRecording;
    ShowOSD('MP4 Record: Failed to start video capture');
  end;
end;

procedure TFrmMain.mnuWebRemoteClick(Sender: TObject);
begin
  ToggleWebRemoteServer(8080);
end;

procedure TFrmMain.ToggleWebRemoteServer(APort: Word);
var
  CurTitle, CurState: string;
  PosMs, DurMs: Int64;
  Vol: Integer;
  Muted: Boolean;
begin
  if FWebRemote = nil then
    FWebRemote := TWebRemoteServer.Create(APort);

  if FWebRemote.Running then
  begin
    FWebRemote.Stop;
    if Assigned(mnuWebRemote) then mnuWebRemote.Checked := False;
    ShowOSD('Web Remote Server: Stopped');
  end
  else
  begin
    FWebRemote.Port := APort;
    if FCurrentFile <> '' then CurTitle := ExtractFileName(FCurrentFile) else CurTitle := 'VLC Modern (Idle)';
    CurState := 'Stopped'; PosMs := 0; DurMs := 0; Vol := 100; Muted := False;
    if FMediaPlayer <> nil then
    begin
      if libvlc_media_player_is_playing(FMediaPlayer) = 1 then CurState := 'Playing'
      else if libvlc_media_player_get_state(FMediaPlayer) = libvlc_Paused then CurState := 'Paused';
      PosMs := libvlc_media_player_get_time(FMediaPlayer);
      DurMs := libvlc_media_player_get_length(FMediaPlayer);
      Vol := libvlc_audio_get_volume(FMediaPlayer);
      Muted := libvlc_audio_get_mute(FMediaPlayer) = 1;
    end;
    FWebRemote.UpdateStatus(CurTitle, CurState, PosMs, DurMs, Vol, Muted);

    if FWebRemote.Start(
      procedure(const Cmd: string)
      begin
        if Cmd = 'playpause' then mnuPlayPauseClick(nil)
        else if Cmd = 'stop' then mnuStopClick(nil)
        else if Cmd = 'prev' then mnuPreviousClick(nil)
        else if Cmd = 'next' then mnuNextClick(nil)
        else if Cmd = 'volup' then AdjustVolume(5)
        else if Cmd = 'voldown' then AdjustVolume(-5)
        else if Cmd = 'mute' then mnuMuteClick(nil)
        else if Cmd = 'fullscreen' then mnuFullscreenClick(nil)
        else if Cmd = 'back10' then JumpSeconds(-10)
        else if Cmd = 'fwd10' then JumpSeconds(10);
      end) then
    begin
      if Assigned(mnuWebRemote) then mnuWebRemote.Checked := True;
      ShowOSD(Format('Web Remote Active: http://127.0.0.1:%d', [APort]));
    end
    else
      ShowOSD(Format('Web Remote: Failed to bind port %d', [APort]));
  end;
end;

procedure TFrmMain.mnuSpeedItemClick(Sender: TObject);
var
  Rate: Single;
begin
  if not (Sender is TMenuItem) or (FMediaPlayer = nil) then Exit;
  Rate := TMenuItem(Sender).Tag / 100.0;
  libvlc_media_player_set_rate(FMediaPlayer, Rate);
  if Assigned(btnSpeed) then btnSpeed.BadgeText := Format('%.2gx', [Rate]);
  ShowOSD(Format('Speed: %.2fx', [Rate]));
end;

procedure TFrmMain.cboSpeedChange(Sender: TObject);
var
  Rate: Single;
  S: string;
begin
  if FMediaPlayer = nil then Exit;
  S := StringReplace(cboSpeed.Text, 'x', '', [rfReplaceAll]);
  Rate := StrToFloatDef(S, 1.0);
  libvlc_media_player_set_rate(FMediaPlayer, Rate);
  if Assigned(btnSpeed) then btnSpeed.BadgeText := Format('%.2gx', [Rate]);
  ShowOSD(Format('Speed: %.2fx', [Rate]));
end;

procedure TFrmMain.mnuAudioClick(Sender: TObject);
begin
  UpdateAudioTracksMenu(mnuAudioTrack);
  if Assigned(mnuVoiceClarifier) then mnuVoiceClarifier.Checked := FSettings.VoiceClarifier;
  if Assigned(mnuNightMode) then mnuNightMode.Checked := FSettings.NightMode;
  if Assigned(mnuHeadphoneSurround) then mnuHeadphoneSurround.Checked := FSettings.HeadphoneSurround;
  if Assigned(mnuKaraokeMode) then mnuKaraokeMode.Checked := FSettings.KaraokeMode;
  if Assigned(mnuAudioPassthrough) then mnuAudioPassthrough.Checked := FSettings.AudioPassthrough;

  if Assigned(popVoiceClarifier) then popVoiceClarifier.Checked := FSettings.VoiceClarifier;
  if Assigned(popNightMode) then popNightMode.Checked := FSettings.NightMode;
  if Assigned(popHeadphoneSurround) then popHeadphoneSurround.Checked := FSettings.HeadphoneSurround;
  if Assigned(popKaraokeMode) then popKaraokeMode.Checked := FSettings.KaraokeMode;
  if Assigned(popAudioPassthrough) then popAudioPassthrough.Checked := FSettings.AudioPassthrough;
end;

procedure TFrmMain.ToggleVoiceClarifier;
begin
  FSettings.VoiceClarifier := not FSettings.VoiceClarifier;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteBool('Audio', 'VoiceClarifier', FSettings.VoiceClarifier); finally Store.Free; end;

  if Assigned(mnuVoiceClarifier) then mnuVoiceClarifier.Checked := FSettings.VoiceClarifier;
  if Assigned(popVoiceClarifier) then popVoiceClarifier.Checked := FSettings.VoiceClarifier;
  ApplyAudioEffects;

  if FSettings.VoiceClarifier then
    ShowOSD('Voice Clarifier: ON (+6dB Dialogue Boost)')
  else
    ShowOSD('Voice Clarifier: OFF');
end;

procedure TFrmMain.ToggleNightMode;
begin
  FSettings.NightMode := not FSettings.NightMode;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteBool('Audio', 'NightMode', FSettings.NightMode); finally Store.Free; end;

  if Assigned(mnuNightMode) then mnuNightMode.Checked := FSettings.NightMode;
  if Assigned(popNightMode) then popNightMode.Checked := FSettings.NightMode;
  ApplyAudioEffects;

  if FSettings.NightMode then
    ShowOSD('Night Mode: ON (Dynamic Range Compressed)')
  else
    ShowOSD('Night Mode: OFF');
end;

procedure TFrmMain.ToggleHeadphoneSurround;
begin
  FSettings.HeadphoneSurround := not FSettings.HeadphoneSurround;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteBool('Audio', 'HeadphoneSurround', FSettings.HeadphoneSurround); finally Store.Free; end;

  if Assigned(mnuHeadphoneSurround) then mnuHeadphoneSurround.Checked := FSettings.HeadphoneSurround;
  if Assigned(popHeadphoneSurround) then popHeadphoneSurround.Checked := FSettings.HeadphoneSurround;
  ApplyAudioEffects;

  if FSettings.HeadphoneSurround then
    ShowOSD('3D Headphone Surround: ON (Binaural HRTF)')
  else
    ShowOSD('3D Headphone Surround: OFF');
end;

procedure TFrmMain.ToggleKaraokeMode;
begin
  FSettings.KaraokeMode := not FSettings.KaraokeMode;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteBool('Audio', 'KaraokeMode', FSettings.KaraokeMode); finally Store.Free; end;

  if Assigned(mnuKaraokeMode) then mnuKaraokeMode.Checked := FSettings.KaraokeMode;
  if Assigned(popKaraokeMode) then popKaraokeMode.Checked := FSettings.KaraokeMode;
  ApplyAudioEffects;

  if FSettings.KaraokeMode then
    ShowOSD('Karaoke Mode (Voice Removal): ON')
  else
    ShowOSD('Karaoke Mode: OFF');
end;

procedure TFrmMain.ToggleAudioPassthrough;
begin
  FSettings.AudioPassthrough := not FSettings.AudioPassthrough;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteBool('Audio', 'AudioPassthrough', FSettings.AudioPassthrough); finally Store.Free; end;

  if Assigned(mnuAudioPassthrough) then mnuAudioPassthrough.Checked := FSettings.AudioPassthrough;
  if Assigned(popAudioPassthrough) then popAudioPassthrough.Checked := FSettings.AudioPassthrough;
  ApplyAudioEffects;

  if FSettings.AudioPassthrough then
    ShowOSD('Audio Passthrough (Bitstreaming): ON')
  else
    ShowOSD('Audio Passthrough: OFF');
end;

procedure TFrmMain.mnuVoiceClarifierClick(Sender: TObject);
begin
  ToggleVoiceClarifier;
end;

procedure TFrmMain.mnuNightModeClick(Sender: TObject);
begin
  ToggleNightMode;
end;

procedure TFrmMain.mnuHeadphoneSurroundClick(Sender: TObject);
begin
  ToggleHeadphoneSurround;
end;

procedure TFrmMain.mnuKaraokeModeClick(Sender: TObject);
begin
  ToggleKaraokeMode;
end;

procedure TFrmMain.mnuAudioPassthroughClick(Sender: TObject);
begin
  ToggleAudioPassthrough;
end;

procedure TFrmMain.ApplyVideoProfile(AProfile: Integer);
var
  C, B, G, S, H: Single;
  ProfileName: string;
begin
  case AProfile of
    1: // Cinema
    begin
      C := 1.15; B := 0.95; G := 1.10; S := 1.10; H := 0.0;
      ProfileName := 'Cinema';
    end;
    2: // Anime / Vivid
    begin
      C := 1.20; B := 1.05; G := 1.05; S := 1.35; H := 0.0;
      ProfileName := 'Anime / Vivid';
    end;
    3: // Eye Comfort / Night
    begin
      C := 0.95; B := 0.90; G := 0.95; S := 0.85; H := -5.0;
      ProfileName := 'Eye Comfort';
    end;
    4: // Noir / B&W
    begin
      C := 1.30; B := 1.00; G := 1.15; S := 0.0; H := 0.0;
      ProfileName := 'Noir (B&W)';
    end;
    5: // Sports / Vibrant
    begin
      C := 1.25; B := 1.10; G := 1.10; S := 1.30; H := 0.0;
      ProfileName := 'Sports / Vibrant';
    end;
    else
    begin
      AProfile := 0;
      C := 1.0; B := 1.0; G := 1.0; S := 1.0; H := 0.0;
      ProfileName := 'Default';
    end;
  end;

  FSettings.VideoProfile := AProfile;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteInteger('Video', 'VideoProfile', AProfile); finally Store.Free; end;

  if (FMediaPlayer <> nil) and Assigned(libvlc_video_set_adjust_int) and Assigned(libvlc_video_set_adjust_float) then
  begin
    if libvlc_video_get_adjust_int(FMediaPlayer, libvlc_adjust_Enable) = 0 then
      libvlc_video_set_adjust_int(FMediaPlayer, libvlc_adjust_Enable, 1);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Contrast, C);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Brightness, B);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Gamma, G);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Saturation, S);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Hue, H);
  end;

  ShowOSD('Video Profile: ' + ProfileName);
end;

procedure TFrmMain.CycleVideoProfile;
begin
  ApplyVideoProfile((FSettings.VideoProfile + 1) mod 6);
end;

procedure TFrmMain.ApplyBufferPreset(APreset: Integer);
const
  PresetNames: array[0..3] of string = (
    'Low Latency (300 ms - Sports/Live)',
    'Balanced (1,200 ms - Standard)',
    'Buffer Shield (3,500 ms - Unstable Net)',
    'Ultra 4K Preload (10,000 ms - 4K UHD)'
  );
begin
  APreset := EnsureRange(APreset, 0, 3);
  FSettings.BufferPreset := APreset;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteInteger('Network', 'BufferPreset', APreset); finally Store.Free; end;

  ShowOSD('Buffer Mode: ' + PresetNames[APreset]);
end;

procedure TFrmMain.CycleBufferPreset;
begin
  ApplyBufferPreset((FSettings.BufferPreset + 1) mod 4);
end;

procedure TFrmMain.ApplyLayoutPreset(APreset: Integer);
begin
  case APreset of
    0: // Normal
    begin
      pnlMenuBar.Visible := True;
      pnlBottom.Visible := True;
      if FIsBorderless then mnuBorderlessClick(nil);
      ShowOSD('Layout: Normal View');
    end;
    1: // Compact
    begin
      pnlMenuBar.Visible := False;
      pnlBottom.Visible := True;
      if FIsBorderless then mnuBorderlessClick(nil);
      ShowOSD('Layout: Compact View');
    end;
    2: // Minimalist Pure Video
    begin
      pnlMenuBar.Visible := False;
      pnlBottom.Visible := False;
      if not FIsBorderless then mnuBorderlessClick(nil);
      ShowOSD('Layout: Minimalist (Pure Video)');
    end;
  end;
end;

procedure TFrmMain.ToggleShader(AShader: TShaderFilter);
var
  CurPos: Int64;
  ShaderName: string;
  IsEnabled: Boolean;
begin
  case AShader of
    sfInvert:
    begin
      FSettings.ShaderInvert := not FSettings.ShaderInvert;
      IsEnabled := FSettings.ShaderInvert;
      ShaderName := 'Invert Colors';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'Invert', IsEnabled); finally Store.Free; end;
    end;
    sfSharpen:
    begin
      FSettings.ShaderSharpen := not FSettings.ShaderSharpen;
      IsEnabled := FSettings.ShaderSharpen;
      ShaderName := 'Sharpen Details';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'Sharpen', IsEnabled); finally Store.Free; end;
    end;
    sfEdgeDetect:
    begin
      FSettings.ShaderEdgeDetect := not FSettings.ShaderEdgeDetect;
      IsEnabled := FSettings.ShaderEdgeDetect;
      ShaderName := 'Edge Detect (Cartoon)';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'EdgeDetect', IsEnabled); finally Store.Free; end;
    end;
    sfFilmGrain:
    begin
      FSettings.ShaderFilmGrain := not FSettings.ShaderFilmGrain;
      IsEnabled := FSettings.ShaderFilmGrain;
      ShaderName := 'Film Grain';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'FilmGrain', IsEnabled); finally Store.Free; end;
    end;
    sfDenoise:
    begin
      FSettings.ShaderDenoise := not FSettings.ShaderDenoise;
      IsEnabled := FSettings.ShaderDenoise;
      ShaderName := '3D Denoise (Clean Noise)';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'Denoise', IsEnabled); finally Store.Free; end;
    end;
    sfSepia:
    begin
      FSettings.ShaderSepia := not FSettings.ShaderSepia;
      IsEnabled := FSettings.ShaderSepia;
      ShaderName := 'Sepia (Vintage)';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'Sepia', IsEnabled); finally Store.Free; end;
    end;
    sfPosterize:
    begin
      FSettings.ShaderPosterize := not FSettings.ShaderPosterize;
      IsEnabled := FSettings.ShaderPosterize;
      ShaderName := 'Posterize (Pop Art)';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'Posterize', IsEnabled); finally Store.Free; end;
    end;
    sfAnaglyph:
    begin
      FSettings.ShaderAnaglyph := not FSettings.ShaderAnaglyph;
      IsEnabled := FSettings.ShaderAnaglyph;
      ShaderName := '3D Anaglyph (Red/Cyan)';
      var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
      try Store.WriteBool('VideoShaders', 'Anaglyph', IsEnabled); finally Store.Free; end;
    end;
  else
    Exit;
  end;

  if (FMediaPlayer <> nil) and (FCurrentFile <> '') then
  begin
    CurPos := libvlc_media_player_get_time(FMediaPlayer);
    PlayFile(FCurrentFile);
    if CurPos > 0 then SeekTo(CurPos);
  end;

  if IsEnabled then
    ShowOSD('Shader: ' + ShaderName + ' ON')
  else
    ShowOSD('Shader: ' + ShaderName + ' OFF');
end;

procedure TFrmMain.ResetAllShaders;
var CurPos: Int64;
begin
  FSettings.ShaderInvert := False;
  FSettings.ShaderSharpen := False;
  FSettings.ShaderEdgeDetect := False;
  FSettings.ShaderFilmGrain := False;
  FSettings.ShaderDenoise := False;
  FSettings.ShaderSepia := False;
  FSettings.ShaderPosterize := False;
  FSettings.ShaderAnaglyph := False;

  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteBool('VideoShaders', 'Invert', False);
    Store.WriteBool('VideoShaders', 'Sharpen', False);
    Store.WriteBool('VideoShaders', 'EdgeDetect', False);
    Store.WriteBool('VideoShaders', 'FilmGrain', False);
    Store.WriteBool('VideoShaders', 'Denoise', False);
    Store.WriteBool('VideoShaders', 'Sepia', False);
    Store.WriteBool('VideoShaders', 'Posterize', False);
    Store.WriteBool('VideoShaders', 'Anaglyph', False);
  finally Store.Free; end;

  if (FMediaPlayer <> nil) and (FCurrentFile <> '') then
  begin
    CurPos := libvlc_media_player_get_time(FMediaPlayer);
    PlayFile(FCurrentFile);
    if CurPos > 0 then SeekTo(CurPos);
  end;

  ShowOSD('Shaders: All Effects Disabled');
end;

procedure TFrmMain.mnuProfileItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    ApplyVideoProfile(TMenuItem(Sender).Tag);
end;

procedure TFrmMain.mnuShaderItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    ToggleShader(TShaderFilter(TMenuItem(Sender).Tag));
end;

procedure TFrmMain.mnuResetShadersClick(Sender: TObject);
begin
  ResetAllShaders;
end;

procedure TFrmMain.mnuAudioChannelClick(Sender: TObject);
var
  Ch: Integer;
begin
  if not (Sender is TMenuItem) or (FMediaPlayer = nil) then Exit;
  Ch := TMenuItem(Sender).Tag;
  FSettings.ChannelMode := Ch;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteInteger('Audio', 'ChannelMode', Ch); finally Store.Free; end;
  if libvlc_audio_set_channel(FMediaPlayer, Ch) = 0 then FAudioPreferencesApplied := True;
  ShowOSD('Audio Channel: ' + TMenuItem(Sender).Caption);
end;

procedure TFrmMain.mnuSubtitleClick(Sender: TObject);
begin
  UpdateSubtitleTracksMenu(mnuSubTrack);
end;

procedure TFrmMain.mnuVolUpClick(Sender: TObject);
begin
  AdjustVolume(5);
end;

procedure TFrmMain.mnuVolDownClick(Sender: TObject);
begin
  AdjustVolume(-5);
end;

procedure TFrmMain.mnuMuteClick(Sender: TObject);
begin
  OnModernMuteClick(Sender);
end;

procedure TFrmMain.tbVolumeChange(Sender: TObject);
begin
  if FMediaPlayer = nil then Exit;
  libvlc_audio_set_volume(FMediaPlayer, tbVolume.Position);
  lblVolPct.Caption := Format('%d%%', [tbVolume.Position]);
  ShowOSD(Format('Volume: %d%%', [tbVolume.Position]));
end;

procedure TFrmMain.mnuAudioDelayPlusClick(Sender: TObject);
var
  D: Int64;
begin
  if FMediaPlayer = nil then Exit;
  D := libvlc_audio_get_delay(FMediaPlayer) + 50000;
  libvlc_audio_set_delay(FMediaPlayer, D);
  ShowOSD(Format('Audio Delay: %d ms', [D div 1000]));
end;

procedure TFrmMain.mnuAudioDelayMinusClick(Sender: TObject);
var
  D: Int64;
begin
  if FMediaPlayer = nil then Exit;
  D := libvlc_audio_get_delay(FMediaPlayer) - 50000;
  libvlc_audio_set_delay(FMediaPlayer, D);
  ShowOSD(Format('Audio Delay: %d ms', [D div 1000]));
end;

procedure TFrmMain.TriggerFullscreenControls;
begin
  if not FIsFullscreen or not IsWindowEnabled(Handle) then Exit;
  pnlBottom.Visible := True;
  if FDockWindow.Dismissing then FDockWindow.Present(FDockWindow.RestingBounds, True)
  else if not FDockWindow.Visible then FDockWindow.Present(FDockWindow.BoundsRect, True);
  pnlVideo.Cursor := crDefault;
  pnlVideoContainer.Cursor := crDefault;
  if Assigned(tmrFullscreenHide) then
  begin
    tmrFullscreenHide.Enabled := False;
    tmrFullscreenHide.Interval := 3000;
    tmrFullscreenHide.Enabled := True;
  end;
end;

procedure TFrmMain.WatchFullscreenMouse(Sender: TObject);
var Pt: TPoint; VideoBounds: TRect;
begin
  if FClosing or not FIsFullscreen or not Enabled or not IsWindowEnabled(Handle) then Exit;
  if GetAncestor(GetForegroundWindow, GA_ROOTOWNER) <> Handle then Exit;
  GetCursorPos(Pt);
  if FHasFullscreenMouse and (Pt = FLastFullscreenMouse) then Exit;
  FLastFullscreenMouse := Pt;
  FHasFullscreenMouse := True;
  VideoBounds := BoundsRect;
  if PtInRect(VideoBounds, Pt) then TriggerFullscreenControls;
end;

procedure TFrmMain.OnFullscreenHideTimer(Sender: TObject);
var
  Pt: TPoint;
begin
  if not FIsFullscreen then
  begin
    if Assigned(tmrFullscreenHide) then tmrFullscreenHide.Enabled := False;
    Exit;
  end;

  GetCursorPos(Pt);
  if PtInRect(FDockWindow.BoundsRect, Pt) or
     (Assigned(cardSeekPreview) and cardSeekPreview.Showing) or
     (PlayerMenuWindow <> nil) then
    Exit;

  FDockWindow.Dismiss(True);
  if Assigned(cardSeekPreview) then cardSeekPreview.Visible := False;
  pnlVideo.Cursor := crNone;
  pnlVideoContainer.Cursor := crNone;
  if Assigned(tmrFullscreenHide) then tmrFullscreenHide.Enabled := False;
end;

procedure TFrmMain.WMUserVideoDrag(var Msg: TMessage);
begin
  if Assigned(tmrClickPause) then tmrClickPause.Enabled := False;
  if FIsFullscreen then Exit;
  FVideoDragging := True;
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmMain.WMUserVideoMouseMove(var Msg: TMessage);
begin
  if FIsFullscreen then
    TriggerFullscreenControls;
end;

procedure TFrmMain.mnuFullscreenClick(Sender: TObject);
var
  Mon: TMonitor;
begin
  if Assigned(FPlaylistTimer) then FPlaylistTimer.Enabled := False;
  if FPlaylistAnimating then
  begin
    FPlaylistAnimating := False;
    pnlPlaylist.Visible := FPlaylistTarget;
  end;
  OnSeekBarLeave(nil);
  HidePlaybackOSD;
  FIsFullscreen := not FIsFullscreen;
  if FIsFullscreen then
  begin
    FHasFullscreenMouse := False;
    if Assigned(FPlaylistTimer) then FPlaylistTimer.Enabled := False;
    if FPlaylistAnimating then
    begin
      FPlaylistAnimating := False;
      pnlPlaylist.Visible := FPlaylistTarget;
    end;
    FOldWindowState := WindowState;
    FOldBounds := BoundsRect;
    FWasPlaylistVisible := pnlPlaylist.Visible;
    FWasBottomVisible := pnlBottom.Visible;

    if Assigned(modernTitleBar) then modernTitleBar.Visible := False;
    if Assigned(pnlMenuBar) then pnlMenuBar.Visible := False;
    pnlPlaylist.Visible := False;
    FPlaylistTarget := False;
    btnPlaylistToggle.IsActive := False;
    mnuViewPlaylist.Checked := False;
    popPlaylist.Checked := False;

    WindowState := wsNormal;
    var DoNotRound: DWORD := 1; // DWMWCP_DONOTROUND
    DwmSetWindowAttribute(Handle, 33, @DoNotRound, SizeOf(DoNotRound));

    Mon := Screen.MonitorFromWindow(Handle);
    if Mon <> nil then
      SetWindowPos(Handle, HWND_TOP, Mon.Left, Mon.Top, Mon.Width, Mon.Height,
        SWP_NOOWNERZORDER or SWP_FRAMECHANGED);

    // Floating control bar in fullscreen: does not resize pnlVideoContainer or recreate D3D swapchain
    pnlBottom.Align := alNone;
    pnlBottom.SetBounds(0, ClientHeight - MulDiv(94, CurrentPPI, 96), ClientWidth, MulDiv(94, CurrentPPI, 96));
    pnlBottom.Visible := True;
    pnlBottom.BringToFront;
    RepositionModernControls;
    FFullscreenMouseTimer.Enabled := True;
    TriggerFullscreenControls;
  end
  else
  begin
    if Assigned(tmrFullscreenHide) then tmrFullscreenHide.Enabled := False;
    FFullscreenMouseTimer.Enabled := False;
    FDockWindow.Dismiss;
    pnlBottom.Parent := Self;
    cardBottomDock.Align := alNone;
    cardBottomDock.CornerRadius := 14;
    pnlVideo.Cursor := crDefault;
  pnlVideoContainer.Cursor := crDefault;
    WindowState := FOldWindowState;
    if FOldWindowState = wsNormal then
      BoundsRect := FOldBounds;
    EnableDwmRoundedCorners(Handle);
    if Assigned(modernTitleBar) then modernTitleBar.Visible := not FIsBorderless;
    if Assigned(pnlMenuBar) then pnlMenuBar.Visible := not FIsBorderless;

    pnlBottom.Align := alBottom;
    pnlBottom.Visible := FWasBottomVisible;
    SetPlaylistVisible(FWasPlaylistVisible, False);
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
  end;
  RedrawWindow(Handle,nil,0,RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW);
end;

procedure TFrmMain.pnlVideoDblClick(Sender: TObject);
var Msg: TMessage;
begin
  Msg := Default(TMessage);
  WMUserVideoDblClick(Msg);
end;

procedure TFrmMain.ExecuteVideoDoubleAction(Sender: TObject);
begin
  case FSettings.DoubleClick of
    0: mnuFullscreenClick(Sender);
    1: mnuPlayPauseClick(Sender);
    2:
      begin
        cboAspect.ItemIndex := (cboAspect.ItemIndex + 1) mod cboAspect.Items.Count;
        ApplyAspectRatio(cboAspect.Text);
      end;
  end;
end;

procedure TFrmMain.pnlVideoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FVideoDownPt := Point(X, Y);
    FVideoDragging := False;
  end;
end;

procedure TFrmMain.pnlVideoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var Pt: TPoint;
begin
  if FIsFullscreen then
  begin
    GetCursorPos(Pt);
    if not FHasFullscreenMouse or (Pt <> FLastFullscreenMouse) then
    begin
      FLastFullscreenMouse := Pt;
      FHasFullscreenMouse := True;
      TriggerFullscreenControls;
    end;
  end;

  if (ssLeft in Shift) and not FVideoDragging and not FIsFullscreen and
     ((Abs(X - FVideoDownPt.X) > 4) or (Abs(Y - FVideoDownPt.Y) > 4)) then
  begin
    FVideoDragging := True;
    FClickActionApplied := False;
    if Assigned(tmrClickPause) then
      tmrClickPause.Enabled := False;
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TFrmMain.pnlVideoClick(Sender: TObject);
var
  Msg: TMessage;
begin
  if not FVideoDragging then
  begin
    FillChar(Msg, SizeOf(Msg), 0);
    WMUserVideoLeftClick(Msg);
  end;
end;

procedure TFrmMain.pnlVideoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
begin
  if Button = mbRight then
  begin
    UpdateAudioTracksMenu(popAudioTrack);
    UpdateSubtitleTracksMenu(popSubTrack);
    Pt := pnlVideo.ClientToScreen(Point(X, Y));
    PopupMenuVideoPopup(PopupMenuVideo);
    ShowPlayerMenu(Self, PopupMenuVideo.Items, Pt);
  end;
end;

procedure TFrmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  PlaylistRect: TRect;
  Origin: TPoint;
  Step: Int64;
begin
  PlaylistRect := pnlPlaylist.ClientRect;
  Origin := pnlPlaylist.ClientToScreen(Point(0, 0));
  OffsetRect(PlaylistRect, Origin.X, Origin.Y);
  if pnlPlaylist.Visible and PtInRect(PlaylistRect, MousePos) then Exit;

  if (ssShift in Shift) or (ssCtrl in Shift) then
  begin
    Step := FSettings.JumpShort;
    if ssCtrl in Shift then Step := FSettings.JumpMedium;
    if WheelDelta > 0 then JumpSeconds(Step) else JumpSeconds(-Step);
    Handled := True;
    Exit;
  end;

  if not FSettings.WheelVolume then Exit;
  if WheelDelta > 0 then AdjustVolume(5) else AdjustVolume(-5);
  Handled := True;
end;

procedure TFrmMain.PopupMenuVideoPopup(Sender: TObject);
begin
  UpdateAudioTracksMenu(popAudioTrack);
  UpdateSubtitleTracksMenu(popSubTrack);
  UpdateChaptersMenu;
  UpdateTitlesMenu;
end;

procedure TFrmMain.mnuAlwaysOnTopClick(Sender: TObject);
begin
  mnuAlwaysOnTop.Checked := not mnuAlwaysOnTop.Checked;
  if Assigned(popAlwaysOnTop) then popAlwaysOnTop.Checked := mnuAlwaysOnTop.Checked;
  if Assigned(mnuViewAlwaysOnTop) then mnuViewAlwaysOnTop.Checked := mnuAlwaysOnTop.Checked;
  if mnuAlwaysOnTop.Checked then
  begin
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    ShowOSD('Always on Top: ON');
  end
  else
  begin
    SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    ShowOSD('Always on Top: OFF');
  end;
end;

procedure TFrmMain.ApplyAspectRatio(const ARatio: string);
var
  AnsiR: AnsiString;
begin
  if FMediaPlayer = nil then Exit;
  FSettings.AspectRatio := ARatio;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Store.WriteString('Video', 'AspectRatio', ARatio);
    Store.WriteBool('Video', 'AspectAuto', ARatio = 'Default');
  finally Store.Free; end;
  if ARatio = 'Default' then
    libvlc_video_set_aspect_ratio(FMediaPlayer, nil)
  else
  begin
    AnsiR := AnsiString(ARatio);
    libvlc_video_set_aspect_ratio(FMediaPlayer, PAnsiChar(AnsiR));
  end;
  ShowOSD('Aspect: ' + ARatio);
end;

procedure TFrmMain.mnuAspectItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    ApplyAspectRatio(TMenuItem(Sender).Caption);
    cboAspect.Text := TMenuItem(Sender).Caption;
  end;
end;

procedure TFrmMain.cboAspectChange(Sender: TObject);
begin
  ApplyAspectRatio(cboAspect.Text);
end;

procedure TFrmMain.mnuCropClick(Sender: TObject);
var
  CropStr: AnsiString;
begin
  if not (Sender is TMenuItem) or (FMediaPlayer = nil) then Exit;
  CropStr := AnsiString(TMenuItem(Sender).Caption);
  FSettings.Crop := string(CropStr);
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteString('Video', 'Crop', string(CropStr)); finally Store.Free; end;
  if CropStr = 'Default' then
    libvlc_video_set_crop_geometry(FMediaPlayer, nil)
  else
    libvlc_video_set_crop_geometry(FMediaPlayer, PAnsiChar(CropStr));
  ShowOSD('Crop: ' + string(CropStr));
end;

procedure TFrmMain.mnuDeinterlaceClick(Sender: TObject);
var
  Mode: AnsiString;
begin
  if not (Sender is TMenuItem) or (FMediaPlayer = nil) then Exit;
  Mode := AnsiString(TMenuItem(Sender).Caption);
  if Mode = 'off' then FSettings.Deinterlace := 0
  else if Mode = 'auto' then FSettings.Deinterlace := 1
  else if FSettings.Deinterlace < 2 then FSettings.Deinterlace := 2;
  var Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try Store.WriteInteger('Video', 'Deinterlace', FSettings.Deinterlace); finally Store.Free; end;
  case FSettings.Deinterlace of
    0: libvlc_video_set_deinterlace(FMediaPlayer, nil);
    1: ApplyAudioEffects;
    2: libvlc_video_set_deinterlace(FMediaPlayer, 'yadif2x');
    3: libvlc_video_set_deinterlace(FMediaPlayer, 'bob');
    4: libvlc_video_set_deinterlace(FMediaPlayer, 'linear');
  end;
  ShowOSD('Deinterlace: ' + string(Mode));
end;

procedure TFrmMain.mnuSnapshotClick(Sender: TObject);
var
  SnapDir, SnapPath, BaseName, TimeStr: string;
  Utf8Snap: UTF8String;
  CurTime: Int64;
begin
  if FMediaPlayer = nil then Exit;
  SnapDir := IncludeTrailingPathDelimiter(TPath.Combine(TPath.GetPicturesPath, 'VLC Modern\Snapshots'));
  if GetEnvironmentVariable('VLC_SETTINGS_TEST_ID')<>'' then
    SnapDir := IncludeTrailingPathDelimiter(TPath.GetFullPath('build\tests\output\snapshots'));
  System.SysUtils.ForceDirectories(SnapDir);

  if (FCurrentFile <> '') and (Pos('://', FCurrentFile)=0) then
    BaseName := TPath.GetFileNameWithoutExtension(FCurrentFile)
  else
    BaseName := 'snapshot';

  CurTime := 0;
  if Assigned(libvlc_media_player_get_time) then
    CurTime := libvlc_media_player_get_time(FMediaPlayer);

  TimeStr := FormatTime(CurTime).Replace(':', '-');
  SnapPath := SnapDir + Format('%s_%s_%s.png', [BaseName, TimeStr, FormatDateTime('hhnnss', Now)]);
  Utf8Snap := UTF8Encode(SnapPath);

  if libvlc_video_take_snapshot(FMediaPlayer, 0, PAnsiChar(Utf8Snap), 0, 0) = 0 then
    ShowOSD('Snapshot Saved: ' + ExtractFileName(SnapPath))
  else
    ShowOSD('Failed to take snapshot');
end;

procedure TFrmMain.mnuCleanSnapshotClick(Sender: TObject);
begin
  TakeCleanSnapshot;
end;

procedure TFrmMain.TakeCleanSnapshot;
var
  SnapDir, SnapPath, BaseName, TimeStr: string;
  Utf8Snap: UTF8String;
  CurTime: Int64;
  SavedSpu: Integer;
begin
  if FMediaPlayer = nil then Exit;
  SnapDir := IncludeTrailingPathDelimiter(TPath.Combine(TPath.GetPicturesPath, 'VLC Modern\Snapshots'));
  if GetEnvironmentVariable('VLC_SETTINGS_TEST_ID') <> '' then
    SnapDir := IncludeTrailingPathDelimiter(TPath.GetFullPath('build\tests\output\snapshots'));
  System.SysUtils.ForceDirectories(SnapDir);

  if (FCurrentFile <> '') and (Pos('://', FCurrentFile) = 0) then
    BaseName := TPath.GetFileNameWithoutExtension(FCurrentFile)
  else
    BaseName := 'snapshot';

  CurTime := 0;
  if Assigned(libvlc_media_player_get_time) then
    CurTime := libvlc_media_player_get_time(FMediaPlayer);

  TimeStr := FormatTime(CurTime).Replace(':', '-');
  SnapPath := SnapDir + Format('%s_Clean_%s_%s.png', [BaseName, TimeStr, FormatDateTime('hhnnss', Now)]);
  Utf8Snap := UTF8Encode(SnapPath);

  SavedSpu := -1;
  if Assigned(libvlc_video_get_spu) then
    SavedSpu := libvlc_video_get_spu(FMediaPlayer);

  if (SavedSpu > 0) and Assigned(libvlc_video_set_spu) then
    libvlc_video_set_spu(FMediaPlayer, -1);

  try
    if (Assigned(libvlc_video_take_snapshot)) and (libvlc_video_take_snapshot(FMediaPlayer, 0, PAnsiChar(Utf8Snap), 0, 0) = 0) then
      ShowOSD('Clean Snapshot Saved: ' + ExtractFileName(SnapPath))
    else
      ShowOSD('Failed to take clean snapshot');
  finally
    if (SavedSpu > 0) and Assigned(libvlc_video_set_spu) then
      libvlc_video_set_spu(FMediaPlayer, SavedSpu);
  end;
end;

procedure TFrmMain.mnuDownloadOnlineSubClick(Sender: TObject);
begin
  DownloadSubtitlesOnline;
end;

procedure TFrmMain.DownloadSubtitlesOnline;
begin
  if (FCurrentFile = '') or (Pos('://', FCurrentFile) > 0) or not TFile.Exists(FCurrentFile) then
  begin
    ShowOSD('Online Subtitles: Please open a local video file first');
    Exit;
  end;

  ShowOSD('Searching OpenSubtitles...');
  var RequestedFile := FCurrentFile;
  TOpenSubtitlesDownloader.SearchAsync(RequestedFile,
    procedure(const Matches: TArray<TSubtitleCandidate>; const ErrorMsg: string)
    begin
      if (FrmMain = nil) or FrmMain.FClosing or
        not SameText(FrmMain.FCurrentFile, RequestedFile) then Exit;
      if ErrorMsg <> '' then
      begin
        FrmMain.ShowOSD('OpenSubtitles: ' + ErrorMsg);
        Exit;
      end;
      var Labels: TArray<string>;
      SetLength(Labels, Length(Matches));
      for var I := 0 to High(Matches) do
        Labels[I] := UpperCase(Matches[I].Language) + '  |  ' + Matches[I].ReleaseName;
      var Selected := PlayerChooseSubtitle(Labels);
      if Selected < 0 then Exit;
      TOpenSubtitlesDownloader.DownloadCandidateAsync(Matches[Selected].FileID,
        procedure(const SubPath: string; Success: Boolean; const ErrorMsg: string)
        begin
          if (FrmMain = nil) or FrmMain.FClosing or
            not SameText(FrmMain.FCurrentFile, RequestedFile) then
          begin
            if SubPath <> '' then System.SysUtils.DeleteFile(SubPath);
            Exit;
          end;
          if Success and (SubPath <> '') then
          begin
            if FrmMain.LoadSubtitleFile(SubPath) then
            begin
              FrmMain.FGeneratedSubtitles.Add(SubPath);
              FrmMain.ShowOSD('Subtitles downloaded');
            end
            else
            begin
              System.SysUtils.DeleteFile(SubPath);
              FrmMain.ShowOSD('OpenSubtitles: could not load downloaded subtitle');
            end;
          end
          else
            FrmMain.ShowOSD('OpenSubtitles: ' + ErrorMsg);
        end
      );
    end);
end;

procedure TFrmMain.mnuTranslateSubClick(Sender: TObject);
begin
  TranslateCurrentSubtitle;
end;

procedure TFrmMain.TranslateCurrentSubtitle;
var
  TargetSRT: string;
begin
  TargetSRT := '';
  if (FCurrentFile <> '') and (Pos('://', FCurrentFile) = 0) then
  begin
    var Base := TPath.Combine(TPath.GetDirectoryName(FCurrentFile), TPath.GetFileNameWithoutExtension(FCurrentFile));
    if TFile.Exists(Base + '.srt') then
      TargetSRT := Base + '.srt'
    else if TFile.Exists(Base + '.en.srt') then
      TargetSRT := Base + '.en.srt';
  end;

  if (TargetSRT = '') or not TFile.Exists(TargetSRT) then
  begin
    if OpenDialogSub.Execute then
      TargetSRT := OpenDialogSub.FileName;
  end;

  if (TargetSRT = '') or not TFile.Exists(TargetSRT) then
  begin
    ShowOSD('Translate Subtitles: No SRT subtitle found to translate');
    Exit;
  end;

  ShowOSD('Translating subtitles to Arabic...');
  TOpenSubtitlesDownloader.TranslateSRTAsync(
    TargetSRT,
    'ar',
    procedure(const SubPath: string; Success: Boolean; const ErrorMsg: string)
    begin
      if Success and (SubPath <> '') then
      begin
        LoadSubtitleFile(SubPath);
        ShowOSD('Translated subtitles loaded: ' + ExtractFileName(SubPath));
      end
      else
        ShowOSD('Translation failed: ' + ErrorMsg);
    end
  );
end;

procedure TFrmMain.mnuLoad3DLUTClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
begin
  OpenDlg := TOpenDialog.Create(Self);
  try
    OpenDlg.Title := 'Select 3D LUT Color Profile';
    OpenDlg.Filter := '3D LUT Files (*.cube;*.3dl;*.lut)|*.cube;*.3dl;*.lut|All Files (*.*)|*.*';
    if OpenDlg.Execute then
      Load3DLUTFile(OpenDlg.FileName);
  finally
    OpenDlg.Free;
  end;
end;

function TFrmMain.EnsureGPUShaderPipeline: Boolean;
var
  Err: string;
begin
  Result := False;
  if not Assigned(pnlVideo) or not pnlVideo.HandleAllocated then Exit;
  if FGPUShader = nil then
    FGPUShader := TD3D11ShaderRenderer.Create;
  if not FGPUShader.Initialized then
  begin
    if not FGPUShader.Initialize(pnlVideo.Handle, Max(64, pnlVideo.Width), Max(64, pnlVideo.Height), Err) then
    begin
      ShowOSD('D3D11 Shader Init Error: ' + Err);
      Exit;
    end;
  end;
  if not FGPUShaderActive then
  begin
    FGPUShaderActive := True;
    if FMediaPlayer <> nil then
    begin
      var State := libvlc_media_player_get_state(FMediaPlayer);
      var Position := libvlc_media_player_get_time(FMediaPlayer);
      libvlc_media_player_stop(FMediaPlayer);
      libvlc_media_player_set_hwnd(FMediaPlayer, nil);
      FGPUShader.AttachToPlayer(FMediaPlayer);
      if State in [libvlc_Playing, libvlc_Paused] then
      begin
        libvlc_media_player_play(FMediaPlayer);
        if (Position > 0) and not FCurrentFile.Contains('://') then SeekTo(Position);
        if State = libvlc_Paused then libvlc_media_player_set_pause(FMediaPlayer, 1);
      end;
    end;
  end;
  Result := True;
end;

procedure TFrmMain.DisableGPUShaderPipeline;
var
  Position: Int64;
  State: libvlc_state_t;
  Source: string;
begin
  if not FGPUShaderActive then Exit;
  FGPUShaderActive := False;
  State := libvlc_Stopped;
  Position := 0;
  Source := FCurrentFile;
  if FMediaPlayer <> nil then
  begin
    State := libvlc_media_player_get_state(FMediaPlayer);
    Position := libvlc_media_player_get_time(FMediaPlayer);
    // The stop joins VLC's video output before the callback state is released.
    libvlc_media_player_stop(FMediaPlayer);
    if Assigned(libvlc_video_set_callbacks) then
      libvlc_video_set_callbacks(FMediaPlayer, nil, nil, nil, nil);
    if Assigned(libvlc_video_set_format_callbacks) then
      libvlc_video_set_format_callbacks(FMediaPlayer, nil, nil);
    if Assigned(pnlVideo) and pnlVideo.HandleAllocated then
      libvlc_media_player_set_hwnd(FMediaPlayer, Pointer(pnlVideo.Handle));
  end;
  if FGPUShader <> nil then
  begin
    FGPUShader.Flags := [];
    FGPUShader.ReleaseDevice;
  end;
  if (Source <> '') and (State in [libvlc_Playing, libvlc_Paused]) then
  begin
    libvlc_media_player_play(FMediaPlayer);
    if (Position > 0) and not Source.Contains('://') then SeekTo(Position);
    if State = libvlc_Paused then libvlc_media_player_set_pause(FMediaPlayer, 1);
  end;
  if Assigned(mnuGPUAnime4K) then mnuGPUAnime4K.Checked := False;
  if Assigned(mnuGPUCAS) then mnuGPUCAS.Checked := False;
  if Assigned(mnuGPUDeband) then mnuGPUDeband.Checked := False;
  if Assigned(mnuGPUACES) then mnuGPUACES.Checked := False;
  if Assigned(mnuGPUCRT) then mnuGPUCRT.Checked := False;
  ShowOSD('GPU HLSL Pipeline Disabled (Native Zero-Copy)');
end;

procedure TFrmMain.ToggleGPUShader(AFlag: TGPUShaderFlag);
const
  FlagNames: array[TGPUShaderFlag] of string = (
    'Anime4K Edge & Line Enhance',
    'CAS Adaptive Sharpen',
    'Ordered Deband & Dither',
    'ACES Filmic HDR->SDR',
    'CRT Retro Scanlines',
    'TV->PC Levels (16-235 -> 0-255)',
    'BT.601 -> BT.709 Color Matrix',
    '3D LUT'
  );
begin
  if not EnsureGPUShaderPipeline then Exit;
  if AFlag in FGPUShader.Flags then
  begin
    FGPUShader.Flags := FGPUShader.Flags - [AFlag];
    ShowOSD('GPU Shader OFF: ' + FlagNames[AFlag]);
  end
  else
  begin
    FGPUShader.Flags := FGPUShader.Flags + [AFlag];
    ShowOSD('GPU Shader ON: ' + FlagNames[AFlag]);
  end;
  if Assigned(mnuGPUAnime4K) then mnuGPUAnime4K.Checked := gsAnime4K in FGPUShader.Flags;
  if Assigned(mnuGPUCAS) then mnuGPUCAS.Checked := gsCAS in FGPUShader.Flags;
  if Assigned(mnuGPUDeband) then mnuGPUDeband.Checked := gsDeband in FGPUShader.Flags;
  if Assigned(mnuGPUACES) then mnuGPUACES.Checked := gsACES in FGPUShader.Flags;
  if Assigned(mnuGPUCRT) then mnuGPUCRT.Checked := gsCRT in FGPUShader.Flags;
  if Assigned(mnuGPULevels) then mnuGPULevels.Checked := gsLevels16_235 in FGPUShader.Flags;
  if Assigned(mnuGPUBT601) then mnuGPUBT601.Checked := gsBT601to709 in FGPUShader.Flags;
end;

procedure TFrmMain.LoadCustomHLSLShader(const APath: string);
var
  Err: string;
begin
  if not EnsureGPUShaderPipeline then Exit;
  if FGPUShader.LoadCustomHLSL(APath, Err) then
    ShowOSD('Custom HLSL Shader Compiled: ' + ExtractFileName(APath))
  else
    ShowOSD('HLSL Compile Error: ' + Err);
end;

procedure TFrmMain.mnuGPUShaderItemClick(Sender: TObject);
begin
  if not (Sender is TMenuItem) then Exit;
  case TMenuItem(Sender).Tag of
    0: ToggleGPUShader(gsAnime4K);
    1: ToggleGPUShader(gsCAS);
    2: ToggleGPUShader(gsDeband);
    3: ToggleGPUShader(gsACES);
    4: ToggleGPUShader(gsCRT);
    5: ToggleGPUShader(gsLevels16_235);
    6: ToggleGPUShader(gsBT601to709);
  end;
end;

procedure TFrmMain.mnuGPULoadHLSLClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
begin
  OpenDlg := TOpenDialog.Create(Self);
  try
    OpenDlg.Title := 'Load Custom HLSL / PotPlayer PxShader (.hlsl, .txt)';
    OpenDlg.Filter := 'HLSL / PotPlayer Shaders (*.hlsl;*.fx;*.txt)|*.hlsl;*.fx;*.txt|All Files (*.*)|*.*';
    if OpenDlg.Execute then
      LoadCustomHLSLShader(OpenDlg.FileName);
  finally
    OpenDlg.Free;
  end;
end;

procedure TFrmMain.mnuGPUDisableClick(Sender: TObject);
begin
  DisableGPUShaderPipeline;
end;

procedure TFrmMain.mnu3DModeItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    Set3DStereoMode(TMenuItem(Sender).Tag);
end;

procedure TFrmMain.Set3DStereoMode(AMode: Integer);
var
  W, H: Cardinal;
  CropStr: AnsiString;
begin
  F3DStereoMode := EnsureRange(AMode, 0, 2);
  if Assigned(mnu3DNormal) then mnu3DNormal.Checked := (F3DStereoMode = 0);
  if Assigned(mnu3DSBS) then mnu3DSBS.Checked := (F3DStereoMode = 1);
  if Assigned(mnu3DTAB) then mnu3DTAB.Checked := (F3DStereoMode = 2);

  if (FMediaPlayer <> nil) and Assigned(libvlc_video_set_crop_geometry) then
  begin
    W := 0; H := 0;
    if Assigned(libvlc_video_get_size) then
      libvlc_video_get_size(FMediaPlayer, 0, @W, @H);
    case F3DStereoMode of
      0:
      begin
        libvlc_video_set_crop_geometry(FMediaPlayer, nil);
        ShowOSD('3D Stereo: Normal 2D');
      end;
      1:
      begin
        if (W > 0) and (H > 0) then
          CropStr := AnsiString(Format('%dx%d+0+0', [W div 2, H]))
        else
          CropStr := '16:18';
        libvlc_video_set_crop_geometry(FMediaPlayer, PAnsiChar(CropStr));
        ShowOSD('3D Stereo: Side-by-Side (SBS) -> 2D');
      end;
      2:
      begin
        if (W > 0) and (H > 0) then
          CropStr := AnsiString(Format('%dx%d+0+0', [W, H div 2]))
        else
          CropStr := '32:9';
        libvlc_video_set_crop_geometry(FMediaPlayer, PAnsiChar(CropStr));
        ShowOSD('3D Stereo: Top-and-Bottom (TAB) -> 2D');
      end;
    end;
  end;
end;

procedure TFrmMain.mnuSleepTimerItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    SetSleepTimerMinutes(TMenuItem(Sender).Tag);
end;

procedure TFrmMain.SetSleepTimerMinutes(AMinutes: Integer);
begin
  if AMinutes <= 0 then
  begin
    FSleepExpireTick := 0;
    ShowOSD('Sleep Timer: Off');
  end
  else
  begin
    FSleepExpireTick := GetTickCount64 + UInt64(AMinutes) * 60000;
    ShowOSD(Format('Sleep Timer: Player will close in %d minutes', [AMinutes]));
  end;
  if Assigned(mnuSleepOff) then mnuSleepOff.Checked := (AMinutes <= 0);
  if Assigned(mnuSleep15) then mnuSleep15.Checked := (AMinutes = 15);
  if Assigned(mnuSleep30) then mnuSleep30.Checked := (AMinutes = 30);
  if Assigned(mnuSleep60) then mnuSleep60.Checked := (AMinutes = 60);
  if Assigned(mnuSleep90) then mnuSleep90.Checked := (AMinutes = 90);
end;

procedure TFrmMain.mnuCycleAudioDeviceClick(Sender: TObject);
begin
  CycleAudioOutputDevice;
end;

procedure TFrmMain.CycleAudioOutputDevice;
var
  Head, Cur, NextDev: Plibvlc_audio_output_device_t;
  CurrentID, TargetID, TargetDesc: string;
begin
  if (FMediaPlayer = nil) or not Assigned(libvlc_audio_output_device_enum) then
  begin
    ShowOSD('Audio Device: No active player');
    Exit;
  end;
  Head := libvlc_audio_output_device_enum(FMediaPlayer);
  if Head = nil then
  begin
    ShowOSD('Audio Device: No output devices enumerated');
    Exit;
  end;
  try
    CurrentID := FSettings.AudioDeviceID;
    Cur := Head;
    NextDev := Head;
    while Cur <> nil do
    begin
      if (CurrentID <> '') and SameText(UTF8ToString(Cur^.psz_device), CurrentID) then
      begin
        if Cur^.p_next <> nil then NextDev := Cur^.p_next
        else NextDev := Head;
        Break;
      end;
      Cur := Cur^.p_next;
    end;
    TargetID := UTF8ToString(NextDev^.psz_device);
    TargetDesc := UTF8ToString(NextDev^.psz_description);
    if Assigned(libvlc_audio_output_device_set) then
      libvlc_audio_output_device_set(FMediaPlayer, nil, NextDev^.psz_device);
    FSettings.AudioDeviceID := TargetID;
    var Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
    try
      Ini.WriteString('Audio', 'DeviceID', TargetID);
    finally
      Ini.Free;
    end;
    ShowOSD('Audio Output: ' + TargetDesc);
  finally
    if Assigned(libvlc_audio_output_device_list_release) then
      libvlc_audio_output_device_list_release(Head);
  end;
end;

procedure TFrmMain.mnuSubSizePlusClick(Sender: TObject);
begin
  AdjustSubtitleSize(1);
end;

procedure TFrmMain.mnuSubSizeMinusClick(Sender: TObject);
begin
  AdjustSubtitleSize(-1);
end;

procedure TFrmMain.mnuSubMoveUpClick(Sender: TObject);
begin
  AdjustSubtitleMargin(10);
end;

procedure TFrmMain.mnuSubMoveDownClick(Sender: TObject);
begin
  AdjustSubtitleMargin(-10);
end;

procedure TFrmMain.AdjustSubtitleSize(Delta: Integer);
const
  SizeLabels: array[0..3] of string = ('Small (16)', 'Normal (22)', 'Large (28)', 'Extra Large (36)');
var
  Ini: TAppSettings;
  Idx: Integer;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Idx := EnsureRange(Ini.ReadInteger('Subtitles', 'Size', 1) + Delta, 0, 3);
    Ini.WriteInteger('Subtitles', 'Size', Idx);
  finally
    Ini.Free;
  end;
  ReloadPlayerPreferences;
  if (FMediaPlayer <> nil) and (FCurrentMedia <> nil) and
     (libvlc_media_player_get_state(FMediaPlayer) in [libvlc_Playing, libvlc_Paused]) then
    ApplyAudioEffects;
  ShowOSD('Subtitle Size: ' + SizeLabels[Idx]);
end;

procedure TFrmMain.AdjustSubtitleMargin(Delta: Integer);
var
  Ini: TAppSettings;
  NewMargin: Integer;
begin
  NewMargin := EnsureRange(FSettings.SubtitleMargin + Delta, 0, 200);
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Ini.WriteInteger('Subtitles', 'Margin', NewMargin);
  finally
    Ini.Free;
  end;
  FSettings.SubtitleMargin := NewMargin;
  if (FMediaPlayer <> nil) and (FCurrentMedia <> nil) and
     (libvlc_media_player_get_state(FMediaPlayer) in [libvlc_Playing, libvlc_Paused]) then
    ApplyAudioEffects;
  ShowOSD(Format('Subtitle Vertical Margin: %d px', [NewMargin]));
end;

procedure TFrmMain.Load3DLUTFile(const ALutPath: string);
var
  Profile: TLut3DProfile;
  Err: string;
  Ini: TAppSettings;
begin
  if not TLut3DProfile.LoadFromCube(ALutPath, Profile, Err) then
  begin
    ShowOSD('3D LUT Error: ' + Err);
    Exit;
  end;

  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Ini.WriteString('Video', 'Lut3DPath', ALutPath);
  finally
    Ini.Free;
  end;
  FSettings.Lut3DPath := ALutPath;

  if EnsureGPUShaderPipeline and FGPUShader.UploadLut3D(Profile, Err) then
  begin
    ShowOSD(Format('GPU 3D LUT Active: %s (%dx%dx%d Texture3D)', [Profile.Title, Profile.Size, Profile.Size, Profile.Size]));
    Exit;
  end;

  if FMediaPlayer <> nil then
  begin
    EnsureVideoAdjustEnabled;
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Contrast, Profile.Contrast);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Brightness, Profile.Brightness);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Gamma, Profile.Gamma);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Saturation, Profile.Saturation);
    libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Hue, Profile.Hue);
  end;

  ShowOSD(Format('3D LUT Applied: %s (%dx%dx%d)', [Profile.Title, Profile.Size, Profile.Size, Profile.Size]));
end;

procedure TFrmMain.mnuScalingItemClick(Sender: TObject);
var
  TagVal: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  TagVal := TMenuItem(Sender).Tag;
  SetScalingAlgorithm(TagVal);
end;

procedure TFrmMain.SetScalingAlgorithm(AMode: Integer);
const
  ModeNames: array[0..3] of string = (
    'Spline36 (Sharp High-Quality)',
    'Lanczos (Anti-Aliased)',
    'Bicubic (Balanced)',
    'Bilinear (Fast)'
  );
var
  Ini: TAppSettings;
  SafeMode: Integer;
begin
  SafeMode := EnsureRange(AMode, 0, 3);
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Ini.WriteInteger('Video', 'ScalingMode', SafeMode);
  finally
    Ini.Free;
  end;
  FSettings.ScalingMode := SafeMode;

  if Assigned(mnuScaleSpline36) then mnuScaleSpline36.Checked := (SafeMode = 0);
  if Assigned(mnuScaleLanczos) then mnuScaleLanczos.Checked := (SafeMode = 1);
  if Assigned(mnuScaleBicubic) then mnuScaleBicubic.Checked := (SafeMode = 2);
  if Assigned(mnuScaleBilinear) then mnuScaleBilinear.Checked := (SafeMode = 3);

  if (FMediaPlayer <> nil) and (FCurrentMedia <> nil) and
     (libvlc_media_player_get_state(FMediaPlayer) in [libvlc_Playing, libvlc_Paused]) then
    ApplyAudioEffects;

  ShowOSD('Video Scaler: ' + ModeNames[SafeMode]);
end;

procedure RendererDiscovererCallback(p_event: Plibvlc_event_t; p_user_data: Pointer); cdecl;
var
  Form: TFrmMain;
  Item: Plibvlc_renderer_item_t;
  NamePtr: PAnsiChar;
  DevName: string;
begin
  if (p_event = nil) or (p_user_data = nil) then Exit;
  Form := TFrmMain(p_user_data);
  if p_event^.i_type = libvlc_RendererDiscovererItemAdded then
  begin
    Item := Plibvlc_renderer_item_t(p_event^.u_ptr);
    if (Item <> nil) and Assigned(libvlc_renderer_item_name) then
    begin
      NamePtr := libvlc_renderer_item_name(Item);
      if NamePtr <> nil then
        DevName := UTF8ToString(NamePtr)
      else
        DevName := 'Smart Display';
      if Assigned(libvlc_renderer_item_hold) then
        libvlc_renderer_item_hold(Item);
      TThread.Queue(nil,
        TThreadProcedure(procedure
        begin
          if (Form <> nil) and (not Form.FClosing) then
          begin
            if Form.FRendererItems = nil then Form.FRendererItems := TList<Plibvlc_renderer_item_t>.Create;
            if Form.FRendererNames = nil then Form.FRendererNames := TStringList.Create;
            if Form.FRendererItems.IndexOf(Item) < 0 then
            begin
              Form.FRendererItems.Add(Item);
              Form.FRendererNames.Add(DevName);
              Form.ShowOSD('Cast Device Found: ' + DevName);
            end
            else if Assigned(libvlc_renderer_item_release) then
              libvlc_renderer_item_release(Item);
          end;
        end));
    end;
  end;
end;

procedure TFrmMain.ReleaseRenderers;
var
  I: Integer;
  EM: Plibvlc_event_manager_t;
begin
  if FRendererDiscoverer <> nil then
  begin
    try
      if Assigned(libvlc_renderer_discoverer_event_manager) and Assigned(libvlc_event_detach) then
      begin
        EM := libvlc_renderer_discoverer_event_manager(FRendererDiscoverer);
        if EM <> nil then
          libvlc_event_detach(EM, libvlc_RendererDiscovererItemAdded, @RendererDiscovererCallback, Self);
      end;
      if Assigned(libvlc_renderer_discoverer_stop) then
        libvlc_renderer_discoverer_stop(FRendererDiscoverer);
      if Assigned(libvlc_renderer_discoverer_release) then
        libvlc_renderer_discoverer_release(FRendererDiscoverer);
    except
    end;
    FRendererDiscoverer := nil;
  end;
  if FRendererItems <> nil then
  begin
    if Assigned(libvlc_renderer_item_release) then
      for I := 0 to FRendererItems.Count - 1 do
        if FRendererItems[I] <> nil then
          libvlc_renderer_item_release(FRendererItems[I]);
    FreeAndNil(FRendererItems);
  end;
  FreeAndNil(FRendererNames);
end;

procedure TFrmMain.mnuRendererClick(Sender: TObject);
begin
  UpdateRendererMenu(mnuRenderer);
end;

procedure TFrmMain.UpdateRendererMenu(AMenu: TMenuItem);
var
  Item: TMenuItem;
  I: Integer;
begin
  if AMenu = nil then Exit;
  AMenu.Clear;

  Item := TMenuItem.Create(AMenu);
  Item.Caption := 'Local Display & Audio';
  Item.Tag := -1;
  Item.Checked := (FActiveRendererIndex < 0);
  Item.OnClick := OnRendererSelect;
  AMenu.Add(Item);

  if (FRendererNames <> nil) and (FRendererNames.Count > 0) then
  begin
    Item := TMenuItem.Create(AMenu);
    Item.Caption := '-';
    AMenu.Add(Item);

    for I := 0 to FRendererNames.Count - 1 do
    begin
      Item := TMenuItem.Create(AMenu);
      Item.Caption := 'Cast: ' + FRendererNames[I];
      Item.Tag := I;
      Item.Checked := (FActiveRendererIndex = I);
      Item.OnClick := OnRendererSelect;
      AMenu.Add(Item);
    end;
  end;

  Item := TMenuItem.Create(AMenu);
  Item.Caption := '-';
  AMenu.Add(Item);

  Item := TMenuItem.Create(AMenu);
  Item.Caption := 'Scan for Smart Screens (DLNA / Chromecast)...';
  Item.OnClick := OnScanRenderersClick;
  AMenu.Add(Item);
end;

procedure TFrmMain.OnRendererSelect(Sender: TObject);
var
  Idx: Integer;
  RItem: Plibvlc_renderer_item_t;
begin
  if (FMediaPlayer = nil) or not (Sender is TMenuItem) then Exit;
  Idx := TMenuItem(Sender).Tag;
  if (Idx >= 0) and (FRendererItems <> nil) and (Idx < FRendererItems.Count) then
  begin
    RItem := FRendererItems[Idx];
    if Assigned(libvlc_media_player_set_renderer) and (libvlc_media_player_set_renderer(FMediaPlayer, RItem) = 0) then
    begin
      FActiveRendererIndex := Idx;
      ShowOSD('Casting to: ' + FRendererNames[Idx]);
    end
    else
      ShowOSD('Cast: Failed to connect to ' + FRendererNames[Idx]);
  end
  else
  begin
    if Assigned(libvlc_media_player_set_renderer) then
      libvlc_media_player_set_renderer(FMediaPlayer, nil);
    FActiveRendererIndex := -1;
    ShowOSD('Renderer: Local Display & Audio active');
  end;
end;

procedure TFrmMain.OnScanRenderersClick(Sender: TObject);
begin
  ScanForRenderers;
end;

procedure TFrmMain.ScanForRenderers;
var
  Utf8Name: UTF8String;
  EM: Plibvlc_event_manager_t;
begin
  if FVlcInstance = nil then
  begin
    ShowOSD('Cast: LibVLC instance not ready');
    Exit;
  end;

  if not Assigned(libvlc_renderer_discoverer_new) then
  begin
    ShowOSD('Cast: Renderer discovery API not available in current LibVLC');
    Exit;
  end;

  ReleaseRenderers;
  FRendererItems := TList<Plibvlc_renderer_item_t>.Create;
  FRendererNames := TStringList.Create;
  FActiveRendererIndex := -1;

  Utf8Name := UTF8Encode('microdns_renderer');
  FRendererDiscoverer := libvlc_renderer_discoverer_new(FVlcInstance, PAnsiChar(Utf8Name));
  if FRendererDiscoverer = nil then
  begin
    Utf8Name := UTF8Encode('chromecast');
    FRendererDiscoverer := libvlc_renderer_discoverer_new(FVlcInstance, PAnsiChar(Utf8Name));
  end;

  if FRendererDiscoverer <> nil then
  begin
    if Assigned(libvlc_renderer_discoverer_event_manager) and Assigned(libvlc_event_attach) then
    begin
      EM := libvlc_renderer_discoverer_event_manager(FRendererDiscoverer);
      if EM <> nil then
        libvlc_event_attach(EM, libvlc_RendererDiscovererItemAdded, @RendererDiscovererCallback, Self);
    end;
    if Assigned(libvlc_renderer_discoverer_start) and (libvlc_renderer_discoverer_start(FRendererDiscoverer) = 0) then
      ShowOSD('Cast: Scanning network for DLNA & Chromecast devices...')
    else
      ShowOSD('Cast: Could not start renderer scan');
  end
  else
    ShowOSD('Cast: No renderer discoverer module available');
end;

procedure TFrmMain.mnuHotkeysClick(Sender: TObject);
begin
  ShowHotkeysReference;
end;

procedure TFrmMain.LoadCustomHotkeys;
const
  Actions: array[0..10] of string = (
    'PlayPause', 'Fullscreen', 'Snapshot', 'CleanSnapshot', 'BossKey',
    'Borderless', 'NextFrame', 'PrevFrame', 'CycleAudio', 'CycleSub', 'DownloadSub'
  );
  Defaults: array[0..10] of Integer = (
    VK_SPACE, Ord('F'), scShift or Ord('S'), scCtrl or scAlt or scShift or Ord('S'),
    VK_F11, VK_F10, VK_OEM_PERIOD, VK_OEM_COMMA, Ord('B'), Ord('V'),
    scCtrl or scShift or Ord('U')
  );
var
  Ini: TAppSettings;
  I: Integer;
begin
  if FCustomHotkeys = nil then
    FCustomHotkeys := TDictionary<string, TShortCut>.Create;
  FCustomHotkeys.Clear;
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    for I := 0 to High(Actions) do
      FCustomHotkeys.Add(Actions[I], TShortCut(Ini.ReadInteger('Hotkeys', Actions[I], Defaults[I])));
  finally
    Ini.Free;
  end;
end;

function TFrmMain.TryHandleCustomHotkey(Key: Word; Shift: TShiftState): Boolean;
var
  PressedSC, BoundSC: TShortCut;
  Pair: TPair<string, TShortCut>;
begin
  Result := False;
  if Key = 0 then Exit;
  if FCustomHotkeys = nil then LoadCustomHotkeys;
  PressedSC := Vcl.Menus.ShortCut(Key, Shift);
  if PressedSC = 0 then Exit;

  for Pair in FCustomHotkeys do
  begin
    BoundSC := Pair.Value;
    if (BoundSC <> 0) and (BoundSC = PressedSC) then
    begin
      if Pair.Key = 'PlayPause' then mnuPlayPauseClick(nil)
      else if Pair.Key = 'Fullscreen' then mnuFullscreenClick(nil)
      else if Pair.Key = 'Snapshot' then mnuSnapshotClick(nil)
      else if Pair.Key = 'CleanSnapshot' then TakeCleanSnapshot
      else if Pair.Key = 'BossKey' then begin if FSettings.BossKeyHide then ToggleBossKey; end
      else if Pair.Key = 'Borderless' then mnuBorderlessClick(nil)
      else if Pair.Key = 'NextFrame' then mnuNextFrameClick(nil)
      else if Pair.Key = 'PrevFrame' then mnuPrevFrameClick(nil)
      else if Pair.Key = 'CycleAudio' then CycleAudioTrack
      else if Pair.Key = 'CycleSub' then CycleSubtitleTrack
      else if Pair.Key = 'DownloadSub' then DownloadSubtitlesOnline
      else Continue;
      Result := True;
      Exit;
    end;
  end;
end;

type
  TShortcutList = class(TListBox)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

  TShortcutCapture = class(THotKey)
  private
    procedure PaintCapture(DC: HDC);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  end;

  THotkeyManagerForm = class(TForm)
  public
    Lst: TListBox;
    HkBox: THotKey;
    ActionKeys: TArray<string>;
    ActionLabels: TArray<string>;
    HotkeysMap: TDictionary<string, TShortCut>;
    OwnerMain: TFrmMain;
    procedure RefreshList;
    procedure DrawShortcut(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure OnListClick(Sender: TObject);
    procedure OnAssignClick(Sender: TObject);
    procedure OnResetClick(Sender: TObject);
  end;

procedure TShortcutList.WndProc(var Message: TMessage);
begin
  if (Message.Msg = CN_DRAWITEM) and (Message.LParam <> 0) then
    PDrawItemStruct(Message.LParam)^.itemState :=
      PDrawItemStruct(Message.LParam)^.itemState and not ODS_FOCUS;
  inherited;
end;

procedure TShortcutCapture.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not WS_BORDER;
  Params.ExStyle := Params.ExStyle and not (WS_EX_CLIENTEDGE or WS_EX_STATICEDGE);
end;

procedure TShortcutCapture.PaintCapture(DC: HDC);
var Surface: TCanvas; Bounds, TextBounds: TRect; KeyText: string;
begin
  Surface := TCanvas.Create;
  try
    Surface.Handle := DC;
    Bounds := ClientRect;
    Surface.Brush.Color := DP_COLOR_SURFACE;
    Surface.FillRect(Bounds);
    var Diameter: Single := MulDiv(14, CurrentPPI, 96);
    var Edge := DP_COLOR_BORDER;
    if Focused then Edge := DP_COLOR_ACCENT;
    var Graphic := TGPGraphics.Create(DC);
    var Outline := TGPGraphicsPath.Create;
    var Fill := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_BG));
    var Stroke := TGPPen.Create(MakeGDIColor(Edge), 1.0);
    try
      Graphic.SetSmoothingMode(SmoothingModeAntiAlias);
      Outline.AddArc(1.0, 1.0, Diameter, Diameter, 180, 90);
      Outline.AddArc(Bounds.Right - Diameter - 1.0, 1.0, Diameter, Diameter, 270, 90);
      Outline.AddArc(Bounds.Right - Diameter - 1.0, Bounds.Bottom - Diameter - 1.0,
        Diameter, Diameter, 0, 90);
      Outline.AddArc(1.0, Bounds.Bottom - Diameter - 1.0, Diameter, Diameter, 90, 90);
      Outline.CloseFigure;
      Graphic.FillPath(Fill, Outline);
      Graphic.DrawPath(Stroke, Outline);
    finally
      Stroke.Free;
      Fill.Free;
      Outline.Free;
      Graphic.Free;
    end;
    Surface.Font.Assign(Font);
    Surface.Font.Color := DP_COLOR_TEXT;
    Surface.Brush.Style := bsClear;
    KeyText := ShortCutToText(HotKey);
    if KeyText = '' then
    begin
      KeyText := 'Press a shortcut';
      Surface.Font.Color := DP_COLOR_MUTED;
    end;
    TextBounds := Bounds;
    InflateRect(TextBounds, -MulDiv(11, CurrentPPI, 96), 0);
    Surface.TextRect(TextBounds, KeyText, [tfLeft, tfSingleLine, tfVerticalCenter, tfEndEllipsis, tfNoPrefix]);
  finally
    Surface.Handle := 0;
    Surface.Free;
  end;
end;

procedure TShortcutCapture.WndProc(var Message: TMessage);
var Paint: TPaintStruct; DC: HDC; Redraw: Boolean;
begin
  case Message.Msg of
    WM_NCCALCSIZE, WM_NCPAINT:
      begin Message.Result := 0; Exit; end;
    WM_ERASEBKGND:
      begin Message.Result := 1; Exit; end;
    WM_PRINTCLIENT:
      begin PaintCapture(HDC(Message.WParam)); Message.Result := 0; Exit; end;
    WM_PAINT:
      begin
        DC := HDC(Message.WParam);
        if DC = 0 then DC := BeginPaint(Handle, Paint);
        try PaintCapture(DC); finally
          if Message.WParam = 0 then EndPaint(Handle, Paint);
        end;
        Message.Result := 0;
        Exit;
      end;
    WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SETFOCUS, WM_KILLFOCUS,
    HKM_SETHOTKEY, WM_LBUTTONDOWN:
      begin
        Redraw := IsWindowVisible(Handle);
        if Redraw then DefWindowProc(Handle, WM_SETREDRAW, 0, 0);
        try inherited; finally
          if Redraw then DefWindowProc(Handle, WM_SETREDRAW, 1, 0);
        end;
        if Focused then HideCaret(Handle);
        Invalidate;
        Exit;
      end;
  end;
  inherited;
end;

procedure THotkeyManagerForm.RefreshList;
var
  I, Sel: Integer;
begin
  Sel := Lst.ItemIndex;
  Lst.Items.BeginUpdate;
  try
    Lst.Items.Clear;
    for I := 0 to High(ActionKeys) do
      Lst.Items.Add(ActionLabels[I]);
  finally
    Lst.Items.EndUpdate;
  end;
  if (Sel >= 0) and (Sel < Lst.Items.Count) then
    Lst.ItemIndex := Sel
  else if Lst.Items.Count > 0 then
    Lst.ItemIndex := 0;
end;

procedure THotkeyManagerForm.DrawShortcut(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var Key: TShortCut; KeyText: string; Chip: TRect; Padding: Integer;
begin
  if Index < 0 then Exit;
  Key := 0;
  HotkeysMap.TryGetValue(ActionKeys[Index], Key);
  KeyText := ShortCutToText(Key);
  if KeyText = '' then KeyText := 'Unassigned';
  Padding := MulDiv(12, CurrentPPI, 96);
  with Lst.Canvas do
  begin
    Brush.Color := DP_COLOR_SURFACE;
    FillRect(Rect);
    if odSelected in State then
    begin
      Brush.Color := DP_COLOR_HOVER;
      Pen.Color := DP_COLOR_HOVER;
      RoundRect(Rect.Left + 2, Rect.Top + 2, Rect.Right - 2, Rect.Bottom - 2, 10, 10);
      Brush.Color := DP_COLOR_ACCENT;
      Pen.Color := DP_COLOR_ACCENT;
      RoundRect(Rect.Left + 3, Rect.Top + 7, Rect.Left + 6, Rect.Bottom - 7, 3, 3);
    end;
    Font.Color := DP_COLOR_TEXT;
    Font.Style := [];
    Brush.Style := bsClear;
    TextOut(Rect.Left + Padding, Rect.Top + (Rect.Height - TextHeight('Ag')) div 2, ActionLabels[Index]);
    Brush.Style := bsSolid;
    Font.Style := [fsBold];
    Chip := System.Types.Rect(Rect.Right - Padding - TextWidth(KeyText) - 20,
      Rect.Top + 5, Rect.Right - Padding, Rect.Bottom - 5);
    Brush.Color := DP_COLOR_BG;
    Pen.Color := DP_COLOR_BORDER;
    RoundRect(Chip.Left, Chip.Top, Chip.Right, Chip.Bottom, 8, 8);
    Brush.Style := bsClear;
    Font.Color := DP_COLOR_ACCENT;
    TextOut(Chip.Left + 10, Chip.Top + (Chip.Height - TextHeight('Ag')) div 2, KeyText);
    Brush.Style := bsSolid;
  end;
end;

procedure THotkeyManagerForm.OnListClick(Sender: TObject);
var
  SC: TShortCut;
begin
  if (Lst.ItemIndex >= 0) and (Lst.ItemIndex <= High(ActionKeys)) then
  begin
    SC := 0;
    HotkeysMap.TryGetValue(ActionKeys[Lst.ItemIndex], SC);
    HkBox.HotKey := SC;
  end;
end;

procedure THotkeyManagerForm.OnAssignClick(Sender: TObject);
var
  Ini: TAppSettings;
  Idx: Integer;
begin
  Idx := Lst.ItemIndex;
  if (Idx < 0) or (Idx > High(ActionKeys)) then Exit;
  HotkeysMap.AddOrSetValue(ActionKeys[Idx], HkBox.HotKey);
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Ini.WriteInteger('Hotkeys', ActionKeys[Idx], Integer(HkBox.HotKey));
  finally
    Ini.Free;
  end;
  RefreshList;
  OwnerMain.ShowOSD('Hotkey Updated: ' + ActionLabels[Idx] + ' = ' + ShortCutToText(HkBox.HotKey));
end;

procedure THotkeyManagerForm.OnResetClick(Sender: TObject);
var
  Ini: TAppSettings;
  I: Integer;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    for I := 0 to High(ActionKeys) do
      Ini.DeleteKey('Hotkeys', ActionKeys[I]);
  finally
    Ini.Free;
  end;
  OwnerMain.LoadCustomHotkeys;
  RefreshList;
  OwnerMain.ShowOSD('Hotkeys reset to defaults');
end;

procedure TFrmMain.ShowHotkeysReference;
var
  Dlg: THotkeyManagerForm;
  BtnAssign, BtnReset, BtnClose: TButton;
  LblInfo: TLabel;
  CurSC: TShortCut;
begin
  if FCustomHotkeys = nil then LoadCustomHotkeys;

  Dlg := THotkeyManagerForm.CreateNew(Self);
  try
    Dlg.OwnerMain := Self;
    Dlg.HotkeysMap := FCustomHotkeys;
    Dlg.ActionKeys := [
      'PlayPause', 'Fullscreen', 'Snapshot', 'CleanSnapshot', 'BossKey',
      'Borderless', 'NextFrame', 'PrevFrame', 'CycleAudio', 'CycleSub', 'DownloadSub'
    ];
    Dlg.ActionLabels := [
      'Play / Pause', 'Toggle Fullscreen', 'Take Snapshot', 'Take Clean Snapshot (No Subs)',
      'Boss Key (Instant Hide)', 'Borderless Window', 'Next Frame', 'Previous Frame',
      'Cycle Audio Track', 'Cycle Subtitle Track', 'Download Online Subtitles'
    ];
    Dlg.Caption := 'Keyboard Shortcuts';
    Dlg.ClientWidth := 540;
    Dlg.ClientHeight := 498;
    Dlg.Position := poMainFormCenter;
    Dlg.BorderStyle := bsSingle;

    LblInfo := TLabel.Create(Dlg);
    LblInfo.Parent := Dlg;
    LblInfo.Left := 16;
    LblInfo.Top := 14;
    LblInfo.Caption := 'Select an action and press the keys you want to assign.';

    Dlg.Lst := TShortcutList.Create(Dlg);
    Dlg.Lst.Parent := Dlg;
    Dlg.Lst.Left := 16;
    Dlg.Lst.Top := 38;
    Dlg.Lst.Width := 508;
    Dlg.Lst.Height := 352;
    Dlg.Lst.Font.Name := 'Segoe UI';
    Dlg.Lst.Font.Size := 10;
    Dlg.Lst.Style := lbOwnerDrawFixed;
    Dlg.Lst.ItemHeight := 31;
    Dlg.Lst.IntegralHeight := False;
    Dlg.Lst.OnDrawItem := Dlg.DrawShortcut;

    Dlg.HkBox := TShortcutCapture.Create(Dlg);
    Dlg.HkBox.Parent := Dlg;
    Dlg.HkBox.Left := 16;
    Dlg.HkBox.Top := 410;
    Dlg.HkBox.Width := 210;
    Dlg.HkBox.Height := 28;
    Dlg.HkBox.Hint := 'Press the key combination to record';
    Dlg.HkBox.ShowHint := True;

    BtnAssign := TButton.Create(Dlg);
    BtnAssign.Parent := Dlg;
    BtnAssign.Left := 236;
    BtnAssign.Top := 410;
    BtnAssign.Width := 110;
    BtnAssign.Height := 28;
    BtnAssign.Caption := 'Assign Key';

    BtnReset := TButton.Create(Dlg);
    BtnReset.Parent := Dlg;
    BtnReset.Left := 354;
    BtnReset.Top := 410;
    BtnReset.Width := 170;
    BtnReset.Height := 28;
    BtnReset.Caption := 'Reset Defaults';

    BtnClose := TButton.Create(Dlg);
    BtnClose.Parent := Dlg;
    BtnClose.Left := 424;
    BtnClose.Top := 454;
    BtnClose.Width := 100;
    BtnClose.Height := 30;
    BtnClose.Caption := 'Close';
    BtnClose.ModalResult := mrOk;

    Dlg.RefreshList;
    if Dlg.Lst.ItemIndex >= 0 then
    begin
      CurSC := 0;
      FCustomHotkeys.TryGetValue(Dlg.ActionKeys[Dlg.Lst.ItemIndex], CurSC);
      Dlg.HkBox.HotKey := CurSC;
    end;

    Dlg.Lst.OnClick := Dlg.OnListClick;
    BtnAssign.OnClick := Dlg.OnAssignClick;
    BtnReset.OnClick := Dlg.OnResetClick;

    ApplyPlayerAppearance(Dlg);
    Dlg.Constraints.MinWidth := Dlg.Width;
    Dlg.Constraints.MaxWidth := Dlg.Width;
    Dlg.Constraints.MinHeight := Dlg.Height;
    Dlg.Constraints.MaxHeight := Dlg.Height;
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TFrmMain.mnuAddSubClick(Sender: TObject);
begin
  if (FMediaPlayer <> nil) and OpenDialogSub.Execute then
    LoadSubtitleFile(OpenDialogSub.FileName);
end;

procedure TFrmMain.mnuAddSecondarySubClick(Sender: TObject);
begin
  if FCurrentFile = '' then
  begin
    ShowOSD('Please open a video first');
    Exit;
  end;
  OpenDialogSub.Title := 'Select Secondary Subtitle (Displays at Top)';
  if OpenDialogSub.Execute then
  begin
    if LoadSecondarySubtitleFile(OpenDialogSub.FileName) then
      ShowOSD('Dual Subtitles Active (Primary Bottom + Secondary Top)')
    else
      ShowOSD('Secondary Subtitle: SRT format required for dual merge');
  end;
end;

function TFrmMain.LoadSubtitleFile(const Path: string): Boolean;
var
  Utf8Sub: UTF8String;
begin
  Result := False;
  if (FMediaPlayer = nil) or not FileExists(Path) then Exit;
  Utf8Sub := UTF8Encode(Path);
  Result := libvlc_video_set_subtitle_file(FMediaPlayer, PAnsiChar(Utf8Sub)) = 1;
  if Result and not FLoadingCombinedSubtitles then FPrimarySubtitlePath := Path;
  if Result then
  begin
    var Options: TStringList;
    if not FPlaylistOptions.TryGetValue(FCurrentFile, Options) then
    begin Options := TStringList.Create; FPlaylistOptions.Add(FCurrentFile, Options); end;
    for var I := Options.Count - 1 downto 0 do
      if StartsText(':sub-file=', Options[I]) then Options.Delete(I);
    Options.Add(':sub-file=' + Path);
  end;
  if Result then
    ShowOSD('Subtitle Loaded: ' + ExtractFileName(Path))
  else
    ShowOSD('Failed to load subtitle');
end;

function TFrmMain.LoadSecondarySubtitleFile(const Path: string): Boolean;
begin
  Result := False;
  if (FPrimarySubtitlePath = '') or not SameText(ExtractFileExt(FPrimarySubtitlePath), '.srt') or
     not SameText(ExtractFileExt(Path), '.srt') then Exit;
  var Destination := TPath.Combine(TPath.GetTempPath, 'VLCModern_dual_' + TPath.GetRandomFileName + '.ass');
  try
    try
      if not BuildDualSRT(FPrimarySubtitlePath, Path, Destination, FSettings.SubtitleFont) then Exit;
      FGeneratedSubtitles.Add(Destination);
      FLoadingCombinedSubtitles := True;
      try Result := LoadSubtitleFile(Destination);
      finally FLoadingCombinedSubtitles := False; end;
    except Result := False; end;
  finally
    if not Result then System.SysUtils.DeleteFile(Destination);
  end;
end;

function TFrmMain.LoadAudioFile(const Path: string): Boolean;
var Media: Plibvlc_media_t; URI: PAnsiChar; Name: UTF8String; SlaveOption: string; Options: TStringList;
begin
  Result := False;
  if (FMediaPlayer = nil) or (FCurrentMedia = nil) or not FileExists(Path) or
     not Assigned(libvlc_media_player_add_slave) then Exit;
  Name := UTF8Encode(Path);
  Media := libvlc_media_new_path(FVlcInstance, PAnsiChar(Name));
  if Media = nil then Exit;
  try
    URI := libvlc_media_get_mrl(Media);
    if URI = nil then Exit;
    try
      Result := libvlc_media_player_add_slave(FMediaPlayer, 1, URI, True) = 0;
      SlaveOption := ':input-slave=' + UTF8ToString(URI);
    finally libvlc_free(URI); end;
  finally libvlc_media_release(Media); end;
  if Result then
  begin
    if not FPlaylistOptions.TryGetValue(FCurrentFile, Options) then
    begin Options := TStringList.Create; FPlaylistOptions.Add(FCurrentFile, Options); end;
    for var I := Options.Count - 1 downto 0 do
      if StartsText(':input-slave=', Options[I]) then Options.Delete(I);
    Options.Add(SlaveOption);
    ShowOSD('External audio loaded: ' + ExtractFileName(Path));
  end;
end;

procedure TFrmMain.mnuSubDelayPlusClick(Sender: TObject);
var
  D: Int64;
begin
  if FMediaPlayer = nil then Exit;
  D := libvlc_video_get_spu_delay(FMediaPlayer) + 50000;
  libvlc_video_set_spu_delay(FMediaPlayer, D);
  ShowOSD(Format('Sub Delay: %d ms', [D div 1000]));
end;

procedure TFrmMain.mnuSubDelayMinusClick(Sender: TObject);
var
  D: Int64;
begin
  if FMediaPlayer = nil then Exit;
  D := libvlc_video_get_spu_delay(FMediaPlayer) - 50000;
  libvlc_video_set_spu_delay(FMediaPlayer, D);
  ShowOSD(Format('Sub Delay: %d ms', [D div 1000]));
end;

procedure TFrmMain.UpdatePanScan;
var
  NewW, NewH: Integer;
begin
  if FPanScanZoom = 1.0 then
  begin
    pnlVideo.Align := alClient;
    FPanScanX := 0;
    FPanScanY := 0;
  end
  else
  begin
    pnlVideo.Align := alNone;
    NewW := Round(pnlVideoContainer.ClientWidth * FPanScanZoom);
    NewH := Round(pnlVideoContainer.ClientHeight * FPanScanZoom);
    pnlVideo.SetBounds(
      (pnlVideoContainer.ClientWidth - NewW) div 2 + FPanScanX,
      (pnlVideoContainer.ClientHeight - NewH) div 2 + FPanScanY,
      NewW, NewH
    );
  end;
  ShowOSD(Format('Zoom & Position: %.1fx', [FPanScanZoom]));
end;

procedure TFrmMain.mnuPanScanItemClick(Sender: TObject);
var
  TagVal: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  TagVal := (Sender as TMenuItem).Tag;
  case TagVal of
    5: // Reset
    begin
      FPanScanZoom := 1.0;
      FPanScanX := 0;
      FPanScanY := 0;
      UpdatePanScan;
    end;
    9: // Zoom In
    begin
      FPanScanZoom := FPanScanZoom + 0.1;
      UpdatePanScan;
    end;
    1: // Zoom Out
    begin
      if FPanScanZoom > 0.4 then FPanScanZoom := FPanScanZoom - 0.1;
      UpdatePanScan;
    end;
    4: // Left
    begin
      FPanScanX := FPanScanX - 25;
      UpdatePanScan;
    end;
    6: // Right
    begin
      FPanScanX := FPanScanX + 25;
      UpdatePanScan;
    end;
    8: // Up
    begin
      FPanScanY := FPanScanY - 25;
      UpdatePanScan;
    end;
    2: // Down
    begin
      FPanScanY := FPanScanY + 25;
      UpdatePanScan;
    end;
    169: // 16:9 TV
    begin
      ApplyAspectRatio('16:9');
      FPanScanZoom := 1.15;
      UpdatePanScan;
    end;
    43: // 4:3 TV
    begin
      ApplyAspectRatio('4:3');
      FPanScanZoom := 1.0;
      UpdatePanScan;
    end;
  end;
end;

procedure TFrmMain.mnuWindowSizeItemClick(Sender: TObject);
var
  TagVal, VW, VH: Cardinal;
  ExtraW: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  TagVal := (Sender as TMenuItem).Tag;
  VW := 0;
  VH := 0;
  if FMediaPlayer <> nil then
    libvlc_video_get_size(FMediaPlayer, 0, @VW, @VH);

  if (VW = 0) or (VH = 0) then
  begin
    VW := 1280;
    VH := 720;
  end;

  if pnlPlaylist.Visible then ExtraW := pnlPlaylist.Width else ExtraW := 0;

  case TagVal of
    50:
    begin
      WindowState := wsNormal;
      ClientWidth := (Integer(VW) div 2) + ExtraW;
      ClientHeight := (Integer(VH) div 2) + pnlBottom.Height;
    end;
    100:
    begin
      WindowState := wsNormal;
      ClientWidth := Integer(VW) + ExtraW;
      ClientHeight := Integer(VH) + pnlBottom.Height;
    end;
    200:
    begin
      WindowState := wsNormal;
      ClientWidth := (Integer(VW) * 2) + ExtraW;
      ClientHeight := (Integer(VH) * 2) + pnlBottom.Height;
    end;
    999:
    begin
      WindowState := wsNormal;
      SetBounds(Screen.WorkAreaLeft, Screen.WorkAreaTop, Screen.WorkAreaWidth, Screen.WorkAreaHeight);
    end;
  end;
  Position := poScreenCenter;
  ShowOSD(Format('Window Size: %d%%', [TagVal]));
end;

procedure TFrmMain.mnuBorderlessClick(Sender: TObject);
begin
  if FIsFullscreen then Exit;
  FIsBorderless := not FIsBorderless;
  mnuBorderless.Checked := FIsBorderless;
  modernTitleBar.Visible := not FIsBorderless;
  pnlMenuBar.Visible := not FIsBorderless;
  RepositionModernControls;
  ShowOSD('Cinema mode: ' + BoolToStr(FIsBorderless, True));
end;

procedure TFrmMain.ToggleBossKey;
begin
  ClosePlayerMenus;
  if not FIsBossHidden then
  begin
    FIsBossHidden := True;
    FPreBossWindowState := WindowState;
    FPreBossPlaying := False;
    if FMediaPlayer <> nil then
    begin
      FPreBossMuted := (libvlc_audio_get_mute(FMediaPlayer) = 1);
      libvlc_audio_set_mute(FMediaPlayer, 1);
      FPreBossPlaying := libvlc_media_player_get_state(FMediaPlayer) = libvlc_Playing;
      if FPreBossPlaying then libvlc_media_player_pause(FMediaPlayer);
    end;
    Application.Minimize;
  end
  else
  begin
    FIsBossHidden := False;
    Show;
    WindowState := FPreBossWindowState;
    BringToFront;
    if FMediaPlayer <> nil then
    begin
      libvlc_audio_set_mute(FMediaPlayer, Ord(FPreBossMuted));
      if FPreBossPlaying then libvlc_media_player_play(FMediaPlayer);
    end;
  end;
end;

procedure TFrmMain.PlayerActivated(Sender: TObject);
begin
  if FUIReady and not FClosing and FIsBossHidden and not IsIconic(Handle) then
    ToggleBossKey;
end;

procedure TFrmMain.mnuBossKeyClick(Sender: TObject);
begin
  ToggleBossKey;
end;

procedure TFrmMain.mnuStatsHUDClick(Sender: TObject);
begin
  lblStatsHUD.Visible := not lblStatsHUD.Visible;
  mnuStatsHUD.Checked := lblStatsHUD.Visible;
  if Assigned(popStatsHUD) then
    popStatsHUD.Checked := lblStatsHUD.Visible;
  if lblStatsHUD.Visible then
    UpdateStatsHUD;
end;

procedure TFrmMain.UpdateStatsHUD;
var
  W, H: Cardinal;
  Fps, Rate: Single;
  CurTime, TotalTime: Int64;
  InfoStr: string;
  Stats: TLibVLCMediaStats;
  Media: Plibvlc_media_t;
  HasStats: Boolean;
begin
  if not lblStatsHUD.Visible or (FMediaPlayer = nil) then Exit;

  W := 0;
  H := 0;
  libvlc_video_get_size(FMediaPlayer, 0, @W, @H);
  Fps := libvlc_media_player_get_fps(FMediaPlayer);
  Rate := libvlc_media_player_get_rate(FMediaPlayer);
  CurTime := libvlc_media_player_get_time(FMediaPlayer);
  TotalTime := libvlc_media_player_get_length(FMediaPlayer);

  HasStats := False;
  FillChar(Stats, SizeOf(Stats), 0);
  if Assigned(libvlc_media_player_get_media) and Assigned(libvlc_media_get_stats) then
  begin
    Media := libvlc_media_player_get_media(FMediaPlayer);
    if Media <> nil then
      HasStats := (libvlc_media_get_stats(Media, @Stats) <> 0);
  end;

  if HasStats and (Stats.InputBitrate > 0) then
  begin
    InfoStr :=
      Format('--- Realtime Diagnostics HUD ---'#13#10 +
             'File: %s'#13#10 +
             'Resolution: %dx%d'#13#10 +
             'FPS: %.2f fps'#13#10 +
             'Speed: %.2fx'#13#10 +
             'Time: %s / %s'#13#10 +
             'Input Bitrate: %.1f kb/s (Demux: %.1f kb/s)'#13#10 +
             'Video Frames: %d displayed, %d dropped'#13#10 +
             'Audio Buffers: %d played, %d lost'#13#10 +
             'Volume: %d%%'#13#10 +
             'Zoom & Position: %.1fx'#13#10 +
             'Audio Delay: %d ms | Sub Delay: %d ms',
             [ExtractFileName(FCurrentFile), W, H, Fps, Rate,
              FormatTime(CurTime), FormatTime(TotalTime),
              Stats.InputBitrate * 8000.0, Stats.DemuxBitrate * 8000.0,
              Stats.DisplayedPictures, Stats.LostPictures,
              Stats.PlayedAudioBuffers, Stats.LostAudioBuffers,
              tbVolume.Position, FPanScanZoom,
              libvlc_audio_get_delay(FMediaPlayer) div 1000,
              libvlc_video_get_spu_delay(FMediaPlayer) div 1000]);
  end
  else
  begin
    InfoStr :=
      Format('--- Diagnostics HUD ---'#13#10 +
             'File: %s'#13#10 +
             'Resolution: %dx%d'#13#10 +
             'FPS: %.2f fps'#13#10 +
             'Speed: %.2fx'#13#10 +
             'Time: %s / %s'#13#10 +
             'Volume: %d%% (Booster to 200%%)'#13#10 +
             'Video Zoom: %.1fx'#13#10 +
             'Audio Delay: %d ms'#13#10 +
             'Subtitle Delay: %d ms',
             [ExtractFileName(FCurrentFile), W, H, Fps, Rate,
              FormatTime(CurTime), FormatTime(TotalTime),
              tbVolume.Position, FPanScanZoom,
              libvlc_audio_get_delay(FMediaPlayer) div 1000,
              libvlc_video_get_spu_delay(FMediaPlayer) div 1000]);
  end;

  lblStatsHUD.Caption := InfoStr;
  lblStatsHUD.BringToFront;
end;

procedure TFrmMain.mnuAfterPlaybackItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    FAfterPlayback := (Sender as TMenuItem).Tag;
    (Sender as TMenuItem).Checked := True;
    ShowOSD('After Playback: ' + (Sender as TMenuItem).Caption);
  end;
end;

procedure TFrmMain.UpdateChaptersMenu;
var
  Count, Cur, I: Integer;
  Mi: TMenuItem;
begin
  if mnuChapters = nil then Exit;
  mnuChapters.Clear;
  if (FMediaPlayer = nil) or not Assigned(libvlc_media_player_get_chapter_count) then Exit;
  try
    Count := libvlc_media_player_get_chapter_count(FMediaPlayer);
    Cur := -1;
    if Assigned(libvlc_media_player_get_chapter) then
      Cur := libvlc_media_player_get_chapter(FMediaPlayer);
    if Count <= 0 then
    begin
      Mi := TMenuItem.Create(mnuChapters);
      Mi.Caption := 'No Chapters';
      Mi.Enabled := False;
      mnuChapters.Add(Mi);
    end
    else
    begin
      for I := 0 to Count - 1 do
      begin
        Mi := TMenuItem.Create(mnuChapters);
        Mi.Caption := Format('Chapter %d', [I + 1]);
        Mi.Tag := I;
        Mi.Checked := (I = Cur);
        Mi.RadioItem := True;
        Mi.OnClick := OnChapterItemClick;
        mnuChapters.Add(Mi);
      end;
    end;
  except
  end;
end;

procedure TFrmMain.OnChapterItemClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and (FMediaPlayer <> nil) then
  begin
    libvlc_media_player_set_chapter(FMediaPlayer, (Sender as TMenuItem).Tag);
    ShowOSD(Format('Switched to Chapter %d', [(Sender as TMenuItem).Tag + 1]));
  end;
end;

procedure TFrmMain.mnuPlaybackClick(Sender: TObject);
begin
  UpdateChaptersMenu;
  UpdateTitlesMenu;
  if Assigned(mnuSkipOpening) then
    mnuSkipOpening.Checked := FSettings.SkipOpening;
  if Assigned(mnuSkipEnding) then
    mnuSkipEnding.Checked := FSettings.SkipEnding;
end;

procedure TFrmMain.UpdateTitlesMenu;
var
  Count, CurTitle, I: Integer;
  Mi: TMenuItem;
begin
  if mnuTitle = nil then Exit;
  mnuTitle.Clear;
  if (FMediaPlayer = nil) or not Assigned(libvlc_media_player_get_title_count) then
  begin
    Mi := TMenuItem.Create(mnuTitle);
    Mi.Caption := 'No Titles Available';
    Mi.Enabled := False;
    mnuTitle.Add(Mi);
    Exit;
  end;

  try
    Count := libvlc_media_player_get_title_count(FMediaPlayer);
    if Count <= 0 then
    begin
      Mi := TMenuItem.Create(mnuTitle);
      Mi.Caption := 'No Titles Available';
      Mi.Enabled := False;
      mnuTitle.Add(Mi);
      Exit;
    end;

    CurTitle := -1;
    if Assigned(libvlc_media_player_get_title) then
      CurTitle := libvlc_media_player_get_title(FMediaPlayer);

    for I := 0 to Count - 1 do
    begin
      Mi := TMenuItem.Create(mnuTitle);
      Mi.Caption := Format('Title %d', [I + 1]);
      Mi.Tag := I;
      Mi.RadioItem := True;
      Mi.Checked := (I = CurTitle);
      Mi.OnClick := OnTitleItemClick;
      mnuTitle.Add(Mi);
    end;
  except
  end;
end;

procedure TFrmMain.OnTitleItemClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and (FMediaPlayer <> nil) and Assigned(libvlc_media_player_set_title) then
  begin
    libvlc_media_player_set_title(FMediaPlayer, (Sender as TMenuItem).Tag);
    ShowOSD(Format('Switched to Title %d', [(Sender as TMenuItem).Tag + 1]));
  end;
end;

procedure TFrmMain.InitEQPresetsMenu;
var
  Count, I: Cardinal;
  PName: PAnsiChar;
  Mi, PopMi: TMenuItem;
begin
  if not IsLibVLCLoaded or not Assigned(libvlc_audio_equalizer_get_preset_count) then Exit;
  if Assigned(mnuEQPresets) then mnuEQPresets.Clear;
  if Assigned(popEQPresets) then popEQPresets.Clear;

  if Assigned(mnuEQPresets) then
  begin
    Mi := TMenuItem.Create(mnuEQPresets);
    Mi.Caption := 'Flat (Default / Off)';
    Mi.Tag := 0;
    Mi.OnClick := OnEQPresetItemClick;
    mnuEQPresets.Add(Mi);
  end;

  if Assigned(popEQPresets) then
  begin
    PopMi := TMenuItem.Create(popEQPresets);
    PopMi.Caption := 'Flat (Default / Off)';
    PopMi.Tag := 0;
    PopMi.OnClick := OnEQPresetItemClick;
    popEQPresets.Add(PopMi);
  end;

  try
    Count := libvlc_audio_equalizer_get_preset_count();
    for I := 0 to Count - 1 do
    begin
      PName := libvlc_audio_equalizer_get_preset_name(I);
      if PName <> nil then
      begin
        if Assigned(mnuEQPresets) then
        begin
          Mi := TMenuItem.Create(mnuEQPresets);
          Mi.Caption := string(AnsiString(PName));
          Mi.Tag := I + 1;
          Mi.OnClick := OnEQPresetItemClick;
          mnuEQPresets.Add(Mi);
        end;
        if Assigned(popEQPresets) then
        begin
          PopMi := TMenuItem.Create(popEQPresets);
          PopMi.Caption := string(AnsiString(PName));
          PopMi.Tag := I + 1;
          PopMi.OnClick := OnEQPresetItemClick;
          popEQPresets.Add(PopMi);
        end;
      end;
    end;
  except
  end;
end;

procedure TFrmMain.OnEQPresetItemClick(Sender: TObject);
begin
  if not (Sender is TMenuItem) then Exit;
  if FrmEffects = nil then
    FrmEffects := TFrmEffects.Create(Self);
  FrmEffects.ApplyPresetIndex((Sender as TMenuItem).Tag);
  ShowOSD('Equalizer: ' + (Sender as TMenuItem).Caption);
end;

procedure TFrmMain.UpdateAudioDevicesMenu(AMenu: TMenuItem);
var
  DevList, Head: Plibvlc_audio_output_device_t;
  Mi: TMenuItem;
begin
  if (FMediaPlayer = nil) or (AMenu = nil) or not Assigned(libvlc_audio_output_device_enum) then Exit;
  AMenu.Clear;
  try
    DevList := libvlc_audio_output_device_enum(FMediaPlayer);
    if DevList = nil then
    begin
      Mi := TMenuItem.Create(AMenu);
      Mi.Caption := 'Default Audio Device';
      Mi.Enabled := False;
      AMenu.Add(Mi);
      Exit;
    end;

    Head := DevList;
    while Head <> nil do
    begin
      Mi := TMenuItem.Create(AMenu);
      if Head^.psz_description <> nil then
        Mi.Caption := string(Head^.psz_description)
      else
        Mi.Caption := 'Audio Device';

      if Head^.psz_device <> nil then
        Mi.Hint := string(Head^.psz_device)
      else
        Mi.Hint := '';

      Mi.OnClick := OnAudioDeviceSelect;
      AMenu.Add(Mi);
      Head := Head^.p_next;
    end;
    if Assigned(libvlc_audio_output_device_list_release) then
      libvlc_audio_output_device_list_release(DevList);
  except
  end;
end;

procedure TFrmMain.OnAudioDeviceSelect(Sender: TObject);
var
  DevId: AnsiString;
begin
  if (Sender is TMenuItem) and (FMediaPlayer <> nil) and Assigned(libvlc_audio_output_device_set) then
  begin
    DevId := AnsiString((Sender as TMenuItem).Hint);
    try
      libvlc_audio_output_device_set(FMediaPlayer, nil, PAnsiChar(DevId));
      ShowOSD('Audio Output: ' + (Sender as TMenuItem).Caption);
    except
    end;
  end;
end;

procedure TFrmMain.UpdateAudioTracksMenu(AMenu: TMenuItem);
var
  Tracks, Cur: Plibvlc_track_description_t;
  MI: TMenuItem;
  ActiveTrack: Integer;
begin
  if (FMediaPlayer = nil) or (AMenu = nil) or not Assigned(libvlc_audio_get_track_description) then Exit;
  AMenu.Clear;
  try
    ActiveTrack := -1;
    if Assigned(libvlc_audio_get_track) then
      ActiveTrack := libvlc_audio_get_track(FMediaPlayer);
    Tracks := libvlc_audio_get_track_description(FMediaPlayer);
    Cur := Tracks;
    while Cur <> nil do
    begin
      MI := TMenuItem.Create(AMenu);
      if Cur^.psz_name <> nil then
        MI.Caption := UTF8ToString(Cur^.psz_name)
      else
        MI.Caption := Format('Track %d', [Cur^.i_id]);
      MI.Tag := Cur^.i_id;
      MI.RadioItem := True;
      MI.Checked := (Cur^.i_id = ActiveTrack);
      MI.OnClick := OnAudioTrackSelect;
      AMenu.Add(MI);
      Cur := Cur^.p_next;
    end;
    if (Tracks <> nil) and Assigned(libvlc_track_description_list_release) then
      libvlc_track_description_list_release(Tracks);
  except
  end;
end;

procedure TFrmMain.OnAudioTrackSelect(Sender: TObject);
begin
  if (Sender is TMenuItem) and (FMediaPlayer <> nil) and Assigned(libvlc_audio_set_track) then
  begin
    libvlc_audio_set_track(FMediaPlayer, TMenuItem(Sender).Tag);
    TMenuItem(Sender).Checked := True;
    ShowOSD('Audio Track: ' + TMenuItem(Sender).Caption);
  end;
end;

procedure TFrmMain.UpdateSubtitleTracksMenu(AMenu: TMenuItem);
var
  Tracks, Cur: Plibvlc_track_description_t;
  MI: TMenuItem;
  ActiveTrack: Integer;
begin
  if (FMediaPlayer = nil) or (AMenu = nil) or not Assigned(libvlc_video_get_spu_description) then Exit;
  AMenu.Clear;
  try
    ActiveTrack := -1;
    if Assigned(libvlc_video_get_spu) then
      ActiveTrack := libvlc_video_get_spu(FMediaPlayer);
    Tracks := libvlc_video_get_spu_description(FMediaPlayer);
    Cur := Tracks;
    while Cur <> nil do
    begin
      MI := TMenuItem.Create(AMenu);
      if Cur^.psz_name <> nil then
        MI.Caption := UTF8ToString(Cur^.psz_name)
      else
        MI.Caption := Format('Subtitle %d', [Cur^.i_id]);
      MI.Tag := Cur^.i_id;
      MI.RadioItem := True;
      MI.Checked := (Cur^.i_id = ActiveTrack);
      MI.OnClick := OnSubtitleTrackSelect;
      AMenu.Add(MI);
      Cur := Cur^.p_next;
    end;
    if (Tracks <> nil) and Assigned(libvlc_track_description_list_release) then
      libvlc_track_description_list_release(Tracks);
  except
  end;
end;

procedure TFrmMain.OnSubtitleTrackSelect(Sender: TObject);
begin
  if (Sender is TMenuItem) and (FMediaPlayer <> nil) then
  begin
    libvlc_video_set_spu(FMediaPlayer, TMenuItem(Sender).Tag);
    TMenuItem(Sender).Checked := True;
    ShowOSD('Subtitle: ' + TMenuItem(Sender).Caption);
  end;
end;

procedure TFrmMain.mnuOpenVltSkinClick(Sender: TObject);
begin
  ShowOSD('Dark appearance active');
end;

procedure TFrmMain.PopulateThemesMenu(AMenu: TMenuItem);
var
  MI: TMenuItem;
begin
  if AMenu = nil then Exit;
  AMenu.Clear;

  MI := TMenuItem.Create(AMenu);
  MI.Caption := 'Windows dark';
  MI.Checked := True;
  MI.RadioItem := True;
  MI.OnClick := OnThemeSelect;
  AMenu.Add(MI);

  MI := TMenuItem.Create(AMenu);
  MI.Caption := 'Default Dark Theme';
  MI.OnClick := mnuOpenVltSkinClick;
  AMenu.Add(MI);
end;

procedure TFrmMain.OnThemeSelect(Sender: TObject);
begin
  if Sender is TMenuItem then
    TMenuItem(Sender).Checked := True;
  ShowOSD('VLC Modern Dark active');
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
  if Assigned(btnTitleMax) then
    if WindowState = wsMaximized then btnTitleMax.IconKind := ikRestore
    else btnTitleMax.IconKind := ikMaximize;
  RepositionModernControls;
  if FGPUShaderActive and (FGPUShader <> nil) and Assigned(pnlVideo) then
    FGPUShader.Resize(Max(1, pnlVideo.Width), Max(1, pnlVideo.Height));
  if Assigned(pnlVideo) and (not FPlaybackStarted or (FMediaPlayer = nil)) then
    pnlVideo.Invalidate;
end;

procedure TFrmMain.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CAPTION or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX;
end;

procedure TFrmMain.CreateWnd;
var Frame: Winapi.UxTheme.TMargins;
begin
  inherited;
  if FIsFullscreen then Exit;
  Frame.cxLeftWidth := 1; Frame.cxRightWidth := 1;
  Frame.cyTopHeight := 1; Frame.cyBottomHeight := 1;
  DwmExtendFrameIntoClientArea(Handle, Frame);
  EnableDwmRoundedCorners(Handle);
end;

procedure TFrmMain.WMNCCalcSize(var Msg: TWMNCCalcSize);
var
  Mon: TMonitor;
begin
  Msg.Result := 0;
  if Msg.CalcValidRects then
  begin
    Msg.Result := 0;
    if FIsFullscreen then
    begin
      Mon := Screen.MonitorFromWindow(Handle);
      if Mon <> nil then
        Msg.CalcSize_Params.rgrc[0] := Mon.BoundsRect;
    end
    else if WindowState = wsMaximized then
    begin
      Mon := Screen.MonitorFromWindow(Handle);
      if Mon <> nil then
        Msg.CalcSize_Params.rgrc[0] := Mon.WorkareaRect;
    end;
  end;
end;

procedure TFrmMain.OnDockMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TFrmMain.WMWindowPosChanging(var Msg:TWMWindowPosChanging);
begin
  inherited;
  if FIsFullscreen or (WindowState<>wsNormal) or (Msg.WindowPos=nil) then Exit;
  var Pos:=Msg.WindowPos;
  var X:=Pos.x; var Y:=Pos.y; var W:=Pos.cx; var H:=Pos.cy;
  if Pos.flags and SWP_NOMOVE<>0 then begin X:=Left; Y:=Top; end;
  if Pos.flags and SWP_NOSIZE<>0 then begin W:=Width; H:=Height; end;
  var Work:=Screen.MonitorFromRect(Rect(X,Y,X+W,Y+H)).WorkareaRect;
  W:=Min(Max(1,W),Work.Width); H:=Min(Max(1,H),Work.Height);
  X:=EnsureRange(X,Work.Left,Work.Right-W); Y:=EnsureRange(Y,Work.Top,Work.Bottom-H);
  if (X<>Left) or (Y<>Top) then Pos.flags:=Pos.flags and not SWP_NOMOVE;
  if (W<>Width) or (H<>Height) then Pos.flags:=Pos.flags and not SWP_NOSIZE;
  Pos.x:=X; Pos.y:=Y; Pos.cx:=W; Pos.cy:=H;
end;

procedure TFrmMain.WMGetMinMaxInfo(var Msg:TWMGetMinMaxInfo);
begin
  inherited;
  if FIsFullscreen then Exit;
  var Monitor:=Screen.MonitorFromWindow(Handle);
  var Work:=Monitor.WorkareaRect;
  Msg.MinMaxInfo.ptMaxPosition:=Point(Work.Left-Monitor.Left,Work.Top-Monitor.Top);
  Msg.MinMaxInfo.ptMaxSize:=Point(Work.Width,Work.Height);
  Msg.MinMaxInfo.ptMaxTrackSize:=Msg.MinMaxInfo.ptMaxSize;
  Msg.MinMaxInfo.ptMinTrackSize:=Point(Min(Constraints.MinWidth,Work.Width),Min(Constraints.MinHeight,Work.Height));
end;

procedure TFrmMain.WMNCHitTest(var Msg: TWMNCHitTest);
var
  Pt, ScreenPt, ScreenMaxTopLeft: TPoint;
  BorderWidth: Integer;
  ScreenMaxRect: TRect;
  Ctrl: TControl;
begin
  if FIsFullscreen then begin Msg.Result := HTCLIENT; Exit; end;
  inherited;
  Pt := ScreenToClient(SmallPointToPoint(Msg.Pos));
  BorderWidth := MulDiv(6, CurrentPPI, 96);

  // 1. Resizing borders when not maximized
  if WindowState <> wsMaximized then
  begin
    if Pt.Y < BorderWidth then
    begin
      if Pt.X < BorderWidth then begin Msg.Result := HTTOPLEFT; Exit; end;
      if Pt.X > ClientWidth - BorderWidth then begin Msg.Result := HTTOPRIGHT; Exit; end;
      Msg.Result := HTTOP; Exit;
    end;
    if Pt.Y > ClientHeight - BorderWidth then
    begin
      if Pt.X < BorderWidth then begin Msg.Result := HTBOTTOMLEFT; Exit; end;
      if Pt.X > ClientWidth - BorderWidth then begin Msg.Result := HTBOTTOMRIGHT; Exit; end;
      Msg.Result := HTBOTTOM; Exit;
    end;
    if Pt.X < BorderWidth then begin Msg.Result := HTLEFT; Exit; end;
    if Pt.X > ClientWidth - BorderWidth then begin Msg.Result := HTRIGHT; Exit; end;
  end;

  // 2. Maximize Button for Windows 11 Snap Layouts hover flyout!
  if Assigned(btnTitleMax) and btnTitleMax.Visible then
  begin
    ScreenMaxTopLeft := btnTitleMax.ClientToScreen(Point(0, 0));
    ScreenMaxRect := Rect(ScreenMaxTopLeft.X, ScreenMaxTopLeft.Y,
      ScreenMaxTopLeft.X + btnTitleMax.Width, ScreenMaxTopLeft.Y + btnTitleMax.Height);
    if PtInRect(ScreenMaxRect, SmallPointToPoint(Msg.Pos)) then
    begin
      Msg.Result := HTMAXBUTTON;
      Exit;
    end;
  end;

  // 3. Caption / Drag Areas (Titlebar, Menu Bar background)
  if (Pt.Y >= 0) and (Pt.Y <= modernTitleBar.Height + pnlMenuBar.Height) then
  begin
    ScreenPt := SmallPointToPoint(Msg.Pos);
    if (btnTitleMin <> nil) and PtInRect(btnTitleMin.ClientRect, btnTitleMin.ScreenToClient(ScreenPt)) then Exit;
    if (btnTitleMax <> nil) and PtInRect(btnTitleMax.ClientRect, btnTitleMax.ScreenToClient(ScreenPt)) then Exit;
    if (btnTitleClose <> nil) and PtInRect(btnTitleClose.ClientRect, btnTitleClose.ScreenToClient(ScreenPt)) then Exit;

    if (pnlMenuBar <> nil) and (Pt.Y > modernTitleBar.Height) then
    begin
      Ctrl := pnlMenuBar.ControlAtPos(pnlMenuBar.ScreenToClient(ScreenPt), True);
      if (Ctrl <> nil) and (Ctrl is TModernVectorButton) then Exit;
    end;

    Msg.Result := HTCAPTION;
    Exit;
  end;
end;

procedure TFrmMain.mnuMediaInfoClick(Sender: TObject);
begin
  if not Assigned(FrmMediaInfo) then
  begin
    FrmMediaInfo := TFrmMediaInfo.Create(Self);
    EnableDwmRoundedCorners(FrmMediaInfo.Handle);
  end;
  FrmMediaInfo.UpdateMediaInfo(FCurrentFile, FCurrentMedia, FMediaPlayer);
  HidePlaybackOSD;
  FrmMediaInfo.ShowModal;
end;

procedure TFrmMain.mnuEffectsClick(Sender: TObject);
begin
  if Assigned(FrmPreferences) then FrmPreferences.DetachEffects(nil);
  if not Assigned(FrmEffects) then
  begin
    FrmEffects := TFrmEffects.Create(Self);
    EnableDwmRoundedCorners(FrmEffects.Handle);
  end;
  FrmEffects.InitializeWithPlayer;
  HidePlaybackOSD;
  if FDockWindow.Visible then FDockWindow.Dismiss;
  FrmEffects.ShowModal;
end;

procedure TFrmMain.mnuViewPlaylistClick(Sender: TObject);
begin
  OnModernPlaylistToggle(Sender);
end;

procedure TFrmMain.mnuMinimalClick(Sender: TObject);
begin
  FMinimalMode := not FMinimalMode;
  mnuMinimal.Checked := FMinimalMode;
  pnlBottom.Visible := not FMinimalMode;
end;

procedure TFrmMain.mnuAboutClick(Sender: TObject);
var
  AboutDlg: TFrmAbout;
begin
  AboutDlg := TFrmAbout.Create(Self);
  try
    AboutDlg.ShowModal;
  finally
    AboutDlg.Free;
  end;
end;

procedure TFrmMain.tbProgressChange(Sender: TObject);
begin
  if FUpdatingTrackBar or (FMediaPlayer = nil) then Exit;

  if (GetAsyncKeyState(VK_LBUTTON) < 0) or tbProgress.Focused then
  begin
    try
      libvlc_media_player_set_position(FMediaPlayer, tbProgress.Position / 1000.0);
    except
    end;
  end;
end;

procedure TFrmMain.btnAddMediaClick(Sender: TObject);
begin
  mnuOpenFileClick(Sender);
end;

procedure TFrmMain.btnRemoveMediaClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lstPlaylist.ItemIndex;
  if (Idx >= 0) and (Idx < FPlaylistPaths.Count) then
  begin
    if Idx = FCurrentPlaylistIndex then
    begin
      mnuStopClick(nil);
      FCurrentPlaylistIndex := -1;
    end
    else if Idx < FCurrentPlaylistIndex then Dec(FCurrentPlaylistIndex);
    FPlaylistPaths.Delete(Idx);
    lstPlaylist.Items.Delete(Idx);
  end;
end;

procedure TFrmMain.btnClearPlaylistClick(Sender: TObject);
begin
  mnuStopClick(nil);
  FPlaylistPaths.Clear;
  lstPlaylist.Items.Clear;
  FCurrentPlaylistIndex := -1;
end;

procedure TFrmMain.btnLoopModeClick(Sender: TObject);
begin
  OnModernRepeatClick(Sender);
end;

procedure TFrmMain.btnShuffleClick(Sender: TObject);
var
  I, J: Integer;
  Tmp: string;
begin
  if FPlaylistPaths.Count < 2 then Exit;
  Randomize;
  for I := FPlaylistPaths.Count - 1 downto 1 do
  begin
    J := Random(I + 1);
    Tmp := FPlaylistPaths[I];
    FPlaylistPaths[I] := FPlaylistPaths[J];
    FPlaylistPaths[J] := Tmp;

    Tmp := lstPlaylist.Items[I];
    lstPlaylist.Items[I] := lstPlaylist.Items[J];
    lstPlaylist.Items[J] := Tmp;
  end;
  ShowOSD('Playlist Shuffled');
end;

procedure TFrmMain.lstPlaylistDblClick(Sender: TObject);
begin
  if lstPlaylist.ItemIndex >= 0 then
    PlayMediaAtIndex(lstPlaylist.ItemIndex);
end;

procedure TFrmMain.tmrUpdateTimer(Sender: TObject);
var
  State: libvlc_state_t;
  Pos: Single;
  CurTime, TotalLen: Int64;
  CurrentVolume: Integer;
  Muted: Boolean;
begin
  if FClosing or (FMediaPlayer = nil) then Exit;

  try
    if (FSleepExpireTick > 0) and (GetTickCount64 >= FSleepExpireTick) then
    begin
      FSleepExpireTick := 0;
      ShowOSD('Sleep Timer Expired - Closing Player');
      Close;
      Exit;
    end;
    ProcessMediaImports;
    State := libvlc_media_player_get_state(FMediaPlayer);

    if State = libvlc_Error then
    begin
      if not FPlaybackFailed then ShowOSD('Unable to open this file or stream. Check the source and connection.');
      FPlaybackFailed := True;
      Exit;
    end;
    if State = libvlc_Ended then
    begin
      if not FPlaybackStarted then
      begin
        FPlaybackFailed := True;
        mnuStopClick(nil);
        ShowOSD('No playable media was received from this source.');
        Exit;
      end;
      if FAfterPlayback > 0 then
      begin
        case FAfterPlayback of
          1: mnuNextClick(nil); // Play Next File
          2: PlayMediaAtIndex(FCurrentPlaylistIndex); // Loop
          3: Close; // Close Player
          4: SetSystemPowerState(True, False); // Sleep / Standby
          5: ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE, 0); // Shutdown PC
        end;
        Exit;
      end;

      case FLoopMode of
        lmLoopOne:
        begin
          if FCurrentPlaylistIndex >= 0 then
            PlayMediaAtIndex(FCurrentPlaylistIndex);
        end;
        lmLoopAll:
        begin
          mnuNextClick(nil);
        end;
        lmOff:
        begin
          if FSettings.AutoPlayNext and (FCurrentPlaylistIndex < FPlaylistPaths.Count - 1) then
            mnuNextClick(nil)
          else
            mnuStopClick(nil);
        end;
      end;
      Exit;
    end;

    if (State = libvlc_Playing) or (State = libvlc_Paused) then
    begin
      if not FVideoPreferencesApplied then
      begin
        var VideoW, VideoH: Cardinal;
        if (libvlc_video_get_size(FMediaPlayer, 0, @VideoW, @VideoH) = 0) and (VideoW > 0) then
        begin
          var Aspect := UTF8Encode(FSettings.AspectRatio);
          if (FSettings.AspectRatio = 'Default') and (FSettings.Transform in [1, 3, 6, 7]) and (VideoH > 0) then
          begin
            Aspect := UTF8Encode(Format('%d:%d', [VideoH, VideoW]));
            libvlc_video_set_aspect_ratio(FMediaPlayer, PAnsiChar(Aspect));
          end
          else if FSettings.AspectRatio = 'Default' then libvlc_video_set_aspect_ratio(FMediaPlayer, nil)
          else libvlc_video_set_aspect_ratio(FMediaPlayer, PAnsiChar(Aspect));
          var Crop := UTF8Encode(FSettings.Crop);
          if FSettings.Crop = 'Default' then libvlc_video_set_crop_geometry(FMediaPlayer, nil)
          else libvlc_video_set_crop_geometry(FMediaPlayer, PAnsiChar(Crop));
          libvlc_video_set_scale(FMediaPlayer, FSettings.ZoomPercent / 100.0);
          FVideoPreferencesApplied := True;
        end;
      end;
      if not FAudioPreferencesApplied then
      begin
        if FSettings.ChannelMode = 0 then FAudioPreferencesApplied := True
        else if libvlc_media_player_get_time(FMediaPlayer) >= 500 then
          FAudioPreferencesApplied := (libvlc_audio_set_channel(FMediaPlayer, FSettings.ChannelMode) = 0) and
            (libvlc_audio_get_channel(FMediaPlayer) = FSettings.ChannelMode);
      end;
      if FManualSubtitles.Count > 0 then
      begin
        for var SubtitlePath in FManualSubtitles do LoadSubtitleFile(SubtitlePath);
        FManualSubtitles.Clear;
      end;
      FPlaybackStarted := True;
      if Assigned(btnPlay) then
      begin
        if State = libvlc_Playing then
        begin
          if btnPlay.IconKind <> ikPause then
          begin
            btnPlay.IconKind := ikPause;
            btnPlay.Hint := 'Pause (Space)';
          end;
        end
        else
        begin
          if btnPlay.IconKind <> ikPlay then
          begin
            btnPlay.IconKind := ikPlay;
            btnPlay.Hint := 'Play (Space)';
          end;
        end;
      end;

      if Assigned(btnMute) then
      begin
        Muted := (libvlc_audio_get_mute(FMediaPlayer) = 1);
        if btnMute.IsActive <> Muted then
        begin
          btnMute.IsActive := Muted;
          if Muted then btnMute.IconKind := ikMute else btnMute.IconKind := ikVolume;
        end;
      end;

      TotalLen := libvlc_media_player_get_length(FMediaPlayer);
      CurTime := libvlc_media_player_get_time(FMediaPlayer);
      Pos := libvlc_media_player_get_position(FMediaPlayer);
      RefreshVideoInput;

      // PotPlayer Skip Opening & Ending features
      if FSettings.SkipOpening and (FSettings.SkipOpeningSeconds > 0) and not FOpeningSkipped then
      begin
        var SkipMs: Int64 := Int64(FSettings.SkipOpeningSeconds) * 1000;
        if (TotalLen > SkipMs * 2) and (CurTime < SkipMs) then
        begin
          FOpeningSkipped := True;
          SeekTo(SkipMs);
          ShowOSD(Format('Skipped Opening (+%ds)', [FSettings.SkipOpeningSeconds]));
        end
        else if (TotalLen > 0) then
          FOpeningSkipped := True;
      end;

      if FSettings.SkipEnding and (FSettings.SkipEndingSeconds > 0) and not FEndingSkipped then
      begin
        if (TotalLen > 120000) and (CurTime > 60000) then
        begin
          var RemainMs := TotalLen - CurTime;
          if (RemainMs <= Int64(FSettings.SkipEndingSeconds) * 1000) and (RemainMs > 1000) then
          begin
            FEndingSkipped := True;
            ShowOSD('Skipped Ending Credits');
            mnuNextClick(nil);
            Exit;
          end;
        end;
      end;
      if FPendingSeek >= 0 then
      begin
        if (FSeekSentAt > 0) and (Abs(CurTime - FPendingSeek) < 1200) then
          FPendingSeek := -1
        else if GetTickCount64 - FSeekRequestedAt > 6000 then
        begin
          FPendingSeek := -1;
          ShowOSD('This source could not seek to the requested position.');
        end
        else if Assigned(libvlc_media_player_is_seekable) and
          (libvlc_media_player_is_seekable(FMediaPlayer) <> 0) and
          ((FSeekSentAt = 0) or (GetTickCount64 - FSeekSentAt >= 1500)) then
        begin
          libvlc_media_player_set_time(FMediaPlayer, FPendingSeek);
          FSeekSentAt := GetTickCount64;
        end;
      end;
      if (FPendingResume < 0) and (TotalLen > -FPendingResume + 5000) then
      begin
        var ResumeTime := -FPendingResume;
        FPendingResume := 0;
        libvlc_media_player_set_pause(FMediaPlayer,1);
        var Remember: Boolean;
        var ContinuePlayback := PlayerResume(FormatTime(ResumeTime),Remember);
        if Remember then
        begin
          var Store:=TAppSettings.Create(ExtractFilePath(ParamStr(0))+'VLCModern.ini');
          try
            if ContinuePlayback then FSettings.ResumeMode:=0 else FSettings.ResumeMode:=2;
            Store.WriteInteger('Playback','Resume',FSettings.ResumeMode);
          finally Store.Free; end;
        end;
        if ContinuePlayback then FPendingResume:=ResumeTime;
        libvlc_media_player_set_pause(FMediaPlayer,0);
      end;
      if (FPendingResume > 0) and (TotalLen > FPendingResume + 5000) then
      begin
        SeekTo(FPendingResume);
        ShowOSD('Resumed at ' + FormatTime(FPendingResume));
        FPendingResume := 0;
      end;

      // Handle A-B Repeat loop
      if (FATime >= 0) and (FBTime > FATime) then
      begin
        if CurTime >= FBTime then
          libvlc_media_player_set_time(FMediaPlayer, FATime);
      end;

      // Sync taskbar progress and state with Windows 10/11
      if Assigned(FTaskbarMgr) then
      begin
        FTaskbarMgr.UpdatePlayState(Handle, State = libvlc_Playing);
        FTaskbarMgr.UpdateProgress(Handle, CurTime, TotalLen, Pos);
      end;

      // Dynamic Audio / Video mode detection
      if (State = libvlc_Playing) and Assigned(libvlc_video_get_size) then
      begin
        var VidW: Cardinal := 0;
        var VidH: Cardinal := 0;
        var HasVideo := (libvlc_video_get_size(FMediaPlayer, 0, @VidW, @VidH) = 0) and (VidW > 0);
        if not HasVideo and not FIsAudioOnly and (FCurrentFile <> '') then
          SwitchToAudioMode(FCurrentFile)
        else if HasVideo and FIsAudioOnly then
          SwitchToVideoMode;
      end;

      // Animate Audio Visualizer
      if FIsAudioOnly and Assigned(cardAudioMode) and cardAudioMode.Visible then
      begin
        if State = libvlc_Playing then
          pbVisualizer.Invalidate;
        if Assigned(pbVisualizer) then
          pbVisualizer.Invalidate;
      end;

      if GetAsyncKeyState(VK_LBUTTON) >= 0 then
      begin
        FUpdatingTrackBar := True;
        try
          Pos := libvlc_media_player_get_position(FMediaPlayer);
          tbProgress.Position := Round(Pos * 1000.0);
          if Assigned(modernSeekBar) and not modernSeekBar.IsDragging then
          begin
            modernSeekBar.TotalTimeMs := TotalLen;
            modernSeekBar.Position := Pos;
          end;
          CurrentVolume := libvlc_audio_get_volume(FMediaPlayer);
          if (CurrentVolume >= 0) and (FPendingVolume >= 0) then
          begin
            if CurrentVolume = FPendingVolume then FPendingVolume := -1
            else
            begin
              libvlc_audio_set_volume(FMediaPlayer, FPendingVolume);
              CurrentVolume := FPendingVolume;
              if CurrentVolume > 0 then libvlc_audio_set_mute(FMediaPlayer, 0);
            end;
          end;
          if (CurrentVolume >= 0) and Assigned(modernVolumeSlider) and not modernVolumeSlider.IsDragging then
            modernVolumeSlider.Volume := CurrentVolume;
          if Assigned(lblVolPctDisplay) and Assigned(modernVolumeSlider) then
            lblVolPctDisplay.Caption := Format('%d%%', [modernVolumeSlider.Volume]);
        finally
          FUpdatingTrackBar := False;
        end;
      end;

      if Assigned(lblTimeDisplay) then
      begin
        if FShowRemainingTime and (TotalLen > CurTime) then
          lblTimeDisplay.Caption := Format('%s / -%s', [FormatTime(CurTime), FormatTime(TotalLen - CurTime)])
        else
          lblTimeDisplay.Caption := Format('%s / %s', [FormatTime(CurTime), FormatTime(TotalLen)]);
      end;
      lblTime.Caption := Format('%s / %s', [FormatTime(CurTime), FormatTime(TotalLen)]);

      if lblStatsHUD.Visible then
        UpdateStatsHUD;
    end
    else
    begin
      if Assigned(btnPlay) and (btnPlay.IconKind <> ikPlay) then
      begin
        btnPlay.IconKind := ikPlay;
        btnPlay.Hint := 'Play (Space)';
      end;
    end;
  except
  end;
end;

procedure TFrmMain.AddRecentMedia(const APath: string);
var
  Ini: TAppSettings;
  List: TStringList;
  I: Integer;
begin
  if not FSettings.SaveHistory or (APath = '') or StartsText('dshow://', APath) then Exit;
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  List := TStringList.Create;
  try
    Ini.ReadSectionValues('RecentMedia', List);
    for I := List.Count - 1 downto 0 do
      if SameText(List.ValueFromIndex[I], APath) then
        List.Delete(I);

    List.Insert(0, Format('File%d=%s', [GetTickCount, APath]));

    while List.Count > 15 do
      List.Delete(List.Count - 1);

    Ini.EraseSection('RecentMedia');
    for I := 0 to List.Count - 1 do
      Ini.WriteString('RecentMedia', Format('Item%d', [I + 1]), List.ValueFromIndex[I]);
  finally
    List.Free;
    Ini.Free;
  end;
  UpdateRecentMediaMenu;
end;

procedure TFrmMain.UpdateRecentMediaMenu;
var
  Ini: TAppSettings;
  List: TStringList;
  I: Integer;
  Mi: TMenuItem;
  FilePath: string;
begin
  if mnuRecentMedia = nil then Exit;
  mnuRecentMedia.Clear;

  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  List := TStringList.Create;
  try
    Ini.ReadSectionValues('RecentMedia', List);
    if List.Count = 0 then
    begin
      Mi := TMenuItem.Create(mnuRecentMedia);
      Mi.Caption := 'No Recent Media';
      Mi.Enabled := False;
      mnuRecentMedia.Add(Mi);
    end
    else
    begin
      for I := 0 to List.Count - 1 do
      begin
        FilePath := List.ValueFromIndex[I];
        if FilePath <> '' then
        begin
          Mi := TMenuItem.Create(mnuRecentMedia);
          Mi.Caption := Format('%d. %s', [I + 1, ExtractFileName(FilePath)]);
          Mi.Hint := FilePath;
          Mi.OnClick := OnRecentMediaItemClick;
          mnuRecentMedia.Add(Mi);
        end;
      end;
      Mi := TMenuItem.Create(mnuRecentMedia);
      Mi.Caption := '-';
      mnuRecentMedia.Add(Mi);

      Mi := TMenuItem.Create(mnuRecentMedia);
      Mi.Caption := 'Clear Recent Media';
      Mi.OnClick := OnClearRecentMediaClick;
      mnuRecentMedia.Add(Mi);
    end;
  finally
    List.Free;
    Ini.Free;
  end;
end;

procedure TFrmMain.OnRecentMediaItemClick(Sender: TObject);
var
  Path: string;
begin
  if Sender is TMenuItem then
  begin
    Path := TMenuItem(Sender).Hint;
    if (Path <> '') then
      PlayFile(Path);
  end;
end;

procedure TFrmMain.OnClearRecentMediaClick(Sender: TObject);
var
  Ini: TAppSettings;
begin
  Ini := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Ini.EraseSection('RecentMedia');
  finally
    Ini.Free;
  end;
  UpdateRecentMediaMenu;
  ShowOSD('Recent media cleared.');
end;

procedure TFrmMain.AdjustSpeed(Delta: Single);
var
  CurRate, NewRate: Single;
begin
  if FMediaPlayer = nil then Exit;
  CurRate := 1.0;
  if Assigned(libvlc_media_player_get_rate) then
    CurRate := libvlc_media_player_get_rate(FMediaPlayer);
  if Delta = 0 then
    NewRate := 1.0
  else
    NewRate := EnsureRange(CurRate + Delta, 0.2, 4.0);

  libvlc_media_player_set_rate(FMediaPlayer, NewRate);
  if Assigned(btnSpeed) then btnSpeed.BadgeText := Format('%.2gx', [NewRate]);
  ShowOSD(Format('Speed: %.2fx', [NewRate]));
  GlobalLog(Format('Playback Speed: %.2fx', [NewRate]));
end;

procedure TFrmMain.SetABPointA;
begin
  if FMediaPlayer = nil then Exit;
  FATime := libvlc_media_player_get_time(FMediaPlayer);
  FBTime := -1;
  ShowOSD('A-B: Point A (' + FormatTime(FATime) + ')');
  GlobalLog('A-B Repeat Point A: ' + FormatTime(FATime));
end;

procedure TFrmMain.SetABPointB;
var
  Cur: Int64;
begin
  if FMediaPlayer = nil then Exit;
  Cur := libvlc_media_player_get_time(FMediaPlayer);
  if (FATime >= 0) and (Cur > FATime) then
  begin
    FBTime := Cur;
    ShowOSD('A-B: Looping ' + FormatTime(FATime) + ' -> ' + FormatTime(FBTime));
    GlobalLog(Format('A-B Repeat Looping %s -> %s', [FormatTime(FATime), FormatTime(FBTime)]));
  end
  else
    ShowOSD('Point B must be after Point A!');
end;

procedure TFrmMain.ClearABLoop;
begin
  FATime := -1;
  FBTime := -1;
  ShowOSD('A-B: Cleared');
  GlobalLog('A-B Repeat Cleared');
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  function MatchShortcut(Item: TMenuItem; Shortcut: TShortCut): Boolean;
  begin
    Result := False;
    if not Item.Enabled or not Item.Visible then Exit;
    if (Shortcut <> 0) and (Item.ShortCut = Shortcut) then
    begin
      Item.Click;
      Exit(True);
    end;
    for var I := 0 to Item.Count - 1 do
      if MatchShortcut(Item.Items[I], Shortcut) then Exit(True);
  end;
begin
  if not Enabled or not IsWindowEnabled(Handle) then Exit;
  if TryHandleCustomHotkey(Key, Shift) then
  begin
    Key := 0;
    Exit;
  end;
  if ((Key = VK_LEFT) or (Key = VK_RIGHT)) and
     ((Shift = []) or (Shift = [ssCtrl]) or (Shift = [ssShift]) or (Shift = [ssAlt])) then
  begin
    var Step := FSettings.JumpShort;
    if Shift = [ssCtrl] then Step := FSettings.JumpMedium;
    if Shift = [ssShift] then Step := FSettings.JumpLong;
    if Shift = [ssAlt] then Step := 60;
    if Key = VK_LEFT then Step := -Step;
    JumpSeconds(Step);
    Key := 0;
    Exit;
  end;
  if MatchShortcut(MainMenu1.Items, ShortCut(Key, Shift)) then
  begin
    Key := 0;
    Exit;
  end;
  for var Popup in FTopPopups do
      if Assigned(Popup) and MatchShortcut(Popup.Items, ShortCut(Key, Shift)) then
      begin
        Key := 0;
        Exit;
      end;
  case Key of
    VK_ESCAPE:
    begin
      if FIsFullscreen then
      begin
        mnuFullscreenClick(nil);
        Key := 0;
      end
      else if FIsBorderless then
      begin
        mnuBorderlessClick(nil);
        Key := 0;
      end;
    end;
    VK_RETURN:
      begin
        if not FSettings.EnterFullscreen then Exit;
        mnuFullscreenClick(nil);
        Key := 0;
      end;
    VK_F5:
    begin
      mnuPreferencesClick(nil);
      Key := 0;
    end;
    VK_F7:
    begin
      mnuEffectsClick(nil);
      Key := 0;
    end;
    VK_F8:
    begin
      mnuIPTVClick(nil);
      Key := 0;
    end;
    VK_PRIOR:
    begin
      if ssCtrl in Shift then
        PlayPrevFileInFolder
      else
        PreviousChapter;
      Key := 0;
    end;
    VK_NEXT:
    begin
      if ssCtrl in Shift then
        PlayNextFileInFolder
      else
        NextChapter;
      Key := 0;
    end;
    VK_OEM_PERIOD:
    begin
      mnuNextFrameClick(nil);
      Key := 0;
    end;
    VK_OEM_COMMA:
    begin
      mnuPrevFrameClick(nil);
      Key := 0;
    end;
    Ord('Z'):
    begin
      if Shift = [] then
      begin
        AdjustSpeed(0);
        Key := 0;
      end
      else if Shift = [ssShift] then
      begin
        FSettings.PreservePitch := not FSettings.PreservePitch;
        var PitchStore:=TAppSettings.Create(ExtractFilePath(ParamStr(0))+'VLCModern.ini');
        try PitchStore.WriteBool('Playback','Scaletempo',FSettings.PreservePitch); finally PitchStore.Free; end;
        if FSettings.PreservePitch then
          ShowOSD('Pitch correction: ON (next media)')
        else
          ShowOSD('Pitch correction: OFF (next media)');
        Key := 0;
      end;
    end;
    Ord('X'):
    begin
      if ssAlt in Shift then
      begin
        mnuExitClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        AdjustSpeed(-0.1);
        Key := 0;
      end;
    end;
    Ord('C'):
    begin
      if Shift = [ssCtrl] then
      begin
        CopySnapshotToClipboard;
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        CycleCropGeometry;
        Key := 0;
      end
      else if Shift = [] then
      begin
        AdjustSpeed(+0.1);
        Key := 0;
      end;
    end;
    219:
    begin
      if Shift = [] then
      begin
        SetABPointA;
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        ToggleSkipOpening;
        Key := 0;
      end;
    end;
    221:
    begin
      if Shift = [] then
      begin
        SetABPointB;
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        ToggleSkipEnding;
        Key := 0;
      end;
    end;
    220:
    begin
      if Shift = [] then
      begin
        ClearABLoop;
        Key := 0;
      end;
    end;
    Ord('R'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        RecordAudioStream;
        Key := 0;
      end
      else if ssAlt in Shift then
      begin
        CycleVideoRotation;
        Key := 0;
      end
      else if Shift=[ssCtrl] then begin mnuConvertClick(nil); Key:=0; end
      else if Shift=[ssShift] then
      begin
        btnShuffleClick(nil);
        ShowOSD('Playlist Shuffled');
        Key := 0;
      end
      else if (Shift = []) and (FPendingResume < 0) then
      begin
        FPendingResume := -FPendingResume;
        Key := 0;
      end;
    end;
    VK_SPACE:
    begin
      mnuPlayPauseClick(nil);
      Key := 0;
    end;
    Ord('S'):
    begin
      if (ssCtrl in Shift) and (ssAlt in Shift) and (ssShift in Shift) then
      begin
        TakeCleanSnapshot;
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        GenerateThumbnailSheet;
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleShader(sfSharpen);
        Key := 0;
      end
      else if (ssShift in Shift) or (ssCtrl in Shift) then
      begin
        mnuSnapshotClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuStopClick(nil);
        Key := 0;
      end;
    end;
    Ord('U'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        DownloadSubtitlesOnline;
        Key := 0;
      end;
    end;
    Ord('M'):
    begin
      if ssCtrl in Shift then
      begin
        pnlMenuBar.Visible := not pnlMenuBar.Visible;
        Key := 0;
      end
      else
      begin
        mnuMuteClick(nil);
        Key := 0;
      end;
    end;
    VK_F10:
    begin
      mnuBorderlessClick(nil);
      Key := 0;
    end;
    VK_F11:
    begin
      if FSettings.BossKeyHide then ToggleBossKey;
      Key := 0;
    end;
    VK_F12:
    begin
      if ssCtrl in Shift then
      begin
        OpenScreenCapture;
        Key := 0;
      end;
    end;
    Ord('F'):
    begin
      if ssCtrl in Shift then
      begin
        mnuOpenFolderClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuFullscreenClick(nil);
        Key := 0;
      end;
    end;
    Ord('I'):
    begin
      if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        ToggleShader(sfInvert);
        Key := 0;
      end
      else if Shift = [ssCtrl] then
      begin
        mnuMediaInfoClick(nil);
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        mnuIPTVClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuStatsHUDClick(nil);
        Key := 0;
      end;
    end;
    VK_NUMPAD5:
    begin
      mnuPanScanItemClick(mnuPanReset);
      Key := 0;
    end;
    VK_NUMPAD9:
    begin
      mnuPanScanItemClick(mnuPanZoomIn);
      Key := 0;
    end;
    VK_NUMPAD1:
    begin
      mnuPanScanItemClick(mnuPanZoomOut);
      Key := 0;
    end;
    VK_NUMPAD4:
    begin
      mnuPanScanItemClick(mnuPanLeft);
      Key := 0;
    end;
    VK_NUMPAD6:
    begin
      mnuPanScanItemClick(mnuPanRight);
      Key := 0;
    end;
    VK_NUMPAD8:
    begin
      mnuPanScanItemClick(mnuPanUp);
      Key := 0;
    end;
    VK_NUMPAD2:
    begin
      mnuPanScanItemClick(mnuPanDown);
      Key := 0;
    end;
    Ord('1'):
    begin
      if Shift = [ssCtrl] then
      begin
        ApplyLayoutPreset(0);
        Key := 0;
      end
      else if ssAlt in Shift then
      begin
        var Mi50 := TMenuItem.Create(Self);
        try
          Mi50.Tag := 50;
          mnuWindowSizeItemClick(Mi50);
        finally
          Mi50.Free;
        end;
        Key := 0;
      end
      else if (Shift = []) and (FMediaPlayer <> nil) then
      begin
        EnsureVideoAdjustEnabled;
        var C := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Contrast) - 0.05;
        if C < 0 then C := 0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Contrast, C);
        ShowOSD(Format('Contrast: %.2f', [C]));
        Key := 0;
      end;
    end;
    Ord('2'):
    begin
      if Shift = [ssCtrl] then
      begin
        ApplyLayoutPreset(1);
        Key := 0;
      end
      else if ssAlt in Shift then
      begin
        var Mi100 := TMenuItem.Create(Self);
        try
          Mi100.Tag := 100;
          mnuWindowSizeItemClick(Mi100);
        finally
          Mi100.Free;
        end;
        Key := 0;
      end
      else if (Shift = []) and (FMediaPlayer <> nil) then
      begin
        EnsureVideoAdjustEnabled;
        var C := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Contrast) + 0.05;
        if C > 2.0 then C := 2.0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Contrast, C);
        ShowOSD(Format('Contrast: %.2f', [C]));
        Key := 0;
      end;
    end;
    Ord('3'):
    begin
      if Shift = [ssCtrl] then
      begin
        ApplyLayoutPreset(2);
        Key := 0;
      end
      else if ssAlt in Shift then
      begin
        var Mi200 := TMenuItem.Create(Self);
        try
          Mi200.Tag := 200;
          mnuWindowSizeItemClick(Mi200);
        finally
          Mi200.Free;
        end;
        Key := 0;
      end
      else if (Shift = []) and (FMediaPlayer <> nil) then
      begin
        EnsureVideoAdjustEnabled;
        var B := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Brightness) - 0.05;
        if B < 0 then B := 0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Brightness, B);
        ShowOSD(Format('Brightness: %.2f', [B]));
        Key := 0;
      end;
    end;
    Ord('4'):
    begin
      if Shift = [ssAlt] then
      begin
        var R := Screen.MonitorFromWindow(Handle).WorkareaRect;
        SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
        ShowOSD('Window: Fit to Screen');
        Key := 0;
      end
      else if FMediaPlayer <> nil then
      begin
        EnsureVideoAdjustEnabled;
        var B := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Brightness) + 0.05;
        if B > 2.0 then B := 2.0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Brightness, B);
        ShowOSD(Format('Brightness: %.2f', [B]));
        Key := 0;
      end;
    end;
    Ord('5'):
    begin
      if FMediaPlayer <> nil then
      begin
        EnsureVideoAdjustEnabled;
        var G := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Gamma) - 0.05;
        if G < 0.1 then G := 0.1;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Gamma, G);
        ShowOSD(Format('Gamma: %.2f', [G]));
      end;
      Key := 0;
    end;
    Ord('6'):
    begin
      if FMediaPlayer <> nil then
      begin
        EnsureVideoAdjustEnabled;
        var G := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Gamma) + 0.05;
        if G > 5.0 then G := 5.0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Gamma, G);
        ShowOSD(Format('Gamma: %.2f', [G]));
      end;
      Key := 0;
    end;
    Ord('7'):
    begin
      if FMediaPlayer <> nil then
      begin
        EnsureVideoAdjustEnabled;
        var S := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Saturation) - 0.05;
        if S < 0 then S := 0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Saturation, S);
        ShowOSD(Format('Saturation: %.2f', [S]));
      end;
      Key := 0;
    end;
    Ord('8'):
    begin
      if FMediaPlayer <> nil then
      begin
        EnsureVideoAdjustEnabled;
        var S := libvlc_video_get_adjust_float(FMediaPlayer, libvlc_adjust_Saturation) + 0.05;
        if S > 3.0 then S := 3.0;
        libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Saturation, S);
        ShowOSD(Format('Saturation: %.2f', [S]));
      end;
      Key := 0;
    end;
    VK_BACK:
    begin
      if ssCtrl in Shift then
      begin
        ResetAllShaders;
        Key := 0;
      end
      else
      begin
        AdjustSpeed(0);
        if FMediaPlayer <> nil then
        begin
          EnsureVideoAdjustEnabled;
          libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Contrast, 1.0);
          libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Brightness, 1.0);
          libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Gamma, 1.0);
          libvlc_video_set_adjust_float(FMediaPlayer, libvlc_adjust_Saturation, 1.0);
          ShowOSD('Picture Controls & Speed Reset');
        end;
        Key := 0;
      end;
    end;
    VK_LEFT:
    begin
      mnuJumpBackClick(nil);
      Key := 0;
    end;
    VK_RIGHT:
    begin
      mnuJumpFwdClick(nil);
      Key := 0;
    end;
    VK_UP:
    begin
      if ssCtrl in Shift then
        AdjustSpeed(+0.1)
      else
        mnuVolUpClick(nil);
      Key := 0;
    end;
    VK_DOWN:
    begin
      if ssCtrl in Shift then
        AdjustSpeed(-0.1)
      else
        mnuVolDownClick(nil);
      Key := 0;
    end;
    Ord('E'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleShader(sfEdgeDetect);
        Key := 0;
      end
      else if ssCtrl in Shift then
        mnuEffectsClick(nil)
      else
        mnuNextFrameClick(nil);
      Key := 0;
    end;
    Ord('T'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ReopenLastClosedFile;
        Key := 0;
      end
      else if ssCtrl in Shift then
      begin
        mnuJumpTimeClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuAlwaysOnTopClick(nil);
        Key := 0;
      end;
    end;
    Ord('A'):
    begin
      if ssCtrl in Shift then
      begin
        mnuAlwaysOnTopClick(nil);
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        CycleAspectRatio;
        Key := 0;
      end
      else if Shift = [] then
      begin
        CycleAudioTrack;
        Key := 0;
      end;
    end;
    Ord('B'):
    begin
      if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        CycleBufferPreset;
        Key := 0;
      end
      else if Shift = [ssCtrl] then
      begin
        mnuBookmarksClick(nil);
        Key := 0;
      end
      else if Shift = [ssShift] then
      begin
        CycleAudioChannel;
        Key := 0;
      end
      else if Shift = [] then
      begin
        CycleAudioTrack;
        Key := 0;
      end;
    end;
    Ord('D'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleShader(sfDenoise);
        Key := 0;
      end
      else if ssCtrl in Shift then
      begin
        mnuOpenDiscClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        ToggleDeinterlace;
        Key := 0;
      end;
    end;
    Ord('L'):
    begin
      if ssCtrl in Shift then
      begin
        OnModernPlaylistToggle(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        OnModernRepeatClick(nil);
        Key := 0;
      end;
    end;
    Ord('W'):
    begin
      if ssCtrl in Shift then
      begin
        mnuStopClick(nil);
        Key := 0;
      end;
    end;
    Ord('V'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleVoiceClarifier;
        Key := 0;
      end
      else if Shift = [ssCtrl] then
      begin
        mnuOpenClipboardClick(nil);
        Key := 0;
      end
      else if Shift = [ssAlt] then
      begin
        mnuAddSecondarySubClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        CycleSubtitleTrack;
        Key := 0;
      end;
    end;
    Ord('N'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleNightMode;
        Key := 0;
      end
      else if Shift = [ssCtrl] then
      begin
        mnuOpenURLClick(nil);
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        FSettings.Normalize := not FSettings.Normalize;
        if FSettings.Normalize then
          ShowOSD('Audio Normalization: ON')
        else
          ShowOSD('Audio Normalization: OFF');
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        NextChapter;
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuNextClick(nil);
        Key := 0;
      end;
    end;
    Ord('P'):
    begin
      if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        CycleVideoProfile;
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleAudioPassthrough;
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        PreviousChapter;
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuPreviousClick(nil);
        Key := 0;
      end;
    end;
    Ord('O'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        mnuOpenFolderClick(nil);
        Key := 0;
      end
      else if Shift = [ssCtrl] then
      begin
        mnuOpenFileClick(nil);
        Key := 0;
      end;
    end;
    Ord('J'):
    begin
      if ssCtrl in Shift then
      begin
        mnuStatsHUDClick(nil);
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        if (FMediaPlayer <> nil) and Assigned(libvlc_audio_set_delay) then
        begin
          libvlc_audio_set_delay(FMediaPlayer, 0);
          ShowOSD('Audio Delay: 0 ms');
        end;
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuAudioDelayMinusClick(nil);
        Key := 0;
      end;
    end;
    Ord('K'):
    begin
      if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        ToggleKaraokeMode;
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuAudioDelayPlusClick(nil);
        Key := 0;
      end;
    end;
    Ord('G'):
    begin
      if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        GenerateAnimatedGif;
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleShader(sfFilmGrain);
        Key := 0;
      end
      else if ssShift in Shift then
      begin
        if (FMediaPlayer <> nil) and Assigned(libvlc_video_set_spu_delay) then
        begin
          libvlc_video_set_spu_delay(FMediaPlayer, 0);
          ShowOSD('Sub Delay: 0 ms');
        end;
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuSubDelayMinusClick(nil);
        Key := 0;
      end;
    end;
    Ord('H'):
    begin
      if (ssCtrl in Shift) and (ssShift in Shift) then
      begin
        ToggleHeadphoneSurround;
        Key := 0;
      end
      else if (ssCtrl in Shift) and (ssAlt in Shift) then
      begin
        ToggleVideoFlipHorizontal;
        Key := 0;
      end
      else if ssCtrl in Shift then
      begin
        mnuMinimalClick(nil);
        Key := 0;
      end
      else if Shift = [] then
      begin
        mnuSubDelayPlusClick(nil);
        Key := 0;
      end;
    end;
    Ord('9'):
    begin
      if Shift = [] then
      begin
        mnuVolDownClick(nil);
        Key := 0;
      end;
    end;
    Ord('0'):
    begin
      if Shift = [] then
      begin
        mnuVolUpClick(nil);
        Key := 0;
      end;
    end;
    VK_F1:
    begin
      mnuAboutClick(nil);
      Key := 0;
    end;
    VK_F4:
    begin
      if Shift = [] then
      begin
        mnuViewPlaylistClick(nil);
        Key := 0;
      end;
    end;
    VK_HOME:
    begin
      if Shift = [] then
      begin
        JumpSeconds(-MaxInt);
        Key := 0;
      end;
    end;
    VK_END:
    begin
      if Shift = [] then
      begin
        mnuNextClick(nil);
        Key := 0;
      end;
    end;
    VK_MEDIA_PLAY_PAUSE:
    begin
      mnuPlayPauseClick(nil);
      Key := 0;
    end;
    VK_MEDIA_STOP:
    begin
      mnuStopClick(nil);
      Key := 0;
    end;
    VK_MEDIA_NEXT_TRACK:
    begin
      mnuNextClick(nil);
      Key := 0;
    end;
    VK_MEDIA_PREV_TRACK:
    begin
      mnuPreviousClick(nil);
      Key := 0;
    end;
    VK_VOLUME_MUTE:
    begin
      mnuMuteClick(nil);
      Key := 0;
    end;
    VK_VOLUME_UP:
    begin
      mnuVolUpClick(nil);
      Key := 0;
    end;
    VK_VOLUME_DOWN:
    begin
      mnuVolDownClick(nil);
      Key := 0;
    end;
  end;
end;

end.
