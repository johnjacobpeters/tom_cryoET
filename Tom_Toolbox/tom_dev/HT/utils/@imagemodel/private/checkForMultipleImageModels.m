function oneIM = checkForMultipleImageModels(imgmodel,filename)
%checkForMultipleImageModels Check if input contains multiple imagemodels.
%   IM = checkForMultipleImageModels(IMGMODEL, FILENAME) checks if the
%   input IMGMODEL to the function FILENAME contains more than one
%   imagemodel. IF IMGMODEL contains multiple imagemodel objects, then
%   checkForMultipleImageModels returns the first element in IMGMODEL array
%   and issues a warning.
%
%   See also IMAGEMODEL.
  
%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:49:54 $

if numel(imgmodel) > 1
  wid = sprintf('Images:%s:ignoreMultipleImageModels',filename);
  msg = sprintf('%s expects one imagemodel object. Using the ', ...
               upper(filename));
  msg2 = 'first element of the imagemodel array.';
  warning(wid,'%s%s',msg,msg2);
end
  
oneIM = imgmodel(1);
               
