function out = tom_HT_fileread(filename,varargin)

p = inputParser;
p.FunctionName = 'tom_HT_fileread';

p.addParamValue('binning', 0, @(x)x>=0 && mod(x,1)==0 && isscalar(x));
p.addParamValue('resample', 1, @(x)x>0 && mod(x,1)==0 && isscalar(x));
p.addParamValue('getParticles',NaN,@isvector);
p.addParamValue('mirror',NaN,@isvector);
p.addParamValue('waitbar',0,@(x)x==0 || x==1)
p.addParamValue('thumbnail', NaN, @isscalar);

p.parse(varargin{:});

if ~exist(filename,'file');
    error(['File' filename ' does not exist or is not readable.']);
end

[pathstr, name, ext] = fileparts(filename);

%determine size of thumbnail
if ~isnan(p.Results.thumbnail)
    
    if tom_isemfile(filename) == 1
        header = tom_reademheader(filename);
    else
        error('Cannot thumbnail this file type.');
    end
    
    resample = auto_size(header.Header.Size(1),p.Results.thumbnail);
    
else 
    resample = p.Results.resample;
end

binning = 2.^p.Results.binning;

%em particle stack
if sum(isnan(p.Results.getParticles)) == 0 && tom_isemfile(filename) == 1
    numParticles = length(p.Results.getParticles);
    h = tom_reademheader(filename);
    out = zeros(h.Header.Size(1)./binning,h.Header.Size(2)./binning,numParticles,'single');
    for partnum = 1:numParticles
        [Data.Value Data.Header.Magic Data.Header.Size Data.Header.Comment, Data.Header.Parameter Data.Header.Fillup] = tom_emreadinc_resample3(filename,[resample resample 1],[binning binning 1],[1 1 p.Results.getParticles(partnum)],[h.Header.Size(1) h.Header.Size(2) 1]);
        out.Value(:,:,partnum) = Data.Value;
    end
    out.filetype = 'emstack';

%spider particle directory
elseif sum(isnan(p.Results.getParticles)) == 0 && isdir(filename) == 1
    numParticles = length(p.Results.getParticles);
    filelist = tom_HT_getdircontents(filename,{'spi'},p.Results.waitbar);
    h = tom_spiderread([filename '/' filelist{1}]);
    [s1 s2 s3 partname] = regexp(filelist{1}, '\S*_');
    out = zeros(h.Header.Size(1)./binning,h.Header.Size(2)./binning,numParticles,'single');
    [xx,xxx, ext] = fileparts(filelist{1});
    if p.Results.waitbar == 1
        h = waitbar(0,'Reading particles');
    end
    fraction = ceil(numParticles./100);
    for partnum = 1:numParticles
        Data = tom_spiderread([filename '/' partname{1} num2str(partnum) ext]);
        Data.Value = tom_binc(Data.Value,p.Results.binning);
        out.Value(:,:,partnum) = Data.Value;
        if p.Results.waitbar == 1 && mod(partnum,fraction) == 0
            waitbar(partnum./numParticles,h,[num2str(partnum), ' of ', num2str(numParticles), ' particles loaded.']);
        end
    end
    if p.Results.waitbar == 1
        close(h);
    end
    out.filetype = 'spistack';

    
%plain em file
elseif tom_isemfile(filename) == 1
     %out = tom_emreadc(filename,'binning',p.Results.binning,'resample',[resample resample 1]);
     %out = tom_emreadc(filename,'resample',[resample resample 1]);
     out = tom_emreadc(filename);
     out.Value = out.Value(1:resample:end,1:resample:end);
     if p.Results.binning > 0
        out.Value = tom_binc(out.Value,p.Results.binning);
     end
     
    out.filetype = 'em';
    if ~isnan(p.Results.thumbnail)
        out.origsize = header.Header.Size;
    else
        out.origsize = out.Header.Size .* binning .* resample;
    end
%spider file
elseif tom_isspiderfile(filename) == 1
    out = tom_spiderread(filename);
    out.filetype = 'spider';
%mat file
elseif strcmp(ext,'.mat') == 1
    out = load(filename);
end


function resampling = auto_size(size_in,size_out)

resampling = floor(size_in./size_out);

if resampling == 0
    resampling = 1;
end




