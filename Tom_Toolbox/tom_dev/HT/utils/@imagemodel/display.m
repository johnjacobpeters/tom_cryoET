function display(imgmodel)
%DISPLAY Display method for imagemodel objects.
%   DISPLAY(IMGMODEL) prints the input variable name associated with IMGMODEL
%   (if any) to the command window and then calls DISP(IMGMODEL).
%   DISPLAY(IMGMODEL) also prints additional blank lines if the FormatSpacing
%   property is 'loose'.
%
%   See also IMAGEMODEL, IMAGEMODEL/DISP.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:38 $

if isequal(get(0,'FormatSpacing'),'compact')
    disp([inputname(1) ' =']);
    disp(imgmodel)
else
    disp(' ')
    disp([inputname(1) ' =']);
    disp(' ');
    disp(imgmodel)
    disp(' ');
end
