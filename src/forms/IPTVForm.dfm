object FrmIPTV: TFrmIPTV
  Left = 180
  Top = 100
  Caption = 'Live TV & IPTV'
  ClientHeight = 680
  ClientWidth = 980
  Color = 2105376
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 840
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 0
    object lblSearch: TLabel
      Left = 14
      Top = 17
      Width = 39
      Height = 15
      Caption = 'Search:'
    end
    object lblChannelCount: TLabel
      Left = 720
      Top = 17
      Width = 100
      Height = 15
      Alignment = taRightJustify
      Caption = '0 Channels'
    end
    object edtSearch: TEdit
      Left = 60
      Top = 13
      Width = 140
      Height = 25
      TabOrder = 0
      OnChange = edtSearchChange
    end
    object btnSwitchServer: TButton
      Left = 208
      Top = 12
      Width = 130
      Height = 28
      Caption = 'Portal / Switch Hub'
      TabOrder = 1
      OnClick = btnSwitchServerClick
    end
    object btnAddM3U: TButton
      Left = 344
      Top = 12
      Width = 86
      Height = 28
      Caption = '+ M3U URL'
      TabOrder = 2
      OnClick = btnAddM3UClick
    end
    object btnConnectXtream: TButton
      Left = 436
      Top = 12
      Width = 88
      Height = 28
      Caption = 'Xtream...'
      TabOrder = 3
      OnClick = btnConnectXtreamClick
    end
    object btnOpenLocalM3U: TButton
      Left = 530
      Top = 12
      Width = 78
      Height = 28
      Caption = 'Open File...'
      TabOrder = 4
      OnClick = btnOpenLocalM3UClick
    end
    object btnRefresh: TButton
      Left = 614
      Top = 12
      Width = 50
      Height = 28
      Caption = 'Reload'
      TabOrder = 5
      OnClick = btnRefreshClick
    end
    object btnExportM3U: TButton
      Left = 670
      Top = 12
      Width = 56
      Height = 28
      Caption = 'Export...'
      TabOrder = 6
      OnClick = btnExportM3UClick
    end
  end
  object pnlCategories: TPanel
    Left = 0
    Top = 52
    Width = 200
    Height = 478
    Align = alLeft
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 1
    object lblCatTitle: TLabel
      Left = 12
      Top = 8
      Width = 71
      Height = 15
      Caption = 'CATEGORIES'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lstCategories: TListBox
      Left = 8
      Top = 28
      Width = 184
      Height = 442
      Align = alNone
      Color = 2697513
      ItemHeight = 30
      Style = lbOwnerDrawFixed
      TabOrder = 0
      OnClick = lstCategoriesClick
    end
  end
  object pnlMain: TPanel
    Left = 200
    Top = 52
    Width = 640
    Height = 478
    Align = alClient
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 2
    object lstChannels: TListBox
      Left = 0
      Top = 0
      Width = 640
      Height = 408
      Align = alClient
      Color = 2697513
      ItemHeight = 40
      Style = lbOwnerDrawFixed
      TabOrder = 0
      OnClick = lstChannelsClick
      OnDblClick = lstChannelsDblClick
    end
    object pnlChannelInfo: TPanel
      Left = 0
      Top = 408
      Width = 640
      Height = 70
      Align = alBottom
      BevelOuter = bvNone
      Color = 1579032
      TabOrder = 1
      object lblInfoName: TLabel
        Left = 14
        Top = 8
        Width = 110
        Height = 17
        Caption = 'Select a Channel...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6344191
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblInfoEPG: TLabel
        Left = 14
        Top = 28
        Width = 230
        Height = 15
        Caption = 'EPG: Live Program Broadcasting Schedule'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15132390
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblInfoUrl: TLabel
        Left = 14
        Top = 48
        Width = 84
        Height = 13
        Caption = 'Stream URL: None'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11250603
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblInfoBadge: TLabel
        Left = 540
        Top = 10
        Width = 85
        Height = 15
        Alignment = taRightJustify
        Caption = '[HLS Live]'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6344191
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 530
    Width = 840
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 3
    object btnWatch: TButton
      Left = 14
      Top = 11
      Width = 140
      Height = 28
      Caption = 'Play Live Stream'
      Default = True
      TabOrder = 0
      OnClick = btnWatchClick
    end
    object btnFav: TButton
      Left = 162
      Top = 11
      Width = 120
      Height = 28
      Caption = 'Add to Favorites'
      TabOrder = 1
      OnClick = btnFavClick
    end
    object btnCopyUrl: TButton
      Left = 290
      Top = 11
      Width = 110
      Height = 28
      Caption = 'Copy Stream URL'
      TabOrder = 2
      OnClick = btnCopyUrlClick
    end
    object btnEPG: TButton
      Left = 408
      Top = 11
      Width = 110
      Height = 28
      Caption = 'TV Guide / EPG'
      TabOrder = 3
      OnClick = btnEPGClick
    end
    object btnClose: TButton
      Left = 736
      Top = 11
      Width = 90
      Height = 28
      Cancel = True
      Caption = 'Close'
      TabOrder = 4
      OnClick = btnCloseClick
    end
  end
  object pnlWelcomeHub: TPanel
    Left = 0
    Top = 52
    Width = 840
    Height = 528
    Align = alClient
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 4
    object pnlHubCard: TPanel
      Left = 100
      Top = 20
      Width = 640
      Height = 475
      BevelOuter = bvNone
      Color = 2697513
      TabOrder = 0
      object lblHubTitle: TLabel
        Left = 24
        Top = 16
        Width = 277
        Height = 21
        Caption = 'IPTV & Live Stream Connection Hub'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6344191
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblHubSubtitle: TLabel
        Left = 24
        Top = 42
        Width = 472
        Height = 15
        Caption = 'Choose your preferred connection method: Xtream Codes, Stalker MAC Portal, M3U URL, or Local File.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11250603
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object grpConnType: TGroupBox
        Left = 24
        Top = 68
        Width = 592
        Height = 85
        Caption = ' Connection Protocol '
        TabOrder = 0
        object rbXtream: TRadioButton
          Left = 18
          Top = 24
          Width = 150
          Height = 20
          Caption = 'Xtream Codes API'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbConnTypeClick
        end
        object rbStalkerMac: TRadioButton
          Left = 180
          Top = 24
          Width = 180
          Height = 20
          Caption = 'MAC / Stalker Portal'
          TabOrder = 1
          OnClick = rbConnTypeClick
        end
        object rbM3UUrl: TRadioButton
          Left = 370
          Top = 24
          Width = 190
          Height = 20
          Caption = 'Remote M3U / M3U8 URL'
          TabOrder = 2
          OnClick = rbConnTypeClick
        end
        object rbLocalFile: TRadioButton
          Left = 18
          Top = 52
          Width = 150
          Height = 20
          Caption = 'Local Playlist File'
          TabOrder = 3
          OnClick = rbConnTypeClick
        end
        object rbDemo: TRadioButton
          Left = 180
          Top = 52
          Width = 220
          Height = 20
          Caption = 'Demo Free Channels (Instant)'
          TabOrder = 4
          OnClick = rbConnTypeClick
        end
      end
      object grpCredentials: TGroupBox
        Left = 24
        Top = 162
        Width = 592
        Height = 238
        Caption = ' Connection Details & Credentials '
        TabOrder = 1
        object lblServerUrl: TLabel
          Left = 18
          Top = 24
          Width = 250
          Height = 15
          Caption = 'Xtream Server URL (e.g. http://server:8080):'
        end
        object edtServerUrl: TEdit
          Left = 18
          Top = 44
          Width = 460
          Height = 23
          TabOrder = 0
          Text = 'http://'
        end
        object btnBrowseFile: TButton
          Left = 486
          Top = 43
          Width = 88
          Height = 25
          Caption = 'Browse...'
          TabOrder = 1
          Visible = False
          OnClick = btnBrowseFileClick
        end
        object lblUsernameOrMac: TLabel
          Left = 18
          Top = 76
          Width = 56
          Height = 15
          Caption = 'Username:'
        end
        object edtUsernameOrMac: TEdit
          Left = 18
          Top = 96
          Width = 260
          Height = 23
          TabOrder = 2
        end
        object lblPassword: TLabel
          Left = 295
          Top = 76
          Width = 53
          Height = 15
          Caption = 'Password:'
        end
        object edtPassword: TEdit
          Left = 295
          Top = 96
          Width = 279
          Height = 23
          PasswordChar = '*'
          TabOrder = 3
        end
        object chkRememberPortal: TCheckBox
          Left = 18
          Top = 132
          Width = 320
          Height = 20
          Caption = 'Remember credentials for fast reconnect'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object lblPortalHint: TLabel
          Left = 18
          Top = 162
          Width = 556
          Height = 55
          AutoSize = False
          Caption = 'Supports Xtream Codes API (TS/M3U8), Stalker MAG MAC portals (00:1A:79:XX), remote M3U playlists, and local files. Once connected, channels and EPG are automatically organized into categories.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 11250603
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
      end
      object btnConnectPortal: TButton
        Left = 24
        Top = 412
        Width = 210
        Height = 36
        Caption = 'Connect & Open Channels'
        Default = True
        TabOrder = 2
        OnClick = btnConnectPortalClick
      end
      object btnCancelHub: TButton
        Left = 248
        Top = 412
        Width = 140
        Height = 36
        Caption = 'Back to Channels'
        TabOrder = 3
        OnClick = btnCancelHubClick
      end
    end
  end
  object OpenDialogM3U: TOpenDialog
    DefaultExt = 'm3u'
    Filter = 'IPTV Playlists (*.m3u;*.m3u8)|*.m3u;*.m3u8|All Files (*.*)|*.*'
    Title = 'Open IPTV Playlist'
    Left = 320
    Top = 200
  end
  object SaveDialogExport: TSaveDialog
    DefaultExt = 'm3u'
    Filter = 'M3U Playlist (*.m3u)|*.m3u|M3U8 Playlist (*.m3u8)|*.m3u8|All Files (*.*)|*.*'
    Title = 'Export IPTV Channels'
    Left = 400
    Top = 200
  end
end
