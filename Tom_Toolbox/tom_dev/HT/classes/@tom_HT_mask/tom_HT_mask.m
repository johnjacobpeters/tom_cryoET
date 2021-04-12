function this = tom_HT_mask(sizex,sizey,projectstruct)

if nargin == 3
    this.projectstruct = projectstruct;
else
    this.projectstruct = '';
end
this.filename = '';
this.size.x = sizex;
this.size.y = sizey;
this.name = '';
this.description = '';
this.mask = ones(sizex,sizey,'single');
this.maskid = 0;
this.params = struct();
this = class(this,'tom_HT_mask');



