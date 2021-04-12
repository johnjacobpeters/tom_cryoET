function cp = controlPoint(x,y,hAxDetail,hAxOverview,constrainDrag)
%controlPoint 

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/06/04 21:11:10 $
  
  hDetailPoint   = makeCustomImpoint(hAxDetail);
  hOverviewPoint = makeCustomImpoint(hAxOverview);       

  cp.hDetailPoint     = hDetailPoint;
  cp.hOverviewPoint   = hOverviewPoint;
  cp.setPairId        = @setPairId;
  cp.setActive        = @setActive;
  cp.setPredicted     = @setPredicted;  
  cp.addButtonDownFcn = @addButtonDownFcn;
  
  wireSisterPoint(iptgetapi(hDetailPoint),iptgetapi(hOverviewPoint))
  wireSisterPoint(iptgetapi(hOverviewPoint),iptgetapi(hDetailPoint))   

  %---------------------------------------------------- 
  function wireSisterPoint(movingAPI,sisterAPI)
  % Tell point to move its sister if it moves 
   
   updateSisterPoint = @(pos) sisterAPI.setPosition(pos);
   movingAPI.addNewPositionCallback(updateSisterPoint);
   
  end

  %------------------------------------------------------------------------
  function [detailPointAPI,overviewPointAPI] = getDetailAndOverviewPointAPI
     % This function is provided to avoid the point APIs being declared in the top
     % function workspace. Limiting the workspace of the point APIs yields improved
     % delete performance, especially for larger numbers of control points.
     detailPointAPI = iptgetapi(hDetailPoint);
     overviewPointAPI = iptgetapi(hOverviewPoint);
      
  end    
 
  %---------------------
  function setPairId(id)
      
    [detailPointAPI,overviewPointAPI] = getDetailAndOverviewPointAPI();  
    
    detailPointAPI.setPairId(id)
    overviewPointAPI.setPairId(id)   

  end

  %---------------------------
  function setActive(isActive)

    [detailPointAPI,overviewPointAPI] = getDetailAndOverviewPointAPI();  
      
    % approach to use for "active as adjective" of point    
    detailPointAPI.setActive(isActive)
    overviewPointAPI.setActive(isActive)   
    
  end

  %---------------------------------
  function setPredicted(isPredicted)
      
    [detailPointAPI,overviewPointAPI] = getDetailAndOverviewPointAPI();  

    detailPointAPI.setPredicted(isPredicted)
    overviewPointAPI.setPredicted(isPredicted)  
    
  end
  
  %-----------------------------
  function addButtonDownFcn(fun)

    iptaddcallback(hDetailPoint,'ButtonDownFcn',fun);
    iptaddcallback(hOverviewPoint,'ButtonDownFcn',fun);

  end
  
  %----------------------------------------------------------
  function hPoint = makeCustomImpoint(hAx)

    % scope within makeCustomImpoint
    pairId = []; 
  
    hPoint = impoint(hAx,x,y,'DrawAPI',cpPointSymbol);
  
    pointAPI = iptgetapi(hPoint);
        
    pointAPI.setPositionConstraintFcn(constrainDrag);
    pointAPI.setColor('c');

    enterFcn = @(f,cp) set(f, 'Pointer', 'fleur');
    iptSetPointerBehavior(hPoint, enterFcn);
  
    % add custom fields to api, and cache in appdata
    pointAPI.setPairId    = @setPairId;
    pointAPI.getPairId    = @getPairId;    
    pointAPI.setActive    = @setActive;        
    pointAPI.setPredicted = @setPredicted;    
    iptsetapi(hPoint,pointAPI)
    
      %---------------------
      function setPairId(id)
        pairId = id;
        idString = mat2str(id);
        pointAPI.setString(idString);

      end

      %----------------------
      function id = getPairId
        id = pairId;
      end

      %---------------------------
      function setActive(isActive)
        
        drawAPI = pointAPI.getDrawAPI();
        drawAPI.showActiveDecoration(isActive);
        
      end

      %------------------------------
      function setPredicted(isPredicted)
        
        drawAPI = pointAPI.getDrawAPI();
        drawAPI.showPredictedDecoration(isPredicted);
        
      end
      
  end

end