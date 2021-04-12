function [descriptions extensions read_fcns write_fcns] = parseImageFormats
%PARSEIMAGEFORMATS parses out image format information into cell arrays.
%   parseImageFormats returns cell arrays which contain information for 
%   each image format returned by IMFORMATS plus DICOM.
%
%   Outputs:
%   descriptions : strings of format descriptions
%   extensions   : cell arrays of string extensions for each format
%   read_fcns    : function handles of format read functions
%   write_fncs   : function handles of format write functions
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/27 19:11:38 $

% Parse formats from IMFORMATS
formats = imformats;
nformats = length(formats);

% Initialize cell arrays
descriptions = cell(nformats,1);
extensions   = cell(nformats,1);
read_fcns    = cell(nformats,1);
write_fcns   = cell(nformats,1);

% Populate cell arrays
[descriptions{:}] = deal(formats.description);
[extensions{:}]   = deal(formats.ext);
[read_fcns{:}]    = deal(formats.read);
[write_fcns{:}]   = deal(formats.write);

% Add other formats that are not part of IMFORMATS
descriptions{end+1} = 'DICOM (DCM)';
extensions{end+1}   = {'dcm'};
read_fcns{end+1}    = @dicomread;
write_fcns{end+1}   = @dicomwrite;
