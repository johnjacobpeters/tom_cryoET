function draw_API = wingedRect
%wingedRect Creates renderer for winged rectangle symbol.
%   DRAW_API = wingedRect(H_GROUP) creates a DRAW_API for use in association
%   with IMRECT that draws rectangles with wings that show only if the rectangle
%   is very small. DRAW_API is a structure of function handles that are used by
%   IMRECT to draw the rectangle and update its properties.
%
%       DRAW_API.setColor
%       DRAW_API.updateView
%       DRAW_API.getBoundingBox
%       DRAW_API.clear    
%       DRAW_API.setResizable
%       DRAW_API.setFixedAspectRatio
%       DRAW_API.setVisible
%       DRAW_API.isRectBody
%       DRAW_API.isSide
%       DRAW_API.isCorner
%       DRAW_API.isWing
%       DRAW_API.findSelectedSide
%       DRAW_API.findSelectedVertex   
    
%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2007/03/27 19:11:40 $

% Initialize function scoped variables to empty
[h_bottom_line,h_wing_line,h_patch,h_corner_markers,h_side_markers,...
h_top_lines,is_fixed_aspect_ratio,is_resizable,num_vert,line_tags,...
side_marker_tags,corner_marker_tags,mode_invariant_obj,...
mode_variant_obj,all_obj,h_axes,h_group,bounding_box] = deal([]);

