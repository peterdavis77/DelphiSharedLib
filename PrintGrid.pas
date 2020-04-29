unit PrintGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, printers, CodeBar, VPrinter, Preview;
const
  //font face
  _FSONG = 1;
  _FHEI = 2;
  _FKAI = 3;
  _FFANG = 4;

  //font_style
  _TNONE = $00;
  _TBOLD = $01;
  _TITALIC = $02;
  _TUNDERLINE = $04;
  _TSTRIKEOUT = $08;

  //align
  _ALEFT = $00;
  _ACENTER = $01;
  _ARIGHT = $02;
  _AVCENTER = $00;
  _ATOP = $04;
  _ABOTTOM = $08;

  _RS0 = $00;
  _RS1 = $10;
  _RS2 = $20;
  _RS3 = $30;
  _RS4 = $40;
  _RS5 = $50;
  _RS6 = $60;
  _RS7 = $70;
 {
  _RS8 = $80;
  _RS9 = $90;
  _RS10 = $A0;
  _RS11 = $B0;
  _RS12 = $C0;
  _RS13 = $D0;
  _RS14 = $E0;
  _RS15 = $F0;
  }
  //减小row span 取值范围，占用3位

  _NWB = $00;
  _WB = $80;

  //_NWB = no word break ; _WB= Word break

  //border
  _BNONE = $00;
  _BTOP = $01;
  _BBOTTOM = $02;
  _BLEFT = $04;
  _BRIGHT = $08;
  _BBOTH = $0F;



type
  Tmargin = record
    top: integer;
    left: integer;
    bottom: integer;
    right: integer;
  end;

  tCellAlign = (caLeft, caCenter, caRight);
  tCellValign = (caVCenter, caTop, caBottom);
  tPrint_info = record
    font_name: string;
    font_size: integer;
    font_style_bold: boolean;
    font_style_italic: boolean;
    font_style_underline: boolean;
    font_style_strikeout: boolean;
    align: tCellAlign;
    valign: tCellValign;
    rowsspan: byte;
    wordbreak: boolean;
    border_top: boolean;
    border_bottom: boolean;
    border_left: boolean;
    border_right: boolean;
    bg_gray: boolean;
    text: string;
    box_width: integer;
    box_height: integer;
  end;



  TPrintGrid = class(TComponent)
  private
    fmargin: TMargin;
    fbody: TStrings;
    fHasTail: boolean;
    ffreezelines: integer;
    fline_space: integer;
    fprint_codebar: boolean;
    fCodeBar_string: string;
