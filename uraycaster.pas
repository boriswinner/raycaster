unit uraycaster;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, Math, GraphMath, ugraphic, utexture, ugame, udoor;

type
  TRaycaster = record
    private
      perpWallDist: double;
      MapPos: TPoint;
      side: boolean;
      Time,OldTime, FrameTime, WallX: double;
    public
      VPlane: TFloatPoint;
      ScreenWidth,ScreenHeight: integer;

      //VCameraX: double;
      procedure CalculateStripe(AScreenX: integer);
      procedure DrawStripe(AScreenX: integer);
      procedure DrawFrame;
      procedure DrawHud;
      procedure DrawFPS;
      procedure HandleInput;//move it to another place
  end;

var
  Raycaster : TRaycaster;
  Textures  : array[1..10] of TTexture; //TODO dynamic loading
  //Doors     : array of TDoor;
procedure InitTextures;

implementation

  procedure InitTextures;
  begin
    Textures[1] := LoadTexture(renderer, 'greystone.bmp', false, true);
    Textures[2] := LoadTexture(renderer, 'colorstone.bmp', false, true);
    Textures[3] := LoadTexture(renderer, 'eagle.bmp', false, true);
    Textures[4] := LoadTexture(renderer, 'reallybig.bmp', false, true);
    Textures[8] := LoadTexture(renderer, 'redbrick.bmp', false, true);
    Textures[9] := LoadTexture(renderer, 'bigtexture.bmp', false, true);
  end;

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


    if (RayDir.Y = 0) then RayDir.Y := 0.000001; //shitty hotfix!

    DeltaDist.y := sqrt(1 + (rayDir.X * rayDir.X) / (rayDir.Y * rayDir.Y));
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

    //calculate value of wallX in range 0.0 - 1.0
    //where exactly the wall was hit
    if side then
      WallX := RayPos.X + ((MapPos.y - RayPos.Y + (1 - Step.y) / 2) / RayDir.Y) * RayDir.X
    else
      WallX := RayPos.Y + ((MapPos.x - RayPos.X + (1 - Step.x) / 2) / RayDir.X) * RayDir.Y;
    WallX := WallX - floor(WallX);
  end;

  procedure TRaycaster.DrawStripe(AScreenX: integer);
  var
    WallColor: TColorRGB;
    LineHeight,DrawStart,drawEnd, TexIndex: integer;
  begin
    LineHeight := floor(ScreenHeight/perpWallDist);
    DrawStart := floor(-LineHeight / 2 + ScreenHeight / 2);
    DrawEnd := floor(LineHeight / 2 + ScreenHeight / 2);

    WallColor := RGB_Magenta; //default texture in case number doesn't exist
    if (side) then WallColor := WallColor / 2;
    TexIndex := GameMap.Map[MapPos.X][MapPos.Y];
    if (TextureExists(@Textures[TexIndex])) then
    begin
      if (side) then
         SetTextureColorMod(@Textures[TexIndex], 127, 127, 127);
      DrawTexStripe(AScreenX,DrawStart,DrawEnd,WallX,@Textures[TexIndex]);
      SetTextureColorMod(@Textures[TexIndex], 255, 255, 255)
    end
    else
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
    DrawHud;
    DrawFps;
    redraw;
    cls;
    HandleInput;
  end;

  procedure TRaycaster.DrawHud;
  begin
    //TODO HUD
  end;

  procedure TRaycaster.DrawFPS;
  begin
    writeText('by t1meshift & boriswinner',0,0);

    OldTime := Time;
    Time := getTicks;
    FrameTime := (time - oldTime) / 1000;
    writeText(FloatToStr(floor(1/FrameTime*100)/100)+' FPS',0,CHAR_SIZE+1);
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
  Raycaster.ScreenWidth := 1024;
  Raycaster.ScreenHeight:= 768;
  Raycaster.VPlane := FloatPoint(0.0,0.66);
  Raycaster.Time := 0;

end.
