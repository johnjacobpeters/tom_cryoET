function tf = isJavaFigure
%isJavaFigure True if figures are Java figures.  
%   TF = isJavaFigure returns true if Java is supported and false if Java is
%   not supported.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2006/10/14 12:23:04 $
  
if usejava('awt')
    tf = true;
else
    tf = false;
end

