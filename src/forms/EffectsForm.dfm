object FrmEffects: TFrmEffects
  Left = 200
  Top = 150
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Adjustments and Effects'
  ClientHeight = 380
  ClientWidth = 600
  Color = 2105376
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 600
    Height = 335
    ActivePage = tabAudio
    Align = alClient
    TabOrder = 0
    object tabAudio: TTabSheet
      Caption = 'Audio Effects'
      object PageControlAudio: TPageControl
        Left = 0
        Top = 0
        Width = 592
        Height = 305
        ActivePage = tabEQ
        Align = alClient
        TabOrder = 0
        object tabEQ: TTabSheet
          Caption = 'Equalizer'
          object pnlAudioTop: TPanel
            Left = 0
            Top = 0
            Width = 584
            Height = 40
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object chkEnableEQ: TPlayerCheckBox
              Left = 16
              Top = 10
              Width = 60
              Height = 19
              Caption = 'Enable'
              TabOrder = 0
              OnClick = chkEnableEQClick
            end
            object chk2Pass: TPlayerCheckBox
              Left = 82
              Top = 10
              Width = 60
              Height = 19
              Caption = '2 Pass'
              TabOrder = 1
            end
            object lblPreset: TLabel
              Left = 150
              Top = 11
              Width = 35
              Height = 15
              Caption = 'Preset:'
            end
            object cboPresets: TComboBox
              Left = 192
              Top = 8
              Width = 240
              Height = 23
              Style = csDropDownList
              TabOrder = 2
              OnChange = cboPresetsChange
            end
            object btnResetEQ: TPlayerTextButton
              Left = 450
              Top = 7
              Width = 95
              Height = 26
              Caption = 'Reset to Flat'
              TabOrder = 3
              OnClick = btnResetEQClick
            end
          end
          object pnlBands: TPanel
            Left = 0
            Top = 40
            Width = 584
            Height = 237
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
        object lblPreamp: TLabel
          Left = 16
          Top = 210
          Width = 43
          Height = 15
          Caption = 'Preamp'
        end
        object lblPreampVal: TLabel
          Left = 20
          Top = 8
          Width = 24
          Height = 15
          Caption = '0 dB'
        end
        object lblBand0: TLabel
          Left = 85
          Top = 210
          Width = 28
          Height = 15
          Caption = '60Hz'
        end
        object lblBand1: TLabel
          Left = 135
          Top = 210
          Width = 35
          Height = 15
          Caption = '170Hz'
        end
        object lblBand2: TLabel
          Left = 185
          Top = 210
          Width = 35
          Height = 15
          Caption = '310Hz'
        end
        object lblBand3: TLabel
          Left = 235
          Top = 210
          Width = 35
          Height = 15
          Caption = '600Hz'
        end
        object lblBand4: TLabel
          Left = 290
          Top = 210
          Width = 23
          Height = 15
          Caption = '1kHz'
        end
        object lblBand5: TLabel
          Left = 340
          Top = 210
          Width = 23
          Height = 15
          Caption = '3kHz'
        end
        object lblBand6: TLabel
          Left = 390
          Top = 210
          Width = 23
          Height = 15
          Caption = '6kHz'
        end
        object lblBand7: TLabel
          Left = 440
          Top = 210
          Width = 29
          Height = 15
          Caption = '12kHz'
        end
        object lblBand8: TLabel
          Left = 490
          Top = 210
          Width = 29
          Height = 15
          Caption = '14kHz'
        end
        object lblBand9: TLabel
          Left = 540
          Top = 210
          Width = 29
          Height = 15
          Caption = '16kHz'
        end
        object tbPreamp: TPlayerSlider
          Left = 20
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 0
          OnChange = tbPreampChange
        end
        object tbBand0: TPlayerSlider
          Tag = 0
          Left = 82
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 1
          OnChange = tbBandChange
        end
        object tbBand1: TPlayerSlider
          Tag = 1
          Left = 132
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 2
          OnChange = tbBandChange
        end
        object tbBand2: TPlayerSlider
          Tag = 2
          Left = 182
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 3
          OnChange = tbBandChange
        end
        object tbBand3: TPlayerSlider
          Tag = 3
          Left = 232
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 4
          OnChange = tbBandChange
        end
        object tbBand4: TPlayerSlider
          Tag = 4
          Left = 282
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 5
          OnChange = tbBandChange
        end
        object tbBand5: TPlayerSlider
          Tag = 5
          Left = 332
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 6
          OnChange = tbBandChange
        end
        object tbBand6: TPlayerSlider
          Tag = 6
          Left = 382
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 7
          OnChange = tbBandChange
        end
        object tbBand7: TPlayerSlider
          Tag = 7
          Left = 432
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 8
          OnChange = tbBandChange
        end
        object tbBand8: TPlayerSlider
          Tag = 8
          Left = 482
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 9
          OnChange = tbBandChange
        end
        object tbBand9: TPlayerSlider
          Tag = 9
          Left = 532
          Top = 28
          Width = 35
          Height = 180
          Max = 20
          Min = -20
          Orientation = psoVertical
          TabOrder = 10
          OnChange = tbBandChange
        end
      end
    end
    object tabCompressor: TTabSheet
      Caption = 'Compressor'
      ImageIndex = 1
      object chkEnableCompressor: TPlayerCheckBox
        Left = 20
        Top = 15
        Width = 260
        Height = 20
        Caption = 'Enable dynamic range compressor'
        TabOrder = 0
      end
    end
    object tabSpatializer: TTabSheet
      Caption = 'Spatializer'
      ImageIndex = 2
      object chkEnableSpatializer: TPlayerCheckBox
        Left = 20
        Top = 15
        Width = 200
        Height = 20
        Caption = 'Enable Spatializer'
        TabOrder = 0
      end
    end
    object tabStereoWidener: TTabSheet
      Caption = 'Stereo Widener'
      ImageIndex = 3
      object chkEnableWidener: TPlayerCheckBox
        Left = 20
        Top = 15
        Width = 200
        Height = 20
        Caption = 'Enable Stereo Widener'
        TabOrder = 0
      end
    end
  end
