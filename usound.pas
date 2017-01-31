unit usound;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ugame, SquallSound;
const
  LevelPrefix = 'level_';
var
  SoundSystem: TSoundSystem;
  SoundManager: TSoundManager;

  SLevelSound: TSound;
implementation

initialization
  SoundSystem := TSoundSystem.Create;
  SoundManager := TSoundManager.Create(SoundSystem);
  SLevelSound := SoundSystem.AddSound('sounds/'+LevelPrefix+
    IntToStr(LevelNumber)+'.ogg',st2D,1);
  SLevelSound.Volume:=100;
  SLevelSound.Play(true);
end.

