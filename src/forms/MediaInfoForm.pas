unit MediaInfoForm;

interface

uses CurvedControls, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, LibVLC;

type
  TFrmMediaInfo = class(TForm)
    pnlBottom: TPanel;
    btnClose: TPlayerTextButton;
    mmoDetails: TMemo;
    lblTitle: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FDetailsCard: TModernCardPanel;
    procedure LayoutInfo(Sender: TObject);
  public
    procedure AfterConstruction; override;
    procedure UpdateMediaInfo(const AFilePath: string; AMedia: Plibvlc_media_t; APlayer: Plibvlc_media_player_t);
  end;

var
  FrmMediaInfo: TFrmMediaInfo;

implementation

uses PlayerDialogs, PlayerLanguage, System.Math;

{$R *.dfm}

procedure TFrmMediaInfo.AfterConstruction;
begin
  inherited;
  BorderStyle := bsSizeable;
  ClientWidth:=MulDiv(720,CurrentPPI,96);
  ClientHeight:=MulDiv(540,CurrentPPI,96);
  Constraints.MinWidth:=Width;
  Constraints.MinHeight:=Height;
  FDetailsCard := TModernCardPanel.Create(Self);
  FDetailsCard.Parent := Self;
  FDetailsCard.CardColor := DP_COLOR_SURFACE;
  FDetailsCard.BorderColor := DP_COLOR_BORDER;
  FDetailsCard.CornerRadius := 12;
  mmoDetails.Parent := FDetailsCard;
  mmoDetails.AlignWithMargins := True;
  mmoDetails.Margins.SetBounds(3,3,3,3);
  mmoDetails.Align := alClient;
  OnResize:=LayoutInfo;
  ApplyPlayerAppearance(Self);
  mmoDetails.Font.Charset := DEFAULT_CHARSET;
  mmoDetails.Font.Name:=PlayerUIFont;
  mmoDetails.Font.Size:=9;
  lblTitle.Font.Name := PlayerUIFont;
  lblTitle.Font.Size := 13;
  lblTitle.Font.Style := [fsBold];
  lblTitle.AutoSize := False;
  if PlayerIsArabic then lblTitle.Alignment := taRightJustify;
  LayoutInfo(nil);
end;
procedure TFrmMediaInfo.LayoutInfo(Sender: TObject);
  function S(Value: Integer): Integer;
  begin Result:=MulDiv(Value,CurrentPPI,96); end;
