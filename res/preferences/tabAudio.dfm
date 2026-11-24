object tabAudio: TTabSheet
  Caption = 'Audio'
  ImageIndex = 3
  object grpAudioOut: TGroupBox
    Left = 12
    Top = 10
    Width = 546
    Height = 140
    Caption = ' Audio Output & WASAPI '
    TabOrder = 0
    object lblAout: TLabel
      Left = 18
      Top = 26
      Width = 128
      Height = 15
      Caption = 'Audio Output Module:'
    end
    object lblChannels: TLabel
      Left = 280
      Top = 26
      Width = 123
      Height = 15
      Caption = 'Speaker Configuration:'
    end
    object cboAout: TComboBox
      Left = 18
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 0
      Text = 'Automatic (WASAPI)'
      Items.Strings = (
        'Automatic (WASAPI)'
        'Windows Audio Session API (WASAPI)'
        'DirectX DirectSound'
        'WaveOut')
    end
    object cboChannels: TComboBox
      Left = 280
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 1
      Text = 'System speaker layout'
      Items.Strings = (
        'System speaker layout'
        'Stereo (2.0)'
        'Reverse stereo'
        'Left channel'
        'Right channel'
        'Dolby stereo')
    end
    object chkRememberVolume: TCheckBox
      Left = 18
      Top = 86
      Width = 320
      Height = 20
      Caption = 'Remember volume level across player restarts'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object chkNormalizer: TCheckBox
      Left = 18
      Top = 110
      Width = 320
      Height = 20
      Caption = 'Normalize audio volume'
      TabOrder = 3
    end
  end
  object grpVolumeDef: TGroupBox
    Left = 12
    Top = 160
    Width = 546
    Height = 110
    Caption = ' Default Volume & Maximum Gain '
    TabOrder = 1
    object lblDefaultVolume: TLabel
      Left = 18
      Top = 26
      Width = 118
      Height = 15
      Caption = 'Startup Default Volume:'
    end
    object lblDefVolVal: TLabel
      Left = 450
      Top = 50
      Width = 35
      Height = 15
      Caption = '100%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object tbDefaultVol: TTrackBar
      Left = 14
      Top = 48
      Width = 420
      Height = 35
      Max = 200
      Frequency = 20
      Position = 100
      TabOrder = 0
      OnChange = tbDefaultVolChange
    end
  end
end
