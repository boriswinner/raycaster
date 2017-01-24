unit ugraphic;

{$mode objfpc}{$H+}{$INLINE ON} {$MODESWITCH ADVANCEDRECORDS}

interface

//I'll use SDL2 because I can.

uses
  Classes, SysUtils, SDL2;

type TColorRGB = record
  r, g, b: UInt8;
  constructor Create(red, green, blue: UInt8);
  end;

const
  CHAR_SIZE = 12;
  KEY_UP = SDLK_UP;
  KEY_DOWN = SDLK_DOWN;
  KEY_LEFT = SDLK_LEFT;
  KEY_RIGHT = SDLK_RIGHT;

var
  screen_width,
  screen_height : integer;
  window        : PSDL_Window;
  renderer      : PSDL_Renderer;
  event         : TSDL_Event;
  scr           : PSDL_Texture;
  font          : PSDL_Surface;
  inkeys        : PUInt8;

  RGB_Black,
  RGB_Red,
  RGB_Green,
  RGB_Blue,
  RGB_Cyan,
  RGB_Magenta,
  RGB_Yellow,
  RGB_White,
  RGB_Gray,
  RGB_Grey,
  RGB_Maroon,
  RGB_Darkgreen,
  RGB_Navy,
  RGB_Teal,
  RGB_Purple: TColorRGB;

//TODO clean up that shit

procedure finish; inline;
function getTicks(): UInt64; inline;

operator / (color: TColorRGB; a: integer) res : TColorRGB;

procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
procedure readKeys;
function  keyDown(key: TSDL_KeyCode): boolean; overload;
function  keyDown(key: TSDL_ScanCode): boolean; overload;
function  done(quit_if_esc, delay: boolean): boolean; overload;
function  done: boolean; inline; overload;
procedure verLine(x, y1, y2: integer; color: TColorRGB);
procedure pSet(x, y: integer; color: TColorRGB);
procedure drawRect(x1, y1, x2, y2: integer; color: TColorRGB);
procedure redraw; inline;
procedure cls(color: TColorRGB); overload;
procedure cls; inline; overload;
procedure initFont;
procedure writeText(text: string; x, y:integer);

{
 TODO: PORT THIS!!!

ColorRGB operator+(const ColorRGB& color, const ColorRGB& color2);
ColorRGB operator-(const ColorRGB& color, const ColorRGB& color2);
ColorRGB operator*(const ColorRGB& color, int a);
ColorRGB operator*(int a, const ColorRGB& color);
bool operator==(const ColorRGB& color, const ColorRGB& color2);
bool operator!=(const ColorRGB& color, const ColorRGB& color2);

//a color with 3 components: h, s and l
struct ColorHSL
[
  int h;
  int s;
  int l;

  ColorHSL(Uint8 h, Uint8 s, Uint8 l);
  ColorHSL();
];

//a color with 3 components: h, s and v
struct ColorHSV
[
  int h;
  int s;
  int v;

  ColorHSV(Uint8 h, Uint8 s, Uint8 v);
  ColorHSV();
];
}

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
  Result := TColorRGB.Create(color.r div a, color.g div a, color.b div a);
end;

//exit program
procedure finish; inline;
begin
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit;
  halt(1);
end;

//getTicks from SDL
function getTicks(): UInt64; inline;
begin
  Result := SDL_GetTicks;
end;

//Screen() -- that's init of SDL
procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
const
  RENDER_FLAGS = SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC; //HW accel + VSync
