object tabPlayback: TTabSheet
  Caption = 'Playback'
  ImageIndex = 1
  object grpPlaybackGen: TGroupBox
    Left = 12
    Top = 10
    Width = 546
    Height = 140
    Caption = ' Playback & History '
    TabOrder = 0
    object lblResume: TLabel
      Left = 18
      Top = 26
      Width = 146
      Height = 15
      Caption = 'Resume Playback Position:'
    end
    object lblAfterPlayback: TLabel
      Left = 280
      Top = 26
      Width = 117
      Height = 15
      Caption = 'After Playback Ends:'
    end
    object cboResume: TComboBox
      Left = 18
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 0
      Text = 'Always Resume Exact Position'
      Items.Strings = (
        'Always Resume Exact Position'
        'Ask User on Start'
        'Never Resume (Start from 0)')
    end
    object cboAfterPlayback: TComboBox
      Left = 280
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 1
      Text = 'Stop Playback'
      Items.Strings = (
        'Stop Playback'
        'Play Next Item in Playlist'
        'Repeat Current Video'
        'Quit Player'
        'Put Computer to Sleep')
    end
    object chkSaveHistory: TPlayerCheckBox
      Left = 18
      Top = 88
      Width = 350
      Height = 20
      Caption = 'Save played files to Recent Media history'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object chkAutoPlayNext: TPlayerCheckBox
      Left = 18
      Top = 112
      Width = 350
      Height = 20
      Caption = 'Automatically play next file in same directory'
      TabOrder = 3
    end
  end
  object grpSpeedJump: TGroupBox
    Left = 12
    Top = 160
    Width = 546
    Height = 150
    Caption = ' Speed & Time Jump (Hotkeys: Z, X, C) '
    TabOrder = 1
    object lblJumpShort: TLabel
      Left = 18
      Top = 26
      Width = 103
      Height = 15
      Caption = 'Short Jump (Left/Right):'
    end
    object lblJumpMedium: TLabel
      Left = 180
      Top = 26
      Width = 121
      Height = 15
      Caption = 'Medium Jump (Ctrl):'
    end
    object lblJumpLong: TLabel
      Left = 350
      Top = 26
      Width = 107
      Height = 15
      Caption = 'Long Jump (Alt):'
    end
    object cboJumpShort: TComboBox
      Left = 18
      Top = 46
      Width = 140
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 1
      TabOrder = 0
      Text = '5 Seconds'
      Items.Strings = ('3 Seconds' '5 Seconds' '10 Seconds')
    end
    object cboJumpMedium: TComboBox
      Left = 180
      Top = 46
      Width = 140
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 1
      TabOrder = 1
      Text = '10 Seconds'
      Items.Strings = ('10 Seconds' '30 Seconds' '60 Seconds')
    end
    object cboJumpLong: TComboBox
      Left = 350
      Top = 46
      Width = 140
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 1
      TabOrder = 2
      Text = '60 Seconds (1 Min)'
      Items.Strings = ('30 Seconds' '60 Seconds (1 Min)' '300 Seconds (5 Min)')
    end
    object chkScaletempo: TPlayerCheckBox
      Left = 18
      Top = 90
      Width = 480
      Height = 20
      Caption = 'Enable Scaletempo (Preserve voice pitch when speeding up / slowing down)'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chkShowSpeedOSD: TPlayerCheckBox
      Left = 18
      Top = 116
      Width = 480
      Height = 20
      Caption = 'Display real-time speed percentage badge on bottom control bar'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
end
