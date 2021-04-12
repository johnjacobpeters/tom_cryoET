function this = update_radius(this,radius)

exec(this.projectstruct.conn,['UPDATE particle_groups SET radius = ' num2str(radius) ' WHERE partgroup_id = ' num2str(this.stackid)]);