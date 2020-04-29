unit CodeBar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, printers;

type
  TCodeType=(Code128A,Code128B,Code128C);
  TCodeBar = class(tcomponent)
  private
    { Private declarations }
    fUnitWidth:integer;
    fHeight:integer;
    fCodeString:string;
    fCanCode:boolean;
    fHead:string;
    fTail:String;
    fBody:string;
    fCheckSum:string;
    fHasCheckSum:boolean;
    fInnerSpace:integer;
    fWithLabel:boolean;
    procedure setCodeString(str:string);virtual;abstract;
    function getWidth:integer;
   protected
    { Protected declarations }
  public
     constructor create(AOwner: TComponent);override;
     destructor destroy;override;
     procedure draw(canvas:TCanvas;x,y:integer);
    { Public declarations }
  published
  { Published declarations }
    property UnitWidth:integer read fUnitWidth write fUnitWidth;
    property Height:integer read fHeight write fHeight;
    property CodeString:string read fCodeString write setCodeString;
    property CanCode:boolean read fCanCode;
    property Width:integer read GetWidth;
    property WithLabel:boolean read fWithLabel write fWithLabel;
  end;

  TCodebar39 =class(tCodeBar)
  Private
    fdict:tStrings;
    procedure setCodeString(str:string);override;
  protected
  public
   constructor create(AOwner: TComponent);override;
   destructor destroy;override;
  published
  end;

 TCodeBar128 =class(TCodebar)
 Private
    fCodeType:tCodeType;
    fdict:array[0..106] of word;
    procedure SetCodeType(CodeType:TcodeType);

    function CheckDict(index:integer):string;

    function Code128AChar(c:char):integer;
    function Code128BChar(c:char):integer;

    function Code128AValid(str:string):boolean;
    function code128BValid(Str:String):boolean;
    function Code128CValid(Str:String):boolean;

    procedure Code128ASetString;
    procedure Code128BSetString;
    procedure Code128CSetString;

    procedure setCodeString(str:string);override;
 Protected
 public
   constructor create(AOwner: TComponent);override;
   destructor destroy;override;
 published
   property CodeType:TCodeType read fCodeType Write SetCodeType;
 end;
//procedure Register;

implementation

function DrawBar(canvas:TCanvas;str:string;X,Y:integer;UnitWidth,UnitHeight:integer):integer;
var
 i,len:integer;
begin
  len:=length(str);
//  canvas.Brush.Color:=clblack;
  for i:=1 to len do
  if str[i]='1' then
    canvas.Rectangle(X+(i-1)*UnitWidth,Y,X+i*UnitWidth,Y+UnitHeight);
  result:=X+len*UnitWidth;
  end;

constructor TcodeBar.create(AOwner:tcomponent);
begin
  inherited;
  fUnitWidth:=5;
  fHeight:=50;
  fCanCode:=false;
  fHead:='';
  fTail:='';
  fBody:='';
  fCheckSum:='';
  fHasCheckSum:=false;
  fInnerSpace:=0;
  fWithLabel:=true;
end;

destructor TcodeBar.destroy;
begin
  inherited;
end;


procedure TCodeBar.draw(canvas:TCanvas;X,Y:integer);
Var
 x1:integer;
 TextWidth:integer;
begin
  if not fCanCode then exit;
//  printer.canvas.Rectangle(X,Y,X+Width,Y+Height);
  canvas.Brush.Color:=clBlack;
  x1:=DrawBar(Canvas,fHead,X,Y,fUnitWidth,fHeight);
  X1:=X1+fInnerSpace*fUnitWidth;
  X1:=DrawBar(Canvas,fBody,X1,Y,fUnitWidth,fHeight);
  if fHasCheckSum then
  begin
    X1:=X1+fInnerSpace*fUnitWidth;
    X1:=DrawBar(Canvas,fCheckSum,X1,Y,fUnitWidth,fHeight);
  end;
  X1:=X1+fInnerSpace*fUnitWidth;
  DrawBar(Canvas,fTail,X1,Y,fUnitWidth,fHeight);
  canvas.Brush.Color:=clwhite;
  if fWithLabel then
  begin
    canvas.Font.Name:='Courier New';
    canvas.Font.Size:=8 * (printer.Canvas.Font.PixelsPerInch) div (canvas.Font.PixelsPerInch);
    canvas.Font.Style:=[];
    TextWidth:=Canvas.TextWidth(CodeString);
    Canvas.TextOut(X+(Width-TextWidth) div 2,Y+fHeight+3, CodeString);
  End;

