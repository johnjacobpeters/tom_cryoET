function this = tom_HT_image(projectstruct)

this.projectstruct = projectstruct;
this.image = [];
this.stat = [];
this.header = [];
this.origsize = [];
this.powerspectrum = [];
this.ps_average = 1;
this.micrographid = 0;

this = class(this,'tom_HT_image');