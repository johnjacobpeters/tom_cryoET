function this = savetodb(this)


idx = find(this.particleid==-1);

if ~isempty(idx)
    set(this.projectstruct.conn,'AutoCommit','off');
    
    for i=idx
        fastinsert(this.projectstruct.conn,'particles',{'pos_x','pos_y','micrographs_micrograph_id'},[this.position.x(i),this.position.y(i), this.micrographid(i)]);
        exec(this.projectstruct.conn,['INSERT INTO particles_has_particle_groups VALUES (LAST_INSERT_ID(),' num2str(this.stackid) ')']);  %'particles_has_particle_groups',{'particles_particle_id','particle_groups_partgroup_id'},{'LAST_INSERT_ID()',this.stackid});
    end
    
    commit(this.projectstruct.conn);
    set(this.projectstruct.conn,'AutoCommit','on');
end

this.particleid(idx) = -2;