end;

function TCodeBar.GetWidth:integer;
begin
  if fCanCode then
    begin
      result:=length(fhead)+length(fbody)+length(ftail);
      if fInnerSpace>0 then result:=result+2;
      if fHasCheckSum then
      begin
        result:=result+length(fCheckSum);
        if fInnerSpace>0 then result:=result+1;
      end;

      result:=result*fUnitWidth;
    end
  else
    result:=0;
end;


constructor TCodeBar39.create(AOwner: TComponent);
begin
  inherited;
  fhead:='100101101101';
  ftail:='100101101101';
  finnerspace:=1;
  fhasCheckSum:=false;
  fCanCode:=false;
  fdict:=tStringList.Create;
  fdict.Add('0=101001101101');
  fdict.Add('1=110100101011');
  fdict.Add('2=101100101011');
  fdict.Add('3=110110010101');
  fdict.Add('4=101001101011');
  fdict.Add('5=110100110101');
  fdict.add('6=101100110101');
  fdict.Add('7=101001011011');
  fdict.Add('8=110100101101');
  fdict.Add('9=101100101101');
  fdict.Add('A=110101001011');
  fdict.Add('B=101101001011');
  fdict.Add('C=110110100101');
  fdict.Add('D=101011001011');
  fdict.Add('E=110101100101');
  fdict.Add('F=101101100101');
  fdict.Add('G=101010011011');
  fdict.Add('H=110101001101');
  fdict.Add('I=101101001101');
  fdict.Add('J=101011001101');
  fdict.Add('K=110101010011');
  fdict.Add('L=101101010011');
  fdict.Add('M=110110101001');
  fdict.Add('N=101011010011');
  fdict.add('O=110101101001');
  fdict.Add('P=101101101001');
  fdict.Add('Q=101010110011');
  fdict.Add('R=110101011001');
  fdict.Add('S=101101011001');
  fdict.Add('T=101011011001');
  fdict.Add('U=110010101011');
  fdict.Add('V=100110101011');
  fdict.Add('W=110011010101');
  fdict.Add('X=100101101011');
  fdict.Add('Y=110010110101');
  fdict.Add('Z=100110110101');

end;

destructor tCodeBar39.destroy;
begin
 fdict.Free;
 inherited;
end;

procedure Tcodebar39.setCodeString(str:string);
var
 i,len:integer;
 a:string;
begin
 fCodeString:=Str;
 len:=length(str);
 fbody:='';
 fCanCode:=true;
 for i:=1 to len do
 begin
   a:=str[i];
   if fdict.Values[a]='' then
   begin
      fCanCode:=false;
      fCodeString:='';
      break;
   end
   else
   fbody:=fbody+fdict.Values[str[i]];
   if finnerspace>0 then fbody:=fbody+'0';
 end;

end;

procedure tCodeBar128.SetCodeType(CodeType:TCodeType);
begin
  fCodeType:=CodeType;
  case CodeType of
    Code128A: fhead:='11010000100';
    code128B: fhead:='11010010000';
    Code128C: fhead:='11010011100';
  end;

  setCodeString(fCodeString);

end;