end
    object tabVideo: TTabSheet
      Caption = 'Video Effects'
      object pnlVideoAdjust: TPanel
        Left = 0
        Top = 0
        Width = 592
        Height = 305
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object chkEnableAdjust: TPlayerCheckBox
          Left = 20
          Top = 15
          Width = 160
          Height = 20
          Caption = 'Image Adjust'
          TabOrder = 0
          OnClick = chkEnableAdjustClick
        end
        object lblContrast: TLabel
          Left = 40
          Top = 55
          Width = 47
          Height = 15
          Caption = 'Contrast:'
        end
        object lblContrastVal: TLabel
          Left = 440
          Top = 55
          Width = 23
          Height = 15
          Caption = '1.00'
        end
        object tbContrast: TPlayerSlider
          Left = 120
          Top = 50
          Width = 300
          Height = 30
          Max = 200
          Position = 100
          TabOrder = 1
          OnChange = tbVideoAdjustChange
        end
        object lblBrightness: TLabel
          Left = 40
          Top = 95
          Width = 58
          Height = 15
          Caption = 'Brightness:'
        end
        object lblBrightnessVal: TLabel
          Left = 440
          Top = 95
          Width = 23
          Height = 15
          Caption = '1.00'
        end
        object tbBrightness: TPlayerSlider
          Left = 120
          Top = 90
          Width = 300
          Height = 30
          Max = 200
          Position = 100
          TabOrder = 2
          OnChange = tbVideoAdjustChange
        end
        object lblHue: TLabel
          Left = 40
          Top = 135
          Width = 25
          Height = 15
          Caption = 'Hue:'
        end
        object lblHueVal: TLabel
          Left = 440
          Top = 135
          Width = 30
          Height = 15
          Caption = '0 deg'
        end
        object tbHue: TPlayerSlider
          Left = 120
          Top = 130
          Width = 300
          Height = 30
          Max = 180
          Min = -180
          Position = 0
          TabOrder = 3
          OnChange = tbVideoAdjustChange
        end
        object lblSaturation: TLabel
          Left = 40
          Top = 175
          Width = 57
          Height = 15
          Caption = 'Saturation:'
        end
        object lblSaturationVal: TLabel
          Left = 440
          Top = 175
          Width = 23
          Height = 15
          Caption = '1.00'
        end
        object tbSaturation: TPlayerSlider
          Left = 120
          Top = 170
          Width = 300
          Height = 30
          Max = 300
          Position = 100
          TabOrder = 4
          OnChange = tbVideoAdjustChange
        end
        object lblGamma: TLabel
          Left = 40
          Top = 215
          Width = 44
          Height = 15
          Caption = 'Gamma:'
        end
        object lblGammaVal: TLabel
          Left = 440
          Top = 215
          Width = 23
          Height = 15
          Caption = '1.00'
        end
        object tbGamma: TPlayerSlider
          Left = 120
          Top = 210
          Width = 300
          Height = 30
          Max = 1000
          Position = 100
          TabOrder = 5
          OnChange = tbVideoAdjustChange
        end
        object btnResetVideo: TPlayerTextButton
          Left = 120
          Top = 260
          Width = 120
          Height = 28
          Caption = 'Reset Defaults'
          TabOrder = 6
          OnClick = btnResetVideoClick
        end
      end
    end
    object tabSync: TTabSheet
      Caption = 'Synchronization'
      object pnlSync: TPanel
        Left = 0
        Top = 0
        Width = 592
        Height = 305
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object grpAudioSync: TModernCardPanel
          Left = 20
          Top = 20
          Width = 550
          Height = 120
          object lblAudioSyncTitle: TLabel
            Left = 16
            Top = 12
            Caption = 'Audio / Video Synchronization'
          end
          object lblAudioDelay: TLabel
            Left = 20
            Top = 35
            Width = 144
            Height = 15
            Caption = 'Audio Desynchronization:'
          end
          object lblAudioDelayVal: TLabel
            Left = 460
            Top = 35
            Width = 27
            Height = 15
            Caption = '0 ms'
          end
          object tbAudioDelay: TPlayerSlider
            Left = 20
            Top = 60
            Width = 380
            Height = 30
            Max = 5000
            Min = -5000
            Position = 0
            TabOrder = 0
            OnChange = tbAudioDelayChange
          end
          object btnAudioDelayMinus: TPlayerTextButton
            Left = 415
            Top = 60
            Width = 45
            Height = 26
            Caption = '-50ms'
            TabOrder = 1
            OnClick = btnAudioDelayMinusClick
          end
          object btnAudioDelayPlus: TPlayerTextButton
            Left = 465
            Top = 60
            Width = 45
            Height = 26
            Caption = '+50ms'
            TabOrder = 2
            OnClick = btnAudioDelayPlusClick
          end
        end
        object grpSubSync: TModernCardPanel
          Left = 20
          Top = 155
          Width = 550
          Height = 120
          object lblSubSyncTitle: TLabel
            Left = 16
            Top = 12
            Caption = 'Subtitle Synchronization'
          end
          object lblSubDelay: TLabel
            Left = 20
            Top = 35
            Width = 148
            Height = 15
            Caption = 'Subtitle Track Sync Delay:'
          end
          object lblSubDelayVal: TLabel
            Left = 460
            Top = 35
            Width = 27
            Height = 15
            Caption = '0 ms'
          end
          object tbSubDelay: TPlayerSlider
            Left = 20
            Top = 60
            Width = 380
            Height = 30
            Max = 5000
            Min = -5000
            Position = 0
            TabOrder = 0
            OnChange = tbSubDelayChange
          end
          object btnSubDelayMinus: TPlayerTextButton
            Left = 415
            Top = 60
            Width = 45
            Height = 26
            Caption = '-50ms'
            TabOrder = 1
            OnClick = btnSubDelayMinusClick
          end
          object btnSubDelayPlus: TPlayerTextButton
            Left = 465
            Top = 60
            Width = 45
            Height = 26
            Caption = '+50ms'
            TabOrder = 2
            OnClick = btnSubDelayPlusClick
          end
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 335
    Width = 600
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnSave: TPlayerTextButton
      Left = 390
      Top = 8
      Width = 90
      Height = 28
      Caption = 'Apply'
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnClose: TPlayerTextButton
      Left = 490
      Top = 8
      Width = 90
      Height = 28
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
end
