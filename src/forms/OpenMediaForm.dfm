object FrmOpenMedia: TFrmOpenMedia
  Left = 220
  Top = 160
  BorderStyle = bsDialog
  Caption = 'Open Media (Network / Disc / Capture)'
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
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 12
    Top = 12
    Width = 476
    Height = 255
    ActivePage = tabNetwork
    TabOrder = 0
    object tabNetwork: TTabSheet
      Caption = 'Network'
      object lblNetworkURL: TLabel
        Left = 16
        Top = 20
        Width = 240
        Height = 15
        Caption = 'Please enter a network URL (HTTP, RTSP, RTMP):'
      end
      object cboNetworkURL: TComboBox
        Left = 16
        Top = 45
        Width = 435
        Height = 23
        TabOrder = 0
        Text = 'https://'
      end
      object lblNetCaching: TLabel
        Left = 16
        Top = 95
        Width = 95
        Height = 15
        Caption = 'Network Caching:'
      end
      object edtNetCaching: TEdit
        Left = 120
        Top = 92
        Width = 60
        Height = 23
        TabOrder = 1
        Text = '1500'
      end
      object lblNetCachingMs: TLabel
        Left = 188
        Top = 95
        Width = 16
        Height = 15
        Caption = 'ms'
      end
    end
    object tabDisc: TTabSheet
      Caption = 'Disc'
      ImageIndex = 1
      object grpDiscType: TRadioGroup
        Left = 16
        Top = 16
        Width = 435
        Height = 65
        Caption = 'Disc Selection'
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'DVD'
          'Audio CD'
          'Blu-ray')
        TabOrder = 0
      end
      object lblDrive: TLabel
        Left = 16
        Top = 105
        Width = 63
        Height = 15
        Caption = 'Disc Device:'
      end
      object cboDrives: TComboBox
        Left = 90
        Top = 102
        Width = 150
        Height = 23
        Style = csDropDownList
        TabOrder = 1
      end
    end
    object tabCapture: TTabSheet
      Caption = 'Capture Device'
      ImageIndex = 2
      object lblCaptureMode: TLabel
        Left = 16
        Top = 20
        Width = 79
        Height = 15
        Caption = 'Capture Mode:'
      end
      object cboCaptureMode: TComboBox
        Left = 16
        Top = 45
        Width = 250
        Height = 23
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Desktop Screen Capture (screen://)'
        Items.Strings = (
          'Desktop Screen Capture (screen://)'
          'DirectShow Device (Webcam / Mic)')
      end
      object lblScreenFps: TLabel
        Left = 16
        Top = 95
        Width = 98
        Height = 15
        Caption = 'Desired Frame Rate:'
      end
      object edtScreenFps: TEdit
        Left = 125
        Top = 92
        Width = 50
        Height = 23
        TabOrder = 1
        Text = '30'
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 275
    Width = 500
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnCancel: TButton
      Left = 398
      Top = 10
      Width = 90
      Height = 26
      Caption = 'Cancel'
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnPlay: TButton
      Left = 298
      Top = 10
      Width = 90
      Height = 26
      Caption = 'Play'
      Default = True
      TabOrder = 1
      OnClick = btnPlayClick
    end
  end
end
