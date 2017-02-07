unit usound;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SquallSound, uconfiguration;
const
  LevelPrefix = 'level_';
var
  SoundSystem: TSoundSystem;
  SoundManager: TSoundManager;
  SLevelSound: TSound;
procedure PlayLevelMusic(LevelNumber: UInt32);
procedure StopLevelMusic;
procedure FinishSoundModule;

implementation

procedure PlayLevelMusic(LevelNumber: UInt32);
begin
  SLevelSound := SoundSystem.AddSound(Config.SoundPath + LevelPrefix +
    IntToStr(LevelNumber) + '.ogg',st2D, 1);
  SLevelSound.Volume:=100;
  SLevelSound.Play(true);
end;
procedure StopLevelMusic;
begin
  if SLevelSound <> nil then
    SLevelSound.Stop;
end;
procedure FinishSoundModule;
begin
  StopLevelMusic;
  if SLevelSound <> nil then
    SLevelSound.Destroy;
  SoundManager.Destroy;
  SoundSystem.Stop;
  SoundSystem.Destroy;
end;

initialization
  SoundSystem := TSoundSystem.Create;
  SoundManager := TSoundManager.Create(SoundSystem);
end.

