function [icon,colormap] = tom_HT_geticon(iconname,size)

settings = tom_HT_settings();

[icon,colormap] = imread([settings.code_basedir '/icons/' num2str(size) '/' iconname '.png'],'png');