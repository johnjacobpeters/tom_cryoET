function out = filterWorkspaceVars(ws_vars, filter)
%filterWorkspaceVars Filter workspace variables   
%   OUT = filterWorkspace(WS_VARS, FILTER) filters the structure WS_VARS
%   based on FILTER string and returns OUT.
%   WS_VARS contains workspace variables (e.g. WS_VARS = WHOS).  FILTER is a
%   string that can be any of the following values: 'colormap', 'rgb',
%   'indexed', 'intensity', 'binary', 'all'.  OUT is an array of indices into
%   WS_VARS of variables that match the filter specification.

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1.8.2 $  $Date: 2004/12/18 07:36:35 $
  
  valid_filters = {'colormap','rgb','indexed','intensity','binary','all'};
  
  if ~isstruct(ws_vars)
    eid = sprintf('Images:%s:invalidType',function_name);
    error(eid,'%s expected %s to be a workspace variable structure.',...
          mfilename, 'WS_VARS');
  end
    
  iptcheckstrs(filter,valid_filters,mfilename,'FILTER',2);
  
  num_of_vars = length(ws_vars);    
  
  default_classes = {'double', 'uint8', 'uint16', 'single'};
  
  out = [];
  
  switch lower(filter)
   case 'colormap'
    
    for n = 1:num_of_vars
      if isColormap(ws_vars(n))
        out = [out, n];
      end
    end
    
   case 'rgb'
    
    for n = 1:num_of_vars
      if isRGB(ws_vars(n)) 
        out = [out, n];
      end
    end
    
   case 'indexed'
    
    for n = 1:num_of_vars
      if isIndexed(ws_vars(n))
        out = [out,n];
      end
    end
    
   case 'intensity'

    for n = 1:num_of_vars
      if isIntensity(ws_vars(n))
        out = [out,n];
      end
    end

   case 'binary'
    
    for n = 1:num_of_vars
      if isBinary(ws_vars(n))
        out = [out,n];
      end
    end
    
   case 'all'
    
    for n = 1:num_of_vars
      if isRGB(ws_vars(n)) || isIntensity(ws_vars(n)) || isBinary(ws_vars(n))
        out = [out,n];
      end
    end
    
  end
  

  function true_or_false = isRGB(var_struct)
    
    is_M_by_N_by_3 = (length(var_struct.size) == 3 && var_struct.size(end) == 3);
    
    is_valid_type = any(strcmpi(var_struct.class,{default_classes{:}, 'int16'}),2);
    
    true_or_false = is_M_by_N_by_3 && is_valid_type;
    
  end
  
  function true_or_false = isColormap(var_struct)
    
    is_M_by_3 = (length(var_struct.size) == 2 && var_struct.size(end) == 3);
    
    is_double = strcmpi(var_struct.class,'double');
    
    true_or_false = is_M_by_3 && is_double;
    
  end

  function true_or_false = isIndexed(var_struct)
    
    is_M_by_N = length(var_struct.size) == 2;
    
    is_float = any(strcmpi(var_struct.class,{'double','single'}),2);
    
    if is_M_by_N && is_float
      
      data = evalin('base',sprintf('%s;',var_struct.name));
      is_integer_values = isequal(data,floor(data)) && all(isfinite(data(:)));
      is_all_non_zero = isempty(find(data == 0,1));
      
      true_or_false = is_integer_values && is_all_non_zero;
      
    else
      is_valid_type = any(strcmpi(var_struct.class,default_classes),2);

      true_or_false = is_M_by_N && is_valid_type;
    end
    
  end

  function true_or_false = isIntensity(var_struct)
    
    is_M_by_N = length(var_struct.size) == 2;
    
    is_valid_type  = any(strcmpi(var_struct.class,{default_classes{:} 'int16'}),2);
    
    true_or_false = is_M_by_N && is_valid_type;
    
  end
  

  function true_or_false = isBinary(var_struct)
    
    is_M_by_N = length(var_struct.size) == 2;
    
    is_logical  = strcmpi(var_struct.class,'logical');
    
    true_or_false = is_M_by_N && is_logical;
    
  end
  

end %filterWorkspaceVars