constructor tCodeBar128.create(aowner:tcomponent);
begin
  inherited;
  ftail:='1100011101011';
  fHasChecksum:=true;
  fCodeString:='';
  SetCodeType(Code128C);
  fdict[0]:=$06CC;
  fdict[1]:=$066C;
  fdict[2]:=$0666;
  fdict[3]:=$0498;
  fdict[4]:=$048C;
  fdict[5]:=$044C;
  fdict[6]:=$04C8;
  fdict[7]:=$04C4;
  fdict[8]:=$0464;
  fdict[9]:=$0648;
  fdict[10]:=$0644;
  fdict[11]:=$0624;
  fdict[12]:=$059C;
  fdict[13]:=$04DC;
  fdict[14]:=$04CE;
  fdict[15]:=$05CC;
  fdict[16]:=$04EC;
  fdict[17]:=$04E6;
  fdict[18]:=$0672;
  fdict[19]:=$065C;
  fdict[20]:=$064E;
  fdict[21]:=$06E4;
  fdict[22]:=$0674;
  fdict[23]:=$076E;
  fdict[24]:=$074C;
  fdict[25]:=$072C;
  fdict[26]:=$0726;
  fdict[27]:=$0764;
  fdict[28]:=$0734;
  fdict[29]:=$0732;
  fdict[30]:=$06D8;
  fdict[31]:=$06C6;
  fdict[32]:=$0636;
  fdict[33]:=$0518;
  fdict[34]:=$0458;
  fdict[35]:=$0446;
  fdict[36]:=$0588;
  fdict[37]:=$0468;
  fdict[38]:=$0462;
  fdict[39]:=$0688;
  fdict[40]:=$0628;
  fdict[41]:=$0622;
  fdict[42]:=$05B8;
  fdict[43]:=$058E;
  fdict[44]:=$046E;
  fdict[45]:=$05D8;
  fdict[46]:=$05C6;
  fdict[47]:=$0476;
  fdict[48]:=$0776;
  fdict[49]:=$068E;
  fdict[50]:=$062E;
  fdict[51]:=$06E8;
  fdict[52]:=$06E2;
  fdict[53]:=$06EE;
  fdict[54]:=$0758;
  fdict[55]:=$0746;
  fdict[56]:=$0716;
  fdict[57]:=$0768;
  fdict[58]:=$0762;
  fdict[59]:=$071A;
  fdict[60]:=$077A;
  fdict[61]:=$0642;
  fdict[62]:=$078A;
  fdict[63]:=$0530;
  fdict[64]:=$050C;
  fdict[65]:=$04B0;
  fdict[66]:=$0486;
  fdict[67]:=$042C;
  fdict[68]:=$0426;
  fdict[69]:=$0590;
  fdict[70]:=$0584;
  fdict[71]:=$04D0;
  fdict[72]:=$04C2;
  fdict[73]:=$0434;
  fdict[74]:=$0432;
  fdict[75]:=$0612;
  fdict[76]:=$0650;
  fdict[77]:=$07BA;
  fdict[78]:=$0614;
  fdict[79]:=$047A;
  fdict[80]:=$053C;
  fdict[81]:=$04BC;
  fdict[82]:=$049E;
  fdict[83]:=$05E4;
  fdict[84]:=$04F4;
  fdict[85]:=$04F2;
  fdict[86]:=$07A4;
  fdict[87]:=$0794;
  fdict[88]:=$0792;
  fdict[89]:=$06DE;
  fdict[90]:=$06F6;
  fdict[91]:=$07B6;
  fdict[92]:=$0578;
  fdict[93]:=$051E;
  fdict[94]:=$045E;
  fdict[95]:=$05E8;
  fdict[96]:=$05E2;
  fdict[97]:=$07A8;
  fdict[98]:=$07A2;
  fdict[99]:=$05DE;
  fdict[100]:=$05EE;
  fdict[101]:=$075E;
  fdict[102]:=$07AE;
  fdict[103]:=$0684;
  fdict[104]:=$0690;
  fdict[105]:=$069C;
  fdict[106]:=$063A;
end;

destructor TCodeBar128.destroy;
begin
  inherited;
