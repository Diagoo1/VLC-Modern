unit ComboMenus;
interface
uses Vcl.StdCtrls;
function ShowComboMenu(Combo: TComboBox): Boolean;
function ComboMenuOpen(Combo: TComboBox): Boolean;
function ComboArrowProgress(Combo: TComboBox): Single;
procedure ConfigureComboMenu(Combo: TComboBox; AllowCustom: Boolean);
implementation
uses System.Classes, System.SysUtils, System.Types, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Forms, Vcl.Menus, Vcl.ExtCtrls, PlayerMenu, PlayerDialogs;
type
  TComboMenuBinding = class(TComponent)
  private
    Combo: TComboBox;
    Root: TMenuItem;
    Timer: TTimer;
    Progress, Target: Single;
    AllowCustomInput: Boolean;
    procedure Animate(Sender: TObject);
    procedure Closed(Sender: TObject);
    procedure SelectItem(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
  end;
constructor TComboMenuBinding.Create(AOwner: TComponent);
begin
  inherited;
  Name := 'PlayerComboMenu';
  Combo := TComboBox(AOwner);
  Root := TMenuItem.Create(Self);
  Timer:=TTimer.Create(Self); Timer.Enabled:=False; Timer.Interval:=16; Timer.OnTimer:=Animate;
end;
destructor TComboMenuBinding.Destroy;
begin
  if PlayerMenuShows(Root) then ClosePlayerMenus;
  inherited;
end;
procedure TComboMenuBinding.SelectItem(Sender: TObject);
begin
  var Index:=TMenuItem(Sender).Tag;
  if Index<0 then
  begin
    var Value:string:=Combo.Text;
    if not PlayerInput('Enter value','Value:',Value) or (Value='') then Exit;
    Index:=Combo.Items.IndexOf(Value);
    if Index<0 then Index:=Combo.Items.Add(Value);
  end;
  Combo.ItemIndex := Index;
  SendMessage(Combo.Handle,CN_COMMAND,MakeWParam(0,CBN_SELCHANGE),Combo.Handle);
end;
procedure TComboMenuBinding.Open;
var OwnerWindow: TWinControl;
begin
  if PlayerMenuShows(Root) then begin ClosePlayerMenus; Exit; end;
  if Assigned(Combo.OnDropDown) then Combo.OnDropDown(Combo);
  Root.Clear;
  for var I:=0 to Combo.Items.Count-1 do
  begin
    var Item:=TMenuItem.Create(Self);
    Item.Caption:=StringReplace(Combo.Items[I],'&','&&',[rfReplaceAll]);
    Item.Tag:=I;
    Item.RadioItem:=True;
    Item.Checked:=I=Combo.ItemIndex;
    Item.OnClick:=SelectItem;
    Root.Add(Item);
  end;
  if AllowCustomInput then
  begin
    var Item:=TMenuItem.Create(Self); Item.Caption:='Enter a custom value...'; Item.Tag:=-1; Item.OnClick:=SelectItem; Root.Add(Item);
  end;
  Root.Tag:=NativeInt(Combo.Handle);
  Target:=1; Timer.Enabled:=True;
  OwnerWindow:=FindControl(GetAncestor(Combo.Handle,GA_ROOT));
  if (Root.Count>0) and (OwnerWindow is TForm) then
    ShowPlayerMenu(TForm(OwnerWindow),Root,Combo.ClientToScreen(Point(0,Combo.Height+4)),Combo.Width,Closed);
end;
procedure TComboMenuBinding.Animate(Sender: TObject);
begin
  Progress:=Progress+(Target-Progress)*0.32;
  if Abs(Target-Progress)<0.01 then begin Progress:=Target; Timer.Enabled:=False; end;
  Combo.Invalidate;
end;
procedure TComboMenuBinding.Closed(Sender: TObject);
begin
  if csDestroying in ComponentState then Exit;
  Target:=0; Timer.Enabled:=True; Combo.Invalidate;
end;
procedure ConfigureComboMenu(Combo: TComboBox; AllowCustom: Boolean);
var Binding:TComboMenuBinding;
begin
  Binding:=TComboMenuBinding(Combo.FindComponent('PlayerComboMenu'));
  if Binding=nil then Binding:=TComboMenuBinding.Create(Combo);
  Binding.AllowCustomInput:=AllowCustom;
end;
function ComboArrowProgress(Combo: TComboBox): Single;
var Binding:TComboMenuBinding;
begin
  Binding:=TComboMenuBinding(Combo.FindComponent('PlayerComboMenu'));
  if Binding=nil then Exit(0);
  Result:=Binding.Progress;
end;
function ComboMenuOpen(Combo: TComboBox): Boolean;
var Binding: TComboMenuBinding;
begin
  Binding:=TComboMenuBinding(Combo.FindComponent('PlayerComboMenu'));
  Result:=(Binding<>nil) and PlayerMenuShows(Binding.Root);
end;
function ShowComboMenu(Combo: TComboBox): Boolean;
var Binding: TComboMenuBinding;
begin
  Result:=Combo.Enabled;
  if not Result then Exit;
  Binding:=TComboMenuBinding(Combo.FindComponent('PlayerComboMenu'));
  if Binding=nil then Binding:=TComboMenuBinding.Create(Combo);
  Binding.Open;
end;
end.
