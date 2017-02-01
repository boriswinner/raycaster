program umain;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, Forms, Interfaces, uraycaster, ugame, ugraphic, usound,
  uconfigurator;

{$R *.res}

begin
  screen(Raycaster.ScreenWidth, Raycaster.ScreenHeight, FullscreenMode, 'Raycaster (collision isn''t good)');
  if (SoundOn) then
    PlayLevelMusic(LevelNumber);
  InitTextures;
  while (not done) do
    Raycaster.DrawFrame;
  FinishSoundModule;
  FinishGraphicModule;
end.

