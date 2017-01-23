unit ugraphic;

{$mode objfpc}{$H+}{$INLINE ON}

interface

//I'll use SDL2 because I can.

uses
  Classes, SysUtils, SDL2;

type TColorRGB = class
  r, g, b: integer;
  constructor Create(); overload;
  constructor Create(red, green, blue: UInt8); overload;
  end;


var
  screen_width,
  screen_height : integer;
  window        : PSDL_Window;
  renderer      : PSDL_Renderer;
  event         : TSDL_Event;
  scr           : PSDL_Texture;
  inkeys        : PUInt8; //maybe array of Uint8?

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

function getTicks(): UInt64; inline;

operator / (color: TColorRGB; a: integer) z : TColorRGB;

procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
procedure readKeys;
function  keyDown(key: TSDL_KeyCode): boolean; overload;
function  keyDown(key: TSDL_ScanCode): boolean; overload;
function  done(quit_if_esc, delay: boolean): boolean; overload;
function  done: boolean; inline; overload;
procedure verLine(x, y1, y2: integer; color: TColorRGB);
procedure redraw; inline;
procedure cls(color: TColorRGB); overload;
procedure cls; inline; overload;


{
 TODO: PORT THIS!!!
 struct ColorRGB8bit;
//a color with 3 components: r, g and b
struct ColorRGB
[
  ColorRGB(const ColorRGB8bit& color);
];

ColorRGB operator+(const ColorRGB& color, const ColorRGB& color2);
ColorRGB operator-(const ColorRGB& color, const ColorRGB& color2);
ColorRGB operator*(const ColorRGB& color, int a);
ColorRGB operator*(int a, const ColorRGB& color);
bool operator==(const ColorRGB& color, const ColorRGB& color2);
bool operator!=(const ColorRGB& color, const ColorRGB& color2);

//a color with 3 components: r, g and b
struct ColorRGB8bit
[
  Uint8 r;
  Uint8 g;
  Uint8 b;

  ColorRGB8bit(Uint8 r, Uint8 g, Uint8 b);
  ColorRGB8bit(const ColorRGB& color);
  ColorRGB8bit();
];

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
//TColorRGB first
constructor TColorRGB.Create; overload;
begin
  r := 0;
  g := 0;
  b := 0;
end;
constructor TColorRGB.Create(red, green, blue: UInt8); overload;
begin

  r := red;
  g := green;
  b := blue;
end;
operator / (color: TColorRGB; a: integer) result : TColorRGB;
begin
  if (a = 0) then exit(color);
  result.r := result.r div a;
  result.g := result.g div a;
  result.b := result.b div a;
end;

//getTicks from SDL
function getTicks(): UInt64; inline;
begin
  Result := SDL_GetTicks;
end;

//Screen() -- that's init of SDL
procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
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
    SDL_Quit;
    halt(1);
  end;

  renderer := SDL_CreateRenderer(window,-1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC);

  if renderer = nil then
  begin
    writeln('Renderer error: ', SDL_GetError);
    SDL_Quit;
    halt(1);
  end;

  if fullscreen then
  begin
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, PChar('linear'));
    if SDL_RenderSetLogicalSize(renderer, screen_width, screen_height)<>0 then
      writeln('logical size error: ', SDL_GetError);
  end;
  scr := SDL_CreateTexture(renderer, SDL_GetWindowPixelFormat(window), 0, width, height);
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
  if delay then SDL_Delay(5);
  readKeys;
  while SDL_PollEvent(@event)<>0 do
  begin
    if (event.type_ = SDL_QUITEV) then exit(true);
    if (quit_if_esc and keyDown(SDL_SCANCODE_ESCAPE)) then exit(true);
  end;
  exit(false);
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

//redraw TODO
procedure redraw; inline;
begin
  SDL_RenderPresent(renderer);
end;

//cls TODO
procedure cls(color: TColorRGB); overload;
begin
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
  SDL_RenderClear(renderer);
end;
procedure cls; inline; overload;
begin
  cls(RGB_Black); //yaaaaay shitty code
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

