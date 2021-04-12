function this = get_micrographs_from_imageseries(this,seriesid)

if ischar(seriesid)
    seriesid = getimageseriesid_from_name(this,seriesid);
end

result = fetch(this.projectstruct.conn,['SELECT micrograph_id, filename FROM micrographs WHERE micrograph_groups_micrographgroup_id = ' num2str(seriesid)]);

if isempty(result)
    error('No micrographs in this image series found.');
else
    this.filenames = result.filename;
    this.goodbad = true(size(this.filenames,1),1);
    this.micrographids = result.micrograph_id;
end
