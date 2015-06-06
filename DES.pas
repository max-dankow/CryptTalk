unit DES;

interface
const ecb=10;
      cbc=11;
      cfb=12;
      ofb=13;
      triple=2;
      double=1;
      single=0;
type
  _bit=array of boolean;
  conkey=record
         c,d:_bit;
          end;
  tbb=array [1..8] of _bit;
  tkeys=array[1..16] of _bit;
  pBuf=^tbuf;
  tBuf=array[1..8] of byte;
var error:string;
    GlobalKeys:tKeys;
procedure Encrypt(var s,f,key:string;reg:integer);
procedure Decrypt(var s,f,key:string;reg:integer);
procedure DESencrypt(s:string;var allkeys:tkeys;var f:string);
procedure DESdecrypt(s:string;var allkeys:tkeys;var f:string);
procedure DecryptSound(var s,f,key:string;reg:integer);
procedure EncryptSound(var s,f,key:string;reg:integer);
procedure BufToBin(p:pBuf;len:integer;var f:_bit);

implementation

procedure StrToBin(s:string;var f:_bit);
var i,j,x:integer;
begin
  for I := 1 to length(s) do
    begin
      x:=ord(s[i]);
      j:=i*8-8;
      repeat
        f[j]:=x mod 2=1;
        x:=x div 2;
        inc(j);
      until x=0;
    end;
end;

procedure BufToBin(p:pBuf;len:integer;var f:_bit);
var x,i,j:integer;
begin
  for I := 1 to len do
    begin
      x:=p^[i];
      j:=i*8-8;
      repeat
        f[j]:=x mod 2=1;
        x:=x div 2;
        inc(j);
      until x=0;
    end;
end;

procedure BinToBuf(s:_bit;p:pBuf;n:integer);
var i,j,x,y:integer;
begin
  for i := 1 to (n div 8) do
    begin
      x:=0;
      for j := 7 downto 0 do
        begin
          y:=i*8+j;
          if s[y]
          then x:=x*2+1
          else x:=x*2;
        end;
        p^[1]:=x;
    end;
end;

procedure BinToStr(s:_bit;var f:string;n:integer);
var i,j,x,y:integer;
begin
  f:='';
  for i := 0 to (n div 8)-1 do
    begin
      x:=0;
      for j := 7 downto 0 do
        begin
          y:=i*8+j;
          if s[y]
          then x:=x*2+1
          else x:=x*2;
        end;
      f:=f+chr(x);
    end;
end;

procedure ip(var S,F:_bit);
const  _IP:array[0..63] of byte =(58,50,42,34,26,18
  ,10,2,60,52,44,36,28,20,12,4,62,54,46,38,30,22,14,
  6,64,56,48,40,32,24,16,8,57,49,41,33,25,17,9,1,59,
  51,43,35,27,19,11,3,61,53,45,37,29,21,13,5,63,55,
  47,39,31,23,15,7);
var i:integer;
begin
  setlength(f,64);
  for i:= 0 to 63 do
  f[i]:=s[_IP[i]-1];
end;

procedure de_ip(var S,F:_bit);
const  _IP:array[0..63] of byte =(58,50,42,34,26,18
  ,10,2,60,52,44,36,28,20,12,4,62,54,46,38,30,22,14,
  6,64,56,48,40,32,24,16,8,57,49,41,33,25,17,9,1,59,
  51,43,35,27,19,11,3,61,53,45,37,29,21,13,5,63,55,
  47,39,31,23,15,7);
  _deIP:array[0..63] of byte=(
  40	,8,	48,	16 ,	56,	24,	64,	32,	39,	7,	47,	15,	55,	23,	63,	31,
38,	6	,46	,14,	54,	22,	62,	30,	37,	5,	45,	13,	53,	21,	61,	29,
36,	4,	44,	12,	52,	20,	60,	28,	35,	3,	43,	11,	51,	19,	59,	27,
34,	2,	42,	10,	50,	18,	58,	26,	33,	1,	41,	9,	49,	17,	57,	25
);
var i:integer;
begin
  setlength(f,64);
  for i:= 0 to 63 do
  f[i]:=s[_deip[i]-1];
