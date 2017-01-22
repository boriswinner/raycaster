unit uraycaster;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, GraphMath, ugame;

type
  TRaycaster = class
    VPlane: TFloatPoint;
    FrameTime,OldFrameTime: double;
    ScreenWidth,ScreenHeight: integer;
    CameraX: double;
  end;

var
  Raycaster: TRaycaster;

implementation


initialization

Raycaster := TRaycaster.Create;
Raycaster.VPlane := FloatPoint(0,0.66);

end.
