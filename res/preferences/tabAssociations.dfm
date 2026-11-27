object tabAssociations: TTabSheet
  Caption = 'Associations'
  ImageIndex = 6
  object grpFileTypes: TGroupBox
    Left = 12
    Top = 10
    Width = 546
    Height = 190
    Caption = ' Windows 11 File Type Associations '
    TabOrder = 0
    object chkAssocVideo: TPlayerCheckBox
      Left = 18
      Top = 26
      Width = 480
      Height = 20
      Caption = 'Video Formats (.mp4, .mkv, .avi, .mov, .wmv, .webm, .flv, .ts)'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkAssocAudio: TPlayerCheckBox
      Left = 18
      Top = 52
      Width = 480
      Height = 20
      Caption = 'Audio Formats (.mp3, .flac, .wav, .aac, .m4a, .ogg, .wma)'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chkAssocPlaylists: TPlayerCheckBox
      Left = 18
      Top = 78
      Width = 480
      Height = 20
      Caption = 'Playlist Files (.m3u, .m3u8, .pls, .xspf)'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object btnRegisterAssoc: TPlayerTextButton
      Left = 18
      Top = 120
      Width = 240
      Height = 32
      Caption = 'Register Associations in Windows...'
      TabOrder = 3
      OnClick = btnRegisterAssocClick
    end
  end
end
