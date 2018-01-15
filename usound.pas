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
  SLevelSound, SSFXSound: TSound;

procedure PlaySFX(SFXFileName: string);
procedure PlayLevelMusic(LevelNumber: UInt32);
procedure StopLevelMusic;
procedure FinishSoundModule;

implementation

procedure PlaySFX(SFXFileName: string);
begin
  SSFXSound := SoundSystem.AddSound(Config.SoundPath + SFXFileName ,st2D, 2);
  SSFXSound.Volume:=100;
  SSFXSound.Play(false);
end;

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
    FreeAndNil(SLevelSound);
  FreeAndNil(SoundManager);
  SoundSystem.Stop;
  FreeAndNil(SoundSystem);
end;

initialization
  SoundSystem := TSoundSystem.Create;
  SoundManager := TSoundManager.Create(SoundSystem);
end.

