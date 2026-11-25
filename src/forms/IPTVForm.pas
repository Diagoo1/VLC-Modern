unit IPTVForm;

interface

uses SettingsStore,
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.ShellAPI, System.SysUtils, System.Classes, System.IniFiles,
  System.StrUtils, System.Generics.Collections, System.Types, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Clipbrd, CurvedControls, PlaylistSource, ProgrammeGuide;

type
  TChannelHealth = (chUnknown, chOnline, chOffline, chChecking);

  TIPTVChannel = class
  public
    Name: string;
    Group: string;
    StreamUrl: string;
    LogoUrl: string;
    TvgId: string;
    IsFavorite: Boolean;
    Health: TChannelHealth;
    HealthLatencyMs: Integer;
    HealthCheckedAt: Cardinal;
  end;

  TFrmIPTV = class(TForm)
    pnlTop: TPanel;
    lblSearch: TLabel;
    lblChannelCount: TLabel;
    edtSearch: TEdit;
    btnSwitchServer: TButton;
    btnAddM3U: TButton;
    btnConnectXtream: TButton;
    btnOpenLocalM3U: TButton;
    btnRefresh: TButton;
    btnExportM3U: TButton;
    pnlCategories: TPanel;
    lblCatTitle: TLabel;
    lstCategories: TListBox;
    pnlMain: TPanel;
    lstChannels: TListBox;
    pnlChannelInfo: TPanel;
    lblInfoName: TLabel;
    lblInfoEPG: TLabel;
    lblInfoUrl: TLabel;
    lblInfoBadge: TLabel;
    pnlBottom: TPanel;
    btnWatch: TButton;
    btnFav: TButton;
    btnCopyUrl: TButton;
    btnEPG: TButton;
    btnCheckHealth: TButton;
    btnRecordStream: TButton;
    btnClose: TButton;
    OpenDialogM3U: TOpenDialog;
    SaveDialogExport: TSaveDialog;

    // IPTV Connection Hub / Welcome Portal
    pnlWelcomeHub: TPanel;
    pnlHubCard: TPanel;
    lblHubTitle: TLabel;
    lblHubSubtitle: TLabel;
    grpConnType: TGroupBox;
    rbXtream: TRadioButton;
    rbStalkerMac: TRadioButton;
    rbM3UUrl: TRadioButton;
    rbLocalFile: TRadioButton;
    rbDemo: TRadioButton;
    grpCredentials: TGroupBox;
    lblServerUrl: TLabel;
    edtServerUrl: TEdit;
    btnBrowseFile: TButton;
    lblUsernameOrMac: TLabel;
    edtUsernameOrMac: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    chkRememberPortal: TCheckBox;
    lblPortalHint: TLabel;
    btnConnectPortal: TButton;
    btnCancelHub: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LayoutStudio(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure lstCategoriesClick(Sender: TObject);
    procedure lstChannelsClick(Sender: TObject);
    procedure lstChannelsDblClick(Sender: TObject);
    procedure btnWatchClick(Sender: TObject);
    procedure btnFavClick(Sender: TObject);
    procedure btnCopyUrlClick(Sender: TObject);
    procedure btnEPGClick(Sender: TObject);
    procedure btnCheckHealthClick(Sender: TObject);
    procedure btnRecordStreamClick(Sender: TObject);
    procedure CheckStreamHealth(Channel: TIPTVChannel);
    procedure CheckAllStreamsHealth;
    procedure btnExportM3UClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAddM3UClick(Sender: TObject);
    procedure btnConnectXtreamClick(Sender: TObject);
    procedure btnOpenLocalM3UClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure lstCategoriesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstChannelsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstChannelsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rbConnTypeClick(Sender: TObject);
    procedure btnBrowseFileClick(Sender: TObject);
    procedure btnConnectPortalClick(Sender: TObject);
    procedure btnCancelHubClick(Sender: TObject);
    procedure btnSwitchServerClick(Sender: TObject);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  private
    FChannels: TObjectList<TIPTVChannel>;
    FFilteredChannels: TList<TIPTVChannel>;
    FCategories: TStringList;
    FLastM3USource: string;
    FGuide: TProgrammeGuide;
    FGuideURL: string;
    FLoadingGuide: Boolean;
    FStalkerPortal, FStalkerMAC: string;
    FResolvingStream: Boolean;
    FRequest: IPlaylistRequest;
    FRequestTimer: TTimer;
    FRequestURL: string;
    FLogoCache: TObjectDictionary<string, TGPImage>;
    FLogoPending: TDictionary<string, Boolean>;
    FClosingForm: Boolean;
    procedure EnsureChannelLogoAsync(const AUrl: string);
    procedure BeginStalker(const Portal, MAC: string; const Command: string = '');
    procedure DownloadTick(Sender: TObject);

    procedure ShowConnectionHub(Value: Boolean);
    procedure LoadPortalProfile;
    procedure SavePortalProfile;
    procedure LoadDefaultStreams;
    procedure ParseM3UContent(const AContent: string);
    procedure ParseM3UFile(const AFileName: string);
    procedure DownloadAndParseM3U(const AUrl: string);
    procedure RebuildCategories;
    procedure FilterChannels;
    procedure UpdateChannelInfoPanel;
    procedure LoadFavorites;
    procedure SaveFavorites;
    function GetIniPath: string;
    function SelectedChannel: TIPTVChannel;
  public
    procedure AfterConstruction; override;
    procedure SelectConnectionSource(Kind: Integer);
  private
    FHubShell: TModernCardPanel;
  end;

var
  FrmIPTV: TFrmIPTV;

implementation

uses PlayerPaths, PlayerDialogs, MainForm, System.Net.HttpClient, System.NetEncoding, System.DateUtils, System.IOUtils, System.RegularExpressions, System.Math;

{$R *.dfm}

procedure TFrmIPTV.AfterConstruction;
begin
  inherited;
  ApplyPlayerAppearance(Self);
  FHubShell:=TModernCardPanel.Create(Self);
  FHubShell.Parent:=pnlWelcomeHub;
  FHubShell.CornerRadius:=14;
  FHubShell.CardColor:=DP_COLOR_SURFACE;
  FHubShell.BorderColor:=DP_COLOR_BORDER;
  pnlHubCard.Parent:=FHubShell;
  pnlHubCard.Align:=alClient;
  pnlHubCard.AlignWithMargins:=True;
  pnlHubCard.Margins.SetBounds(8,8,8,8);
  rbConnTypeClick(nil);
  OnResize := LayoutStudio;
  LayoutStudio(nil);
end;

procedure TFrmIPTV.SelectConnectionSource(Kind: Integer);
begin
  case Kind of
    0: rbXtream.Checked:=True;
    1: rbStalkerMac.Checked:=True;
    2: rbM3UUrl.Checked:=True;
    3: rbLocalFile.Checked:=True;
    4: rbDemo.Checked:=True;
  else Exit;
  end;
  ShowConnectionHub(True);
  rbConnTypeClick(nil);
end;

procedure TFrmIPTV.ShowConnectionHub(Value: Boolean);
begin
  pnlCategories.Visible := not Value;
  pnlMain.Visible := not Value;
  pnlTop.Visible := not Value;
  pnlBottom.Visible := not Value;
  pnlWelcomeHub.Visible := Value;
  if Value then pnlWelcomeHub.BringToFront;
  LayoutStudio(nil);
end;

procedure TFrmIPTV.LayoutStudio(Sender: TObject);
var SearchField: TControl; Scale, CardW, ColW, FieldW, HubH: Integer;
  procedure Place(C: TControl; X, Y, W, H: Integer);
  begin
    if (C is TEdit) and (C.Parent is TModernCardPanel) then C:=C.Parent;
    C.SetBounds(MulDiv(X, Scale, 96), MulDiv(Y, Scale, 96),
    MulDiv(W, Scale, 96), MulDiv(H, Scale, 96)); end;
begin
  Scale := CurrentPPI;
  Constraints.MinWidth := MulDiv(920, Scale, 96);
  Constraints.MinHeight := MulDiv(640, Scale, 96);
  pnlBottom.Height:=MulDiv(56,Scale,96);
  btnClose.SetBounds(pnlBottom.ClientWidth-MulDiv(128,Scale,96),MulDiv(12,Scale,96),MulDiv(104,Scale,96),MulDiv(32,Scale,96));
  Place(btnWatch,16,12,112,32);
  Place(btnFav,140,12,112,32);
  Place(btnCopyUrl,264,12,112,32);
  Place(btnEPG,388,12,100,32);
  pnlCategories.Width:=MulDiv(210,Scale,96);
  lblCatTitle.SetBounds(MulDiv(16,Scale,96),MulDiv(16,Scale,96),pnlCategories.ClientWidth-MulDiv(32,Scale,96),MulDiv(24,Scale,96));
  lstCategories.SetBounds(MulDiv(12,Scale,96),MulDiv(48,Scale,96),pnlCategories.ClientWidth-MulDiv(24,Scale,96),pnlCategories.ClientHeight-MulDiv(60,Scale,96));
  pnlTop.Height := MulDiv(90, Scale, 96);
  SearchField := edtSearch;
  if edtSearch.Parent is TModernCardPanel then SearchField := edtSearch.Parent;
  Place(lblSearch, 16, 18, 44, 20);
  Place(SearchField, 66, 12, 260, 28);
  lblChannelCount.SetBounds(pnlTop.ClientWidth - MulDiv(180, Scale, 96),
    MulDiv(18, Scale, 96), MulDiv(160, Scale, 96), MulDiv(20, Scale, 96));
  Place(btnSwitchServer, 16, 50, 132, 30);
  Place(btnAddM3U, 158, 50, 100, 30);
  Place(btnConnectXtream, 268, 50, 100, 30);
  Place(btnOpenLocalM3U, 378, 50, 100, 30);
  Place(btnRefresh, 488, 50, 90, 30);
  Place(btnExportM3U, 588, 50, 100, 30);
  Place(lblHubTitle, 24, 18, 592, 30);
  lblHubTitle.Caption := 'Connect your TV source';
  lblHubTitle.Font.Size := 17;
  Place(lblHubSubtitle, 24, 56, 592, 32);
  lblHubSubtitle.AutoSize := False;
  lblHubSubtitle.WordWrap := True;
  lblHubSubtitle.Caption := 'Choose a source, then enter the details supplied by your provider.';
  grpConnType.Caption := '';
  Place(grpConnType, 24, 100, 592, 100);
  rbXtream.Caption := 'Xtream Codes';
  rbStalkerMac.Caption := 'Stalker / MAC';
  rbM3UUrl.Caption := 'M3U playlist URL';
  rbLocalFile.Caption := 'Local playlist';
  rbDemo.Caption := 'Playback samples';
  Place(rbXtream, 0, 0, 184, 40);
  Place(rbStalkerMac, 198, 0, 184, 40);
  Place(rbM3UUrl, 396, 0, 184, 40);
  Place(rbLocalFile, 0, 50, 184, 40);
  Place(rbDemo, 198, 50, 184, 40);
  Place(grpCredentials, 24, 216, 592, 220);
  grpCredentials.Caption := 'Connection details';
  grpCredentials.Visible := not rbDemo.Checked;
  btnConnectPortal.Caption := 'Connect';
  if FRequest <> nil then btnConnectPortal.Caption := 'Connecting...';
  if rbDemo.Checked then
  begin
    pnlHubCard.Height := MulDiv(290, Scale, 96);
    Place(btnConnectPortal, 24, 220, 184, 40);
    Place(btnCancelHub, 222, 220, 128, 40);
  end
  else
  begin
    pnlHubCard.Height := MulDiv(552, Scale, 96);
    Place(btnConnectPortal, 24, 492, 184, 36);
    Place(btnCancelHub, 222, 492, 128, 36);
  end;
  if FChannels.Count > 0 then btnCancelHub.Caption := 'Back'
  else btnCancelHub.Caption := 'Cancel';
  if FHubShell<>nil then
  begin
    if rbDemo.Checked then HubH:=MulDiv(306,Scale,96)
    else HubH:=MulDiv(568,Scale,96);
    CardW:=Min(MulDiv(688,Scale,96),pnlWelcomeHub.ClientWidth-MulDiv(32,Scale,96));
    FHubShell.SetBounds((pnlWelcomeHub.ClientWidth-CardW) div 2,
      Max(MulDiv(12,Scale,96),(pnlWelcomeHub.ClientHeight-HubH) div 2),CardW,HubH);
    CardW:=MulDiv(pnlHubCard.ClientWidth,96,Scale)-48;
    grpConnType.Width:=MulDiv(CardW,Scale,96);
    ColW:=(CardW-28) div 3;
    Place(rbXtream,0,0,ColW,40);
    Place(rbStalkerMac,ColW+14,0,ColW,40);
    Place(rbM3UUrl,(ColW+14)*2,0,ColW,40);
    Place(rbLocalFile,0,50,ColW,40);
    Place(rbDemo,ColW+14,50,ColW,40);
    Place(grpCredentials,24,220,CardW,252);
    Place(lblServerUrl,18,24,CardW-36,22);
    FieldW:=CardW-36;
    if rbLocalFile.Checked then Dec(FieldW,108);
    Place(edtServerUrl,18,52,FieldW,32);
    Place(btnBrowseFile,CardW-114,52,96,32);
    Place(lblUsernameOrMac,18,100,CardW-36,22);
    FieldW:=CardW-36;
    if rbXtream.Checked then FieldW:=(CardW-48) div 2;
    Place(edtUsernameOrMac,18,126,FieldW,32);
    Place(lblPassword,CardW div 2+6,100,CardW div 2-24,22);
    Place(edtPassword,CardW div 2+6,126,CardW div 2-24,32);
    Place(chkRememberPortal,18,174,CardW-36,24);
    Place(lblPortalHint,18,206,CardW-36,34);
    lblPortalHint.Font.Color:=DP_COLOR_MUTED;
  end
  else
  begin
    pnlHubCard.Left := Max(12, (pnlWelcomeHub.ClientWidth - pnlHubCard.Width) div 2);
    pnlHubCard.Top := Max(12, (pnlWelcomeHub.ClientHeight - pnlHubCard.Height) div 2);
  end;
end;

function TFrmIPTV.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'VLCModern_IPTV.ini';
end;

procedure TFrmIPTV.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  FGuide := TProgrammeGuide.Create;
  FChannels := TObjectList<TIPTVChannel>.Create(True);
  FFilteredChannels := TList<TIPTVChannel>.Create;
  FCategories := TStringList.Create;
  FCategories.Duplicates := dupIgnore;
  FCategories.Sorted := True;
  FRequestTimer := TTimer.Create(Self);
  FRequestTimer.Enabled := False;
  FRequestTimer.Interval := 100;
  FRequestTimer.OnTimer := DownloadTick;

  lstCategories.OnDrawItem := lstCategoriesDrawItem;
  lstChannels.OnDrawItem := lstChannelsDrawItem;
  lstChannels.OnKeyDown := lstChannelsKeyDown;
  edtSearch.OnKeyDown := edtSearchKeyDown;

  LoadPortalProfile;
  rbConnTypeClick(nil);
  ShowConnectionHub(True);
  pnlWelcomeHub.BringToFront;
end;

procedure TFrmIPTV.FormDestroy(Sender: TObject);
begin
  FClosingForm := True;
  DragAcceptFiles(Handle, False);
  FRequestTimer.Enabled := False;
  FRequest := nil;
  if FChannels.Count > 0 then SaveFavorites;
  FFilteredChannels.Free;
  FCategories.Free;
  FChannels.Free;
  FGuide.Free;
  FLogoCache.Free;
  FLogoPending.Free;
end;

procedure TFrmIPTV.WMDropFiles(var Msg: TWMDropFiles);
var
  Count, Len, I: Integer;
  FileName, Ext: string;
begin
  Count := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  try
    for I := 0 to Count - 1 do
    begin
      Len := DragQueryFile(Msg.Drop, I, nil, 0);
      if Len > 0 then
      begin
        SetLength(FileName, Len);
        DragQueryFile(Msg.Drop, I, PChar(FileName), Len + 1);
        if FileExists(FileName) then
        begin
          Ext := LowerCase(ExtractFileExt(FileName));
          if MatchText(Ext, ['.m3u', '.m3u8', '.pls']) then
          begin
            ParseM3UFile(FileName);
            ShowConnectionHub(False);
            Break;
          end;
        end;
      end;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TFrmIPTV.LoadPortalProfile;
var
  Ini: TAppSettings;
  PType: string;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    PType := Ini.ReadString('Portal', 'LastType', 'Xtream');
    edtServerUrl.Text := Ini.ReadString('Portal', 'ServerUrl', 'http://');
    edtUsernameOrMac.Text := Ini.ReadString('Portal', 'UsernameOrMac', '');
    edtPassword.Text := Ini.ReadString('Portal', 'Password', '');
    chkRememberPortal.Checked := Ini.ReadBool('Portal', 'Remember', True);

    if SameText(PType, 'StalkerMac') then rbStalkerMac.Checked := True
    else if SameText(PType, 'M3UUrl') then rbM3UUrl.Checked := True
    else if SameText(PType, 'LocalFile') then rbLocalFile.Checked := True
    else if SameText(PType, 'Demo') then rbDemo.Checked := True
    else rbXtream.Checked := True;
  finally
    Ini.Free;
  end;
end;

procedure TFrmIPTV.SavePortalProfile;
var
  Ini: TAppSettings;
  PType: string;
begin
  if not chkRememberPortal.Checked then Exit;
  Ini := TAppSettings.Create(GetIniPath);
  try
    if rbStalkerMac.Checked then PType := 'StalkerMac'
    else if rbM3UUrl.Checked then PType := 'M3UUrl'
    else if rbLocalFile.Checked then PType := 'LocalFile'
    else if rbDemo.Checked then PType := 'Demo'
    else PType := 'Xtream';

    Ini.WriteString('Portal', 'LastType', PType);
    Ini.WriteString('Portal', 'ServerUrl', edtServerUrl.Text);
    Ini.WriteString('Portal', 'UsernameOrMac', edtUsernameOrMac.Text);
    Ini.WriteString('Portal', 'Password', edtPassword.Text);
    Ini.WriteBool('Portal', 'Remember', chkRememberPortal.Checked);
  finally
    Ini.Free;
  end;
end;

procedure TFrmIPTV.rbConnTypeClick(Sender: TObject);
  procedure FieldVisible(Edit: TEdit; Value: Boolean);
  begin
    Edit.Visible := Value;
    if Edit.Parent is TModernCardPanel then Edit.Parent.Visible := Value;
  end;
begin
  btnBrowseFile.Visible := rbLocalFile.Checked;
  lblPassword.Visible := rbXtream.Checked;
  FieldVisible(edtPassword, rbXtream.Checked);

  if rbXtream.Checked then
  begin
    lblServerUrl.Caption := 'Xtream Server URL (e.g. http://server:8080):';
    lblUsernameOrMac.Visible := True;
    FieldVisible(edtUsernameOrMac, True);
    lblUsernameOrMac.Caption := 'Username:';
    if edtServerUrl.Text = '' then edtServerUrl.Text := 'http://';
    lblPortalHint.Caption := 'Xtream Codes API: imports the provider''s live channel playlist.';
  end
  else if rbStalkerMac.Checked then
  begin
    lblServerUrl.Caption := 'Stalker Portal URL (e.g. http://server:8080/c/):';
    lblUsernameOrMac.Visible := True;
    FieldVisible(edtUsernameOrMac, True);
    lblUsernameOrMac.Caption := 'MAC Address (e.g. 00:1A:79:XX:XX:XX):';
    if edtServerUrl.Text = '' then edtServerUrl.Text := 'http://';
    lblPortalHint.Caption := 'Stalker MAG Portal: authenticate with your registered MAC address (00:1A:79:XX) to load live channels directly.';
  end
  else if rbM3UUrl.Checked then
  begin
    lblServerUrl.Caption := 'Remote M3U / M3U8 Playlist URL:';
    lblUsernameOrMac.Visible := True;
    FieldVisible(edtUsernameOrMac, True);
    lblUsernameOrMac.Caption := 'Playlist Name / Label (Optional):';
    if edtServerUrl.Text = '' then edtServerUrl.Text := 'https://';
    lblPortalHint.Caption := 'M3U / M3U8 Direct Link: imports a channel list with names and category groups.';
  end
  else if rbLocalFile.Checked then
  begin
    lblServerUrl.Caption := 'Local Playlist File Path:';
    lblUsernameOrMac.Visible := False;
    FieldVisible(edtUsernameOrMac, False);
    lblPortalHint.Caption := 'Local File: select any .m3u or .m3u8 playlist file saved on your computer.';
  end
  else if rbDemo.Checked then
  begin
    lblServerUrl.Caption := 'Demo Global Channels (No setup required):';
    lblUsernameOrMac.Visible := False;
    FieldVisible(edtUsernameOrMac, False);
    lblPortalHint.Caption := 'Public HLS and bundled MP4 samples for checking playback.';
  end;
  if Assigned(FRequestTimer) then LayoutStudio(nil);
end;

procedure TFrmIPTV.btnBrowseFileClick(Sender: TObject);
begin
  if OpenDialogM3U.Execute then
    edtServerUrl.Text := OpenDialogM3U.FileName;
end;

procedure TFrmIPTV.btnConnectPortalClick(Sender: TObject);
var
  SUrl, Mac, User, Pass: string;
begin
  SavePortalProfile;
  SUrl := Trim(edtServerUrl.Text);
  User := Trim(edtUsernameOrMac.Text);
  Pass := Trim(edtPassword.Text);

  if rbDemo.Checked then
  begin
    FChannels.Clear;
    LoadDefaultStreams;
    LoadFavorites;
    RebuildCategories;
    FilterChannels;
    UpdateChannelInfoPanel;
    ShowConnectionHub(False);
    Exit;
  end;

  if rbLocalFile.Checked then
  begin
    if (SUrl = '') or not FileExists(SUrl) then
    begin
      PlayerMessage('Please select a valid local .m3u / .m3u8 file.');
      Exit;
    end;
    ParseM3UFile(SUrl);
    if FChannels.Count > 0 then
      ShowConnectionHub(False);
    Exit;
  end;

  if (SUrl = '') or (SUrl = 'http://') or (SUrl = 'https://') then
  begin
    PlayerMessage('Please enter a valid Server or Playlist URL.');
    Exit;
  end;

  if rbXtream.Checked then
  begin
    if (User = '') or (Pass = '') then
    begin
      PlayerMessage('Please enter both Username and Password for Xtream Codes.');
      Exit;
    end;
    while EndsText('/', SUrl) do SetLength(SUrl, Length(SUrl) - 1);
    SUrl := SUrl + '/get.php?username=' + TNetEncoding.URL.Encode(User) + '&password=' + TNetEncoding.URL.Encode(Pass) + '&type=m3u_plus&output=ts';
    DownloadAndParseM3U(SUrl);
  end
  else if rbStalkerMac.Checked then
  begin
    Mac := Trim(edtUsernameOrMac.Text);
    if Mac = '' then
    begin
      PlayerMessage('Please enter your device MAC Address (e.g. 00:1A:79:B1:C2:D3).');
      Exit;
    end;
    if not TRegEx.IsMatch(Mac, '^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$') then
    begin
      PlayerMessage('Enter the MAC address registered with your provider.');
      Exit;
    end;
    FStalkerPortal := SUrl;
    FStalkerMAC := UpperCase(Mac);
    BeginStalker(FStalkerPortal, FStalkerMAC);
  end
  else if rbM3UUrl.Checked then
  begin
    DownloadAndParseM3U(SUrl);
  end;

  if FChannels.Count > 0 then
  begin
    ShowConnectionHub(False);
    UpdateChannelInfoPanel;
  end;
end;

procedure TFrmIPTV.btnSwitchServerClick(Sender: TObject);
begin
  ShowConnectionHub(True);
  pnlWelcomeHub.BringToFront;
end;

procedure TFrmIPTV.btnCancelHubClick(Sender: TObject);
begin
  if FChannels.Count > 0 then
    ShowConnectionHub(False)
  else
    Close;
end;

procedure TFrmIPTV.LoadDefaultStreams;
  procedure AddStream(const AName, AGroup, AUrl: string);
  var
    Ch: TIPTVChannel;
  begin
    Ch := TIPTVChannel.Create;
    Ch.Name := AName;
    Ch.Group := AGroup;
    Ch.StreamUrl := AUrl;
    Ch.IsFavorite := False;
    FChannels.Add(Ch);
  end;
begin
  AddStream('HLS playback sample', 'Playback samples', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8');
  if FileExists(ExtractFilePath(ParamStr(0)) + 'sample.mp4') then
    AddStream('Local video sample', 'Playback samples', ExtractFilePath(ParamStr(0)) + 'sample.mp4');
end;

procedure TFrmIPTV.ParseM3UContent(const AContent: string);
var
  Lines: TStringList;
  I, P, J: Integer;
  Quoted: Boolean;
  Line, NextLine, ExtInf: string;
  Ch: TIPTVChannel;
  function ExtractAttr(const Tag, AttrName: string): string;
  var
    Key: string;
    KPos, VStart, VEnd: Integer;
  begin
    Result := '';
    Key := AttrName + '="';
    KPos := Pos(Key, Tag);
    if KPos > 0 then
    begin
      VStart := KPos + Length(Key);
      VEnd := PosEx('"', Tag, VStart);
      if VEnd > VStart then
        Result := Copy(Tag, VStart, VEnd - VStart);
    end;
  end;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := AContent;
    if Lines.Count > 0 then
    begin
      FGuideURL := ExtractAttr(Lines[0], 'url-tvg');
      if FGuideURL = '' then FGuideURL := ExtractAttr(Lines[0], 'x-tvg-url');
    end;
    FFilteredChannels.Clear;
    FChannels.Clear;

    I := 0;
    while I < Lines.Count do
    begin
      Line := Trim(Lines[I]);
      if StartsText('#EXTINF:', Line) then
      begin
        ExtInf := Line;
        Inc(I);
        while (I < Lines.Count) and ((Trim(Lines[I]) = '') or StartsText('#', Trim(Lines[I]))) do
        begin
          if StartsText('#EXTVLCOPT:', Trim(Lines[I])) then ; // Ignore VLC options
          Inc(I);
        end;

        if I < Lines.Count then
        begin
          NextLine := Trim(Lines[I]);
          if NextLine <> '' then
          begin
            Ch := TIPTVChannel.Create;
            Ch.StreamUrl := NextLine;

            // Extract group-title
            Ch.Group := ExtractAttr(ExtInf, 'group-title');
            if Ch.Group = '' then Ch.Group := 'General';

            // Extract tvg-logo
            Ch.LogoUrl := ExtractAttr(ExtInf, 'tvg-logo');

            // Extract tvg-id
            Ch.TvgId := ExtractAttr(ExtInf, 'tvg-id');

            // Extract Channel Name (after last comma)
            P := 0;
            Quoted := False;
            for J := 1 to Length(ExtInf) do
              if ExtInf[J] = '"' then Quoted := not Quoted
              else if (ExtInf[J] = ',') and not Quoted then
              begin P := J; Break; end;
            if P > 0 then
              Ch.Name := Trim(Copy(ExtInf, P + 1, MaxInt))
            else
            begin
              Ch.Name := ExtractAttr(ExtInf, 'tvg-name');
              if Ch.Name = '' then Ch.Name := 'Channel ' + IntToStr(FChannels.Count + 1);
            end;

            Ch.IsFavorite := False;
            FChannels.Add(Ch);
          end;
        end;
      end;
      Inc(I);
    end;
  finally
    Lines.Free;
  end;

  LoadFavorites;
  RebuildCategories;
  FilterChannels;
end;

procedure TFrmIPTV.ParseM3UFile(const AFileName: string);
var
  S: TStringList;
begin
  if not FileExists(AFileName) then Exit;
  S := TStringList.Create;
  try
    S.LoadFromFile(AFileName, TEncoding.UTF8);
    ParseM3UContent(S.Text);
    FLastM3USource := AFileName;
  finally
    S.Free;
  end;
end;

procedure TFrmIPTV.BeginStalker(const Portal, MAC, Command: string);
begin
  if FRequest <> nil then Exit;
  if not StartsText('http://', Portal) and not StartsText('https://', Portal) then
  begin
    PlayerMessage('Enter an HTTP or HTTPS portal address.');
    Exit;
  end;
  FResolvingStream := Command <> '';
  FRequestURL := Portal;
  FRequest := DownloadStalker(Portal, MAC, Command);
  lblChannelCount.Caption := 'Connecting...';
  btnConnectPortal.Enabled := False;
  btnConnectPortal.Caption := 'Connecting...';
  btnRefresh.Enabled := False;
  FRequestTimer.Enabled := True;
end;

procedure TFrmIPTV.DownloadAndParseM3U(const AUrl: string);
begin
  if FRequest <> nil then Exit;
  if not StartsText('http://', AUrl) and not StartsText('https://', AUrl) then
  begin
    PlayerMessage('Enter an HTTP or HTTPS playlist address.');
    Exit;
  end;
  if not FLoadingGuide then
  begin
    FStalkerPortal := '';
    FStalkerMAC := '';
  end;
  FRequestURL := AUrl;
  FRequest := DownloadPlaylist(AUrl);
  lblChannelCount.Caption := 'Loading...';
  btnConnectPortal.Enabled := False;
  btnConnectPortal.Caption := 'Connecting...';
  btnRefresh.Enabled := False;
  FRequestTimer.Enabled := True;
end;

procedure TFrmIPTV.DownloadTick(Sender: TObject);
var Request: IPlaylistRequest;
begin
  if (FRequest = nil) or not FRequest.Finished then Exit;
  FRequestTimer.Enabled := False;
  Request := FRequest;
  FRequest := nil;
  btnConnectPortal.Enabled := True;
  btnConnectPortal.Caption := 'Connect';
  btnRefresh.Enabled := True;
  if Request.ErrorText <> '' then
  begin
    FLoadingGuide := False;
    FResolvingStream := False;
    lblChannelCount.Caption := 'Connection failed';
    PlayerMessage(Request.ErrorText);
    Exit;
  end;
  if FResolvingStream then
  begin
    FResolvingStream := False;
    if Assigned(FrmMain) then FrmMain.PlayFile(Request.Content);
    Close;
    Exit;
  end;
  if FLoadingGuide then
  begin
    FLoadingGuide := False;
    try
      FGuide.LoadXML(Request.Content);
      var Ch := SelectedChannel;
      if Ch <> nil then
      begin
        var Text := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
        if Text = '' then Text := 'No current programmes match this channel ID.';
        PlayerMessage(Ch.Name + sLineBreak + sLineBreak + Text);
      end;
    except on E: Exception do PlayerMessage('The programme guide could not be read. Select a valid XMLTV file.'); end;
    Exit;
  end;
  ParseM3UContent(Request.Content);
  if FChannels.Count = 0 then
  begin
    PlayerMessage('The source contains no channels. Select an M3U channel playlist.');
    Exit;
  end;
  FLastM3USource := FRequestURL;
  ShowConnectionHub(False);
  UpdateChannelInfoPanel;
end;

function ClassifyMediaKind(Ch: TIPTVChannel): string;
var
  LowerUrl, LowerGroup: string;
begin
  if Ch = nil then Exit('Live TV');
  LowerUrl := LowerCase(Ch.StreamUrl);
  LowerGroup := LowerCase(Ch.Group);
  if ContainsText(LowerUrl, '/series/') or ContainsText(LowerGroup, 'series') or
     TRegEx.IsMatch(Ch.Name, 'S\d{1,2}\s*E\d{1,2}', [roIgnoreCase]) then
    Result := 'Series'
  else if ContainsText(LowerUrl, '/movie/') or EndsText('.mp4', LowerUrl) or
          EndsText('.mkv', LowerUrl) or EndsText('.avi', LowerUrl) or
          ContainsText(LowerGroup, 'vod') or ContainsText(LowerGroup, 'movie') then
    Result := 'Movies / VOD'
  else
    Result := 'Live TV';
end;

procedure TFrmIPTV.RebuildCategories;
var
  Ch: TIPTVChannel;
  I, FavCount, LiveCount, VodCount, SeriesCount: Integer;
  Kind: string;
begin
  FCategories.Clear;
  FavCount := 0;
  LiveCount := 0;
  VodCount := 0;
  SeriesCount := 0;
  for I := 0 to FChannels.Count - 1 do
  begin
    Ch := FChannels[I];
    if Ch.IsFavorite then Inc(FavCount);
    Kind := ClassifyMediaKind(Ch);
    if Kind = 'Series' then Inc(SeriesCount)
    else if Kind = 'Movies / VOD' then Inc(VodCount)
    else Inc(LiveCount);
    if (Ch.Group <> '') and (FCategories.IndexOf(Ch.Group) < 0) then
      FCategories.Add(Ch.Group);
  end;

  lstCategories.Items.BeginUpdate;
  try
    lstCategories.Items.Clear;
    lstCategories.Items.Add(Format('★ Favorites (%d)', [FavCount]));
    lstCategories.Items.Add(Format('All Channels (%d)', [FChannels.Count]));
    if LiveCount > 0 then lstCategories.Items.Add(Format('Live TV (%d)', [LiveCount]));
    if VodCount > 0 then lstCategories.Items.Add(Format('Movies / VOD (%d)', [VodCount]));
    if SeriesCount > 0 then lstCategories.Items.Add(Format('Series (%d)', [SeriesCount]));
    for I := 0 to FCategories.Count - 1 do
    begin
      var CatName := FCategories[I];
      var CatCount := 0;
      for var J := 0 to FChannels.Count - 1 do
        if SameText(FChannels[J].Group, CatName) then Inc(CatCount);
      lstCategories.Items.Add(Format('%s (%d)', [CatName, CatCount]));
    end;
  finally
    lstCategories.Items.EndUpdate;
  end;

  if lstCategories.Items.Count > 1 then
    lstCategories.ItemIndex := 1; // Default to 'All Channels'
end;

procedure TFrmIPTV.FilterChannels;
var
  I: Integer;
  Ch: TIPTVChannel;
  SelectedCat, CleanCat, SearchQuery: string;
  MatchesCat, MatchesSearch: Boolean;
begin
  SelectedCat := 'All Channels';
  if lstCategories.ItemIndex >= 0 then
    SelectedCat := lstCategories.Items[lstCategories.ItemIndex];

  CleanCat := SelectedCat;
  var ParenPos := Pos(' (', CleanCat);
  if ParenPos > 0 then CleanCat := Copy(CleanCat, 1, ParenPos - 1);

  SearchQuery := LowerCase(Trim(edtSearch.Text));

  FFilteredChannels.Clear;
  lstChannels.Items.BeginUpdate;
  try
    lstChannels.Items.Clear;
    for I := 0 to FChannels.Count - 1 do
    begin
      Ch := FChannels[I];

      if StartsText('★ Favorites', CleanCat) then
        MatchesCat := Ch.IsFavorite
      else if StartsText('All Channels', CleanCat) then
        MatchesCat := True
      else if SameText(CleanCat, 'Live TV') or SameText(CleanCat, 'Movies / VOD') or SameText(CleanCat, 'Series') then
        MatchesCat := SameText(ClassifyMediaKind(Ch), CleanCat)
      else
        MatchesCat := SameText(Ch.Group, CleanCat);

      if MatchesCat then
      begin
        if SearchQuery = '' then
          MatchesSearch := True
        else
          MatchesSearch := (Pos(SearchQuery, LowerCase(Ch.Name)) > 0) or
                           (Pos(SearchQuery, LowerCase(Ch.Group)) > 0);

        if MatchesSearch then
        begin
          FFilteredChannels.Add(Ch);
          lstChannels.Items.Add(Ch.Name);
        end;
      end;
    end;
  finally
    lstChannels.Items.EndUpdate;
  end;

  lblChannelCount.Caption := Format('%d Channels', [FFilteredChannels.Count]);
  if lstChannels.Items.Count > 0 then
    lstChannels.ItemIndex := 0;
  UpdateChannelInfoPanel;
end;

procedure TFrmIPTV.LoadFavorites;
var
  Ini: TAppSettings;
  FavList: TStringList;
  I, J: Integer;
begin
  Ini := TAppSettings.Create(GetIniPath);
  FavList := TStringList.Create;
  try
    Ini.ReadSection('Favorites', FavList);
    for I := 0 to FChannels.Count - 1 do
    begin
      for J := 0 to FavList.Count - 1 do
      begin
        if SameText(FChannels[I].StreamUrl, FavList[J]) or SameText(FChannels[I].Name, FavList[J]) then
        begin
          FChannels[I].IsFavorite := True;
          Break;
        end;
      end;
    end;
  finally
    FavList.Free;
    Ini.Free;
  end;
end;

procedure TFrmIPTV.SaveFavorites;
var
  Ini: TAppSettings;
  I: Integer;
begin
  Ini := TAppSettings.Create(GetIniPath);
  try
    Ini.EraseSection('Favorites');
    for I := 0 to FChannels.Count - 1 do
    begin
      if FChannels[I].IsFavorite then
        Ini.WriteString('Favorites', FChannels[I].StreamUrl, FChannels[I].Name);
    end;
  finally
    Ini.Free;
  end;
end;

function TFrmIPTV.SelectedChannel: TIPTVChannel;
begin
  Result := nil;
  if (lstChannels.ItemIndex >= 0) and (lstChannels.ItemIndex < FFilteredChannels.Count) then
    Result := FFilteredChannels[lstChannels.ItemIndex];
end;

procedure TFrmIPTV.edtSearchChange(Sender: TObject);
begin
  FilterChannels;
end;

procedure TFrmIPTV.edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    edtSearch.Text := '';
    Key := 0;
  end
  else if (Key = VK_DOWN) and (lstChannels.Count > 0) then
  begin
    lstChannels.SetFocus;
    if lstChannels.ItemIndex < 0 then
      lstChannels.ItemIndex := 0;
    Key := 0;
  end;
end;

procedure TFrmIPTV.lstChannelsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
    begin
      btnWatchClick(nil);
      Key := 0;
    end;
    VK_SPACE, Ord('F'):
    begin
      btnFavClick(nil);
      Key := 0;
    end;
    Ord('H'), Ord('C'):
    begin
      btnCheckHealthClick(nil);
      Key := 0;
    end;
  end;
end;

procedure TFrmIPTV.lstCategoriesClick(Sender: TObject);
begin
  FilterChannels;
end;

procedure TFrmIPTV.lstChannelsClick(Sender: TObject);
begin
  UpdateChannelInfoPanel;
end;

procedure TFrmIPTV.UpdateChannelInfoPanel;
var
  Ch: TIPTVChannel;
  FmtBadge, HealthStr: string;
begin
  Ch := SelectedChannel;
  if Ch = nil then
  begin
    lblInfoName.Caption := 'Select a Channel...';
    lblInfoEPG.Caption := 'EPG: No channel selected';
    lblInfoUrl.Caption := 'Stream URL: None';
    lblInfoBadge.Caption := '';
    btnFav.Caption := 'Add to Favorites';
    Exit;
  end;

  lblInfoName.Caption := Ch.Name;

  // EPG Program Info (IPTVnator)
  if (FGuide <> nil) and (Ch.TvgId <> '') then
  begin
    var CurProg := FGuide.GetCurrentProgram(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
    if CurProg.HasProgram then
    begin
      var ProgStr := Format('NOW: %s (%s - %s) [%d%%]', [
        CurProg.CurrentTitle,
        FormatDateTime('hh:nn', CurProg.CurrentStartLocal),
        FormatDateTime('hh:nn', CurProg.CurrentEndLocal),
        CurProg.ProgressPercent
      ]);
      if CurProg.NextTitle <> '' then
        ProgStr := ProgStr + Format('  |  NEXT: %s (%s)', [
          CurProg.NextTitle,
          FormatDateTime('hh:nn', CurProg.NextStartLocal)
        ]);
      lblInfoEPG.Caption := ProgStr;
    end
    else
    begin
      var Desc := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
      if Desc <> '' then
        lblInfoEPG.Caption := 'UPCOMING: ' + StringReplace(Trim(Desc), sLineBreak, '  |  ', [rfReplaceAll])
      else
        lblInfoEPG.Caption := Format('Category: %s | EPG ID: %s', [Ch.Group, Ch.TvgId]);
    end;
  end
  else if Ch.Group <> '' then
    lblInfoEPG.Caption := Format('Category: %s | EPG ID: %s', [Ch.Group, Ch.TvgId])
  else
    lblInfoEPG.Caption := 'No programme guide loaded';

  lblInfoUrl.Caption := 'URL: ' + Ch.StreamUrl;

  if Pos('.m3u8', LowerCase(Ch.StreamUrl)) > 0 then
    FmtBadge := '[HLS Live Stream]'
  else if Pos('.ts', LowerCase(Ch.StreamUrl)) > 0 then
    FmtBadge := '[MPEG-TS Live Stream]'
  else if Pos('.mp4', LowerCase(Ch.StreamUrl)) > 0 then
    FmtBadge := '[VOD Movie MP4]'
  else
    FmtBadge := '[Live Stream]';

  case Ch.Health of
    chOnline:   HealthStr := Format('ONLINE (%dms)', [Ch.HealthLatencyMs]);
    chOffline:  HealthStr := 'OFFLINE (Broken Stream)';
    chChecking: HealthStr := 'CHECKING...';
  else
    HealthStr := 'Stream Health: Untested';
  end;

  lblInfoBadge.Caption := Format('%s  |  %s', [HealthStr, FmtBadge]);

  if Ch.IsFavorite then
    btnFav.Caption := 'Remove Favorite'
  else
    btnFav.Caption := 'Add to Favorites';
end;

procedure TFrmIPTV.lstChannelsDblClick(Sender: TObject);
begin
  btnWatchClick(Sender);
end;

procedure TFrmIPTV.btnWatchClick(Sender: TObject);
var
  Ch: TIPTVChannel;
  Opts: TStringList;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;

  if StartsText('stalker-cmd://', Ch.StreamUrl) then
  begin
    BeginStalker(FStalkerPortal, FStalkerMAC,
      TNetEncoding.URL.Decode(Copy(Ch.StreamUrl, Length('stalker-cmd://') + 1, MaxInt)));
    Exit;
  end;

  if Assigned(FrmMain) then
  begin
    Opts := TStringList.Create;
    try
      Opts.Add(':network-caching=2000');
      Opts.Add(':http-user-agent=IPTVSmartersPlayer');
      FrmMain.PlayFile(Ch.StreamUrl, Opts);
    finally
      Opts.Free;
    end;
    FrmMain.ShowOSD('IPTV Live: ' + Ch.Name);
    Close;
  end;
end;

procedure TFrmIPTV.btnRecordStreamClick(Sender: TObject);
var
  Ch: TIPTVChannel;
  Opts: TStringList;
  RecDir, RecFile: string;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;

  if Assigned(FrmMain) then
  begin
    RecDir := PlayerDataPath('recordings');
    System.SysUtils.ForceDirectories(RecDir);
    RecFile := TPath.Combine(RecDir, Format('IPTV_%s_%s.ts', [
      TRegEx.Replace(Ch.Name, '[^\w\-]', '_'),
      FormatDateTime('yyyymmdd_hhnnss', Now)
    ]));

    Opts := TStringList.Create;
    try
      Opts.Add(':network-caching=3000');
      Opts.Add(':http-user-agent=IPTVSmartersPlayer');
      Opts.Add(Format(':sout=#duplicate{dst=display,dst=std{access=file,mux=ts,dst=''%s''}}', [RecFile]));
      FrmMain.PlayFile(Ch.StreamUrl, Opts);
    finally
      Opts.Free;
    end;
    FrmMain.ShowOSD('Recording IPTV Live: ' + ExtractFileName(RecFile));
    Close;
  end;
end;

procedure TFrmIPTV.btnEPGClick(Sender: TObject);
var Ch: TIPTVChannel; Text: string; Dialog: TOpenDialog;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;
  Text := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
  if Text <> '' then
  begin
    PlayerMessage(Ch.Name + sLineBreak + sLineBreak + Text);
    Exit;
  end;
  if (FGuideURL <> '') and (FRequest = nil) then
  begin
    FLoadingGuide := True;
    DownloadAndParseM3U(FGuideURL);
    FGuideURL := '';
    Exit;
  end;
  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Title := 'Import an XMLTV programme guide';
    Dialog.Filter := 'XMLTV guide (*.xml)|*.xml';
    if not Dialog.Execute then Exit;
    try
      FGuide.LoadXML(TFile.ReadAllText(Dialog.FileName, TEncoding.UTF8));
      Text := FGuide.Describe(Ch.TvgId, TTimeZone.Local.ToUniversalTime(Now));
      if Text = '' then Text := 'No current programmes match this channel ID in the selected guide.';
      PlayerMessage(Ch.Name + sLineBreak + sLineBreak + Text);
    except on E: Exception do PlayerMessage('The programme guide could not be read. Select a valid XMLTV file.'); end;
  finally Dialog.Free; end;
end;

procedure TFrmIPTV.CheckStreamHealth(Channel: TIPTVChannel);
begin
  if (Channel = nil) or (Channel.StreamUrl = '') then Exit;
  Channel.Health := chChecking;
  lstChannels.Invalidate;
  UpdateChannelInfoPanel;

  var TargetUrl := Channel.StreamUrl;
  TThread.CreateAnonymousThread(
    procedure
    var
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
      TStart: Cardinal;
      IsOnline: Boolean;
      Latency: Integer;
    begin
      IsOnline := False;
      Latency := 0;
      HTTP := THTTPClient.Create;
      try
        HTTP.ConnectionTimeout := 3000;
        HTTP.ResponseTimeout := 3500;
        HTTP.UserAgent := 'VLC Modern IPTV Engine/1.0';
        TStart := GetTickCount;
        try
          Resp := HTTP.Head(TargetUrl);
          if (Resp = nil) or (Resp.StatusCode = 405) then
            Resp := HTTP.Get(TargetUrl);
          if (Resp <> nil) and ((Resp.StatusCode = 200) or (Resp.StatusCode = 206) or
             ((Resp.StatusCode >= 300) and (Resp.StatusCode < 400))) then
          begin
            IsOnline := True;
            Latency := GetTickCount - TStart;
          end;
        except
          IsOnline := False;
        end;
      finally
        HTTP.Free;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          if IsOnline then
          begin
            Channel.Health := chOnline;
            Channel.HealthLatencyMs := Latency;
          end
          else
          begin
            Channel.Health := chOffline;
            Channel.HealthLatencyMs := 0;
          end;
          Channel.HealthCheckedAt := GetTickCount;
          lstChannels.Invalidate;
          UpdateChannelInfoPanel;
        end
      );
    end
  ).Start;
end;

procedure TFrmIPTV.CheckAllStreamsHealth;
var
  I: Integer;
begin
  if FFilteredChannels.Count = 0 then Exit;
  if Assigned(FrmMain) then
    FrmMain.ShowOSD(Format('Probing %d IPTV channels health...', [FFilteredChannels.Count]));

  for I := 0 to FFilteredChannels.Count - 1 do
    FFilteredChannels[I].Health := chChecking;
  lstChannels.Invalidate;

  TThread.CreateAnonymousThread(
    procedure
    var
      I: Integer;
      Ch: TIPTVChannel;
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
      TStart: Cardinal;
      IsOnline: Boolean;
      Latency: Integer;
    begin
      HTTP := THTTPClient.Create;
      try
        HTTP.ConnectionTimeout := 2500;
        HTTP.ResponseTimeout := 3000;
        HTTP.UserAgent := 'VLC Modern IPTV Engine/1.0';

        for I := 0 to FFilteredChannels.Count - 1 do
        begin
          Ch := FFilteredChannels[I];
          if Ch = nil then Continue;
          IsOnline := False;
          Latency := 0;
          TStart := GetTickCount;
          try
            Resp := HTTP.Head(Ch.StreamUrl);
            if (Resp = nil) or (Resp.StatusCode = 405) then
              Resp := HTTP.Get(Ch.StreamUrl);
            if (Resp <> nil) and ((Resp.StatusCode = 200) or (Resp.StatusCode = 206) or
               ((Resp.StatusCode >= 300) and (Resp.StatusCode < 400))) then
            begin
              IsOnline := True;
              Latency := GetTickCount - TStart;
            end;
          except
            IsOnline := False;
          end;

          TThread.Synchronize(nil,
            procedure
            begin
              if IsOnline then
              begin
                Ch.Health := chOnline;
                Ch.HealthLatencyMs := Latency;
              end
              else
              begin
                Ch.Health := chOffline;
                Ch.HealthLatencyMs := 0;
              end;
              Ch.HealthCheckedAt := GetTickCount;
              lstChannels.Invalidate;
            end
          );
        end;
      finally
        HTTP.Free;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          if Assigned(FrmMain) then
            FrmMain.ShowOSD('Channel health check completed');
          UpdateChannelInfoPanel;
        end
      );
    end
  ).Start;
end;

procedure TFrmIPTV.btnCheckHealthClick(Sender: TObject);
begin
  if (SelectedChannel <> nil) and not (GetKeyState(VK_SHIFT) < 0) then
    CheckStreamHealth(SelectedChannel)
  else
    CheckAllStreamsHealth;
end;

procedure TFrmIPTV.btnExportM3UClick(Sender: TObject);
var
  S: TStringList;
  I: Integer;
  Ch: TIPTVChannel;
begin
  if SaveDialogExport.Execute then
  begin
    S := TStringList.Create;
    try
      S.Add('#EXTM3U');
      for I := 0 to FFilteredChannels.Count - 1 do
      begin
        Ch := FFilteredChannels[I];
        S.Add(Format('#EXTINF:-1 tvg-id="%s" tvg-name="%s" group-title="%s" tvg-logo="%s",%s',
          [Ch.TvgId, Ch.Name, Ch.Group, Ch.LogoUrl, Ch.Name]));
        S.Add(Ch.StreamUrl);
      end;
      S.SaveToFile(SaveDialogExport.FileName, TEncoding.UTF8);
      if Assigned(FrmMain) then
        FrmMain.ShowOSD(Format('Exported %d channels to M3U.', [FFilteredChannels.Count]));
    finally
      S.Free;
    end;
  end;
end;

procedure TFrmIPTV.btnFavClick(Sender: TObject);
var
  Ch: TIPTVChannel;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;

  Ch.IsFavorite := not Ch.IsFavorite;
  SaveFavorites;
  RebuildCategories;
  lstChannels.Invalidate;
  UpdateChannelInfoPanel;
  if Assigned(FrmMain) then
  begin
    if Ch.IsFavorite then
      FrmMain.ShowOSD('Added to Favorites: ' + Ch.Name)
    else
      FrmMain.ShowOSD('Removed from Favorites: ' + Ch.Name);
  end;
end;

procedure TFrmIPTV.btnCopyUrlClick(Sender: TObject);
var
  Ch: TIPTVChannel;
begin
  Ch := SelectedChannel;
  if Ch = nil then Exit;
  Clipboard.AsText := Ch.StreamUrl;
  if Assigned(FrmMain) then FrmMain.ShowOSD('Stream URL copied to clipboard.');
end;

procedure TFrmIPTV.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmIPTV.btnAddM3UClick(Sender: TObject);
begin
  rbM3UUrl.Checked := True;
  rbConnTypeClick(nil);
  btnSwitchServerClick(nil);
end;

procedure TFrmIPTV.btnConnectXtreamClick(Sender: TObject);
begin
  rbXtream.Checked := True;
  rbConnTypeClick(nil);
  btnSwitchServerClick(nil);
end;

procedure TFrmIPTV.btnOpenLocalM3UClick(Sender: TObject);
begin
  if OpenDialogM3U.Execute then
    ParseM3UFile(OpenDialogM3U.FileName);
end;

procedure TFrmIPTV.btnRefreshClick(Sender: TObject);
begin
  if FStalkerPortal <> '' then
  begin
    BeginStalker(FStalkerPortal, FStalkerMAC);
    Exit;
  end;
  if FLastM3USource <> '' then
  begin
    if StartsText('http://', FLastM3USource) or StartsText('https://', FLastM3USource) then
      DownloadAndParseM3U(FLastM3USource)
    else
      ParseM3UFile(FLastM3USource);
  end
  else
  begin
    FChannels.Clear;
    LoadDefaultStreams;
    LoadFavorites;
    RebuildCategories;
    FilterChannels;
  end;
end;

procedure TFrmIPTV.lstCategoriesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Canvas: TCanvas;
  Text: string;
  TextR: TRect;
  IsSel: Boolean;
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Path: TGPGraphicsPath;
  R: TRect;
begin
  if (Index < 0) or (Index >= lstCategories.Items.Count) then Exit;
  Canvas := lstCategories.Canvas;
  IsSel := (odSelected in State) or (odFocused in State);

  Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(Rect);

  R := Rect;
  InflateRect(R, -4, -2);

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(R.Left, R.Top, 6, 6, 180, 90);
      Path.AddArc(R.Right - 6, R.Top, 6, 6, 270, 90);
      Path.AddArc(R.Right - 6, R.Bottom - 6, 6, 6, 0, 90);
      Path.AddArc(R.Left, R.Bottom - 6, 6, 6, 90, 90);
      Path.CloseFigure;

      if IsSel then
        Brush := TGPSolidBrush.Create(MakeColor(255, 30, 58, 74))
      else
        Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ELEVATED));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      if IsSel then
        Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_ACCENT), 1.2)
      else
        Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 1.0);
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;
  finally
    G.Free;
  end;

  Text := lstCategories.Items[Index];
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 9;
  if IsSel then
  begin
    Canvas.Font.Color := DP_COLOR_ACCENT;
    Canvas.Font.Style := [fsBold];
  end
  else
  begin
    Canvas.Font.Color := DP_COLOR_TEXT;
    Canvas.Font.Style := [];
  end;

  TextR := R;
  Inc(TextR.Left, 10);
  DrawText(Canvas.Handle, PChar(Text), Length(Text), TextR, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
end;

procedure TFrmIPTV.lstChannelsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Canvas: TCanvas;
  Ch: TIPTVChannel;
  TextR, BadgeR, NumR: TRect;
  IsSel: Boolean;
  G: TGPGraphics;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  Path: TGPGraphicsPath;
  LogoImg: TGPImage;
  R: TRect;
  NumStr, FmtBadge: string;
begin
  if (Index < 0) or (Index >= FFilteredChannels.Count) then Exit;
  Ch := FFilteredChannels[Index];
  Canvas := lstChannels.Canvas;
  IsSel := (odSelected in State) or (odFocused in State);

  Canvas.Brush.Color := DP_COLOR_SURFACE;
  Canvas.FillRect(Rect);

  R := Rect;
  InflateRect(R, -4, -3);

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(R.Left, R.Top, 8, 8, 180, 90);
      Path.AddArc(R.Right - 8, R.Top, 8, 8, 270, 90);
      Path.AddArc(R.Right - 8, R.Bottom - 8, 8, 8, 0, 90);
      Path.AddArc(R.Left, R.Bottom - 8, 8, 8, 90, 90);
      Path.CloseFigure;

      if IsSel then
        Brush := TGPSolidBrush.Create(MakeColor(255, 35, 45, 55))
      else
        Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ELEVATED));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      if IsSel then
        Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_ACCENT), 1.5)
      else
        Pen := TGPPen.Create(MakeGDIColor(DP_COLOR_BORDER), 1.0);
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

    if IsSel then
    begin
      Brush := TGPSolidBrush.Create(MakeGDIColor(DP_COLOR_ACCENT));
      try
        G.FillRectangle(Brush, Single(R.Left + 2), Single(R.Top + 6), 4.0, Single(R.Height - 12));
      finally
        Brush.Free;
      end;
    end;

    // Stream Health status dot (IPTVnator)
    case Ch.Health of
      chOnline:   Brush := TGPSolidBrush.Create(MakeColor(255, 16, 185, 129)); // Vibrant Green
      chOffline:  Brush := TGPSolidBrush.Create(MakeColor(255, 239, 68, 68));  // Red
      chChecking: Brush := TGPSolidBrush.Create(MakeColor(255, 245, 158, 11)); // Amber
    else
      Brush := TGPSolidBrush.Create(MakeColor(255, 100, 116, 139)); // Slate Gray
    end;
    try
      G.FillEllipse(Brush, Single(R.Left + 12), Single(R.Top + (R.Height div 2) - 4), 8.0, 8.0);
    finally
      Brush.Free;
    end;

    // Format badge pill
    if Pos('.m3u8', LowerCase(Ch.StreamUrl)) > 0 then
      FmtBadge := 'HLS HD'
    else if Pos('.mp4', LowerCase(Ch.StreamUrl)) > 0 then
      FmtBadge := 'VOD 1080p'
    else
      FmtBadge := 'LIVE TS';

    BadgeR := System.Types.Rect(R.Right - 86, R.Top + 7, R.Right - 10, R.Bottom - 7);
    Path := TGPGraphicsPath.Create;
    try
      Path.AddArc(BadgeR.Left, BadgeR.Top, 6, 6, 180, 90);
      Path.AddArc(BadgeR.Right - 6, BadgeR.Top, 6, 6, 270, 90);
      Path.AddArc(BadgeR.Right - 6, BadgeR.Bottom - 6, 6, 6, 0, 90);
      Path.AddArc(BadgeR.Left, BadgeR.Bottom - 6, 6, 6, 90, 90);
      Path.CloseFigure;

      Brush := TGPSolidBrush.Create(MakeColor(255, 24, 34, 44));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      Pen := TGPPen.Create(MakeColor(255, 45, 75, 100), 1.0);
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

    // Render cached tvg-logo image if available, or trigger async download
    if Ch.LogoUrl <> '' then
    begin
      LogoImg := nil;
      if (FLogoCache <> nil) and FLogoCache.TryGetValue(Ch.LogoUrl, LogoImg) and (LogoImg <> nil) then
        G.DrawImage(LogoImg, Single(R.Left + 62), Single(R.Top + (R.Height - 22) div 2), 22.0, 22.0)
      else
        EnsureChannelLogoAsync(Ch.LogoUrl);
    end;
  finally
    G.Free;
  end;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := DP_COLOR_ACCENT;
  DrawText(Canvas.Handle, PChar(FmtBadge), Length(FmtBadge), BadgeR, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

  NumStr := Format('%02d', [Index + 1]);
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [];
  Canvas.Font.Color := DP_COLOR_MUTED;
  NumR := System.Types.Rect(R.Left + 26, R.Top, R.Left + 56, R.Bottom);
  DrawText(Canvas.Handle, PChar(NumStr), Length(NumStr), NumR, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

  if Ch.IsFavorite then
  begin
    Canvas.Font.Size := 10;
    Canvas.Font.Color := RGB(255, 204, 0);
    Canvas.TextOut(R.Left + 58, R.Top + (R.Height - Canvas.TextHeight('★')) div 2, '★');
  end;

  Canvas.Font.Size := 10;
  if IsSel then
  begin
    Canvas.Font.Color := DP_COLOR_ACCENT;
    Canvas.Font.Style := [fsBold];
  end
  else
  begin
    Canvas.Font.Color := DP_COLOR_TEXT;
    Canvas.Font.Style := [];
  end;

  if Ch.LogoUrl <> '' then
  begin
    if (FLogoCache <> nil) and FLogoCache.ContainsKey(Ch.LogoUrl) then
      TextR := System.Types.Rect(R.Left + 92, R.Top, BadgeR.Left - 10, R.Bottom)
    else
    begin
      Canvas.Font.Size := 7;
      Canvas.Font.Color := RGB(100, 200, 255);
      Canvas.Font.Style := [fsBold];
      Canvas.TextOut(R.Left + 72, R.Top + (R.Height - Canvas.TextHeight('TV')) div 2, 'TV');
      TextR := System.Types.Rect(R.Left + 92, R.Top, BadgeR.Left - 10, R.Bottom);
    end;
  end
  else
    TextR := System.Types.Rect(R.Left + 76, R.Top, BadgeR.Left - 10, R.Bottom);
  DrawText(Canvas.Handle, PChar(Ch.Name), Length(Ch.Name), TextR, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
end;

procedure TFrmIPTV.EnsureChannelLogoAsync(const AUrl: string);
begin
  if FClosingForm or (AUrl = '') then Exit;
  if FLogoCache = nil then FLogoCache := TObjectDictionary<string, TGPImage>.Create([doOwnsValues]);
  if FLogoPending = nil then FLogoPending := TDictionary<string, Boolean>.Create;
  if FLogoCache.ContainsKey(AUrl) or FLogoPending.ContainsKey(AUrl) then Exit;
  if FLogoPending.Count > 60 then Exit; // Keep burst bounded

  FLogoPending.Add(AUrl, True);
  TThread.CreateAnonymousThread(
    procedure
    var
      HTTP: THTTPClient;
      Resp: IHTTPResponse;
      MS: TMemoryStream;
      SA: IStream;
      Img: TGPImage;
    begin
      Img := nil;
      HTTP := THTTPClient.Create;
      try
        HTTP.ConnectionTimeout := 2500;
        HTTP.ResponseTimeout := 3500;
        HTTP.UserAgent := 'VLCModern/1.0';
        try
          Resp := HTTP.Get(AUrl);
          if (Resp <> nil) and (Resp.StatusCode = 200) and (Resp.ContentStream.Size > 0) and (Resp.ContentStream.Size < 512 * 1024) then
          begin
            MS := TMemoryStream.Create;
            Resp.ContentStream.Position := 0;
            MS.CopyFrom(Resp.ContentStream, 0);
            MS.Position := 0;
            SA := TStreamAdapter.Create(MS, soOwned);
            Img := TGPImage.Create(SA);
            if Img.GetLastStatus <> Ok then
              FreeAndNil(Img);
          end;
        except
          FreeAndNil(Img);
        end;
      finally
        HTTP.Free;
      end;

      TThread.Queue(nil,
        TThreadProcedure(procedure
        begin
          if not FClosingForm then
          begin
            if (Img <> nil) and (FLogoCache <> nil) and not FLogoCache.ContainsKey(AUrl) then
              FLogoCache.Add(AUrl, Img)
            else
              Img.Free;
            if FLogoPending <> nil then
              FLogoPending.Remove(AUrl);
            if Assigned(lstChannels) then
              lstChannels.Invalidate;
          end
          else
            Img.Free;
        end));
    end).Start;
end;

end.
