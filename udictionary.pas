unit udictionary;

{$mode objfpc}{$H+} {$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils;

type
  TPair = record
    value: Pointer;
    key: string;
    valtype: integer;
    //0 - longint
    //1 - string
    //2 - bool
  end;

  TDictionary = record
    dict: array of TPair;
    procedure AddToDict (AKey: string; AValue: pointer; AValtype: integer);
    function ReturnValue (AKey: string): pointer;
    function ReturnValueType (AKey: string): integer;
  end;

var
  ConfigurationDictionary: TDictionary;
  MapDictionary: TDictionary;
implementation

procedure TDictionary.AddToDict(AKey: string; AValue: pointer; AValtype: integer);
begin
  setlength(dict,length(dict)+1);
  dict[high(dict)].key:= AKey;
  dict[high(dict)].value:= AValue;
  dict[high(dict)].valtype:= AValtype;
end;

function TDictionary.ReturnValue (AKey: string): pointer;
var
  i: integer;
begin
  Result := nil;
  for i := low(dict) to high(dict) do
  begin
    if dict[i].key = AKey then Result := dict[i].value;
  end;
end;

function TDictionary.ReturnValueType (AKey: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := low(dict) to high(dict) do
  begin
    if dict[i].key = AKey then Result := dict[i].valtype;
  end;
end;

end.

