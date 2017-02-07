unit uconfigurator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Math,Forms, Controls, Graphics, Dialogs,
  StdCtrls, uraycaster, ugraphic, utexture, uconfiguration, usound, ugame;

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

var
  ConfiguratorForm: TConfiguratorForm;
  SoundOn: boolean;


implementation

{$R *.lfm}

{ TConfiguratorForm }

procedure TConfiguratorForm.WindowWidthEditChange(Sender: TObject);
begin
  Config.ScreenWidth := StrToIntDef((Sender as TEdit).Text,640);
end;

procedure TConfiguratorForm.WindowHeightEditChange(Sender: TObject);
begin
  Config.ScreenHeight := StrToIntDef((Sender as TEdit).Text,480);
end;

procedure TConfiguratorForm.FullscreenCheckBoxChange(Sender: TObject);
begin
  Config.Fullscreen := (Sender as TCheckBox).Checked;
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
  Config.VSync := (Sender as TCheckBox).Checked;
end;

procedure TConfiguratorForm.FOVEditChange(Sender: TObject);
begin
  Raycaster.FOV := StrToInt((Sender as TEdit).Text);
  Raycaster.VPlane.x := Game.VDirection.Y*tan(degtorad(Raycaster.FOV/2));
  Raycaster.VPlane.y := -Game.VDirection.X*tan(degtorad(Raycaster.FOV/2));
end;

procedure TConfiguratorForm.FormActivate(Sender: TObject);
begin
  WindowWidthEdit.Text:= IntToStr(Config.ScreenWidth);
  WindowHeightEdit.Text:= IntToStr(Config.ScreenHeight);
  FontPathEdit.Text := FontPath;
  TexturePathEdit.Text := TexturePath;
  SoundPathEdit.Text := SoundPath;
  FOVEdit.Text:=IntToStr(Config.FOV);
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

