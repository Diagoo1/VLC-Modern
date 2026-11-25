unit VideoSaveProgress;

interface

uses System.SysUtils, System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, OnlineVideoSave;

type
  TVideoSaveProgress = class(TForm)
  private
    FStatus: TLabel;
    FBar: TProgressBar;
    FCancel, FRetry: TButton;
    FRetryAction: TProc;
    procedure RetryClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure CancelOnClose(Sender: TObject; var CanClose: Boolean);
  public
    Task: IOnlineVideoSave;
    constructor Create(AOwner: TComponent); override;
    procedure UpdateProgress(Percent, RemainingSeconds: Integer);
    procedure RequestCancel;
    procedure BeginAttempt;
    procedure ShowInterrupted(const Retry: TProc);
  end;

implementation

uses Winapi.Windows, PlayerDialogs;

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
  FStatus.Caption := 'Connecting...';

  FBar := TProgressBar.Create(Self);
  FBar.Parent := Self;
  FBar.SetBounds(24, 59, 392, 8);
  FBar.Max := 100;

  FCancel := TButton.Create(Self);
  FCancel.Parent := Self;
  FCancel.SetBounds(295, 98, 120, 34);
  FCancel.Caption := 'Cancel';
  FCancel.OnClick := CancelClick;
  FRetry := TButton.Create(Self);
  FRetry.Parent := Self;
  FRetry.SetBounds(164, 98, 120, 34);
  FRetry.Caption := 'Retry';
  FRetry.Visible := False;
  FRetry.OnClick := RetryClick;
  OnCloseQuery := CancelOnClose;
  ApplyPlayerAppearance(Self);
end;

procedure TVideoSaveProgress.BeginAttempt;
begin
  FStatus.AutoSize := True;
  FStatus.WordWrap := False;
  FStatus.Caption := 'Connecting...';
  FBar.Visible := True;
  FBar.Position := 0;
  FRetry.Visible := False;
  FCancel.Caption := 'Cancel';
  FCancel.Enabled := True;
end;

procedure TVideoSaveProgress.ShowInterrupted(const Retry: TProc);
begin
  FRetryAction := Retry;
  FBar.Visible := False;
  FStatus.AutoSize := False;
  FStatus.WordWrap := True;
  FStatus.Width := FBar.Width;
  FStatus.Height := MulDiv(42, CurrentPPI, 96);
  FStatus.Caption := 'The connection was interrupted. The incomplete download was removed.';
  FCancel.Caption := 'Close';
  FCancel.Enabled := True;
  FRetry.Visible := True;
end;

procedure TVideoSaveProgress.RetryClick(Sender: TObject);
begin
  var Retry := FRetryAction;
  FRetryAction := nil;
  if Assigned(Retry) then Retry();
end;

procedure TVideoSaveProgress.UpdateProgress(Percent, RemainingSeconds: Integer);
var
  Estimate: string;
begin
  if not FCancel.Enabled then Exit;
  if Percent < 0 then
  begin
    FStatus.Caption := 'Downloading...';
    Exit;
  end;
  FBar.Position := Percent;
  if Percent = 100 then
    FStatus.Caption := '100% | Verifying MP4...'
  else
  begin
    if RemainingSeconds < 0 then Estimate := 'Estimating time remaining...'
    else Estimate := Format('~%d:%.2d remaining', [RemainingSeconds div 60, RemainingSeconds mod 60]);
    FStatus.Caption := IntToStr(Percent) + '% | ' + Estimate;
  end;
end;

procedure TVideoSaveProgress.RequestCancel;
begin
  if Task <> nil then Task.Cancel;
  FStatus.Caption := 'Cancelling...';
  FCancel.Enabled := False;
end;

procedure TVideoSaveProgress.CancelClick(Sender: TObject);
begin
  if Task = nil then Close else RequestCancel;
end;

procedure TVideoSaveProgress.CancelOnClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Task = nil;
  if not CanClose then RequestCancel;
end;

end.
