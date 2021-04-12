function infotext = get_infotext(this)

if isempty(this.stat)
    this = calcstats(this);
end

infotext{1} = ['Size: ' num2str(this.origsize(1)) ' x ' num2str(this.origsize(2))];
infotext{2} = ['Microscope: ' this.header.Microscope{1}];
infotext{3} = ['Voltage: ' num2str(this.header.Voltage./1000) ' kV'];
infotext{4} = ['Objectpixelsize: ' num2str(this.header.Objectpixelsize./10) ' nm'];
infotext{5} = ['intended defocus:' num2str(this.header.Defocus./10000) ' \mu m'];
infotext{6} = ['[min max mean std var]'];
infotext{7} = ['[' num2str(this.stat.min) ' ' num2str(this.stat.max) ' ' num2str(round(this.stat.mean)) ' ' num2str(round(this.stat.std)) ' ' num2str(round(this.stat.variance)) ']'];