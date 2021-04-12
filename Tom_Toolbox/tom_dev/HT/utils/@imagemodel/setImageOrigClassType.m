function imgmodel = setImageOrigClassType(imgmodel,classType)
%setImageOrigClassType set class of image in the imagemodel.
%   setImageOrigClassType(IMGMODEL,classType) sets the class of the image
%   associated with the imagemodel. This function is useful in GUIs that open
%   images whose class is not supported by IMAGE, e.g., int16 and
%   single. However, be careful when using this function as it does break the
%   dynamic nature of the imagemodel object.
%
%   See also IMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/03/31 16:33:09 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);

%check if this imagemodel is also stored in the image object's appdata.
appdataImgmodel = getappdata(imgmodel.ImageHandle,'imagemodel');

if isequal(imgmodel,appdataImgmodel)
  
  imgmodel.ImageOrigClassType = classType;
  setappdata(imgmodel.ImageHandle,'imagemodel',imgmodel);

else
  imgmodel.ImageOrigClassType = classType; 
end
