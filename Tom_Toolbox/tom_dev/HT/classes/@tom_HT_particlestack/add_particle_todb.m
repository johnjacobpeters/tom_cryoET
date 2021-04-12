function this = add_particle_todb(this,particleid)

set(this.projectstruct.conn,'AutoCommit','off');

fastinsert(this.projectstruct.conn,'particles',{'pos_x','pos_y','micrographs_micrograph_id'},[this.position.x(particleid),this.position.y(particleid), this.micrographid(particleid)]);
exec(this.projectstruct.conn,['INSERT INTO particles_has_particle_groups VALUES (LAST_INSERT_ID(),' num2str(this.stackid) ')']); 

commit(this.projectstruct.conn);
set(this.projectstruct.conn,'AutoCommit','on');