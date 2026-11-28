program VLCModern;

uses
  Winapi.Windows,
  CrashTrace,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  System.SysUtils,
  InstanceBroker,
  LibVLC in 'src\core\LibVLC.pas',
  Lut3D in 'src\core\Lut3D.pas',
  D3D11ShaderRenderer in 'src\core\D3D11ShaderRenderer.pas',
  OpenSubtitlesDownloader in 'src\core\OpenSubtitlesDownloader.pas',
  PlaybackResumeStore in 'src\core\PlaybackResumeStore.pas',
  WebRemoteServer in 'src\core\WebRemoteServer.pas',
  YtDlpResolver in 'src\core\YtDlpResolver.pas',
  VideoInput in 'src\core\VideoInput.pas',
  CurvedControls in 'src\ui\CurvedControls.pas',
  PlayerDialogs in 'src\ui\PlayerDialogs.pas',
  PlayerMenu in 'src\ui\PlayerMenu.pas',
  WatermarkOSD in 'src\ui\WatermarkOSD.pas',
  TaskbarManager in 'src\ui\TaskbarManager.pas',
  MainForm in 'src\forms\MainForm.pas' {FrmMain},
  EffectsForm in 'src\forms\EffectsForm.pas' {FrmEffects},
  MediaInfoForm in 'src\forms\MediaInfoForm.pas' {FrmMediaInfo},
  JumpTimeForm in 'src\forms\JumpTimeForm.pas' {FrmJumpTime},
  PreferencesForm in 'src\forms\PreferencesForm.pas' {FrmPreferences},
  BookmarksForm in 'src\forms\BookmarksForm.pas' {FrmBookmarks},
  OpenMediaForm in 'src\forms\OpenMediaForm.pas' {FrmOpenMedia},
  ConvertForm in 'src\forms\ConvertForm.pas' {FrmConvert},
  IPTVForm in 'src\forms\IPTVForm.pas' {FrmIPTV},
  MessagesForm in 'src\forms\MessagesForm.pas' {FrmMessages},
  CustomizeForm in 'src\forms\CustomizeForm.pas' {FrmCustomize},
  PlayerLanguage in 'src\core\PlayerLanguage.pas',
  AboutForm in 'src\forms\AboutForm.pas' {FrmAbout};

{$R 'res\VLCModern.res'}

begin
  Application.Initialize;
  Application.Title := 'VLC Modern';
  try
    Application.Icon.Handle := LoadIcon(HInstance, 'MAINICON');
  except
  end;
  if ForwardToRunningPlayer then Exit;
  InitializePlayerLanguage;
  InitializePlayerAppearance;
  Application.MainFormOnTaskbar := True;

  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
