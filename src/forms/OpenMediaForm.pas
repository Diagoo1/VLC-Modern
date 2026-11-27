unit OpenMediaForm;

interface

uses CurvedControls, SettingsStore,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.IniFiles, System.StrUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TFrmOpenMedia = class(TForm)
    PageControl1: TPageControl;
    tabNetwork: TTabSheet;
    tabDisc: TTabSheet;
    tabCapture: TTabSheet;
    pnlBottom: TPanel;
    btnPlay: TPlayerTextButton;
    btnCancel: TPlayerTextButton;

    // Network Tab
    lblNetworkURL: TLabel;
    cboNetworkURL: TComboBox;
    lblNetCaching: TLabel;
    edtNetCaching: TEdit;
    lblNetCachingMs: TLabel;

    // Disc Tab
    grpDiscType: TRadioGroup;
    lblDrive: TLabel;
    cboDrives: TComboBox;

    // Capture Tab
    lblCaptureMode: TLabel;
    cboCaptureMode: TComboBox;
    lblScreenFps: TLabel;
    edtScreenFps: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FSelectedMRL: string;
    FOptions: TStringList;
    FMediaCards: array[0..2] of TModernCardPanel;
    procedure LayoutMedia(Sender: TObject);
    function GetIniPath: string;
    procedure PopulateDrives;
    procedure LoadUrlHistory;
    procedure SaveUrlHistory(const AUrl: string);
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    property SelectedMRL: string read FSelectedMRL;
    property Options: TStringList read FOptions;
  end;

var
  FrmOpenMedia: TFrmOpenMedia;

implementation

uses PlayerDialogs, PlayerLanguage;

{$R *.dfm}

procedure TFrmOpenMedia.AfterConstruction;
begin
  inherited;
  BorderStyle := bsSizeable;
  ClientWidth:=MulDiv(640,CurrentPPI,96);
  ClientHeight:=MulDiv(420,CurrentPPI,96);
  Constraints.MinWidth:=Width;
  Constraints.MinHeight:=Height;
  for var I := 0 to High(FMediaCards) do
  begin
    var Page := PageControl1.Pages[I];
    var Card := TModernCardPanel.Create(Self);
    Card.CardColor := DP_COLOR_SURFACE;
    Card.BorderColor := DP_COLOR_BORDER;
    Card.CornerRadius := 12;
    Card.SetBounds(0, 0, Page.ClientWidth, Page.ClientHeight);
    while Page.ControlCount > 0 do Page.Controls[0].Parent := Card;
    Card.Parent := Page;
    FMediaCards[I] := Card;
  end;
  OnResize:=LayoutMedia;
  ApplyPlayerAppearance(Self);
  if PlayerIsArabic then
  begin
    for var L in [lblNetworkURL, lblNetCaching, lblDrive, lblCaptureMode, lblScreenFps] do
    begin
      L.AutoSize := False;
      L.Alignment := taRightJustify;
    end;
  end;
  LayoutMedia(nil);
end;

procedure TFrmOpenMedia.LayoutMedia(Sender: TObject);
  function S(Value: Integer): Integer;
  begin Result:=MulDiv(Value,CurrentPPI,96); end;
  procedure Place(Control: TControl; X,Y,W,H: Integer);
  begin
    if (Control is TEdit) and (Control.Parent is TModernCardPanel) then Control:=Control.Parent;
    PlaceLocalized(Control, S(X), S(Y), W, S(H));
  end;
begin
  pnlBottom.Height:=S(56);
  PlaceLocalized(btnCancel, pnlBottom.ClientWidth-S(128),S(12),S(104),S(32));
  PlaceLocalized(btnPlay, pnlBottom.ClientWidth-S(244),S(12),S(104),S(32));
  PageControl1.SetBounds(S(16),S(48),ClientWidth-S(32),ClientHeight-S(120));
  PageControl1.TabHeight:=S(36);
  for var Card in FMediaCards do
    if Assigned(Card) then
      Card.SetBounds(S(10), S(12), Card.Parent.ClientWidth-S(20), Card.Parent.ClientHeight-S(24));
  Place(lblNetworkURL,24,24,FMediaCards[0].ClientWidth-S(48),24);
  Place(cboNetworkURL,24,56,FMediaCards[0].ClientWidth-S(48),32);
  Place(lblNetCaching,24,126,S(140),24);
  Place(edtNetCaching,180,120,S(100),32);
  Place(lblNetCachingMs,290,126,S(32),24);
  grpDiscType.SetBounds(S(24),S(24),FMediaCards[1].ClientWidth-S(48),S(80));
  var ChoiceWidth:=(grpDiscType.ClientWidth-S(40)) div 3;
  for var I:=0 to grpDiscType.ControlCount-1 do
    PlaceLocalized(grpDiscType.Controls[I], S(12)+I*(ChoiceWidth+S(8)),S(26),ChoiceWidth,S(40));
  Place(lblDrive,24,126,S(240),24);
  Place(cboDrives,24,156,FMediaCards[1].ClientWidth-S(48),32);
  Place(lblCaptureMode,24,24,S(240),24);
  Place(cboCaptureMode,24,56,FMediaCards[2].ClientWidth-S(48),32);
  Place(lblScreenFps,24,126,S(140),24);
  Place(edtScreenFps,180,120,S(100),32);
