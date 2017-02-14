unit utexture;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SDL2, uconfiguration;

type TTexture = record
  RawTexture, RawTextureSide : PSDL_Texture;
  Width, Height : Int32;
  Transparent, Solid : boolean;
  RenderTarget : PSDL_Renderer;
end;
//type TTransparency =

type PTexture = ^TTexture;

function LoadTexture(_RenderTarget : PSDL_Renderer; FileName: string; _Transparent, _Solid: boolean) : TTexture; overload;
function LoadTexture(_RenderTarget : PSDL_Renderer; FileName, FileNameSide: string; _Transparent, _Solid: boolean) : TTexture; overload;
procedure DestroyTexture(TextureToDestroy : PTexture);
function TextureExists(Target : PTexture) : boolean; inline;

implementation

//LoadTexture(RenderTarget, FileName, Transparent, Solid);
    //RenderTarget - use 'renderer' variable;
    //FileName - I think you got it;
    //Transparent - shows if texture supports transparency or not;
    //Solid - shows ability to walk through walls with this texture.

function LoadTexture(_RenderTarget : PSDL_Renderer; FileName: string; _Transparent, _Solid: boolean) : TTexture; overload;
var
  bmp : PSDL_Surface;
begin
   Result.Width:=0;
   Result.Height:=0;
   bmp := SDL_LoadBMP(PAnsiChar(Config.TexturePath + FileName));
   if bmp = nil then
     exit;

   if _Transparent then
   begin
     SDL_SetColorKey(bmp, 1, SDL_MapRGB(bmp^.format, 255, 0, 255)); //magenta is transparent
   end;

   Result.Transparent := _Transparent;

   Result.RawTexture := SDL_CreateTextureFromSurface(_RenderTarget, bmp);
   Result.RawTextureSide := Result.RawTexture;

   if Result.RawTexture = nil then
     exit;
   SDL_FreeSurface(bmp);

   SDL_QueryTexture(Result.RawTexture, nil, nil, @Result.Width, @Result.Height);
   Result.RenderTarget := _RenderTarget;
   Result.Solid := _Solid;
end;

function LoadTexture(_RenderTarget : PSDL_Renderer; FileName, FileNameSide: string; _Transparent, _Solid: boolean) : TTexture; overload;
var
  bmp : PSDL_Surface;
begin
   Result.Width:=0;
   Result.Height:=0;
   bmp := SDL_LoadBMP(PAnsiChar(Config.TexturePath + FileName));
   if bmp = nil then
     exit;

   if _Transparent then
   begin
     SDL_SetColorKey(bmp, 1, SDL_MapRGB(bmp^.format, 255, 0, 255)); //magenta is transparent
   end;

   Result.Transparent := _Transparent;

   Result.RawTexture := SDL_CreateTextureFromSurface(_RenderTarget, bmp);

   //load side texture
   bmp := SDL_LoadBMP(PAnsiChar(Config.TexturePath + FileNameSide));
   if bmp = nil then
     exit;
   if _Transparent then
   begin
     SDL_SetColorKey(bmp, 1, SDL_MapRGB(bmp^.format, 255, 0, 255)); //magenta is transparent
   end;
   Result.RawTextureSide := SDL_CreateTextureFromSurface(_RenderTarget, bmp);

   if (Result.RawTexture = nil) or (Result.RawTextureSide = nil) then
     exit;
   SDL_FreeSurface(bmp);

   SDL_QueryTexture(Result.RawTexture, nil, nil, @Result.Width, @Result.Height);
   Result.RenderTarget := _RenderTarget;
   Result.Solid := _Solid;
end;

procedure DestroyTexture(TextureToDestroy : PTexture);
begin
  with TextureToDestroy^ do
  begin
    RenderTarget := nil;
    SDL_DestroyTexture(RawTexture);
    RawTexture := nil;
    Width := 0; Height := 0;
  end;
end;

function TextureExists(Target : PTexture) : boolean; inline;
begin
  Result := (Target^.Height <> 0) and (Target^.Width <> 0);
end;

initialization
end.

