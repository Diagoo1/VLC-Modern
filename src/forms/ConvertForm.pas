unit ConvertForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  LibVLC;

type
  TFrmConvert = class(TForm)
    lblSource: TLabel;
    edtSource: TEdit;
    btnBrowseSource: TButton;
    lblProfile: TLabel;
    cboProfile: TComboBox;
    lblDestination: TLabel;
    edtDestination: TEdit;
    btnBrowseDest: TButton;
    pnlProgress: TPanel;
    pbConvert: TProgressBar;
    lblStatus: TLabel;
    pnlBottom: TPanel;
    btnStart: TButton;
    btnClose: TButton;
    OpenDialogSource: TOpenDialog;
    SaveDialogDest: TSaveDialog;
    tmrMonitor: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBrowseSourceClick(Sender: TObject);
    procedure btnBrowseDestClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure tmrMonitorTimer(Sender: TObject);
  private
    FConvertInstance: Plibvlc_instance_t;
    FConvertPlayer: Plibvlc_media_player_t;
    FConvertMedia: Plibvlc_media_t;
    FIsConverting: Boolean;
    FLastError: string;
    FSucceeded: Boolean;
    FVerifyPlayer: Plibvlc_media_player_t;
    FVerifyMedia: Plibvlc_media_t;
    FVerifyDeadline: UInt64;
    FExpectVideo, FExpectAudio: Boolean;
    procedure LayoutConvert(Sender: TObject);
    function VerifyOutput: Boolean;
    function DoStart(Options: TStrings): Boolean;
    procedure StopConverting(const AMessage: string);
  public
    procedure AfterConstruction; override;
    procedure SetSourceFile(const AFilePath: string);
    function ValidateConversion(out Error: string): Boolean;
    function StartConversion(const Source, Destination: string; Profile: Integer;
      Options: TStrings = nil): Boolean;
    property IsConverting: Boolean read FIsConverting;
    property Succeeded: Boolean read FSucceeded;
    property LastError: string read FLastError;
  end;

var
  FrmConvert: TFrmConvert;

implementation

uses PlayerDialogs, CurvedControls;

{$R *.dfm}

procedure TFrmConvert.AfterConstruction;
begin
  inherited;
  ClientWidth:=MulDiv(660,CurrentPPI,96);
  ClientHeight:=MulDiv(450,CurrentPPI,96);
  Constraints.MinWidth:=MulDiv(600,CurrentPPI,96);
  Constraints.MinHeight:=MulDiv(440,CurrentPPI,96);
  OnResize:=LayoutConvert;
  ApplyPlayerAppearance(Self);
  LayoutConvert(nil);
end;
procedure TFrmConvert.LayoutConvert(Sender: TObject);
  function S(Value: Integer): Integer;
  begin Result:=MulDiv(Value,CurrentPPI,96); end;
  procedure Place(Control: TControl; X,Y,W,H: Integer);
  begin
    if (Control is TEdit) and (Control.Parent is TModernCardPanel) then Control:=Control.Parent;
    Control.SetBounds(S(X),S(Y),W,S(H));
  end;
begin
  pnlBottom.Height:=S(56);
  btnClose.SetBounds(ClientWidth-S(128),S(12),S(104),S(32));
  btnStart.SetBounds(btnClose.Left-S(116),S(12),S(104),S(32));
  btnStart.Caption:='Convert';
  Place(lblSource,24,60,S(240),24);
  Place(edtSource,24,88,ClientWidth-S(172),32);
  btnBrowseSource.SetBounds(ClientWidth-S(132),S(88),S(108),S(32));
  Place(lblProfile,24,140,S(240),24);
  Place(cboProfile,24,168,ClientWidth-S(48),32);
  Place(lblDestination,24,220,S(240),24);
  Place(edtDestination,24,248,ClientWidth-S(172),32);
  btnBrowseDest.SetBounds(ClientWidth-S(132),S(248),S(108),S(32));
  pnlProgress.SetBounds(S(24),S(304),ClientWidth-S(48),S(64));
  pbConvert.SetBounds(0,0,pnlProgress.ClientWidth,S(12));
  lblStatus.SetBounds(0,S(28),pnlProgress.ClientWidth,S(24));
