function this = loadimage(this,imageid,outsize,binning)

if nargin < 4
    binning = 0;
end

if nargin < 3
    outsize = [];
end


if ischar(imageid)
    imageid = get_imageid_from_filename(this,imageid);
end

image = get_fullname_from_imageid(this,imageid);

if ~isempty(outsize)
    this.image = tom_HT_fileread(image,'thumbnail',outsize);
else
    this.image = tom_HT_fileread(image,'binning',binning);
end

result = fetch(this.projectstruct.conn,['SELECT date FROM micrographs WHERE micrograph_id = ' num2str(imageid)]);

this.image.Header.Date = result.date{1};
this.image.Header.Date = this.image.Header.Date(1:end-2);
this.header = this.image.Header;
if isfield(this.image,'origsize')
    this.origsize = this.image.origsize;
else
    this.origsize = size(this.image.Value);
end

this.micrographid = imageid;



