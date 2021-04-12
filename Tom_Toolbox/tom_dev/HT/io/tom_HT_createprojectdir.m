function tom_HT_createprojectdir(dir_name)


dirs = {'mtfs','references','masks','particles','micrographs','symmetryfiles','mat-files','xmipp','pdfs'};

settings = tom_HT_settings();

[success,message] = mkdir([settings.data_basedir '/' dir_name]);
if success ~= 1
    error(['Could not create directory ' settings.data_basedir '/' dir_name ': ' message]);
end


for directory = dirs;
    [success,message] = mkdir([settings.data_basedir '/' dir_name '/' directory{1}]);
    if success ~= 1
        error(['Could not create directory ' settings.data_basedir '/' dir_name '/' directory ': ' message]);
    end
end