unit ugraphic;

{$mode objfpc}{$H+}

interface

//I'll use SDL2 because I can.

uses
  Classes, SysUtils, SDL2;

type TColorRGB = class
  r, g, b: integer;
  constructor Create(); overload;
  constructor Create(r, g, b: UInt8); overload;
  end;

var
  screen_width,
  screen_height : integer;
  window        : PSDL_Window;
  renderer      : PSDL_Renderer;
  event         : TSDL_Event;
  scr           : PSDL_Texture;
  inkeys        : array of UInt8;

//keyboard functions


procedure screen(width, height, fullscreen, window_name);
procedure redraw();
procedure cls();

{
 TODO: PORT THIS!!!
 struct ColorRGB8bit;
//a color with 3 components: r, g and b
struct ColorRGB
{
  int r;
  int g;
  int b;

  ColorRGB(Uint8 r, Uint8 g, Uint8 b);
  ColorRGB(const ColorRGB8bit& color);
  ColorRGB();
};

ColorRGB operator+(const ColorRGB& color, const ColorRGB& color2);
ColorRGB operator-(const ColorRGB& color, const ColorRGB& color2);
ColorRGB operator*(const ColorRGB& color, int a);
ColorRGB operator*(int a, const ColorRGB& color);
ColorRGB operator/(const ColorRGB& color, int a);
bool operator==(const ColorRGB& color, const ColorRGB& color2);
bool operator!=(const ColorRGB& color, const ColorRGB& color2);

static const ColorRGB RGB_Black    (  0,   0,   0);
static const ColorRGB RGB_Red      (255,   0,   0);
static const ColorRGB RGB_Green    (  0, 255,   0);
static const ColorRGB RGB_Blue     (  0,   0, 255);
static const ColorRGB RGB_Cyan     (  0, 255, 255);
static const ColorRGB RGB_Magenta  (255,   0, 255);
static const ColorRGB RGB_Yellow   (255, 255,   0);
static const ColorRGB RGB_White    (255, 255, 255);
static const ColorRGB RGB_Gray     (128, 128, 128);
static const ColorRGB RGB_Grey     (192, 192, 192);
static const ColorRGB RGB_Maroon   (128,   0,   0);
static const ColorRGB RGB_Darkgreen(  0, 128,   0);
static const ColorRGB RGB_Navy     (  0,   0, 128);
static const ColorRGB RGB_Teal     (  0, 128, 128);
static const ColorRGB RGB_Purple   (128,   0, 128);
static const ColorRGB RGB_Olive    (128, 128,   0);

//a color with 3 components: r, g and b
struct ColorRGB8bit
{
  Uint8 r;
  Uint8 g;
  Uint8 b;

  ColorRGB8bit(Uint8 r, Uint8 g, Uint8 b);
  ColorRGB8bit(const ColorRGB& color);
  ColorRGB8bit();
};

//a color with 3 components: h, s and l
struct ColorHSL
{
  int h;
  int s;
  int l;

  ColorHSL(Uint8 h, Uint8 s, Uint8 l);
  ColorHSL();
};

//a color with 3 components: h, s and v
struct ColorHSV
{
  int h;
  int s;
  int v;

  ColorHSV(Uint8 h, Uint8 s, Uint8 v);
  ColorHSV();
};
}

implementation

procedure screen(width, height:integer; fullscreen:boolean; window_name:string);
begin
  screen_width := width;
  screen_height := height;

  if not fullscreen then
    window := SDL_CreateWindow(PChar(window_name), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
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

  {///
  if (fullscreen) {
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");  // make the scaled rendering look smoother.
    if (SDL_RenderSetLogicalSize(ren, w, h) != 0)
      std::cout << "logical size error " << SDL_GetError() << std::endl;
  }
  ///}
  scr := SDL_CreateTexture(renderer, SDL_GetWindowPixelFormat(window),0, width, height);
end;
end.

