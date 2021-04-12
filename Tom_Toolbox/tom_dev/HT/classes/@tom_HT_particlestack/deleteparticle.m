function this = deleteparticle(this,particleid)

idx = find(this.particleid==particleid);

this.radius(idx) = 0;
this.position.x(idx) = 0;
this.position.y(idx) = 0;
this.micrographid(idx) = 0;
this.particleid(idx) = 0;

this.radius = nonzeros(this.radius);
this.position.x = nonzeros(this.position.x);
this.position.y = nonzeros(this.position.y);
this.micrographid = nonzeros(this.micrographid);
this.particleid = nonzeros(this.particleid);

this.numparticles = this.numparticles - 1;

exec(this.projectstruct.conn,['DELETE FROM particles WHERE particle_id = ' num2str(particleid)]);