function value = getPixelValue(imgmodel,r,c)
%getPixelValue Pixel value at a given location.
%   VALUE = getPixelValue(IMGMODEL,R,C) returns a pixel value at the
%   location row R, column C.  
%
%   IMGMODEL is expected to contain one image model object.
%
%   Example
%   -------  
%       h = imshow('shadow.tif');
%       im = imagemodel(h);
%       value = getPixelValue(im,5,4);
%
%   See also IMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:51 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
getValue = getDataFromImageTypeFormatter(imgmodel,'PixelValue');
value = getValue(r,c);
