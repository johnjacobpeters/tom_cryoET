function imageclass = getClassType(imgmodel)
%getClassType Class of image associated with the imagemodel.  
%   IMAGECLASS = getClassType(IMGMODEL) returns the class associated with the
%   imagemodel IMGMODEL.  IMAGECLASS is a string set to 'uint8', 'uint16',
%   'double', or 'logical'. IMGMODEL is expected to contain only one imagemodel
%   object.
%
%   Note
%   ----  
%   IMAGEMODEL works by querying the image object's CData.  For an single or
%   int16 image, the image object converts its CData to double. For example,
%   in the case of h = imshow(int16(ones(10))), class(get(h,'CData')) returns
%   'double'. Therefore, getClassType(imgmodel) returns 'double'.
%
%   Example
%   -------
%       h = imshow('moon.tif');
%       im = imagemodel(h);  
%       imageClass = getClassType(im)
%
%   See also IMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/03/31 16:32:00 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);

if isempty(imgmodel.ImageOrigClassType)
  imageclass = class(get(imgmodel.ImageHandle,'CData'));
else
  imageclass = imgmodel.ImageOrigClassType;
end
