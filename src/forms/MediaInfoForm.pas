unit MediaInfoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, LibVLC;

type
  TFrmMediaInfo = class(TForm)
    pnlBottom: TPanel;
    btnClose: TButton;
    mmoDetails: TMemo;
    lblTitle: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure LayoutInfo(Sender: TObject);
  public
    procedure AfterConstruction; override;
    procedure UpdateMediaInfo(const AFilePath: string; AMedia: Plibvlc_media_t; APlayer: Plibvlc_media_player_t);
  end;

var
  FrmMediaInfo: TFrmMediaInfo;

implementation

uses PlayerDialogs;

{$R *.dfm}

procedure TFrmMediaInfo.AfterConstruction;
begin
  inherited;
  ClientWidth:=MulDiv(720,CurrentPPI,96);
  ClientHeight:=MulDiv(540,CurrentPPI,96);
  Constraints.MinWidth:=MulDiv(560,CurrentPPI,96);
  Constraints.MinHeight:=MulDiv(420,CurrentPPI,96);
  OnResize:=LayoutInfo;
  ApplyPlayerAppearance(Self);
  mmoDetails.Font.Name:='Segoe UI';
  mmoDetails.Font.Size:=10;
  LayoutInfo(nil);
end;
procedure TFrmMediaInfo.LayoutInfo(Sender: TObject);
  function S(Value: Integer): Integer;
  begin Result:=MulDiv(Value,CurrentPPI,96); end;
begin
  lblTitle.SetBounds(S(24),S(52),ClientWidth-S(48),S(28));
  mmoDetails.SetBounds(S(24),S(92),ClientWidth-S(48),ClientHeight-S(164));
  pnlBottom.Height:=S(56);
  btnClose.SetBounds(ClientWidth-S(128),S(12),S(104),S(32));
end;
procedure TFrmMediaInfo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMediaInfo.FormShow(Sender: TObject);
begin
  //
end;

procedure TFrmMediaInfo.UpdateMediaInfo(const AFilePath: string; AMedia: Plibvlc_media_t; APlayer: Plibvlc_media_player_t);
var
  W, H: Cardinal;
  DurationMs: Int64;
  AspectStr: PAnsiChar;
  AudioTrackCount, SpuTrackCount: Integer;
  AudioTracks, SpuTracks, CurTrack: Plibvlc_track_description_t;
  MetaTitle, MetaArtist, MetaAlbum, MetaDate: PAnsiChar;
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Add('====================================================');
    S.Add(' VLC MODERN - MEDIA & CODEC INFORMATION');
    S.Add('====================================================');
    S.Add('');
    S.Add('File Path: ' + AFilePath);
    if FileExists(AFilePath) then
    begin
      var LSize: Int64 := 0;
      var FRec: TSearchRec;
      if FindFirst(AFilePath, faAnyFile, FRec) = 0 then
      begin
        LSize := FRec.Size;
        FindClose(FRec);
      end;
      S.Add(Format('File Size: %.2f MB (%d bytes)', [LSize / (1024 * 1024), LSize]));
    end;

    if AMedia <> nil then
    begin
      DurationMs := libvlc_media_get_duration(AMedia);
      if DurationMs > 0 then
      begin
        var Sec := DurationMs div 1000;
        var Hh := Sec div 3600;
        var Mm := (Sec mod 3600) div 60;
        var Ss := Sec mod 60;
        S.Add(Format('Duration: %.2d:%.2d:%.2d (%d ms)', [Hh, Mm, Ss, DurationMs]));
      end;

      MetaTitle := libvlc_media_get_meta(AMedia, Ord(libvlc_meta_Title));
      if MetaTitle <> nil then
      begin
        S.Add('Title: ' + UTF8ToString(MetaTitle));
        libvlc_free(MetaTitle);
      end;
      MetaArtist := libvlc_media_get_meta(AMedia, Ord(libvlc_meta_Artist));
      if MetaArtist <> nil then
      begin
        S.Add('Artist: ' + UTF8ToString(MetaArtist));
        libvlc_free(MetaArtist);
      end;
      MetaAlbum := libvlc_media_get_meta(AMedia, Ord(libvlc_meta_Album));
      if MetaAlbum <> nil then
      begin
        S.Add('Album: ' + UTF8ToString(MetaAlbum));
        libvlc_free(MetaAlbum);
      end;
      MetaDate := libvlc_media_get_meta(AMedia, Ord(libvlc_meta_Date));
      if MetaDate <> nil then
      begin
        S.Add('Year / Date: ' + UTF8ToString(MetaDate));
        libvlc_free(MetaDate);
      end;
    end;

    S.Add('');
    S.Add('--- Video Stream Details ---');
    if APlayer <> nil then
    begin
      W := 0;
      H := 0;
      if libvlc_video_get_size(APlayer, 0, @W, @H) = 0 then
        S.Add(Format('Resolution: %d x %d pixels', [W, H]))
      else
        S.Add('Resolution: N/A (Audio or stream loading)');

      AspectStr := libvlc_video_get_aspect_ratio(APlayer);
      if AspectStr <> nil then
      begin
        S.Add('Aspect Ratio: ' + UTF8ToString(AspectStr));
        libvlc_free(AspectStr);
      end
      else
        S.Add('Aspect Ratio: Default / Auto');

      S.Add(Format('Current Rate / Speed: %.2fx', [libvlc_media_player_get_rate(APlayer)]));
    end;

    S.Add('');
    S.Add('--- Audio Streams ---');
    if APlayer <> nil then
    begin
      AudioTrackCount := libvlc_audio_get_track_count(APlayer);
      S.Add(Format('Total Audio Tracks: %d', [AudioTrackCount]));
      AudioTracks := libvlc_audio_get_track_description(APlayer);
      CurTrack := AudioTracks;
      while CurTrack <> nil do
      begin
        S.Add(Format('  - [ID %d] %s', [CurTrack^.i_id, UTF8ToString(CurTrack^.psz_name)]));
        CurTrack := CurTrack^.p_next;
      end;
      if AudioTracks <> nil then
        libvlc_track_description_list_release(AudioTracks);
    end;

    S.Add('');
    S.Add('--- Subtitles (SPU Streams) ---');
    if APlayer <> nil then
    begin
      SpuTrackCount := libvlc_video_get_spu_count(APlayer);
      S.Add(Format('Total Subtitle Tracks: %d', [SpuTrackCount]));
      SpuTracks := libvlc_video_get_spu_description(APlayer);
      CurTrack := SpuTracks;
      while CurTrack <> nil do
      begin
        S.Add(Format('  - [ID %d] %s', [CurTrack^.i_id, UTF8ToString(CurTrack^.psz_name)]));
        CurTrack := CurTrack^.p_next;
      end;
      if SpuTracks <> nil then
        libvlc_track_description_list_release(SpuTracks);
    end;

    S.Add('');
    S.Add('--- VLC Engine ---');
    if IsLibVLCLoaded then
      S.Add('VLC Core Version: ' + string(libvlc_get_version()))
    else
      S.Add('VLC Core: Not Loaded');

    for var I:=S.Count-1 downto 0 do
      if S[I].StartsWith('===') then S.Delete(I)
      else if S[I].StartsWith('--- ') then S[I]:=S[I].Replace('---','').Trim;
    mmoDetails.Lines.Assign(S);
  finally
    S.Free;
  end;
end;

end.
