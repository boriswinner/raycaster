unit ugraphic;

{$mode objfpc}{$H+}{$INLINE ON} {$MODESWITCH ADVANCEDRECORDS}

interface

//I'll use SDL2 because I can.

uses
  Classes, SysUtils, SDL2, utexture, uconfiguration, Math;

type

  TColorRGB = record
    r, g, b: UInt8;
    constructor Create(red, green, blue: UInt8);
  end;

const
  CHAR_SIZE = 12;
  KEY_UP = SDLK_UP;
  KEY_DOWN = SDLK_DOWN;
  KEY_LEFT = SDLK_LEFT;
  KEY_RIGHT = SDLK_RIGHT;
  KEY_SPACE = SDLK_SPACE;

  RGB_Black     : TColorRGB = (r: 0; g: 0; b: 0);
  RGB_Red       : TColorRGB = (r: 255; g: 0; b: 0);
  RGB_Green     : TColorRGB = (r: 0; g: 255; b: 0);
  RGB_Blue      : TColorRGB = (r: 0; g: 0; b: 255);
  RGB_Cyan      : TColorRGB = (r: 0; g: 255; b: 255);
  RGB_Magenta   : TColorRGB = (r: 255; g: 0; b: 255);
  RGB_Yellow    : TColorRGB = (r: 255; g: 255; b: 0);
  RGB_White     : TColorRGB = (r: 255; g: 255; b: 255);
  RGB_Gray      : TColorRGB = (r: 128; g: 128; b: 128);
  RGB_Grey      : TColorRGB = (r: 192; g: 192; b: 192);
  RGB_Maroon    : TColorRGB = (r: 128; g: 0; b: 0);
  RGB_Darkgreen : TColorRGB = (r: 0; g: 128; b: 0);
  RGB_Navy      : TColorRGB = (r: 0; g: 0; b: 128);
  RGB_Teal      : TColorRGB = (r: 0; g: 128; b: 128);
  RGB_Purple    : TColorRGB = (r: 128; g: 0; b: 128);


var
  screen_width,
  screen_height : integer;
  window        : PSDL_Window;
  renderer      : PSDL_Renderer;
  event         : TSDL_Event;
  scr           : PSDL_Texture;
  font          : PSDL_Surface;
  inkeys        : PUInt8;
  pFormat,
  bgFormat      : PSDL_PixelFormat;
  pixels        : PUInt32;
  pitch         : UInt32;
  font_tex      : PSDL_Texture;

//TODO clean up that shit

procedure FinishGraphicModule; inline;
procedure MsgBox(msg: string); inline;
function getTicks: UInt64; inline;
procedure delay (ms: UInt32); inline;

operator / (color: TColorRGB; a: integer) res : TColorRGB;

procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
procedure readKeys;
function  keyDown(key: TSDL_KeyCode): boolean; overload;
function  keyDown(key: TSDL_ScanCode): boolean; overload;
function  done(quit_if_esc, delay: boolean): boolean; overload;
function  done: boolean; inline; overload;
//procedure SetTextureColorMod(Tex: PTexture; R, G, B: UInt8);
procedure verLine(x, y1, y2: integer; color: TColorRGB);
procedure horLine(y, x1, x2: integer; color: TColorRGB);
procedure DrawTexStripe(DrawX, y1, y2: integer; TexCoordX: double; Tex: PTexture); overload;
procedure DrawTexStripe(DrawX, y1, y2: integer; TexCoordX: double; Tex: PTexture; Side: boolean; wallDist: double); overload;
procedure lock;
procedure unlock;
procedure pSet(x, y: integer; color: TColorRGB);
procedure pSet(x, y: integer; texture: PTexture; tx,ty: UInt32);
procedure drawRect(x1, y1, x2, y2: integer; color: TColorRGB);
procedure redraw; inline;
procedure cls(color: TColorRGB); overload;
procedure cls; inline; overload;
procedure initFont(APath: PChar);
procedure writeText(text: string; x, y:integer);

implementation
//TColorRGB stuff first
constructor TColorRGB.Create(red, green, blue: UInt8);
begin
  r := red;
  g := green;
  b := blue;
end;
operator / (color: TColorRGB; a: integer) res : TColorRGB;
begin
  if (a <= 0) then exit(color);
  Result := TColorRGB.Create(color.r div a, color.g div a, color.b div a); // seems shitty, need to fix it
end;

//exit program
procedure FinishGraphicModule; inline;
begin
  SDL_SetRenderTarget(renderer, nil);
  SDL_DestroyTexture(scr);
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit;
  halt(1);
end;

//Message box.
procedure MsgBox(msg: string); inline;
begin
  SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION,PAnsiChar('Message'),PAnsiChar(msg), nil);
