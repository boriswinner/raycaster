unit uconfigurator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Math,Forms, Controls, Graphics, Dialogs,
  StdCtrls, uraycaster, ugraphic, utexture, usound, ugame;

type

  { TConfiguratorForm }

  TConfiguratorForm = class(TForm)
    VSyncCheckBox: TCheckBox;
    SoundCheckBox: TCheckBox;
    CloseButton: TButton;
    SoundPathEdit: TEdit;
    SoundPathLabel: TLabel;
    TexturePathLabel: TLabel;
    TexturePathEdit: TEdit;
    FontPathEdit: TEdit;
    FOVEdit: TEdit;
    FullscreenCheckBox: TCheckBox;
    FontPathLabel: TLabel;
    FOVLabel: TLabel;
    WindowHeightEdit: TEdit;
    WindowWidthEdit: TEdit;
    WindowSizeLabel: TLabel;
    procedure CloseButtonClick(Sender: TObject);
    procedure FontPathEditChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FOVEditChange(Sender: TObject);
    procedure FullscreenCheckBoxChange(Sender: TObject);
    procedure SoundCheckBoxChange(Sender: TObject);
    procedure SoundPathEditChange(Sender: TObject);
    procedure TexturePathEditChange(Sender: TObject);
    procedure VSyncCheckBoxChange(Sender: TObject);
    procedure WindowHeightEditChange(Sender: TObject);
    procedure WindowWidthEditChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

//TODO type for all game settings (not level!)
type TConfig = record
  FullscreenMode, SoundOn, VSyncFlag: boolean;
  ScreenWidth, ScreenHeight: integer;
end;

var
  ConfiguratorForm: TConfiguratorForm;
  FullscreenMode, SoundOn: boolean;


implementation

{$R *.lfm}

{ TConfiguratorForm }

procedure TConfiguratorForm.WindowWidthEditChange(Sender: TObject);
begin
  Raycaster.ScreenWidth := StrToIntDef((Sender as TEdit).Text,640);
end;

procedure TConfiguratorForm.WindowHeightEditChange(Sender: TObject);
begin
  Raycaster.ScreenHeight := StrToIntDef((Sender as TEdit).Text,480);
end;

procedure TConfiguratorForm.FullscreenCheckBoxChange(Sender: TObject);
begin
  FullscreenMode := (Sender as TCheckBox).Checked;
end;

procedure TConfiguratorForm.SoundCheckBoxChange(Sender: TObject);
begin
  SoundOn := (Sender as TCheckBox).Checked;
end;

procedure TConfiguratorForm.SoundPathEditChange(Sender: TObject);
begin
  SoundPath := (Sender as TEdit).Text;
end;

procedure TConfiguratorForm.TexturePathEditChange(Sender: TObject);
begin
  TexturePath := (Sender as TEdit).Text;
end;

procedure TConfiguratorForm.VSyncCheckBoxChange(Sender: TObject);
begin
  VSyncFlag := (Sender as TCheckBox).Checked;
end;

procedure TConfiguratorForm.FOVEditChange(Sender: TObject);
begin
  Raycaster.FOV := StrToInt((Sender as TEdit).Text);
  //Raycaster.VPlane.y := StrToFloatDef((Sender as TEdit).Text,66)/100;
  Raycaster.VPlane.x := Game.VDirection.Y*tan(degtorad(Raycaster.FOV/2));
  Raycaster.VPlane.y := -Game.VDirection.X*tan(degtorad(Raycaster.FOV/2));
end;

procedure TConfiguratorForm.FormActivate(Sender: TObject);
begin
  WindowWidthEdit.Text:= IntToStr(Raycaster.ScreenWidth);
  WindowHeightEdit.Text:= IntToStr(Raycaster.ScreenHeight);
  FontPathEdit.Text := FontPath;
  TexturePathEdit.Text := TexturePath;
  SoundPathEdit.Text := SoundPath;
  FOVEdit.Text:=IntToStr(Raycaster.FOV);
end;

procedure TConfiguratorForm.CloseButtonClick(Sender: TObject);
begin
  ConfiguratorForm.Close;
end;

procedure TConfiguratorForm.FontPathEditChange(Sender: TObject);
begin
  FontPath := PChar((Sender as TEdit).Text);
end;

initialization
  SoundOn := true;
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TConfiguratorForm, ConfiguratorForm);
  Application.Run;
  ConfiguratorForm.Show;
  ConfiguratorForm.Destroy;
end.

