program umain;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, uraycaster, ugame
  { you can add units after this };
begin
  writeln('Just test. If you can see that message, then it was compiled successfully.'); //REMOVE THIS
  readln;                                                                                //AND THIS
end.

