unit Vprinter;

interface

uses
  Windows, Messages, SysUtils, Classes, contnrs, Graphics, printers;

type
  TVprinter = class(TComponent)
  private
    { Private declarations }
    fprint_doc: TObjectList;
    fPageWidth: integer;
    fPageHeight: integer;
    fPageNumber: integer;
    fPrinting: boolean;
    fAborted: boolean;
    fcanvas: tMetaFileCanvas;
    fMetaFile : TMetafile;
    fRequestPageNumber:integer;

    procedure SetRequestPageNumber(PN:integer);
    Function GetPages:integer;
  protected
    { Protected declarations }
  public
    { Public declarations }

    constructor create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure BeginDoc;
    procedure EndDoc;
    procedure NewPage;
    procedure Abort;
    procedure Refresh;

  published
    { Published declarations }
    property canvas: tMetaFileCanvas read fCanvas write fCanvas;
    property PageWidth: integer read fPageWidth;
    property PageHeight: integer read fPageHeight;
    property PageNumber: integer read fPageNumber;
    property Printing: boolean read fPrinting;
    property Aborted: boolean read fAborted;
    property RequestPageNumber:integer read fRequestPageNumber write SetRequestPageNumber;
    property MetaFile:TMetaFile read fMetaFile;
    property Pages: integer read GetPages;
  end;
{
procedure Register;
}
implementation

uses Preview;

procedure TVPrinter.Refresh;
begin
  if fPrinting then
    raise Exception.Create('正在打印中');
  fprinting := false;
  fAborted := false;
  fPageHeight := printer.PageHeight;
  fPageWidth := printer.PageWidth;
  fPageNumber := 0;
  fRequestPageNumber:=0;
end;

constructor TVPrinter.create(AOwner: TComponent);
begin
  inherited;
  fprinting := false;
  fAborted := false;
  fPageHeight := printer.PageHeight;
  fPageWidth := printer.PageWidth;
  fPageNumber := 0;
  fPrint_doc:=tObjectList.Create;
end;

destructor TVPrinter.destroy;
var
  i: integer;
begin
{
  if assigned(fCanvas) then
    fCanvas.free;   }
  for i := 0 to fPrint_Doc.Count - 1 do
    if Assigned(fPrint_Doc[i]) then fprint_doc[i].Free;
//  fPrint_doc.Free;
  inherited;
end;

procedure TVPrinter.BeginDoc;
var
  i:integer;
begin
  if fPrinting then
    raise exception.Create('正在打印');
  if assigned(fCanvas) then fCanvas.free;
  for i := 0 to fPrint_Doc.Count - 1 do
    if Assigned(fPrint_Doc[i]) then fprint_doc[i].Free;
  fPrinting:=true;
  fprint_doc.Add(tMetaFile.Create);
  fPageNumber:=1;
  fCanvas:=tMetaFileCanvas.Create(TMetaFile(fPrint_doc[fPageNumber-1]),printer.Handle);
end;

procedure TVPrinter.NewPage;
begin
  fCanvas.Free;
  fPrint_doc.Add(tMetaFile.Create);
  inc(fPageNumber);
  fCanvas:=TMetaFileCanvas.Create(TMetaFile(fPrint_doc[fPageNumber-1]),printer.Handle);
end;

procedure TVPrinter.EndDoc;
begin
    fCanvas.Free;
    fPrinting:=false;
end;

procedure TVPrinter.Abort;
var
  i:integer;
begin
  if NOT Printing then exit;
  if assigned(fCanvas) then fCanvas.free;
  for i := 0 to fPrint_Doc.Count - 1 do
    if Assigned(fPrint_Doc[i]) then fprint_doc[i].Free;
  fPrinting:=false;
  fAborted:=true;

end;

Procedure TVPrinter.SetRequestPageNumber(PN:integer);
begin
  if (PN<1) or (PN>fPageNumber) then
    raise Exception.Create('页码超范围');
  fRequestPageNumber:=PN;
  fMetaFile:=tMetaFile(fPrint_doc[PN-1]);
end;

Function TVPrinter.GetPages:integer;
begin
  result:=fPrint_doc.Count;
end;
{procedure Register;
begin
  RegisterComponents('Samples', [TVprinter]);
end;
}
end.

