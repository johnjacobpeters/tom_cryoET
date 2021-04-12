function height = getImageHeight(imgmodel)
%getImageHeight Image height associated with the imagemodel.  
%   HEIGHT = getImageHeight(IMGMODEL) returns the image height associated with the
%   imagemodel IMGMODEL.  IMGMODEL is expected to contain only one imagemodel
%   object.
%
%   Example
%   -------
%       h = imshow('moon.tif');
%       im = imagemodel(h);  
%       imageHeight = getImageHeight(im)
%
%   See also IMAGEMODEL,IMATTRIBUTES.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/08/10 01:49:43 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
height = size(get(imgmodel.ImageHandle,'CData'),1);
  
