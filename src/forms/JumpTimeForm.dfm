object FrmJumpTime: TFrmJumpTime
  Left = 320
  Top = 260
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Jump to Specific Time'
  ClientHeight = 165
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object lblPrompt: TLabel
    Left = 24
    Top = 18
    Width = 148
    Height = 15
    Caption = 'Enter target playback time:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object lblH: TLabel
    Left = 70
    Top = 50
    Width = 14
    Height = 15
    Caption = 'hr'
  end
  object lblM: TLabel
    Left = 145
    Top = 50
    Width = 21
    Height = 15
    Caption = 'min'
  end
  object lblS: TLabel
    Left = 225
    Top = 50
    Width = 17
    Height = 15
    Caption = 'sec'
  end
  object lblTotal: TLabel
    Left = 24
    Top = 88
    Width = 120
    Height = 14
    Caption = 'Total Duration: 00:00:00'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object edtH: TEdit
    Left = 24
    Top = 46
    Width = 42
    Height = 23
    Alignment = taCenter
    NumbersOnly = True
    TabOrder = 0
    Text = '0'
  end
  object edtM: TEdit
    Left = 98
    Top = 46
    Width = 42
    Height = 23
    Alignment = taCenter
    NumbersOnly = True
    TabOrder = 1
    Text = '0'
  end
  object edtS: TEdit
    Left = 178
    Top = 46
    Width = 42
    Height = 23
    Alignment = taCenter
    NumbersOnly = True
    TabOrder = 2
    Text = '0'
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 120
    Width = 320
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnJump: TButton
      Left = 140
      Top = 8
      Width = 80
      Height = 28
      Caption = 'Go / Jump'
      Default = True
      TabOrder = 0
      OnClick = btnJumpClick
    end
    object btnCancel: TButton
      Left = 226
      Top = 8
      Width = 80
      Height = 28
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
