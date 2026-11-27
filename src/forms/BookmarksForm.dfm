object FrmBookmarks: TFrmBookmarks
  Left = 240
  Top = 180
  BorderStyle = bsDialog
  Caption = 'Edit Bookmarks'
  ClientHeight = 320
  ClientWidth = 420
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
  object lstBookmarks: TListBox
    Left = 12
    Top = 12
    Width = 396
    Height = 250
    ItemHeight = 15
    TabOrder = 0
    OnDblClick = lstBookmarksDblClick
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 275
    Width = 420
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnAdd: TPlayerTextButton
      Left = 12
      Top = 8
      Width = 85
      Height = 28
      Caption = '+ Create'
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnJump: TPlayerTextButton
      Left = 104
      Top = 8
      Width = 85
      Height = 28
      Caption = 'Jump To'
      TabOrder = 1
      OnClick = btnJumpClick
    end
    object btnDelete: TPlayerTextButton
      Left = 196
      Top = 8
      Width = 85
      Height = 28
      Caption = 'Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnClose: TPlayerTextButton
      Left = 323
      Top = 8
      Width = 85
      Height = 28
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseClick
    end
  end
end
