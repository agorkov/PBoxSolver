unit UGlobalTypes;

interface

uses
  Graphics;

type
  TECellType = (ctWall, ctEmpty, ctAinable, ctBox, ctBoxPlace, ctHome);

  TRMove = record
    FromI, FormJ, ToI, ToJ: Integer;
  end;

  TAMoveList = array of TRMove;

  TCMap = class
  private
    FieldH, FieldW: Integer;
    Field: array of array of set of TECellType;
  public
    procedure SetMapSize;
    procedure LoadMapFromFile(FileName: string);
    procedure CalculateMap;
    function DrawMap: TBitmap;
    function GenerateMoves: TAMoveList;
    function MakeMove(Move: TRMove): TCMap;
    var
      isSolved: Boolean;
  end;

  TRPosition = record
    PrevInd: Integer;
    map: TCMap;
  end;

  TCList = class
    Count: Integer;
    p: array of TRPosition;
  public
    procedure AddMap(Prev: Integer; map: TCMap);
    procedure Solve;
  end;

implementation

uses
  UColorImages;

procedure TCMap.SetMapSize;
var
  i, j: Integer;
begin
  SetLength(Self.Field, Self.FieldH + 2);
  for i := 0 to Self.FieldH + 1 do
    SetLength(Self.Field[i], Self.FieldW + 2);
end;

procedure TCMap.LoadMapFromFile(FileName: string);
var
  f: TextFile;
  I: Integer;
  j: Integer;
  t: AnsiChar;
begin
  AssignFile(f, FileName);
  Reset(f);
  Read(f, Self.FieldH);
  Readln(f, Self.FieldW);
  Self.SetMapSize();
  for I := 0 to Self.FieldH + 1 do
    for j := 0 to Self.FieldW + 1 do
      if (I < 1) or (I > FieldH) or (j < 1) or (j > FieldW) then
        Self.Field[I, j] := [ctWall]
      else
        Self.Field[I, j] := [ctEmpty];
  while not Eof(f) do
  begin
    Read(f, I);
    Read(f, j);
    Read(f, t);
    Readln(f, t);
    case t of
      'H':
        Field[I, j] := Field[I, j] + [ctHome];
      'I':
        Field[I, j] := Field[I, j] + [ctAinable];
      'W':
        Field[I, j] := Field[I, j] + [ctWall];
      'B':
        Field[I, j] := Field[I, j] + [ctBox];
      'P':
        Field[I, j] := Field[I, j] + [ctBoxPlace];
    end;
  end;
  CloseFile(f);
  Self.isSolved := False;
  Self.CalculateMap;
  Self.GenerateMoves;
end;

procedure TCMap.CalculateMap;
var
  fl: Boolean;
  i: Integer;
  j: Integer;
  t: set of TECellType;
begin
  fl := True;
  t := [ctWall, ctBox, ctAinable];
  while fl do
  begin
    fl := False;
    for i := 1 to FieldH do
      for j := 1 to FieldW do
        if ctAinable in Field[i, j] then
        begin
          if t * Field[i - 1, j] = [] then
          begin
            Field[i - 1, j] := Field[i - 1, j] + [ctAinable];
            fl := True;
          end;
          if t * Field[i + 1, j] = [] then
          begin
            Field[i + 1, j] := Field[i + 1, j] + [ctAinable];
            fl := True;
          end;
          if t * Field[i, j - 1] = [] then
          begin
            Field[i, j - 1] := Field[i, j - 1] + [ctAinable];
            fl := True;
          end;
          if t * Field[i, j + 1] = [] then
          begin
            Field[i, j + 1] := Field[i, j + 1] + [ctAinable];
            fl := True;
          end;
        end;
  end;
end;

function TCMap.DrawMap: TBitmap;
var
  CI: UColorImages.TCColorImage;
  i: Integer;
  j: Integer;
