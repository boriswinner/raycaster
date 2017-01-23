unit ugame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, GraphMath;
//GraphMath only for TFLoatPoint, better to write own type

type
  IntGrid = array of array of integer;

  TGame = class
    VPlayer, VDirection: TFloatPoint; //vectors
  end;

  TMap = class
    private
      const MapFileName = 'map.txt';
    public
      Map: IntGrid;
      function ReadFromFile: IntGrid;
  end;

var
  Game: TGame;
  GameMap: TMap;
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
        Result[high(Result),j-1] := StrToIntDef(s[j],0);
    end;
    close(fin);
  end;
initialization

  Game := TGame.Create;

  GameMap := TMap.Create;
  GameMap.Map := GameMap.ReadFromFile;

  Game.VPlayer := FloatPoint(5,7);
  Game.VDirection := FloatPoint(-1,0);
end.

