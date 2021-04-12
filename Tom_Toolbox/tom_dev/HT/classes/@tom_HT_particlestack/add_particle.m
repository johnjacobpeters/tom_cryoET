function [this,lastids] = add_particle(this,pos_x,pos_y,radius,micrographid)

numparts = size(pos_x,1);

if isscalar(radius)
    radius  = repmat(radius,numparts,1);
end

if isscalar(micrographid)
    micrographid  = repmat(micrographid,numparts,1);
end

set(this.projectstruct.conn,'AutoCommit','off');

lastids = zeros(1,numparts,'uint32');

for i=1:numparts
    this.radius(this.numparticles+i) = radius(i);
    this.position.x(this.numparticles+i) = pos_x(i);
    this.position.y(this.numparticles+i) = pos_y(i);
    this.micrographid(this.numparticles+i) = micrographid(i);
       
    fastinsert(this.projectstruct.conn,'particles',{'pos_x','pos_y','micrographs_micrograph_id'},[pos_x(i),pos_y(i), micrographid(i)]);
    exec(this.projectstruct.conn,['INSERT INTO particles_has_particle_groups VALUES (LAST_INSERT_ID(),' num2str(this.stackid) ')']);
    
    commit(this.projectstruct.conn);
    lastid = tom_HT_lastinsertid(this.projectstruct.conn);
    this.particleid(this.numparticles+i) = lastid;
    lastids(i) = lastid;
end

set(this.projectstruct.conn,'AutoCommit','on');
this.numparticles = this.numparticles + numparts;
this.currentparticle = this.numparticles;
