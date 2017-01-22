unit ugame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, GraphMath;
//GraphMath only for TFLoatPoint, better to write own type

type
  TGame = class
    VPlayer, VDirection, VPlane: TFloatPoint; //vectors
  end;

  TMap = class
    private
      //TODO: dynamic width & height, custom map name & extension
      const
        MapWidth = 10;
        MapHeight = 10;
        MapFileName = 'map.txt';

      type MapArray = array[1..MapWidth,1..MapHeight] of integer;
    public
        var
          Map: MapArray;

        function ReadFromFile: MapArray;
  end;

var
  Game: TGame;
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

Game := TGame.Create;

GameMap := TMap.Create;
GameMap.ReadFromFile;

Game.VPlayer := FloatPoint(5,7);
Game.VDirection := FloatPoint(-1,0);
Game.VPlane := FloatPoint(0,0.66);
end.

