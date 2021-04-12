function result = tom_HT_getmasks(projectstruct)

result = fetch(projectstruct.conn,['SELECT mask_id, name FROM masks LEFT JOIN masks_has_projects ON masks_mask_id = ' num2str(projectstruct.projectid)]);
