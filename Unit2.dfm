object Form2: TForm2
  Left = 638
  Top = 74
  Width = 208
  Height = 225
  Caption = 'Form2'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object seFreq: TSpinEdit
    Left = 104
    Top = 16
    Width = 73
    Height = 22
    Increment = 1000
    MaxValue = 48000
    MinValue = 8000
    TabOrder = 0
    Value = 8000
  end
  object se1: TSpinEdit
    Left = 104
    Top = 80
    Width = 73
    Height = 22
    MaxValue = 2
    MinValue = 1
    TabOrder = 1
    Value = 1
  end
  object txt1: TStaticText
    Left = 16
    Top = 20
    Width = 46
    Height = 17
    Caption = #1063#1072#1089#1090#1086#1090#1072
    TabOrder = 2
  end
  object txt2: TStaticText
    Left = 16
    Top = 52
    Width = 46
    Height = 17
    Caption = #1043#1083#1091#1073#1080#1085#1072
    TabOrder = 3
  end
  object txt3: TStaticText
    Left = 17
    Top = 83
    Width = 43
    Height = 17
    Caption = #1050#1072#1085#1072#1083#1099
    TabOrder = 4
  end
  object btn1: TButton
    Left = 16
    Top = 152
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 5
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 104
    Top = 152
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 6
    OnClick = btn2Click
  end
  object SpinEdit1: TSpinEdit
    Left = 104
    Top = 112
    Width = 73
    Height = 22
    Increment = 1000
    MaxValue = 24000
    MinValue = 1000
    TabOrder = 7
    Value = 1000
  end
  object StaticText1: TStaticText
    Left = 17
    Top = 114
    Width = 80
    Height = 17
    Caption = #1056#1072#1079#1084#1077#1088' '#1073#1091#1092#1077#1088#1072
    TabOrder = 8
  end
  object se2: TSpinEdit
    Left = 104
    Top = 48
    Width = 73
    Height = 22
    Increment = 8
    MaxValue = 16
    MinValue = 8
    TabOrder = 9
    Value = 8
  end
end
