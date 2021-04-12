function api = basicPolygon(h_group,draw_api,positionConstraintFcn)
%basicPolygon creates the common API shared by imfreehand and impoly.
%   API = basicPolygon(H_GROUP,DRAW_API) creates a base API for use in
%   defining a draggable polygon. H_GROUP specifies the hggroup that
%   contains the polygon or freehand ROI. DRAW_API is the draw_api used by
%   an ROI. basicPolygon returns an API. positionConstraintFcn is a function
%   handle used to constrain the position of an ROI.
    
%   Copyright 2007 The MathWorks, Inc.    
     
  h_fig = iptancestor(h_group,'figure');
  h_axes = iptancestor(h_group,'axes');
  
  position = [];
      
  dispatchAPI = roiCallbackDispatcher(@getPosition);
    
  % This is a workaround to HG bug g349263. There are problems with the figure
  % selection mode when both the hggroup and its children have a
  % buttonDownFcn. Need the hittest property of the hgobjects defined in
  % wingedRect to be on to determine what type of drag action to take.  When
  % the hittest of hggroup children is on, the buttonDownFcn of the hggroup
  % doesnt fire. Instead, pass buttonDownFcn to children inside the appdata of
  % the hggroup.
  setappdata(h_group,'buttonDown',@startDrag);
  
  draw_api.initialize(h_group);
  
  % In the other ROI tools, the initial color is defined in
  % createROIContextMenu. It is necessary to create the context menu after
  % interactive placement for impoly/imfreehand, so we need to initialize color here.
  color_choices = getColorChoices;
  draw_api.setColor(color_choices(1).Color);
      
  draw_api.setVisible(true);
  
  % Alias updateView.
  updateView = draw_api.updateView;
  
  api.startDrag                 = @startDrag;
  api.addNewPositionCallback    = dispatchAPI.addNewPositionCallback;
  api.removeNewPositionCallback = dispatchAPI.removeNewPositionCallback;
  api.setPosition               = @setPosition;
  api.setConstrainedPosition    = @setConstrainedPosition;
  api.getPosition               = @getPosition;
  api.delete                    = @deletePolygon;
  api.getPositionConstraintFcn  = @getPositionConstraintFcn;
  api.setPositionConstraintFcn  = @setPositionConstraintFcn;
  api.setPolygonPointerBehavior = @setPolygonPointerBehavior;
  api.updateView                = draw_api.updateView;
  api.setVisible                = draw_api.setVisible;
  api.setClosed                 = draw_api.setClosed;
  
  %-------------------------------
  function deletePolygon(varargin)
     
      delete(h_group);
      
  end %deletePolygon
       
  %-------------------------
  function pos = getPosition
    
      pos = position;    
    
  end %getPosition

  %------------------------
  function setPosition(pos)
     
      position = pos;
      updateView(pos);
      dispatchAPI.dispatchCallbacks('newPosition');
      
  end %setPosition
  
  %-----------------------------------
  function setConstrainedPosition(pos)
     
      pos = positionConstraintFcn(pos);
      setPosition(pos);
      
  end %setConstrainedPosition
  
  %---------------------------------
  function setPositionConstraintFcn(fun)
  
      positionConstraintFcn = fun;
    
  end %setPositionConstraintFcn
    
  %---------------------------------
  function fh = getPositionConstraintFcn
      
      fh = positionConstraintFcn;
  
  end %getPositionConstraintFcn
  
  %---------------------------
  function startDrag(varargin) %#ok varargin needed by HG caller
  
    mouse_selection = get(h_fig,'SelectionType');
    is_normal_click = strcmp(mouse_selection,'normal');
    
    is_modifier_key_pressed = ~isempty(get(h_fig,'CurrentModifier'));
    is_shift_click = strcmp(mouse_selection,'extend') &&...
                     is_modifier_key_pressed;   
    
    if ~(is_normal_click || is_shift_click)
        return
    end
  
    start_position = getPosition();
    num_vert = size(start_position,1);
    
    [start_x,start_y] = getCurrentPoint(h_axes);
    
    % Workaround to HG bug g371764. Remove patch_hitarea_workaround once bug
    % fixed. Clicking anywhere within the bounding rectangle of a patch
    % causes its buttonDownFcn to fire. We only want the buttonDown fire
    % within the polygon defined by the patch.
    inside_polygon = inpolygon(start_x,start_y,...
    	                       start_position(:,1),start_position(:,2));
      
    h_hit = hittest(h_fig);
    patch_hitarea_workaround = strcmp(get(h_hit,'type'),'patch') && ~inside_polygon;
    
    if patch_hitarea_workaround
    	return;
    end
    	 
    % Disable the figure's pointer manager during the drag.
    iptPointerManager(h_fig, 'disable');
  
    drag_motion_callback_id = iptaddcallback(h_fig, ...
                                             'WindowButtonMotionFcn', ...
                                             @dragMotion);
    
    drag_up_callback_id = iptaddcallback(h_fig, ...
                                             'WindowButtonUpFcn', ...
                                             @stopDrag);
    									 	 
      %----------------------------
      function dragMotion(varargin) %#ok varargin needed by HG caller
        
          if ~ishandle(h_axes)
              return;
          end
        
          [new_x,new_y] = getCurrentPoint(h_axes);      
          delta_x = new_x - start_x;
          delta_y = new_y - start_y;
          
          candidate_position = start_position + repmat([delta_x delta_y],num_vert,1);
          new_position = positionConstraintFcn(candidate_position);
      
          setPosition(new_position)
      
      end
      
      %--------------------------
      function stopDrag(varargin) %#ok varargin needed by HG caller
            
            dragMotion();
            
            iptremovecallback(h_fig, 'WindowButtonMotionFcn', ...
                              drag_motion_callback_id);
            iptremovecallback(h_fig, 'WindowButtonUpFcn', ...
                              drag_up_callback_id);
            
            % Enable the figure's pointer manager.
            iptPointerManager(h_fig, 'enable');
        
      end % stopDrag
      	
  end %startDrag

  %---------------------------------
  function setPolygonPointerBehavior
          
  	h_lines = findobj(h_group,'type','line');
  	for i = 1:length(h_lines)
  		iptSetPointerBehavior(h_lines(i),@lineEnterFcn);
  	end
  	
  	% HG hittest returns patch if you are inside the bounding rectangle
  	% inclosing a patch. Have to use traverse function to determine if
  	% mouse is really inside patch polygon.
  	h_patch = findobj(h_group,'type','patch');
  	patchBehavior.enterFcn = [];
  	patchBehavior.exitFcn = [];
  	patchBehavior.traverseFcn = @patchTraverseFcn;
      
  	iptSetPointerBehavior(h_patch, patchBehavior);
  			       
      %------------------------------------
      function lineEnterFcn(h_fig,varargin)
  			set(h_fig,'Pointer','fleur');
  	end %lineEnterFcn
  	
  	%----------------------------------------
  	function patchTraverseFcn(h_fig,varargin)
  		pos = getPosition();
  		[current_x,current_y] = getCurrentPoint(h_axes);
  		if inpolygon(current_x,current_y,pos(:,1),pos(:,2))
  			set(h_fig,'Pointer','fleur');
  		else
  			set(h_fig,'Pointer','arrow');
  		end
  
  	end %patchTraverseFcn
  		  
  end %setPolygonPointerBehavior
    
end % basicPolygon

