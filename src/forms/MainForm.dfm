object FrmMain: TFrmMain
  Left = 120
  Top = 80
  BorderStyle = bsNone
  Caption = 'VLC Modern'
  ClientHeight = 580
  ClientWidth = 980
  Color = 3483412
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  PopupMenu = PopupMenuVideo
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheel = FormMouseWheel
  OnShow = FormShow
  TextHeight = 15
  object pnlRoot: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 495
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlPlaylist: TPanel
      Left = 700
      Top = 0
      Width = 280
      Height = 486
      Align = alRight
      BevelOuter = bvNone
      Color = 3483412
      ParentBackground = False
      TabOrder = 0
      Visible = False
      object pnlPlaylistHeader: TPanel
        Left = 0
        Top = 0
        Width = 280
        Height = 35
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        Visible = False
        object lblPlaylistTitle: TLabel
          Left = 10
          Top = 9
          Width = 105
          Height = 15
          Caption = 'Playlist / Media List'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object btnHidePlaylist: TPlayerTextButton
          Left = 246
          Top = 6
          Width = 28
          Height = 24
          Caption = 'X'
          TabOrder = 0
          OnClick = mnuViewPlaylistClick
        end
      end
      object lstPlaylist: TListBox
        Left = 0
        Top = 35
        Width = 280
        Height = 381
        Align = alNone
        BorderStyle = bsNone
        Color = 3483412
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16513523
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemHeight = 34
        ParentFont = False
        Style = lbOwnerDrawFixed
        TabOrder = 1
        OnDblClick = lstPlaylistDblClick
      end
      object pnlPlaylistBottom: TPanel
        Left = 0
        Top = 416
        Width = 280
        Height = 70
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        Visible = False
      end
    end
    object pnlVideoContainer: TPanel
      Left = 0
      Top = 0
      Width = 720
      Height = 495
      Align = alClient
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 1
      object pnlVideo: TPanel
        Left = 0
        Top = 0
        Width = 720
        Height = 495
        Align = alClient
        BevelOuter = bvNone
        Color = clBlack
        DoubleBuffered = True
        ParentBackground = False
        ParentDoubleBuffered = False
        PopupMenu = PopupMenuVideo
        TabOrder = 0
        OnClick = pnlVideoClick
        OnDblClick = pnlVideoDblClick
        OnMouseUp = pnlVideoMouseUp
        object lblOSD: TLabel
          Left = 24
          Top = 24
          Width = 100
          Height = 25
          Color = 2105376
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
        end
        object lblStatsHUD: TLabel
          Left = 24
          Top = 55
          Width = 320
          Height = 175
          Color = 1052688
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clYellow
          Font.Height = -12
          Font.Name = 'Consolas'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Visible = False
        end
      end
    end
  end
  object pnlBottom: TPlayerDockPanel
    Left = 0
    Top = 486
    Width = 980
    Height = 94
    Align = alBottom
    BevelOuter = bvNone
    Color = 3483412
    ParentBackground = False
    TabOrder = 1
    object pnlProgressRow: TPanel
      Left = 0
      Top = 0
      Width = 980
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      Visible = False
      object lblTime: TLabel
        Left = 865
        Top = 5
        Width = 110
        Height = 18
        Alignment = taCenter
        AutoSize = False
        Caption = '00:00 / 00:00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
      end
      object tbProgress: TPlayerSlider
        Left = 0
        Top = 0
        Width = 860
        Height = 28
        Align = alNone
        Max = 1000
        PageSize = 50
        TabOrder = 0
        OnChange = tbProgressChange
      end
    end
    object pnlControlsRow: TPanel
      Left = 0
      Top = 28
      Width = 980
      Height = 57
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object pnlTransport: TPanel
        Left = 0
        Top = 0
        Width = 425
        Height = 57
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
      end
      object pnlVolume: TPanel
        Left = 425
        Top = 0
        Width = 175
        Height = 57
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object tbVolume: TPlayerSlider
          Left = 50
          Top = 13
          Width = 85
          Height = 30
          Max = 200
          PageSize = 10
          Position = 100
          TabOrder = 0
          OnChange = tbVolumeChange
        end
        object lblVolPct: TLabel
          Left = 138
          Top = 19
          Width = 35
          Height = 15
          Caption = '100%'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlRightControls: TPanel
        Left = 600
        Top = 0
        Width = 380
        Height = 57
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 2
        object cboAspect: TComboBox
          Left = 6
          Top = 16
          Width = 72
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'Default'
          OnChange = cboAspectChange
          Items.Strings = (
            'Default'
            '16:9'
            '4:3'
            '16:10'
            '1:1'
            '2.35:1'
          )
        end
        object cboSpeed: TComboBox
          Left = 84
          Top = 16
          Width = 65
          Height = 23
          Style = csDropDownList
          ItemIndex = 2
          TabOrder = 1
          Text = '1.00x'
          OnChange = cboSpeedChange
          Items.Strings = (
            '0.50x'
            '0.75x'
            '1.00x'
            '1.25x'
            '1.50x'
            '2.00x'
          )
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 40
    Top = 50
    object mnuMedia: TMenuItem
      Caption = '&Media'
      object mnuOpenFile: TMenuItem
        Caption = 'Open &File...'
        ShortCut = 16463
        OnClick = mnuOpenFileClick
      end
      object mnuOpenMultiple: TMenuItem
        Caption = 'Open &Multiple Files...'
        ShortCut = 24655
        OnClick = mnuOpenMultipleClick
      end
      object mnuOpenFolder: TMenuItem
        Caption = 'Open F&older...'
        ShortCut = 16454
        OnClick = mnuOpenFolderClick
      end
      object mnuOpenDisc: TMenuItem
        Caption = 'Open &Disc...'
        ShortCut = 16452
        OnClick = mnuOpenDiscClick
      end
      object mnuOpenURL: TMenuItem
        Caption = 'Open &Network Stream...'
        ShortCut = 16462
        OnClick = mnuOpenURLClick
      end
      object mnuOpenCapture: TMenuItem
        Caption = 'Open &Capture Device...'
        ShortCut = 16451
        OnClick = mnuOpenCaptureClick
      end
      object mnuScreenCapture: TMenuItem
        Caption = 'Open &Desktop Screen (30 FPS)'
        OnClick = mnuScreenCaptureClick
      end
      object mnuOpenClipboard: TMenuItem
        Caption = 'Open &Location from clipboard'
        ShortCut = 16470
        OnClick = mnuOpenClipboardClick
      end
      object mnuRecentMedia: TMenuItem
        Caption = 'Open &Recent Media'
      end
      object mnuSep1: TMenuItem
        Caption = '-'
      end
      object mnuSavePlaylist: TMenuItem
        Caption = '&Save Playlist to File...'
        ShortCut = 16473
        OnClick = mnuSavePlaylistClick
      end
      object mnuConvert: TMenuItem
        Caption = 'Con&vert / Save...'
        ShortCut = 16466
        OnClick = mnuConvertClick
      end
      object mnuStream: TMenuItem
        Caption = 'Strea&m...'
        ShortCut = 16467
        OnClick = mnuStreamClick
      end
      object mnuSepMedia2: TMenuItem
        Caption = '-'
      end
      object mnuQuitAtEnd: TMenuItem
        Caption = 'Quit at the end of playlist'
        OnClick = mnuQuitAtEndClick
      end
      object mnuQuit: TMenuItem
        Caption = '&Quit'
        ShortCut = 16465
        OnClick = mnuExitClick
      end
    end
    object mnuPlayback: TMenuItem
      Caption = '&Playback'
      OnClick = mnuPlaybackClick
      object mnuTitle: TMenuItem
        Caption = '&Title'
      end
      object mnuChapters: TMenuItem
        Caption = '&Chapter'
      end
      object mnuProgram: TMenuItem
        Caption = '&Program'
      end
      object mnuBookmarks: TMenuItem
        Caption = 'Custom &Bookmarks'
        ShortCut = 16450
        OnClick = mnuBookmarksClick
      end
      object mnuSleepTimer: TMenuItem
        Caption = 'Sleep &Timer (Auto-Close)'
        object mnuSleepOff: TMenuItem
          Tag = 0
          Caption = 'Off'
          Checked = True
          OnClick = mnuSleepTimerItemClick
        end
        object mnuSleep15: TMenuItem
          Tag = 15
          Caption = '15 Minutes'
          OnClick = mnuSleepTimerItemClick
        end
        object mnuSleep30: TMenuItem
          Tag = 30
          Caption = '30 Minutes'
          OnClick = mnuSleepTimerItemClick
        end
        object mnuSleep60: TMenuItem
          Tag = 60
          Caption = '60 Minutes'
          OnClick = mnuSleepTimerItemClick
        end
        object mnuSleep90: TMenuItem
          Tag = 90
          Caption = '90 Minutes'
          OnClick = mnuSleepTimerItemClick
        end
      end
      object mnuRenderer: TMenuItem
        Caption = '&Renderer'
        OnClick = mnuRendererClick
      end
      object mnuSpeed: TMenuItem
        Caption = 'Spee&d'
        object mnuSpeed025: TMenuItem
          Tag = 25
          Caption = '0.25x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed05: TMenuItem
          Tag = 50
          Caption = '0.50x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed075: TMenuItem
          Tag = 75
          Caption = '0.75x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed10: TMenuItem
          Tag = 100
          Caption = '1.00x (Normal)'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed125: TMenuItem
          Tag = 125
          Caption = '1.25x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed15: TMenuItem
          Tag = 150
          Caption = '1.50x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed20: TMenuItem
          Tag = 200
          Caption = '2.00x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed30: TMenuItem
          Tag = 300
          Caption = '3.00x'
          OnClick = mnuSpeedItemClick
        end
        object mnuSpeed40: TMenuItem
          Tag = 400
          Caption = '4.00x'
          OnClick = mnuSpeedItemClick
        end
      end
      object mnuSep2: TMenuItem
        Caption = '-'
      end
      object mnuJumpFwd: TMenuItem
        Caption = 'Jump &Forward'
        ShortCut = 16423
        OnClick = mnuJumpFwdClick
      end
      object mnuJumpBack: TMenuItem
        Caption = 'Jump &Backward'
        ShortCut = 16421
        OnClick = mnuJumpBackClick
      end
      object mnuJumpTime: TMenuItem
        Caption = 'Jump to &Specific Time...'
        ShortCut = 16468
        OnClick = mnuJumpTimeClick
      end
      object mnuSkipOpening: TMenuItem
        Caption = 'Skip &Opening (Intro)'
        OnClick = mnuSkipOpeningClick
      end
      object mnuSkipEnding: TMenuItem
        Caption = 'Skip &Ending (Outro)'
        OnClick = mnuSkipEndingClick
      end
      object mnuSepPlay2: TMenuItem
        Caption = '-'
      end
      object mnuPlayPause: TMenuItem
        Caption = '&Pause'
        ShortCut = 32
        OnClick = mnuPlayPauseClick
      end
      object mnuStop: TMenuItem
        Caption = '&Stop'
        ShortCut = 83
        OnClick = mnuStopClick
      end
      object mnuPrevious: TMenuItem
        Caption = 'P&revious'
        ShortCut = 80
        OnClick = mnuPreviousClick
      end
      object mnuNext: TMenuItem
        Caption = '&Next'
        ShortCut = 78
        OnClick = mnuNextClick
      end
      object mnuRecord: TMenuItem
        Caption = '&Record'
        ShortCut = 8274
        OnClick = mnuRecordClick
      end
    end
    object mnuAudio: TMenuItem
      Caption = '&Audio'
      OnClick = mnuAudioClick
      object mnuAudioTrack: TMenuItem
        Caption = 'Audio &Track'
      end
      object mnuAudioDevice: TMenuItem
        Caption = 'Audio &Device'
      end
      object mnuCycleAudioDevice: TMenuItem
        Caption = 'Cycle Audio &Output Device'
        ShortCut = 32833
        OnClick = mnuCycleAudioDeviceClick
      end
      object mnuAudioChannel: TMenuItem
        Caption = 'Stereo &Mode / Channel'
        object mnuChannelStereo: TMenuItem
          Tag = 1
          Caption = 'Stereo'
          OnClick = mnuAudioChannelClick
        end
        object mnuChannelRStereo: TMenuItem
          Tag = 2
          Caption = 'Reverse Stereo'
          OnClick = mnuAudioChannelClick
        end
        object mnuChannelLeft: TMenuItem
          Tag = 3
          Caption = 'Left Only'
          OnClick = mnuAudioChannelClick
        end
        object mnuChannelRight: TMenuItem
          Tag = 4
          Caption = 'Right Only'
          OnClick = mnuAudioChannelClick
        end
        object mnuChannelDolby: TMenuItem
          Tag = 5
          Caption = 'Dolby Surround'
          OnClick = mnuAudioChannelClick
        end
      end
      object mnuVolUp: TMenuItem
        Caption = 'Increase Volume'
        ShortCut = 16422
        OnClick = mnuVolUpClick
      end
      object mnuVolDown: TMenuItem
        Caption = 'Decrease Volume'
        ShortCut = 16424
        OnClick = mnuVolDownClick
      end
      object mnuMute: TMenuItem
        Caption = '&Mute'
        ShortCut = 77
        OnClick = mnuMuteClick
      end
      object mnuAudioDelayPlus: TMenuItem
        Caption = 'Audio Delay (+50ms)'
        OnClick = mnuAudioDelayPlusClick
      end
      object mnuAudioDelayMinus: TMenuItem
        Caption = 'Audio Delay (-50ms)'
        OnClick = mnuAudioDelayMinusClick
      end
      object mnuSepAudioFilters: TMenuItem
        Caption = '-'
      end
      object mnuVoiceClarifier: TMenuItem
        Caption = 'Voice &Clarifier (Dialogue Boost)'
        OnClick = mnuVoiceClarifierClick
      end
      object mnuNightMode: TMenuItem
        Caption = '&Night Mode (Compress Loud Audio)'
        OnClick = mnuNightModeClick
      end
      object mnuHeadphoneSurround: TMenuItem
        Caption = '3D &Headphone Surround (HRTF)'
        OnClick = mnuHeadphoneSurroundClick
      end
      object mnuKaraokeMode: TMenuItem
        Caption = '&Voice Removal (Karaoke Mode)'
        OnClick = mnuKaraokeModeClick
      end
      object mnuAudioPassthrough: TMenuItem
        Caption = 'Digital Audio &Passthrough (S/PDIF / HDMI)'
        OnClick = mnuAudioPassthroughClick
      end
      object mnuAudioRecord: TMenuItem
        Caption = '&Record Audio Stream...'
        OnClick = mnuAudioRecordClick
      end
      object mnuSep3: TMenuItem
        Caption = '-'
      end
      object mnuEQPresets: TMenuItem
        Caption = 'Equalizer &Presets'
      end
      object mnuAudioEqualizer: TMenuItem
        Caption = '&Equalizer and Effects...'
        ShortCut = 16453
        OnClick = mnuEffectsClick
      end
    end
    object mnuVideo: TMenuItem
      Caption = '&Video'
      object mnuFullscreen: TMenuItem
        Caption = '&Fullscreen'
        ShortCut = 70
        OnClick = mnuFullscreenClick
      end
      object mnuAlwaysOnTop: TMenuItem
        Caption = '&Always on Top'
        OnClick = mnuAlwaysOnTopClick
      end
      object mnuSep4: TMenuItem
        Caption = '-'
      end
      object mnuAspect: TMenuItem
        Caption = '&Aspect Ratio'
        object mnuAspectDef: TMenuItem
          Caption = 'Default'
          OnClick = mnuAspectItemClick
        end
        object mnuAspect169: TMenuItem
          Caption = '16:9'
          OnClick = mnuAspectItemClick
        end
        object mnuAspect43: TMenuItem
          Caption = '4:3'
          OnClick = mnuAspectItemClick
        end
        object mnuAspect1610: TMenuItem
          Caption = '16:10'
          OnClick = mnuAspectItemClick
        end
        object mnuAspect11: TMenuItem
          Caption = '1:1'
          OnClick = mnuAspectItemClick
        end
        object mnuAspect235: TMenuItem
          Caption = '2.35:1'
          OnClick = mnuAspectItemClick
        end
      end
      object mnuCrop: TMenuItem
        Caption = '&Crop'
        object mnuCropDef: TMenuItem
          Caption = 'Default'
          OnClick = mnuCropClick
        end
        object mnuCrop169: TMenuItem
          Caption = '16:9'
          OnClick = mnuCropClick
        end
        object mnuCrop43: TMenuItem
          Caption = '4:3'
          OnClick = mnuCropClick
        end
        object mnuCrop1610: TMenuItem
          Caption = '16:10'
          OnClick = mnuCropClick
        end
        object mnuCrop11: TMenuItem
          Caption = '1:1'
          OnClick = mnuCropClick
        end
      end
      object mnuDeinterlace: TMenuItem
        Caption = '&Deinterlace'
        object mnuDeinterlaceAuto: TMenuItem
          Caption = 'auto'
          OnClick = mnuDeinterlaceClick
        end
        object mnuDeinterlaceOn: TMenuItem
          Caption = 'on'
          OnClick = mnuDeinterlaceClick
        end
        object mnuDeinterlaceOff: TMenuItem
          Caption = 'off'
          OnClick = mnuDeinterlaceClick
        end
      end
      object mnuSep5: TMenuItem
        Caption = '-'
      end
      object mnuSnapshot: TMenuItem
        Caption = 'Take &Snapshot'
        ShortCut = 49235
        OnClick = mnuSnapshotClick
      end
      object mnuCleanSnapshot: TMenuItem
        Caption = 'Take &Clean Snapshot (No Subtitles)'
        ShortCut = 57427
        OnClick = mnuCleanSnapshotClick
      end
      object mnuThumbnailSheet: TMenuItem
        Caption = 'Save &Thumbnail Sheet...'
        ShortCut = 24659
        OnClick = mnuThumbnailSheetClick
      end
      object mnuAnimatedGif: TMenuItem
        Caption = 'Create &Animated GIF...'
        OnClick = mnuAnimatedGifClick
      end
      object mnuRecordVideoMP4: TMenuItem
        Caption = 'Record &Live Video (MP4)...'
        ShortCut = 32835
        OnClick = mnuRecordVideoMP4Click
      end
      object mnuVideoPresets: TMenuItem
        Caption = 'Video &Profiles (Presets)'
        object mnuProfileDefault: TMenuItem
          Tag = 0
          Caption = 'Default / Normal'
          OnClick = mnuProfileItemClick
        end
        object mnuProfileCinema: TMenuItem
          Tag = 1
          Caption = 'Cinema (Warm Contrast)'
          OnClick = mnuProfileItemClick
        end
        object mnuProfileAnime: TMenuItem
          Tag = 2
          Caption = 'Anime / Vivid (High Saturation)'
          OnClick = mnuProfileItemClick
        end
        object mnuProfileEyeComfort: TMenuItem
          Tag = 3
          Caption = 'Eye Comfort (Night / Low Blue)'
          OnClick = mnuProfileItemClick
        end
        object mnuProfileNoir: TMenuItem
          Tag = 4
          Caption = 'Noir / Black && White'
          OnClick = mnuProfileItemClick
        end
        object mnuProfileSports: TMenuItem
          Tag = 5
          Caption = 'Sports / Vibrant'
          OnClick = mnuProfileItemClick
        end
      end
      object mnuShaders: TMenuItem
        Caption = 'Pixel &Shaders && Effects'
        object mnuShaderInvert: TMenuItem
          Tag = 0
          Caption = '&Invert Colors'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderSharpen: TMenuItem
          Tag = 1
          Caption = '&Sharpen Details'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderDenoise: TMenuItem
          Tag = 4
          Caption = '&3D Denoise (Clean Noise)'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderFilmGrain: TMenuItem
          Tag = 3
          Caption = 'Film &Grain'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderEdgeDetect: TMenuItem
          Tag = 2
          Caption = '&Edge Detect (Cartoon)'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderSepia: TMenuItem
          Tag = 5
          Caption = 'Sepia (&Vintage)'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderPosterize: TMenuItem
          Tag = 6
          Caption = '&Posterize (Pop Art)'
          OnClick = mnuShaderItemClick
        end
        object mnuShaderAnaglyph: TMenuItem
          Tag = 7
          Caption = '3D &Anaglyph (Red/Cyan)'
          OnClick = mnuShaderItemClick
        end
        object mnuSepShader: TMenuItem
          Caption = '-'
        end
        object mnuShaderReset: TMenuItem
          Caption = '&Reset All Shaders'
          OnClick = mnuResetShadersClick
        end
      end
      object mnuPanScan: TMenuItem
        Caption = 'Zoom && &Position'
        object mnuPanReset: TMenuItem
          Tag = 5
          Caption = 'Reset (Num 5)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanZoomIn: TMenuItem
          Tag = 9
          Caption = 'Zoom In (Num 9)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanZoomOut: TMenuItem
          Tag = 1
          Caption = 'Zoom Out (Num 1)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanLeft: TMenuItem
          Tag = 4
          Caption = 'Move Left (Num 4)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanRight: TMenuItem
          Tag = 6
          Caption = 'Move Right (Num 6)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanUp: TMenuItem
          Tag = 8
          Caption = 'Move Up (Num 8)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanDown: TMenuItem
          Tag = 2
          Caption = 'Move Down (Num 2)'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanScale169: TMenuItem
          Tag = 169
          Caption = 'Scale to 16:9 TV'
          OnClick = mnuPanScanItemClick
        end
        object mnuPanScale43: TMenuItem
          Tag = 43
          Caption = 'Scale to 4:3 TV'
          OnClick = mnuPanScanItemClick
        end
      end
      object mnuLoad3DLUT: TMenuItem
        Caption = 'Load 3D &LUT Profile (.cube)...'
        OnClick = mnuLoad3DLUTClick
      end
      object mnuGPUShaders: TMenuItem
        Caption = '&GPU HLSL Shaders (Direct3D 11)'
        object mnuGPUAnime4K: TMenuItem
          Tag = 0
          Caption = 'Anime4K Edge && Line Enhance (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuGPUCAS: TMenuItem
          Tag = 1
          Caption = 'CAS Adaptive Sharpen (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuGPUDeband: TMenuItem
          Tag = 2
          Caption = 'Ordered Deband && Dither (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuGPUACES: TMenuItem
          Tag = 3
          Caption = 'ACES Filmic HDR->SDR Tone Map (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuGPUCRT: TMenuItem
          Tag = 4
          Caption = 'CRT Retro Scanlines (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuGPULevels: TMenuItem
          Tag = 5
          Caption = 'TV->PC Levels 16-235 -> 0-255 (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuGPUBT601: TMenuItem
          Tag = 6
          Caption = 'BT.601 -> BT.709 Color Matrix (GPU)'
          OnClick = mnuGPUShaderItemClick
        end
        object mnuSepGPULoad: TMenuItem
          Caption = '-'
        end
        object mnuGPULoadHLSL: TMenuItem
          Caption = 'Load Custom .hlsl Pixel Shader...'
          OnClick = mnuGPULoadHLSLClick
        end
        object mnuGPUDisable: TMenuItem
          Caption = 'Disable GPU Shader Pipeline (Native Zero-Copy)'
          OnClick = mnuGPUDisableClick
        end
      end
      object mnu3DMode: TMenuItem
        Caption = '3&D Stereo Mode (PotPlayer)'
        object mnu3DNormal: TMenuItem
          Tag = 0
          Caption = 'Normal 2D'
          Checked = True
          OnClick = mnu3DModeItemClick
        end
        object mnu3DSBS: TMenuItem
          Tag = 1
          Caption = '3D Side-by-Side (SBS) -> 2D'
          OnClick = mnu3DModeItemClick
        end
        object mnu3DTAB: TMenuItem
          Tag = 2
          Caption = '3D Top-and-Bottom (TAB) -> 2D'
          OnClick = mnu3DModeItemClick
        end
      end
      object mnuScaling: TMenuItem
        Caption = 'Video &Scaling Algorithm'
        object mnuScaleSpline36: TMenuItem
          Tag = 0
          Caption = 'Spline36 (Sharp High-Quality)'
          OnClick = mnuScalingItemClick
        end
        object mnuScaleLanczos: TMenuItem
          Tag = 1
          Caption = 'Lanczos (Anti-Aliased)'
          OnClick = mnuScalingItemClick
        end
        object mnuScaleBicubic: TMenuItem
          Tag = 2
          Caption = 'Bicubic (Balanced)'
          OnClick = mnuScalingItemClick
        end
        object mnuScaleBilinear: TMenuItem
          Tag = 3
          Caption = 'Bilinear (Fast)'
          OnClick = mnuScalingItemClick
        end
      end
    end
    object mnuSubtitle: TMenuItem
      Caption = '&Subtitle'
      OnClick = mnuSubtitleClick
      object mnuAddSub: TMenuItem
        Caption = '&Add Subtitle File...'
        OnClick = mnuAddSubClick
      end
      object mnuAddSecondarySub: TMenuItem
        Caption = 'Add &Secondary Subtitle (Top Display)...'
        OnClick = mnuAddSecondarySubClick
      end
      object mnuSubTrack: TMenuItem
        Caption = 'Subtitle &Track'
      end
      object mnuSubDelayPlus: TMenuItem
        Caption = 'Subtitle Delay (+50ms)'
        OnClick = mnuSubDelayPlusClick
      end
      object mnuSubDelayMinus: TMenuItem
        Caption = 'Subtitle Delay (-50ms)'
        OnClick = mnuSubDelayMinusClick
      end
      object mnuSubSizePlus: TMenuItem
        Caption = 'Subtitle Font Size + (Larger)'
        ShortCut = 32801
        OnClick = mnuSubSizePlusClick
      end
      object mnuSubSizeMinus: TMenuItem
        Caption = 'Subtitle Font Size - (Smaller)'
        ShortCut = 32802
        OnClick = mnuSubSizeMinusClick
      end
      object mnuSubMoveUp: TMenuItem
        Caption = 'Move Subtitles Up'
        ShortCut = 32806
        OnClick = mnuSubMoveUpClick
      end
      object mnuSubMoveDown: TMenuItem
        Caption = 'Move Subtitles Down'
        ShortCut = 32808
        OnClick = mnuSubMoveDownClick
      end
      object mnuDownloadOnlineSub: TMenuItem
        Caption = 'Download Subtitles &Online (OpenSubtitles)...'
        ShortCut = 24661
        OnClick = mnuDownloadOnlineSubClick
      end
      object mnuTranslateSub: TMenuItem
        Caption = '&Translate Subtitles (Online Machine Translation)...'
        OnClick = mnuTranslateSubClick
      end
    end
    object mnuTools: TMenuItem
      Caption = '&Tools'
      object mnuEffects: TMenuItem
        Caption = '&Effects and Filters...'
        ShortCut = 16453
        OnClick = mnuEffectsClick
      end
      object mnuTrackSync: TMenuItem
        Caption = '&Track Synchronization'
        OnClick = mnuTrackSyncClick
      end
      object mnuMediaInfo: TMenuItem
        Caption = 'Media &Information...'
        ShortCut = 16457
        OnClick = mnuMediaInfoClick
      end
      object mnuCodecInfo: TMenuItem
        Caption = '&Codec Information...'
        ShortCut = 16458
        OnClick = mnuCodecInfoClick
      end
      object mnuVLM: TMenuItem
        Caption = 'VLM &Configuration...'
        ShortCut = 24663
        OnClick = mnuMediaInfoClick
      end
      object mnuProgramGuide: TMenuItem
        Caption = 'Program &Guide'
        OnClick = mnuProgramGuideClick
      end
      object mnuMessages: TMenuItem
        Caption = '&Messages...'
        ShortCut = 16461
        OnClick = mnuMessagesClick
      end
      object mnuPlugins: TMenuItem
        Caption = '&Plugins and extensions'
        OnClick = mnuPluginsClick
      end
      object mnuThemes: TMenuItem
        Caption = '&Theme / Style'
        OnClick = mnuThemesClick
      end
      object mnuWebRemote: TMenuItem
        Caption = '&Web Remote Control Server (Port 8080)'
        OnClick = mnuWebRemoteClick
      end
      object mnuSepTools: TMenuItem
        Caption = '-'
      end
      object mnuCustomizeInterface: TMenuItem
        Caption = 'Customize &Interface...'
        OnClick = mnuCustomizeInterfaceClick
      end
      object mnuPreferences: TMenuItem
        Caption = '&Preferences...'
        ShortCut = 16464
        OnClick = mnuPreferencesClick
      end
    end
    object mnuView: TMenuItem
      Caption = 'Vie&w'
      object mnuViewPlaylist: TMenuItem
        Caption = '&Playlist'
        Checked = True
        ShortCut = 16460
        OnClick = mnuViewPlaylistClick
      end
      object mnuDockedPlaylist: TMenuItem
        Caption = '&Docked Playlist'
        Checked = True
        OnClick = mnuDockedPlaylistClick
      end
      object mnuSepView1: TMenuItem
        Caption = '-'
      end
      object mnuViewAlwaysOnTop: TMenuItem
        Caption = 'Always on &top'
        OnClick = mnuAlwaysOnTopClick
      end
      object mnuMinimal: TMenuItem
        Caption = '&Minimal Interface'
        ShortCut = 16456
        OnClick = mnuMinimalClick
      end
      object mnuViewFullscreen: TMenuItem
        Caption = '&Fullscreen Interface'
        ShortCut = 122
        OnClick = mnuFullscreenClick
      end
      object mnuAdvancedControls: TMenuItem
        Caption = 'Advanc&ed Controls'
        Checked = True
        OnClick = mnuAdvancedControlsClick
      end
      object mnuStatusBar: TMenuItem
        Caption = 'Status &Bar'
        Checked = True
        OnClick = mnuStatusBarClick
      end
      object mnuBorderless: TMenuItem
        Caption = 'Borderless Cinema Mode'
        ShortCut = 16432
        OnClick = mnuBorderlessClick
      end
      object mnuStatsHUD: TMenuItem
        Caption = 'Diagnostics HUD'
        ShortCut = 73
        OnClick = mnuStatsHUDClick
      end
      object mnuSepView2: TMenuItem
        Caption = '-'
      end
      object mnuAddInterface: TMenuItem
        Caption = 'Add &Interface'
        Visible = False
        OnClick = mnuAddInterfaceClick
      end
      object mnuVLSub: TMenuItem
        Caption = 'Load subtitle &file...'
        OnClick = mnuVLSubClick
      end
    end
    object mnuHelp: TMenuItem
      Caption = '&Help'
      object mnuHotkeys: TMenuItem
        Caption = '&Keyboard Shortcuts Reference...'
        ShortCut = 112
        OnClick = mnuHotkeysClick
      end
      object mnuAbout: TMenuItem
        Caption = '&About VLC Modern...'
        OnClick = mnuAboutClick
      end
    end
  end
  object PopupMenuVideo: TPopupMenu
    OnPopup = PopupMenuVideoPopup
    Left = 40
    Top = 110
    object popPlayPause: TMenuItem
      Caption = 'Play / Pause'
      ShortCut = 32
      OnClick = mnuPlayPauseClick
    end
    object popStop: TMenuItem
      Caption = 'Stop'
      ShortCut = 83
      OnClick = mnuStopClick
    end
    object popPrevious: TMenuItem
      Caption = 'Previous'
      ShortCut = 80
      OnClick = mnuPreviousClick
    end
    object popNext: TMenuItem
      Caption = 'Next'
      ShortCut = 78
      OnClick = mnuNextClick
    end
    object popJumpFwd: TMenuItem
      Caption = 'Jump Forward 10s'
      OnClick = mnuJumpFwdClick
    end
    object popJumpBack: TMenuItem
      Caption = 'Jump Backward 10s'
      OnClick = mnuJumpBackClick
    end
    object popJumpTime: TMenuItem
      Caption = 'Jump to Specific Time...'
      ShortCut = 16468
      OnClick = mnuJumpTimeClick
    end
    object popABRepeat: TMenuItem
      Caption = 'A-B Repeat Loop'
      OnClick = mnuABRepeatClick
    end
    object popNextFrame: TMenuItem
      Caption = 'Step Frame'
      ShortCut = 69
      OnClick = mnuNextFrameClick
    end
    object popSep1: TMenuItem
      Caption = '-'
    end
    object popVideo: TMenuItem
      Caption = 'Video'
      object popFullscreen: TMenuItem
        Caption = 'Fullscreen'
        ShortCut = 70
        OnClick = mnuFullscreenClick
      end
      object popAlwaysOnTop: TMenuItem
        Caption = 'Always on Top'
        OnClick = mnuAlwaysOnTopClick
      end
      object popAspect: TMenuItem
        Caption = 'Aspect Ratio'
        object popAspectDef: TMenuItem
          Caption = 'Default'
          OnClick = mnuAspectItemClick
        end
        object popAspect169: TMenuItem
          Caption = '16:9'
          OnClick = mnuAspectItemClick
        end
        object popAspect43: TMenuItem
          Caption = '4:3'
          OnClick = mnuAspectItemClick
        end
        object popAspect1610: TMenuItem
          Caption = '16:10'
          OnClick = mnuAspectItemClick
        end
        object popAspect11: TMenuItem
          Caption = '1:1'
          OnClick = mnuAspectItemClick
        end
        object popAspect235: TMenuItem
          Caption = '2.35:1'
          OnClick = mnuAspectItemClick
        end
      end
      object popCrop: TMenuItem
        Caption = 'Crop'
        object popCropDef: TMenuItem
          Caption = 'Default'
          OnClick = mnuCropClick
        end
        object popCrop169: TMenuItem
          Caption = '16:9'
          OnClick = mnuCropClick
        end
        object popCrop43: TMenuItem
          Caption = '4:3'
          OnClick = mnuCropClick
        end
        object popCrop1610: TMenuItem
          Caption = '16:10'
          OnClick = mnuCropClick
        end
        object popCrop11: TMenuItem
          Caption = '1:1'
          OnClick = mnuCropClick
        end
      end
      object popDeinterlace: TMenuItem
        Caption = 'Deinterlace'
        object popDeinterlaceAuto: TMenuItem
          Caption = 'auto'
          OnClick = mnuDeinterlaceClick
        end
        object popDeinterlaceOn: TMenuItem
          Caption = 'on'
          OnClick = mnuDeinterlaceClick
        end
        object popDeinterlaceOff: TMenuItem
          Caption = 'off'
          OnClick = mnuDeinterlaceClick
        end
      end
      object popSnapshot: TMenuItem
        Caption = 'Take Snapshot'
        ShortCut = 49235
        OnClick = mnuSnapshotClick
      end
    end
    object popAudio: TMenuItem
      Caption = 'Audio'
      object popAudioTrack: TMenuItem
        Caption = 'Audio Track'
      end
      object popAudioChannel: TMenuItem
        Caption = 'Stereo Channel'
        object popChanStereo: TMenuItem
          Tag = 1
          Caption = 'Stereo'
          OnClick = mnuAudioChannelClick
        end
        object popChanRStereo: TMenuItem
          Tag = 2
          Caption = 'Reverse Stereo'
          OnClick = mnuAudioChannelClick
        end
        object popChanLeft: TMenuItem
          Tag = 3
          Caption = 'Left Only'
          OnClick = mnuAudioChannelClick
        end
        object popChanRight: TMenuItem
          Tag = 4
          Caption = 'Right Only'
          OnClick = mnuAudioChannelClick
        end
        object popChanDolby: TMenuItem
          Tag = 5
          Caption = 'Dolby Surround'
          OnClick = mnuAudioChannelClick
        end
      end
      object popVolUp: TMenuItem
        Caption = 'Volume Up (+5%)'
        OnClick = mnuVolUpClick
      end
      object popVolDown: TMenuItem
        Caption = 'Volume Down (-5%)'
        OnClick = mnuVolDownClick
      end
      object popMute: TMenuItem
        Caption = 'Mute'
        ShortCut = 77
        OnClick = mnuMuteClick
      end
      object popAudioDelayPlus: TMenuItem
        Caption = 'Audio Delay (+50ms)'
        OnClick = mnuAudioDelayPlusClick
      end
      object popAudioDelayMinus: TMenuItem
        Caption = 'Audio Delay (-50ms)'
        OnClick = mnuAudioDelayMinusClick
      end
      object popSepAudioFilters: TMenuItem
        Caption = '-'
      end
      object popVoiceClarifier: TMenuItem
        Caption = 'Voice &Clarifier (Dialogue Boost)'
        OnClick = mnuVoiceClarifierClick
      end
      object popNightMode: TMenuItem
        Caption = '&Night Mode (Compress Loud Audio)'
        OnClick = mnuNightModeClick
      end
      object popHeadphoneSurround: TMenuItem
        Caption = '3D &Headphone Surround (HRTF)'
        OnClick = mnuHeadphoneSurroundClick
      end
      object popKaraokeMode: TMenuItem
        Caption = '&Voice Removal (Karaoke Mode)'
        OnClick = mnuKaraokeModeClick
      end
      object popAudioPassthrough: TMenuItem
        Caption = 'Digital Audio &Passthrough (S/PDIF / HDMI)'
        OnClick = mnuAudioPassthroughClick
      end
      object popEQPresets: TMenuItem
        Caption = 'Equalizer Presets'
      end
      object popEffects: TMenuItem
        Caption = 'Effects and Filters...'
        ShortCut = 16453
        OnClick = mnuEffectsClick
      end
    end
    object popSubtitle: TMenuItem
      Caption = 'Subtitle'
      object popAddSub: TMenuItem
        Caption = 'Add Subtitle File...'
        OnClick = mnuAddSubClick
      end
      object popAddSecondarySub: TMenuItem
        Caption = 'Add Secondary Subtitle (Top Display)...'
        OnClick = mnuAddSecondarySubClick
      end
      object popSubTrack: TMenuItem
        Caption = 'Subtitle Track'
      end
      object popSubDelayPlus: TMenuItem
        Caption = 'Subtitle Delay (+50ms)'
        OnClick = mnuSubDelayPlusClick
      end
      object popSubDelayMinus: TMenuItem
        Caption = 'Subtitle Delay (-50ms)'
        OnClick = mnuSubDelayMinusClick
      end
    end
    object popSpeed: TMenuItem
      Caption = 'Speed'
      object popSpeed025: TMenuItem
        Tag = 25
        Caption = '0.25x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed05: TMenuItem
        Tag = 50
        Caption = '0.50x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed075: TMenuItem
        Tag = 75
        Caption = '0.75x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed10: TMenuItem
        Tag = 100
        Caption = '1.00x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed125: TMenuItem
        Tag = 125
        Caption = '1.25x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed15: TMenuItem
        Tag = 150
        Caption = '1.50x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed20: TMenuItem
        Tag = 200
        Caption = '2.00x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed30: TMenuItem
        Tag = 300
        Caption = '3.00x'
        OnClick = mnuSpeedItemClick
      end
      object popSpeed40: TMenuItem
        Tag = 400
        Caption = '4.00x'
        OnClick = mnuSpeedItemClick
      end
    end
    object popSep2: TMenuItem
      Caption = '-'
    end
    object popMediaInfo: TMenuItem
      Caption = 'Codec Information...'
      ShortCut = 16457
      OnClick = mnuMediaInfoClick
    end
    object popPlaylist: TMenuItem
      Caption = 'Playlist'
      ShortCut = 16460
      OnClick = mnuViewPlaylistClick
    end
    object popOpenFile: TMenuItem
      Caption = 'Open File...'
      ShortCut = 16463
      OnClick = mnuOpenFileClick
    end
    object popOpenURL: TMenuItem
      Caption = 'Open Network Stream...'
      ShortCut = 16462
      OnClick = mnuOpenURLClick
    end
    object popSep3: TMenuItem
      Caption = '-'
    end
    object popThemes: TMenuItem
      Caption = 'Themes'
    end
    object popBookmarks: TMenuItem
      Caption = 'Bookmarks...'
      ShortCut = 16450
      OnClick = mnuBookmarksClick
    end
    object popStatsHUD: TMenuItem
      Caption = 'Diagnostics HUD'
      ShortCut = 73
      OnClick = mnuStatsHUDClick
    end
    object popPreferences: TMenuItem
      Caption = 'Preferences...'
      ShortCut = 16464
      OnClick = mnuPreferencesClick
    end
    object popExit: TMenuItem
      Caption = 'Exit'
      OnClick = mnuExitClick
    end
  end
  object tmrUpdate: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmrUpdateTimer
    Left = 120
    Top = 50
  end
  object tmrOSD: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = tmrOSDTimer
    Left = 190
    Top = 50
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'All Media Files|*.mp4;*.mkv;*.avi;*.mov;*.flv;*.wmv;*.ts;*.webm;*.mp3;*.wav;*.m4a;*.flac;*.aac;*.ogg|Video Files|*.mp4;*.mkv;*.avi;*.mov;*.flv;*.wmv;*.ts;*.webm|Audio Files|*.mp3;*.wav;*.m4a;*.flac;*.aac;*.ogg|All Files (*.*)|*.*'
    Title = 'Select Media File'
    Left = 260
    Top = 50
  end
  object OpenDialogSub: TOpenDialog
    Filter = 
      'Subtitle Files (*.srt, *.sub, *.ass, *.vtt)|*.srt;*.sub;*.ass;*.vtt|All Files (*.*)|*.*'
    Title = 'Select Subtitle File'
    Left = 340
    Top = 50
  end
  object SaveDialogPlaylist: TSaveDialog
    DefaultExt = 'm3u'
    Filter = 'M3U Playlist (*.m3u)|*.m3u|All Files (*.*)|*.*'
    Title = 'Save Playlist'
    Left = 420
    Top = 50
  end
  object OpenDialogPlaylist: TOpenDialog
    Filter = 'M3U Playlist (*.m3u)|*.m3u|All Files (*.*)|*.*'
    Title = 'Open Playlist'
    Left = 500
    Top = 50
  end
end
