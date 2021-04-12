function imagetype = getImageType(imgmodel)
%getImageType Image type associated with the imagemodel IMGMODEL.  
%   IMAGETYPE = getImageType(IMGMODEL) returns the image type associated with
%   the imagemodel IMGMODEL. IMAGETYPE can be 'intensity', 'truecolor',
%   'binary', or 'indexed'. IMGMODEL is expected to contain one imagemodel
%   object.
%
%   Example
%   -------
%       [X,map] = imread('trees.tif');
%       h = imshow(X,map);
%       im = imagemodel(h);  
%       imageType = getImageType(im)
%
%   See also IMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/08/10 01:49:44 $
  
imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
imagetype = findImageType(imgmodel.ImageHandle);