end;
procedure TFrmConvert.FormCreate(Sender: TObject);
var
  Args: array[0..7] of PAnsiChar;
  LogOption: UTF8String;
  ArgCount: Integer;
begin
  FIsConverting := False;
  if not IsLibVLCLoaded then
  begin
    btnStart.Enabled := False;
    lblStatus.Caption := 'The playback engine is unavailable.';
    Exit;
  end;
  Args[0] := '--quiet';
  Args[1] := '--no-video-title-show';
  Args[2] := '--avcodec-hw=none';
  Args[3] := '--vout=dummy';
  Args[4] := '--aout=adummy';
  Args[5] := nil;
  ArgCount := 5;
  if GetEnvironmentVariable('VLC_CONVERT_LOG') <> '' then
  begin
    Args[0] := '--verbose=2';
    Args[5] := '--file-logging';
    LogOption := UTF8Encode('--logfile=' + GetEnvironmentVariable('VLC_CONVERT_LOG'));
    Args[6] := PAnsiChar(LogOption);
    Args[7] := nil;
    ArgCount := 7;
  end;
  Args[ArgCount] := '--ignore-config';
  Inc(ArgCount);
  FConvertInstance := libvlc_new(ArgCount, @Args[0]);
  if FConvertInstance <> nil then
  begin
    FConvertPlayer := libvlc_media_player_new(FConvertInstance);
    // LibVLC 3 creates avcodec-hw on the player without inheritance. Setting
    // callbacks is its public API for software decode; conversion has no vout.
    if FConvertPlayer <> nil then
      libvlc_video_set_callbacks(FConvertPlayer, nil, nil, nil, nil);
  end;
end;

procedure TFrmConvert.FormDestroy(Sender: TObject);
begin
  tmrMonitor.Enabled := False;
  StopConverting('Cancelled');

  if FConvertPlayer <> nil then
  begin
    libvlc_media_player_release(FConvertPlayer);
    FConvertPlayer := nil;
  end;

  if FConvertInstance <> nil then
  begin
    libvlc_release(FConvertInstance);
    FConvertInstance := nil;
  end;
end;

procedure TFrmConvert.SetSourceFile(const AFilePath: string);
begin
  edtSource.Text := AFilePath;
  if AFilePath <> '' then
    edtDestination.Text := ChangeFileExt(AFilePath, '_converted.mp4');
end;

procedure TFrmConvert.btnBrowseSourceClick(Sender: TObject);
begin
  if OpenDialogSource.Execute then
  begin
    edtSource.Text := OpenDialogSource.FileName;
    if edtDestination.Text = '' then
      edtDestination.Text := ChangeFileExt(OpenDialogSource.FileName, '_converted.mp4');
  end;
end;

procedure TFrmConvert.btnBrowseDestClick(Sender: TObject);
begin
  case cboProfile.ItemIndex of
    0: SaveDialogDest.Filter := 'MP4 Video (*.mp4)|*.mp4';
    1: SaveDialogDest.Filter := 'WebM Video (*.webm)|*.webm';
    2: SaveDialogDest.Filter := 'MP3 Audio (*.mp3)|*.mp3';
    3: SaveDialogDest.Filter := 'FLAC Audio (*.flac)|*.flac';
  end;
  SaveDialogDest.FileName := edtDestination.Text;
  if SaveDialogDest.Execute then
    edtDestination.Text := SaveDialogDest.FileName;
end;

function TFrmConvert.ValidateConversion(out Error: string): Boolean;
var
  Source, Destination: string;
begin
  Error := '';
  Source := Trim(edtSource.Text);
  Destination := Trim(edtDestination.Text);
  if (FConvertPlayer = nil) or not IsLibVLCLoaded then Error := 'The conversion engine is unavailable.'
  else if not FileExists(Source) and (Pos('://', Source) = 0) then Error := 'Choose an existing source file or a stream URL.'
  else if Destination = '' then Error := 'Choose a destination file.'
  else if SameText(ExpandFileName(Source), ExpandFileName(Destination)) then Error := 'The destination must be different from the source file.'
  else if FileExists(Destination) then Error := 'The destination already exists. Choose a new file name.'
  else if not DirectoryExists(ExtractFileDir(ExpandFileName(Destination))) then Error := 'The destination folder does not exist.'
  else if (cboProfile.ItemIndex < 0) or (cboProfile.ItemIndex > 3) then Error := 'Choose a conversion profile.';
  Result := Error = '';
