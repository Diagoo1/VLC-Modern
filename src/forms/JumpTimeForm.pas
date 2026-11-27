unit JumpTimeForm;

interface

uses CurvedControls, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TFrmJumpTime = class(TForm)
    lblPrompt: TLabel;
    lblH: TLabel;
    lblM: TLabel;
    lblS: TLabel;
    edtH: TEdit;
    edtM: TEdit;
    edtS: TEdit;
    pnlBottom: TPanel;
    btnJump: TPlayerTextButton;
    btnCancel: TPlayerTextButton;
    lblTotal: TLabel;
    procedure btnJumpClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    TotalLengthMs: Int64;
    CurrentTimeMs: Int64;
    procedure AfterConstruction; override;
  end;

var
  FrmJumpTime: TFrmJumpTime;

implementation

uses
  MainForm, LibVLC, PlayerDialogs;

{$R *.dfm}

procedure TFrmJumpTime.AfterConstruction;
begin
  inherited;
  ApplyPlayerAppearance(Self, True);
end;
procedure TFrmJumpTime.FormShow(Sender: TObject);
var
  CurSec, H, M, S: Int64;
  TotSec, TH, TM, TS: Int64;
begin
  if (FrmMain.MediaPlayer <> nil) then
  begin
    CurrentTimeMs := libvlc_media_player_get_time(FrmMain.MediaPlayer);
    TotalLengthMs := libvlc_media_player_get_length(FrmMain.MediaPlayer);
  end;

  CurSec := CurrentTimeMs div 1000;
  H := CurSec div 3600;
  M := (CurSec mod 3600) div 60;
  S := CurSec mod 60;

  edtH.Text := IntToStr(H);
  edtM.Text := IntToStr(M);
  edtS.Text := IntToStr(S);

  TotSec := TotalLengthMs div 1000;
  TH := TotSec div 3600;
  TM := (TotSec mod 3600) div 60;
  TS := TotSec mod 60;
  lblTotal.Caption := Format('Total Duration: %.2d:%.2d:%.2d', [TH, TM, TS]);
  edtS.SetFocus;
end;

procedure TFrmJumpTime.btnJumpClick(Sender: TObject);
var
  H, M, S: Integer;
  TargetMs: Int64;
begin
  H := StrToIntDef(Trim(edtH.Text), 0);
  M := StrToIntDef(Trim(edtM.Text), 0);
  S := StrToIntDef(Trim(edtS.Text), 0);

  TargetMs := (Int64(H) * 3600 + Int64(M) * 60 + Int64(S)) * 1000;

  if (FrmMain.MediaPlayer <> nil) then
  begin
    if TargetMs < 0 then TargetMs := 0;
    if (TotalLengthMs > 0) and (TargetMs > TotalLengthMs) then
      TargetMs := TotalLengthMs;
    FrmMain.SeekTo(TargetMs);
  end;

  ModalResult := mrOk;
end;

procedure TFrmJumpTime.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
