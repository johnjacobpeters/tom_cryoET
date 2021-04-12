function overMe = findLowestManagedObject(hFigure,currentPoint)
%FINDLOWESTMANAGEDOBJECT Find lowest object in the hg hierarchy with a pointer behavior.
%   OVERME = findLowestManagedObject(HFIGURE,CURRENTPOINT) returns the lowest
%   object in the HG hierarchy of hFigure that contains a pointer
%   behavior. The search for a managed object begins at the position specified
%   by currentPoint.
%      
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/02/11 05:46:41 $   
    
    % Begin search for an object with a pointerBehavior directly underneath the
    % mouse pointer. If this object returned by hittest does not have a
    % pointerBehavior, climb the HG tree of ancestors until either an object
    % with a pointerBehavior is found or the root object is reached.
    root = 0;
    hit_test_obj = ipthittest(hFigure,currentPoint);
    overMe.Handle = hit_test_obj;
    overMe.PointerBehavior = [];
    
    while overMe.Handle ~= root
       overMe.PointerBehavior = iptGetPointerBehavior(overMe.Handle);
       if ~isempty(overMe.PointerBehavior)
           break;
       end
       overMe.Handle = get(overMe.Handle,'Parent'); 
    end   

    % If no pointer behavior was found in the ancestor tree, return empty Handle
    % and PointerBehavior.
    if isempty(overMe.PointerBehavior)
        overMe.PointerBehavior = [];
        overMe.Handle = [];
    end
         