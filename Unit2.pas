unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TForm2 = class(TForm)
    seFreq: TSpinEdit;
    se1: TSpinEdit;
    txt1: TStaticText;
    txt2: TStaticText;
    txt3: TStaticText;
    btn1: TButton;
    btn2: TButton;
    SpinEdit1: TSpinEdit;
    StaticText1: TStaticText;
    se2: TSpinEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
implementation

uses Unit1;

{$R *.dfm}


procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
form1.enabled:=True;
end;

procedure TForm2.btn2Click(Sender: TObject);
begin
Form2.Close;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
seFreq.Value:=Form1.nFreq;
se1.Value:=form1.nchanels;
se2.Value:=form1.nBPS;
spinedit1.Value:=form1.nbuf;
end;

procedure TForm2.btn1Click(Sender: TObject);
begin
Form1.nFreq:=seFreq.Value;
form1.nchanels:=se1.Value;
form1.nBPS:=se2.Value;
form1.nbuf:=spinedit1.Value;
form1.btn6Click(@Self);
form2.close;
end;

end.
