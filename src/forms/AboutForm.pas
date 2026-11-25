unit AboutForm;

interface

uses System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, System.Threading, CurvedControls;

type
  TFrmAbout = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FUpdate: IFuture<string>;
    FUpdateTimer: TTimer;
    FUpdateButton: TButton;
    FUpdateStatus: TLabel;
    procedure CheckUpdate(Sender: TObject);
    procedure UpdateFinished(Sender: TObject);
    procedure OpenLink(Sender: TObject);
    procedure OpenShortcuts(Sender: TObject);
  end;

implementation

uses Winapi.Windows, Winapi.ShellAPI, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.JSON, System.Net.HttpClient, Vcl.Graphics,
  PlayerDialogs, MainForm;

{$R *.dfm}

const
  Links: array[0..4] of string = (
    'https://github.com/Diagoo1/VLC-Modern',
    'https://github.com/Diagoo1',
    'https://paypal.me/Diagoo1',
    'mailto:tarek.sadek44@gmail.com',
    'https://github.com/Diagoo1/VLC-Modern/issues/new');

type
  TAboutArtwork = class(TGraphicControl)
  private
    FSource: IStream;
    FImage, FRendered: TGPBitmap;
    FFramed: Boolean;
    procedure RenderArtwork;
  protected
    procedure Paint; override;
  public
    constructor CreateResource(AOwner: TComponent; const ResourceName: string;
      Framed: Boolean);
    destructor Destroy; override;
  end;

constructor TAboutArtwork.CreateResource(AOwner: TComponent;
  const ResourceName: string; Framed: Boolean);
begin
  inherited Create(AOwner);
  FFramed := Framed;
  FSource := TStreamAdapter.Create(
    TResourceStream.Create(HInstance, ResourceName, RT_RCDATA), soOwned);
  FImage := TGPBitmap.Create(FSource);
end;

destructor TAboutArtwork.Destroy;
begin
  FRendered.Free;
  FImage.Free;
  FSource := nil;
  inherited;
end;

procedure TAboutArtwork.RenderArtwork;
const
  QualityScale = 3;
var
  HiRes: TGPBitmap;
  Graphics: TGPGraphics;
  Frame: TGPLinearGradientBrush;
  Mask: TGPGraphicsPath;
  W, H, Inset: Integer;
begin
  FreeAndNil(FRendered);
  W := Width * QualityScale;
  H := Height * QualityScale;
  HiRes := TGPBitmap.Create(W, H, PixelFormat32bppPARGB);
  try
    Graphics := TGPGraphics.Create(HiRes);
    try
      Graphics.Clear(0);
      Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
      Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      Inset := 0;
      if FFramed then
      begin
        Frame := TGPLinearGradientBrush.Create(MakeRect(0, 0, W, H),
          MakeColor(255, 96, 205, 255), MakeColor(255, 23, 58, 89),
          LinearGradientModeForwardDiagonal);
        try
          Graphics.FillEllipse(Frame, 3, 3, W - 6, H - 6);
        finally
          Frame.Free;
        end;
        Inset := MulDiv(4, CurrentPPI, 96) * QualityScale;
        Mask := TGPGraphicsPath.Create;
        try
          Mask.AddEllipse(Inset, Inset, W - 2 * Inset, H - 2 * Inset);
          Graphics.SetClip(Mask);
        finally
          Mask.Free;
        end;
      end;
      Graphics.DrawImage(FImage, Inset, Inset, W - 2 * Inset, H - 2 * Inset);
    finally
      Graphics.Free;
    end;
    FRendered := TGPBitmap.Create(Width, Height, PixelFormat32bppPARGB);
    Graphics := TGPGraphics.Create(FRendered);
    try
      Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      Graphics.DrawImage(HiRes, 0, 0, Width, Height);
    finally
      Graphics.Free;
    end;
  finally
    HiRes.Free;
  end;
end;

procedure TAboutArtwork.Paint;
var
  Graphics: TGPGraphics;
begin
  if (FImage = nil) or (Width < 10) or (Height < 10) then Exit;
  if (FRendered = nil) or (Integer(FRendered.GetWidth) <> Width) or
    (Integer(FRendered.GetHeight) <> Height) then RenderArtwork;
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.DrawImage(FRendered, 0, 0);
  finally
    Graphics.Free;
  end;
end;

