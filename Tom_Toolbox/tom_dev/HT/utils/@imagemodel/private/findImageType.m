function imgtype = findImageType(hIm)
%   IMGTYPE = FINDIMAGETYPE(hIm) returns the image type of the CData in
%   the image object.
%   
%   See also IMAGEMODEL.
    
%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:55 $

iptcheckhandle(hIm,{'image'},mfilename,'HIM',1);

if ndims(get(hIm,'CData')) == 3
  imgtype = 'truecolor';  

else
  if strcmp(get(hIm,'CDataMapping'),'direct')
    imgtype = 'indexed';
  else
    % 'scaled'
    % intensity or binary image
    if islogical(get(hIm,'Cdata'))
      imgtype = 'binary';
    else
      imgtype = 'intensity';
    end
  end
end

