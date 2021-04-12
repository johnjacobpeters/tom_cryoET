function checkImageHandleArray(hImage,mfilename)
%checkImageHandleArray checks an array of image handles.
%   checkImageHandleArray(hImage,mfilename) validates that HIMAGE contains a
%   valid array of image handles. If HIMAGE is not a valid array,
%   then checkImageHandles issues an error for MFILENAME.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2004/08/10 01:49:59 $

if ~all(ishandle(hImage)) || ~all(strcmp(get(hImage,'type'),'image'))
    eid = sprintf('Images:%s:invalidImageHandle',mfilename);
    msg = 'HIMAGE must be an array containing valid image handles.';
    error(eid,'%s',msg);
end