procedure TFrmAbout.CheckUpdate(Sender: TObject);
begin
  if FUpdate <> nil then Exit;
  FUpdateStatus.Caption := 'Checking GitHub for updates...';
  FUpdate := TTask.Future<string>(
    function: string
    var
      Client: THTTPClient;
      Response: IHTTPResponse;
      Data: TJSONValue;
      Release: TJSONObject;
    begin
      Result := '';
      try
        Client := THTTPClient.Create;
        try
          Client.ConnectionTimeout := 5000;
          Client.ResponseTimeout := 5000;
          Client.UserAgent := 'VLC-Modern';
          Response := Client.Get('https://api.github.com/repos/Diagoo1/VLC-Modern/releases?per_page=1');
          if Response.StatusCode <> 200 then Exit;
          Data := TJSONObject.ParseJSONValue(Response.ContentAsString);
          try
            if (Data is TJSONArray) and (TJSONArray(Data).Count > 0) and
              (TJSONArray(Data).Items[0] is TJSONObject) then
            begin
              Release := TJSONObject(TJSONArray(Data).Items[0]);
              Release.TryGetValue<string>('tag_name', Result);
            end;
          finally
            Data.Free;
          end;
        finally
          Client.Free;
        end;
      except
        Result := '';
      end;
    end);
  FUpdateTimer.Enabled := True;
end;

procedure TFrmAbout.UpdateFinished(Sender: TObject);
var
  Tag: string;
begin
  if FUpdate.Status <> TTaskStatus.Completed then Exit;
  FUpdateTimer.Enabled := False;
  Tag := FUpdate.Value;
  FUpdate := nil;

  if Tag = '' then
    FUpdateStatus.Caption := 'Could not check for updates. Try again later.'
  else if SameText(Tag, 'v1.0.8') then
    FUpdateStatus.Caption := 'You have the latest published release (' + Tag + ').'
  else
    FUpdateStatus.Caption := 'GitHub release ' + Tag + ' is listed under Releases.';
end;

procedure TFrmAbout.OpenLink(Sender: TObject);
begin
  if ShellExecute(Handle, 'open', PChar(Links[TButton(Sender).Tag]), nil, nil,
    SW_SHOWNORMAL) <= 32 then
    PlayerMessage('Windows could not open this link.');
end;

