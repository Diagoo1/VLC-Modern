object tabNetwork: TTabSheet
  Caption = 'Network & IPTV'
  ImageIndex = 5
  object grpStreamBuffer: TGroupBox
    Left = 12
    Top = 10
    Width = 546
    Height = 120
    Caption = ' Stream Buffer & Caching (Prevents Stutter) '
    TabOrder = 0
    object lblNetCache: TLabel
      Left = 18
      Top = 26
      Width = 152
      Height = 15
      Caption = 'Network Cache Buffer (ms):'
    end
    object lblLiveEdge: TLabel
      Left = 280
      Top = 26
      Width = 105
      Height = 15
      Caption = 'Live Stream Mode:'
    end
    object cboNetCache: TComboBox
      Left = 18
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 1
      TabOrder = 0
      Text = '2000 ms (Standard Smooth)'
      Items.Strings = (
        '1000 ms (Low Latency)'
        '2000 ms (Standard Smooth)'
        '3500 ms (High Quality)'
        '5000 ms (Heavy / Unstable Connection)')
    end
    object cboLiveEdge: TComboBox
      Left = 280
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 1
      Text = 'Optimal Live Edge'
      Items.Strings = (
        'Optimal Live Edge'
        'Catchup Buffering'
        'DVR Time-Shifted')
    end
    object chkHlsHardware: TPlayerCheckBox
      Left = 18
      Top = 84
      Width = 350
      Height = 20
      Caption = 'Enable GPU Hardware Decoding for IPTV Streams'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object grpUserAgent: TGroupBox
    Left = 12
    Top = 140
    Width = 546
    Height = 110
    Caption = ' Custom User-Agent & Headers '
    TabOrder = 1
    object lblUserAgent: TLabel
      Left = 18
      Top = 26
      Width = 148
      Height = 15
      Caption = 'HTTP User-Agent Identifier:'
    end
    object cboUserAgent: TComboBox
      Left = 18
      Top = 46
      Width = 350
      Height = 23
      ItemIndex = 0
      TabOrder = 0
      Text = 'VLC/3.0.18 LibVLC/3.0.18'
      Items.Strings = (
        'VLC/3.0.18 LibVLC/3.0.18'
        'IPTVSmartersPlayer'
        'TiviMate/4.7.0'
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
        'AppleCoreMedia/1.0.0')
    end
    object chkPassReferer: TPlayerCheckBox
      Left = 18
      Top = 78
      Width = 350
      Height = 20
      Caption = 'Send HTTP Referer Header on stream request'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
end
