#ifndef Edition
  #error Define Edition as Full or Lite
#endif
#ifndef Payload
  #error Define the absolute payload directory
#endif
#ifndef OutputPath
  #error Define the absolute output directory
#endif

#ifdef TestBuild
  #define InstallId "VLCModern.Installer.Fixture"
  #define RegisteredName "VLC Modern Installer Fixture"
  #define Capabilities "Software\Orvana\VLCModernInstallerFixture\Capabilities"
  #define MediaProgId "VLCModern.MediaFile.InstallerFixture"
#else
  #define InstallId "VLCModern.Win32"
  #define RegisteredName "VLC Modern"
  #define Capabilities "Software\Orvana\VLCModern\Capabilities"
  #define MediaProgId "VLCModern.MediaFile"
#endif

[Setup]
AppId={#InstallId}
AppName={#RegisteredName}
AppVersion=1.0.9
AppVerName={#RegisteredName} 1.0.9 ({#Edition})
AppPublisher=Tarek Sadek
AppPublisherURL=https://diagoo1.github.io/VLC-Modern/
AppSupportURL=https://github.com/Diagoo1/VLC-Modern/issues
AppUpdatesURL=https://github.com/Diagoo1/VLC-Modern/releases
DefaultDirName={autopf}\{#RegisteredName}
UsePreviousAppDir=no
DefaultGroupName={#RegisteredName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
MinVersion=10.0
ArchitecturesAllowed=x64compatible
ChangesAssociations=yes
SetupIconFile=..\res\app_icon.ico
UninstallDisplayIcon={app}\VLCModern.exe
OutputDir={#OutputPath}
OutputBaseFilename=VLC-Modern-v1.0.9-Setup-{#Edition}-Windows
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
CloseApplications=yes
RestartApplications=no
#if Edition == "Lite"
ArchiveExtraction=full
#endif

[INI]
Filename: "{app}\VLCModern.installed.ini"; Section: "Installation"; Key: "Scope"; String: "Machine"; Flags: uninsdeletesection

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
#if Edition == "Lite"
Name: "downloadplugins"; Description: "Download playback plugins (video, audio, subtitles and streaming)"; GroupDescription: "Optional downloads during setup"; Flags: unchecked
Name: "downloadffmpeg"; Description: "Download FFmpeg (frame-accurate MP4 clipping)"; GroupDescription: "Optional downloads during setup"; Flags: unchecked
#endif

[Files]
Source: "{#Payload}\tools\quickjs-ng\*"; DestDir: "{app}\tools\quickjs-ng"; Flags: ignoreversion
Source: "{#Payload}\VLCModern.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Payload}\libvlc.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Payload}\libvlccore.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Payload}\README.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Payload}\VideoLAN-COPYING.txt"; DestDir: "{app}"; Flags: ignoreversion
#if Edition == "Full"
Source: "{#Payload}\plugins\*"; DestDir: "{app}\plugins"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#Payload}\tools\ffmpeg.exe"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "{#Payload}\tools\FFmpeg-*.txt"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "{#Payload}\tools\.ffmpeg-release-digest"; DestDir: "{app}\tools"; Flags: ignoreversion
#else
Source: "{#Payload}\plugins\*"; DestDir: "{app}\plugins"; Flags: onlyifdoesntexist recursesubdirs createallsubdirs; Check: InstallStarterPlugins
#endif

[Icons]
Name: "{autoprograms}\{#RegisteredName}"; Filename: "{app}\VLCModern.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\{#RegisteredName}"; Filename: "{app}\VLCModern.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Registry]
Root: HKLM; Subkey: "Software\Classes\{#MediaProgId}"; ValueType: string; ValueData: "VLC Modern media"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Classes\{#MediaProgId}\DefaultIcon"; ValueType: string; ValueData: """{app}\VLCModern.exe"",0"
Root: HKLM; Subkey: "Software\Classes\{#MediaProgId}\shell\open"; ValueType: string; ValueData: "Play with VLC Modern"
Root: HKLM; Subkey: "Software\Classes\{#MediaProgId}\shell\open\command"; ValueType: string; ValueData: """{app}\VLCModern.exe"" ""%1"""
Root: HKLM; Subkey: "{#Capabilities}"; ValueType: string; ValueName: "ApplicationName"; ValueData: "{#RegisteredName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "{#Capabilities}"; ValueType: string; ValueName: "ApplicationDescription"; ValueData: "Video and audio player with network streams and IPTV"
Root: HKLM; Subkey: "Software\RegisteredApplications"; ValueType: string; ValueName: "{#RegisteredName}"; ValueData: "{#Capabilities}"; Flags: uninsdeletevalue

Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".mp4"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.mp4\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".mkv"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.mkv\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".avi"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.avi\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".mov"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.mov\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".wmv"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.wmv\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".flv"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.flv\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".webm"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.webm\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".ts"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.ts\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".m2ts"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.m2ts\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".vob"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.vob\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".3gp"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.3gp\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".mpg"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.mpg\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".mpeg"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.mpeg\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".ogv"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.ogv\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".mp3"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.mp3\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".flac"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.flac\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".wav"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.wav\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".aac"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.aac\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".m4a"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.m4a\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".ogg"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.ogg\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".wma"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.wma\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".opus"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.opus\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".m3u"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.m3u\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".m3u8"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.m3u8\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKLM; Subkey: "{#Capabilities}\FileAssociations"; ValueType: string; ValueName: ".pls"; ValueData: "{#MediaProgId}"
Root: HKLM; Subkey: "Software\Classes\.pls\OpenWithProgids"; ValueType: string; ValueName: "{#MediaProgId}"; ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty

[Run]
Filename: "{app}\VLCModern.exe"; WorkingDir: "{app}"; Description: "Launch VLC Modern"; Flags: nowait postinstall skipifsilent runasoriginaluser
Filename: "ms-settings:defaultapps?registeredAppMachine=VLC%20Modern"; Description: "Open Windows Default Apps to choose file associations"; Flags: shellexec nowait postinstall skipifsilent runasoriginaluser unchecked

[InstallDelete]
#if Edition == "Full"
Type: files; Name: "{app}\plugins\.lite-baseline"
#endif
Type: files; Name: "{app}\tools\node\node.exe"
Type: files; Name: "{app}\tools\node\LICENSE"
Type: dirifempty; Name: "{app}\tools\node"

[UninstallDelete]
Type: files; Name: "{app}\VLCModern.installed.ini"
; Lite can create these runtime folders after installation.
Type: filesandordirs; Name: "{app}\plugins"
Type: filesandordirs; Name: "{app}\plugins.pending"
Type: filesandordirs; Name: "{app}\maintenance\plugins-rollback"
Type: dirifempty; Name: "{app}\maintenance"
Type: filesandordirs; Name: "{app}\tools"
Type: dirifempty; Name: "{app}"

#if Edition == "Lite"
[Code]
const
#ifdef OfflineFixture
  #ifndef TestBuild
    #error OfflineFixture requires TestBuild
  #endif
  ReleaseURL = 'http://127.0.0.1:9/';
#else
  ReleaseURL = 'https://github.com/Diagoo1/VLC-Modern/releases/download/components-v1/';
#endif
  PluginsArchive = 'VLC-Modern-LibVLC3-971959D4-x86-Plugins.zip';
  PluginsSHA = '452c93c5f119bb4e81cffc2b497d49cb30cac712917cae08bef6f3f90c03d3a3';
  FFmpegArchive = 'VLC-Modern-FFmpeg-Windows-x64.zip';
  FFmpegSHA = '609355d6ca814f0c8fb3f4089825846ef86df1ffffe0f850e573645ded20e132';

function DownloadProgress(const URL, FileName: String; const Bytes, Total: Int64): Boolean;
begin
  if Total > 0 then
    WizardForm.ProgressGauge.Position := WizardForm.ProgressGauge.Max * Bytes div Total;
  Result := True;
end;

function InstallStarterPlugins: Boolean;
begin
  Result := not FileExists(ExpandConstant('{app}\plugins\.release-digest'));
end;

function InstallComponent(const Name, Archive, Hash: String; IsPlugins: Boolean): Boolean;
var
  Stage, Target: String;
begin
  Result := False;
  Stage := ExpandConstant('{app}\.setup-') + ExtractFileName(ExpandConstant('{tmp}'));
  try
    if IsPlugins then begin
      Target := ExpandConstant('{app}\plugins');
      if DirExists(Target) and not FileExists(Target + '\.lite-baseline') then begin
        Result := True;
        Exit;
      end;
    end else begin
      Target := ExpandConstant('{app}\tools');
      if FileExists(Target + '\ffmpeg.exe') then begin
        Result := True;
        Exit;
      end;
    end;
    WizardForm.StatusLabel.Caption := 'Downloading ' + Name + '...';
    WizardForm.ProgressGauge.Position := 0;
    DownloadTemporaryFile(ReleaseURL + Archive, Archive, Hash, @DownloadProgress);
    WizardForm.StatusLabel.Caption := 'Installing ' + Name + '...';
    if not ForceDirectories(Stage) then
      RaiseException('Could not create component staging directory');
    ExtractArchive(AddBackslash(ExpandConstant('{tmp}')) + Archive, Stage, '', True, nil);
    if IsPlugins then begin
      if not DirExists(Stage + '\codec') then
        RaiseException('Playback plugin archive is incomplete');
      if not SaveStringToFile(Stage + '\.release-digest', 'sha256:' + Hash, False) then
        RaiseException('Could not write playback plugins revision');
      if DirExists(Target) and not RenameFile(Target, Stage + '-starter') then
        RaiseException('Could not stage the starter plugins');
      if not RenameFile(Stage, Target) then begin
        if DirExists(Stage + '-starter') then
          RenameFile(Stage + '-starter', Target);
        RaiseException('Could not activate playback plugins');
      end;
      if DirExists(Stage + '-starter') then
        DelTree(Stage + '-starter', True, True, True);
    end else begin
      if not FileExists(Stage + '\ffmpeg.exe') then
        RaiseException('FFmpeg archive is incomplete');
      if not ForceDirectories(Target) or
         not FileCopy(Stage + '\FFmpeg-NOTICE.txt', Target + '\FFmpeg-NOTICE.txt', False) or
         not FileCopy(Stage + '\FFmpeg-license-notice.txt', Target + '\FFmpeg-license-notice.txt', False) or
         not SaveStringToFile(Target + '\.ffmpeg-release-digest', 'sha256:' + Hash, False) or
         not RenameFile(Stage + '\ffmpeg.exe', Target + '\ffmpeg.exe') then
        RaiseException('Could not activate FFmpeg');
    end;
    Log(Name + ' installed');
    Result := True;
  except
    Log(Name + ' was skipped: ' + GetExceptionMessage);
  end;
  if DirExists(Stage) then
    DelTree(Stage, True, True, True);
end;

procedure CurStepChanged(Step: TSetupStep);
var
  Missing: Boolean;
begin
  if Step <> ssPostInstall then
    Exit;
  Missing := False;
  if WizardIsTaskSelected('downloadplugins') then
    Missing := not InstallComponent('Playback plugins', PluginsArchive, PluginsSHA, True);
  if WizardIsTaskSelected('downloadffmpeg') then
    if not InstallComponent('FFmpeg', FFmpegArchive, FFmpegSHA, False) then
      Missing := True;
  if Missing and not WizardSilent then
    MsgBox('VLC Modern was installed. Some optional components could not be downloaded. You can retry later from Preferences > Components.', mbInformation, MB_OK);
end;
#endif
