unit UGlobalTypes;

interface

uses
  Vcl.Graphics;

type
  TECellType = (ctWall, ctEmpty, ctAinable, ctBox, ctBoxPlace, ctHome);

  TRMove = record
    FromI, FormJ, ToI, ToJ: integer;
  end;

  TAMoveList = array of TRMove;

  TCMap = class
  private
    mapH, mapW: integer;
    map: array of array of set of TECellType;
  public
    procedure LoadMapFromFile(FileName: string);
    procedure CalculateMap;
    function DrawMap: TBitmap;
    function GenerateMoves: TAMoveList;
    function MakeMove(Move: TRMove): TCMap;
    function isEnd: Boolean;
  end;

  TRPosition = record
    PrevInd: Integer;
    Map: TCMap;
  end;

  TCList = class
    Count: integer;
    p: array of TRPosition;
  public
    procedure AddMap(Prev: Integer; Map: TCMap);
    procedure Solve;
  end;

implementation

uses
  UColorImages;

procedure TCMap.LoadMapFromFile(FileName: string);
var
  f: TextFile;
  I: Integer;
  j: Integer;
  t: AnsiChar;
begin
  AssignFile(f, FileName);
  Reset(f);
  Read(f, Self.mapH);
  SetLength(self.map, Self.mapH + 2);
  Readln(f, Self.mapW);
  for I := 0 to Self.mapH + 1 do
    SetLength(Self.map[I], Self.mapW + 2);
  for I := 0 to Self.mapH + 1 do
    for j := 0 to Self.mapW + 1 do
      if (I < 1) or (I > mapH) or (j < 1) or (j > mapW) then
        self.map[I, j] := [ctWall]
      else
        self.map[I, j] := [ctEmpty];
  while not Eof(f) do
  begin
    read(f, I);
    read(f, j);
    read(f, t);
    Readln(f, t);
    case t of
      'H':
        map[I, j] := map[I, j] + [ctHome];
      'I':
        map[I, j] := map[I, j] + [ctAinable];
      'W':
        map[I, j] := map[I, j] + [ctWall];
      'B':
        map[I, j] := map[I, j] + [ctBox];
      'P':
        map[I, j] := map[I, j] + [ctBoxPlace];
    end;
  end;
  CloseFile(f);
  Self.CalculateMap;
  Self.GenerateMoves;
end;

procedure TCMap.CalculateMap;
var
  fl: Boolean;
  i: Integer;
  j: Integer;
begin
  fl := true;
  while fl do
  begin
    fl := False;
    for i := 1 to mapH do
      for j := 1 to mapW do
        if ctAinable in map[i, j] then
        begin
          if (not (ctWall in map[i - 1, j])) and (not (ctBox in map[i - 1, j])) and (not (ctAinable in map[i - 1, j])) then
          begin
            map[i - 1, j] := map[i - 1, j] + [ctAinable];
            fl := True;
          end;
          if (not (ctWall in map[i + 1, j])) and (not (ctBox in map[i + 1, j])) and (not (ctAinable in map[i + 1, j])) then
          begin
            map[i + 1, j] := map[i + 1, j] + [ctAinable];
            fl := True;
          end;
          if (not (ctWall in map[i, j - 1])) and (not (ctBox in map[i, j - 1])) and (not (ctAinable in map[i, j - 1])) then
          begin
            map[i, j - 1] := map[i, j - 1] + [ctAinable];
            fl := True;
          end;
          if (not (ctWall in map[i, j + 1])) and (not (ctBox in map[i, j + 1])) and (not (ctAinable in map[i, j + 1])) then
          begin
            map[i, j + 1] := map[i, j + 1] + [ctAinable];
            fl := True;
          end;
        end;
  end;

end;

function TCMap.DrawMap: TBitmap;
var
  CI: UcolorImages.TCColorImage;
  i: Integer;
  j: Integer;
