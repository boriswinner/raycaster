unit ugame;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, Math, GraphMath, usound;
//GraphMath only for TFLoatPoint, better to write own type

type

  TGame = record
    VPlayer, VDirection: TFloatPoint; //vectors
  end;

var
  Game: TGame;
  LevelNumber: integer;
implementation

initialization

  Game.VPlayer := FloatPoint(5.0,7.0);
  Game.VDirection := FloatPoint(-1.0,0.0);

  LevelNumber := 1;

end.

