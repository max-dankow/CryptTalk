object Form3: TForm3
  Left = 556
  Top = 89
  Width = 479
  Height = 150
  BorderIcons = []
  Caption = 'Form3'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object edit2: TEdit
    Left = 3
    Top = 37
    Width = 297
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    OnChange = edit2Change
  end
  object chk1: TCheckBox
    Left = 11
    Top = 73
    Width = 129
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1082#1083#1102#1095
    TabOrder = 1
    OnClick = chk1Click
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 7
    Width = 32
    Height = 17
    Caption = #1050#1083#1102#1095
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 320
    Top = 40
    Width = 113
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 3
    OnClick = btnOkClick
  end
end