//    fprint_info: tprint_info;
//    fcurrent_content: string;
    fWidths: tstrings;
    fContents: tstrings;

    ffontFace: byte;
    ffontSize: integer;
    ffontStyle: byte;

    falign: byte;
    fborder: byte;
    fbg_gray: boolean;

    fcur_x, fcur_y: integer;
    fcur_page: integer;
    fcur_line: integer;
    fdoc_area: trect;

    fline_heights: tstrings;
    fPreview: boolean;
    fVPrinter: TVPrinter;

    procedure set_fontface(fontface: byte);
    procedure set_fontsize(fontsize: integer);
    procedure set_fontStyle(fontStyle: byte);

    function get_bold: boolean;
    procedure set_bold(bold: boolean);

    function get_italic: boolean;
    procedure set_italic(italic: boolean);

    function get_underline: boolean;
    procedure set_underline(underline: boolean);

    function get_strikeout: boolean;
    procedure set_strikeout(strikeout: boolean);

    procedure set_align(align: byte);
    procedure set_border(border: byte);

    procedure solve_print(print_str: string; var print_info: tprint_info);
    procedure printcell(print_info: tprint_info);
    function printline(line_str: string; empty: boolean = false): boolean;
    procedure NextPage;
    procedure printtail;
    procedure printCodebar;

    function get_HAlign: TCellAlign;
    function get_VAlign: TcellVAlign;
    function get_RowSpan: integer;
    function get_WordBreak: boolean;

    procedure Set_HAlign(HAlign: TCellAlign);
    procedure Set_VAlign(VAlign: TCellVAlign);
    procedure Set_RowSpan(RowSpan: integer);
    procedure Set_WordBreak(WordBreak: Boolean);
    { Private declarations }

  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure newline;
    procedure newcell(content: string; width: integer); overload;
    procedure newcell(content: string; width: integer; cell_align: byte); overload;
    procedure post;
    procedure set_freezelines(lines: integer);

    procedure print(fill_page: boolean = false);

    procedure init;

  published
    { Published declarations }
    property margin: tmargin read fmargin write fmargin;
    property fontface: byte read ffontface write set_fontface;
    property line_space: integer read fline_space write fline_space;
    property fontsize: integer read ffontsize write set_fontsize;
    property fontstyle: byte read ffontstyle write set_fontstyle;
    property align: byte read falign write set_align;
    property border: byte read fborder write set_border;
    property HAlign: tCellAlign read get_HAlign write set_HAlign;
    property VAlign: tCellVAlign read get_VAlign write set_VAlign;
    property RowSpan: integer read get_RowSpan write set_RowSpan;
    property WordBreak: boolean read Get_WordBreak write Set_WordBreak;

    property bold: boolean read get_bold write set_bold;
    property italic: boolean read get_italic write set_italic;
    property underline: boolean read get_underline write set_underline;
    property strikeout: boolean read get_strikeout write set_strikeout;

    property bg_gray: boolean read fbg_gray write fbg_gray;

    property freezelines: integer read ffreezelines write set_freezelines;
    property hastail: boolean read fhastail write fhastail;
    property codebar_string: string read fCodebar_string write fcodebar_string;
    property print_codebar: boolean read fprint_codebar write fprint_codebar;
    property body: tstrings read fbody;
    property preview: boolean read fPreview write fPreview;
    property Vprinter: TVPrinter read fVPrinter;
  end;


//procedure Register;
function TextHeightEx(canvas: tcanvas; text: string; Width: integer; WordBreak: boolean): integer;
procedure TextRectEx(canvas: tcanvas; r: trect; text: string; halign: tCellAlign; valign: tCellVAlign; WordBreak: boolean);
function dquotedstr(s: string): string; //加双引号
implementation


function TextHeightEx(canvas: tcanvas; text: string; Width: integer; WordBreak: boolean): integer;
var
  p: pchar;
  r: trect;

begin
  r := bounds(1, 1, width, 1);
  p := pchar(text);
  if wordbreak then
    drawtextex(Canvas.Handle, p, -1, r, DT_CALCRECT + DT_WORDBREAK, nil)
  else
    drawtextex(Canvas.Handle, p, -1, r, DT_CALCRECT, nil);
  result := r.Bottom - r.Top;
end;

procedure TextRectEx(canvas: tcanvas; r: trect; text: string; halign: tCellAlign; valign: tCellVAlign; WordBreak: boolean);
var
  dtFormat: cardinal;
  dy: integer;

begin

  dtFORMAT := DT_LEFT;
  case halign of
    caCENTER: dtformat := DT_CENTER;
    caLEFT: dtformat := DT_LEFT;
    caRIGHT: dtformat := DT_RIGHT;
  end;
  dy := 0;
  case valign of
    caBOTTOM: dy := r.Bottom - r.top - TextHeightEx(canvas, text, r.Right - r.Left, WordBreak);
    caVCENTER: dy := (r.Bottom - r.Top - TextHeightEx(canvas, text, r.Right - r.Left, WordBreak)) div 2;
  end;
  if WordBreak then
    dtFORMAT := dtFORMAT + DT_WORDBREAK;
  if dy < 0 then dy := 0; //只能这么写，格子里放不下这么多内容，center和bottom的时候变成top了。
  r.Top := r.Top + dy;
  drawtextex(Canvas.Handle, pchar(text), -1, r, dtformat, nil);
end;


function dquotedstr(s: string): string;
begin
  result := stringreplace(s, '"', '""', [rfReplaceAll]);
  result := '"' + result + '"';
end;

