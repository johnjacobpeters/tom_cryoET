function outVal = checkInitialMagnification(in, valid_strings, function_name, ...
                                            variable_name, argument_position)
%checkInitialMagnification Check initial magnification value.
%   MAG_OUT = checkInitialMagnification(MAG_IN,VALID_STRINGS,FUNCTION_NAME,...
%   VARIABLE_NAME, ARGUMENT_POSITION) checks the validity of the
%   magnification value MAG_IN. MAG_IN can be one of the VALID_STRINGS or a
%   numeric scalar magnification. 
%
%   checkInitialMagnification returns the magnification value in MAG_OUT. If
%   MAG_IN is a string, checkInitialMagnification looks for a
%   case-insensitive nonambiguous match between MAG_IN and the strings in
%   VALID_STRINGS.
%
%   VALID_STRINGS is a cell array containing strings.
%
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision $  $Date: 2004/08/10 01:50:00 $

iptcheckinput(in, {'char','numeric'}, {}, function_name, variable_name, argument_position);

if ischar(in)
  outVal = iptcheckstrs(in, valid_strings, function_name,...
                        variable_name, argument_position);
  
elseif isscalar(in)
  iptcheckinput(in, {'numeric'}, ...
                {'real' 'nonsparse' 'finite' 'scalar' 'positive'}, ...
                function_name, variable_name, argument_position);
  outVal = in;
  
else
  eid = sprintf('Images:%s:invalidInitialMagnification',function_name);
  error(eid,'%s %s %s, ',...
        variable_name,'must be ',valid_strings{:},' or a scalar magnification.');
  
end