end;

procedure copybit(var s,f:_bit;start,n:integer);
var i:integer;
begin
  for I := start-1 to n - 1 do
    f[i-start+1]:=s[i];
end;

function xorbin(var s1,s2:_bit;n:integer):_bit;
var i:integer;
  temp:_bit;
begin
  setlength(temp,n);
  for I := 0 to n - 1 do
    temp[i]:=s1[i] xor s2[i];
  xorbin:=temp;
end;

procedure getC0D0(var s:_bit;var f:conkey);
const _C0:array[0..27] of byte =(57,49,41,33,25,17,
      9,1,58,50,42,34,26,18,10,2,59,51,43,35,27,19,11,3,
      60,52,44,36);

      _D0:array[0..27] of byte =(63,55,47,39,31,23,
      15,7,62,54,46,38,30,22,14,6,61,53,45,37,29,21,
      13,5,28,20,12,4);
var i:integer;
begin
     for I := 0 to 27 do
       begin
         f.c[i]:=s[_c0[i]-1];
         f.d[i]:=s[_d0[i]-1];
       end;
end;

function ShlBit(var s:_bit;n:integer):_bit;
var i:integer;
  temp:boolean;
  tbit:_bit;
begin
  temp:=s[n-1];
  setlength(tbit,28);
  for I := n-1 downto 1 do
    begin
      tbit[i]:=s[i-1];
    end;
  s[0]:=temp;
  shlbit:=tbit;
end;

procedure getConKey(var s:conkey;var f:_bit;n:integer);
const  _shl:array[1..16] of byte =(1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1);
       P:array[0..47] of byte =(14,17,11,24,1,5,3,28,15,6,21,10,23,19,12,4,
       26,8,16,7,27,20,13,2,41,52,31,37,47,55,30,40,
       51,45,33,48,44,49,39,56,34,53,46,42,50,36,29,32);
var i:integer;
  temp:_bit;
begin
  setlength(temp,56);
  for i := 1 to _shl[n] do
    begin
      s.c:=shlbit(s.c,28);
      s.d:=shlbit(s.d,28);
    end;
  for I := 0 to 27 do
    begin
      temp[i]:=s.d[i];
      temp[i+28]:=s.c[i]
    end;
  for I := 0 to 47  do
    f[i]:=temp[p[i]-1];
end;

function e(var s:_bit):_bit;
const _e:array[0..47]of byte =(32,1,2,3,4,5,4,5,6,7
,8,9,8,9,10,11,12,13,12,13,14,15,16,17,16,17,18,19
,20,21,20,21,22,23,24,25,24,25,26,27,28,29,28,29,30,31,32,1);
var i:integer;
  temp:_bit;
begin
  setlength(temp,48);
  for I := 0 to 47  do
      temp[i]:=s[_e[i]-1];
  e:=temp;
end;

procedure makebb(var s:_bit;var f:tbb);
var i,j:integer;
begin
  for I := 1 to 8  do
    begin
      setlength(f[9-i],6);
      for j := 0 to 5  do
        f[9-i,j]:=s[i*6+j-6];
    end;
end;

procedure getBACK(var s:tbb;var f:_bit);
var i,j:integer;
begin
  for I := 1 to 8 do
  begin
    for j := 0 to 3 do
      f[i*4-4+j]:=s[9-i,j];
  end;
end;

function getA(var s:_bit):integer;
var temp:integer;
begin
  temp:=0;
  if s[5]
  then temp:=temp+1;
  temp:=temp*2;
  if s[0]
  then temp:=temp+1;
  geta:=temp;
end;

function getB(var s:_bit):integer;
var temp:integer;
begin
  temp:=0;
  if s[4]
  then temp:=temp+1;
  temp:=temp*2;
  if s[3]
  then temp:=temp+1;
  temp:=temp*2;
  if s[2]
  then temp:=temp+1;
  temp:=temp*2;
  if s[1]
  then temp:=temp+1;
  getb:=temp
