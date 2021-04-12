function DRAW_API = polygonSymbol
    
% Initialize all function scoped variables to empty
    [h_top_line,h_bottom_line,h_patch,...
     h_close_line_top,h_close_line_bottom,h_group,...
	 mode_invariant_obj,mode_variant_obj,all_obj,...
	 show_vertices, is_closed] = deal([]);
    
    DRAW_API.setColor               = @setColor;
    DRAW_API.initialize             = @initialize;
    DRAW_API.setVisible             = @setVisible;
    DRAW_API.setClosed              = @setClosed;
	DRAW_API.updateView             = @updateView;
	DRAW_API.showVertices           = @showVertices;
    
    function initialize(h)
       
		line_width = getPointsPerScreenPixel();
        h_group = h;
		show_vertices = true;
	
		% This is a workaround to an HG bug g349263.
		buttonDown = getappdata(h_group,'buttonDown');
       
		h_patch = patch('FaceColor', 'none',...
			'EdgeColor', 'none', ...
			'HitTest', 'on', ...
			'Parent', h_group,...
			'ButtonDown',buttonDown,...
			'Tag','patch',...
			'Visible','off');
		
        h_bottom_line = line('Color', 'w', ...
                             'LineStyle', '-', ...
                             'LineWidth', 3*line_width, ...
                             'HitTest', 'on', ...
							 'ButtonDown',buttonDown, ...
                             'Parent', h_group,...
                             'Tag','bottom line',...
                             'Visible','off');

        h_top_line = line('LineStyle', '-', ...
                          'LineWidth', line_width, ...
                          'HitTest', 'on', ...
                          'ButtonDown',buttonDown,...
                          'Parent', h_group,...
                          'Tag','top line',...
                          'Visible','off');
        
        h_close_line_bottom = line('Color', 'w', ...
                                   'LineStyle', '-', ...
                                   'LineWidth', 3*line_width, ...
                                   'HitTest', 'on', ...
								   'ButtonDown',buttonDown, ...
                                   'Parent', h_group,...
                                   'Tag','close line bottom',...
                                   'Visible','off');
        
        h_close_line_top = line('LineStyle', '-', ...
                          'LineWidth', line_width, ...
                          'HitTest', 'on', ...
                          'Parent', h_group,...
						  'ButtonDown',buttonDown,...
                          'Tag','close line top',...
                          'Visible','off');

        mode_invariant_obj = [h_top_line,h_bottom_line,h_patch];
				

	end
    
    %---------------------
    function setClosed(TF)
        
        is_closed = TF;
        drawModeAffordances();
        
    end
    
    %--------------------------------
    function showVertices(TF)
		
		show_vertices = TF;
        drawModeAffordances();
        
    end %setVerticesDraggable

   %----------------------
   function setVisible(TF)
       
	   mode_variant_obj = getVertices();
	   all_obj = [mode_invariant_obj,mode_variant_obj'];
       if TF
           set(mode_invariant_obj,'Visible','on');
           drawModeAffordances();
       else
           set(all_obj,'Visible','off');
       end
       
   end    

    %-------------------------------
	function vertices =  getVertices
		% This is the only way to find all impoints within h_group until
        % impoint is a real object.
		vertices = findobj(h_group,'tag','impoint');
	end

    %---------------------------
    function drawModeAffordances
   
		h_vertices = getVertices();
        if show_vertices
			set(h_vertices,'Visible','on');
		else
			set(h_vertices,'Visible','off');
        end
        
        h_close = [h_close_line_top,h_close_line_bottom,h_patch];
        if is_closed
            set(h_close,'Visible','on');
        else
            set(h_close,'Visible','off');
        end
    
    end %drawModeAffordances
    
    %---------------------------
    function updateView(new_pos)
        
        set([h_patch,h_top_line,h_bottom_line],...
            'XData',new_pos(:,1),...
            'YData',new_pos(:,2));
		
        close_line_x_data = [new_pos(end,1) new_pos(1,1)];
        close_line_y_data = [new_pos(end,2) new_pos(1,2)];
		
		set([h_close_line_top,h_close_line_bottom],...
			'XData',close_line_x_data,...
			'YData',close_line_y_data);
        
	end %updateView

	%-------------------
	function setColor(c)

			set([h_top_line,h_close_line_top], 'Color', c);
			
			h_vertices = getVertices();
			for i = 1:numel(h_vertices)
				vertex_api = iptgetapi(h_vertices(i));
				vertex_api.setColor(c);
			end
			
	end %setColor
          
end
    