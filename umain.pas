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
  //writeln('Just test. If you can see that message, then it was compiled successfully.'); //REMOVE THIS
  //readln;//AND THIS
  //InitGraph(GrDrv,GrMode,'');  //SAY NO TO GRAPH!
  screen(Raycaster.ScreenWidth, Raycaster.ScreenHeight, false, 'Raycaster!');
  // !!!!! TODO: make UScreen module to do game drawing stuff there, well, at least just port your shit to UGraphic.
  while (not done()) do Raycaster.PerformRaycast;
  readln;
end.

