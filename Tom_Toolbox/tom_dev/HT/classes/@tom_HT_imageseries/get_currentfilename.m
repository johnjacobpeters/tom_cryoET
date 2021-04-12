function [this,filename,fullfilename] = get_currentfilename(this)

if isempty(this.fullfilenames)
    this = get_fullfilenames(this);
end

fullfilename = this.fullfilenames{this.currentfile};
filename = this.filenames{this.currentfile};