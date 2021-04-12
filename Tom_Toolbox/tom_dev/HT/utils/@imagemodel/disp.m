function disp(imgmodel)
%DISP Display method for imagemodel objects.
%   DISP(IMGMODEL) prints a description of the imagemodel IMGMODEL to the
%   command window.
%
%   See also IMAGEMODEL, IMAGEMODEL/DISPLAY.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2005/11/15 01:02:48 $

if length(imgmodel) > 1
  s = size(imgmodel);
  str = sprintf('%dx',s);
  str(end)=[];
  fprintf('%s array of IMAGEMODEL objects\n',str);

else

  features = { 
      'ClassType',    getClassType(imgmodel);
      'DisplayRange', getDisplayRange(imgmodel);
      'ImageHeight',  getImageHeight(imgmodel);
      'ImageType',    getImageType(imgmodel);
      'ImageWidth',   getImageWidth(imgmodel);
      'MinIntensity', getMinIntensity(imgmodel);
      'MaxIntensity', getMaxIntensity(imgmodel);
             };
  
  if strcmp(getImageType(imgmodel),'indexed')
    features{6,1} = 'MinIndex';
    features{7,1} = 'MaxIndex';              
  end
  
  fprintf('IMAGEMODEL object accessing an image with these properties:\n\n',...
          imgmodel.ImageHandle);
  disp(cell2struct(features(:,2),features(:,1),1))
end
