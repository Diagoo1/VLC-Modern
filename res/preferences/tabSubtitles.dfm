object tabSubtitles: TTabSheet
  Caption = 'Subtitles'
  ImageIndex = 4
  object grpSubStyle: TGroupBox
    Left = 12
    Top = 10
    Width = 546
    Height = 170
    Caption = ' Subtitle Typography & Styling '
    TabOrder = 0
    object lblSubFont: TLabel
      Left = 18
      Top = 26
      Width = 63
      Height = 15
      Caption = 'Font Family:'
    end
    object lblSubSize: TLabel
      Left = 280
      Top = 26
      Width = 50
      Height = 15
      Caption = 'Font Size:'
    end
    object lblSubEncoding: TLabel
      Left = 18
      Top = 84
      Width = 84
      Height = 15
      Caption = 'Text Encoding:'
    end
    object cboSubFont: TComboBox
      Left = 18
      Top = 46
      Width = 220
      Height = 23
      ItemIndex = 0
      TabOrder = 0
      Text = 'Segoe UI'
      Items.Strings = ('Segoe UI' 'Arial' 'Tahoma' 'Roboto' 'Cairo' 'Trebuchet MS')
    end
    object cboSubSize: TComboBox
      Left = 280
      Top = 46
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 1
      TabOrder = 1
      Text = 'Normal (22pt)'
      Items.Strings = ('Small (16pt)' 'Normal (22pt)' 'Large (28pt)' 'Very Large (36pt)')
    end
    object cboSubEncoding: TComboBox
      Left = 18
      Top = 104
      Width = 220
      Height = 23
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 2
      Text = 'Universal (UTF-8)'
      Items.Strings = (
        'Universal (UTF-8)'
        'Arabic (Windows-1256)'
        'Western European (Windows-1252)'
        'Eastern European (Windows-1250)'
        'Cyrillic (Windows-1251)')
    end
    object chkSubBold: TCheckBox
      Left = 280
      Top = 104
      Width = 150
      Height = 20
      Caption = 'Bold Subtitles'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chkSubAutoLoad: TCheckBox
      Left = 18
      Top = 138
      Width = 350
      Height = 20
      Caption = 'Auto-detect and load subtitles with matching filename'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
end
