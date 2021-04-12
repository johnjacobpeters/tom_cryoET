function hpanel = getimscrollpanel(h_over)
%GETIMSCROLLPANEL Get image scrollpanel.
%   HPANEL = GETIMSCROLLPANEL(H_OVER) returns the imscrollpanel associated
%   with H_OVER. H_OVER may be of type axes or image. If no imscrollpanel is
%   found, GETIMSCROLLPANEL returns an empty matrix.
  
%   Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2.26.1 $  $Date: 2007/07/11 18:56:51 $

hScrollable = ancestor(h_over,'uipanel');

% Not using ancestor here because of a possible HG bug.
% hpanel = ancestor(hScrollable,'uipanel') is returning hScrollable
hpanel = get(hScrollable,'Parent');  

% validate hpanel is a scrollpanel by checking hierarchy
if ~isempty(hpanel)

  kids = get(hpanel,'children');

  if numel(kids)~=4 
    hpanel = [];
    return
  end

  types = get(kids,'Type');
  if ~isequal(types,{'uipanel','uicontrol','uicontrol','uicontrol'}')
    hpanel = [];
    return
  end
  
  styles = get(kids(2:4),'Style');
  if ~isequal(styles,{'frame','slider','slider'}')
    hpanel = [];
    return
  end
  
  grandkid = get(kids(1),'children');
  if numel(grandkid)~=1 || ~strcmp('axes',get(grandkid,'Type'))
    hpanel = [];
    return
  end
  
  greatgrandkids = get(grandkid,'children');
  greatgrandkid_image = findobj(greatgrandkids,'Type','image');
  if numel(greatgrandkid_image)~=1
      hpanel = [];
      return
  end
  

end