begin
  lblTitle.SetBounds(S(24),S(52),ClientWidth-S(48),S(28));
  if Assigned(FDetailsCard) then
    FDetailsCard.SetBounds(S(24),S(92),ClientWidth-S(48),ClientHeight-S(164));
  pnlBottom.Height:=S(56);
  btnClose.SetBounds(ClientWidth-S(128),S(12),S(104),S(32));
  if PlayerIsArabic then btnClose.Left := S(24);
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
    if AFilePath <> '' then S.Add(Translate('File Path: ') + AFilePath);
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
    S.Add(Translate('Real Codec & Elementary Streams'));
    if (AMedia <> nil) and Assigned(libvlc_media_tracks_get) and Assigned(libvlc_media_tracks_release) then
    begin
      var TracksPtr: PPlibvlc_media_track_t := nil;
      var TrackCount := libvlc_media_tracks_get(AMedia, @TracksPtr);
      if (TrackCount > 0) and (TracksPtr <> nil) then
      begin
        try
          var PArr := TracksPtr;
          for var TI := 0 to Integer(TrackCount) - 1 do
          begin
            var Trk := PArr^;
            if Trk <> nil then
            begin
              var FourCCStr := string(AnsiChar(Trk^.i_codec and $FF)) +
                               string(AnsiChar((Trk^.i_codec shr 8) and $FF)) +
                               string(AnsiChar((Trk^.i_codec shr 16) and $FF)) +
                               string(AnsiChar((Trk^.i_codec shr 24) and $FF));
              var CodecDesc := FourCCStr;
              if Assigned(libvlc_media_get_codec_description) then
              begin
                var DescP := libvlc_media_get_codec_description(Trk^.i_type, Trk^.i_codec);
                if DescP <> nil then
                  CodecDesc := UTF8ToString(DescP) + ' [' + FourCCStr + ']';
              end;

              case Trk^.i_type of
                libvlc_track_video:
                begin
                  var VT := Plibvlc_video_track_t(Trk^.u_track);
                  var FPS := 0.0;
                  if (VT <> nil) and (VT^.i_frame_rate_den > 0) then
                    FPS := VT^.i_frame_rate_num / VT^.i_frame_rate_den;
                  S.Add(Format('Video Track #%d: %s | %dx%d | %.3f fps | Bitrate: %d kbps',
                    [Trk^.i_id, CodecDesc, VT^.i_width, VT^.i_height, FPS, Trk^.i_bitrate div 1000]));
                end;
                libvlc_track_audio:
                begin
                  var AT := Plibvlc_audio_track_t(Trk^.u_track);
                  if AT <> nil then
                    S.Add(Format('Audio Track #%d: %s | %d Hz | %d ch | Bitrate: %d kbps',
                      [Trk^.i_id, CodecDesc, AT^.i_rate, AT^.i_channels, Trk^.i_bitrate div 1000]))
                  else
                    S.Add(Format('Audio Track #%d: %s', [Trk^.i_id, CodecDesc]));
                end;
                libvlc_track_text:
                begin
                  var LangS := '';
                  if Trk^.psz_language <> nil then LangS := ' (' + UTF8ToString(Trk^.psz_language) + ')';
                  S.Add(Format('Subtitle Track #%d: %s%s', [Trk^.i_id, CodecDesc, LangS]));
                end;
              end;
            end;
            Inc(PArr);
          end;
        finally
          libvlc_media_tracks_release(TracksPtr, TrackCount);
        end;
      end
      else
        S.Add('Elementary Tracks: Parsing or stream metadata unavailable');
    end;

    S.Add('');
    S.Add(Translate('Video Stream Details'));
    if APlayer <> nil then
    begin
      W := 0;
      H := 0;
      if libvlc_video_get_size(APlayer, 0, @W, @H) = 0 then
        S.Add(Format('Active Output Resolution: %d x %d pixels', [W, H]))
      else
        S.Add(Translate('Resolution: N/A (Audio or stream loading)'));

      AspectStr := libvlc_video_get_aspect_ratio(APlayer);
      if AspectStr <> nil then
      begin
        S.Add('Aspect Ratio: ' + UTF8ToString(AspectStr));
        libvlc_free(AspectStr);
      end
      else
        S.Add(Translate('Aspect Ratio: Default / Auto'));

      S.Add(Format(Translate('Current Rate / Speed: %.2fx'), [libvlc_media_player_get_rate(APlayer)]));
    end;

    S.Add('');
    S.Add(Translate('Audio Streams'));
    if APlayer <> nil then
    begin
      AudioTrackCount := Max(0, libvlc_audio_get_track_count(APlayer));
      S.Add(Format(Translate('Total Audio Tracks: %d'), [AudioTrackCount]));
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
    S.Add(Translate('Subtitles (SPU Streams)'));
    if APlayer <> nil then
    begin
      SpuTrackCount := libvlc_video_get_spu_count(APlayer);
      S.Add(Format(Translate('Total Subtitle Tracks: %d'), [SpuTrackCount]));
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
    S.Add(Translate('Stream & Decoder Performance'));
    if AMedia <> nil then
    begin
      var Stats: TLibVLCMediaStats;
      FillChar(Stats, SizeOf(Stats), 0);
      if Assigned(libvlc_media_get_stats) and (libvlc_media_get_stats(AMedia, @Stats) <> 0) then
      begin
        S.Add(Format('Input Bitrate: %.1f kbps (%.2f Mbps)', [Stats.InputBitrate * 8000.0, (Stats.InputBitrate * 8.0) / 1000.0]));
        S.Add(Format('Demux Bitrate: %.1f kbps', [Stats.DemuxBitrate * 8000.0]));
        S.Add(Format('Data Read: %.2f MB (%d bytes)', [Stats.ReadBytes / (1024.0 * 1024.0), Stats.ReadBytes]));
        S.Add(Format('Video Frames Displayed: %d frames', [Stats.DisplayedPictures]));
        S.Add(Format('Video Frames Dropped / Lost: %d frames', [Stats.LostPictures]));
        if (Stats.DisplayedPictures + Stats.LostPictures) > 0 then
        begin
          var DropRate := (Stats.LostPictures / (Stats.DisplayedPictures + Stats.LostPictures)) * 100.0;
          S.Add(Format('Dropped Frames Ratio: %.2f%%', [DropRate]));
        end
        else
          S.Add('Dropped Frames Ratio: 0.00% (Smooth Playback)');
        S.Add(Format('Audio Buffers Played: %d buffers', [Stats.PlayedAudioBuffers]));
        S.Add(Format('Audio Buffers Lost: %d buffers', [Stats.LostAudioBuffers]));
      end
      else
        S.Add('Performance Statistics: Active stream decoding');
    end;

    S.Add('');
    S.Add(Translate('VLC Engine'));
    if IsLibVLCLoaded then
      S.Add(Translate('VLC Core Version: ') + string(libvlc_get_version()))
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
