function string = getPixelInfoString(imgmodel,r,c)
%getPixelInfoString Formatted pixel value string.
%   STRING = getPixelInfoString(IMGMODEL,R,C) returns a formatted
%   string containing the image pixel value at the location R,C.
%
%   IMGMODEL is expected to contain one image model object.
%
%   Example
%   -------  
%       h = imshow('shadow.tif');
%       im = imagemodel(h);
%       string = getPixelInfoString(im,5,4);
%
%   See also IMAGEMODEL,IMPIXELINFOVAL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:49 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
getString = getDataFromImageTypeFormatter(imgmodel,'PixelInfoString');
string = getString(r,c);
