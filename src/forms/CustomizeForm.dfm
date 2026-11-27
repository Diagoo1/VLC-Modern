object FrmCustomize: TFrmCustomize
  Left = 240
  Top = 150
  BorderStyle = bsDialog
  Caption = 'Customize Interface - VLC Modern'
  ClientHeight = 460
  ClientWidth = 560
  Color = 2105376
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object grpTopBar: TGroupBox
    Left = 14
    Top = 12
    Width = 532
    Height = 90
    Caption = ' Top Bar & Navigation '
    TabOrder = 0
    object chkShowMenuBar: TPlayerCheckBox
      Left = 18
      Top = 26
      Width = 450
      Height = 20
      Caption = 'Show Modern Menu Bar (Media, Playback, Audio, Video, Tools...)'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkShowLiveTVBtn: TPlayerCheckBox
      Left = 18
      Top = 54
      Width = 450
      Height = 20
      Caption = 'Show "Live TV" quick access button on Menu Bar'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object grpBottomDock: TGroupBox
    Left = 14
    Top = 110
    Width = 532
    Height = 175
    Caption = ' Bottom Controls Dock '
    TabOrder = 1
    object chkShowSeekBar: TPlayerCheckBox
      Left = 18
      Top = 26
      Width = 240
      Height = 20
      Caption = 'Show Glowing Seek Bar'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkShowTime: TPlayerCheckBox
      Left = 280
      Top = 26
      Width = 230
      Height = 20
      Caption = 'Show Time Elapsed / Duration'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chkShowVolume: TPlayerCheckBox
      Left = 18
      Top = 54
      Width = 240
      Height = 20
      Caption = 'Show Volume Slider & Percentage'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object chkShowSpeedBtn: TPlayerCheckBox
      Left = 280
      Top = 54
      Width = 230
      Height = 20
      Caption = 'Show Playback Speed (1.0x) Button'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chkShowEqualizerBtn: TPlayerCheckBox
      Left = 18
      Top = 82
      Width = 240
      Height = 20
      Caption = 'Show Equalizer Quick Button'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object chkShowPlaylistBtn: TPlayerCheckBox
      Left = 280
      Top = 82
      Width = 230
      Height = 20
      Caption = 'Show Playlist Side Pane Button'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object chkShowFullscreenBtn: TPlayerCheckBox
      Left = 18
      Top = 110
      Width = 240
      Height = 20
      Caption = 'Show Fullscreen Button'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object chkShowAdvControls: TPlayerCheckBox
      Left = 280
      Top = 110
      Width = 230
      Height = 20
      Caption = 'Show Step & Repeat Loop Buttons'
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object lblDockHeight: TLabel
      Left = 18
      Top = 142
      Width = 112
      Height = 15
      Caption = 'Bottom Dock Height:'
    end
    object cboDockHeight: TComboBox
      Left = 140
      Top = 138
      Width = 180
      Height = 23
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 8
      Text = 'Standard (94 px)'
      Items.Strings = (
        'Compact (75 px)'
        'Standard (94 px)'
        'Large (110 px)')
    end
  end
  object grpThemeAccent: TGroupBox
    Left = 14
    Top = 295
    Width = 532
    Height = 105
    Caption = ' Theme & Accent Color '
    TabOrder = 2
    object lblAccentColor: TLabel
      Left = 18
      Top = 28
      Width = 103
      Height = 15
      Caption = 'Player Accent Color:'
    end
    object lblCornerRadius: TLabel
      Left = 280
      Top = 28
      Width = 104
      Height = 15
      Caption = 'Card Corner Radius:'
    end
    object cboAccentColor: TComboBox
      Left = 18
      Top = 50
      Width = 230
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Cyan Accent (#60CDFF)'
      Items.Strings = (
        'Cyan Accent (#60CDFF)'
        'VLC Classic Orange (#E67E22)'
        'Emerald Green (#2ECC71)'
        'Royal Purple (#9B59B6)'
        'Teal Accent (#008080)')
    end
    object cboCornerRadius: TComboBox
      Left = 280
      Top = 50
      Width = 230
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Windows 11 Fluent (10 px)'
      Items.Strings = (
        'Windows 11 Fluent (10 px)'
        'Subtle Round (6 px)'
        'Classic Sharp (0 px)')
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 412
    Width = 560
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 3
    object btnReset: TPlayerTextButton
      Left = 14
      Top = 10
      Width = 120
      Height = 28
      Caption = 'Reset Defaults'
      TabOrder = 0
      OnClick = btnResetClick
    end
    object btnOK: TPlayerTextButton
      Left = 345
      Top = 10
      Width = 95
      Height = 28
      Caption = 'OK'
      Default = True
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TPlayerTextButton
      Left = 450
      Top = 10
      Width = 95
      Height = 28
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnApply: TPlayerTextButton
      Left = 240
      Top = 10
      Width = 95
      Height = 28
      Caption = 'Apply'
      TabOrder = 3
      OnClick = btnApplyClick
    end
  end
end
