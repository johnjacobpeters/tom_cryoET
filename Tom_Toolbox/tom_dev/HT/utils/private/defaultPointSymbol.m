function draw_API = defaultPointSymbol
%defaultPointSymbol Creates renderer for points.  
%   DRAW_API = defaultPointSymbol creates a DRAW_API for use in association
%   with IMPOINT that draws points. DRAW_API is a structure of function handles
%   that are used by IMPOINT to draw the point and update its properties.
%
%       DRAW_API.initialize(h_group)
%       DRAW_API.setColor(color)
%       DRAW_API.updateView(position)  
%       DRAW_API.setString(string)   
%       DRAW_API.getBoundingBox()   
%       DRAW_API.clear()
%       DRAW_API.setVisible()    

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5.2.1 $  $Date: 2007/07/09 17:10:15 $
  
  % initialize variables needing function scope
  [bounding_box, h_group, h_axes, h_circle, h_plus, h_text,...
   is_ydir_reverse, circle_diameter_pixels,...
   half_delta_x_data_units, half_delta_y_data_units,...
   text_nudge_data_units] = deal([]);

  draw_API.initialize              = @initialize;
  draw_API.setColor                = @setColor;
  draw_API.updateView              = @updateView;  
  draw_API.translateView           = @translateView;    
  draw_API.setString               = @setString;  
  draw_API.getBoundingBox          = @getBoundingBox;
  draw_API.clear                   = @clear;
  draw_API.setVisible              = @setVisible;

  %------------------------------
  function setVisible(TF)
           
      if TF
         set(h_group,'Visible','on')
     else
         set(h_group,'Visible','off');
     end
      
  end    
  
  %----------------------------
  function pos = getBoundingBox
    pos = bounding_box;
  end

  %---------------------------
  function initialize(h)

    h_group = h;
    
    % want hg objects to be created by not visible until client is ready to
    % display point.
    set(h_group,'Visible','off');
    
    h_circle      = line(...
                         'Marker', 'o', ...
                         'HitTest', 'off', ...
                         'Tag','circle',...
                         'Parent', h_group);
    
    h_plus        = line(...
                         'Marker', '+', ...                       
                         'HitTest', 'off', ...
                         'Tag','plus',...
                         'Parent', h_group);
  
    h_text        = text(...,
                         'FontName','SansSerif',...
                         'FontSize',8,...
                         'HorizontalAlignment','left',...
                         'VerticalAlignment','top',...
                         'Clipping','on',...
                         'HitTest', 'off', ...
                         'Parent', h_group,...
                         'Tag','label',...
                         'BackgroundColor','w');

    h_axes = iptancestor(h_group, 'axes');

    is_ydir_reverse = strcmp(get(h_axes,'YDir'),'reverse');
    
    circle_diameter_pixels = 3;
    wing_size_pixels = 3;

    points_per_screen_pixel = getPointsPerScreenPixel;
    circle_size_points = 2*circle_diameter_pixels * points_per_screen_pixel;
    plus_size_points = ...
        circle_size_points + 2*wing_size_pixels*points_per_screen_pixel; 

    set(h_circle,'MarkerSize',circle_size_points)
    set(h_plus,'MarkerSize',plus_size_points)    
    
  end

  %-------------
  function clear

    delete([h_circle h_plus h_text])
    
  end

  %-------------------
  function setColor(c)
    if ishandle(h_group) 
      set(h_plus, 'Color', c);
      set(h_circle,'MarkerFaceColor',c,...
                   'MarkerEdgeColor',c);                     
    end
  end

  %----------------------------
  function updateView(position)
       
    pos_x = position(1);
    pos_y = position(2);    
  
    if ~ishandle(h_group)
        return;
    end

    [dx_per_screen_pixel, dy_per_screen_pixel] = getAxesScale(h_axes);
    
    x_mid = pos_x / dx_per_screen_pixel;
    x_left = x_mid - circle_diameter_pixels;
    x_right = x_mid + circle_diameter_pixels;

    % Note that y_min and y_max are reversed in terms of how the shape 
    % is drawn if get(h_axes,'YDir') is 'reverse'.
    y_mid = pos_y / dy_per_screen_pixel;
    y_min = y_mid - circle_diameter_pixels;
    y_max = y_mid + circle_diameter_pixels;

    % Convert the x and y extrema to data units
    [x,y] = pixel2DataUnits(h_axes,[x_left x_right],[y_min y_max]);

    % Calculate deltas to use when we are just translating
    half_delta_x_data_units = (x(2) - x(1))/2;
    half_delta_y_data_units = (y(2) - y(1))/2;

    % move the text over a bit
    nudge = circle_diameter_pixels * 2; 
    text_nudge_data_units = nudge * dx_per_screen_pixel;
    
    % Set the bounding box to include the entire extent of the drawn
    % rectangle, including decorations.
    bounding_box = findBoundingBox(x,y);
    
    if ~isequal(get(h_circle, 'XData'), pos_x) || ...
       ~isequal(get(h_circle, 'YData'), pos_y)
      set([h_circle h_plus],...
          'XData', pos_x, 'YData', pos_y);
    end

    % This needs to be outside of conditional in case user zoomed and so 
    % text stays right distance from the symbol.
    moveText(x,y)
  end

  %-------------------------------
  function translateView(position)
    
    pos_x = position(1);
    pos_y = position(2);

    dx2 = half_delta_x_data_units;
    x = [pos_x-dx2, pos_x+dx2];

    dy2 = half_delta_y_data_units;
    y = [pos_y-dy2, pos_y+dy2];
    
    % Set the bounding box to include the entire extent of the drawn
    % rectangle, including decorations.
    bounding_box = findBoundingBox(x,y);
    
    if ~isequal(get(h_circle, 'XData'), pos_x) || ...
       ~isequal(get(h_circle, 'YData'), pos_y)
      set([h_circle h_plus],...
          'XData', pos_x, 'YData', pos_y);
      moveText(x,y)
    end
    
  end
  
  %---------------------
  function moveText(x,y)
    
    no_text = isempty(get(h_text,'String'));
    if no_text
        return;
    end
      
    % Figure out text position depending on axes 'YDir'
    x_right = max(x) + text_nudge_data_units;
    y_min = min(y); 
    y_max = max(y); 
    if is_ydir_reverse
      text_pos = [x_right y_max];
    else
      text_pos = [x_right y_min];    
    end
    set(h_text,'Position',text_pos);
    
  end
  
  %--------------------
  function setString(s)
      if ~isempty(s)
          set(h_text,'String',s);
          api = iptgetapi(h_group);
          updateView(api.getPosition());
      end
  end

  
end
