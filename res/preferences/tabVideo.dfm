object tabVideo: TTabSheet
  Caption = 'Video'
  ImageIndex = 2
  object grpHardware: TGroupBox
    Left = 12
    Top = 10
    Width = 546
    Height = 120
    Caption = ' Hardware Acceleration & Decoders '
    TabOrder = 0
    object lblHwAccel: TLabel
      Left = 18
      Top = 26
      Width = 176
      Height = 15
      Caption = 'Hardware-Accelerated Decoding:'
    end
    object cboHwAccel: TComboBox
      Left = 18
      Top = 46
      Width = 320
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 0
      Text = 'Automatic (Direct3D 11 / DXVA2)'
      Items.Strings = (
        'Automatic (Direct3D 11 / DXVA2)'
        'Direct3D 11 Video Acceleration (D3D11VA)'
        'DirectX Video Acceleration (DXVA2)'
        'Disabled (CPU Software Decoding)')
    end
    object chkZeroCopy: TPlayerCheckBox
      Left = 18
      Top = 82
      Width = 400
      Height = 20
      Caption = 'Allow decoder direct rendering'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object grpVideoOut: TGroupBox
    Left = 12
    Top = 140
    Width = 546
    Height = 120
    Caption = ' Video Output & Deinterlacing '
    TabOrder = 1
    object lblVout: TLabel
      Left = 18
      Top = 26
      Width = 125
      Height = 15
      Caption = 'Video Output Module:'
    end
    object lblDeinterlace: TLabel
      Left = 280
      Top = 26
      Width = 117
      Height = 15
      Caption = 'Deinterlacing Filter:'
    end
    object cboVout: TComboBox
      Left = 18
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 0
      Text = 'Automatic'
      Items.Strings = (
        'Automatic'
        'Direct3D 11'
        'Direct3D 9'
        'Windows GDI'
        'OpenGL')
    end
    object cboDeinterlace: TComboBox
      Left = 280
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 1
      TabOrder = 1
      Text = 'Auto (Dynamic)'
      Items.Strings = (
        'Off (Disabled)'
        'Auto (Dynamic)'
        'On - Yadif 2x (Best Quality)'
        'On - Bob'
        'On - Linear')
    end
    object chkAspectAuto: TPlayerCheckBox
      Left = 18
      Top = 84
      Width = 350
      Height = 20
      Caption = 'Automatically honor native video aspect ratio'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
end
