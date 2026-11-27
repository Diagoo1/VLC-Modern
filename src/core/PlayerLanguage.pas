unit PlayerLanguage;

interface

uses CurvedControls, System.SysUtils, Vcl.Controls, Winapi.GDIPOBJ;

procedure InitializePlayerLanguage;
function PlayerLanguageChoice: string;
function PlayerIsArabic: Boolean;
function PlayerUIFont: string;
function PlayerFontFamily: TGPFontFamily;
function Translate(const Source: string): string;
function LocalizeMessageText(const Source: string): string;
function LocalizeWindowsError(Code: Cardinal): string;
function LocalizeExceptionText(E: Exception): string;
procedure LocalizeControls(Control: TControl);
procedure PlaceLocalized(Control: TControl; Left, Top, Width, Height: Integer);

implementation

uses
  Winapi.Windows, System.Classes, System.IOUtils, System.JSON, System.TypInfo,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Graphics, SettingsStore;

var
  Catalog: TJSONObject;
  Arabic, CairoLoaded: Boolean;
  CairoRegular, CairoBold: THandle;
  CairoFontCollection: TGPPrivateFontCollection;

function PlayerLanguageChoice: string;
var
  Store: TAppSettings;
begin
  Store := TAppSettings.Create(ExtractFilePath(ParamStr(0)) + 'VLCModern.ini');
  try
    Result := Store.ReadString('Interface', 'Language', 'system');
  finally
    Store.Free;
  end;
  if (Result <> 'ar') and (Result <> 'en') then Result := 'system';
end;

function LoadFont(const ResourceName: string): THandle;
var
  Resource: HRSRC;
  Count, Size: DWORD;
  Data: Pointer;
begin
  Result := 0;
  Resource := FindResource(HInstance, PChar(ResourceName), RT_RCDATA);
  if Resource = 0 then Exit;
  Size := SizeOfResource(HInstance, Resource);
  Data := LockResource(LoadResource(HInstance, Resource));
  if (Data <> nil) and (Size > 0) then
  begin
    Result := AddFontMemResourceEx(Data, Size, nil, @Count);
    CairoFontCollection.AddMemoryFont(Data, Size);
  end;
end;

procedure InitializePlayerLanguage;
var
  Choice, ResourceName: string;
  Resource: TResourceStream;
  Data: TBytes;
  Parsed: TJSONValue;
begin
  Choice := PlayerLanguageChoice;
  Arabic := (Choice = 'ar') or ((Choice = 'system') and
    ((GetUserDefaultUILanguage and $03FF) = LANG_ARABIC));
  if Arabic then
  begin
    ResourceName := 'PLAYER_LANG_AR';
    CairoFontCollection := TGPPrivateFontCollection.Create;
    CairoRegular := LoadFont('PLAYER_CAIRO_REGULAR');
    CairoBold := LoadFont('PLAYER_CAIRO_BOLD');
    CairoLoaded := CairoRegular <> 0;
  end
  else ResourceName := 'PLAYER_LANG_EN';
  Resource := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    SetLength(Data, Resource.Size);
    Resource.ReadBuffer(Data[0], Length(Data));
    Parsed := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetString(Data));
    if Parsed is TJSONObject then Catalog := TJSONObject(Parsed)
    else Parsed.Free;
  finally
    Resource.Free;
  end;
end;

function PlayerIsArabic: Boolean;
begin
  Result := Arabic;
end;

function PlayerUIFont: string;
begin
  if Arabic and CairoLoaded then Result := 'Cairo'
  else Result := 'Segoe UI';
end;

function PlayerFontFamily: TGPFontFamily;
begin
  if CairoLoaded then
  begin
    Result := TGPFontFamily.Create('Cairo', CairoFontCollection);
    if Ord(Result.GetLastStatus) = 0 then Exit;
    Result.Free;
  end;
  Result := TGPFontFamily.Create('Segoe UI');
end;

function Translate(const Source: string): string;
var
  Value: TJSONValue;
begin
  Result := Source;
  if Catalog = nil then Exit;
  Value := Catalog.GetValue(Source.Trim);
  if Value is TJSONString then Result := Value.Value;
end;

function LocalizeMessageText(const Source: string): string;
  function LocalizeLine(const Line: string): string;
  begin
    Result := Translate(Line);
    if Result <> Line then Exit;
    for var I := Length(Line) - 1 downto 1 do
      if (Line[I] = ':') and (Line[I + 1] = ' ') then
      begin
        var Prefix := Copy(Line, 1, I);
        var Localized := Translate(Prefix);
        if Localized <> Prefix then Exit(Localized + Copy(Line, I + 1, MaxInt));
      end;
  end;
var
  Start, I: Integer;
