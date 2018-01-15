unit uraycaster;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, Math, GraphMath, uconfiguration, ugraphic, utexture, ugame,
  udoor, umap;

//you can increase or reduce this value. affects on performance.
//but you know, i don't think 64 won't be enough.
const STACK_LOAD_MAX = 64;
type
  RenderInfo = record
    CPerpWallDist, CWallX: double;
    CMapPos: TPoint;
    CSide: boolean;
    Sprite: boolean;
  end;
type
  TRaycaster = record
    private
      perpWallDist: double;
      MapPos: TPoint;
      side: boolean;
      Time,OldTime, FrameTime, WallX: double;
      RenderStack: array[0..STACK_LOAD_MAX+1] of RenderInfo;
      StackLoad: UInt8;
    public
      FOV : Int16;
      VPlane: TFloatPoint;

      //VCameraX: double;
      procedure CalculateStripe(AScreenX: integer);
     // procedure DrawFloorAndCeil(AScreenX: integer);
      procedure DrawStripe(AScreenX: integer);
      procedure DrawFrame;
      procedure DrawHud;
      procedure DrawFPS;
      procedure HandleInput;//move it to another place
  end;


var
  Raycaster : TRaycaster;
  Textures  : array[1..10000000] of TTexture; //TODO dynamic loading
  SpriteTextures: array[1..1000] of TTexture;
  DoorToOpen: TPoint;
  DoorOpened: boolean;

procedure InitTextures;
procedure HandleDoors;

