function figName = createFigureName(toolName,targetFigureHandle)
% CREATEFIGURENAME(TOOLNAME, TARGETFIGUREHANDLE) creates a name for the figure
% created by the tool, TOOLNAME.  The figure name, FIGNAME, will include
% TOOLNAME and the name of the figure on which the tool depends. TOOLNAME must
% be a string, and TARGETFIGUREHANDLE must be a valid handle to the figure on
% which TOOLNAME depends.
%
%   Example
%   -------
%       h = imshow('bag.png');
%       hFig = figure;
%       imhist(imread('bag.png'));
%       toolName = 'Histogram';
%       targetFigureHandle = ancestor(h,'Figure');
%       name = createFigureName(toolName,targetFigureHandle);
%       set(hFig,'Name',name);
%
%   See also IMAGEINFO, BASICIMAGEINFO, IMPIXELREGION.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/08/10 01:50:03 $
  
  
if ~ischar(toolName)
  eid = sprintf('Images:%s:invalidInput',mfilename);
  msg = 'TOOLNAME must be a string.';
  error(eid,'%s',msg);
end

if ishandle(targetFigureHandle) && ...
      strcmp(get(targetFigureHandle,'type'),'figure')

  targetFigureName = get(targetFigureHandle,'Name');
  
  if isempty(targetFigureName) && isequal(get(targetFigureHandle, ...
                                              'IntegerHandle'), 'on')
    targetFigureName = sprintf('Figure %d', double(targetFigureHandle));
  end

  if ~isempty(targetFigureName)
    figName = sprintf('%s (%s)', toolName, targetFigureName);
  else
    figName = toolName;
  end
  
else
  eid = sprintf('Images:%s:invalidFigureHandle',mfilename);
  msg = 'TARGETFIGUREHANDLE must be a valid figure handle.';
  error(eid,'%s',msg);
end

  