begin
  Result := Translate(Source);
  if not Arabic or (Result <> Source) then Exit;
  Result := '';
  Start := 1;
  for I := 1 to Length(Source) do
    if CharInSet(Source[I], [#10, #13]) then
    begin
      Result := Result + LocalizeLine(Copy(Source, Start, I - Start)) + Source[I];
      Start := I + 1;
    end;
  Result := Result + LocalizeLine(Copy(Source, Start, MaxInt));
end;

function LocalizeWindowsError(Code: Cardinal): string;
begin
  if not Arabic then Exit(SysErrorMessage(Code));
  case Code of
    ERROR_FILE_NOT_FOUND: Result := Translate('Windows could not find the file.');
    ERROR_PATH_NOT_FOUND: Result := Translate('Windows could not find the folder.');
    ERROR_ACCESS_DENIED: Result := Translate('Windows denied access. Check the file or folder permissions.');
    ERROR_SHARING_VIOLATION, ERROR_LOCK_VIOLATION:
      Result := Translate('The file is in use. Close the other program and try again.');
    ERROR_HANDLE_DISK_FULL, ERROR_DISK_FULL:
      Result := Translate('The drive is full. Free some space and try again.');
    ERROR_INVALID_NAME, ERROR_FILENAME_EXCED_RANGE:
      Result := Translate('The file or folder name is invalid.');
    ERROR_FILE_EXISTS, ERROR_ALREADY_EXISTS:
      Result := Translate('A file with that name already exists. Choose a new name.');
  else
    Result := Format(Translate('Windows error %d.'), [Code]);
  end;
end;

function LocalizeExceptionText(E: Exception): string;
begin
  if not Arabic then Exit(E.Message);
  if E is EOSError then Exit(LocalizeWindowsError(EOSError(E).ErrorCode));
  if E is EDirectoryNotFoundException then Exit(LocalizeWindowsError(ERROR_PATH_NOT_FOUND));
  if E is EFileNotFoundException then Exit(LocalizeWindowsError(ERROR_FILE_NOT_FOUND));
  if E is EFCreateError then
    Exit(Translate('Could not create the file. Check the path, available space and permissions.'));
  if E is EFOpenError then
    Exit(Translate('Could not open the file. Check the path and permissions.'));
  Result := LocalizeMessageText(E.Message);
end;

type
  TLocalizedControlAccess = class(TControl);

procedure LocalizeControls(Control: TControl);
var
  CaptionInfo: PPropInfo;
  Source, Localized: string;
begin
  if not Arabic then Exit;
  if (Control is TComboBox) and SameText(Control.Name, 'cboNetworkURL') then
    Control.BiDiMode := bdLeftToRight
  else
    Control.BiDiMode := bdRightToLeftReadingOnly;
  if not (Control is TCustomEdit) then
  begin
    CaptionInfo := GetPropInfo(Control, 'Caption');
    if CaptionInfo <> nil then
    begin
      Source := GetStrProp(Control, CaptionInfo);
      Localized := Translate(Source);
      if Source <> Localized then SetStrProp(Control, CaptionInfo, Localized);
    end;
  end;
  if (Control is TPlayerCheckBox) and not TLocalizedControlAccess(Control).AutoSize then
  begin
    var MinimumHeight := MulDiv(21, Control.CurrentPPI, 96);
    if Control.Height < MinimumHeight then Control.Height := MinimumHeight;
  end;
  Control.Hint := Translate(Control.Hint);
  if TLocalizedControlAccess(Control).Font.Name = 'Segoe UI' then
    TLocalizedControlAccess(Control).Font.Name := PlayerUIFont;
  if (Control is TLabel) and not TLocalizedControlAccess(Control).AutoSize and
     not TLabel(Control).WordWrap and (TLabel(Control).Caption <> '') then
  begin
    var LabelControl := TLabel(Control);
    LabelControl.Canvas.Font.Assign(LabelControl.Font);
    var TextHeight := LabelControl.Canvas.TextHeight(LabelControl.Caption) +
      MulDiv(2, Control.CurrentPPI, 96);
    if Control.Height < TextHeight then Control.Height := TextHeight;
  end;
  if Control is TWinControl then
    for var I := 0 to TWinControl(Control).ControlCount - 1 do
      LocalizeControls(TWinControl(Control).Controls[I]);
end;

procedure PlaceLocalized(Control: TControl; Left, Top, Width, Height: Integer);
begin
  if Arabic and Assigned(Control.Parent) then
    Left := Control.Parent.ClientWidth - Left - Width;
  Control.SetBounds(Left, Top, Width, Height);
end;

initialization

finalization
  Catalog.Free;
  CairoFontCollection.Free;
  if CairoBold <> 0 then RemoveFontMemResourceEx(CairoBold);
  if CairoRegular <> 0 then RemoveFontMemResourceEx(CairoRegular);

end.