begin
  screen_width := width;
  screen_height := height;

  if not fullscreen then
    window := SDL_CreateWindow(PChar(window_name), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN)
  else
    window := SDL_CreateWindow(PChar(window_name), SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 0, 0, SDL_WINDOW_FULLSCREEN_DESKTOP);

  if window = nil then
  begin
    writeln('Window error: ', SDL_GetError);
    finish;
  end;

  renderer := SDL_CreateRenderer(window,-1, RENDER_FLAGS);

  if renderer = nil then
  begin
    writeln('Renderer error: ', SDL_GetError);
    finish;
  end;

  if fullscreen then
  begin
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, PChar('linear'));
    if SDL_RenderSetLogicalSize(renderer, screen_width, screen_height)<>0 then
      writeln('logical size error: ', SDL_GetError);
  end;

  //scr := SDL_CreateTexture(renderer, SDL_GetWindowPixelFormat(window), 0, width, height);

  initFont;
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
  if delay then SDL_Delay(5);
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

//vertical line
procedure verLine(x, y1, y2: integer; color: TColorRGB);
begin
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderDrawLine(renderer, x, y1, x, y2);
end;

//set pixel
procedure pSet(x, y: integer; color: TColorRGB);
begin
  if (x < 0) or (y < 0) or (x >= screen_width) or (y >= screen_height) then exit;
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderDrawPoint(renderer, x, y);
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

//clear screen
procedure cls(color: TColorRGB); overload;
begin
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderClear(renderer);
end;
procedure cls; inline; overload;
begin
  cls(RGB_Black); //yaaaaay shitty code
end;

//init font to make it usable
procedure initFont;
begin
  font := SDL_LoadBMP('./res/good_font.bmp');
  if font = nil then
  begin
    writeln('Can''t get the font file. ');
    exit;
  end;
  SDL_ConvertSurfaceFormat(font, SDL_PIXELFORMAT_RGB24, 0);
  SDL_SetColorKey(font, 1, SDL_MapRGB(font^.format, 0, 0, 0));
end;

// write text
procedure writeText(text: string; x, y:integer);
var
  len, i, row_cnt: integer;
  char_code: byte;
  font_tex: PSDL_Texture;
  selection, char_rect: TSDL_Rect;
begin
  len := CHAR_SIZE * Length(text);
  row_cnt := font^.w div CHAR_SIZE;

  if ((x < 0) or ((x+len) > screen_width) or (y < 0) or ((y+CHAR_SIZE) > screen_height)) then
    exit;

  selection.w := CHAR_SIZE;
  selection.h := CHAR_SIZE;

  char_rect.w := CHAR_SIZE;
  char_rect.h := CHAR_SIZE;
  char_rect.y := y;

  font_tex := SDL_CreateTextureFromSurface(renderer,font);
  for i:=1 to Length(text) do
  begin
    char_code := ord(text[i]);
    selection.y := (char_code div row_cnt)*CHAR_SIZE;
    selection.x := (char_code mod row_cnt)*CHAR_SIZE;
    char_rect.x := x + (i-1)*CHAR_SIZE;
    SDL_RenderCopy(renderer,font_tex,@selection,@char_rect);
  end;
  SDL_DestroyTexture(font_tex);
end;

initialization
  //TODO implement this as static property of class!!!!!!!!
  RGB_Black     := TColorRGB.Create(0,    0,    0);
  RGB_Red       := TColorRGB.Create(255,   0,   0);
  RGB_Green     := TColorRGB.Create(0,   255,   0);
  RGB_Blue      := TColorRGB.Create(0,   0,   255);
  RGB_Cyan      := TColorRGB.Create(0,  255,  255);
  RGB_Magenta   := TColorRGB.Create(255,  0,  255);
  RGB_Yellow    := TColorRGB.Create(255,  255,  0);
  RGB_White     := TColorRGB.Create(255, 255, 255);
  RGB_Gray      := TColorRGB.Create(128, 128, 128);
  RGB_Grey      := TColorRGB.Create(192, 192, 192);
  RGB_Maroon    := TColorRGB.Create(128,   0,   0);
  RGB_Darkgreen := TColorRGB.Create(  0, 128,   0);
  RGB_Navy      := TColorRGB.Create(  0,   0, 128);
  RGB_Teal      := TColorRGB.Create(  0, 128, 128);
  RGB_Purple    := TColorRGB.Create(128,   0, 128);

end.

