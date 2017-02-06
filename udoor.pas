unit udoor;

{$mode objfpc}{$H+}{$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, ugraphic;

const DOOR_TIMEOUT = 5; //in seconds

type TDoor = record
  Opened: boolean;
  TickOpen: UInt64;
  x,y: UInt32;
  procedure Open;
  procedure CheckTimeout;
end;

implementation

procedure TDoor.Open;
begin
  Opened := true;
  TickOpen := GetTicks;
end;

procedure TDoor.CheckTimeout;
begin
  if not Opened then exit;
  if ((GetTicks - TickOpen)/1000) > DOOR_TIMEOUT then
    Opened := false;
end;

end.

