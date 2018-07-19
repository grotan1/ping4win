object OptionsForm: TOptionsForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 505
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 214
    Width = 55
    Height = 13
    Caption = 'Test Status'
  end
  object FromEdit: TLabeledEdit
    Left = 8
    Top = 24
    Width = 185
    Height = 21
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'From Address'
    TabOrder = 0
  end
  object ToEdit: TLabeledEdit
    Left = 8
    Top = 67
    Width = 185
    Height = 21
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'To Address'
    TabOrder = 1
  end
  object SMTPEdit: TLabeledEdit
    Left = 8
    Top = 112
    Width = 185
    Height = 21
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'SMTP Server'
    TabOrder = 2
  end
  object Button1: TButton
    Left = 8
    Top = 472
    Width = 75
    Height = 25
    Caption = 'Save'
    ModalResult = 1
    TabOrder = 9
  end
  object AuthenticationCheck: TCheckBox
    Left = 226
    Top = 31
    Width = 129
    Height = 17
    Caption = 'Require authentication'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object UsernameEdit: TLabeledEdit
    Left = 242
    Top = 67
    Width = 161
    Height = 21
    EditLabel.Width = 48
    EditLabel.Height = 13
    EditLabel.Caption = 'Username'
    TabOrder = 6
  end
  object PasswordEdit: TLabeledEdit
    Left = 242
    Top = 112
    Width = 161
    Height = 21
    EditLabel.Width = 46
    EditLabel.Height = 13
    EditLabel.Caption = 'Password'
    PasswordChar = '*'
    TabOrder = 7
  end
  object TLSCheck: TCheckBox
    Left = 226
    Top = 8
    Width = 59
    Height = 17
    Caption = 'Use TLS'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object TestButton: TButton
    Left = 8
    Top = 183
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 8
    OnClick = TestButtonClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 233
    Width = 395
    Height = 233
    TabStop = False
    ScrollBars = ssVertical
    TabOrder = 11
  end
  object PortEdit: TLabeledEdit
    Left = 8
    Top = 156
    Width = 75
    Height = 21
    EditLabel.Width = 20
    EditLabel.Height = 13
    EditLabel.Caption = 'Port'
    NumbersOnly = True
    TabOrder = 3
    Text = '587'
  end
  object Button2: TButton
    Left = 89
    Top = 472
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 10
  end
  object IdSMTP1: TIdSMTP
    OnStatus = IdSMTP1Status
    IOHandler = IdSSLIOHandlerSocketOpenSSL1
    SASLMechanisms = <>
    Left = 312
    Top = 328
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    OnStatus = IdSSLIOHandlerSocketOpenSSL1Status
    Destination = ':25'
    MaxLineAction = maException
    Port = 25
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    OnStatusInfo = IdSSLIOHandlerSocketOpenSSL1StatusInfo
    OnStatusInfoEx = IdSSLIOHandlerSocketOpenSSL1StatusInfoEx
    Left = 176
    Top = 408
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CharSet = 'utf-8'
    CCList = <>
    ContentType = 'text/html'
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 56
    Top = 408
  end
  object NotificationCenter1: TNotificationCenter
    Left = 312
    Top = 408
  end
end
