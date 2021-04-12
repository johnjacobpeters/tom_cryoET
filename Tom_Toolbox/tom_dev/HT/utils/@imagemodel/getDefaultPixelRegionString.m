function string = getDefaultPixelRegionString(imgmodel)
%getDefaultPixelRegionString Default string used in pixel region panel.
%   STRING = getDefaultPixelRegionString(IMGMODEL) returns the default string
%   used in IMPIXELREGIONPANEL.
%
%   IMGMODEL is expected to contain one image model object.
%
%   Example
%   -------  
%       h = imshow('shadow.tif');
%       im = imagemodel(h);
%       string = getDefaultPixelRegionString(im);
%
%   See also IMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:41 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
string = getDataFromImageTypeFormatter(imgmodel,'DefaultPixelRegionString');
