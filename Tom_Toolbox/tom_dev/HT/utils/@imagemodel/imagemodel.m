function imgmodel = imagemodel(varargin)
%IMAGEMODEL Access to properties of an image relevant to its display.
%   IMGMODEL = IMAGEMODEL(HIMAGE) creates an image model object 
%   associated with the target image HIMAGE. HIMAGE is a handle 
%   to an image object or an array of handles to image objects. 
%   
%   IMAGEMODEL returns an image model object or, if HIMAGE is an 
%   array of image objects, an array of image model objects. 
%  
%   An image model object stores information about an image
%   such as class, type, display range, width, height, minimum
%   intensity value and maximum intensity value.  
%   
%   The image model object supports methods that you can use
%   to access this information, get information about the pixels
%   in an image, and perform special text formatting.  
%   The following lists these methods with a brief description. 
%   Use METHODS(IMGMODEL) to get a list of image model methods. 
%
%   getClassType
%
%       Returns a string indicating the class of the image.
%
%           str = getClassType(IMGMODEL)
%
%       where IMGMODEL is a valid image model and STR is a text
%       string, such as 'uint8'.
%
%   getDisplayRange
%
%       Returns a double array containing the minimum and 
%       maximum values of the display range for an intensity image.
%       For image types other than intensity, the value returned 
%       is an empty array.
%   
%           disp_range = getDisplayRange(IMGMODEL)
%
%       where IMGMODEL is a valid image model and disp_range is 
%       an array of doubles such as [0 255]. 
%
%   getImageHeight
%
%       Returns a double scalar containing the number of rows.
%
%          HEIGHT = getImageHeight(IMGMODEL)
%
%       where IMGMODEL is a valid image model and HEIGHT is 
%       a double scalar.    
%
%
%   getImageType
%
%       Returns a text string indicating the image type. 
%
%          STR = getImageType(IMGMODEL)
%
%       where IMGMODEL is a valid image model and STR is 
%       one of the text strings 'intensity', 'truecolor',
%       'binary', or 'indexed'.
%
%   getImageWidth
%
%       Returns a double scalar containing the number of columns.
%
%          WIDTH = getImageWidth(IMGMODEL)
%
%       where IMGMODEL is a valid image model and WIDTH is 
%       a double scalar.
%
%   getMinIntensity
%
%       Returns the minimum value in the image calculated as 
%       min(Image(:)). For an intensity image, the value returned is 
%       the minimum intensity. For an indexed image, the value 
%       returned is the minimum index. For any other image type, the 
%       value returned is an empty array.
%       
%          MINVAL = getMinIntensity(IMGMODEL)
%
%       where IMGMODEL is a valid image model and MINVAL is 
%       a numeric value. The class of MINVAL depends on the class
%       of the target image. 
%
%   getMaxIntensity
%
%       Returns the maximum value in the image calculated as 
%       max(Image(:)). For an intensity image, the value returned is 
%       the maximum intensity. For an indexed image, the value 
%       returned is the maximum index. For any other image type, the 
%       value returned is an empty array.
%       
%          MAXVAL = getMaxIntensity(IMGMODEL)
%
%       where IMGMODEL is a valid image model and MAXVAL is 
%       a numeric value. The class of MAXVAL depends on the class
%       of the target image.
%
%
%   The image model object also supports methods that return image 
%   information as a text string or perform specialized formatting 
%   of information. 
%  
%   getPixelInfoString
%   
%       Returns a text string containing value of the pixel at the 
%       location specified by ROW and COLUMN.
%   
%           STR = getPixelInfoString(IMGMODEL,ROW,COLUMN)
%
%       where IMGMODEL is a valid image model and ROW and COLUMN are 
%       numeric scalar values. STR is a character array. For example,
%       for an RGB image, the method returns a text string such as 
%       '[66 35 60]'.
%  
%   getDefaultPixelInfoString
%
%       Returns a text string indicating the type of information returned
%       in a pixel information string. This string can be used in place
%       of actual pixel information values.
%
%           STR = getDefaultPixelInfoString(IMGMODEL)
%
%       where IMGMODEL is a valid image model. Depending on the image type,
%       STR can be the text string 'Intensity','[R G B]','BW', or 
%       '<Index> [R G B]'.  
%
%   getDefaultPixelRegionString
%
%       Returns a text string indicating the type of information displayed
%       in the Pixel Region tool for each image type. This string can be
%       used in place of actual pixel values.
%
%           STR = getDefaultPixelRegionString(IMGMODEL)
%
%       where IMGMODEL is a valid image model. Depending on the image type,
%       STR can be the text string '000','R:000 G:000 B:000]','0', or 
%       '<000> R:0.00 G:0.00 B:0.00'.  
%
%   getPixelValue
%
%       Returns the value of the pixel at the location specified
%       by ROW and COLUMN as a numeric array.
%
%           VAL = getPixelValue(IMGMODEL,ROW,COLUMN)
%
%       where IMGMODEL is a valid image model and ROW and COLUMN are 
%       numeric scalar values. The class of VAL depends on the class 
%       of the target image. 
%
%   getScreenPixelRGBValue
%
%       Returns the screen display value of the pixel at the location 
%       specified by ROW and COLUMN as a double array.
%
%           VAL = getScreenPixelRGBValue(IMGMODEL,ROW,COLUMN)
%
%       where IMGMODEL is a valid image model and ROW and COLUMN are 
%       numeric scalar values. VAL is an array of doubles, such as
%       [0.2 0.5 0.3].
%
%
%   In addition to these information formatting functions, the image
%   model supports methods that return handles to functions that
%   perform special formatting.
%
%   getNumberFormatFcn
%
%       Returns the handle to a function that converts a 
%       numeric value into a string.
%
%           FUN = getNumberFormatFcn(IMGMODEL)
%
%       where IMGMODEL is a valid image model. FUN is a handle
%       to a function that accepts a numeric value and returns 
%       the value as a text string. For example, you can use
%       this function to convert the numeric return value of
%       the getPixelValue method into a text string.
%
%           STR = FUN(getPixelValue(IMGMODEL,100,100)) 
%
%   getPixelRegionFormatFcn
%
%       Returns a handle to a function that formats the value
%       of a pixel into a text string. 
%   
%           FUN = getPixelRegionFormatFcn(IMGMODEL)
%
%       where IMGMODEL is a valid image model. FUN is a handle
%       to a function that accepts the location (ROW,COLUMN) of
%       a pixel in the target image and returns the value of
%       the pixel as a specially formatted text string. For 
%       example, when used with an RGB image, this function
%       returns a text string of the form 'R:000 G:000 B:000'
%       where 000 is the actual pixel value.
%
%           STR = FUN(100,100)
%
%   Note
%   ----  
%   IMAGEMODEL works by querying the image object's CData.  For a
%   single or int16 image, the image object converts its CData to
%   double. For example, in the case of h = imshow(int16(ones(10))),
%   class(get(h,'CData')) returns 'double'. Therefore, 
%   getClassType(imgmodel) returns 'double'.
%
%   Examples
%   --------
%
%       h = imshow('peppers.png');
%       im = imagemodel(h);
%
%       figure,subplot(1,2,1)
%       h1 = imshow('hestain.png');
%       subplot(1,2,2)
%       h2 = imshow('coins.png');
%       im = imagemodel([h1 h2]);
%   
%   See also GETIMAGEMODEL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision.1 $  $Date: 2005/03/31 16:32:02 $


