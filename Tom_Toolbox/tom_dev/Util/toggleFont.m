function toggleFont(fontSize)
%toggleFont sets to editor and desktop to given fontSize
% without arguments toggles between 14 and 35
%
%  toggleRes(fontSize)
%
%PARAMETERS
%
%  INPUT
%   fontSize  fontsize to be set
%
%
%EXAMPLE
%  
% %for 4k Monitor
%  toggleFont(30)
%
% %for 2k Monitor
%   toggleFont(15)
%
%REFERENCES
%
%
%SEE ALSO
%   ...
%
%NOTE:
%
% it only works if in Preferences==>MATLAB==>Fonts==>Custom  
%             for all DesktopTools the "Font to use" is "Desktop code"
%   
%
%   updated by FB 01/04/16 
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

if (nargin < 1)
     fObj=com.mathworks.services.FontPrefs.getTextFont;
     fontSizeIn=fObj.getSize;
     if (fontSizeIn>22)
          fontSize=14;
     else
          fontSize=35;
     end;
end;


if (fontSize<8)
    error('fontSize given is too small use 8 to 35');
end;

if (fontSize>40)
    error('fontSize given is too small use 8 to 40');
end;

if (fontSize<18)
    com.mathworks.services.FontPrefs.setCodeFont(java.awt.Font('SansSerif',java.awt.Font.PLAIN,fontSize));
    com.mathworks.services.FontPrefs.setTextFont(java.awt.Font('SansSerif',java.awt.Font.PLAIN,fontSize));
else
    com.mathworks.services.FontPrefs.setCodeFont(java.awt.Font('SansSerif',java.awt.Font.PLAIN,fontSize));
    com.mathworks.services.FontPrefs.setTextFont(java.awt.Font('SansSerif',java.awt.Font.PLAIN,fontSize));
end;

