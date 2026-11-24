unit FileAssociations;
interface
function RegisterPlayerAssociations(const AppPath:string; Video,Audio,Playlists:Boolean):Integer;
implementation
uses Winapi.Windows,Winapi.ShlObj, System.SysUtils,System.Win.Registry,SettingsStore;
function RegisterPlayerAssociations(const AppPath:string; Video,Audio,Playlists:Boolean):Integer;
var Reg:TRegistry; Prefix,ProgId,Command:string;
  procedure Put(const Key,Name,Value:string);
  begin
    Reg.CloseKey;
    if not Reg.OpenKey(Prefix+Key,True) then raise Exception.Create('Could not register media file types.');
    Reg.WriteString(Name,Value); Reg.CloseKey;
  end;
  procedure Extensions(const Values:array of string);
  begin
    for var Ext in Values do
    begin
      // Advertise Open With support; preserve existing extension defaults.
      Put('Software\Classes\'+Ext+'\OpenWithProgids',ProgId,'');
      Put('Software\Orvana\VLCModern\Capabilities\FileAssociations',Ext,ProgId);
      Inc(Result);
    end;
  end;
begin
  Result:=0;
  if not (Video or Audio or Playlists) then Exit;
  Prefix:='';
  if GetEnvironmentVariable('VLC_SETTINGS_TEST_ID')<>'' then Prefix:=SettingsRegistryRoot+'\AssociationFixture\';
  ProgId:='VLCModern.MediaFile'; Command:='"'+AppPath+'" "%1"';
  Reg:=TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey:=HKEY_CURRENT_USER;
    Put('Software\Classes\'+ProgId,'','VLC Modern media');
    Put('Software\Classes\'+ProgId+'\DefaultIcon','','"'+AppPath+'",0');
    Put('Software\Classes\'+ProgId+'\shell\open','', 'Play with VLC Modern');
    Put('Software\Classes\'+ProgId+'\shell\open\command','',Command);
    Put('Software\Orvana\VLCModern\Capabilities','ApplicationName','VLC Modern');
    Put('Software\Orvana\VLCModern\Capabilities','ApplicationDescription','Video and audio player');
    Put('Software\RegisteredApplications','VLC Modern','Software\Orvana\VLCModern\Capabilities');
    if Video then Extensions(['.mp4','.mkv','.avi','.mov','.wmv','.flv','.webm','.ts','.m2ts','.vob','.3gp','.mpg','.mpeg','.ogv']);
    if Audio then Extensions(['.mp3','.flac','.wav','.aac','.m4a','.ogg','.wma','.opus']);
    if Playlists then Extensions(['.m3u','.m3u8','.pls']);
  finally Reg.Free; end;
  if Prefix='' then SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,nil,nil);
end;
end.
