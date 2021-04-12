function value = getMaxIntensity(imgmodel)
%getMaxIntensity Maximum intensity of image associated with the imagemodel.
%   VALUE = getMaxintensity(IMGMODEL) returns the maximum intensity of the
%   image associated with the imagemodel IMGMODEL.  For an intensity or
%   indexed image, VALUE is the corresponding maximum value or index. For a
%   binary or truecolor image, VALUE is [].
%
%   IMGMODEL is expected to contain only one imagemodel object.
%
%   Example
%   -------
%       h = imshow('moon.tif');
%       im = imagemodel(h);  
%       maxIntensity = getMaxIntensity(im)
%
%   See also IMAGEMODEL,IMATTRIBUTES.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/08/10 01:49:46 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
imageType = findImageType(imgmodel.ImageHandle);

if strcmp(imageType,'intensity') || strcmp(imageType,'indexed')
  img = get(imgmodel.ImageHandle,'CData');
  value = max(img(:));
else
  value = [];
end

