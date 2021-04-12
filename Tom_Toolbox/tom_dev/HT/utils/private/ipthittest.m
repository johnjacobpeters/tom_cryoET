function h = ipthittest(hFigure, currentPoint)
%ipthittest Handle of object currently under the mouse pointer.
%   handle = ipthittest(hFigure, currentPoint) returns the handle of the HG
%   object under the mouse pointer at a specific location.
%
%   See also iptGetPointerBehavior, iptPointerManager, iptSetPointerBehavior.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2.12.1 $  $Date: 2007/07/11 18:56:53 $

% Preconditions (not checked):
%     Two input arguments
%     First input argument is a valid HG figure handle
%     Second input argument is a valid figure CurrentPoint
%
%     Design note: It is a deliberate design choice for this routine not to
%     validate its input arguments.  ipthittest will be called for every
%     WindowButtonMotionEvent and needs to run as quickly as possible.

% Information hiding:
%     This routine hides knowledge of hittest bugs and their associated
%     work-arounds from the rest of the pointer management code.

% Initialize the table of functions that work around specific hittest
% problems.
workaroundTable = {@fixImScrollbars};

% Initalize output handle by calling the undocumented builtin hittest function.

h = hittest(hFigure, currentPoint);
if isempty(h)
    return;
end

% Invoke each function in the work-around table.
for k = 1:numel(workaroundTable)
    fcn = workaroundTable{k};
    h = fcn(h, hFigure, currentPoint);
end

%----------------------------------------------------------------------
function hnew = fixImScrollbars(h, hFigure, currentPoint)  %#ok - hFigure unused

hnew = h;

hPanel = getimscrollpanel(h);
isImageInsideScrollpanel = ~isempty(hPanel);

if ~isImageInsideScrollpanel
    return;
end

if ~isOverScrollbars(currentPoint(1), currentPoint(2), hPanel)
    return;
end

hSliders = findobj(hPanel, 'Type', 'uicontrol', ...
                   'Style', 'slider');

% For ipthittest purposes, it is necessary only to return one of the
% sliders; it is not necessary to take the extra step of determining which
% one.  If it should become necessary to return that information, then modify
% isOverScrollbars to return the information as an additional output
% argument, since isOverScrollbars is already doing that computation.

hnew = hSliders(1);
