{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdUDPServer, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient,mmsystem,Idsockethandle, ScktComp, winsock,des, ExtCtrls,
  ComCtrls, Spin, Gauges;
Const
TPS=2;
CwaveBufferCount = 16;
Cbufsize=11000;
bitsPERSimple=16;
sampPerSEC=22000;
type
  TModeDescr = record
    mode: DWORD; // код режима работы
    descr: string[32]; // словесное описание
  end;
  oneB=array[1..48000]of byte;
  TForm1 = class(TForm)
  IdUDPClient1: TIdUDPClient;
  Button1: TButton;
  Memo1: TMemo;
  IdUDPServer1: TIdUDPServer;
    ClientSocket1: TClientSocket;
    ServerSocket1: TServerSocket;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Button7: TButton;
    Label1: TLabel;
    Label2: TLabel;
    dlgOpen1: TOpenDialog;
    rb1: TRadioButton;
    rb2: TRadioButton;
    btn5: TButton;
    btn6: TButton;
    tmr1: TTimer;
    pause: TButton;
    filename: TLabel;
    pb1: TGauge;
    bChangePassword: TButton;
    SendP: TButton;
  procedure Button1Click(Sender: TObject);
  procedure playsound(s:Tstream);
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure FormCreate(Sender: TObject);
  procedure IdUDPServer1UDPRead(Sender: TObject; AData: TStream;
   ABinding: TIdSocketHandle);
    procedure ClientSocket1Lookup(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Connecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure btn1Click(Sender: TObject);
    procedure rg1Click(Sender: TObject);
    procedure rb2Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure tmr1Timer(Sender: TObject);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure pauseClick(Sender: TObject);
    procedure rb2DblClick(Sender: TObject);
    procedure rb1Click(Sender: TObject);
    procedure bChangePasswordClick(Sender: TObject);
    procedure SendPClick(Sender: TObject);
  private

  procedure OnWaveMessage(var msg:TMessage); message MM_WIM_DATA;
  private
{ Private declarations }
  public
  nFreq,nBPS,nChanels,nBuf:LongInt;
  fnFreq,fnBPS,fnChanels,fnBuf:LongInt;
  PassWord,FriendWord:string;
  WaveOut:HWAVEOUT;
  WaveHdrOut,WaveHdrOut2:TWaveHdr;
  WaveFormatOut:tWAVEFORMATEX;
  FBuffer:Pointer;
  FSndBuffer:Pointer;
  FHeaders:array[0..CWaveBufferCount-1] of TWAVEHDR;
  FBufSize:Cardinal;
{ Public declarations }

  Wavein:HWAVEIN;
  WaveHdr:TWaveHdr;
end;
var
  Form1: TForm1;
  myname,frname,SelectedFile:string;
  WaveDataLength,FileSize,TekPos:integer;
  bytes:integer;
  Punk:array[0..100000]of byte;
  SBlock:array[0..15]of oneb;
  device:word;
  bufsize:longint;
  waveformat: TWAVEFORMATEX;
  a,gi:integer;
  WaveOut: HWAVEOUT;
  WaveHdrOut,WaveHdrOut2: TWaveHdr;
  WaveFormatOut: tWAVEFORMATEX;
  WaveF:file;
  modes: array[1..12] of TModeDescr = ((mode: WAVE_FORMAT_1M08; descr:
    '11.025 kHz, mono, 8-bit'),
    (mode: WAVE_FORMAT_1M16; descr: '11.025 kHz, mono, 16-bit'),
    (mode: WAVE_FORMAT_1S08; descr: '11.025 kHz, stereo, 8-bit'),
    (mode: WAVE_FORMAT_1S16; descr: '11.025 kHz, stereo, 16-bit'),
    (mode: WAVE_FORMAT_2M08; descr: '22.05 kHz, mono, 8-bit'),
    (mode: WAVE_FORMAT_2M16; descr: '22.05 kHz, mono, 16-bit'),
    (mode: WAVE_FORMAT_2S08; descr: '22.05 kHz, stereo, 8-bit'),
    (mode: WAVE_FORMAT_2S16; descr: '22.05 kHz, stereo, 16-bit'),
    (mode: WAVE_FORMAT_4M08; descr: '44.1 kHz, mono, 8-bit'),
    (mode: WAVE_FORMAT_4M16; descr: '44.1 kHz, mono, 16-bit'),
    (mode: WAVE_FORMAT_4S08; descr: '44.1 kHz, stereo, 8-bit'),
    (mode: WAVE_FORMAT_4S16; descr: '44.1 kHz, stereo, 16-bit'));
implementation

uses Unit2, Unit3;

{$R *.dfm}

procedure ShowInfo;
var
  WaveNums, i, j: integer;
  WaveInCaps: TWaveInCaps;
begin
  WaveNums := waveInGetNumDevs;
  if WaveNums > 0 then
  begin
    for i := 0 to WaveNums - 1 do
    begin
      waveInGetDevCaps(i, @WaveInCaps, sizeof(TWaveInCaps));
      form1.memo1.Lines.Insert(0,PChar(@WaveInCaps.szPname));
      for j := 1 to High(modes) do
      begin
        if (modes[j].mode and WaveInCaps.dwFormats) = modes[j].mode then
        form1.memo1.Lines.Insert(0,modes[j].descr);
      end;
    end;
  end;
end;

procedure TForm1.playsound(s:Tstream);
var i:integer;
begin
While a<>CWaveBufferCount do Begin
If FHeaders[a].dwUser=0 then begin
s.Read(Fheaders[a].lpdata^,bufsize);
if FriendWord<>Password
then begin
       for i:=0 to bufsize do
       punk[i]:=random(255);
       Fheaders[a].lpdata:=addr(punk);
     end;
waveOutPrepareHeader(WaveOut,@FHeaders[a],sizeof(FHeaders));
waveOutWrite(WaveOut,@FHeaders[a],sizeof(FHeaders));
FHeaders[a].dwFlags:= 0;
With FHeaders[a] do begin
dwBufferLength:= bufsize;
dwBytesRecorded:= 0;
dwUser  := 0;
dwLoops:= 1;
dwFlags:= WHDR_INQUEUE
end;
inc(a);
exit;
end
end
end;

procedure InitWave(var Wave:TWAVEFORMATEX;freq,bitsperSEMPL,Channels:word);
begin
with wave do begin
nChannels:=Channels;
wFormatTag:=WAVE_FORMAT_PCM;
nSamplesPerSec:=freq;
wBitsPerSample:=bitsperSEMPL;
nBlockAlign:=nChannels*wBitsPerSample shr 3;
nAvgBytesPerSec:=nSamplesPerSec*nBlockAlign;
cbSize:=0;
end;
end;

procedure ErFile;
begin
 showmessage('Неправильный формат файла.');
 CloseFile(wavef);
 form1.tmr1.Enabled:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
type SoundProp=record
       c1,c2:char;
       freq,bps,chanels,bufsize:longint;
       end;
var SendProp:SoundProp;
 s:string;
 error:boolean;
a:longint;
c:char;
begin
If button1.Caption='Включить звук'
then Begin
if rb1.Checked
then begin
btn6.Click;
waveInPrepareHeader(waveIn,@WaveHdr,sizeof(Twavehdr));
waveInAddBuffer(wavein,@WaveHdr,sizeof(TwaveHdr));
idUDPClient1.Sendbuffer(WaveHdr.lpData^,WaveHdr.dwBufferLength);
waveInStart(waveIn);
end
else begin
          btn5.enabled:=false;
          filename.Visible:=true;
          pb1.Visible:=true;
          pb1.Progress:=0;
          error:=false;
       reset(waveF,1);

       setlength(s,4);
       blockread(wavef,s[1],4);
       if s<>'RIFF'
       then error:=true;

       blockread(wavef,s[1],4);

       blockread(wavef,s[1],4);
       if s<>'WAVE'
       then error:=true;

       blockread(wavef,s[1],4);
       if s<>'fmt '
       then error:=true;

       blockread(wavef,a,4);

       blockread(wavef,a,2);
       if a<>1
       then error:=true;

       blockread(wavef,fnChanels,2);
       blockread(wavef,fnFreq,4);
       blockread(wavef,fnBuf,4);
       fnbuf:=fnbuf div TPS;
       blockread(wavef,a,2);
       blockread(wavef,fnBPS,2);

       repeat
       blockread(wavef,c,1);
       until (c='d')or (eof(WaveF));
       setlength(s,3);
       blockread(wavef,s[1],3);
       s:=c+s;
       if s<>'data'
       then error:=true;
       if error
       then begin
          erfile;
          exit;
          end
       else begin
       blockread(wavef,filesize,4);
       tekPos:=filesize;
       tmr1.interval:=1000 div TPS -10;
       sendprop.c1:='#';
       sendprop.c2:='S';
       sendprop.freq:=fnfreq;
       sendprop.bps:=fnbps;
       sendprop.chanels:=fnChanels;
       sendprop.bufsize:=fnBuf;
       ClientSocket1.Socket.sendbuf(sendprop,sizeof(sendprop));
       pb1.Progress:=0;
       gi:=0;
       end;
       tmr1.Enabled:=true;
       pause.Visible:=true;
       pause.Enabled:=true;
       pause.Caption:='Пауза';
     end;
IdUDPClient1.host:=clientsocket1.Host;
IdUDPClient1.Port:=10090;
IdUDPClient1.Active:= true;
button1.Caption:='Отключить звук';
rb1.Enabled:=False;
rb2.Enabled:=False;
btn5.Enabled:=False;
end
 else Begin
button1.Caption:='Включить звук';
IdUDPClient1.Active:=false;
rb1.Enabled:=True;;
rb2.Enabled:=True;
btn5.Enabled:=true;
if rb1.Checked
then
begin
waveInUnprepareHeader(Wavein,@WaveHdr,sizeof(TwaveHdr));
waveInStop(Wavein);
end
else begin
         form1.btn6Click(@Self);
         tmr1.Enabled:=false;
         CloseFile(wavef);
         pb1.Visible:=false;
         pause.Visible:=false;
         filename.Visible:=false;
       pause.Enabled:=false;
     end;
end
end;

procedure TForm1.OnWaveMessage(var msg:TMessage);
var i:integer;
begin
waveInPrepareHeader(waveIn,@WaveHdr,sizeof(Twavehdr));
waveInAddBuffer(wavein,@WaveHdr,sizeof(TwaveHdr));
for i := 0 to ServerSocket1.Socket.ActiveConnections-1 do
{if form1.ServerSocket1.Socket.Connections[i].RemoteAddress='127.0.0.1'
then idUDPClient1.Sendbuffer(WaveHdr.lpData^,WaveHdr.dwBufferLength)
else idUDPServer1.sendbuffer(form1.ServerSocket1.Socket.Connections[i].RemoteAddress,4901,WaveHdr.lpData^,WaveHdr.dwBufferLength);}
idUDPClient1.Sendbuffer(WaveHdr.lpData^,WaveHdr.dwBufferLength);
UpDate
end;
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action:= caFree;
IdUDPClient1.Active:=false;
ClientSocket1.Active:=False;
ServerSocket1.Active:=False;
IdUDPServer1.Active:= False;
waveInClose(Wavein);
end;

function GetLocalIP: String;
const WSVer = $101;
var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: array [0..127] of Char;
begin
  Result := '';
  if WSAStartup(WSVer, wsaData) = 0 then begin
    if GetHostName(@Buf, 128) = 0 then begin
      P := GetHostByName(@Buf);
      if P <> nil then Result := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
    end;
    WSACleanup;
  end;
end;

procedure ReInitOut(var Wave:TWAVEFORMATEX;freq,bitsperSEMPL,Channels,bufsizeN:longint);
var a:integer;
begin
WaveOut:= 0;
InitWave(Wave,freq,bitsperSEMPL,Channels);
For a:= 0 to CWaveBufferCount-1 do
With Form1.FHeaders[a] do begin
dwFlags:= WHDR_INQUEUE;
dwBufferLength:= bufsizeN;
dwBytesRecorded:= 0;
dwUser:= 0;
dwLoops:= 1;
GetMem(Form1.Fheaders[a].lpData, bufsizeN);
end;
//Form1.IdUDPServer1.BufferSize:= bufsizen;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
for i:=0 to 100000 do
punk[i]:=random(255);
PassWord:='123456789012345678901234';
nFreq:=sampPerSEC;
nbuf:=Cbufsize;
nChanels:=1;
nBPS:=bitsPERSimple;
btn6.Visible:=false;

rb1.Checked:=True;

serverSocket1.Port := 4901;
serversocket1.open;

label1.Caption:=getlocalIP;

InitWave(WaveFormat,sampPerSEC,bitsPERSimple,1);

bufsize:= Cbufsize;
IdUDPClient1.BufferSize:=100000;
waveInOpen(@Wavein,WAVE_MAPPER,addr(waveformat),self.Handle,0,CALLBACK_WINDOW);
WaveHdr.lpData:=Pchar(GlobalAlloc(GMEM_FIXED, bufsize));
WaveHdr.dwBufferLength:=bufsize;
WaveHdr.dwFlags:=0;
IdUDPClient1.Port:= 10090;
ReInitOut(WaveFormatOut,sampPerSEC,bitsPERSimple,1,Cbufsize);

IdUDPServer1.DefaultPort:= 10090;
waveOutOpen(@WaveOut, WAVE_MAPPER, @WaveFormatOut, self.Handle, 0, CALLBACK_WINDOW);
IdUDPServer1.BufferSize:=100000;
//IdUDPserver1.Active:= true;
end;

procedure TForm1.IdUDPServer1UDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
begin
If a = CWaveBufferCount then
a:= 0;
playsound(Adata);
Bytes:=Bytes + aData.Size;
UpDate
end;

procedure TForm1.ClientSocket1Lookup(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  memo1.lines.Insert(0,'Поиск сервера...');
end;

procedure TForm1.ClientSocket1Connecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  memo1.lines.Insert(0,'Соединение...');
end;


procedure TForm1.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  memo1.lines.Insert(0,'Ошибка :'+inttostr(errorcode));
  ClientSocket1.close;
  button5.caption:='Подключиться';
  button7.Enabled:=false;
  button1.Enabled:=false;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  showinfo;
end;

procedure TForm1.Button5Click(Sender: TObject);
var value:string;
begin
  if button5.caption='Подключиться'
  then
  begin
  myname:='User';
  repeat
    if not InputQuery('Crypt Talk', 'Пожалуйста, укажите своё имя', MYname)
    then exit;
  until myname <> '';
  value:=label1.Caption;
  repeat
    if not InputQuery('Crypt Talk', 'Введите IP', value)
    then exit;
  until value <> '';
  label2.Caption:=myname;
  ClientSocket1.Host := value;
  ClientSocket1.Port := 4901;
  ClientSocket1.Open;
  IdUDPServer1.Active:=true;
  button5.caption:='Отключиться';
  button1.Enabled:=true;
  end
  else
  begin
       myname:='';
       label2.Caption:=myname;
       ClientSocket1.close;
       IdUDPServer1.Active:=false;
       memo1.lines.Insert(0,'Сессия закрыта.');
       button1.Enabled:=false;
       button5.caption:='Подключиться';
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if not ServerSocket1.active
  then
  begin
  serverSocket1.Port := 4901;
  serversocket1.open;
  memo1.lines.Insert(0,'Сервер запущен.');
  if not clientsocket1.active
  then begin
         ClientSocket1.Host := 'localhost';
         ClientSocket1.Port := 4901;
         ClientSocket1.Open;
         button5.caption:='Отключиться'
       end;
  end;
end;
procedure TForm1.Button7Click(Sender: TObject);
VAR S,k,f:string;
i:integer;
begin
  if (edit1.Text<>'')
    then begin
          memo1.Lines.Insert(0,myname+': '+edit1.text);
          s:=myname+': '+edit1.Text;
          k:=PassWord;
          Encrypt(s,f,k,triple);
          for i := 0 to ServerSocket1.Socket.ActiveConnections-1 do
          begin
          ServerSocket1.Socket.Connections[i].SendText('#T'+f);
          //showmessage(ServerSocket1.Socket.Connections[i].RemoteAddress);
          end;
          //ClientSocket1.Socket.Sendtext('#T'+f);
          edit1.Text:='';
          end;
end;

procedure TForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   memo1.Lines.Insert(0,frname+' отключился.');
   frname:='';
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN)and(button7.Enabled)
  then Button7.Click;
  if (key=vk_delete)and(ssshift in shift)and(ssctrl in shift)
  then memo1.Clear;
end;

procedure TForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
type SoundProp=record
       c1,c2:char;
       freq,bps,chanels,bufsize:longint;
       end;
    rSoundProp=record
       freq,bps,chanels,bufsize:longint;
       end;
var SendProp:SoundProp;
  p:^SoundProp;
  s,k,f,stat:string;
  resProp:rSoundProp;
  p1:^rSoundProp;
begin
  s:=socket.ReceiveText;
  stat:=copy(s,1,2);
  delete(s,1,2);
  if Stat='#P'
  then begin
        friendWord:=s;
        exit;
       end;
  if stat='#S'
  then begin
         s:=copy(s,3,16);
         p1:=@s[1];
         resprop:=p1^;
         ReInitOut(WaveFormatOut,resprop.freq,resprop.bps,resprop.chanels,resprop.bufsize);
         bufsize:=resprop.bufsize;
         waveOutOpen(@WaveOut, WAVE_MAPPER, @WaveFormatOut, self.Handle, 0, CALLBACK_WINDOW);
         exit;
       end;
  if stat='#E'
  then
  begin
    memo1.Lines.Insert(0,s+' подключился.');
    if rb1.Checked
    then begin
    frname:=s;
    sendprop.c1:='#';
    sendprop.c2:='S';
    sendprop.freq:=nfreq;
    sendprop.bps:=nbps;
    sendprop.chanels:=nChanels;
    sendprop.bufsize:=nBuf;
    ClientSocket1.Socket.sendbuf(sendprop,sizeof(sendprop));
    end
    else begin
    frname:=s;
    sendprop.c1:='#';
    sendprop.c2:='S';
    sendprop.freq:=fnfreq;
    sendprop.bps:=fnbps;
    sendprop.chanels:=fnChanels;
    sendprop.bufsize:=fnBuf;
    ClientSocket1.Socket.sendbuf(sendprop,sizeof(sendprop));
         end;
    exit;
  end;
  k:=PassWord;
  decrypt(s,f,k,triple);
  memo1.Lines.Insert(0,f);
end;


procedure TForm1.btn1Click(Sender: TObject);
begin
  ReInitOut(WaveFormatOut,sampPerSEC div 2,bitsPERSimple,1,Cbufsize);
  waveOutOpen(@WaveOut, WAVE_MAPPER, @WaveFormatOut, self.Handle, 0, CALLBACK_WINDOW);
end;

procedure TForm1.rg1Click(Sender: TObject);
begin
         if dlgOpen1.Execute
         then ShowMessage('File : '+dlgopen1.FileName)
         else ShowMessage('Открытие файла остановлено.');
end;

procedure TForm1.rb2Click(Sender: TObject);
type SoundProp=record
       freq,bps,chanels,bufsize:longint;
       end;
var SendProp:SoundProp;
 s:string;
 error:boolean;
a:longint;
c:char;
begin
  if dlgOpen1.Execute
  then begin
          SelectedFile:=dlgOpen1.FileName;
          a:=length(dlgOpen1.FileName);
          while dlgOpen1.FileName[a]<>'\' do
          dec(a);
          AssignFile(WaveF,dlgOpen1.FileName);
          if (length(dlgOpen1.FileName)-a)<=22
          then filename.Caption:=copy(dlgopen1.FileName,a+1,length(dlgOpen1.FileName)-a)
          else filename.Caption:=copy(dlgopen1.FileName,a+1,22)+'...'
       end
  else begin
          ShowMessage('Открытие файла остановлено.');
          rb1.Checked:=True;
          rb2.Checked:=False;
          btn5.enabled:=true;
       end;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
InitWave(WaveFormat,sampPerSEC div 2,bitsPERSimple,1);

bufsize:= Cbufsize;
IdUDPClient1.BufferSize:=bufsize;
waveInOpen(@Wavein,WAVE_MAPPER,addr(waveformat),self.Handle,0,CALLBACK_WINDOW);
WaveHdr.lpData:=Pchar(GlobalAlloc(GMEM_FIXED, bufsize));
WaveHdr.dwBufferLength:=bufsize;
WaveHdr.dwFlags:=0;
end;

procedure TForm1.btn3Click(Sender: TObject);
begin
ReInitOut(WaveFormatOut,sampPerSEC,bitsPERSimple,1,Cbufsize);
  waveOutOpen(@WaveOut, WAVE_MAPPER, @WaveFormatOut, self.Handle, 0, CALLBACK_WINDOW);
end;

procedure TForm1.btn4Click(Sender: TObject);
begin
InitWave(WaveFormat,sampPerSEC,bitsPERSimple,1);
bufsize:= Cbufsize;
IdUDPClient1.BufferSize:=bufsize;
waveInOpen(@Wavein,WAVE_MAPPER,addr(waveformat),self.Handle,0,CALLBACK_WINDOW);
WaveHdr.lpData:=Pchar(GlobalAlloc(GMEM_FIXED, bufsize));
WaveHdr.dwBufferLength:=bufsize;
WaveHdr.dwFlags:=0;
end;

procedure TForm1.btn5Click(Sender: TObject);
begin
Form2:= TForm2.Create(Application);
Form2.Caption:= 'Настройка';
form2.Show;
Form1.Enabled:=False;
end;

procedure TForm1.btn6Click(Sender: TObject);
type SoundProp=record
       c1,c2:char;
       freq,bps,chanels,bufsize:longint;
       end;
var SendProp:SoundProp;
begin
sendprop.c1:='#';
sendprop.c2:='S';
sendprop.freq:=nfreq;
sendprop.bps:=nbps;
sendprop.chanels:=nChanels;
sendprop.bufsize:=nBuf;
ClientSocket1.Socket.sendbuf(sendprop,sizeof(sendprop));
InitWave(WaveFormat,nFreq,nBPS,nChanels);
//IdUDPClient1.BufferSize:=nbuf;
waveInOpen(@Wavein,WAVE_MAPPER,addr(waveformat),self.Handle,0,CALLBACK_WINDOW);
WaveHdr.lpData:=Pchar(GlobalAlloc(GMEM_FIXED, nBuf));
WaveHdr.dwBufferLength:=nBuf;
WaveHdr.dwFlags:=0;
end;

procedure TForm1.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
type SoundProp=record
       freq,bps,chanels,bufsize:longint;
       end;
var SendProp:SoundProp;
  p:^SoundProp;
  s,k,f,stat:string;
  resProp:SoundProp;
begin
  s:=socket.ReceiveText;
  stat:=copy(s,1,2);
  delete(s,1,2);
  if Stat='#P'
  then begin
        friendWord:=s;
        exit;
       end;
  if stat = '#Y'
  then
  begin
       button7.Enabled:=true;
       button1.Enabled:=true;
       memo1.Lines.Insert(0,'Подключено');
       ClientSocket1.Socket.Sendtext('#E'+myname);
       Sendp.Click;
       exit;
  end;
  if stat = '#N'
  then
  begin
       ClientSocket1.close;
       memo1.lines.Insert(0,'Сессия закрыта');
       button5.caption:='Подключиться';
       button7.Enabled:=false;
       button1.Enabled:=false;
       memo1.Lines.Insert(0,'Сервер занят');
       exit;
  end;
  if stat='#S'
  then begin
         p:=@s[1];
         resprop:=p^;
         ReInitOut(WaveFormatOut,resprop.freq,resprop.bps,resprop.chanels,resprop.bufsize);
         bufsize:=resprop.bufsize;
         waveOutOpen(@WaveOut, WAVE_MAPPER, @WaveFormatOut, self.Handle, 0, CALLBACK_WINDOW);
         exit;
       end;
  if stat='#E'
  then
  begin
    memo1.Lines.Insert(0,s+' подключился.');
    frname:=s;
    sendprop.freq:=nfreq;
    sendprop.bps:=nbps;
    sendprop.chanels:=nChanels;
    sendprop.bufsize:=nBuf;
    ClientSocket1.Socket.Sendtext('#S');
    ClientSocket1.Socket.sendbuf(sendprop,sizeof(sendprop));
    exit;
  end;
  k:=PassWord;
  decrypt(s,f,k,triple);
  memo1.Lines.Insert(0,f);
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var i:integer;
begin
  if tekpos>=fnbuf
  then begin
        blockRead(waveF,Sblock[gi],fnbuf);
        pb1.Progress:=100-(tekpos*100 div filesize);
        tekpos:=tekpos-fnbuf
       end
  else begin
      blockRead(waveF,Sblock[gi],tekpos);
      for i:= tekpos to fnbuf do
      sBlock[gi][i]:=0;
      tekpos:=0;
      pb1.Progress:=100;
      form1.btn6Click(@Self);
      pb1.Visible:=false;
      Form1.button1.Click;
      end;
  idUDPClient1.Sendbuffer(SBlock[gi],fnbuf);
  gi:=(gi+1) mod 16;
end;

procedure TForm1.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if serversocket1.socket.activeconnections>1
  then ServerSocket1.Socket.Connections[1].SendText('#N')
  else begin
          ServerSocket1.Socket.Connections[0].SendText('#Y');
          sendP.click;
       end;
end;

procedure TForm1.pauseClick(Sender: TObject);
begin
  if pause.Caption='Пауза'
  then begin
         pause.Caption:='Продолжить';
         tmr1.Enabled:=false;
       end
  else begin
         pause.Caption:='Пауза';
         tmr1.Enabled:=true;
       end;
end;

procedure TForm1.rb2DblClick(Sender: TObject);
type SoundProp=record
       freq,bps,chanels,bufsize:longint;
       end;
var SendProp:SoundProp;
 s:string;
 error:boolean;
a:longint;
c:char;
begin
  if dlgOpen1.Execute
  then begin
          SelectedFile:=dlgOpen1.FileName;
          a:=length(dlgOpen1.FileName);
          while dlgOpen1.FileName[a]<>'\' do
          dec(a);
          AssignFile(WaveF,dlgOpen1.FileName);
          if (length(dlgOpen1.FileName)-a)<=22
          then filename.Caption:=copy(dlgopen1.FileName,a+1,length(dlgOpen1.FileName)-a)
          else filename.Caption:=copy(dlgopen1.FileName,a+1,22)+'...'
       end
  else begin
          ShowMessage('Открытие файла остановлено.');
          rb1.Checked:=True;
          rb2.Checked:=False;
          btn5.enabled:=true;
       end;
end;

procedure TForm1.rb1Click(Sender: TObject);
begin
  filename.Caption:='';
end;


procedure TForm1.bChangePasswordClick(Sender: TObject);
begin
Form3:= TForm3.Create(Application);
Form3.Caption:= 'Изменения пароля';
form3.Show;
Form1.Enabled:=False;
end;

procedure TForm1.SendPClick(Sender: TObject);
var i:integer;
begin                                                             
  for i := 0 to ServerSocket1.Socket.ActiveConnections-1 do
  ServerSocket1.Socket.Connections[i].SendText('#P'+password);
end;

end.