procedure TFrmAbout.OpenShortcuts(Sender: TObject);
begin
  if Assigned(FrmMain) then FrmMain.ShowHotkeysReference;
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
const
  DarkHeroFill = $00342518;   // Deep blue surface under the project cyan
  DarkHeroEdge = $00634528;
  Captions: array[0..4] of string = ('Project on GitHub', 'Developer profile', 'Support', 'Email', 'Report a bug');
  Glyphs: array[0..4] of Char = (#$E12B, #$E77B, #$E719, #$E715, #$E90F);
var
  Body: TPanel;
  Hero, Profile, Badge: TModernCardPanel;
  AppIcon: TAboutArtwork;
  HeroFill, HeroEdge, BadgeFill, WatermarkColor: TColor;
  VersionText, EngineText, CreditText, AccountText: TLabel;
  Button: TButton;

  function Px(Value: Integer): Integer;
  begin
    Result := MulDiv(Value, CurrentPPI, 96);
  end;

  procedure Place(Control: TControl; X, Y, W, H: Integer);
  begin
    Control.SetBounds(Px(X), Px(Y), Px(W), Px(H));
  end;

  function Card(Host: TWinControl; X, Y, W, H, Radius: Integer;
    Fill, Edge: TColor): TModernCardPanel;
  begin
    Result := TModernCardPanel.Create(Self);
    Result.Parent := Host;
    Result.CardColor := Fill;
    Result.BorderColor := Edge;
    Result.CornerRadius := Radius;
    Place(Result, X, Y, W, H);
  end;

  function Text(Host: TWinControl; const Caption: string; X, Y, Size: Integer;
    Bold: Boolean = False): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Host;
    Result.Caption := Caption;
    Result.Font.Size := Size;
    if Bold then Result.Font.Style := [fsBold];
    Result.Transparent := True;
    Result.Left := Px(X);
    Result.Top := Px(Y);
  end;

  function Action(const Caption: string; X, Y, W: Integer): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := Body;
    Result.Caption := Caption;
    Place(Result, X, Y, W, 34);
  end;

begin
  ClientWidth := Px(576);
  ClientHeight := Px(396);
  Body := TPanel.Create(Self);
  Body.Parent := Self;
  Body.Align := alClient;
  Body.BevelOuter := bvNone;

  HeroFill := DarkHeroFill;
  HeroEdge := DarkHeroEdge;
  BadgeFill := $004B3421;
  WatermarkColor := $004F4339;
  if PlayerLightTheme then
  begin
    HeroFill := DP_COLOR_ACCSOFT;
    HeroEdge := DP_COLOR_BORDER;
    BadgeFill := DP_COLOR_ELEVATED;
    WatermarkColor := DP_COLOR_BORDER;
  end;
  Hero := Card(Body, 16, 14, 532, 102, 14, HeroFill, HeroEdge);
  AppIcon := TAboutArtwork.CreateResource(Self, 'APP_ICON_PNG', False);
  AppIcon.Parent := Hero;
  Place(AppIcon, 14, 14, 74, 74);
  Text(Hero, 'VLC Modern', 96, 15, 22, True);
  EngineText := Text(Hero, 'Windows media player powered by LibVLC', 97, 61, 10);
  Badge := Card(Hero, 380, 19, 132, 28, 10, BadgeFill, HeroEdge);
  VersionText := Text(Badge, 'v1.0.8', 0, 5, 9, True);
  VersionText.Left := (Badge.Width - VersionText.Width) div 2;

  Profile := Card(Body, 16, 130, 532, 139, 14, DP_COLOR_ELEVATED, DP_COLOR_BORDER);
  var Portrait := TAboutArtwork.CreateResource(Self, 'DEV_AVATAR', True);
  Portrait.Parent := Profile;
  Place(Portrait, 20, 18, 104, 104);
  CreditText := Text(Profile, 'DESIGN & DEVELOPMENT', 147, 24, 9, True);
  CreditText.ShowAccelChar := False;
  Text(Profile, 'Tarek Sadek', 146, 45, 22, True);
  var TagCard := Card(Profile, 146, 88, 100, 29, 9, DP_COLOR_BG, DP_COLOR_BORDER);
  AccountText := Text(TagCard, '@Diagoo1', 10, 5, 10, True);
  var CodeWatermark := Text(Profile, '</>', 389, 34, 36, True);

  for var Index := Low(Captions) to High(Captions) do
  begin
    Button := Action(Glyphs[Index], 16 + Index * 50, 283, 42);
    Button.Font.Name := 'Segoe MDL2 Assets';
    Button.Font.Size := 12;
    Button.Hint := Captions[Index];
    Button.ShowHint := True;
    Button.Tag := Index;
    Button.OnClick := OpenLink;
  end;
  Button := Action(#$E765, 266, 283, 42);
  Button.Font.Name := 'Segoe MDL2 Assets';
  Button.Font.Size := 12;
  Button.Hint := 'Keyboard shortcuts';
  Button.ShowHint := True;
  Button.OnClick := OpenShortcuts;
  FUpdateButton := Action('Check for updates', 372, 283, 176);
  FUpdateButton.Hint := 'Check GitHub for a newer VLC Modern release';
  FUpdateButton.ShowHint := True;
  FUpdateButton.OnClick := CheckUpdate;
  FUpdateTimer := TTimer.Create(Self);
  FUpdateTimer.Enabled := False;
  FUpdateTimer.Interval := 100;
  FUpdateTimer.OnTimer := UpdateFinished;
  FUpdateStatus := Text(Body, '', 16, 338, 9);
  Button := Action('Close', 452, 331, 96);
  Button.Hint := 'Close About';
  Button.ShowHint := True;
  Button.ModalResult := mrCancel;
  Button.Cancel := True;
  Button.Default := True;

  ApplyPlayerAppearance(Self);
  Body.Color := DP_COLOR_SURFACE;
  FUpdateStatus.Font.Color := DP_COLOR_MUTED;
  VersionText.Font.Color := DP_COLOR_ACCENT;
  EngineText.Font.Color := DP_COLOR_MUTED;
  CreditText.Font.Color := DP_COLOR_ACCENT;
  AccountText.Font.Color := DP_COLOR_MUTED;
  CodeWatermark.Font.Color := WatermarkColor;
end;

end.