implementation

  procedure InitTextures;
  var
    b: TBlock;
    s: TSprite;
  begin
    //TODO Load textures from special list
    //loading manually for now

    //Test setting for first block
    //MsgBox(GameMap.Blocks[0].NSTexture);

    for b in GameMap.Blocks do
    begin
      Textures[b.ID] := LoadTexture(renderer, b.NSTexture, b.EWTexture,
        b.transparent, b.solid);
    end;
    for s in GameMap.Sprites do
    begin
      SpriteTextures[s.ID] := LoadTexture(renderer, s.texture, true, s.solid);
    end;

    // LoadTexture(renderer, 'greystone.bmp', false, true);
    Textures[2] := LoadTexture(renderer, 'colorstone.bmp', false, true);
    Textures[3] := LoadTexture(renderer, 'eagle.bmp', false, true);
    Textures[4] := LoadTexture(renderer, 'reallybig.bmp', false, true);
    //Textures[5] := LoadTexture(renderer, 'door.bmp', 'door2_side.bmp', true, false);
    Textures[6] := LoadTexture(renderer, 'fence.bmp', true, false);
    Textures[7] := LoadTexture(renderer, 'test.bmp', true, false);
    Textures[8] := LoadTexture(renderer, 'redbrick.bmp', false, true);
  end;

  //Doing ray casting calculations there.
  procedure TRaycaster.CalculateStripe(AScreenX: integer);
  var
    CameraX: double;
    RayPos, RayDir, DeltaDist, SideDist: TFloatPoint;
    Step: TPoint;
    hit: boolean;
    CurrSprite: PSprite;
  begin
    // Render stack elements count.
    StackLoad   := 0;
    // X coordinate in camera space
    CameraX     := 2.0*double(AScreenX)/double(Config.ScreenWidth) - 1.0;
    // Starting point of ray
    RayPos      := Game.VPlayer;
    RayDir.x    := Game.VDirection.x + VPlane.x * CameraX; // Direction of ray (X)
    RayDir.y    := Game.VDirection.y + VPlane.y * CameraX; // Direction of ray (Y)
    // Which box of the map we're in
    MapPos.x    := floor(RayPos.x);
    MapPos.y    := floor(RayPos.y);
    DeltaDist.x := sqrt(1 + (rayDir.Y * rayDir.Y) / (rayDir.X * rayDir.X));

    //prevent division by zero!
    if (RayDir.Y = 0) then RayDir.Y := 0.000001;

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
      // checking on map borders
      if ((MapPos.x > 0) and (MapPos.x < Length(GameMap.Map)-1) and (MapPos.y > 0) and (MapPos.y < Length(GameMap.Map[MapPos.x])-1)) then
      begin
        CurrSprite := GameMap.FindSprite(MapPos.x, MapPos.y);
        if (CurrSprite <> nil) and TextureExists(@SpriteTextures[CurrSprite^.ID]) then
        begin
          if (StackLoad < STACK_LOAD_MAX) then
          begin
            inc(StackLoad);
            RenderStack[StackLoad].Sprite := true;
            //doing calculations for stack elems
            RenderStack[StackLoad].CMapPos.X := MapPos.X;
            RenderStack[StackLoad].CMapPos.Y := MapPos.Y;
            RenderStack[StackLoad].CSide := side;

            // calculating perpWallDist
            RenderStack[StackLoad].CPerpWallDist := sqrt(
              power(Game.VPlayer.X - CurrSprite^.x - 0.45*Sign(RayDir.x), 2) +
              power(Game.VPlayer.Y - CurrSprite^.Y - 0.45*Sign(RayDir.Y), 2)
            );

            // and WallX too
            if RenderStack[StackLoad].CSide then
              RenderStack[StackLoad].CWallX := RayPos.X + ((MapPos.y - RayPos.Y + (1 - Step.y) / 2) / RayDir.Y) * RayDir.X
            else
              RenderStack[StackLoad].CWallX := RayPos.Y + ((MapPos.x - RayPos.X + (1 - Step.x) / 2) / RayDir.X) * RayDir.Y;

            RenderStack[StackLoad].CWallX := RenderStack[StackLoad].CWallX - floor(RenderStack[StackLoad].CWallX);
          end
          else
            hit := true;
        end;
        // if we hit a wall
        if (GameMap.Map[MapPos.x][MapPos.y] > 0) then
        begin
          // check if it's a texture and it supports transparency
          if ( TextureExists(@Textures[GameMap.Map[MapPos.x][MapPos.y]]) and (Textures[GameMap.Map[MapPos.x][MapPos.y]].Transparent = true)) then
          begin
            //if it is, then we check on stack bounds
            if (StackLoad < STACK_LOAD_MAX) then
            begin
              inc(StackLoad);

              RenderStack[StackLoad].Sprite := false;
              //doing calculations for stack elems
              RenderStack[StackLoad].CMapPos.X := MapPos.X;
              RenderStack[StackLoad].CMapPos.Y := MapPos.Y;
              RenderStack[StackLoad].CSide := side;

              // calculating perpWallDist
              if (RenderStack[StackLoad].CSide = false) then
                RenderStack[StackLoad].CPerpWallDist := (MapPos.X - RayPos.X + (1 - step.X) / 2) / RayDir.X
              else
                RenderStack[StackLoad].CPerpWallDist := (MapPos.Y - RayPos.Y + (1 - step.Y) / 2) / RayDir.Y;

              // and WallX too
              if RenderStack[StackLoad].CSide then
                RenderStack[StackLoad].CWallX := RayPos.X + ((MapPos.y - RayPos.Y + (1 - Step.y) / 2) / RayDir.Y) * RayDir.X
              else
                RenderStack[StackLoad].CWallX := RayPos.Y + ((MapPos.x - RayPos.X + (1 - Step.x) / 2) / RayDir.X) * RayDir.Y;

              RenderStack[StackLoad].CWallX := RenderStack[StackLoad].CWallX - floor(RenderStack[StackLoad].CWallX);

              // And now we must render the "invisible" side of our wall
              inc(StackLoad);
              RenderStack[StackLoad].CMapPos.X := MapPos.X; // they are the same
              RenderStack[StackLoad].CMapPos.Y := MapPos.Y; // because we draw the same texture

              // but here come the differences
              if (SideDist.X < SideDist.Y) then
              begin
                RenderStack[StackLoad].CSide := false;
                RenderStack[StackLoad].CPerpWallDist := ( (MapPos.X + Step.X) - RayPos.X + (1 - step.X) / 2) / RayDir.X;
                RenderStack[StackLoad].CWallX := RayPos.Y + (( (MapPos.X + Step.X) - RayPos.X + (1 - Step.X) / 2) / RayDir.X) * RayDir.Y;
              end else
              begin
                RenderStack[StackLoad].CSide := true;
                RenderStack[StackLoad].CPerpWallDist := ( (MapPos.Y + Step.Y) - RayPos.Y + (1 - step.Y) / 2) / RayDir.Y;
                RenderStack[StackLoad].CWallX := RayPos.X + (( (MapPos.Y + Step.Y) - RayPos.Y + (1 - Step.Y) / 2) / RayDir.Y) * RayDir.X;
              end;
              RenderStack[StackLoad].CWallX := RenderStack[StackLoad].CWallX - floor(RenderStack[StackLoad].CWallX);

            end;
          end
          else
            hit := true;
        end;
      end
      else
      begin
        hit := true;
      end;
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
    LineHeight,DrawStart,drawEnd, TexIndex, i, DrawEndPrev, DrawStartPrev: integer;
    CurrDoor : PDoor;
    CurrSprite: PSprite;
  begin
    {$IFOPT D+}
    // DEBUG INFO
    // Dist from crosshair to wall
    if (AScreenX = Config.ScreenWidth div 2) then
      writeln('WallDist: ',perpWallDist:0:5);
    {$ENDIF}

    //to prevent opening doors from far distances
    if (FindDoor(RenderStack[StackLoad].CMapPos.X, RenderStack[StackLoad].CMapPos.Y) <> nil) and (RenderStack[StackLoad].CPerpWallDist < 1.2) then
    begin
      DoorToOpen := RenderStack[StackLoad].CMapPos;
    end;

    //at first we draw the farthest objects...
    LineHeight := floor(Config.ScreenHeight/perpWallDist);
    DrawStart := floor(-LineHeight / 2 + Config.ScreenHeight / 2);
    DrawEnd := floor(LineHeight / 2 + Config.ScreenHeight / 2);
    WallColor := RGB_Magenta; //default texture in case number doesn't exist
    if (side) then WallColor := WallColor / 2;
    if ((MapPos.x >= 0) and (MapPos.x < Length(GameMap.Map)) and (MapPos.y >= 0) and (MapPos.y < Length(GameMap.Map[MapPos.x]))) then
    begin
      TexIndex := GameMap.Map[MapPos.X][MapPos.Y];

      if (TextureExists(@Textures[TexIndex])) then
      begin
        DrawTexStripe(AScreenX,DrawStart,DrawEnd,WallX,@Textures[TexIndex],side, perpWallDist)
      end
      else
        verLine(AScreenX,DrawStart,DrawEnd,WallColor);

      CurrSprite := GameMap.FindSprite(MapPos.X, MapPos.Y);
      if CurrSprite <> nil then
      begin
        TexIndex := CurrSprite^.ID;
        if TextureExists(@SpriteTextures[TexIndex]) then
        begin
          DrawTexStripe(AScreenX, DrawStart, DrawEnd, WallX, @SpriteTextures[TexIndex], false, perpWallDist);
        end;
      end;
    end;

    //...and so on to nearest.
    for i:=StackLoad downto 1 do
    begin
      LineHeight := floor(Config.ScreenHeight/RenderStack[i].CPerpWallDist);
      DrawStart := floor(-LineHeight / 2 + Config.ScreenHeight / 2);
      DrawEnd := floor(LineHeight / 2 + Config.ScreenHeight / 2);
      if RenderStack[i].Sprite then
      begin
        CurrSprite := GameMap.FindSprite(RenderStack[i].CMapPos.X, RenderStack[i].CMapPos.Y);
        if CurrSprite <> nil then
        begin
          TexIndex := CurrSprite^.ID;
          if TextureExists(@SpriteTextures[TexIndex]) then
          begin
            DrawTexStripe(AScreenX, DrawStart, DrawEnd, RenderStack[i].CWallX, @SpriteTextures[TexIndex], false, RenderStack[i].CPerpWallDist);
          end;
        end;
      end
      else
      begin
        TexIndex := GameMap.Map[RenderStack[i].CMapPos.X][RenderStack[i].CMapPos.Y];

        //just test code for door rendering
        CurrDoor := FindDoor(RenderStack[i].CMapPos.X, RenderStack[i].CMapPos.Y);
        if CurrDoor <> nil then
        begin
          DrawEnd := DrawEnd - floor((DrawEnd - DrawStart)*(CurrDoor^.OpenValue));
        end;

        DrawTexStripe(AScreenX,DrawStart,DrawEnd,RenderStack[i].CWallX,@Textures[TexIndex],RenderStack[i].CSide, RenderStack[i].CPerpWallDist);
      end;
      //because we don't have floors and ceils for now
      //and yeah, this is way too shitty
      if (i+1) <= StackLoad then
      begin
        if (RenderStack[i].CMapPos.X = RenderStack[i+1].CMapPos.X) and (RenderStack[i].CMapPos.Y = RenderStack[i+1].CMapPos.Y) then
        begin
          DrawEndPrev := floor(floor(Config.ScreenHeight/RenderStack[i+1].CPerpWallDist) / 2 + Config.ScreenHeight / 2);
          DrawStartPrev := floor(-(floor(Config.ScreenHeight/RenderStack[i+1].CPerpWallDist)) / 2 + Config.ScreenHeight / 2);

          if (CurrDoor <> nil) then
            DrawEndPrev := DrawEndPrev - floor((DrawEndPrev - DrawStartPrev)*(CurrDoor^.OpenValue));

          if (DrawEnd < DrawEndPrev)
          and (RenderStack[i].CMapPos.x = RenderStack[i+1].CMapPos.x)
          and (RenderStack[i].CMapPos.y = RenderStack[i+1].CMapPos.y)
          then
            verLine(AScreenX,DrawEnd,DrawEndPrev,RGB_Gray);
        end;
      end;
    end;
  end;

  procedure TRaycaster.DrawFrame;
  var
    ScreenX: integer;
  begin
    drawRect(0, 0, Config.ScreenWidth, Config.ScreenHeight div 2, RGB_Gray); // ceiling
    drawRect(0, Config.ScreenHeight div 2, Config.ScreenWidth, Config.ScreenHeight, RGB_Grey); //floor
    for ScreenX := 0 to Config.ScreenWidth do
    begin
      CalculateStripe(ScreenX);
      DrawStripe(ScreenX);
      //DRAW CROSSHAIR
      verLine(Config.ScreenWidth div 2, (Config.ScreenHeight div 2)-5, (Config.ScreenHeight div 2)+5, RGB_White);
      horLine(Config.ScreenHeight div 2, (Config.ScreenWidth div 2)-5, (Config.ScreenWidth div 2)+5, RGB_White);
    end;
    DrawHud;
    DrawFps;
    redraw;
    cls;
    HandleInput;
    HandleDoors;
  end;

  procedure TRaycaster.DrawHud;
  begin
    writeText('Plane= '+FloatToStr(VPlane.X)+';'+FloatToStr(VPlane.Y),0,Config.ScreenHeight-3*CHAR_SIZE-1);
    writeText('Player X='+FloatToStr(Game.VPlayer.X)+'; Y='+FloatToStr(Game.VPlayer.Y),0,Config.ScreenHeight-2*CHAR_SIZE-1);
    writeText('Direction: ('+FloatToStr(Game.VDirection.X)+';'+FloatToStr(Game.VDirection.Y)+')',0,Config.ScreenHeight-CHAR_SIZE-1);
  end;

  procedure TRaycaster.DrawFPS;
  begin
    writeText('by t1meshift & boriswinner',0,0);

    OldTime := Time;
    Time := getTicks;
    FrameTime := (time - oldTime) / 1000;
    writeText(FloatToStr(floor(1/FrameTime*100)/100)+' FPS',0,CHAR_SIZE+1);
  end;

  procedure HandleDoors;
  var i: integer;
    CurrDoor: PDoor;
  begin
    if (DoorOpened) then
    begin
      CurrDoor := FindDoor(DoorToOpen.x, DoorToOpen.y);
      CurrDoor^.Open;
    end;
    DoorOpened := false;
    DoorToOpen.x := -1; //does not exist ofc
    DoorToOpen.y := -1; //does not exist ofc

    for i := low(Doors) to high(Doors) do
    begin
      Doors[i].DoorTick;
    end;
  end;

  procedure TRaycaster.HandleInput;
  var
    MoveSpeed,RotSpeed: double;
    OldVDirection,OldVPlane: TFloatPoint;
    MoveDoor: PDoor;
    MoveThroughDoor: boolean;
  begin
    MoveSpeed := FrameTime*7;
    RotSpeed := FrameTime*3;

    readKeys;
    if keyDown(KEY_SPACE) then
    begin
      if (DoorToOpen.x > -1) and (DoorToOpen.y > -1) then
      begin
        DoorOpened := true;
      end;
    end;
    if keyDown(KEY_UP) then
    begin
      MoveDoor := FindDoor(Floor(Game.VPlayer.X+Game.VDirection.X*MoveSpeed), Floor(Game.VPlayer.Y));
      if MoveDoor = nil then
        MoveThroughDoor := false
      else
        MoveThroughDoor := MoveDoor^.Opened;

      if ((GameMap.Map[Floor(Game.VPlayer.X+Game.VDirection.X*MoveSpeed)][Floor(Game.VPlayer.Y)] = 0) or
       (not Textures[GameMap.Map[Floor(Game.VPlayer.X+Game.VDirection.X*MoveSpeed)][Floor(Game.VPlayer.Y)]].Solid)) or
       (MoveThroughDoor) then
         Game.VPlayer.X += Game.VDirection.X*MoveSpeed;

      MoveDoor := FindDoor(Floor(Game.VPlayer.X), Floor(Game.VPlayer.Y+Game.VDirection.Y*MoveSpeed));
      if MoveDoor = nil then
        MoveThroughDoor := false
      else
        MoveThroughDoor := MoveDoor^.Opened;

      if ((GameMap.Map[Floor(Game.VPlayer.X)][Floor(Game.VPlayer.Y+Game.VDirection.Y*MoveSpeed)] = 0) or //empty
       (not Textures[GameMap.Map[Floor(Game.VPlayer.X)][Floor(Game.VPlayer.Y+Game.VDirection.Y*MoveSpeed)]].Solid)) or //non-solid
       (MoveThroughDoor) then //door
         Game.VPlayer.Y += Game.VDirection.Y*MoveSpeed;
    end;
    if keyDown(KEY_DOWN) then
    begin
      MoveDoor := FindDoor(Floor(Game.VPlayer.X-Game.VDirection.X*MoveSpeed), Floor(Game.VPlayer.Y));
      if MoveDoor = nil then
        MoveThroughDoor := false
      else
        MoveThroughDoor := MoveDoor^.Opened;

      if ((GameMap.Map[Floor(Game.VPlayer.X-Game.VDirection.X*MoveSpeed)][Floor(Game.VPlayer.Y)] = 0) or
       (not Textures[GameMap.Map[Floor(Game.VPlayer.X-Game.VDirection.X*MoveSpeed)][Floor(Game.VPlayer.Y)]].Solid)) or
       (MoveThroughDoor) then
         Game.VPlayer.X -= Game.VDirection.X*MoveSpeed;

      MoveDoor := FindDoor(Floor(Game.VPlayer.X), Floor(Game.VPlayer.Y-Game.VDirection.Y*MoveSpeed));
      if MoveDoor = nil then
        MoveThroughDoor := false
      else
        MoveThroughDoor := MoveDoor^.Opened;

      if ((GameMap.Map[Floor(Game.VPlayer.X)][Floor(Game.VPlayer.Y-Game.VDirection.Y*MoveSpeed)] = 0) or
       (not Textures[GameMap.Map[Floor(Game.VPlayer.X)][Floor(Game.VPlayer.Y-Game.VDirection.Y*MoveSpeed)]].Solid)) or
       (MoveThroughDoor) then
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
  Raycaster.FOV := 66;
  Raycaster.VPlane.x := Game.VDirection.Y*tan(degtorad(Config.FOV/2));
  Raycaster.VPlane.y := -Game.VDirection.X*tan(degtorad(Config.FOV/2));
  Raycaster.Time := 0;

  DoorOpened := false;

end.