end;

function Tcodebar128.CheckDict(index:integer):string;
Var
  i:integer;
  a: string;
  w,mask:word;
BEGIN
  a:='11111111111';
  w:=fdict[index];
  mask:=$0400;
  for i:=1 to 11 do
    if (w and (mask shr (i-1))) = $0000 then
     a[i]:='0';
  result:=a;

END;

function tCodeBar128.Code128AChar(C:char):integer;
begin

  if c<#32 then
     result:=integer(c)+64
  else
     result:=integer(c)-32;

end;

function tCodeBar128.Code128BChar(c:Char):integer;
begin
  result:=integer(c)-32;
end;



function TCodeBar128.Code128AValid(str:String):boolean;
Var
  i:integer;
  c:char;
begin
 result:=true;
 for i:=1 to length(str) do
 begin
   c:=str[i];
   if c>=#96 then
   begin
     result:=false;
     break;
   end;
 end;
end;

function TCodeBar128.Code128BValid(str:String):boolean;
Var
  i:integer;
  c:char;
begin
 result:=true;
 for i:=1 to length(str) do
 begin
   c:=str[i];
   if (c<#32) or (c>#127) then
   begin
     result:=false;
     break;
   end;
 end;
end;

function TCodeBar128.Code128CValid(str:String):boolean;
Var
  i:integer;
  c:char;
begin
 result:=true;
 for i:=1 to length(str) do
 begin
   c:=str[i];
   if (c<#48) or (c>#57) then
   begin
     result:=false;
     break;
   end;
 end;
end;

procedure TCodeBar128.Code128ASetString;
var
  c:char;
  checksum:integer;
  body:string;
  i,k:integer;
begin
  checksum:=0;
  Body:='';
  fHasCheckSum:=true;
  fCheckSum:='';
  for i:=1 to length(fCodeString) do
  begin
    c:=fCodeString[i];
    k:=Code128AChar(c);
    body:=body+checkdict(k);
    checksum:=(checksum+k*i) mod 103;
  end;
  fBody:=body;
  fCheckSum:=checkdict(checksum);

end;

procedure TCodeBar128.Code128BSetString;
var
  c:char;
  checksum:integer;
  body:string;
  i,k:integer;
begin
  checksum:=1;
  Body:='';
  fHasCheckSum:=true;
  for i:=1 to length(fCodeString) do
  begin
    c:=fCodeString[i];
    k:=Code128BChar(c);
    body:=body+checkdict(k);
    checksum:=(checksum+k*i) mod 103;
  end;
  fBody:=body;
  fCheckSum:=checkdict(checksum);

end;

procedure TCodeBar128.Code128CSetString;
var
 i,l,k:integer;
 checksum:integer;
 myCodeString:string;
 body:string;
begin
  fHasCheckSum:=true;
  l:=length(fCodeString);
  if (l mod 2)=1 then begin
                        myCodeString:='0'+fCodeString;
                        l:=l+1;
                       end
                 else myCodeString:=fCodeString;
  l:=l div 2;
  checksum:=2;
  body:='';
  for i:=1 to l do
  begin
    k:=strtoint(copy(myCodeString,(i-1)*2+1,2));
    body:=body+checkdict(k);
    checksum:=(checksum+k*i) mod 103;
  end;
    fbody:=body;
    fchecksum:=checkdict(checksum);

end;

procedure TCodeBar128.setCodeString(str:string);

begin
  case fCodeType of
    Code128A: fCanCode:=Code128AValid(str);
    Code128B: fCanCode:=Code128BValid(str);
    Code128C: fCanCode:=Code128CValid(str);
  end;

  if not fCanCode then exit;
  fCodeString:=str;

  case fCodeType of
    Code128A:Code128ASetString;
    Code128B:Code128BSetString;
    Code128C:Code128CSetString;
  end;
end;

//procedure Register;
//begin
//  RegisterComponents('Samples', [TCodeBar]);
//end;

end.
