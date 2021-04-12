function hout = imgridlines(h)
%IMGRIDLINES Superimpose pixel grid lines on a displayed image.
%   IMGRIDLINES adds dashed gray lines, forming a grid outlining each
%   pixel, to the current axes.  The current axes must contain an image. 
%
%   IMGRIDLINES(IMAGE_HANDLE) adds the lines to the axes containing the
%   specified image handle.  IMGRIDLINES(AXES_HANDLE) or
%   IMGRIDLINES(FIGURE_HANDLE) adds lines for the first image object
%   found within the specified axes or figure object.
%
%   HGROUP = IMGRIDLINES(...) returns a handle to the HGGROUP object that
%   contains the line objects comprising the pixel grid.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/10/28 15:52:03 $

if nargin < 1
    hFig = gcf;
    hAx  = gca;
    hIm = findobj(hAx, 'Type', 'image');
    if isempty(hIm)
        error('Images:imgridlines:noImage', ...
              'Could not find image.');
    else
        hIm = hIm(1);
    end
else
    if ~ishandle(h)
        error('Images:imgridlines:notHandle', ...
              'H is not a valid handle.');
    end
    switch get(h, 'Type')
      case 'figure'
        hFig = h;
        hAx = get(hFig, 'CurrentAxes');
        hIm = findobj(hAx, 'Type', 'image');
        
      case 'axes'
        hFig = ancestor(h, 'figure');
        hAx = h;
        hIm = findobj(hAx, 'Type', 'image');
        
      case 'image'
        hIm = h;
        hAx = ancestor(hIm, 'axes');
        hFig = ancestor(hAx, 'figure');
        
      otherwise
        error('Images:imgridlines:wrongTypeHandle', ...
              'H is not a valid figure, axes, or image handle.');
    end
    
    if isempty(hIm)
        error('Images:imgridlines:noImage', ...
              'Could not find image.');
    end
    
    hIm = hIm(1);
end

ax_handle = handle(ancestor(hIm, 'axes'));

hgrp = hggroup('Parent', ax_handle);

h_vertical_solid = line('LineStyle', '-', ...
                        'Color', [.5 .5 .5], ...
                        'Parent', hgrp);

h_vertical_dotted = line('LineStyle', ':', ...
                         'Color', [.65 .65 .65], ...
                         'Parent', hgrp);

h_horizontal_solid = line('LineStyle', '-', ...
                          'Color', [.5 .5 .5], ...
                          'Parent', hgrp);

h_horizontal_dotted = line('LineStyle', ':', ...
                           'Color', [.65 .65 .65], ...
                           'Parent', hgrp);

updateXYData();

updateFunction = @updateXYData;

hImage = handle(hIm);
xdata_listener = handle.listener(hImage, ... 
                                 hImage.findprop('XData'), ...
                                 'PropertyPostSet', ...
                                 updateFunction);
ydata_listener = handle.listener(hImage, ...
                                 hImage.findprop('YData'), ...
                                 'PropertyPostSet', ...
                                 updateFunction);

setappdata(hgrp, 'Listeners', [xdata_listener ydata_listener]);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function updateXYData(varargin)
  
    im_xdata = get(hIm, 'XData');
    im_ydata = get(hIm, 'YData');
    M = size(get(hIm, 'CData'), 1);
    N = size(get(hIm, 'CData'), 2);
    
    kids = get(hgrp, 'Children');
    
    if N <= 1
        x_per_pixel = 1;
    else
        x_per_pixel = diff(im_xdata) / (N - 1);
    end
    
    if M <= 1
        y_per_pixel = 1;
    else
        y_per_pixel = diff(im_ydata) / (M - 1);
    end
    
    x1 = im_xdata(1) - (x_per_pixel/2);
    x2 = im_xdata(2) + (x_per_pixel/2);
    y1 = im_ydata(1) - (y_per_pixel/2);
    y2 = im_ydata(2) + (y_per_pixel/2);
    
    x = linspace(x1, x2, N+1);
    xx = zeros(1, 2*length(x));
    xx(1:2:end) = x;
    xx(2:2:end) = x;
    yy = zeros(1, length(xx));
    yy(1:4:end) = y1;
    yy(2:4:end) = y2;
    yy(3:4:end) = y2;
    yy(4:4:end) = y1;
    
    set(kids(1), 'XData', xx, 'YData', yy);
    set(kids(2), 'XData', xx, 'YData', yy);
    
    y = linspace(y1, y2, M+1);
    yy = zeros(1, 2*length(y));
    yy(1:2:end) = y;
    yy(2:2:end) = y;
    xx = zeros(1, length(yy));
    xx(1:4:end) = x1;
    xx(2:4:end) = x2;
    xx(3:4:end) = x2;
    xx(4:4:end) = x1;
    
    set(kids(3), 'XData', xx, 'YData', yy);
    set(kids(4), 'XData', xx, 'YData', yy);
    
  end

if nargout > 0
    hout = hgrp;
end

end
