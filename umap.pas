unit umap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  MapWidth = 10;
  MapHeight = 10;
  MapFileName = 'map.txt';

type
  MapArray = array[1..MapWidth,1..MapHeight] of integer;

  TMap = class
    Map: MapArray;
    function ReadFromFile: MapArray;
  end;

var
  GameMap: TMap;
implementation

function TMap.ReadFromFile: MapArray;
var
  fin: text;
  i,j: integer;
  s: string;
begin
  assign(fin,MapFileName);
  reset(fin);
  for i := 1 to MapHeight do
  begin
    readln(fin,s);
    for j := 1 to MapWidth do
    begin
      Result[i,j] := StrToInt(s[j]);
    end;
  end;
end;

initialization

GameMap := TMap.Create;
GameMap.ReadFromFile;
end.

