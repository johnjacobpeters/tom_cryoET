function display_range = checkDisplayRange(display_range,fcnName)
%checkDisplayRange display range check function

%   Copyright 2006 The MathWorks, Inc.  
%   $Revision: 1.1.6.1 $  $Date: 2006/10/04 22:38:55 $

if isempty(display_range)
    return
end

iptcheckinput(display_range, {'numeric'},...
              {'real' 'nonsparse' 'vector','nonnan'}, ...
              fcnName, '[LOW HIGH]', 2);
          
if numel(display_range) ~= 2
    eid = sprintf('Images:%s:not2ElementVector', fcnName);
    error(eid,'[LOW HIGH] must be a 2-element vector.')
end

if display_range(2) <= display_range(1)
  eid = sprintf('Images:%s:badDisplayRangeValues', fcnName);
  error(eid,'HIGH must be greater than LOW.');
end

display_range = double(display_range);

