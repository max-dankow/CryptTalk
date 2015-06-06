unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm3 = class(TForm)
    edit2: TEdit;
    chk1: TCheckBox;
    StaticText1: TStaticText;
    btnOk: TButton;
    procedure edit2Change(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm3.edit2Change(Sender: TObject);
begin
  statictext1.Caption:=inttostr(length(edit2.Text));
  if  length(edit2.Text)<>24
  then  begin
        statictext1.Caption:=statictext1.Caption+'- длина ключа должна быть 24 символа';
        statictext1.Font.Color:=clred;
        end
  else  begin
        statictext1.Caption:=statictext1.Caption+'- OK';
        statictext1.Font.Color:=clgreen;
        end
end;

procedure TForm3.chk1Click(Sender: TObject);
begin
    if chk1.checked
    then  edit2.PasswordChar:=#0
    else edit2.PasswordChar:='*';
end;

procedure TForm3.btnOkClick(Sender: TObject);
begin
  statictext1.Caption:=inttostr(length(edit2.Text));
  if  length(edit2.Text)<>24
  then  begin
        statictext1.Caption:=statictext1.Caption+'- длина ключа должна быть 24 символа';
        statictext1.Font.Color:=clred;
        end
  else  begin
        statictext1.Caption:=statictext1.Caption+'- OK';
        statictext1.Font.Color:=clgreen;
        form1.password:=edit2.Text;
        form3.close;
        end
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Enabled:=true;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  edit2.Text:=form1.PassWord;
end;

end.
