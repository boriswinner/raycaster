program umain;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, uraycaster, ugame, ugraphic, usound;

begin
  screen(Raycaster.ScreenWidth, Raycaster.ScreenHeight, false, 'Raycaster (collision isn''t good)');
  InitTextures;
  while (not done) do Raycaster.DrawFrame;
  FinishSoundModule;
  FinishGraphicModule;
end.

