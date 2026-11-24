unit PageTransitions;
interface
uses Vcl.ComCtrls;
procedure EnablePageTransitions(Page: TPageControl);
procedure SelectPageAnimated(Page: TPageControl; Index: Integer);
implementation
uses Winapi.Windows, Winapi.Messages;
procedure EnablePageTransitions(Page: TPageControl);
begin
  Page.DoubleBuffered := False;
end;
procedure SelectPageAnimated(Page: TPageControl; Index: Integer);
var Visible: Boolean;
begin
  if (Index<0) or (Index>=Page.PageCount) or (Page.ActivePageIndex=Index) then Exit;
  Visible := Page.Showing;
  if Visible then SendMessage(Page.Handle,WM_SETREDRAW,0,0);
  try
    Page.ActivePageIndex := Index;
    if Assigned(Page.OnChange) then Page.OnChange(Page);
  finally
    if Visible then
    begin
      SendMessage(Page.Handle,WM_SETREDRAW,1,0);
      RedrawWindow(Page.Handle,nil,0,RDW_INVALIDATE or RDW_ALLCHILDREN);
    end;
  end;
end;
end.
