unit UformMain;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls;

type
  TForm1 = class(TForm)
    btnLoadMap: TButton;
    img1: TImage;
    mmo1: TMemo;
    procedure btnLoadMapClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses
  UGlobalTypes;

procedure TForm1.btnLoadMapClick(Sender: TObject);
var
  map: UGlobalTypes.TCMap;
  l: TCList;
  i: Integer;
  k: integer;
begin
  map := TCMap.Create;
  map.LoadMapFromFile('map1.txt');
  img1.Picture.Assign(map.DrawMap);
  l := TCList.Create;
  l.AddMap(0, map);
  l.Solve;
  for i := 1 to l.Count do
    if l.p[i].map.isEnd then
      Break;

  while l.p[i].PrevInd <> 0 do
  begin
    mmo1.LineS.add(IntToStr(i));
    i := l.p[i].PrevInd;
  end;
  k := 0;
  img1.Picture.Assign(l.p[1].map.DrawMap);
  img1.Picture.SaveToFile(IntToStr(k) + '.jpg');
  for i := mmo1.Lines.Count - 1 downto 0 do
  begin
    k := k + 1;
    Form1.Repaint;
    Sleep(3000);
    Application.ProcessMessages;
    img1.Picture.Assign(l.p[strtoint(mmo1.Lines[i])].map.DrawMap);
    img1.Picture.SaveToFile(IntToStr(k) + '.jpg');
  end;

end;

end.

