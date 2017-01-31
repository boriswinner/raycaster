program umain;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, Forms, Interfaces, uraycaster, ugame, ugraphic, usound,
  uconfigurator;

begin
  screen(Raycaster.ScreenWidth, Raycaster.ScreenHeight, FullscreenMode, 'Raycaster (collision isn''t good)');
  InitTextures;
  while (not done) do
    Raycaster.DrawFrame;
  FinishSoundModule;
  FinishGraphicModule;
end.

