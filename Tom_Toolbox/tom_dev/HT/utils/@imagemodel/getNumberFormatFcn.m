function [formatFcn,containsFloat,needsExponent] = getNumberFormatFcn(imgmodel)
%getNumberFormatFcn Returns handle to function that returns formatted number string.
%   formatFcn = getNumberFormatFcn(IMGMODEL) returns a function
%   handle. formatFcn has this signature:
%
%       STR = formatFcn(V)
%
%   where STR is a formatted string representation of V, a scalar.
%
%   IMGMODEL is expected to contain one image model object.
%
%   Example
%   -------
%       This example shows how the formatted string depends on the
%       image class type.
%
%       I = imread('snowflakes.png');
%       h = imshow(I)
%       im = imagemodel(h);
%       formatFcn = getNumberFormatFcn(imgmodel)
%       string = formatFcn(I(1,1))
%
%       I = im2single(I);
%       h = imshow(I);
%       im = imagemodel(h);
%       formatFcn = getNumberFormatFcn(im)
%       string = formatFcn(I(1,1))
%
%   See also IMAGEMODEL.

%   [formatFcn,containsFloat] = getNumberFormatFcn(imgmodel) returns
%   a boolean containsFloat indicating whether IMGMODEL accesses
%   an image containing floating point values. containsExponent
%
%   [formatFcn,containsFloat,needsExponent] = getNumberFormatFcn(imgmodel)
%   returns a boolean needsExponent indicating whether the function uses
%   exponent notation to represent the image data.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2007/01/15 14:37:52 $

imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
imageClass = getClassType(imgmodel);

containsFloat = false;

switch imageClass
    case {'int16','uint16','uint8','logical'}
        needsExponent = false;
        formatFcn = @(value) sprintf('%d',value);

    case {'double','single'}
        img = get(imgmodel.ImageHandle,'CData');

        absMaxVal = abs(max(img(:)));

        % The way we check if the image doesn't have floating pt numbers is
        % not ideal, but it is faster than the old version. Plan to
        % refactor this in the next release.
        try
            errState = lasterror;
            iptcheckinput(img,{'double', 'single'}, {'integer'}, ...
                mfilename, 'img',1);
        catch
            containsFloat = true;
            lasterror(errState);
        end

        if containsFloat
            needsExponent = absMaxVal >= 10^4 | absMaxVal < 10^-2;
            if needsExponent
                formatFcn = @createStringForExponents;
            else
                formatFcn = @(value) sprintf('%1.2f',value);
            end
        else
            % we do not want int16 data to be viewed as an exponent
            needsExponent = absMaxVal > 32768 ; 
            
            if needsExponent
                formatFcn = @createStringForExponents;
            else
                formatFcn = @(value) sprintf('%d',value);
            end
        end

    otherwise
        eid = sprintf('Images:%s:internalError',mfilename);
        msg = 'Internal error: invalid class type.';
        error(eid,'%s',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function string = createStringForExponents(value)

state = warning('off','Images:imuitoolsgate:undocumentedFunction');
string = sprintf('%1.2E', value);
fixENotation = imuitoolsgate('FunctionHandle','fixENotation');
string = fixENotation(string);
warning(state);