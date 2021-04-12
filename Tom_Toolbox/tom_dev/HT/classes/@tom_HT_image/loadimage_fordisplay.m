function this = loadimage_fordisplay(this,imageid,outsize,binning)

if nargin < 4
    binning = 0;
end

if nargin < 3
    outsize = [];
end

this = loadimage(this,imageid,outsize,binning);

this.image.Value = tom_norm(single(this.image.Value),255);

