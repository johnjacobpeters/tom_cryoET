function updateColorContextMenu(cmenu,color_new)
%updateColorContextMenu Updates the color submenu of the context menu in ROI tools 
%    updateColorContextMenu(CMENU,COLOR_NEW) adds the appropriate check
%    affordances to the color submenu of CMENU if COLOR_NEW matches one of
%    the colors in the color submenu of CMENU.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2007/06/04 21:11:21 $    

% Note: This function is only capable of updating color context menus of the form
% created in createROIContextMenu.
    
color_cmenu = findobj(cmenu,'tag','set color cmenu item');

if ishandle(color_cmenu)

    color_choices = getColorChoices();
    
    idx = [];
    for i = 1:numel(color_choices)
        if isequal(color_choices(i).Color,color_new)
            idx = i;
            break;
        end

    end

    color_submenus = get(color_cmenu,'Children');
    set(color_submenus,'Checked','off');

    new_color_is_context_menu_color = ~isempty(idx);
    if new_color_is_context_menu_color

        % Children of color context menu are parented in opposite order
        % than they appear in context menu.
        menu_idx = numel(color_choices) - idx +1;
        set(color_submenus(menu_idx),'Checked','on');
    end

end

        
    
    
    
    