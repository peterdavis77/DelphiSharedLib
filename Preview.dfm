object PreviewForm: TPreviewForm
  Left = 382
  Top = 102
  Width = 870
  Height = 500
  Caption = #25171#21360#39044#35272
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 854
    Height = 41
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 16
      Top = 8
      Width = 75
      Height = 25
      Caption = #25918#22823
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = #32553#23567
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 160
      Top = 8
      Width = 75
      Height = 25
      Caption = #25972#39029
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 280
      Top = 8
      Width = 75
      Height = 25
      Caption = #21069#19968#39029
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 352
      Top = 8
      Width = 75
      Height = 25
      Caption = #21518#19968#39029
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 480
      Top = 8
      Width = 75
      Height = 25
      Caption = #25171#21360
      TabOrder = 5
    end
    object Button7: TButton
      Left = 552
      Top = 8
      Width = 75
      Height = 25
      Caption = #36864#20986
      TabOrder = 6
      OnClick = Button7Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 443
    Width = 854
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 41
    Width = 854
    Height = 402
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 2
    object Panel2: TPanel
      Left = 320
      Top = 56
      Width = 185
      Height = 273
      BorderWidth = 1
      TabOrder = 0
      object Image1: TImage
        Left = 2
        Top = 2
        Width = 181
        Height = 269
        Align = alClient
        AutoSize = True
      end
    end
  end
end
