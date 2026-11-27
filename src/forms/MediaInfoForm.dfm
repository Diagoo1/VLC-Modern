object FrmMediaInfo: TFrmMediaInfo
  Left = 280
  Top = 220
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Current Media & Codec Information'
  ClientHeight = 420
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object lblTitle: TLabel
    Left = 16
    Top = 12
    Width = 143
    Height = 17
    Caption = 'Media & Stream Details'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object mmoDetails: TMemo
    Left = 16
    Top = 38
    Width = 488
    Height = 325
    Color = clWindow
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 375
    Width = 520
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnClose: TPlayerTextButton
      Left = 414
      Top = 8
      Width = 90
      Height = 28
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
  end
end
