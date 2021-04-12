function [this,stack,idx] = getparticles_frommicrograph(this,micrographid,micrograph,binning)

idx = find(this.micrographid==micrographid);

if ~isempty(idx)
    radius = this.radius(idx(1));
    [this,stack] = getparticles(this,micrograph,radius,idx,binning);
    idx = this.particleid(idx);
else
    stack = [];
    idx = [];
end