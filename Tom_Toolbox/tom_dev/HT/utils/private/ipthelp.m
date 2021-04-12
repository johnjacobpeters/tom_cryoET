function ipthelp(topic, errorname)
% IPTHELP Help utility for interactive tools
% IPTHELP(TOPIC,ERRORNAME) displays help for TOPIC. If the map file cannot
% be found, an error dialog is displayed that refers to ERRORNAME.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2004/08/10 01:50:22 $

try
    helpview([docroot '/toolbox/images/images.map'],topic);
catch
    if ~isstudent
      message = sprintf('Unable to display help for %s\n', ...
                        errorname);
      errordlg(message)
    else
      errordlg({'Help for interactive tools in the Image Processing Toolbox',...
                'is not available in the Student Version.',...
                'See the Image Processing Toolbox documentation at:',...
                'www.mathworks.com'});
    end
    
end