end;

procedure _6to4(var s,f:tbb);
const ss:array[1..8,0..3,0..15] of byte=(

	((14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7),
        (0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8),
        (4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0),
        (15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13)),

        ((15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10),
        (3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5),
        (0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15),
        (13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9)),

        ((10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8),
        (13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1),
        (13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7),
        (1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12)),

        ((7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15),
	(13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9),
        (10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4),
        (3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14)),

	((2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9),
        (14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6),
        (4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14),
        (11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3)),

	((12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11),
	(10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8),
	(9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6),
	(4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13)),

	((4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1),
	(13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6),
	(1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2),
	(6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12)),

	((13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7),
        (1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2),
        (7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8),
        (2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11)));
var i,x:integer;
begin
  for I := 1 to 8  do
    begin
      x:=ss[i,getA(s[i]),getB(s[i])];
      setlength(f[i],4);
      if x mod 2=1
      then
      begin
        f[i,0]:=true;
        x:=x-1;
      end
      else f[i,0]:=false;
      x:=x div 2;
      if x mod 2=1
      then
      begin
        f[i,1]:=true;
        x:=x-1;
      end
      else f[i,1]:=false;
      x:=x div 2;
      if x mod 2=1
      then
      begin
        f[i,2]:=true;
        x:=x-1;
      end
      else f[i,2]:=false;
      x:=x div 2;
      if x mod 2=1
      then
      begin
        f[i,3]:=true;
      end
      else f[i,3]:=false;
    end;
end;

procedure feistel(var s,key,f:_bit);
const p:array[0..31]of byte=(16,7,20,21,29,12,28,17,1,15,
23,26,5,18,31,10,2,8,24,14,32,27,3,9,19,13,30,6,22,11,4,25);
var bb,bb4:tbb;
  t1,t2,t11:_bit;
  i:integer;
begin
  setlength(t11,48);
  t11:=e(s);
  setlength(t1,48);
  t1:=xorbin(t11,key,48);
  makeBB(t1,bb);
  _6to4(bb,bb4);
  setlength(t2,32);
  getback(bb4,t2);
  setlength(f,32);
  for i := 0 to 31  do
    f[i]:=t2[p[i]-1];
end;

procedure DESencrypt(s:string;var allkeys:tkeys;var f:string);
type tcon=record
          l,r:_bit;
          end;
var startbin,ki,ipbin,keyb,temp:_bit;
  con,last:tcon;
  test:array[1..8]of byte;
  i:integer;
begin
     for i:=1 to 8 do
     test[i]:=i*2;
     
     setlength(startbin,64);
     strtobin(s,startbin);

     setlength(keyb,64);
     setlength(ki,48);
     ip(startbin,ipbin);


     setlength(last.l,32);
     setlength(last.r,32);
     copybit(ipbin,last.r,1,32);
     copybit(ipbin,last.l,33,64);
     setlength(con.l,32);
     setlength(con.r,32);


     setlength(temp,32);
     for I := 1 to 16 do
       begin
        ki:=allkeys[i];
        con.l:=last.r;
        feistel(last.r,ki,temp);
        con.r:=xorbin(last.l,temp,32);
        last:=con;
       end;

      for I := 0 to 31  do
       begin
        startbin[i]:=last.r[i];
        startbin[i+32]:=last.l[i];
       end;
     de_ip(startbin,ipbin);
     bintostr(ipbin,f,64);
end;
procedure DESdecrypt(s:string;var allkeys:tkeys;var f:string);
type tcon=record
          l,r:_bit;
          end;
var startbin,ki,ipbin,keyb,temp:_bit;
  con,last:tcon;
  i:integer;
