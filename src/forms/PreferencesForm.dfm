object FrmPreferences: TFrmPreferences
  Left = 200
  Top = 100
  Caption = 'VLC Modern Settings'
  ClientHeight = 560
  ClientWidth = 780
  Color = 2105376
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 512
    Align = alLeft
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 0
    object lblCategoriesTitle: TLabel
      Left = 12
      Top = 10
      Width = 73
      Height = 15
      Caption = 'CATEGORIES'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object treeCategories: TTreeView
      Left = 8
      Top = 32
      Width = 184
      Height = 472
      Align = alNone
      Color = 2697513
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 15527148
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Indent = 18
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      ShowLines = False
      TabOrder = 0
      OnChange = treeCategoriesChange
    end
  end
  object pnlMain: TPanel
    Left = 200
    Top = 0
    Width = 580
    Height = 512
    Align = alClient
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 1
    object PageControlPages: TPageControl
      Left = 0
      Top = 0
      Width = 580
      Height = 512
      ActivePage = tabGeneral
      Align = alClient
      TabOrder = 0
      object tabGeneral: TTabSheet
        Caption = 'General'
        object grpStartup: TGroupBox
          Left = 12
          Top = 10
          Width = 546
          Height = 180
          Caption = ' Startup & Instances '
          TabOrder = 0
          object lblTheme: TLabel
            Left = 260
            Top = 28
            Caption = 'Theme (applies on restart)'
          end
          object cboTheme: TComboBox
            Left = 260
            Top = 51
            Width = 222
            Height = 25
            Style = csDropDownList
            TabOrder = 7
            Items.Strings = (
              'Follow system'
              'Light'
              'Dark')
          end
          object chkSingleInstance: TPlayerCheckBox
            Left = 18
            Top = 24
            Width = 320
            Height = 18
            Caption = 'Allow only single instance of player'
            Checked = True
            State = cbChecked
            TabOrder = 0
          end
          object chkRememberSize: TPlayerCheckBox
            Left = 18
            Top = 46
            Width = 320
            Height = 18
            Caption = 'Remember window size and position'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object chkStartFullscreen: TPlayerCheckBox
            Left = 18
            Top = 68
            Width = 320
            Height = 18
            Caption = 'Start video in Fullscreen mode'
            TabOrder = 2
          end
          object chkBossKeyHide: TPlayerCheckBox
            Left = 18
            Top = 90
            Width = 320
            Height = 18
            Caption = 'Boss Key (F11) hides player and mutes sound'
            Checked = True
            State = cbChecked
            TabOrder = 3
          end
          object chkCinemaMode: TPlayerCheckBox
            Left = 18
            Top = 112
            Width = 320
            Height = 18
            Caption = 'Cinema Mode (Frameless / Hide title & menu)'
            TabOrder = 4
          end
          object chkShowMenuBar: TPlayerCheckBox
            Left = 18
            Top = 134
            Width = 220
            Height = 18
            Caption = 'Show Top Menu Bar'
            Checked = True
            State = cbChecked
            TabOrder = 5
          end
          object chkShowTitleBar: TPlayerCheckBox
            Left = 260
            Top = 134
            Width = 220
            Height = 18
            Caption = 'Show Title Bar'
            Checked = True
            State = cbChecked
            TabOrder = 6
          end
        end
        object grpOSD: TGroupBox
          Left = 12
          Top = 196
          Width = 546
          Height = 145
          Caption = ' OSD (On-Screen Display) '
          TabOrder = 1
          object lblOsdDuration: TLabel
            Left = 18
            Top = 84
            Width = 108
            Height = 15
            Caption = 'OSD Fade Duration:'
          end
          object lblOsdSize: TLabel
            Left = 280
            Top = 84
            Width = 77
            Height = 15
            Caption = 'OSD Font Size:'
          end
          object chkShowOSD: TPlayerCheckBox
            Left = 18
            Top = 26
            Width = 350
            Height = 20
            Caption = 'Show OSD messages (volume, seek, speed, aspect)'
            Checked = True
            State = cbChecked
            TabOrder = 0
          end
          object chkShowFilename: TPlayerCheckBox
            Left = 18
            Top = 52
            Width = 350
            Height = 20
            Caption = 'Display file name and media title on playback start'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object cboOsdDuration: TComboBox
            Left = 18
            Top = 106
            Width = 220
            Height = 23
            Style = csOwnerDrawFixed
            ItemIndex = 1
            TabOrder = 2
            Text = '2.0 Seconds (Standard)'
            Items.Strings = (
              '1.0 Second (Quick)'
              '2.0 Seconds (Standard)'
              '3.5 Seconds (Extended)'
              '5.0 Seconds (Persistent)')
          end
          object cboOsdSize: TComboBox
            Left = 280
            Top = 106
            Width = 220
            Height = 23
            Style = csOwnerDrawFixed
            ItemIndex = 1
            TabOrder = 3
            Text = 'Medium (18pt)'
            Items.Strings = (
              'Small (14pt)'
              'Medium (18pt)'
              'Large (24pt)'
              'Extra Large (32pt)')
          end
        end
        object grpMouse: TGroupBox
          Left = 12
          Top = 348
          Width = 546
          Height = 125
          Caption = ' Mouse & Interactions '
          TabOrder = 2
          object lblSingleClick: TLabel
            Left = 18
            Top = 26
            Width = 106
            Height = 15
            Caption = 'Left Click on Video:'
          end
          object lblDblClick: TLabel
            Left = 280
            Top = 26
            Width = 121
            Height = 15
            Caption = 'Double Click on Video:'
          end
          object cboSingleClick: TComboBox
            Left = 18
            Top = 46
            Width = 220
            Height = 23
            Style = csOwnerDrawFixed
            ItemIndex = 0
            TabOrder = 0
            Text = 'Play / Pause (Toggle)'
            Items.Strings = (
              'Play / Pause (Toggle)'
              'Fullscreen (Toggle)'
              'Do Nothing')
          end
          object cboDblClick: TComboBox
            Left = 280
            Top = 46
            Width = 220
            Height = 23
            Style = csOwnerDrawFixed
            ItemIndex = 0
            TabOrder = 1
            Text = 'Fullscreen (Toggle)'
            Items.Strings = (
              'Fullscreen (Toggle)'
              'Play / Pause (Toggle)'
              'Aspect Ratio (Cycle)')
          end
          object chkWheelVolume: TPlayerCheckBox
            Left = 18
            Top = 86
            Width = 350
            Height = 20
            Caption = 'Mouse Wheel adjusts audio volume (+/- 5%)'
            Checked = True
            State = cbChecked
            TabOrder = 2
          end
        end
      end
      object tabPlayback: TTabSheet
        Caption = 'Playback'
      end
      object tabVideo: TTabSheet
        Caption = 'Video'
      end
      object tabAudio: TTabSheet
        Caption = 'Audio'
      end
      object tabSubtitles: TTabSheet
        Caption = 'Subtitles'
      end
      object tabNetwork: TTabSheet
        Caption = 'Network & IPTV'
      end
      object tabAssociations: TTabSheet
        Caption = 'Associations'
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 512
    Width = 780
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 2
    object btnReset: TPlayerTextButton
      Left = 14
      Top = 10
      Width = 140
      Height = 28
      Caption = 'Reset All Defaults'
      TabOrder = 0
      OnClick = btnResetClick
    end
    object btnSave: TPlayerTextButton
      Left = 560
      Top = 10
      Width = 100
      Height = 28
      Caption = 'OK'
      Default = True
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object btnCancel: TPlayerTextButton
      Left = 670
      Top = 10
      Width = 95
      Height = 28
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnApply: TPlayerTextButton
      Left = 450
      Top = 10
      Width = 100
      Height = 28
      Caption = 'Apply'
      TabOrder = 3
      OnClick = btnApplyClick
    end
  end
end
