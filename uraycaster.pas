unit uraycaster;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, GraphMath, ugraphic, ugame;

type
  TRaycaster = class
    VPlane: TFloatPoint;
    FrameTime,OldFrameTime: double;
    ScreenWidth,ScreenHeight: integer;
    VCameraX: double;
    procedure PerformRaycast;
  end;

var
  Raycaster: TRaycaster;

implementation

  procedure TRaycaster.PerformRaycast;
  var
    ScreenX,i,LineHeight,DrawStart,DrawEnd: integer;
    RayPos,RayDir, SideDist, DeltaDist: TFloatPoint;
    MapPos,step : TPoint;
    perpWallDist: double;
    hit,side: boolean;//NS or EW side
    LineColor: TColorRGB;
    TempColor: word;
    key: char;
    MoveSpeed, RotSpeed: double;
    OldVDirection, OldVPlane: TFloatPoint;
  begin
    side := false; //hotfix!
    MoveSpeed := 0.1;
    RotSpeed := 0.05;
    for ScreenX := 0 to ScreenWidth do
    begin
      VCameraX := 2*ScreenX/ScreenWidth - 1;
      if (VCameraX = 0) then
      begin
        writeln('ScreenX ',IntToStr(ScreenX));
        writeln('ScreenWidth  ',IntToStr(ScreenWidth));
      end;
      RayPos := Game.VPlayer;
      RayDir.x := Game.VDirection.x + VPlane.x * VCameraX;
      RayDir.y := Game.VDirection.y + VPlane.y * VCameraX;
      MapPos.x := floor(RayPos.x);
      MapPos.y := floor(RayPos.y);
      DeltaDist.x := sqrt(1 + (rayDir.Y * rayDir.Y) / max(rayDir.X * rayDir.X,0.001)); //bad hotfix here
      DeltaDist.y := sqrt(1 + (rayDir.X * rayDir.X) / max(rayDir.Y * rayDir.Y,0.001));
      hit := false;

      if (RayDir.x < 0) then
      begin
        Step.X := -1;
        SideDist.X := (RayPos.X - MapPos.X)*DeltaDist.X;
      end else
      begin
        Step.X := 1;
        SideDist.X := (MapPos.X + 1 - RayPos.X)*DeltaDist.X;
      end;

      if (RayDir.Y < 0) then
      begin
        Step.y := -1;
        SideDist.Y := (RayPos.Y - MapPos.Y)*DeltaDist.Y;
      end else
      begin
        Step.Y := 1;
        SideDist.Y := (MapPos.Y + 1 - RayPos.Y)*DeltaDist.Y;
      end;

      //perform DDA

      while (hit = false) do
      begin
        if (SideDist.X < SideDist.Y) then
        begin
          SideDist.X := SideDist.X + DeltaDist.X;
          MapPos.X := MapPos.X + Step.X;
          side := false;
        end else
        begin
          SideDist.Y := SideDist.Y + DeltaDist.Y;
          MapPos.Y := MapPos.Y + Step.Y;
          side := true;
        end;
        if (GameMap.Map[MapPos.x][MapPos.y] > 0) then hit := true;
      end;

      if (side = false) then
        perpWallDist := (MapPos.X - RayPos.X + (1 - step.X) / 2) / RayDir.X
      else
        perpWallDist := (MapPos.Y - RayPos.Y + (1 - step.Y) / 2) / RayDir.Y;

      LineHeight := floor(ScreenHeight/perpWallDist);
      DrawStart := floor(-LineHeight / 2 + ScreenHeight / 2);
      if (DrawStart < 0) then DrawStart := 0;
      DrawEnd := floor(LineHeight / 2 + ScreenHeight / 2);
      if (drawEnd >= ScreenHeight) then DrawEnd := ScreenHeight - 1;

      case GameMap.Map[MapPos.X][MapPos.Y] of
      1:
        begin
          LineColor:= RGB_Red;
        end;
      end;
      if (side = true) then
      begin
        LineColor := RGB_Maroon;
      end;
      verLine(ScreenX,DrawStart,DrawEnd,LineColor);
      end;
      //key := ReadKey;
      readKeys;
      if keyDown(KEY_UP) then
      begin
        if (GameMap.Map[Round(Game.VPlayer.X+Game.VDirection.X*MoveSpeed)][Round(Game.VPlayer.Y)] = 0) then
          Game.VPlayer.X := Game.VPlayer.X + Game.VDirection.X*MoveSpeed;
        if (GameMap.Map[Round(Game.VPlayer.X)][Round(Game.VPlayer.Y+Game.VDirection.X*MoveSpeed)] = 0) then
          Game.VPlayer.Y := Game.VPlayer.Y + Game.VDirection.Y*MoveSpeed;
      end;
      if keyDown(KEY_DOWN) then
      begin
        if (GameMap.Map[Round(Game.VPlayer.X-Game.VDirection.X*MoveSpeed)][Round(Game.VPlayer.Y)] = 0) then
          Game.VPlayer.X := Game.VPlayer.X - Game.VDirection.X*MoveSpeed;
        if (GameMap.Map[Round(Game.VPlayer.X)][Round(Game.VPlayer.Y-Game.VDirection.X*MoveSpeed)] = 0) then
          Game.VPlayer.Y := Game.VPlayer.Y - Game.VDirection.Y*MoveSpeed;
      end;
      if keyDown(KEY_RIGHT) then
      begin
        OldVDirection.X := Game.VDirection.X;
        Game.VDirection.X := Game.VDirection.X * cos(-rotSpeed) - Game.VDirection.Y * sin(-rotSpeed);
        Game.VDirection.Y := OldVDirection.X * sin(-rotSpeed) + Game.VDirection.Y * cos(-rotSpeed);
        OldVPlane.X := VPlane.X;
        VPlane.X := VPlane.X * cos(-rotSpeed) - VPlane.Y * sin(-rotSpeed);
        VPlane.Y := OldVPlane.X * sin(-rotSpeed) + VPlane.Y * cos(-rotSpeed);
      end;
      if keyDown(KEY_LEFT) then
      begin
        OldVDirection.X := Game.VDirection.X;
        Game.VDirection.X := Game.VDirection.X * cos(rotSpeed) - Game.VDirection.Y * sin(rotSpeed);
        Game.VDirection.Y := OldVDirection.X * sin(rotSpeed) + Game.VDirection.Y * cos(rotSpeed);
        OldVPlane.X := VPlane.X;
        VPlane.X := VPlane.X * cos(rotSpeed) - VPlane.Y * sin(rotSpeed);
        VPlane.Y := OldVPlane.X * sin(rotSpeed) + VPlane.Y * cos(rotSpeed);
      end;
      //ClearDevice;
      redraw;
      cls;
  end;

initialization

  Raycaster := TRaycaster.Create;
  Raycaster.ScreenWidth := 800;
  Raycaster.ScreenHeight:= 600;
  Raycaster.VPlane := FloatPoint(0,0.66);
end.