procedure TPrintGrid.init;
begin
  fmargin.top := 30;
  fmargin.bottom := 30;
  fmargin.right := 50;
  fmargin.left := 50;
  fbody.Clear;
  fhastail := true;
  ffontface := _FSONG;
  ffontStyle := _TNONE;
  ffontsize := 10;
  fAlign := _ALEFT;
  fborder := _BNONE;
  fbg_gray := false;
  fcur_x := 0;
  fcur_y := 0;

  fcur_page := 1;
  fcur_line := 1;
  ffreezelines := 0;
  fline_space := 500;
//  fcurrent_content := '';
  fwidths.Clear;
  fcontents.Clear;
  fCodebar_string := '';
  fPrint_codebar := false;
end;

constructor TPrintGrid.create(Aowner: TComponent);
begin
  inherited;
  fbody := tStringlist.Create;
  fwidths := tstringlist.Create;
  fcontents := tstringlist.Create;
  fline_heights := tstringlist.Create;
  fPreview := false;
  fVPrinter := TVPrinter.create(self);
  init;
end;

destructor TPrintGrid.destroy;
begin
  fbody.Free;
  fwidths.Free;
  fcontents.Free;
  inherited;
end;

procedure tPrintGrid.set_fontface(fontface: byte);
begin
  if (fontface < 1) or (fontface > 4) then
    raise exception.Create('字体非法');
  ffontface := fontface;
end;

procedure tPrintGrid.set_fontsize(fontsize: integer);
begin
  if (fontsize < 5) or (fontsize > 200) then
    raise exception.Create('字号非法');
  ffontsize := fontsize;
end;

procedure tPrintGrid.set_fontStyle(fontstyle: byte);
begin
  if (fontStyle > 16) then
    raise exception.Create('字体风格非法');
  ffontStyle := fontStyle;
end;

procedure tPrintGrid.set_align(align: byte);
begin
  falign := align;
end;

procedure tPrintGrid.set_border(border: byte);
begin
  if border > 16 then
    raise exception.Create('边框非法');
  fborder := border;
end;

function tPrintGrid.get_bold: boolean;
begin
  result := not ((ffontstyle and _TBOLD) = $00);
end;

function tPrintGrid.get_italic: boolean;
begin
  result := not ((ffontstyle and _TITALIC) = $00);
end;

function tPrintGrid.get_underline: boolean;
begin
  result := not ((ffontstyle and _TUNDERLINE) = $00);
end;

function tPrintGrid.get_strikeout: boolean;
begin
  result := not ((ffontstyle and _TSTRIKEOUT) = $00);
end;

procedure tPrintGrid.set_bold(bold: boolean);
begin
  if bold then
    ffontstyle := ffontstyle or _TBOLD
  else
    ffontstyle := ffontstyle and not (_TBOLD);
end;

procedure tprintGrid.set_italic(italic: Boolean);
begin
  if italic then
    ffontstyle := ffontstyle or _TITALIC
  else
    ffontstyle := ffontstyle and not (_TITALIC);
end;

procedure tPrintGrid.set_underline(underline: boolean);
begin
  if underline then
    ffontstyle := ffontstyle or _TUNDERLINE
  else
    ffontstyle := ffontstyle and not (_TUNDERLINE);
end;

procedure tPrintGrid.set_strikeout(strikeout: boolean);
begin
  if strikeout then
    ffontstyle := ffontstyle or _TSTRIKEOUT
  else
    ffontstyle := ffontstyle and not (_TSTRIKEOUT);
end;


procedure tPrintGrid.newline;
begin
//  fcurrent_content := '';
  fwidths.Clear;
  fContents.Clear;
end;

procedure tPrintGrid.post;
var
  i, c: integer;
  curr_con: string;
begin
  if fWidths.Count = 0 then exit;
//  fbody.Add(fcurrent_content);
  c := 0;
//  curr_con:='';
  for i := 0 to fwidths.count - 1 do
    c := c + strtoint(fwidths[i]);
  for i := 0 to fWidths.Count - 1 do
    fwidths[i] := inttostr(1000 * strtoint(fwidths[i]) div c);
  for i := 0 to fWidths.Count - 1 do
  begin
    if i = 0 then curr_con := dquotedstr(fcontents[i] + '#' + fwidths[i])
    else curr_con := curr_con + ',' + dquotedstr(fcontents[i] + '#' + fwidths[i]);
  end;
  fbody.Add(curr_con);