end;

function TFrmConvert.StartConversion(const Source, Destination: string; Profile: Integer;
  Options: TStrings): Boolean;
begin
  Result := False;
  if FIsConverting then
  begin
    FLastError := 'A conversion is already running.';
    Exit;
  end;
  edtSource.Text := Source;
  edtDestination.Text := Destination;
  cboProfile.ItemIndex := Profile;
  FSucceeded := False;
  if not ValidateConversion(FLastError) then Exit;
  Result := DoStart(Options);
end;

procedure TFrmConvert.btnStartClick(Sender: TObject);
begin
  if FIsConverting then StopConverting('Conversion cancelled.')
  else if not StartConversion(edtSource.Text, edtDestination.Text, cboProfile.ItemIndex) then
    PlayerMessage(FLastError);
end;

function TFrmConvert.DoStart(Options: TStrings): Boolean;
var
  Source, Destination, Pipeline: string;
  Utf8Source, Utf8Option: UTF8String;
begin
  Result := False;
  Source := Trim(edtSource.Text);
  Destination := ExpandFileName(Trim(edtDestination.Text));
  case cboProfile.ItemIndex of
    0: Pipeline := Format(':sout=#transcode{vcodec=h264,venc=x264{preset=veryfast,lookahead=0,bframes=0},threads=2,vb=1800,acodec=mp4a,ab=160,channels=2}:std{access=file,mux=mp4,dst="%s"}', [Destination]);
    1: Pipeline := Format(':sout=#transcode{vcodec=VP80,acodec=vorb,ab=128,channels=2}:std{access=file,mux=webm,dst="%s"}', [Destination]);
    2: Pipeline := Format(':sout=#transcode{vcodec=none,acodec=mp3,ab=192,channels=2}:std{access=file,mux=raw,dst="%s"}', [Destination]);
    3: Pipeline := Format(':sout=#transcode{vcodec=none,acodec=flac,channels=2}:std{access=file,mux=raw,dst="%s"}', [Destination]);
  end;
  Utf8Source := UTF8Encode(Source);
  if Pos('://', Source) > 0 then
    FConvertMedia := libvlc_media_new_location(FConvertInstance, PAnsiChar(Utf8Source))
  else FConvertMedia := libvlc_media_new_path(FConvertInstance, PAnsiChar(Utf8Source));
  if FConvertMedia = nil then
  begin
    FLastError := 'Unable to open the conversion source.';
    Exit;
  end;
  Utf8Option := UTF8Encode(Pipeline);
  libvlc_media_add_option(FConvertMedia, PAnsiChar(Utf8Option));
  libvlc_media_add_option(FConvertMedia, ':avcodec-hw=none');
  if Options <> nil then
    for var Option in Options do
    begin
      Utf8Option := UTF8Encode(Option);
      libvlc_media_add_option(FConvertMedia, PAnsiChar(Utf8Option));
    end;
  libvlc_media_player_set_media(FConvertPlayer, FConvertMedia);
  if libvlc_media_player_play(FConvertPlayer) = 0 then
  begin
    FIsConverting := True;
    btnStart.Caption := 'Cancel';
    edtSource.Enabled := False;
    edtDestination.Enabled := False;
    cboProfile.Enabled := False;
    btnBrowseSource.Enabled := False;
    btnBrowseDest.Enabled := False;
    lblStatus.Caption := 'Converting...';
    pbConvert.Position := 0;
    tmrMonitor.Enabled := True;
    Result := True;
  end
  else
  begin
    FLastError := 'The conversion could not start.';
    libvlc_media_release(FConvertMedia);
    FConvertMedia := nil;
  end;
end;

