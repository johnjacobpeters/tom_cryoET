function iptabout(varargin)
%IPTABOUT About the Image Processing Toolbox.
%   IPTABOUT displays the version number of the Image Processing
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2004/08/10 01:50:21 $ 

tlbx = ver('images');
tlbx = tlbx(1);
str = sprintf('%s %s\nCopyright 1993-%s The MathWorks, Inc.', ...
              tlbx.Name, tlbx.Version, datestr(tlbx.Date, 10));
s = load(fullfile(ipticondir, 'iptabout.mat'));
num_icons = numel(s.icons);
save_state = rand('state');
rand('state',sum(100*clock));
icon_idx = ceil(rand * num_icons);
rand('state',save_state);
msgbox(str,tlbx.Name,'custom',s.icons{icon_idx},gray(64),'modal');

