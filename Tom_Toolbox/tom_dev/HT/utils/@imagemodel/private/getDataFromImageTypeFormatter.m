function data = getDataFromImageTypeFormatter(imgmodel,tag)
%getDataFromImageTypeFormatter Data based on imgmodel.
%   DATA = getDataFromImageTypeFormatter(IMGMODEL,TAG) returns DATA from the
%   imagemodel as specified by TAG. TAG can have various options as listed
%   in the first column of the table below. The DATA generated as a result
%   of TAG is listed in the second column.
%
%   'DefaultPixelInfoString'      Default string used in IMPIXELINFOVAL.
%
%   'PixelInfoString'             Function handle that takes a row and
%                                 column as an input and returns a formatted
%                                 string containing the pixel value at that
%                                 location.
%
%   'DefaultPixelRegionString'    Default string used in IMPIXELREGIONPANEL.
%
%   'PixelRegionString'           Function handle that takes a row and
%                                 column as an input and returns a
%                                 formatted string containing
%                                 the pixel value at that location.
%
%   'PixelValue'                  Function handle that takes a row and
%                                 column as an input and returns the pixel
%                                 value at that location.
%
%   See also IMAGEMODEL.
%
%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision.6.8.1 $  $Date: 2006/06/15 20:09:47 $


[formatNumber, containsFloat] = getNumberFormatFcn(imgmodel);

switch findImageType(imgmodel.ImageHandle)
    case 'intensity'
        data = intensityformatter;

    case 'truecolor'
        data = truecolorformatter;

    case 'binary'
        data = binaryformatter;

    case 'indexed'
        data = indexedformatter;

    otherwise
        eid = sprintf('Images:%s:internalError',mfilename);
        msg = 'Internal error: invalid image type.';
        error(eid,'%s',msg);