begin
     setlength(startbin,64);
     strtobin(s,startbin);
     setlength(keyb,64);
     setlength(ki,48);
     ip(startbin,ipbin);

     setlength(last.l,32);
     setlength(last.r,32);
     copybit(ipbin,last.r,1,32);
     copybit(ipbin,last.l,33,64);
     setlength(con.l,32);
     setlength(con.r,32);
     
     setlength(temp,32);

     for I := 16 downto 1 do
       begin
        ki:=allkeys[i];
        con.r:=last.l;
        feistel(last.l,ki,temp);
        con.l:=xorbin(last.r,temp,32);
        last:=con;
       end;

      for I := 0 to 31  do
       begin
        startbin[i]:=last.r[i];
        startbin[i+32]:=last.l[i];
       end;
     de_ip(startbin,ipbin);
     bintostr(ipbin,f,64);
end;
procedure KeyGenerate(s:string;var f:tkeys);
var cd:conkey;
  i:integer;
  keyb:_bit;
begin
     setlength(cd.c,28);
     setlength(cd.d,28);
     setlength(keyb,64);
     strtobin(s,keyb);
     getC0d0(keyb,cd);
     for i:=1 to 16 do
     begin
        setlength(f[i],48);
        getconkey(cd,f[i],i);
     end;
end;
procedure enblock(var s,f:string;ki1,ki2,ki3:tkeys;reg:integer);
var temp,temp2:string;
begin
     case reg of
     single:begin
                desEncrypt(s,ki1,f);
              end;
     double:
      begin       desEncrypt(s,ki1,temp);
                  desEncrypt(temp,ki2,f);
              end;
     triple:
      begin
                  desEncrypt(s,ki1,temp);
                  desEncrypt(temp,ki2,temp2);
                  desEncrypt(temp2,ki3,f);
              end;
      end;
end;
procedure deblock(var s,f:string;ki1,ki2,ki3:tkeys;reg:integer);
var temp,temp2:string;
begin
     case reg of
     single:begin
                desdecrypt(s,ki1,f);
              end;
     double:
      begin       desdecrypt(s,ki2,temp);
                  desdecrypt(temp,ki1,f);
              end;
     triple:
      begin
                  desdecrypt(s,ki3,temp);
                  desdecrypt(temp,ki2,temp2);
                  desdecrypt(temp2,ki1,f);
              end;
      end;
end;
function xorstr(a,b:string;n:integer):string;
var abin,bbin,cbin:_bit;
  c:string;
begin
  setlength(abin,n*8);
  strtobin(copy(a,1,8),abin);
  setlength(bbin,n*8);
  strtobin(copy(b,1,8),bbin);
  setlength(cbin,n*8);
  cbin:=xorbin(abin,bbin,n*8);
  BinToStr(cbin,c,n*8);
  xorstr:=c;
end;
procedure Encrypt(var s,f,key:string;reg:integer);
const IV='w1r,2/-;';
var temp,temp2,last,temp3:string;
    d,j:int64;
    i:integer;
    rest:byte;
    ki1,ki2,ki3:tkeys;
begin
  error:='';
  case reg of
     single:
      begin
        if length(key)<>8
        then  error:='Длинна ключа должна быть 8 символов'
        else  keygenerate(key,ki1);
      end;
     double:
      begin
        if length(key)<>16
        then  error:='Длинна ключа должна быть 16 символов'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
              end;
      end;
     triple:
      begin
        if length(key)<>24
        then  error:='Длинна ключа должна быть 24 символа'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
                  keyGenerate(copy(key,17,8),ki3);
              end;
      end;
     end;
  d:=length(s)div 8;
  rest:=length(s)mod 8;
  f:='';
  f:=f+chr(rest+ord('a'));
  if error<>''
  then exit;
      j:=0;
      last:=IV;
      while j<>d do
      begin
        inc(j);
        temp:=copy(s,1,8);
        s:=copy(s,9,length(s)-7);
        temp3:=xorstr(temp,last,8);
        enblock(temp3,temp2,ki1,ki2,ki3,reg);
        last:=temp2;
        f:=f+temp2;
      end;
      temp:='        ';
      for i:=1 to rest do
        temp[i]:=s[i];
      if rest>0
      then
      begin
        temp3:=xorstr(temp,last,8);
        enblock(temp3,temp2,ki1,ki2,ki3,reg);
        f:=f+temp2;
      end;