procedure TFrmConvert.StopConverting(const AMessage: string);
begin
  tmrMonitor.Enabled := False;
  if FVerifyPlayer <> nil then
  begin
    libvlc_media_player_stop(FVerifyPlayer);
    libvlc_media_player_release(FVerifyPlayer);
    FVerifyPlayer := nil;
  end;
  if FVerifyMedia <> nil then
  begin
    libvlc_media_release(FVerifyMedia);
    FVerifyMedia := nil;
  end;
  if FConvertPlayer <> nil then
    libvlc_media_player_stop(FConvertPlayer);

  if FConvertMedia <> nil then
  begin
    libvlc_media_release(FConvertMedia);
    FConvertMedia := nil;
  end;

  FIsConverting := False;
  btnStart.Caption := 'Start conversion';
  edtSource.Enabled := True;
  edtDestination.Enabled := True;
  cboProfile.Enabled := True;
  btnBrowseSource.Enabled := True;
  btnBrowseDest.Enabled := True;
  lblStatus.Caption := AMessage;
end;

function TFrmConvert.VerifyOutput: Boolean;
var
  Path: UTF8String;
begin
  Result := False;
  if not FileExists(edtDestination.Text) then Exit;
  Path := UTF8Encode(ExpandFileName(edtDestination.Text));
  FVerifyMedia := libvlc_media_new_path(FConvertInstance, PAnsiChar(Path));
  if FVerifyMedia = nil then Exit;
  libvlc_media_add_option(FVerifyMedia, ':avcodec-hw=none');
  libvlc_media_add_option(FVerifyMedia, ':vout=dummy');
  libvlc_media_add_option(FVerifyMedia, ':aout=adummy');
  FVerifyPlayer := libvlc_media_player_new(FConvertInstance);
  if FVerifyPlayer = nil then Exit;
  libvlc_media_player_set_media(FVerifyPlayer, FVerifyMedia);
  if libvlc_media_player_play(FVerifyPlayer) <> 0 then Exit;
  FVerifyDeadline := GetTickCount64 + 15000;
  FIsConverting := True;
  btnStart.Caption := 'Cancel';
  edtSource.Enabled := False;
  edtDestination.Enabled := False;
  cboProfile.Enabled := False;
  btnBrowseSource.Enabled := False;
  btnBrowseDest.Enabled := False;
  lblStatus.Caption := 'Verifying output...';
  tmrMonitor.Enabled := True;
  Result := True;
end;

procedure TFrmConvert.tmrMonitorTimer(Sender: TObject);
var
  State: libvlc_state_t;
  Stats: TLibVLCMediaStats;
  Ready: Boolean;
  Position: Single;
begin
  if not FIsConverting then Exit;
  if FVerifyPlayer <> nil then
  begin
    Stats := Default(TLibVLCMediaStats);
    State := libvlc_media_player_get_state(FVerifyPlayer);
    Ready := False;
    if libvlc_media_get_stats(FVerifyMedia, @Stats) <> 0 then
      Ready := (not FExpectVideo or ((Stats.DecodedVideo > 0) and (Stats.DisplayedPictures > 0))) and
        (not FExpectAudio or (Stats.DecodedAudio > 0));
    if Ready then
    begin
      FLastError := '';
      StopConverting('Saved: ' + ExtractFileName(edtDestination.Text));
      FSucceeded := True;
      pbConvert.Position := 100;
    end
    else if (State = libvlc_Error) or (State = libvlc_Ended) or
      (GetTickCount64 > FVerifyDeadline) then
    begin
      FLastError := 'The output is incomplete or could not be decoded. Check the source and selected profile.';
      StopConverting(FLastError);
    end;
    Exit;
  end;
  if FConvertPlayer = nil then Exit;
  State := libvlc_media_player_get_state(FConvertPlayer);
  Position := libvlc_media_player_get_position(FConvertPlayer);
  if Position >= 0 then pbConvert.Position := Round(Position * 100);
  if State = libvlc_Ended then
  begin
    FExpectVideo := cboProfile.ItemIndex < 2;
    FExpectAudio := (cboProfile.ItemIndex >= 2) or
      (libvlc_audio_get_track_count(FConvertPlayer) > 0);
    StopConverting('Finalizing output...');
    if not VerifyOutput then
    begin
      FLastError := 'Unable to open the converted output for verification.';
      StopConverting(FLastError);
    end;
  end
  else if State = libvlc_Error then
  begin
    FLastError := 'Conversion failed. Check the source and destination permissions.';
    StopConverting(FLastError);
  end;
end;

procedure TFrmConvert.btnCloseClick(Sender: TObject);
begin
  if FIsConverting then
    StopConverting('Cancelled');
  Close;
end;

end.
