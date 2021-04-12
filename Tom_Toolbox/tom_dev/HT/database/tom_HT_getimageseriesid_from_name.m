function result = tom_HT_getimageseriesid_from_name(projectstruct,seriesname)

setdbprefs('DataReturnFormat','numeric');
result = fetch(projectstruct.conn,['SELECT micrographgroup_id FROM micrograph_groups LEFT JOIN micrograph_groups_has_projects ON micrograph_groups_micrographgroup_id = ' num2str(projectstruct.projectid) ' WHERE name = ''' seriesname '''']);
setdbprefs('DataReturnFormat','structure');