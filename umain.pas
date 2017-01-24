program umain;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, uraycaster, ugame, ugraphic;

begin
  screen(Raycaster.ScreenWidth, Raycaster.ScreenHeight, false, 'Raycaster (fix collision plz!)');
  while (not done()) do Raycaster.DrawFrame;
  finish;
end.

