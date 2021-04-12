function printImageToFigure(hParent)
%PRINTIMAGETOFIGURE Print image to a figure.  
%  PRINTIMAGETOFIGURE(HPARENT) prints the image thats parented by
%  HPARENT to a new figure.  The new figure window is centered on the
%  screen.

% Copyright 2004 The MathWorks, Inc.

  if strcmpi(get(hParent,'Type'),'uipanel')
    hScrollpanel = hParent;
    old_fig = ancestor(hScrollpanel,'figure');
    old_axes = findobj(old_fig, 'type', 'axes');    
    
    scrollpanelAPI = iptgetapi(hScrollpanel);
    mag  = scrollpanelAPI.getMagnification();
    vis_rect = scrollpanelAPI.getVisibleImageRect();
  
    fig_width  = mag * vis_rect(3);
    fig_height = mag * vis_rect(4);
    xlim = vis_rect(1) + [0 vis_rect(3)];
    ylim = vis_rect(2) + [0 vis_rect(4)];
    
  else %parent is a figure
    old_fig = hParent;
    old_axes = findobj(old_fig, 'type', 'axes');    
    old_fig_pos = get(hParent,'Position');
    
    fig_width = old_fig_pos(3);
    fig_height = old_fig_pos(4);
    xlim = get(old_axes,'Xlim');
    ylim = get(old_axes,'Ylim');
    
  end

  fp = figparams;
  
  fig_left   = round((fp.ScreenWidth - fig_width) / 2);
  fig_bottom = round((fp.ScreenHeight - fig_height) / 2);
  
  fig_position = [fig_left fig_bottom fig_width fig_height];
  
  old_cmap = get(old_fig,'Colormap');
  
  h_figure = figure('Visible', 'off', ...
                    'Units', 'pixels', ...
                    'Position', fig_position, ...
                    'Colormap', old_cmap,...
                    'PaperPositionMode', 'auto', ...
                    'InvertHardcopy', 'off');
  
  h_axes = copyobj(old_axes, h_figure);
  set(h_axes, 'Units', 'normalized', ...
              'Position', [0 0 1 1], ...
              'XLim', xlim,...
              'YLim', ylim);
  hImage = findobj(h_axes, 'type', 'image');
  set(hImage,'ButtonDownFcn', '',...
             'UicontextMenu','');

  set(h_figure, 'Visible', 'on');
  