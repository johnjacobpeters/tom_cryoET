function result = get_stacks_fromdb(this)

result = fetch(this.projectstruct.conn,['SELECT partgroup_id,name FROM particle_groups LEFT JOIN particle_groups_has_projects ON particle_groups_partgroup_id = ' num2str(this.projectstruct.projectid)]);
