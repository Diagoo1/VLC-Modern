unit MessagesForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Clipbrd, CurvedControls;

type
  TFrmMessages = class(TForm)
    pnlBottom: TPanel;
    btnCopy: TPlayerTextButton;
    btnClear: TPlayerTextButton;
    btnSave: TPlayerTextButton;
    btnClose: TPlayerTextButton;
    memoLog: TMemo;
    SaveDialogLog: TSaveDialog;

    procedure btnCopyClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  public
    procedure AfterConstruction; override;
    procedure LogMsg(const AMsg: string);
  end;

var
  FrmMessages: TFrmMessages;

procedure GlobalLog(const AMsg: string);

implementation

uses PlayerDialogs;

{$R *.dfm}

var
  GLogBuffer: TStringList = nil;

procedure GlobalLog(const AMsg: string);
var
  Timestamped: string;
begin
  Timestamped := Format('[%s] %s', [FormatDateTime('hh:nn:ss.zzz', Now), AMsg]);
  if GLogBuffer = nil then
    GLogBuffer := TStringList.Create;

  GLogBuffer.Add(Timestamped);
  if GLogBuffer.Count > 1000 then
    GLogBuffer.Delete(0);

  if Assigned(FrmMessages) and FrmMessages.Visible then
    FrmMessages.memoLog.Lines.Add(Timestamped);
end;

procedure TFrmMessages.AfterConstruction;
begin
  inherited;
  ApplyPlayerAppearance(Self, True);
  if GLogBuffer <> nil then
    memoLog.Lines.Assign(GLogBuffer);
end;

procedure TFrmMessages.LogMsg(const AMsg: string);
begin
  GlobalLog(AMsg);
end;

procedure TFrmMessages.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText := memoLog.Text;
end;

procedure TFrmMessages.btnClearClick(Sender: TObject);
begin
  memoLog.Clear;
  if GLogBuffer <> nil then
    GLogBuffer.Clear;
end;

procedure TFrmMessages.btnSaveClick(Sender: TObject);
begin
  if SaveDialogLog.Execute then
    memoLog.Lines.SaveToFile(SaveDialogLog.FileName, TEncoding.UTF8);
end;

procedure TFrmMessages.btnCloseClick(Sender: TObject);
begin
  Close;
end;

initialization

finalization
  if GLogBuffer <> nil then
    GLogBuffer.Free;

end.
