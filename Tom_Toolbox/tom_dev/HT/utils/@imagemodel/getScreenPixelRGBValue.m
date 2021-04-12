function rgbValue = getScreenPixelRGBValue(imgmodel,r,c)
%getScreenPixelRGBValue RGB value of a pixel displayed on the screen.
%   RGBVALUE = getScreenPixelRGBValue(IMGMODEL,R,C) takes an imagemodel
%   IMGMODEL, row R, and column C as inputs and returns the RGB value of the
%   pixel at that location as displayed on the screen. IMGMODEL must contain
%   one imagemodel object.
%
%   Example
%   -------
%       This example demonstrates how the display range of an image in a
%       figure affects the RGB value of pixel when it is displayed on the
%       screen.
%  
%       I = imread('pout.tif');  
%       h = imshow(I);
%       im = imagemodel(h);  
%       getScreenPixelRGBValue(im,1,1)
%
%       figure
%       h2 = imshow(I,[]);
%       im2 = imagemodel(h2);
%       getScreenPixelRGBValue(im2,1,1)
%  
%   See also IMAGEMODEL,IMPIXELREGIONPANEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/12/18 07:36:34 $

if numel(imgmodel) > 1
  eid = sprintf('Images:%s:invalidNumImageModels',mfilename);
  msg = sprintf('%s requires one imagemodel object.',upper(mfilename));
  error(eid,'%s',msg);
end
  
h = imgmodel.ImageHandle;
imageType = findImageType(h);
img = get(h,'CData');

if ~isempty(img)
  switch imageType
    
   case 'truecolor'
    range = getrangefromclass(img);
    pixelValue = double(getPixelValue(imgmodel,r,c));   
    rgbValue = (pixelValue - range(1)) ./ ...
       (range(2) - range(1));
    rgbValue = min(1, max(0, rgbValue));
    
   case 'indexed'
    rgbValue = double(getPixelValue(imgmodel,r,c));   
    
   otherwise
    % intensity or binary image
    map = get(ancestor(h,'Figure'),'Colormap');
    numentry = size(map,1);
    range = get(ancestor(h,'Axes'),'Clim');
    
    % range(1) maps to index #1 into the colormap and range(2) maps to index
    % #numentry into the colormap.  The index into the colormap is scaled
    % using these factors.
    slope = (numentry - 1) / (range(2) - range(1));
    intercept = 1 - (slope * range(1));
    
    M = size(img, 1);
    N = size(img, 2);
    
    index = round(slope*double(img((c(:) - 1)*M + r(:))) + intercept);
    index = min(numentry,max(1,index));
    rgbValue = map(index,:);
  end
else
  rgbValue = get(ancestor(h,'Figure'),'Color');
end
