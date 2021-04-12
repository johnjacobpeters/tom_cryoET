function removeListenerFcns = reactToImageChangesInFig(varargin)
%reactToImageChangesInFig sets up listeners to react to image changes.
%   reactToImageChangesInFig(HIMAGE,DELETE_FCN) calls DELETE_FCN if the
%   target image HIMAGE changes in its figure.  DELETE_FCN is a function
%   handle specified by the client that would cause the client or some part
%   of the client to delete itself. HIMAGE can be array of handles to
%   graphics image objects.
%
%   reactToImageChangesInFig(HIMAGE,DELETE_FCN,RECREATE_FCN) calls the
%   DELETE_FCN if the target image HIMAGE is deleted from the figure and
%   calls RECREATE_FCN if a new image is added to that figure.  For
%   example, if a user calls imshow twice on the same figure, the target
%   image HIMAGE is deleted and a new image is added. RECREATE_FCN is a
%   function handle specified by the client that would cause the client or
%   some part of the client to recreate itself.
%
%   reactToImageChangesInFig(...,LISTEN2CDATA) can optionally opt out of
%   listening the target images' CData property.  By default, listeners are
%   created to listen to image CData changes.  Setting LISTEN2CDATA to
%   false will opt out of listening to these changes.
%
%   removeListenerFcns = reactToImageChangesInFig(...) returns a function
%   handle that the client can use to remove all listeners created during 
%   a call to reactToImageChangesInFig.
%
%   Notes
%   -----
%   User has the responsibility to use valid function handles.
%   HIMAGE must be an array of image handles that are in the same figure.
%
%   See also IMPIXELINFO,IMPIXELINFOVAL.

%   Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/05/10 13:46:41 $

[hImage,deleteFcn,recreateFcn,listen2CData] = parseInputs(varargin{:});

% get image parent(s)
hImageParent = get(hImage,'Parent');

% get image figure; array of images must belong to the same figure.
hFig = ancestor(hImage,'Figure');
if iscell(hFig)
    if any(diff([hFig{:}]))
        eid = sprintf('Images:%s:invalidImageArray',mfilename);
        error(eid,'HIMAGE must belong to the same figure.');
    else
        hFig = hFig{1};
    end
end

% get handle to image parent
if iscell(hImageParent)
    parentHandle = handle([hImageParent{:}]);
else
    parentHandle = handle(hImageParent);
end

% setup listeners and cleanup functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fcnArray = {};

% the parent should listen for children being removed
childRemovedListener = handle.listener(parentHandle,...
    'ObjectChildRemoved',{@childRemoved,deleteFcn});
cleanListenerFcns = storeListener(hImage,childRemovedListener);
fcnArray = {fcnArray{:} cleanListenerFcns{:}};

% the image should listen for its own cdata changes
if listen2CData
    imageHandle = handle(hImage);
    cdataProperty = imageHandle(1).findprop('CData');
    imageCDataChangedListener = handle.listener(imageHandle,cdataProperty,...
        'PropertyPostSet', {@childCDataChanged,deleteFcn,recreateFcn});
    cleanListenerFcns = storeListener(hImage,imageCDataChangedListener);
    fcnArray = {fcnArray{:} cleanListenerFcns{:}};
end

% if new image is added, call recreate fcn
if ~isempty(recreateFcn)

    % listen for new axes added to the figure
    childAddedListener = handle.listener(hFig,'ObjectChildAdded',...
        @childAddedToFig);
    cleanListenerFcns = storeListener(hFig,childAddedListener);
    fcnArray = {fcnArray{:} cleanListenerFcns{:}};

    % listen for new image added to existing axes
    childAddedListener = handle.listener(parentHandle,'ObjectChildAdded',...
        @childAddedToAxes);
    cleanListenerFcns = storeListener(parentHandle,childAddedListener);
    fcnArray = {fcnArray{:} cleanListenerFcns{:}};

end

% create master cleanup function for child tool
removeListenerFcns = @() removeListeners(fcnArray);

