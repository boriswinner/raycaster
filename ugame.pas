unit ugame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, GraphMath;
//GraphMath only for TFLoatPoint, better to write own type

type
  TGame = class
    VPlayer, VDirection, VPlane: TFloatPoint;//vectors
  end;

var
  Game: TGame;
implementation

initialization

Game := TGame.Create;
Game.VPlayer := FloatPoint(5,7);
Game.VDirection := FloatPoint(-1,0);
Game.VPlane := FloatPoint(0,0.66);
end.

