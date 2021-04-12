function width = getImageWidth(imgmodel)
%getImageWidth Image width associated with the imagemodel.  
%   WIDTH = getImageWidth(IMGMODEL) returns the image width associated with the
%   imagemodel IMGMODEL.  IMGMODEL is expected to contain only one imagemodel
%   object.
%
%   Example
%   -------
%       h = imshow('moon.tif');
%       im = imagemodel(h);  
%       imageWidth = getImageWidth(im)
%
%   See also IMAGEMODEL,IMATTRIBUTES.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/08/10 01:49:45 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
width    = size(get(imgmodel.ImageHandle,'CData'),2);

  