end;

procedure tPrintGrid.set_freezelines(lines: integer);
begin
  if lines > fbody.Count then
    raise exception.Create('设置冻结行失败')
  else
    ffreezelines := lines;
end;

procedure tPrintGrid.newcell(content: string; width: integer; cell_align: byte);
var
  ori_align: byte;
begin
  ori_align := falign;
  align := cell_align;
  newcell(content, width);
  falign := ori_align;
end;

procedure tPrintGrid.newcell(content: string; width: integer);
var
  ret_text: string;
  rep_text: string;
begin

  rep_text := stringreplace(content, '\', '\b', [rfReplaceAll]);
  rep_text := stringreplace(rep_text, '#', '\s', [rfReplaceAll]);
  rep_text := stringreplace(rep_text, ',', '\c', [rfReplaceAll]);
  rep_text := dquotedstr(rep_text);

  ret_text := inttostr(fFontFace) + '#' + inttostr(fFontSize) + '#' + inttostr(fFontStyle) + '#' + inttostr(fAlign) + '#' + inttostr(fBorder) + '#' + inttostr(ord(fbg_gray)) + '#' + rep_text;
  fcontents.Add(ret_text);
  fwidths.Add(inttostr(width));
//  if fCurrent_content = '' then
//    fCurrent_content := ret_text
//  else
//    fcurrent_content := fcurrent_content + ',' + ret_text;
end;

function conv_fontface(fontface: byte): string;
begin
  result := '宋体';
  case fontface of
    _FHEI: result := '黑体';
    _FKAI: result := '楷体';
    _FFANG: result := '仿宋';
  end;
end;

function conv_bits(in_byte: byte; mask: byte): boolean;
begin
  result := not ((in_byte and mask) = $00);
end;

function conv_align(in_byte: byte): tCellAlign;
begin
  result := caLeft;
  case (in_byte and $03) of
//    _ALEFT: result:=caLeft;
    _ACENTER: result := caCenter;
    _ARIGHT: result := caRight;
  end;

end;

function conv_valign(in_byte: byte): tCellVAlign;
begin
  result := caVCENTER;
  case (in_byte and $0C) of
//    _ALEFT: result:=caLeft;
    _ATOP: result := caTOP;
    _ABOTTOM: result := caBOTTOM;
  end;
end;

function conv_WordBreak(in_byte: byte): boolean;
begin
  result := not ((in_byte and $80) = $00);
end;

function conv_RowsSpan(in_byte: byte): byte;
begin
  result := (in_byte shr 4) and $07;
end;

function conv_str(in_str: string): string;
begin

  result := stringreplace(in_str, '\c', ',', [rfReplaceAll]);
  result := stringreplace(result, '\s', '#', [rfReplaceAll]);
  result := stringreplace(result, '\b', '\', [rfReplaceAll]);
end;


function tPrintGrid.get_HAlign: tCellAlign;
begin
  result := conv_align(fAlign);
end;

function TPrintGrid.get_VAlign: tCellVAlign;
begin
  result := conv_valign(fAlign);
end;

function TPrintGrid.get_RowSpan: integer;
begin
  result := integer(Conv_RowsSpan(FAlign));
end;

function TPrintGrid.get_WordBreak: boolean;
begin
  result := Conv_WordBreak(Falign);
end;

procedure TPrintGrid.Set_HAlign(HAlign: TCellAlign);
begin
  fAlign := fAlign and $FC;
  case HAlign of
    caLEFT: fAlign := fAlign or _ALEFT;
    caCENTER: fAlign := fAlign or _ACENTER;
    caRIGHT: fAlign := fAlign or _ARIGHT;
  end;
end;

procedure TPrintGrid.Set_VAlign(VAlign: TCellVAlign);
begin
  fAlign := fAlign and $F3;
  case VALign of
    caVCENTER: fAlign := fAlign or _AVCENTER;
    caTOP: falign := falign or _ATOP;
    caBOTTOM: fAlign := fAlign or _ABOTTOM;
  end;
end;

procedure TPrintGrid.Set_RowSpan(RowSpan: integer);
var
  mask: byte;
begin
  if (RowSpan < 0) or (RowSpan > 7) then
    raise exception.Create('跨行数必须介于０-7');

  fAlign := fAlign and $8F;
  mask := RowSpan;
  fAlign := fAlign or (mask shl 4);
end;

procedure TPrintGrid.Set_WordBreak(WordBreak: boolean);
begin
  if WordBreak then
    fAlign := fAlign or $80
  else
    fAlign := fAlign and $7F;
end;

procedure tprintgrid.solve_print(print_str: string; var print_info: tprint_info);
var
  temp_strs: tstrings;
  canvas: tCanvas;
begin
  if fPreview then canvas := vprinter.Canvas
  else canvas := Printer.canvas;
  temp_strs := tstringlist.Create;
  temp_strs.Delimiter := '#';
  temp_strs.DelimitedText := print_str;
  print_info.font_name := conv_fontface(byte(strtoint(temp_strs[0])));
  print_info.font_size := strtoint(temp_strs[1]) * (printer.Canvas.Font.PixelsPerInch) div (canvas.Font.PixelsPerInch);
  print_info.font_style_bold := conv_bits(byte(strtoint(temp_strs[2])), _TBOLD);
  print_info.font_style_italic := conv_bits(byte(strtoint(temp_strs[2])), _TITALIC);
  print_info.font_style_underline := conv_bits(byte(strtoint(temp_strs[2])), _TUNDERLINE);
  print_info.font_style_strikeout := conv_bits(byte(strtoint(temp_strs[2])), _TSTRIKEOUT);
  print_info.align := conv_align(byte(strtoint(temp_strs[3])));
  print_info.valign := conv_valign(byte(strtoint(temp_strs[3])));
  print_info.rowsspan := conv_rowsspan(byte(strtoint(temp_strs[3])));
  print_info.wordbreak := conv_WordBreak(byte(strtoint(temp_strs[3])));
  print_info.border_top := conv_bits(byte(strtoint(temp_strs[4])), _BTOP);
  print_info.border_bottom := conv_bits(byte(strtoint(temp_strs[4])), _BBOTTOM);
  print_info.border_left := conv_bits(byte(strtoint(temp_strs[4])), _BLEFT);
  print_info.border_right := conv_bits(byte(strtoint(temp_strs[4])), _BRIGHT);
  print_info.bg_gray := (strtoint(temp_strs[5]) = 1);
  print_info.text := conv_str(temp_strs[6]);
  print_info.box_width := strtoint(temp_strs[7]) * (printer.PageWidth * (1000 - fmargin.left - fmargin.right) div 1000) div 1000;
  Canvas.Font.Name := print_info.font_name;
  Canvas.Font.Size := print_info.font_size;
  Canvas.Font.style := [];
  if print_info.font_style_bold then Canvas.Font.Style := printer.Canvas.Font.Style + [fsBOLD];
  if print_info.font_style_underline then Canvas.Font.Style := printer.Canvas.Font.Style + [fsUNDERLINE];
  if print_info.font_style_italic then Canvas.Font.Style := printer.Canvas.Font.Style + [fsITALIC];
  if print_info.font_style_strikeout then Canvas.Font.Style := printer.Canvas.Font.Style + [fsSTRIKEOUT];
  if (print_info.text = '') or (print_info.rowsspan > 0) then
    print_info.box_height := (fline_space + 1000) * Canvas.TextHeight('A') div 1000
  else
    print_info.box_height := TextHeightEX(Canvas, print_info.text, print_info.box_Width, print_info.WordBreak) + line_space * Canvas.TextHeight('A') div 1000;

 // print_info.box_height := fline_space * text_height div 1000;
  temp_strs.Free;
end;

procedure tPrintGrid.printtail;
var
  tail_text: string;
  text_width, text_height: integer;
  text_x, text_y: integer;
  canvas: tcanvas;
begin
  if fPreview then canvas := VPrinter.canvas
  else canvas := printer.Canvas;
  Canvas.Font.name := '宋体';
  if fPreview then
    Canvas.Font.size := 10 * (printer.Canvas.Font.PixelsPerInch) div (VPrinter.canvas.Font.PixelsPerInch)
  else
    canvas.Font.size := 10;
  Canvas.Font.Style := [];
  tail_text := '第' + inttostr(fcur_page) + '页';
  text_width := Canvas.TextWidth(tail_text);
  text_height := Canvas.TextHeight(tail_text);
  text_x := (fdoc_area.Left + fdoc_area.Right - text_width) div 2;
  text_y := (printer.PageHeight + fdoc_area.Bottom - text_height) div 2;

//  if fpreview then canvas := VPrinter.canvas;
  Canvas.TextOut(text_x, text_y, tail_text);

end;

procedure tPrintGrid.printCodebar;
var
  myCodeBar: TCodeBar128;
  canvas: tcanvas;
begin
  canvas := printer.Canvas;
  if fpreview then canvas := VPrinter.canvas;
  myCodeBar := TcodeBar128.create(self);
  myCodeBar.UnitWidth := 10;
  myCodeBar.WithLabel := true;
  myCodeBar.CodeType := Code128C;
  myCodeBar.CodeString := fCodeBar_string;
  if not myCodeBar.CanCode then
  begin
    mycodebar.Free;
    exit;
  end;
  printer.Canvas.Font.name := '宋体';
  printer.Canvas.Font.size := 10;
  printer.Canvas.Font.Style := [];
  myCodeBar.Height := printer.Canvas.TextHeight(fCodeBar_String) * 3;
  myCodeBar.draw(Canvas, fdoc_area.Left, fdoc_area.Top);
  fCur_y := fcur_y + myCodeBar.Height + printer.Canvas.TextHeight(fCodeBar_String) * 2;
  mycodeBar.Free;

end;

procedure tPrintGrid.NextPage;
begin
  fline_heights.Clear;
  if fpreview then
    Vprinter.NewPage
  else
    printer.NewPage;
  inc(fcur_page);
  fcur_line := 1;
  fcur_y := fdoc_area.Top;
end;

procedure tPrintGrid.print(fill_page: boolean = false);
var
  i, j: integer;
begin
  fdoc_area.Left := printer.PageWidth * fmargin.left div 1000;
  fdoc_area.Top := printer.PageHeight * fmargin.top div 1000;
  fdoc_area.Right := printer.PageWidth * (1000 - fmargin.right) div 1000;
  fdoc_area.Bottom := printer.PageHeight * (1000 - fmargin.bottom) div 1000;

  fcur_x := fdoc_area.Left;
  fcur_y := fdoc_area.Top;

  fcur_page := 1;
  fcur_line := 1;
  if fPreview then
    VPrinter.BeginDoc
  else
    printer.BeginDoc;
  printer.Canvas.TextWidth('hello');
  i := ffreezelines;
  if fprint_codebar and not (fCodeBar_string = '') then
    printcodebar;
  while i < fbody.Count do
  begin
    if fcur_line = 1 then
    begin

      for j := 0 to ffreezelines - 1 do
        printline(body[j]);
      if fhastail then printtail;
    end;
    if not printline(body[i]) then
      NextPage
    else
      inc(i);
  end;
  if fill_page then
    while printline(body[body.count - 1], true) do
    begin
    end;
  if fPreview then
    vPrinter.EndDoc
  else
    printer.EndDoc;

  if fPreview then
  begin
    PreviewForm := TPreviewForm.Create(self);
 //   PreviewForm.fPreviewVP:=VPrinter;
    PreviewForm.init(VPrinter);
    previewForm.ShowModal;
    previewform.Free;
  end;

end;

function tPrintGrid.printline(line_str: string; empty: boolean = false): boolean;
var
  i: integer;
  line_buff: tstrings;
  max_height: integer;
  total_width: integer;
  print_infos: array of tprint_info;
begin
  line_buff := tstringlist.Create;
  line_buff.Delimiter := ',';
  line_buff.DelimitedText := line_str;

  setlength(print_infos, line_buff.Count);
  //解析单元格
  for i := 0 to line_buff.Count - 1 do
    solve_print(line_buff[i], print_infos[i]);

  max_height := 0; //最大高度
  total_width := 0; //总宽度
  for i := 0 to high(print_infos) do
  begin
    total_width := total_width + print_infos[i].box_width;
    if print_infos[i].box_height > max_height then
      max_height := print_infos[i].box_height;
  end;
  if (fcur_y + max_height) > fdoc_area.Bottom then
  begin
    line_buff.Free;
    print_infos := nil;
    result := false;
    exit;
  end;
  //set the max_height to every cell in the line
  for i := 0 to high(print_infos) do
    print_infos[i].box_height := max_height;
  //adjust line width
  print_infos[high(print_infos)].box_width := print_infos[high(print_infos)].box_width + fdoc_area.Right - fdoc_area.Left - total_width;
  fcur_x := fdoc_area.Left;
  if empty then
    for i := 0 to high(print_infos) do
      print_infos[i].text := ' ';
  for i := 0 to high(print_infos) do
    printcell(print_infos[i]);
  fline_heights.Add(inttostr(max_height));
  fcur_y := fcur_y + max_height;
  inc(fcur_line);
  print_infos := nil;
  line_buff.Free;
  result := true;
end;

procedure PrintBorder(canvas: tCanvas; r: trect; left: boolean; top: boolean; right: boolean; bottom: boolean);
begin
  if top then
  begin
    Canvas.MoveTo(r.Left, r.Top);
    Canvas.LineTo(r.Right, r.Top);
  end;
  if bottom then
  begin
    Canvas.MoveTo(r.Left, r.Bottom);
    Canvas.LineTo(r.Right, r.Bottom);
  end;
  if left then
  begin
    Canvas.MoveTo(r.Left, r.Top);
    Canvas.LineTo(r.left, r.bottom);
  end;
  if right then
  begin
    Canvas.MoveTo(r.right, r.Top);
    Canvas.LineTo(r.right, r.bottom);
  end;


end;

procedure tPrintGrid.printcell(print_info: tprint_info);
var
  i: integer;
  myrect: trect;
  offset_x, offset_y: integer;
  canvas: tcanvas;
begin
  if fPreview then canvas := vPrinter.canvas
  else canvas := printer.Canvas;
  myrect := bounds(fcur_x, fcur_y, print_info.box_width, print_info.box_height);

  if print_info.rowsspan > 0 then
  begin
    if print_info.rowsspan > fline_heights.Count then
    begin
      print_info.rowsspan := fline_heights.Count;
      print_info.text := '';
    end;
    for i := 1 to print_info.rowsspan do
      myrect.Top := myrect.Top - strtoint(fline_heights[fline_heights.count - i]);

  end;

//  printer.Canvas.Brush.Color:=clWhite;
 // printer.Canvas.Brush.Style:=bsSolid;
  Canvas.FillRect(myrect);
 // printer.Canvas.Brush.Style:=bsClear;

  Canvas.Font.Name := print_info.font_name;
  Canvas.Font.Size := print_info.font_size;
  Canvas.Font.style := [];
  if print_info.font_style_bold then Canvas.Font.Style := printer.Canvas.Font.Style + [fsBOLD];
  if print_info.font_style_underline then Canvas.Font.Style := printer.Canvas.Font.Style + [fsUNDERLINE];
  if print_info.font_style_italic then Canvas.Font.Style := printer.Canvas.Font.Style + [fsITALIC];
  if print_info.font_style_strikeout then Canvas.Font.Style := printer.Canvas.Font.Style + [fsSTRIKEOUT];
  PrintBorder(Canvas, myrect, print_info.border_left, print_info.border_top, print_info.border_right, print_info.border_bottom);
  if print_info.bg_gray then
  begin
    Canvas.Brush.Color := clGray;
    canvas.Rectangle(myrect);
  end;
  offset_x := printer.Canvas.TextWidth('A') div 3;
  offset_y := fline_space * printer.Canvas.TextHeight('A') div 3000;
  inflateRect(myrect, -offset_x, -offset_y);
  if not (print_info.text = '') then
    textrectex(Canvas, myrect, print_info.text, print_info.align, print_info.valign, print_info.wordbreak);
  Canvas.Brush.Color := clWhite;
  fcur_x := fcur_x + print_info.box_width;

end;
{
procedure Register;
begin
  RegisterComponents('Samples', [TPrintGrid]);
end;
}


end.

