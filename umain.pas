program umain;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, uraycaster, ugame, ugraphic;
var
  GrDrv, GrMode: smallint;
begin
  screen(Raycaster.ScreenWidth, Raycaster.ScreenHeight, false, 'Raycaster (fix collision plz!)');
  while (not done()) do Raycaster.PerformRaycast;
  finish;
end.

