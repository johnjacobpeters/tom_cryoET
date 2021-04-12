function this = writeemstack(this,stackname,binning)

if nargin > 2
    binning = 0;
end

if nargin > 1
    this.stackname = stackname;
end

radius = this.radius(end)*2;

settings = tom_HT_settings();

filename = [settings.data_basedir '/particles/' stackname];
tom_emwritec(filename,[radius radius this.numparticles],'new','single');

l = 1;

for micrographid=1:length(this.micrographid)
    idx = find(this.micrographid==micrographid);

    if ~isempty(idx)
        [this,stack] = getparticles(this,micrograph,radius,idx,binning);
        tom_emwritec(outstackname,particle,'subregion',[1 1 lauf],[size(particle,1) size(particle,2) 1]);
        stacksize = size(stack,3);
        tom_emwritec(filename,'subregion',[1 1 l],[radius radius stacksize]);
        l = l + stacksize;
    end
end

