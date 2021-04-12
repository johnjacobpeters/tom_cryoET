function string = getDefaultPixelInfoString(imgmodel)
%getDefaultPixelInfoString Default string used in pixel information tool.
%   STRING = getDefaultPixelInfoString(IMGMODEL) returns the default string
%   used in IMPIXELINFOVAL.
%
%   IMGMODEL is expected to contain one image model object.
%
%   Example
%   -------  
%       h = imshow('shadow.tif');
%       im = imagemodel(h);
%       string = getDefaultPixelInfoString(im);
%
%   See also IMAGEMODEL, IMPIXELINFOVAL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:40 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
string = getDataFromImageTypeFormatter(imgmodel,'DefaultPixelInfoString');
