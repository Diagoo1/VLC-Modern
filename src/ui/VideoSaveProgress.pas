unit VideoSaveProgress;

interface

uses System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, OnlineVideoSave;

type
  TVideoSaveProgress = class(TForm)
  private
    FStatus: TLabel;
    FBar: TProgressBar;
    FCancel: TButton;
    procedure CancelClick(Sender: TObject);
    procedure CancelOnClose(Sender: TObject; var CanClose: Boolean);
  public
    Task: IOnlineVideoSave;
    constructor Create(AOwner: TComponent); override;
    procedure UpdateProgress(Percent, RemainingSeconds: Integer);
    procedure RequestCancel;
  end;

implementation

uses System.SysUtils, PlayerDialogs;

constructor TVideoSaveProgress.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Saving YouTube Video';
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;
  ClientWidth := 440;
  ClientHeight := 160;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.SetBounds(24, 24, 392, 24);
  FStatus.Caption := 'Connecting…';

  FBar := TProgressBar.Create(Self);
  FBar.Parent := Self;
  FBar.SetBounds(24, 59, 392, 8);
  FBar.Max := 100;

  FCancel := TButton.Create(Self);
  FCancel.Parent := Self;
  FCancel.SetBounds(295, 98, 120, 34);
  FCancel.Caption := 'Cancel';
  FCancel.OnClick := CancelClick;
  OnCloseQuery := CancelOnClose;
  ApplyPlayerAppearance(Self);
end;

procedure TVideoSaveProgress.UpdateProgress(Percent, RemainingSeconds: Integer);
var
  Estimate: string;
begin
  if not FCancel.Enabled then Exit;
  if Percent < 0 then
  begin
    FStatus.Caption := 'Downloading…';
    Exit;
  end;
  FBar.Position := Percent;
  if Percent = 100 then
    FStatus.Caption := '100% · Verifying MP4…'
  else
  begin
    if RemainingSeconds < 0 then Estimate := 'Estimating time remaining…'
    else Estimate := Format('~%d:%.2d remaining', [RemainingSeconds div 60, RemainingSeconds mod 60]);
    FStatus.Caption := IntToStr(Percent) + '% · ' + Estimate;
  end;
end;

procedure TVideoSaveProgress.RequestCancel;
begin
  if Task <> nil then Task.Cancel;
  FStatus.Caption := 'Cancelling…';
  FCancel.Enabled := False;
end;

procedure TVideoSaveProgress.CancelClick(Sender: TObject);
begin
  RequestCancel;
end;

procedure TVideoSaveProgress.CancelOnClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  RequestCancel;
end;

end.