begin
  CI := TCColorImage.Create;
  CI.Height := FieldH;
  CI.Width := FieldW;
  for i := 1 to FieldH do
    for j := 1 to FieldW do
      if ctWall in Field[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clBlack
      else if ctBox in Field[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clWebBrown
      else if ctBoxPlace in Field[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clWebSandyBrown
      else if ctHome in Field[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clRed
      else if ctAinable in Field[i, j] then
        CI.Pixels[i - 1, j - 1].FullColor := clGreen
      else
        CI.Pixels[i - 1, j - 1].FullColor := clWhite;
  DrawMap := CI.SaveToBitMap;
end;

function TCMap.GenerateMoves;
var
  m: TAMoveList;
  count: Integer;
  I: Integer;
  j: Integer;
begin
  count := 0;
  for I := 1 to FieldH do
    for j := 1 to FieldW do
      if ctBox in Field[I, j] then
      begin
        if (ctAinable in Field[I - 1, j]) and ((Field[I + 1, j] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I + 1;
          m[count].ToJ := j;
        end;
        if (ctAinable in Field[I + 1, j]) and ((Field[I - 1, j] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I - 1;
          m[count].ToJ := j;
        end;

        if (ctAinable in Field[I, j - 1]) and ((Field[I, j + 1] * [ctBox, ctWall, ctHome]) = []) then
        begin
          count := count + 1;
          SetLength(m, count + 1);
          m[count].FromI := I;
          m[count].FormJ := j;
          m[count].ToI := I;
          m[count].ToJ := j + 1;
        end;
        if (ctAinable in Field[I, j + 1]) and ((Field[I, j - 1] * [ctBox, ctWall, ctHome]) = []) then
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
  nm.FieldH := Self.FieldH;
  nm.FieldW := Self.FieldW;
  nm.SetMapSize;
  for i := 0 to nm.FieldH + 1 do
    for j := 0 to nm.FieldW + 1 do
      nm.Field[i, j] := Self.Field[i, j] - [ctAinable];

  nm.Field[Move.FromI, Move.FormJ] := nm.Field[Move.FromI, Move.FormJ] - [ctBox];
  nm.Field[Move.ToI, Move.ToJ] := nm.Field[Move.ToI, Move.ToJ] + [ctBox];
  nm.Field[Move.FromI, Move.FormJ] := nm.Field[Move.FromI, Move.FormJ] + [ctAinable];

  nm.CalculateMap;

  if [ctBoxPlace] * nm.Field[Move.ToI, Move.ToJ] = [] then
    nm.isSolved := False
  else
  begin
    nm.isSolved := True;
    for i := 1 to Self.FieldH do
      for j := 1 to Self.FieldW do
      begin
        if (ctHome in nm.Field[i, j]) then
          if not (ctAinable in nm.Field[i, j]) then
            nm.isSolved := False;

        if ctBoxPlace in nm.Field[i, j] then
          if not (ctBox in nm.Field[i, j]) then
            nm.isSolved := False;
      end;
  end;

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
  NeedAdd := True;

  for q := 1 to count do
  begin
    fl := True;
    for i := 1 to Self.p[q].Map.FieldH do
      for j := 1 to Self.p[q].Map.FieldW do
        if Map.Field[i, j] <> Self.p[q].Map.Field[i, j] then
          fl := False;
    if fl then
      NeedAdd := False;
  end;

  if NeedAdd then
  begin
    Self.Count := Self.Count + 1;
    SetLength(Self.p, count + 1);

    Self.p[count].PrevInd := Prev;
    Self.p[count].Map := Map;
  end;
end;

procedure TCList.Solve;
var
  p: Integer;
  m: TAMoveList;
  mInd: Integer;
begin
  p := 1;
  while p <= Self.Count do
  begin
    if Self.p[p].map.isSolved then
      Break;
    m := Self.p[p].map.GenerateMoves;
    for mInd := 1 to Length(m) - 1 do
      Self.AddMap(p, Self.p[p].map.MakeMove(m[mInd]));
    p := p + 1;
  end;

end;

end.

