unit umap;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, udoor;

type
  IntGrid = array of array of integer;

TMap = record
  private
    const MapFileName = 'map.txt';
  public
    Map: IntGrid;
    function ReadFromFile: IntGrid;
end;

var
  GameMap: TMap;
  Doors  : array of TDoor;

function FindDoor(x,y:UInt32) : PDoor;

implementation

function TMap.ReadFromFile: IntGrid;
var
  fin: text;
  j: integer;
  s: string;
begin
  assign(fin,MapFileName);
  reset(fin);
  while (not eof(fin)) do
  begin
    setlength(Result,length(Result)+1);
    readln(fin,s);
    setlength(Result[high(Result)],length(s));
    for j := low(s) to high(s) do
    begin
      Result[high(Result),j-1] := StrToIntDef(s[j],0);
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
    end;
  end;
  close(fin);
end;

function FindDoor(x,y:UInt32) : PDoor;
var i: UInt32;
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

GameMap.Map := GameMap.ReadFromFile;

end.

