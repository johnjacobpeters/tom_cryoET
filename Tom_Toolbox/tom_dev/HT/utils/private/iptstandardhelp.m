function iptstandardhelp(helpmenu)
%iptstandardhelp Add Toolbox, Demos, and About to help menu.
%   iptstandardhelp(HELPMENU) adds Image Processing Toolbox Help,
%   Demos, and About Image Processing Toolbox to HELPMENU, which is a
%   uimenu object.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:50:23 $


toolboxItem = uimenu(helpmenu, 'Label', 'Image Processing &Toolbox Help', ...
                     'Callback', @(varargin) doc('images/'));
demosItem = uimenu(helpmenu, 'Label', 'Image Processing Toolbox &Demos', ...
                   'Callback', @(varargin) demo('toolbox','image processing'), ...
                   'Separator', 'on');
aboutItem = uimenu(helpmenu, 'Label', 'About Image Processing Toolbox', ...
                   'Callback', @iptabout, ...
                   'Separator', 'on');
