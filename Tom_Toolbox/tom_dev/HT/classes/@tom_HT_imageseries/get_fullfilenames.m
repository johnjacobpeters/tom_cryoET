function [this,filenames] = get_fullfilenames(this)

if isempty(this.fullfilenames)
    settings = tom_HT_settings();
    this.fullfilenames = cellfun(@(x)strcat(settings.data_basedir,'/',this.projectstruct.projectname,'/micrographs/',x),this.filenames,'UniformOutput',0);
end

filenames = this.fullfilenames;
