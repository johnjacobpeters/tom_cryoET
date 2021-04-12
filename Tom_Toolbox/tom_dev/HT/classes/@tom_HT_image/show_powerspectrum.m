function [this,ps_size] = show_powerspectrum(this,average)

this = calc_powerspectrum(this,average);

imagesc(log(this.powerspectrum'));axis off;axis ij;colormap gray;
ps_size = size(this.powerspectrum);