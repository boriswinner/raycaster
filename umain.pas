program umain;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, Forms, Interfaces, uconfiguration, uconfigurator, uraycaster, ugame,
  ugraphic, usound, umap, udictionary;

{$R *.res}

begin
  screen(Config.ScreenWidth, Config.ScreenHeight, Config.Fullscreen, 'Raycaster');
  if (Config.SoundOn) then
    PlayLevelMusic(LevelNumber);
  InitTextures;
  while (not done) do
    Raycaster.DrawFrame;
  FinishSoundModule;
  FinishGraphicModule;
end.