end;

procedure Decrypt(var s,f,key:string;reg:integer);
const IV='w1r,2/-;';
var temp,temp2,temp3,last,tek:string;
    rest:integer;
    d,j:int64;
    ki1,ki2,ki3:tkeys;
begin
  error:='';
  case reg of
     single:
      begin
        if length(key)<>8
        then  error:='Длинна ключа должна быть 8 символов'
        else  keygenerate(key,ki1);
      end;
     double:
      begin
        if length(key)<>16
        then  error:='Длинна ключа должна быть 16 символов'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
              end;
      end;
     triple:
      begin
        if length(key)<>24
        then  error:='Длинна ключа должна быть 24 символа'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
                  keyGenerate(copy(key,17,8),ki3);
              end;
      end;
     end;
  if error<>''
  then exit;
  d:=(length(s)-1) div 8;
  rest:=ord(s[1])-ord('a');
  f:='';
  s:=copy(s,2,length(s)-1);
      j:=0;
      tek:=IV;
      while j<>d do
      begin
        inc(j);
        temp:=copy(s,1,8);
        s:=copy(s,9,length(s)-7);
        last:=temp;
        deblock(temp,temp2,ki1,ki2,ki3,reg);
        temp3:=xorstr(temp2,tek,8);
        tek:=last;
        f:=f+temp3;
      end;
      if rest<>0
      then f:=copy(f,0,length(f)-8+rest);
end;

procedure EncryptSound(var s,f,key:string;reg:integer);
const IV='w1r,2/-;';
var temp,temp2,last,temp3:string;
    d,j:int64;
    ki1,ki2,ki3:tkeys;
begin
  error:='';
  case reg of
     single:
      begin
        if length(key)<>8
        then  error:='Длинна ключа должна быть 8 символов'
        else  keygenerate(key,ki1);
      end;
     double:
      begin
        if length(key)<>16
        then  error:='Длинна ключа должна быть 16 символов'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
              end;
      end;
     triple:
      begin
        if length(key)<>24
        then  error:='Длинна ключа должна быть 24 символа'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
                  keyGenerate(copy(key,17,8),ki3);
              end;
      end;
     end;
  d:=length(s)div 8;
  f:='';
  if error<>''
  then exit;
      j:=0;
      last:=IV;
      while j<>d do
      begin
        inc(j);
        temp:=copy(s,1,8);
        s:=copy(s,9,length(s)-7);
        temp3:=xorstr(temp,last,8);
        enblock(temp3,temp2,ki1,ki2,ki3,reg);
        last:=temp2;
        f:=f+temp2;
      end;
end;

procedure DecryptSound(var s,f,key:string;reg:integer);
const IV='w1r,2/-;';
var temp,temp2,temp3,last,tek:string;
    d,j:int64;
    ki1,ki2,ki3:tkeys;
begin
  error:='';
  case reg of
     single:
      begin
        if length(key)<>8
        then  error:='Длинна ключа должна быть 8 символов'
        else  keygenerate(key,ki1);
      end;
     double:
      begin
        if length(key)<>16
        then  error:='Длинна ключа должна быть 16 символов'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
              end;
      end;
     triple:
      begin
        if length(key)<>24
        then  error:='Длинна ключа должна быть 24 символа'
        else  begin
                  keyGenerate(copy(key,1,8),ki1);
                  keyGenerate(copy(key,9,8),ki2);
                  keyGenerate(copy(key,17,8),ki3);
              end;
      end;
     end;
  if error<>''
  then exit;
  d:=length(s) div 8;
  f:='';
      j:=0;
      tek:=IV;
      while j<>d do
      begin
        inc(j);
        temp:=copy(s,1,8);
        s:=copy(s,9,length(s)-7);
        last:=temp;
        deblock(temp,temp2,ki1,ki2,ki3,reg);
        temp3:=xorstr(temp2,tek,8);
        tek:=last;
        f:=f+temp3;
      end;
end;

end.
