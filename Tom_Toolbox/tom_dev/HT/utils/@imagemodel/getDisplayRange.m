function range = getDisplayRange(imgmodel)
%getDisplayRange Display range of image associated with imagemodel.
%   RANGE = getDisplayRange(IMGMODEL) returns the display range of the
%   image object associated with the imagemodel.  The display range is
%   empty if image object does not contain an intensity image.
%
%   Example
%   -------
%       I = imread('pout.tif');
%       h = imshow(I,[])
%       im = imagemodel(h);  
%       displayrange = getDisplayRange(im)
%  
%   See also IMAGEMODEL,IMDISPLAYRANGEPANEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:42 $
  
imgmodel = checkForMultipleImageModels(imgmodel,mfilename);

if strcmp(findImageType(imgmodel.ImageHandle),'intensity')
  range = get(ancestor(imgmodel.ImageHandle,'Axes'),'Clim');
else
  range = [];
end

