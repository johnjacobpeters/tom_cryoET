function this = tom_HT_particlestack(projectstruct)

this.projectstruct = projectstruct;
this.radius = [];
this.particles = [];
this.position.x = [];
this.position.y = [];
this.micrographid = [];
this.particleid = [];
this.numparticles = 0;
this.currentparticle = [];
this.stackid = 0;
this.emstackname = '';

this = class(this,'tom_HT_particlestack');