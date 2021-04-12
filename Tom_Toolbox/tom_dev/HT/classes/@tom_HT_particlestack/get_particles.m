function particles = get_particles(this,micrographid)


idx = find(this.micrographid==micrographid);

particles.position.x = this.position.x(idx);
particles.position.y = this.position.y(idx);
particles.micrographid = this.micrographid(idx);
particles.radius = this.radius(idx);

