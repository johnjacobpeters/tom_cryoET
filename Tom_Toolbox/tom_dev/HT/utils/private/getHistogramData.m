function histDataStruct = getHistogramData(hImage)
% GETHISTOGRAMDATA Returns data needed to create the image histogram.
%   The fields inside of HISTDATASTRUCT are:
%     histRange      Histogram Range
%     finalBins      Bin locations
%     counts         Histogram counts
%     nBins          Number of bins
%
%

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision.3.4.3 $  $Date: 2007/01/15 14:37:57 $


%  This function is called IMCONTRAST, WINDOWLEVEL, and IMHISTPANEL.


if isappdata(hImage, 'HistogramData')
    histDataStruct = getappdata(hImage, 'HistogramData');

else
    [hrange, fbins, cnts, numbins] = computeHistogramData(hImage);
    histDataStruct.histRange = hrange;
    histDataStruct.finalBins = fbins;
    histDataStruct.counts    = cnts;
    histDataStruct.nbins     = numbins;

    setappdata(hImage,'HistogramData', histDataStruct);

    % Attach listeners to remove the HISTOGRAM data when the following
    % image properties change:
    %  * CData
    %  * CDataMapping
    image_handle = handle(hImage);

    cdata = image_handle.findprop('CData');
    CdataListener = handle.listener(image_handle, cdata,...
        'PropertyPostSet', @removeHistogramData);

    cdatamapping = image_handle.findprop('CDataMapping');
    CdataMappingListener = handle.listener(image_handle, cdatamapping,...
        'PropertyPostSet', @removeHistogramData);

    % We are storing the listeners in the image handle object because the
    % caller of this function could be a tool in a separate figure or a
    % tool in the target figure.
    setappdata(hImage,...
        'ImagePropertyListener',[CdataListener, CdataMappingListener]);
end

    %====================================
    function removeHistogramData(varargin)
        rmappdata(hImage, 'HistogramData');

        % Need to call delete as a workaround to g356436
        delete(CdataListener);
        delete(CdataMappingListener);
        rmappdata(hImage, 'ImagePropertyListener');
    end % removeHistogramData

end % getHistogramData

%==========================================================================
function [histRange, finalBins, counts, nbins] = computeHistogramData(hIm)
% This function does the actual computation

X = get(hIm,'CData');
X = X(1:10:end,1:10:end);
xMin = min(X(:));
xMax = max(X(:));
origRange = xMax - xMin;

% Compute Histogram for the image.  The Xlim([minX maxX]) is based on either the
% range of the class or the data range of the image.  In addition, we have to
% consider that users may need "wiggle room" in the xlim.  For example, customers
% may be working on images that have data ranges that are smaller than the display
% range. They may use the tool on several images to come up with a clim range  
% that works for all cases.

switch (class(X))
   case 'uint8'
        nbins = 256;
        [counts, bins]     = imhist(X, nbins);
        calculateFinalBins = @(bins,idx) bins;
        calculateNewCounts = @(counts,idx) counts;

        calculateMinX      = @(bins,fBins,idx) 0;
        calculateMaxX      = @(bins,fBins,idx) 255; 

   case {'uint16'}
      % The values are set with respect to the first and last bin containing image
      % data instead of the min and max of the datatype. If we didn't do this,
      % then a uint16 image with a small data range would have a very
      % squished and not meaningful histogram.
       
      % JM chose 4 after looking at a couple of 16-bit images and thought was more
      % useful representation of the data.
      
      nbins = 65536 / 4; 
      [counts,  bins]     = imhist(X, nbins);
      calculateFinalBins = @(bins,idx) bins(idx);
      calculateNewCounts = @(counts,idx) counts(idx);
      calculateMinX      = @(bins,fBins,idx) max(0, bins(idx(1)) - 100);
      calculateMaxX      = @(bins,fBins,idx) min(65535, bins(idx(end)) + 100);
  
  case {'double','single'}
        % Images with double CData often don't work well with IMHIST. Convert all
        % images to be in the range [0,1] and convert back later if necessary.
        if (xMin >= 0) && (xMax <= 1)
            nbins = 256;
            [counts, bins]     = imhist(X, nbins); %bins is in range [0,1]
            calculateFinalBins = @(bins,idx) bins;
            calculateNewCounts = @(counts,idx) counts;
            
            calculateMinX      = @(bins,fBins,idx) 0;
            calculateMaxX      = @(bins,fBins,idx) 1;

        else
            if (origRange > 1023) %JM doesn't remember why he chose 1023
                nbins = 1024;
                calculateFinalBins = @(bins,idx) bins(idx);
                calculateNewCounts = @(counts,idx) counts(idx);
                
                calculateMinX      = @(bins,fBins,idx) bins(idx(1)) - 100;
                calculateMaxX      = @(bins,fBins,idx) bins(idx(end)) + 100;


            elseif (origRange > 255)
                nbins = 256;
                calculateFinalBins = @(bins,idx) bins;
                calculateNewCounts = @(counts,idx) counts;
                
                calculateMinX      = @(bins,fBins,idx) bins(idx(1)) - 10;
                calculateMaxX      = @(bins,fBins,idx) bins(idx(end)) + 10;
            else
                nbins = round(origRange + 1);
                calculateFinalBins = @(bins,idx) bins(idx);
                calculateNewCounts = @(counts,idx) counts(idx);
                
                calculateMinX      = @(bins,fBins,idx) fBins(idx(1)) - 10;
                calculateMaxX      = @(bins,fBins,idx) fBins(idx(end)) + 10;

            end

            X = mat2gray(X);
            [counts, bins] = imhist(X, nbins); %bins is in range [0,1]
            bins = round(bins .* origRange + xMin); % bins in range of originalData
        end

    otherwise
        error('Images:imcontrast:classNotSupported', ...
            'This image class is not yet supported.')
end

[counts,idxOfBinsWithImageData] = saturateOverlyRepresentedCounts(counts);

counts = calculateNewCounts(counts,idxOfBinsWithImageData);
finalBins = calculateFinalBins(bins,idxOfBinsWithImageData);
minX = calculateMinX(bins,finalBins,idxOfBinsWithImageData);
maxX = calculateMaxX(bins,finalBins,idxOfBinsWithImageData);
histRange = [minX maxX];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [counts,idxOfImage] = saturateOverlyRepresentedCounts(counts)

idx = find(counts ~= 0);
mu = mean(counts(idx));
sigma = std(counts(idx));

% ignore counts that are beyond 4 degrees of standard deviation.These are
% generally outliers.
countsWithoutOutliers = counts(counts <= (mu + 4 * sigma));
idx2 = countsWithoutOutliers ~= 0;
mu2 = mean(countsWithoutOutliers(idx2));

fudgeFactor = 5;
saturationValue = round(fudgeFactor * mu2); %should be an integer

counts(counts > saturationValue) = saturationValue;

%return idx of bins that contain Image Data
if isempty(idx)
    idxOfImage = 1 : nbins;
else
    idxOfImage = (idx(1) : idx(end))';
end

end
