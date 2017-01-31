unit utexture;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SDL2;

type TTexture = record
  RawTexture : PSDL_Texture;
  Width, Height : Int32;
  Transparent, Solid: boolean;
  RenderTarget : PSDL_Renderer;
end;
type PTexture = ^TTexture;

function LoadTexture(_RenderTarget : PSDL_Renderer; FileName: string; _Transparent, _Solid: boolean) : TTexture;
procedure DestroyTexture(TextureToDestroy : PTexture);
function TextureExists(Target : PTexture) : boolean; inline;

implementation

function LoadTexture(_RenderTarget : PSDL_Renderer; FileName: string; _Transparent, _Solid: boolean) : TTexture;
var
  bmp : PSDL_Surface;
begin
   Result.Width:=0;
   Result.Height:=0;
   bmp := SDL_LoadBMP(PAnsiChar('./res/textures/' + FileName));
   if bmp = nil then
     exit;

   if Transparent then
   begin
     //SDL_SetColorKey(bmp, );
   end;

   Result.RawTexture := SDL_CreateTextureFromSurface(_RenderTarget, bmp);
   if Result.RawTexture = nil then
     exit;
   SDL_FreeSurface(bmp);

   SDL_QueryTexture(Result.RawTexture, nil, nil, @Result.Width, @Result.Height);
   Result.RenderTarget := _RenderTarget;
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

end.

