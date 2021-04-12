function result = getimageseriesid_from_name(this,seriesname)

result = fetch(this.projectstruct.conn,['SELECT micrographgroup_id FROM micrograph_groups LEFT JOIN micrograph_groups_has_projects ON micrograph_groups_micrographgroup_id = ' num2str(this.projectstruct.projectid) ' WHERE name = ''' seriesname '''']);
result = result.micrographgroup_id;