unit umap;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, udoor, strutils, udictionary;

type
  IntGrid = array of array of integer;

  TBlock = record
    NSTexture: string;
    EWTexture: string;
    FloorTexture: string;
    CeilTexture: string;
    solid: boolean;
    transparent: boolean;
    function RegisterVariables: TDictionary;
  end;

TMap = record
  private
    const MapFileName = 'map.txt';
  public
    Map: IntGrid;
    Blocks: array of TBlock; //block id is its position in the array
    procedure ReadFromFile;
    function DefineBlock (var AFile: TextFile): TBlock;
    function ReadMap(var AFile: TextFile): IntGrid;
end;

var
  GameMap: TMap;
  Doors  : array of TDoor;

function FindDoor(x,y:UInt32) : PDoor;

implementation

function TBlock.RegisterVariables: TDictionary;
begin
  Result.AddToDict('NSTexture',@NSTexture,1);
  Result.AddToDict('EWTexture',@EWTexture,1);
  Result.AddToDict('FloorTexture',@FloorTexture,1);
  Result.AddToDict('CeilTexture',@CeilTexture,1);
  Result.AddToDict('solid',@solid,2);
  Result.AddToDict('transparent',@transparent,2);
end;
function TMap.DefineBlock (var AFile: TextFile): TBlock;
var
  tDict: TDictionary;
  tname, tvalue,t: string;
begin
  tdict := Result.RegisterVariables;
  readln(AFile,t);
  while (t <> 'end') do
  begin
    tname := (ExtractWord(1,t,[' ']));
    tvalue := (ExtractWord(2,t,[' ']));
    case tDict.ReturnValueType(tname) of
    0: PInteger((tDict.ReturnValue(tname)))^ := StrToInt(tvalue);
    1: PString((tDict.ReturnValue(tname)))^ := tvalue;
    2: PBoolean((tDict.ReturnValue(tname)))^ := StrToBool(tvalue);
    end;
    readln(AFile,t);
  end;
end;

function TMap.ReadMap(var AFile: TextFile): IntGrid;
var
  s: string;
  i,j: integer;
begin
  while (not eof(AFile)) do
  begin
    readln(AFile,s);
    setlength(Result,length(Result)+1);
    setlength(Result[high(Result)],length(s));
    for j := low(s) to high(s) do
    begin
      Result[high(Result),j-1] := StrToIntDef(s[j],0);

      //FIXME
      if Result[high(Result),j-1] = 5 then //Well, the new map format still in progress...
      begin
        setlength(Doors, length(Doors)+1);
        with Doors[high(Doors)] do
        begin
          Opened := false;
          OpenValue := 0.0;
          x := high(Result);
          y := j-1;
        end;
      end;
      //EOFFIXME
    end;
  end;
end;

procedure TMap.ReadFromFile;
var
  fin: TextFile;
  j: integer;
  s: string;
begin
  assign(fin,MapFileName);
  reset(fin);
  while (not eof(fin)) do
  begin
    readln(fin,s);
    if (s='') or (s[1]='#') then continue;
    case ExtractWord(1,s,[' ']) of
      'DEFINE':
        begin
          setlength(Blocks,length(Blocks)+1);
          Blocks[high(Blocks)] := DefineBlock(fin);
        end;
      'MAP':
        begin
          Map :=  ReadMap(fin);
        end;
    end;
  end;
  close(fin);
end;

function FindDoor(x,y:UInt32) : PDoor;
var i: integer;
begin
  Result := nil;
  for i := Low(Doors) to High(Doors) do
  begin
    if (Doors[i].x = x) and (Doors[i].y = y) then
    begin
      Result := @Doors[i];
      Break;
    end;
  end;
end;

initialization

GameMap.ReadFromFile;

end.