begin
  CI := TCColorImage.Create;
  CI.Height := mapH;
  CI.Width := mapW;
  for i := 1 to mapH do
    for j := 1 to mapW do
      if ctWall in map[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clBlack
      else if ctBox in map[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clWebBrown
      else if ctBoxPlace in map[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clWebSandyBrown
      else if ctHome in map[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clRed
      else if ctAinable in map[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clGreen
      else
        CI.Pixels[i - 1, j - 1].FullColor := clWhite;
  DrawMap := CI.SaveToBitMap;
end;

function TCMap.GenerateMoves;
var
  m: TAMoveList;
  count: integer;
  I: Integer;
  j: Integer;
begin
  count := 0;
  for I := 1 to mapH do
    for j := 1 to mapW do
      if ctBox in map[I, j] then
      begin
        if (ctAinable in map[I - 1, j]) and ((map[I + 1, j] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I + 1;
          m[count].ToJ := j;
        end;
        if (ctAinable in map[I + 1, j]) and ((map[I - 1, j] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I - 1;
          m[count].ToJ := j;
        end;

        if (ctAinable in map[I, j - 1]) and ((map[I, j + 1] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I;
          m[count].ToJ := j + 1;
        end;
        if (ctAinable in map[I, j + 1]) and ((map[I, j - 1] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I;
          m[count].ToJ := j - 1;
        end;
      end;
  GenerateMoves := m;
end;

function TCMap.MakeMove(Move: TRMove): TCMap;
var
  nm: TCMap;
  i, j: Integer;
begin
  nm := TCMap.Create;
  nm.mapH := Self.mapH;
  SetLength(nm.map, nm.mapH + 2);
  nm.mapW := Self.mapW;
  for i := 0 to nm.mapH + 1 do
    SetLength(nm.map[i], nm.mapW + 2);
  for i := 0 to nm.mapH + 1 do
    for j := 0 to nm.mapW + 1 do
      nm.map[i, j] := self.map[i, j] - [ctAinable];
  nm.map[Move.FromI, Move.FormJ] := nm.map[Move.FromI, Move.FormJ] - [ctBox];
  nm.map[Move.ToI, Move.ToJ] := nm.map[Move.ToI, Move.ToJ] + [ctBox];
  nm.map[Move.FromI, Move.FormJ] := nm.map[Move.FromI, Move.FormJ] + [ctAinable];
  nm.CalculateMap;
  MakeMove := nm;
end;

procedure TCList.AddMap(Prev: Integer; Map: TCMap);
var
  NeedAdd: Boolean;
  fl: Boolean;
  q: Integer;
  i: Integer;
  j: Integer;
begin
  NeedAdd := true;

  for q := 1 to count do
  begin
    fl := True;
    for i := 1 to Self.p[q].Map.mapH do
      for j := 1 to Self.p[q].Map.mapW do
        if Map.map[i, j] <> Self.p[q].Map.map[i, j] then
          fl := False;
    if fl then
      NeedAdd := False;
  end;

  if NeedAdd then
  begin
    Self.Count := Self.Count + 1;
    SetLength(self.p, count + 1);

    Self.p[count].PrevInd := Prev;
    Self.p[count].Map := Map;
  end;
end;

procedure TCList.Solve;
var
  p: integer;
  m: TAMoveList;
  mInd: Integer;
begin
  p := 1;
  while p <= Self.Count do
  begin
    if Self.p[p].Map.isEnd then
     break;
    m := Self.p[p].Map.GenerateMoves;
    for mInd := 1 to Length(m) - 1 do
      self.AddMap(p, Self.p[p].Map.MakeMove(m[mInd]));
    p := p + 1;
  end;

end;

function TCMap.isEnd;
var
  i: Integer;
  j: Integer;
  fl: Boolean;
begin
  fl := true;
  for i := 1 to self.mapH do
    for j := 1 to Self.mapW do
    begin
      if (ctHome in self.map[i, j]) then
        if not (ctAinable in Self.map[i, j]) then
          fl := false;

      if ctBoxPlace in self.map[i, j] then
        if not (ctBox in Self.map[i, j]) then
          fl := false;
    end;

  isEnd := fl;
end;

end.

