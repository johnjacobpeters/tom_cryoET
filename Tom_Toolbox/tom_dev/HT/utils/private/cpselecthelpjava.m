function cpselecthelpjava
% CPSELECTTHELPJAVA Displays help for Control Point Selection Tool

%   Copyright 1993-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $

try
    helpview([docroot '/toolbox/images/images.map'],'cpselect_gui');
catch
    if ~isstudent
        errordlg(['Unable to display help for Control Point Selection Tool:' ...
                  sprintf('\n') lasterr ]);
    else
        errordlg({'Control Point Selection Tool Help is not available in the Student Version.',...
                  'See the Image Processing Toolbox documentation at:',...
                  'www.mathworks.com'});
    end
    
end
