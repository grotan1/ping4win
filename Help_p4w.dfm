object HelpForm: THelpForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 288
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sPanel1: TPanel
    Left = 0
    Top = 0
    Width = 353
    Height = 288
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    Caption = 'sPanel1'
    TabOrder = 0
    object sLabel4: TLabel
      Left = 117
      Top = 235
      Width = 119
      Height = 14
      Cursor = crHandPoint
      Caption = 'Http://klingsundet.no'
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnClick = sLabel4Click
    end
    object sLabel3: TLabel
      Left = 75
      Top = 215
      Width = 203
      Height = 14
      Caption = 'Copyright (c) 2018 Geir Rune Gr'#248'tan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object sLabel2: TLabel
      Left = 136
      Top = 48
      Width = 81
      Height = 19
      Caption = 'Version 2.1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object sLabel1: TLabel
      Left = 116
      Top = 8
      Width = 120
      Height = 35
      Caption = 'Ping4Win'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object sButton1: TButton
      Left = 139
      Top = 255
      Width = 75
      Height = 25
      Caption = 'Close'
      ModalResult = 1
      TabOrder = 0
    end
    object sRichEdit1: TRichEdit
      Left = 8
      Top = 73
      Width = 337
      Height = 136
      TabStop = False
      Color = 16645629
      Font.Charset = ANSI_CHARSET
      Font.Color = 4473924
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'sRichEdit1')
      ParentFont = False
      TabOrder = 1
      Zoom = 100
    end
  end
end
