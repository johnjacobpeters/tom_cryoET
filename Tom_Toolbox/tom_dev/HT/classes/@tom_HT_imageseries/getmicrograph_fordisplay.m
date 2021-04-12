function micrograph = getmicrograph_fordisplay(this,micrographid,statflag,outsize,binning)

if nargin < 5
    binning = 0;
end

if nargin < 4
    outsize = [];
end

if nargin < 3
    statflag = 0;
end

if isempty(micrographid)
    micrographid = get_currentfilename(this);
end

micrograph = tom_HT_image(this.projectstruct);
micrograph = loadimage_fordisplay(micrograph,micrographid,outsize,binning);

if statflag == 1
    micrograph = calcstats(micrograph);
end