% initialize 
cleanAx = {};
cleanGroup = {};
cleanIm = {};


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function childAddedToFig(obj,eventData) %#ok<INUSL>
        % This function is called if a child is added to hFig

        if isa(eventData.Child,'axes')
            hAxes = eventData.Child;
            childAddedListener = handle.listener(hAxes,'ObjectChildAdded', ...
                @childAddedToAxes);
            cleanAx = storeListener(hAxes,childAddedListener);
        end
    end % childAddedToFig


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function childAddedToAxes(obj,eventData) %#ok<INUSL>
        % This function is called if a child is added to hFig's axes

        if isa(eventData.Child,'image')
            setPropertyListenerOnImage(eventData);

        elseif isa(eventData.Child,'hggroup')
            hHGGroup = eventData.Child;
            childAddedListener = handle.listener(hHGGroup,'ObjectChildAdded', ...
                @childAddedToHGgroup);
            cleanGroup = storeListener(hHGGroup,childAddedListener);
        end
    end % childAddedToAxes


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function childAddedToHGgroup(obj,eventData) %#ok<INUSL>
        if isa(eventData.Child,'image')
            setPropertyListenerOnImage(eventData);
        end 
    end % childAddedToHGgroup
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setPropertyListenerOnImage(eventData)

        hIm = eventData.Child;
        prop = hIm.findprop('CData');
        cleanIm = storeListener(hIm, handle.listener(hIm, prop, ...
            'PropertyPostSet',@propDone));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function propDone(obj,eventData) %#ok<INUSD>

            % call recreate function
            recreateFcn();
            
            % delete the listeners that we just created to get us here
            removeListeners({cleanAx{:} cleanGroup{:} cleanIm{:}});
            
            % clear these cell arrays so they will start empty in 
            % subsequent events
            cleanAx = {};
            cleanGroup = {};
            cleanIm = {};

        end %propDone
        
    end %setPropertyListenerOnImage

end %main


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hIm,deleteFcn,recreateFcn,listen2CData] = parseInputs(varargin)

iptchecknargin(2,4,nargin,mfilename);

hIm = varargin{1};
checkImageHandleArray(hIm,mfilename);

deleteFcn = varargin{2};

% set default values
recreateFcn = [];
listen2CData = true;

% recreate function is optional
if nargin == 3
    if isa(varargin{3},'function_handle')
        recreateFcn = varargin{3};
    else
        listen2CData = varargin{3};
    end
end

if nargin == 4
    recreateFcn = varargin{3};
    listen2CData = varargin{4};
end

end % parseInputs


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeListenerFcns = storeListener(source,listener)
% this function stores the listeners in the appdata of the given object via
% the makelist function.  It returns a function handle that can be used to
% clean up all listeners that were stored during the function call.

% initialize an empty cell array
removeListenerFcns = {};
for k = 1 : numel(source)
    listenerList = getappdata(source(k),'imageChangeListeners');
    if isempty(listenerList)
        listenerList = makeList;
    end
    listenerID = listenerList.appendItem(listener);

    % append each delete function to the end of our array of delete fcns
    removeListenerFcns{end+1} = @() listenerList.removeItem(listenerID); %#ok<AGROW>

    setappdata(source(k),'imageChangeListeners',listenerList);
end

end % storeListener


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function childRemoved(obj,evt,deleteFcn) %#ok<INUSL>
% This function is called if a child object of an hImageParent is deleted.
% I.e. if you delete the image object or any sibling image object then the
% child tools are deleted.

if isa(evt.Child,'image')
    deleteFcn();
end

end % childRemoved


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function childCDataChanged(obj,evt,deleteFcn,recreateFcn) %#ok<INUSL>
% This function is called if the CData property of an image object is
% modified.

deleteFcn();
if ~isempty(recreateFcn)
    recreateFcn();
end

end % childCDataChanged


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeListeners(removeFcnArray)
% This function removes all listeners by calling each removal function in
% removeFcnArray

for i = 1:numel(removeFcnArray)
    removeFcn = removeFcnArray{i};
    if isa(removeFcn,'function_handle')
        removeFcn();
    end
end

end % removeListeners
