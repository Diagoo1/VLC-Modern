object FrmConvert: TFrmConvert
  Left = 200
  Top = 150
  BorderStyle = bsDialog
  Caption = 'Convert & Stream Media'
  ClientHeight = 320
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object lblSource: TLabel
    Left = 16
    Top = 16
    Width = 88
    Height = 15
    Caption = 'Source File / URL:'
  end
  object edtSource: TEdit
    Left = 16
    Top = 36
    Width = 380
    Height = 23
    TabOrder = 0
  end
  object btnBrowseSource: TPlayerTextButton
    Left = 404
    Top = 35
    Width = 80
    Height = 25
    Caption = 'Browse...'
    TabOrder = 1
    OnClick = btnBrowseSourceClick
  end
  object lblProfile: TLabel
    Left = 16
    Top = 75
    Width = 84
    Height = 15
    Caption = 'Convert Profile:'
  end
  object cboProfile: TComboBox
    Left = 16
    Top = 95
    Width = 380
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = 'Video - H.264 + AAC (MP4)'
    Items.Strings = (
      'Video - H.264 + AAC (MP4)'
      'Video - VP80 + Vorbis (WebM)'
      'Audio - MP3'
      'Audio - FLAC')
  end
  object lblDestination: TLabel
    Left = 16
    Top = 135
    Width = 113
    Height = 15
    Caption = 'Destination File Path:'
  end
  object edtDestination: TEdit
    Left = 16
    Top = 155
    Width = 380
    Height = 23
    TabOrder = 3
  end
  object btnBrowseDest: TPlayerTextButton
    Left = 404
    Top = 154
    Width = 80
    Height = 25
    Caption = 'Browse...'
    TabOrder = 4
    OnClick = btnBrowseDestClick
  end
  object pnlProgress: TPanel
    Left = 16
    Top = 195
    Width = 468
    Height = 65
    BevelOuter = bvNone
    TabOrder = 5
    object pbConvert: TPlayerProgress
      Left = 0
      Top = 10
      Width = 468
      Height = 20
      TabOrder = 0
    end
    object lblStatus: TLabel
      Left = 2
      Top = 38
      Width = 105
      Height = 15
      Caption = 'Ready to convert...'
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 275
    Width = 500
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 6
    object btnClose: TPlayerTextButton
      Left = 398
      Top = 8
      Width = 90
      Height = 28
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object btnStart: TPlayerTextButton
      Left = 280
      Top = 8
      Width = 110
      Height = 28
      Caption = 'Start Convert'
      Default = True
      TabOrder = 1
      OnClick = btnStartClick
    end
  end
  object OpenDialogSource: TOpenDialog
    Filter = 'All Media Files|*.mp4;*.mkv;*.avi;*.mov;*.flv;*.mp3;*.wav;*.flac;*.ts;*.wmv;*.webm|All Files (*.*)|*.*'
    Left = 368
    Top = 8
  end
  object SaveDialogDest: TSaveDialog
    Filter = 'MP4 Video (*.mp4)|*.mp4'
    Left = 432
    Top = 8
  end
  object tmrMonitor: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrMonitorTimer
    Left = 304
    Top = 8
  end
end