draw_API.initialize          = @initialize;
draw_API.setColor            = @setColor;
draw_API.updateView          = @updateView;
draw_API.getBoundingBox      = @getBoundingBox;
draw_API.clear               = @clear;
draw_API.setResizable        = @setResizable;
draw_API.setFixedAspectRatio = @setFixedAspectRatio;
draw_API.setVisible          = @setVisible;
draw_API.isBody              = @isBody;
draw_API.isSide              = @isSide;
draw_API.isCorner            = @isCorner;
draw_API.isWing              = @isWing;
draw_API.findSelectedSide    = @findSelectedSide;
draw_API.findSelectedVertex  = @findSelectedVertex;

   %---------------------
   function initialize(h)
	   
	   h_group = h;
	  
	   h_axes = iptancestor(h_group,'axes');

	   % This is a workaround to an HG bug g349263.
	   buttonDown = getappdata(h_group,'buttonDown');

	   % The line objects should have a width of one screen pixel.
	   % line_width = ceil(getPointsPerScreenPixel);
	   line_width = getPointsPerScreenPixel();
	   h_bottom_line = line('Color', 'w', ...
		   'LineStyle', '-', ...
		   'LineWidth', 3*line_width, ...
		   'HitTest', 'off', ...
		   'Parent', h_group,...
		   'Tag','bottom line',...
		   'Visible','off');
	   h_wing_line = line(...
		   'LineStyle', '-', ...
		   'LineWidth', line_width, ...
		   'HitTest', 'on', ...
		   'Parent', h_group,...
		   'Tag','wing line',...
		   'ButtonDownFcn',buttonDown,...
		   'Visible','off');

	   h_patch = patch('FaceColor', 'none', 'EdgeColor', 'none', ...
		   'HitTest', 'on', ...
		   'Parent', h_group,...
		   'Tag','patch',...
		   'ButtonDownFcn',buttonDown,...
		   'Visible','off');

	   % Function scope. Determines whether rectangle is drawn to indicate fixed
	   % aspect ratio.
	   is_fixed_aspect_ratio = false;

	   % Function scope. Determines whether rectangle is drawn to indicate it is
	   % resizable.
	   is_resizable = true;

	   % Function scope. Number of vertices in rectangle.
	   num_vert = 4;

	   line_tags = {'minx' 'maxy' 'maxx' 'miny'};

	   % Preallocate arrays containing HG objects to clean up lint.
	   [h_top_lines,h_side_markers,h_corner_markers] = deal(zeros(1,4));

	   for i = 1:num_vert

		   h_top_lines(i) = line('LineStyle', '-', ...
			   'LineWidth', line_width, ...
			   'HitTest', 'on', ...
			   'Parent', h_group,...
			   'Tag', [line_tags{i} ' top line'],...
			   'ButtonDownFcn',buttonDown,...
			   'Visible','off');
	   end

	   side_marker_tags   = {'minx' 'maxy' 'maxx' 'miny'};
	   corner_marker_tags = {'minx miny', 'minx maxy',...
		   'maxx maxy', 'maxx miny'};

	   for i = 1:num_vert

		   h_side_markers(i) = line('Marker','square',...
			   'MarkerSize',6,...
			   'HitTest','off',...
			   'Parent',h_group,...
			   'Tag',[side_marker_tags{i} ' side marker'],...
			   'Visible','off');

		   h_corner_markers(i) = line('Marker','square',...
			   'MarkerSize',6,...
			   'HitTest','on',...
			   'Parent',h_group,...
			   'Tag',[corner_marker_tags{i} ' corner marker'],...
			   'ButtonDownFcn',buttonDown,...
			   'Visible','off');
	   end

	   % Declare at function scope for use in setVisible and clear methods.
	   mode_invariant_obj = [h_wing_line,h_bottom_line,h_top_lines,h_patch];
	   mode_variant_obj = [h_corner_markers,h_side_markers];
	   all_obj = [mode_invariant_obj, mode_variant_obj];

	   setupCursorManagement();
	   
   end

   %-------------
   function clear
   
       delete(all_obj);
       
   end
    
   %----------------------
   function setVisible(TF)
           
       if TF
           set(mode_invariant_obj,'Visible','on');
           drawModeAffordances();
       else
           set(all_obj,'Visible','off');
       end
       
   end    

    %----------------------------
    function pos = getBoundingBox
        pos = bounding_box;
    end % getBoundingBox

    %----------------------------
    function updateView(position)

        if ~ishandle(h_group)
            return;
        end

        x_side_markers = [position(1), position(1)+position(3)/2,...
                          position(1)+position(3), position(1)+position(3)/2];
        
        y_side_markers = [position(2)+position(4)/2, position(2)+position(4),...
                          position(2)+position(4)/2, position(2)];
        
        x_top_lines = [position(1), position(1);...
                       position(1), position(1)+position(3);...
                       position(1)+position(3),position(1)+position(3);...
                       position(1)+position(3),position(1)];
        
        y_top_lines = [position(2), position(2)+position(4);...
                       position(2)+position(4),position(2)+position(4);...
                       position(2)+position(4),position(2);...
                       position(2),position(2)];
   
        [dx_per_screen_pixel, dy_per_screen_pixel] = getAxesScale(h_axes);

        min_decorated_rect_size = 30;
        x_left = position(1) / dx_per_screen_pixel;
        x_right = (position(1) + position(3)) / dx_per_screen_pixel;
        x_wing_size = max(ceil((min_decorated_rect_size - ...
            (x_right - x_left)) / 2), 0);

        y_bottom = position(2) / dy_per_screen_pixel;
        y_top = (position(2) + position(4)) / dy_per_screen_pixel;
        y_wing_size = max(ceil((min_decorated_rect_size - ...
            (y_top - y_bottom)) / 2), 0);

        x1 = x_left - x_wing_size;
        x2 = x_left;
        x3 = (x_left + x_right) / 2;
        x4 = x_right;
        x5 = x_right + x_wing_size;

        y1 = y_bottom - y_wing_size;
        y2 = y_bottom;
        y3 = (y_bottom + y_top) / 2;
        y4 = y_top;
        y5 = y_top + y_wing_size;
        
        % (x,y) is a polygon that strokes the middle line.  Here it is in
        % screen pixel units.
        x = [x1 x2 x2 x3 x3 x3 x4 x4 x5 x4 x4 x3 x3 x3 x2 x2 x1];
        y = [y3 y3 y2 y2 y1 y2 y2 y3 y3 y3 y4 y4 y5 y4 y4 y3 y3];
        
        % Convert the (x,y) polygon back to data units.
        [x,y] = pixel2DataUnits(h_axes,x,y);
        
        xx1 = x1 - 1;
        xx2 = x2 - 1;
        xx3 = x3 - 1;
        xx4 = x3 + 1;
        xx5 = x4 + 1;
        xx6 = x5 + 1;

        yy1 = y1 - 1;
        yy2 = y2 - 1;
        yy3 = y3 - 1;
        yy4 = y3 + 1;
        yy5 = y4 + 1;
        yy6 = y5 + 1;

        % (xx,yy) is a polygon that strokes the outer line.  Here it is in
        % screen pixel units.
        xx = [xx1 xx2 xx2 xx3 xx3 xx4 xx4 xx5 xx5 xx6 xx6 xx5 xx5 ...
            xx4 xx4 xx3 xx3 xx2 xx2 xx1 xx1];
        yy = [yy3 yy3 yy2 yy2 yy1 yy1 yy2 yy2 yy3 yy3 yy4 yy4 yy5 ...
            yy5 yy6 yy6 yy5 yy5 yy4 yy4 yy3];

        % Convert the (xx,yy) polygon back to data units.
        [xx,yy] = pixel2DataUnits(h_axes,xx,yy);

        % Set the outer position to include the entire extent of the drawn
        % rectangle, including decorations.
        bounding_box = findBoundingBox(xx,yy);
        
        setXYDataIfChanged(x, y,...
                           x_side_markers, y_side_markers,...
                           x_top_lines,y_top_lines);
                       
    end %updateView

    %------------------
    function setColor(c)
        
        handlesAreValid = all(ishandle([h_top_lines,...
                                        h_wing_line,...
                                        h_side_markers,...
                                        h_corner_markers]));
                                
        if handlesAreValid
            set([h_top_lines,h_wing_line], 'Color', c);
            set([h_side_markers,h_corner_markers],'Color',c)
        end
        
    end %setColor        

    %-------------------------------
    function setFixedAspectRatio(TF)
    
        is_fixed_aspect_ratio = TF;
        drawModeAffordances();
        
    end %setFixedAspectRatio
    
    %------------------------
    function setResizable(TF)
    
        is_resizable = TF;
        drawModeAffordances();
        
    end %setResizable
    
    %---------------------------
    function drawModeAffordances
    
        if is_resizable
            set(h_corner_markers,'Visible','on');
            if is_fixed_aspect_ratio
                set(h_side_markers,'Visible','off');
                set(h_top_lines,'hittest','off');
            else
                set(h_side_markers,'Visible','on');
                set(h_top_lines,'hittest','on');
            end
        else
            set([h_corner_markers,h_side_markers],'Visible','off');
            set(h_top_lines,'hittest','off');
        end        
    
    end %drawModeAffordances
    
    %----------------------------------
    function setXYDataIfChanged(x, y, x_side_markers, y_side_markers,...
                                x_top_lines,y_top_lines)
    
        % Set XData and YData of HG object h to x and y if they are different.  h
        % must be a valid HG handle to an object having XData and YData properties.
        % No validation is performed.
        h = [h_wing_line,h_bottom_line,h_patch];
        if ~isequal(get(h, 'XData'), x) || ~isequal(get(h, 'YData'), y)
            set(h, 'XData', x, 'YData', y);
            for j= 1:num_vert
                set(h_top_lines(j),'XData',x_top_lines(j,:),'YData',y_top_lines(j,:));
                set(h_corner_markers(j),'XData',x_top_lines(j,1),'YData',y_top_lines(j,1));   
                set(h_side_markers(j),'XData',x_side_markers(j),'YData',y_side_markers(j));
            end
          
        end
    end % setXYDataIfChanged
    
    %-------------------------------
    function TF =  isBody(h_hit)
    
        TF = h_hit == h_patch;

    end %isBody
    
    %--------------------------
    function TF = isSide(h_hit)
    
        TF = any(h_hit == h_top_lines);
        
    end %isSide
        
    %----------------------------
    function TF = isCorner(h_hit)

        TF = any(h_hit == h_corner_markers);
        
    end %isCorner

    %--------------------------
    function TF = isWing(h_hit)

        TF = h_hit == h_wing_line;
        
    end %isWing
       
    %--------------------------------------------
    function side_index = findSelectedSide(h_hit)
        
        side_index = find(h_hit == h_top_lines);
        
    end
    
    %------------------------------------------------
	function vertex_index = findSelectedVertex(h_hit)
        
        vertex_index = find(h_hit == h_corner_markers);
        
    end
        
    %-----------------------------    
    function setupCursorManagement
        h_fig = iptancestor(h_axes,'figure');
        iptPointerManager(h_fig);
        
        iptSetPointerBehavior(h_patch,@(h_fig,current_point) set(h_fig,'Pointer','fleur'));
        
        % provide affordance to indicate that clicking on wing lines will
        % translate rectangle when rectangle is small
        iptSetPointerBehavior(h_wing_line,@(h_fig,current_point)...
            set(h_fig,'Pointer','fleur'));
        
        % Need listeners to react to changes in xdir/ydir of associated axes so that
        % pointer orientations always point in the left/right/up/down
        % directions as seen by the user.
        hax = handle(h_axes);
   
        makeAxesDirectionListener = ...
            @(hax,prop) handle.listener(hax,hax.findprop(prop),...
                                        'PropertyPostSet',@setupCornerPointerBehavior); 
        
        listeners(1)     = makeAxesDirectionListener(hax,'xdir');
        listeners(end+1) = makeAxesDirectionListener(hax,'ydir');
        
        setappdata(h_group,'CornerPointerListeners',listeners);
                        
        setupCornerPointerBehavior();
        setupSidePointerBehavior();
        
        %--------------------------------
        function setupSidePointerBehavior
            
        % left/right/up/down cursors are oriented correctly independent of xdir/ydir
        % of axes. Don't need to worry about these cases as with corner
        % pointers.
            cursor_names = {'left','top','right','bottom'};
            for j = 1:num_vert
                enterFcn = @(h_fig,currentPoint) set(h_fig,'Pointer',cursor_names{j});
                iptSetPointerBehavior(h_top_lines(j),enterFcn);
            end
                        
        end %setupSidePointerBehavior
        
        %----------------------------------
        function setupCornerPointerBehavior
            
             xFlipped = strcmp(get(h_axes,'xdir'),'reverse');
             yFlipped  = strcmp(get(h_axes,'ydir'),'reverse');
             
             if xFlipped && yFlipped
                 cursor_names = {'topr','botr','botl','topl'};
             elseif xFlipped
                 cursor_names = {'botr','topr','topl','botl'};
             elseif yFlipped
                 cursor_names = {'topl','botl','botr','topr'};
             else
                 cursor_names = {'botl','topl','topr','botr'};
             end
             
             for j = 1:num_vert
                 enterFcn = @(h_fig,currentPoint) set(h_fig,'Pointer',cursor_names{j});
                 iptSetPointerBehavior(h_corner_markers(j),enterFcn); 
             end
                
        end %setupCornerPointerBehavior
        
    end %setupCursorManagement
   
end %wingedRect