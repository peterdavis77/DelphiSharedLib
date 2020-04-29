unit Preview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, VPrinter;

type
  TScale = (s100, s125, s150, s200);
  TPreviewForm = class(TForm)
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    ScrollBox1: TScrollBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Panel2: TPanel;
    Image1: TImage;
    procedure Button7Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }

    fCur_page: integer;
    fPages: integer;
    fScale: TScale;
    procedure redraw;
  public
    { Public declarations }
     fPreviewVP: tVPrinter;
     procedure init(VPrinter:TVprinter);

  end;

var
  PreviewForm: TPreviewForm;

implementation

uses main, PrintGrid;

{$R *.dfm}

procedure TPreviewForm.Button7Click(Sender: TObject);
begin
  close;
end;

procedure TPreviewForm.redraw;
var
  PageHeight, PageWidth, PanelHeight, PanelWidth: integer;
  scale: integer;
  MyRect: TRect;
begin
  PageHeight := fPreviewVp.MetaFile.Height;
  PageWidth := fPreviewVp.MetaFile.Width;
  PanelHeight := ScrollBox1.Height;
  PanelWidth := PanelHeight * PageWidth div PageHeight;
  if PanelWidth > ScrollBox1.Width then
  begin
    PanelWidth := ScrollBox1.Width;
    PanelHeight := PanelWidth * PageHeight div PageWidth;
  end;
  scale := 1000;
  case fScale of
    s100: scale := 100;
    s125: scale := 125;
    s150: scale := 150;
    s200: scale := 200;
  end;

  PanelWidth := PanelWidth * scale div 100;
  PanelHeight := PanelHeight * scale div 100;

  Panel2.Top := 0;
  Panel2.Left := ScrollBox1.Width div 2 - PanelWidth div 2;

  Panel2.Width := PanelWidth;
  Panel2.Height := PanelHeight;
  image1.Width := Panel2.Width;
  image1.Height := panel2.Height;
  image1.Picture.Bitmap.Width := panelWidth;
  image1.Picture.Bitmap.Height := panelHeight;
//  image1.ClientWidth:=panelWidth;
  MyRect := rect(0, 0, panelWidth, PanelHeight);
  image1.Canvas.Rectangle(myrect);
  image1.Canvas.StretchDraw(myrect, fPreviewVp.MetaFile);
  statusBar1.SimpleText := '第' + inttostr(fCur_page) + '页,共' + inttostr(fpages) + '页，放大倍数:' + inttostr(scale) + '%';


end;

procedure TPreviewForm.Button1Click(Sender: TObject);
begin
  if fScale < high(fScale) then
  begin
    inc(fScale);
    redraw;
  end;

end;

procedure TPreviewForm.Button2Click(Sender: TObject);
begin
  if fScale > low(fScale) then
  begin
    dec(fScale);
    redraw;
  end;

end;

procedure TPreviewForm.Button3Click(Sender: TObject);
begin
  fScale := s100;
  redraw;
end;

procedure TPreviewForm.Button4Click(Sender: TObject);
begin
  if fCur_page > 1 then
  begin
    dec(fCur_Page);
    fPreviewVp.RequestPageNumber := fCur_page;
    redraw;
  end
  else
  showmessage('已经是第一页了');
end;

procedure TPreviewForm.Button5Click(Sender: TObject);
begin
  if fCur_page < fPreviewVp.Pages then
  begin
    inc(fCur_page);
    fPreviewVp.RequestPageNumber := fCur_page;
    redraw;
  end
  else
  showmessage('已经是最后一页了');
end;

procedure TPreviewForm.init(VPrinter:TVPrinter);
begin
  fPreviewVP:=VPrinter;
  fCur_page:=1;
  fPages:=fPreviewVP.Pages;
  fScale:=s100;
  fPreviewVP.RequestPageNumber:=1;
  redraw;
end;
end.

