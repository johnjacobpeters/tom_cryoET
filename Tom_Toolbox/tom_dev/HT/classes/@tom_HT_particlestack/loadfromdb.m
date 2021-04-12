function [this,radius] = loadfromdb(this,stackid)

if ischar(stackid)
    stackid = get_stackid_from_name(this,stackid);
end
setdbprefs('DataReturnFormat','numeric');
radius = fetch(this.projectstruct.conn,['SELECT radius FROM particle_groups WHERE partgroup_id = ' num2str(stackid)]);

result = fetch(this.projectstruct.conn,['SELECT p.particle_id, p.pos_x, p.pos_y, p.micrographs_micrograph_id  from particles p JOIN particles_has_particle_groups php ON php.particles_particle_id = p.particle_id WHERE particle_groups_partgroup_id = ' num2str(stackid)]);
setdbprefs('DataReturnFormat','structure');

if ~isempty(result)
    this.numparticles = size(result,1);
    this.particleid = result(:,1)';
    this.position.x = result(:,2)';
    this.position.y = result(:,3)';
    this.micrographid = result(:,4)';
    this.radius = zeros(this.numparticles,1)+radius;
end

this.stackid = stackid;