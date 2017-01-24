unit uraycaster;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, Math, GraphMath, ugraphic, ugame;

type
  TRaycaster = record
    private
      perpWallDist: double;
      MapPos: TPoint;
      side: boolean;
      Time,OldTime, FrameTime: double;
    public
      VPlane: TFloatPoint;
      ScreenWidth,ScreenHeight: integer;

      //VCameraX: double;
      procedure CalculateStripe(AScreenX: integer);
      procedure DrawStripe(AScreenX: integer);
      procedure DrawFrame;
      procedure DrawFPS;
      procedure HandleInput;//move it to another place
  end;

var
  Raycaster: TRaycaster;

implementation

  procedure TRaycaster.CalculateStripe(AScreenX: integer);
  var
    CameraX: double;
    RayPos,RayDir,DeltaDist,SideDist: TFloatPoint;
    Step: TPoint;
    hit: boolean;
  begin
    CameraX := 2.0*double(AScreenX)/double(ScreenWidth) - 1.0;
    RayPos := Game.VPlayer;
    RayDir.x := Game.VDirection.x + VPlane.x * CameraX;
    RayDir.y := Game.VDirection.y + VPlane.y * CameraX;
    MapPos.x := floor(RayPos.x);
    MapPos.y := floor(RayPos.y);
    DeltaDist.x := sqrt(1 + (rayDir.Y * rayDir.Y) / (rayDir.X * rayDir.X));
    //shitty hotfix!
    if (RayDir.Y = 0) then begin
    DeltaDist.y := 1; RayDir.Y := 0.00001 end else
    DeltaDist.y := sqrt(1 + (rayDir.X * rayDir.X) / (rayDir.Y * rayDir.Y));
    //end of hotfix
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
        SideDist.X += DeltaDist.X;
        MapPos.X += Step.X;
        side := false;
      end else
      begin
        SideDist.Y += DeltaDist.Y;
        MapPos.Y  += Step.Y;
        side := true;
      end;
      if (GameMap.Map[MapPos.x][MapPos.y] > 0) then hit := true;
    end;

    if (side = false) then
      perpWallDist := (MapPos.X - RayPos.X + (1 - step.X) / 2) / RayDir.X
    else
      perpWallDist := (MapPos.Y - RayPos.Y + (1 - step.Y) / 2) / RayDir.Y;
  end;

  procedure TRaycaster.DrawStripe(AScreenX: integer);
  var
    WallColor: TColorRGB;
    LineHeight,DrawStart,drawEnd: integer;
  begin
    LineHeight := floor(ScreenHeight/perpWallDist);
    DrawStart := max(0,floor(-LineHeight / 2 + ScreenHeight / 2));
    DrawEnd := min(ScreenHeight - 1,floor(LineHeight / 2 + ScreenHeight / 2));

    case GameMap.Map[MapPos.X][MapPos.Y] of
      1: WallColor := RGB_Red;
      2: WallColor := RGB_Green;
      3: WallColor := RGB_Teal;
    end;
    if (side) then WallColor := WallColor / 2;
    verLine(AScreenX,DrawStart,DrawEnd,WallColor);
  end;

  procedure TRaycaster.DrawFrame;
  var
    ScreenX: integer;
  begin
    drawRect(0, 0, ScreenWidth, ScreenHeight div 2, RGB_Gray); // ceiling
    drawRect(0, ScreenHeight div 2, ScreenWidth, ScreenHeight, RGB_Grey); //floor
    for ScreenX := 0 to ScreenWidth do
    begin
      CalculateStripe(ScreenX);
      DrawStripe(ScreenX);
    end;
    DrawFps;
    redraw;
    cls;
    HandleInput;
  end;

  procedure TRaycaster.DrawFPS;
  begin
    writeText('Raycaster v.0.2 by t1meshift & boriswinner',0,0);
    writeText('Graphics by t1meshift',0,CHAR_SIZE+1);

    OldTime := Time;
    Time := getTicks;
    FrameTime := (time - oldTime) / 1000;
    writeText('FPS: '+FloatToStr(1/FrameTime),0,2*CHAR_SIZE+1);
  end;

  procedure TRaycaster.HandleInput;
  var
    MoveSpeed,RotSpeed: double;
    OldVDirection,OldVPlane: TFloatPoint;
  begin
    MoveSpeed := FrameTime*7;
    RotSpeed := FrameTime*3;

    readKeys;
    if keyDown(KEY_UP) then
    begin
      if (GameMap.Map[Floor(Game.VPlayer.X+Game.VDirection.X*MoveSpeed)][Floor(Game.VPlayer.Y)] = 0) then
        Game.VPlayer.X += Game.VDirection.X*MoveSpeed;
      if (GameMap.Map[Floor(Game.VPlayer.X)][Floor(Game.VPlayer.Y+Game.VDirection.Y*MoveSpeed)] = 0) then
        Game.VPlayer.Y += Game.VDirection.Y*MoveSpeed;
    end;
    if keyDown(KEY_DOWN) then
    begin
      if (GameMap.Map[Floor(Game.VPlayer.X-Game.VDirection.X*MoveSpeed)][Floor(Game.VPlayer.Y)] = 0) then
        Game.VPlayer.X -= Game.VDirection.X*MoveSpeed;
      if (GameMap.Map[Floor(Game.VPlayer.X)][Floor(Game.VPlayer.Y-Game.VDirection.Y*MoveSpeed)] = 0) then
        Game.VPlayer.Y -= Game.VDirection.Y*MoveSpeed;
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
  end;

initialization
  Raycaster.ScreenWidth := 800;
  Raycaster.ScreenHeight:= 600;
  Raycaster.VPlane := FloatPoint(0.0,0.66);
  Raycaster.Time := 0;
end.
