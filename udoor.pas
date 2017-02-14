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
  OpenValue: Single;
  procedure Open;
  procedure CheckTimeout;
  procedure DoorTick;
end;
type PDoor = ^TDoor;

implementation

procedure TDoor.Open;
begin
  if (not Opened) then
  begin
    OpenValue := 0.0;
    TickOpen := GetTicks;
    Opened := true;
  end;
end;

procedure TDoor.CheckTimeout;
begin
  if not Opened then exit;
  if ((GetTicks - TickOpen)/1000) > DOOR_TIMEOUT then
    begin
    Opened := false;
    OpenValue := 1.0;
    end;
end;

procedure TDoor.DoorTick;
begin
  if Opened then
  begin
    if OpenValue < 1 then
    begin
      OpenValue := OpenValue + 0.1;
    end
    else
    begin
      OpenValue := 1.0;
      CheckTimeout;
    end;
  end
  else
  begin
    if OpenValue > 0 then
    begin
      OpenValue := OpenValue - 0.1;
    end
    else
    begin
      OpenValue := 0.0;
    end;
  end;
end;

end.

