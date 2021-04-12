function info = getinfo(this,idx)

idx = find(this.particleid == idx);

info.idx = idx;
info.particleid = this.particleid(idx);
info.micrographid = this.micrographid(idx);
info.position.x =  this.position.x(idx);
info.position.y = this.position.y(idx);
info.stackid = this.stackid;

