unit CustomizeForm;

interface

uses SettingsStore,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  CurvedControls;

type
  TFrmCustomize = class(TForm)
    grpTopBar: TGroupBox;
    chkShowMenuBar: TPlayerCheckBox;
    chkShowLiveTVBtn: TPlayerCheckBox;
    grpBottomDock: TGroupBox;
    chkShowSeekBar: TPlayerCheckBox;
    chkShowTime: TPlayerCheckBox;
    chkShowVolume: TPlayerCheckBox;
    chkShowSpeedBtn: TPlayerCheckBox;
    chkShowEqualizerBtn: TPlayerCheckBox;
    chkShowPlaylistBtn: TPlayerCheckBox;
    chkShowFullscreenBtn: TPlayerCheckBox;
    chkShowAdvControls: TPlayerCheckBox;
    lblDockHeight: TLabel;
    cboDockHeight: TComboBox;
    grpThemeAccent: TGroupBox;
    lblAccentColor: TLabel;
    cboAccentColor: TComboBox;
    lblCornerRadius: TLabel;
    cboCornerRadius: TComboBox;
    pnlBottom: TPanel;
    btnReset: TPlayerTextButton;
    btnApply: TPlayerTextButton;
    btnOK: TPlayerTextButton;
    btnCancel: TPlayerTextButton;

    procedure FormCreate(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FDesignWidth: Integer;
    procedure LayoutCustomize(Sender: TObject);
    function GetIniPath: string;
    procedure LoadSettings;
    procedure SaveSettings;
  public
    procedure AfterConstruction; override;
  end;

var
  FrmCustomize: TFrmCustomize;

implementation

uses PlayerDialogs, MainForm, PlayerLanguage;

{$R *.dfm}

procedure TFrmCustomize.AfterConstruction;
begin
  inherited;
  BorderStyle := bsSizeable;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  ApplyPlayerAppearance(Self, True);
  FDesignWidth := ClientWidth;
  for var Group in [grpTopBar, grpBottomDock, grpThemeAccent] do
    Group.Anchors := [akLeft, akTop, akRight];
  btnReset.Anchors := [akLeft, akTop];
  if PlayerIsArabic then btnReset.Anchors := [akRight, akTop];
  OnResize := LayoutCustomize;
  LayoutCustomize(nil);
end;

procedure TFrmCustomize.LayoutCustomize(Sender: TObject);
begin
  var Extra := (ClientWidth - FDesignWidth) div 2;
  var W := MulDiv(220, CurrentPPI, 96) + Extra;
  cboAccentColor.Width := W;
  cboCornerRadius.Width := W;
  if PlayerIsArabic then
  begin
    cboAccentColor.Left := grpThemeAccent.ClientWidth - W - MulDiv(20, CurrentPPI, 96);
    cboCornerRadius.Left := grpThemeAccent.ClientWidth div 2 - W - MulDiv(12, CurrentPPI, 96);
    btnReset.Caption := Translate('Reset settings');
  end
  else
    cboCornerRadius.Left := grpThemeAccent.ClientWidth div 2 + MulDiv(12, CurrentPPI, 96);
end;

function TFrmCustomize.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'VLCModern.ini';
end;

procedure TFrmCustomize.FormCreate(Sender: TObject);
begin
  LoadSettings;
end;

procedure TFrmCustomize.LoadSettings;
var
  Ini: TAppSettings;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    chkShowMenuBar.Checked := Ini.ReadBool('Interface', 'ShowMenuBar', True);
    chkShowLiveTVBtn.Checked := Ini.ReadBool('Interface', 'ShowLiveTVBtn', True);

    chkShowSeekBar.Checked := Ini.ReadBool('Interface', 'ShowSeekBar', True);
    chkShowTime.Checked := Ini.ReadBool('Interface', 'ShowTime', True);
    chkShowVolume.Checked := Ini.ReadBool('Interface', 'ShowVolume', True);
    chkShowSpeedBtn.Checked := Ini.ReadBool('Interface', 'ShowSpeedBtn', True);
    chkShowEqualizerBtn.Checked := Ini.ReadBool('Interface', 'ShowEqualizerBtn', True);
    chkShowPlaylistBtn.Checked := Ini.ReadBool('Interface', 'ShowPlaylistBtn', True);
    chkShowFullscreenBtn.Checked := Ini.ReadBool('Interface', 'ShowFullscreenBtn', True);
    chkShowAdvControls.Checked := Ini.ReadBool('Interface', 'ShowAdvControls', True);
    cboDockHeight.ItemIndex := Ini.ReadInteger('Interface', 'DockHeightIndex', 1);

    cboAccentColor.ItemIndex := Ini.ReadInteger('Interface', 'AccentColorIndex', 0);
    cboCornerRadius.ItemIndex := Ini.ReadInteger('Interface', 'CornerRadiusIndex', 0);
  finally
    Ini.Free;
  end;
end;

procedure TFrmCustomize.SaveSettings;
var
  Ini: TAppSettings;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    Ini.WriteBool('Interface', 'ShowMenuBar', chkShowMenuBar.Checked);
    Ini.WriteBool('Interface', 'ShowLiveTVBtn', chkShowLiveTVBtn.Checked);

    Ini.WriteBool('Interface', 'ShowSeekBar', chkShowSeekBar.Checked);
    Ini.WriteBool('Interface', 'ShowTime', chkShowTime.Checked);
    Ini.WriteBool('Interface', 'ShowVolume', chkShowVolume.Checked);
    Ini.WriteBool('Interface', 'ShowSpeedBtn', chkShowSpeedBtn.Checked);
    Ini.WriteBool('Interface', 'ShowEqualizerBtn', chkShowEqualizerBtn.Checked);
    Ini.WriteBool('Interface', 'ShowPlaylistBtn', chkShowPlaylistBtn.Checked);
    Ini.WriteBool('Interface', 'ShowFullscreenBtn', chkShowFullscreenBtn.Checked);
    Ini.WriteBool('Interface', 'ShowAdvControls', chkShowAdvControls.Checked);
    Ini.WriteInteger('Interface', 'DockHeightIndex', cboDockHeight.ItemIndex);

    Ini.WriteInteger('Interface', 'AccentColorIndex', cboAccentColor.ItemIndex);
    Ini.WriteInteger('Interface', 'CornerRadiusIndex', cboCornerRadius.ItemIndex);
  finally
    Ini.Free;
  end;

  if Assigned(FrmMain) then
    FrmMain.ApplyInterfaceCustomization;
end;

procedure TFrmCustomize.btnApplyClick(Sender: TObject);
begin
  SaveSettings;
end;

procedure TFrmCustomize.btnOKClick(Sender: TObject);
begin
  SaveSettings;
  ModalResult := mrOk;
end;

procedure TFrmCustomize.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFrmCustomize.btnResetClick(Sender: TObject);
begin
  chkShowMenuBar.Checked := True;
  chkShowLiveTVBtn.Checked := True;
  chkShowSeekBar.Checked := True;
  chkShowTime.Checked := True;
  chkShowVolume.Checked := True;
  chkShowSpeedBtn.Checked := True;
  chkShowEqualizerBtn.Checked := True;
  chkShowPlaylistBtn.Checked := True;
  chkShowFullscreenBtn.Checked := True;
  chkShowAdvControls.Checked := True;
  cboDockHeight.ItemIndex := 1;
  cboAccentColor.ItemIndex := 0;
  cboCornerRadius.ItemIndex := 0;
  PlayerMessage('Default settings restored. Select Apply or OK to save.');
end;

end.
