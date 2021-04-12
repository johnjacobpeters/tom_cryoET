function [img,map] = getImageFromFile(filename,fcnName)
%getImageFromFile retrieves image from file

%   Copyright 2006 The MathWorks, Inc.  
%   $Revision: 1.1.6.1 $  $Date: 2006/11/08 17:49:32 $

if ~ischar(filename)
    eid = sprintf('Images:%s:invalidType', fcnName);
    error(eid, 'The specified filename is not a string.');
end

if ~exist(filename, 'file')
  eid = sprintf('Images:%s:fileDoesNotExist', fcnName);
  error(eid, 'Cannot find the specified file: "%s"', filename);
end

wid = sprintf('Images:%s:multiframeFile', fcnName);

try
  [img,map] = imread(filename);
  info = imfinfo(filename);
  if numel(info) > 1
      warning(wid,'Can only display one frame from this multiframe file: %s.', filename);
  end
  
catch
    try
        info = dicominfo(filename);
        if isfield(info,'NumberOfFrames')
            [img,map] = dicomread(info,'Frames',1);
            warning(wid,'Can only display one frame from this multiframe file: %s.',filename);
        else
            [img,map] = dicomread(info);
        end
        
    catch
        eid = sprintf('Images:%s:couldNotReadFile', fcnName); 
        error(eid,'Could not read this file: "%s"', filename);
    end
end    

