unit BookmarksForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TBookmarkItem = class
    TimeMs: Int64;
    Description: string;
  end;

  TFrmBookmarks = class(TForm)
    lstBookmarks: TListBox;
    pnlButtons: TPanel;
    btnAdd: TButton;
    btnJump: TButton;
    btnDelete: TButton;
    btnClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnJumpClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure lstBookmarksDblClick(Sender: TObject);
  private
    FCurrentTimeMs: Int64;
    function FormatTime(AMs: Int64): string;
  public
    OnJumpToTime: procedure(ATimeMs: Int64) of object;
    procedure AfterConstruction; override;
    property CurrentTimeMs: Int64 read FCurrentTimeMs write FCurrentTimeMs;
  end;

var
  FrmBookmarks: TFrmBookmarks;

implementation

uses PlayerDialogs;

{$R *.dfm}

procedure TFrmBookmarks.AfterConstruction;
begin
  inherited;
  ApplyPlayerAppearance(Self);
end;
procedure TFrmBookmarks.FormCreate(Sender: TObject);
begin
  FCurrentTimeMs := 0;
end;

procedure TFrmBookmarks.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lstBookmarks.Items.Count - 1 do
    lstBookmarks.Items.Objects[I].Free;
end;

function TFrmBookmarks.FormatTime(AMs: Int64): string;
var
  TotalSec, H, M, S: Int64;
begin
  if AMs < 0 then AMs := 0;
  TotalSec := AMs div 1000;
  H := TotalSec div 3600;
  M := (TotalSec mod 3600) div 60;
  S := TotalSec mod 60;
  if H > 0 then
    Result := Format('%.2d:%.2d:%.2d', [H, M, S])
  else
    Result := Format('%.2d:%.2d', [M, S]);
end;

procedure TFrmBookmarks.btnAddClick(Sender: TObject);
var
  B: TBookmarkItem;
  Desc, TimeStr: string;
begin
  TimeStr := FormatTime(FCurrentTimeMs);
  Desc := 'Bookmark at ' + TimeStr;
  if not PlayerInput('Add Bookmark', 'Bookmark description', Desc) then Exit;
  if Desc <> '' then
  begin
    B := TBookmarkItem.Create;
    B.TimeMs := FCurrentTimeMs;
    B.Description := Desc;
    lstBookmarks.Items.AddObject(Format('[%s] %s', [TimeStr, Desc]), B);
  end;
end;

procedure TFrmBookmarks.btnJumpClick(Sender: TObject);
var
  B: TBookmarkItem;
begin
  if lstBookmarks.ItemIndex >= 0 then
  begin
    B := TBookmarkItem(lstBookmarks.Items.Objects[lstBookmarks.ItemIndex]);
    if (B <> nil) and Assigned(OnJumpToTime) then
      OnJumpToTime(B.TimeMs);
  end;
end;

procedure TFrmBookmarks.lstBookmarksDblClick(Sender: TObject);
begin
  btnJumpClick(Sender);
end;

procedure TFrmBookmarks.btnDeleteClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lstBookmarks.ItemIndex;
  if Idx >= 0 then
  begin
    lstBookmarks.Items.Objects[Idx].Free;
    lstBookmarks.Items.Delete(Idx);
  end;
end;

procedure TFrmBookmarks.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