end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function data = intensityformatter

        switch tag
            case 'PixelInfoString'
                data = @getIntensityPixelInfoString;
            case 'DefaultPixelInfoString'
                data = 'Intensity';
            case 'PixelRegionString'
                data = @getIntensityPixelRegionStrings;
            case 'DefaultPixelRegionString'
                data = getDefaultPixelRegNumString;
            case 'PixelValue'
                data = @getValues;
        end

    end % end of intensityFormatter


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function data = binaryformatter

        switch tag
            case 'PixelInfoString'
                data = @getIntensityPixelInfoString;
            case 'DefaultPixelInfoString'
                data = 'BW';
            case 'PixelRegionString'
                data = @getIntensityPixelRegionStrings;
            case 'DefaultPixelRegionString'
                data = '0';
            case 'PixelValue'
                data = @getValues;
        end
    end %end of binaryFormatter


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function data = truecolorformatter

        switch tag
            case 'PixelInfoString'
                data = @getPixelInfoString;
            case 'DefaultPixelInfoString'
                data = '[R G B]';
            case 'PixelRegionString'
                data = @getPixelRegionStrings;
            case 'DefaultPixelRegionString'
                data = getDefaultPixelRegionString;
            case 'PixelValue'
                data = @getRGBValues;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pixelInfoString = getPixelInfoString(r,c)

            color = getRGBValues(r,c);
            [redString,greenString,blueString] = ...
                getRGBColorStrings(color,formatNumber);
            pixelInfoString = sprintf('[%1s %1s %1s]', redString{1}, ...
                                      greenString{1}, blueString{1});

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function string = getDefaultPixelRegionString

            color = getDefaultPixelRegNumString;
            string = sprintf('R:%1s\nG:%1s\nB:%1s', color,color,color);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pixelRegionStrings = getPixelRegionStrings(r,c)

            colors = getRGBValues(r,c);

            [redStrings,greenStrings,blueStrings] = ...
                getRGBColorStrings(colors,formatNumber);

            max_length = max([max(cellfun('prodofsize', redStrings)) ...
                max(cellfun('prodofsize', greenStrings)) ...
                max(cellfun('prodofsize', blueStrings))]);

            formatString = sprintf('R:%%%ds\nG:%%%ds\nB:%%%ds', ...
                max_length, max_length, max_length);

            numCoord = numel(r);
            pixelRegionStrings = cell(numCoord, 1);

            for k = 1:numCoord
                pixelRegionStrings{k} = sprintf(formatString, redStrings{k}, ...
                    greenStrings{k}, ...
                    blueStrings{k});
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function color = getRGBValues(r,c)

            img = get(imgmodel.ImageHandle,'CData');
            M = size(img, 1);
            N = size(img, 2);
            idx = (c-1)*M + r;
            page_size = M*N;
            if ~isempty(img)
                color = [img(idx) img(idx + page_size) img(idx + 2*page_size)];
            else
                color = [];
            end
        end

    end % end of truecolorFormatter


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function data = indexedformatter

        % the case where the image is a floating pt image with a cdatamapping
        % of 'direct' is handled in the indexedformatter to preserve the
        % dynamic nature of the imagemodel object.
        switch tag
            case 'PixelInfoString'
                data = @getPixelInfoString;
            case 'DefaultPixelInfoString'
                if ~containsFloat
                    data = '<Index>  [R G B]';
                else
                    data = 'Value  <Index>  [R G B]';
                end
            case 'PixelRegionString'
                data = @getPixelRegionStrings;
            case 'DefaultPixelRegionString'
                data = getDefaultPixelRegionString;
            case 'PixelValue'
                data = @getIndexColors;
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pixelInfoString = getPixelInfoString(r,c)

            [color,index,mapIndex] = getIndexColors(r,c);

            [redString,greenString,blueString] = getRGBColorStrings(color, ...
                imgmodel.MapEntryFormatFcn);
            pixelInfoString = sprintf('%1s  [%1s %1s %1s]', ...
                getIndexString(index,mapIndex), ...
                redString{1}, greenString{1}, ...
                blueString{1});
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pixelRegionStrings = getPixelRegionStrings(r,c)

            [colors,indices,mapIndices] = getIndexColors(r,c);

            [redStrings,greenStrings,blueStrings] = ...
                getRGBColorStrings(colors,imgmodel.MapEntryFormatFcn);

            numCoord = numel(r);
            pixelRegionStrings = cell(numCoord, 1);

            for k = 1:numCoord
                if isempty(indices)
                    pixelRegionStrings{k} = sprintf('<%1s>\nR:%1s\nG:%1s\nB:%1s', ...
                        ' ', redStrings{k}, ...
                        greenStrings{k}, blueStrings{k});
                else
                    pixelRegionStrings{k} = ...
                        sprintf('%1s\nR:%1s\nG:%1s\nB:%1s', ...
                        getIndexString(indices(k),mapIndices(k)), ...
                        redStrings{k}, greenStrings{k}, blueStrings{k});
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function string = getDefaultPixelRegionString

            formatMapEntry = imgmodel.MapEntryFormatFcn;
            mapEntry = formatMapEntry(0);

            if ~containsFloat
                indexString = getDefaultPixelRegNumString;
                string = sprintf('<%s>\nR:%s\nG:%s\nB:%s', indexString,mapEntry, ...
                                 mapEntry,mapEntry);
            else
                valueString = formatNumber(0);
                indexString = '000';  %choosing some that is reasonable
                                      %given this edge case
                string = sprintf('%s <%s>\nR:%s\nG:%s\nB:%s',valueString, ...
                                 indexString,mapEntry, mapEntry,mapEntry);
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [color,index,mapIndex] = getIndexColors(r,c)

            classType = getClassType(imgmodel);
            map = get(ancestor(imgmodel.ImageHandle, 'figure'),'Colormap');

            index = getValues(r,c);

            if ~isempty(index)
                if ~strcmp(classType,'double') && ~strcmp(classType,'single')
                    mapIndex = index + 1;
                else
                    if ~containsFloat
                        mapIndex = max(1,index);
                    else
                        mapIndex = max(1,floor(index));
                    end
                end
                mapIndex = min(mapIndex,size(map,1));
                color = map(mapIndex,:);
            else
                mapIndex = index;
                color = [];
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function string = getIndexString(index,mapIndex)

            if ~containsFloat
                if isempty(index)
                    % need this case because of the way sprintf is designed.
                    string = '< >';
                else
                    string = sprintf('<%1d>',index);
                end
            else
                string = sprintf('%1s  <%1d>', formatNumber(index),mapIndex);
            end
        end
    end % end of indexedFormatter

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [redStr,greenStr,blueStr] = getRGBColorStrings(colors,formatFcn)

        numColors = size(colors,1);

        if numColors == 0
            redStr = {''};
            greenStr = {''};
            blueStr = {''};
        else
            redStr = cell(numColors, 1);
            greenStr = cell(numColors, 1);
            blueStr = cell(numColors, 1);

            for k = 1 : numColors
                redStr{k} = formatFcn(colors(k,1));
                greenStr{k} = formatFcn(colors(k,2));
                blueStr{k} = formatFcn(colors(k,3));
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pixelInfoString = getIntensityPixelInfoString(r,c)

        value = getValues(r,c);
        pixelInfoString = sprintf('%1s', formatNumber(value));
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pixelRegionStrings = getIntensityPixelRegionStrings(r,c)

        pixelRegionStrings = cell(numel(r), 1);
        for k = 1:numel(r)
            pixelRegionStrings{k} = getIntensityPixelInfoString(r(k), c(k));
        end

    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function values = getValues(r,c)

        img = get(imgmodel.ImageHandle,'CData');
        M = size(img, 1);
        if ~isempty(img)
            values = img((c-1)*M + r);
        else
            values = [];
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function string = getDefaultPixelRegNumString

        switch getClassType(imgmodel)
            case {'double','single'}
                if ~containsFloat
                    %this could be data that was once int16
                    string = '-0.00E+00';
                else
                    string = formatNumber(0);
                end
            case 'uint16'
                string = '00000';
            case 'int16'
                string = '-00000';
            case 'uint8'
                string = '000';
            otherwise
                eid = sprintf('Images:%s:internalError',mfilename);
                msg = 'Internal error - invalid class type.';
                error(eid,'%s',msg);
        end
    end

end % end of getDataFromImageTypeFormatter