end;
function TFrmOpenMedia.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'VLCModern.ini';
end;

procedure TFrmOpenMedia.FormCreate(Sender: TObject);
begin
  FOptions := TStringList.Create;
  PopulateDrives;
  LoadUrlHistory;
end;

destructor TFrmOpenMedia.Destroy;
begin
  FOptions.Free;
  inherited;
end;

procedure TFrmOpenMedia.PopulateDrives;
var
  Drives: DWORD;
  DriveLetter: Char;
  RootPath: string;
  DriveType: UINT;
begin
  cboDrives.Items.Clear;
  Drives := GetLogicalDrives;
  for DriveLetter := 'A' to 'Z' do
  begin
    if (Drives and (1 shl (Ord(DriveLetter) - Ord('A')))) <> 0 then
    begin
      RootPath := DriveLetter + ':\';
      DriveType := GetDriveType(PChar(RootPath));
      if (DriveType = DRIVE_CDROM) or (DriveType = DRIVE_REMOVABLE) then
        cboDrives.Items.Add(RootPath);
    end;
  end;
  if cboDrives.Items.Count > 0 then
    cboDrives.ItemIndex := 0
  else
    cboDrives.Items.Add('D:\');
end;

procedure TFrmOpenMedia.LoadUrlHistory;
var
  Ini: TAppSettings;
  I: Integer;
  Url: string;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    cboNetworkURL.Items.Clear;
    for I := 1 to 10 do
    begin
      Url := Ini.ReadString('NetworkHistory', 'Url' + IntToStr(I), '');
      if Url <> '' then
        cboNetworkURL.Items.Add(Url);
    end;
    if cboNetworkURL.Items.Count > 0 then
      cboNetworkURL.Text := cboNetworkURL.Items[0]
    else
      cboNetworkURL.Text := 'https://';
  finally
    Ini.Free;
  end;
end;

procedure TFrmOpenMedia.SaveUrlHistory(const AUrl: string);
var
  Ini: TAppSettings;
  I: Integer;
begin
  if (AUrl = '') or (AUrl = 'https://') then Exit;
  Ini := TAppSettings.Create(GetIniPath);
  try
    if cboNetworkURL.Items.IndexOf(AUrl) < 0 then
      cboNetworkURL.Items.Insert(0, AUrl);
    for I := 0 to cboNetworkURL.Items.Count - 1 do
    begin
      if I >= 10 then Break;
      Ini.WriteString('NetworkHistory', 'Url' + IntToStr(I + 1), cboNetworkURL.Items[I]);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TFrmOpenMedia.btnPlayClick(Sender: TObject);
begin
  FOptions.Clear;

  if PageControl1.ActivePage = tabNetwork then
  begin
    FSelectedMRL := Trim(cboNetworkURL.Text);
    var Separator := Pos('://', FSelectedMRL);
    var Scheme := LowerCase(Copy(FSelectedMRL, 1, Separator - 1));
    if (Separator = 0) or (Length(FSelectedMRL) <= Separator + 2) or
      not MatchText(Scheme, ['http', 'https', 'rtsp', 'rtmp', 'mms', 'udp', 'rtp', 'srt', 'ftp', 'file']) then
    begin
      PlayerMessage('Please enter a valid network stream URL.');
      Exit;
    end;
    SaveUrlHistory(FSelectedMRL);
    var Cache := StrToIntDef(edtNetCaching.Text, 1500);
    if Cache < 0 then Cache := 0;
    if Cache > 60000 then Cache := 60000;
    FOptions.Add(':network-caching=' + IntToStr(Cache));
  end
  else if PageControl1.ActivePage = tabDisc then
  begin
    var Drive := cboDrives.Text;
    case grpDiscType.ItemIndex of
      0: FSelectedMRL := 'dvd://' + Drive;
      1: FSelectedMRL := 'cdda://' + Drive;
      2: FSelectedMRL := 'bluray://' + Drive;
    end;
  end
  else if PageControl1.ActivePage = tabCapture then
  begin
    if cboCaptureMode.ItemIndex = 0 then
    begin
      FSelectedMRL := 'screen://';
      var Fps := StrToIntDef(edtScreenFps.Text, 30);
      if Fps < 1 then Fps := 1;
      if Fps > 120 then Fps := 120;
      FOptions.Add(Format(':screen-fps=%d', [Fps]));
    end
    else
    begin
      FSelectedMRL := 'dshow://';
    end;
  end;

  ModalResult := mrOk;
end;

procedure TFrmOpenMedia.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
