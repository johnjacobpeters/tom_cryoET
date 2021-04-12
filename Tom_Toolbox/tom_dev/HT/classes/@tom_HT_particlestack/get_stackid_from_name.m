function result = get_stackid_from_name(this,stackname)

result = fetch(this.projectstruct.conn,['SELECT partgroup_id FROM particle_groups LEFT JOIN particle_groups_has_projects ON particle_groups_partgroup_id = ' num2str(this.projectstruct.projectid) ' WHERE name = ''' stackname '''']);
result = result.partgroup_id;