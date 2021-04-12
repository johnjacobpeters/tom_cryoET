function tools = navToolFactory(toolbar)
%navToolFactory Add navigational toolbar buttons to toolbar.
%   TOOLS = navToolFactory(TOOLBAR) returns TOOLS, a structure containing
%   handles to navigational tools. Tools for zoom in, zoom out, and pan are
%   added the TOOLBAR.
%
%   Note: navToolFactory does not set up callbacks for the tools.
%
%   Example
%   -------
%
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('tissue.png'); 
%       hSP = imscrollpanel(hFig,hIm);
% 
%       toolbar = uitoolbar(hFig);
%       tools = navToolFactory(toolbar)
%
%   See also UITOGGLETOOL, UITOOLBAR.

%   Copyright 2005-2006 The MathWorks, Inc.  
%   $Revision: 1.1.6.2 $  $Date: 2006/03/13 19:44:20 $

[iconRoot, iconRootMATLAB] = ipticondir;

% Common properties
s.toolConstructor            = @uitoggletool;
s.properties.Parent          = toolbar;

% zoom in
s.iconConstructor            = @makeToolbarIconFromGIF;
s.iconRoot                   = iconRootMATLAB;    
s.icon                       = 'view_zoom_in.gif';
s.properties.TooltipString   = 'Zoom in';
s.properties.Tag             = 'zoom in toolbar button';
tools.zoomInTool = makeToolbarItem(s);

% zoom out
s.iconConstructor            = @makeToolbarIconFromGIF;
s.iconRoot                   = iconRootMATLAB;    
s.icon                       = 'view_zoom_out.gif';
s.properties.TooltipString   = 'Zoom out';
s.properties.Tag             = 'zoom out toolbar button';
tools.zoomOutTool = makeToolbarItem(s);

% pan
s.iconConstructor            = @makeToolbarIconFromPNG;
s.iconRoot                   = iconRoot;    
s.icon                       = 'tool_hand.png';
s.properties.TooltipString   = 'Drag image to pan';
s.properties.Tag             = 'pan toolbar button';
tools.panTool = makeToolbarItem(s);