end;

//getTicks from SDL
function GetTicks: UInt64; inline;
begin
  Result := SDL_GetTicks;
end;

//delays program
procedure delay (ms: UInt32); inline;
begin
  SDL_Delay(ms);
end;

//Screen() -- that's init of SDL
procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
var
  RENDER_FLAGS : UInt32;
begin
  RENDER_FLAGS := SDL_RENDERER_ACCELERATED or (SDL_RENDERER_PRESENTVSYNC and (UInt8(Config.VSync) shl 2)); //HW accel + VSync
  screen_width := width;
  screen_height := height;

  if not fullscreen then
    window := SDL_CreateWindow(PChar(window_name), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN)
  else
    window := SDL_CreateWindow(PChar(window_name), SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 0, 0, SDL_WINDOW_FULLSCREEN_DESKTOP);

  if window = nil then
  begin
    writeln('Window error: ', SDL_GetError);
    FinishGraphicModule;
  end;

  renderer := SDL_CreateRenderer(window, -1, RENDER_FLAGS);

  if renderer = nil then
  begin
    writeln('Renderer error: ', SDL_GetError);
    FinishGraphicModule;
  end;

  if fullscreen then
  begin
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, PChar('linear'));
    if SDL_RenderSetLogicalSize(renderer, screen_width, screen_height)<>0 then
      writeln('logical size error: ', SDL_GetError);
  end;
  pFormat := SDL_AllocFormat(SDL_GetWindowPixelFormat(window));
  bgFormat := SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888);
  scr := SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, width, height);
  SDL_SetTextureBlendMode(scr, SDL_BLENDMODE_BLEND);
  initFont(PChar(Config.FontPath));
end;

//Reads keys to array.
procedure readKeys;
begin
  inkeys := SDL_GetKeyboardState(nil);
end;

//KeyDown events check.
function keyDown(key: TSDL_KeyCode): boolean; overload;
var scancode: TSDL_ScanCode;
begin
  scancode := SDL_GetScancodeFromKey(key);
  Result := inkeys[scancode] <> 0;
end;
function keyDown(key: TSDL_ScanCode): boolean; overload;
begin
  Result := inkeys[key] <> 0;
end;

//checking if we have received exit event
function done(quit_if_esc, delay: boolean): boolean;
begin
  //quit_if_esc does not work!
  if delay then SDL_Delay(3); //2 or less gives too many FPS
  readKeys;
  while SDL_PollEvent(@event)<>0 do
  begin
    if (event.type_ = SDL_QUITEV) then exit(true);
    if (quit_if_esc and keyDown(SDL_SCANCODE_ESCAPE)) then exit(true);
  end;
  Result := false;
end;
function done: boolean; inline; overload;
begin
  Result := done(true, true);
end;

//modifies color palette of texture
procedure SetTextureColorMod(Tex: PTexture; R, G, B: UInt8);
begin
  SDL_SetTextureColorMod(Tex^.RawTexture, R, G, B);
end;

//vertical line
procedure verLine(x, y1, y2: integer; color: TColorRGB);
var dy1, dy2: integer;
begin
  dy1 := max(0, y1);
  dy2 := min(screen_height - 1, y2);
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderDrawLine(renderer, x, dy1, x, dy2);
end;

//horizontal line
procedure horLine(y, x1, x2: integer; color: TColorRGB);
var dx1, dx2: integer;
begin
  dx1 := max(0, x1);
  dx2 := min(screen_width - 1, x2);
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderDrawLine(renderer, dx1, y, dx2, y);
end;

//draws a stripe from texture
procedure DrawTexStripe(DrawX, y1, y2: integer; TexCoordX: double; Tex: PTexture); overload;
var
  src, dst: TSDL_Rect;
begin
  src.x := SInt32(Trunc(TexCoordX * double(Tex^.Width)));
  src.y := 0;
  src.w := 1;
  src.h := Tex^.Height;

  dst.x := DrawX;
  dst.y := y1;
  dst.w := 1;
  dst.h := y2-y1+1;
  SDL_RenderCopy(renderer, Tex^.RawTexture, @src, @dst);
end;
procedure DrawTexStripe(DrawX, y1, y2: integer; TexCoordX: double; Tex: PTexture; Side: boolean; wallDist: double); overload;
var
  src, dst: TSDL_Rect;
  shading: byte;
