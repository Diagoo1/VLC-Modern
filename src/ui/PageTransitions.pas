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
begin
  if (Index<0) or (Index>=Page.PageCount) or (Page.ActivePageIndex=Index) then Exit;
  Page.ActivePageIndex := Index;
  if Assigned(Page.OnChange) then Page.OnChange(Page);
  if Page.Showing then
    RedrawWindow(Page.Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
end;
end.
