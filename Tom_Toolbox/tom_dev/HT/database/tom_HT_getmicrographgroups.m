function result = tom_HT_getmicrographgroups(projectstruct)

result = fetch(projectstruct.conn,['SELECT micrographgroup_id, name FROM micrograph_groups LEFT JOIN micrograph_groups_has_projects ON micrograph_groups_micrographgroup_id = ' num2str(projectstruct.projectid)]);