%   IMAGEMODEL stores the following data it derives from the image object.
%  
%   ImageHandle          Handle to image object. 
%   
%   MapEntryFormatFcn    Anonymous function that takes
%                        one band value of a color in the colormap as an 
%                        input and returns a formatted string.
%
%                        For example:
%
%                        string = imgmodel.MapEntryFormatFcn(.5625);
%
  
hImage = parseInputs(varargin{:});

imgmodel = imagemodelStruct;

if ~isempty(hImage)
  numHandles = numel(hImage);
  imgmodel = repmat(imgmodel,1,numHandles);

  for k = 1 : numHandles
    imgmodel(k).ImageHandle = hImage(k);
    imgmodel(k).MapEntryFormatFcn = @dispMapEntryFcn;
  end
end
imgmodel = class(imgmodel,'imagemodel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function im = imagemodelStruct
%defaults
im.ImageHandle = [];
im.MapEntryFormatFcn = '';
im.ImageOrigClassType = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function hIm = parseInputs(varargin)
  
%Assign Defaults
hIm = [];

iptchecknargin(0,1,nargin,mfilename);

if nargin == 1
  hIm = varargin{1};

  if ~all(ishandle(hIm)) || ~all(strcmp(get(hIm,'type'),'image'))
    eid = sprintf('Images:%s:invalidImageHandle',mfilename);
    msg = 'HIMAGE must be an array containing valid image handles.';
    error(eid,'%s',msg);
  end
end

function out_str = dispMapEntryFcn(mapEntry)
% This function used to be an anonymous function, but it was causing multiple
% instances of the object to be created.  This was due to the fact that
% anonymous function makes the parent workspace persist and act like nested
% functions.

% @(mapEntry) sprintf('%1.2f',mapEntry);

out_str = sprintf('%1.2f',mapEntry);
