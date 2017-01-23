program umain;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, uraycaster, Graph, ugame;
var
  GrDrv, GrMode: smallint;
begin
  writeln('Just test. If you can see that message, then it was compiled successfully.'); //REMOVE THIS
  readln;//AND THIS
  InitGraph(GrDrv,GrMode,'');
  Raycaster.PerformRaycast;
  readln;
end.

