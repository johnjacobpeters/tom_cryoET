function [common_args,specific_args] = imageDisplayParseInputs(varargin)
%imageDisplayParseInputs Parse inputs for image display functions.
%   [common_args,specific_args] =
%   imageDisplayParseInputs(specificNames,varargin) parse inputs for image display
%   functions including properties specified in property value pairs. Client-specific
%   arguments specified in specificNames are returned in specific_args.
%
%   common_args is a structure containing arguments that are shared by imtool and imshow.
%
%   specific_args is a structure containing arguments that are specific to a
%   particular client. Arguments specified in specific_args will be returned
%   as fields of specific_args if they are given as p/v pairs by clients.
%
%   Valid syntaxes:
%   DISPLAY_FUNCTION refers to any image display function that uses this utility
%   for input parsing.
%   DISPLAY_FUNCTION - no arguments
%   DISPLAY_FUNCTION(I)
%   DISPLAY_FUNCTION(I,[LOW HIGH])
%   DISPLAY_FUNCTION(RGB)
%   DISPLAY_FUNCTION(BW)
%   DISPLAY_FUNCTION(X,MAP)
%   DISPLAY_FUNCTION(FILENAME)
%
%   DISPLAY_FUNCTION(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   Parameters include:
%      'DisplayRange', RANGE
%      'InitialMagnification', INITIAL_MAG
%      'XData',X
%      'YData',Y

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2007/06/04 21:11:15 $

% I/O Spec
%   I            2-D, real, full matrix of class:
%                uint8, uint16, int16, single, or double.
%
%   BW           2-D, real full matrix of class logical.
%
%   RGB          M-by-N-by-3 3-D real, full array of class:
%                uint8, uint16, int16, single, or double.
%
%   X            2-D, real, full matrix of class:
%                uint8, uint16, double
%                if isa(X,'uint8') || isa(X,'uint16'): X <= size(MAP,1)-1
%                if isa(X,'double'): 1 <= X <= size(MAP,1)
%
%   MAP          2-D, real, full matrix
%                if isa(X,'uint8'): size(MAP,1) <= 256
%                if isa(X,'uint16') || isa(X,'double'): size(MAP,1) <= 65536
%
%   RANGE        2 element vector or empty array, double
%
%   FILENAME     String of a valid filename that is on the path.
%                File must be readable by IMREAD or DICOMREAD.
%
%   INITIAL_MAG  'adaptive', 'fit'
%                numeric scalar
%
%   X,Y          2-element vector, can be more than 2 elements but only
%                first and last are used.
%
%   STYLE        'docked', 'normal'
%
%   H            image object (possibly subclass of HG image object with
%                access to more navigational API)


specific_arg_names = varargin{1};
varargin = varargin(2:end);

% Initialize common_args to default values.
common_args = struct('Filename','',...
    'CData', [],...
    'CDataMapping','',...
    'DisplayRange',[],...
    'Map',[],...
    'XData',[],...
    'YData',[],...
    'InitialMagnification',[]);

specific_args = struct([]);

num_args = length(varargin);
params_to_parse = false;

eid_invalid =  sprintf('Images:%s:invalidInputs',mfilename);
msg_invalid = 'Invalid input arguments.';

% See if there are parameter-value pairs
% DISPLAY_FUNCTION(...,'DisplayRange',...
%                   'InitialMagnification', INITIAL_MAG,...
%                   'XData', x, ...
%                   'YData', y,...)
string_indices = find(cellfun('isclass',varargin,'char'));
valid_params = {'DisplayRange','InitialMagnification',...
    'XData','YData'};
valid_params = [valid_params,specific_arg_names];

if ~isempty(string_indices) && num_args > 1
    params_to_parse = true;

    is_first_string_first_arg = (string_indices(1)==1);

    nargs_after_first_string = num_args - string_indices(1);
    even_nargs_after_first_string = ~mod(nargs_after_first_string,2);

    if is_first_string_first_arg && even_nargs_after_first_string
        % DISPLAY_FUNCTION(FILENAME,PARAM,VALUE,...)
        param1_index = string_indices(2);
    else
        % DISPLAY_FUNCTION(PARAM,VALUE,...)
        % DISPLAY_FUNCTION(...,PARAM,VALUE,...)
        param1_index = string_indices(1);

        % Make sure first string is a real parameter, if not
        % error here with generic message because user could
        % be trying DISPLAY_FUNCTION(FILENAME,[]).
        matches = strncmpi(varargin{param1_index},valid_params,...
            length(varargin{param1_index}));
        if ~any(matches) %i.e. none
            error(eid_invalid, msg_invalid);
        end
    end
end

if params_to_parse
    num_pre_param_args = param1_index-1;
    num_args = num_pre_param_args;
end

iptchecknargin(0,2,num_args,mfilename);

switch num_args
    case 1
        % DISPLAY_FUNCTION(FILENAME)
        % DISPLAY_FUNCTION(I)
        % DISPLAY_FUNCTION(RGB)

        if (ischar(varargin{1}))
            % DISPLAY_FUNCTION(FILENAME)
            common_args.Filename = varargin{1};
            [common_args.CData,common_args.Map] = ...
                getImageFromFile(common_args.Filename, mfilename);
        else
            % DISPLAY_FUNCTION(I)
            % DISPLAY_FUNCTION(RGB)
            common_args.CData = varargin{1};
        end

    case 2
        % DISPLAY_FUNCTION(I,[])
        % DISPLAY_FUNCTION(I,[a b])
        % DISPLAY_FUNCTION(X,map)

        common_args.CData = varargin{1};

        if (isempty(varargin{2}))
            % DISPLAY_FUNCTION(I,[])
            common_args.DisplayRange = getAutoCLim(common_args.CData);

        elseif isequal(numel(varargin{2}),2)
            % DISPLAY_FUNCTION(I,[a b])
            common_args.DisplayRange = checkDisplayRange(varargin{2},...
                mfilename);

        elseif (size(varargin{2},2) == 3)
            % DISPLAY_FUNCTION(X,map)
            common_args.Map = varargin{2};

        else
            error(eid_invalid, msg_invalid);

        end

end

% Make sure CData is numeric before going any further.
iptcheckinput(common_args.CData, {'numeric','logical'},...
    {'nonsparse'}, ...
    mfilename, 'I', 1);

if params_to_parse
    [common_args,specific_args] = parseParamValuePairs(varargin(param1_index:end),valid_params,...
                                                      specific_arg_names,...
                                                      num_pre_param_args,...
                                                      mfilename,...
                                                      common_args,...
                                                      specific_args);
end

if isempty(common_args.XData)
    common_args.XData = [1 size(common_args.CData,2)];
end

if isempty(common_args.YData)
    common_args.YData = [1 size(common_args.CData,1)];
end

image_type = findImageType(common_args.CData,common_args.Map);
common_args.CData = validateCData(common_args.CData,image_type);

common_args.CDataMapping = getCDataMapping(image_type);

if strcmp(common_args.CDataMapping,'scaled')
    common_args.Map = gray(256);

    if isempty(common_args.DisplayRange) || ...
            (common_args.DisplayRange(1) == common_args.DisplayRange(2))
        common_args.DisplayRange = getrangefromclass(common_args.CData);
    end
end

common_args.DisplayRange = checkDisplayRange(common_args.DisplayRange,mfilename);
        
%----------------------------------------------------
function [cdatamapping] = getCDataMapping(image_type)

cdatamapping = 'direct';

% cdatamapping is not relevant for RGB images, but we set it to something so
% we can call IMAGE with one set of arguments no matter what image type.

% May want to treat binary images as 'direct'-indexed images for display
% in HG which requires no map.
%
% For now, they are treated as 'scaled'-indexed images for display in HG.

switch image_type
    case {'intensity','binary'}
        cdatamapping = 'scaled';

    case 'indexed'
        cdatamapping = 'direct';

end

%---------------------------------
function clim = getAutoCLim(cdata)

clim = double([min(cdata(:)) max(cdata(:))]);

%-----------------------------------------------
function cdata = validateCData(cdata,image_type)

if ((ndims(cdata) > 3) || ((size(cdata,3) ~= 1) && (size(cdata,3) ~= 3)))
    eid = sprintf('Images:%s:unsupportedDimension',mfilename);
    error(eid, '%s', 'Unsupported dimension')
end

if islogical(cdata) && (ndims(cdata) > 2)
    eid = sprintf('Images:%s:expected2D',mfilename);
    error(eid, '%s', 'If input is logical (binary), it must be two-dimensional.');
end

% RGB images can be only be uint8, uint16, single, or double
if ( (ndims(cdata) == 3)   && ...
        ~isa(cdata, 'double') && ...
        ~isa(cdata, 'uint8')  && ...
        ~isa(cdata, 'uint16') && ...
        ~isa(cdata, 'single') )
    eid = sprintf('Images:%s:invalidRGBClass',mfilename);
    msg = 'RGB images must be uint8, uint16, single, or double.';
    error(eid,'%s',msg);
end

if strcmp(image_type,'indexed') && isa(cdata,'int16')
    eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
    msg1 = 'An indexed image can be uint8, uint16, double, single, or ';
    msg2 = 'logical.';
    error(eid,'%s %s',msg1, msg2);
end

% Clip double and single RGB images to [0 1] range
if ndims(cdata) == 3 && ( isa(cdata, 'double') || isa(cdata,'single') )
    cdata(cdata > 1) = 1;
    cdata(cdata < 0) = 0;
end

% Catch complex CData case
if (~isreal(cdata))
    wid = sprintf('Images:%s:displayingRealPart',mfilename);
    warning(wid, '%s', 'Displaying real part of complex input.');
    cdata = real(cdata);
end

%--------------------------------------------------------------------------
function [common_args,specific_args] = parseParamValuePairs(in,valid_params,...
                                                  specific_arg_names,...
                                                  num_pre_param_args,...
                                                  function_name,...
                                                  common_args,...
                                                  specific_args)

if rem(length(in),2)~=0
    eid = sprintf('Images:%s:oddNumberArgs',function_name);
    error(eid, ...
        'Function %s expected an even number of parameter/value arguments.',...
        upper(function_name));
end

for k = 1:2:length(in)
    prop_string = iptcheckstrs(in{k}, valid_params, function_name,...
        'PARAM', num_pre_param_args + k);

    switch prop_string
        case 'DisplayRange'
            if isempty(in{k+1})
                common_args.(prop_string) = getAutoCLim(common_args.CData);
            else
                common_args.(prop_string) = checkDisplayRange(in{k+1},mfilename);
            end

        case 'InitialMagnification'
            common_args.(prop_string) = in{k+1};

        case {'XData','YData'}
            common_args.(prop_string) = in{k+1};
            checkCoords(in{k+1},upper(prop_string),num_pre_param_args+k+1)

        case specific_arg_names
            % A subscript is necessary because specific_args is initialized
            % as an empty struct.
            specific_args(1).(prop_string) = in{k+1};

        otherwise
            eid = sprintf('Images:%s:unrecognizedParameter',function_name);
            error(eid,'%s','The parameter, %s, is not recognized by %s',...
                prop_string,function_name);

    end
end

%------------------------------------------------
function checkCoords(coords,coord_string,arg_pos)

iptcheckinput(coords, {'numeric'}, {'real' 'nonsparse' 'finite' 'vector'}, ...
    mfilename, coord_string, arg_pos);

if numel(coords) < 2
    eid = sprintf('Images:%s:need2Coords', mfilename);
    error(eid,'%s must be a 2-element vector.',coord_string);
end

%----------------------------------------
function imgtype = findImageType(img,map)

if (isempty(map))
    if ndims(img) == 3
        imgtype = 'truecolor';
    elseif islogical(img)
        imgtype = 'binary';
    else
        imgtype = 'intensity';
    end
else
    imgtype = 'indexed';
end

