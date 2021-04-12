function [this,particle] = get_lastparticle(this,micrograph,binning)

[this,particle] = getparticles(this,micrograph,this.radius(this.currentparticle),this.currentparticle,binning);