begin
  src.x := SInt32(Trunc(TexCoordX * double(Tex^.Width)));
  src.y := 0;
  src.w := 1;
  src.h := Tex^.Height;

  dst.x := DrawX;
  dst.y := y1;
  dst.w := 1;
  dst.h := y2-y1+1;

  {if Side then
    SDL_SetTextureColorMod(Tex^.RawTexture, 127, 127, 127);}

  //MAX_DIST = 75;
  //if wallDist > 75 then
  //  exit;
  shading := max(round((1 - (wallDist/32))*255),3);
  SDL_SetTextureColorMod(Tex^.RawTexture, shading, shading, shading);
  SDL_SetTextureColorMod(Tex^.RawTextureSide, shading, shading, shading);

  if Side then
    SDL_RenderCopy(renderer, Tex^.RawTextureSide, @src, @dst)
  else
    SDL_RenderCopy(renderer, Tex^.RawTexture, @src, @dst);

  SDL_SetTextureColorMod(Tex^.RawTexture, 255, 255, 255);
  SDL_SetTextureColorMod(Tex^.RawTextureSide, 255, 255, 255);
end;

//lock screen overlay in order to be able to draw pixel-by-pixel
procedure lock;
var bgColor, i: UInt32;
begin
  SDL_LockTexture(scr, nil, @pixels, @pitch);
  bgColor := SDL_MapRGBA(bgFormat, 255, 255, 255, 0); //transparent
  for i:=0 to screen_width*screen_height-1 do
    pixels[i] := bgColor;
end;
//unlock screen overlay to finally draw changes
procedure unlock;
begin
  SDL_UnlockTexture(scr);
  SDL_RenderCopy(renderer, scr, nil, nil);
end;

//set pixel
procedure pSet(x, y: integer; color: TColorRGB);
var
  pColor, pixelpos: UInt32;
begin
  if (x < 0) or (y < 0) or (x >= screen_width) or (y >= screen_height) then exit;
  //SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  //SDL_RenderDrawPoint(renderer, x, y);
  pColor := SDL_MapRGBA(bgFormat, color.r, color.g, color.b, 255);

  pixelpos := screen_width*y+x;
  pixels[pixelpos] := pColor;
end;

//set pixel from texture
procedure pSet(x, y: integer; texture: PTexture; tx,ty: UInt32);
var
  region,dst: TSDL_Rect;
begin
  region.x:=tx;
  region.y:=ty;
  region.w:=1;
  region.h:=1;

  dst.x:=x;
  dst.y:=y;
  dst.w:=1;
  dst.h:=1;

  SDL_RenderCopy(renderer,texture^.RawTexture,@region,@dst);
end;

//draw rectangular
procedure drawRect(x1, y1, x2, y2: integer; color: TColorRGB);
var r: TSDL_Rect;
begin
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  r.x := x1; r.y := y1; r.w := x2-x1; r.h := y2-y1;
  SDL_RenderFillRect(renderer,@r);
end;

//redraw the frame.
procedure redraw; inline;
begin
  SDL_RenderPresent(renderer);
end;

//clear screen.
procedure cls(color: TColorRGB); overload;
begin
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderClear(renderer);
end;
procedure cls; inline; overload;
begin
  cls(RGB_Black);
end;

//init font to make it usable
procedure initFont(APath: PChar);
begin
  // TODO LOAD FONTS FROM FILE
  font := SDL_LoadBMP(APath);
  if font = nil then
  begin
    writeln('Can''t get the font file. ');
    exit;
  end;
  SDL_ConvertSurfaceFormat(font, SDL_PIXELFORMAT_RGB24, 0);
  SDL_SetColorKey(font, 1, SDL_MapRGB(font^.format, 0, 0, 0)); //make transparent bg
  font_tex := SDL_CreateTextureFromSurface(renderer,font); // we need this for RenderCopy
end;

// write text
procedure writeText(text: string; x, y:integer);
var
  len, i, row_cnt: integer;
  char_code: byte;
  selection, char_rect: TSDL_Rect;
begin
  //TODO \n support
  len := CHAR_SIZE * Length(text);
  row_cnt := font^.w div CHAR_SIZE;

  //if ((x < 0) or ((x+len) > screen_width) or (y < 0) or ((y+CHAR_SIZE) > screen_height)) then
  //  exit; // if our text is too big then we don't work

  selection.w := CHAR_SIZE;
  selection.h := CHAR_SIZE;

  char_rect.w := CHAR_SIZE;
  char_rect.h := CHAR_SIZE;
  char_rect.y := y;

  for i:=1 to Length(text) do
  begin
    char_code := ord(text[i]); // getting char code...
    selection.y := (char_code div row_cnt)*CHAR_SIZE; // and then we get our
    selection.x := (char_code mod row_cnt)*CHAR_SIZE; // char location on font
    char_rect.x := x + (i-1)*CHAR_SIZE; // move next char of string to the right
    SDL_RenderCopy(renderer,font_tex,@selection,@char_rect); // and then we copy our char from font
  end;
  //SDL_DestroyTexture(font_tex); // prevent memory leak
end;

initialization
end.

