function tom_HT_createimageseriesdir(projectname,name)

settings = tom_HT_settings();

outputdir = [settings.data_basedir '/' projectname '/micrographs/' name];

[status,message] = mkdir(outputdir);
if status ~= 1
    error(message);
end

[status,message] = fileattrib(outputdir,'+w','u g');
if status ~= 1
    error(message);
end