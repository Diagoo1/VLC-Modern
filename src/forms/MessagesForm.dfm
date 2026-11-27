object FrmMessages: TFrmMessages
  Left = 250
  Top = 150
  Caption = 'Messages - VLC Modern'
  ClientHeight = 420
  ClientWidth = 640
  Color = 2105376
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlBottom: TPanel
    Left = 0
    Top = 372
    Width = 640
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Color = 2105376
    TabOrder = 0
    object btnCopy: TPlayerTextButton
      Left = 14
      Top = 10
      Width = 90
      Height = 28
      Caption = 'Copy Log'
      TabOrder = 0
      OnClick = btnCopyClick
    end
    object btnClear: TPlayerTextButton
      Left = 112
      Top = 10
      Width = 85
      Height = 28
      Caption = 'Clear'
      TabOrder = 1
      OnClick = btnClearClick
    end
    object btnSave: TPlayerTextButton
      Left = 205
      Top = 10
      Width = 110
      Height = 28
      Caption = 'Save Log...'
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnClose: TPlayerTextButton
      Left = 536
      Top = 10
      Width = 90
      Height = 28
      Cancel = True
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseClick
    end
  end
  object memoLog: TMemo
    Left = 12
    Top = 12
    Width = 616
    Height = 352
    Align = alClient
    Color = 1579032
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 15132390
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object SaveDialogLog: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'
    Title = 'Save Messages Log'
    Left = 360
    Top = 200
  end
end
