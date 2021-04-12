function formatFcn = getPixelRegionFormatFcn(imgmodel)
%getPixelRegionString Returns a function handle to format pixel value
%   formatFcn = getPixelRegionString(IMGMODEL) returns a function
%   handle. formatFcn has this signature:
%
%       STR = formatFcn(R,C)
%
%   where STR is a formatted string containing the pixel value at the location
%   row R and column C.
%
%   IMGMODEL is expected to contain one image model object.
%
%   Example
%   -------  
%       h = imshow('shadow.tif');
%       im = imagemodel(h);
%       getPixelString = getPixelRegionFormatFcn(im);
%       string = getPixelRegionString(5,4);
%
%   See also IMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:50 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
formatFcn = getDataFromImageTypeFormatter(imgmodel,'PixelRegionString');
