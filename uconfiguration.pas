unit uconfiguration;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, strutils, udictionary;

type TConfig = record
  private
    procedure ReadFromFile(AFileName: string);
  public
    Fullscreen, SoundOn, VSync: boolean;
    ScreenWidth, ScreenHeight, FOV: integer;
    TexturePath, SoundPath, FontPath: string;
end;

var
  Config: TConfig;
implementation

procedure TConfig.ReadFromFile(AFileName: string);
var
  src: TextFile;
  t: string;
  tname, tvalue: string;
  tptr: pointer;
begin
  assign(src, AFileName);
  reset(src);
  readln(src,t);
  if t<>'SIGNATURE RAYCASTERCONFIG' then exit;
  while (not eof(src)) do
  begin
    readln(src,t);
    if (t='') or (t[1]='#') then continue;
    if (ExtractWord(1,t,[' ']) = 'SECTION') then continue;
    tname := (ExtractWord(1,t,[' ']));
    tvalue := (ExtractWord(2,t,[' ']));
    case ConfigurationDictionary.ReturnValueType(tname) of
    0: PInteger((ConfigurationDictionary.ReturnValue(tname)))^ := StrToInt(tvalue);
    1: PString((ConfigurationDictionary.ReturnValue(tname)))^ := tvalue;
    2: PBoolean((ConfigurationDictionary.ReturnValue(tname)))^ := StrToBool(tvalue);
    end;
  end;
  close(src);
end;

initialization

ConfigurationDictionary.AddToDict('ScreenWidth',@Config.ScreenWidth,0);
ConfigurationDictionary.AddToDict('ScreenHeight',@Config.ScreenHeight,0);
ConfigurationDictionary.AddToDict('FullScreen',@Config.FullScreen,2);
ConfigurationDictionary.AddToDict('VSync',@Config.VSync,2);
ConfigurationDictionary.AddToDict('FOV',@Config.FOV,0);
ConfigurationDictionary.AddToDict('TexturePath',@Config.TexturePath,1);
ConfigurationDictionary.AddToDict('SoundPath',@Config.SoundPath,1);
ConfigurationDictionary.AddToDict('FontPath',@Config.FontPath,1);
ConfigurationDictionary.AddToDict('SoundOn',@Config.SoundOn,2);

Config.ReadFromFile('config.txt');

end.

