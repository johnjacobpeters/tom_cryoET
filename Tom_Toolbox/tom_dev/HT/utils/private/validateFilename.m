function filename = validateFilename(filename,filter_ext)
%VALIDATEFILENAME validates user input to the Save Image tool.
%   validateFileame(filename,filter_ext) compares any user-supplied file
%   extension at the end of filename, and appends filter_ext if necessary.
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:11:39 $

% Find any dots in the user supplied filename
dot_loc = strfind(filename,'.');

if isempty(dot_loc)
    filename = sprintf('%s.%s',filename,filter_ext);
elseif strcmp(filename(end),'.')
    filename = sprintf('%s.%s',filename,filter_ext);
else
    % Get user-supplied file extension to validate
    user_ext = filename(dot_loc(end)+1:end);
    
    % Get valid extensions from IMFORMATS
    [desc imformats_ext_arrays] = parseImageFormats;
    
    % Find the user supplied extension in our arrays of valid extensions
    findExtInLists = @(ext_array) any(strcmp(user_ext,ext_array));
    matched_index  = cellfun(findExtInLists,imformats_ext_arrays);
    found_user_ext_in_imformats = any(matched_index);

    % If the user supplied an unknown extension, append a valid one and
    % return
    if ~found_user_ext_in_imformats
        filename = sprintf('%s.%s',filename,filter_ext);
        return
    end
    
    % Check that the matched user-supplied extension actually matches the
    % file format that was selected in the file filter dropdown box
    matched_ext_array = imformats_ext_arrays{matched_index};
    valid_ext = any(strcmp(filter_ext,matched_ext_array));
    if ~valid_ext
        filename = sprintf('%s.%s',filename,filter_ext);
    end
end

