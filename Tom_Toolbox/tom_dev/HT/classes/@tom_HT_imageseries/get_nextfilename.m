function [this,filename,number] = get_nextfilename(this)

%first call in this object
if isempty(this.currentfile)
    this = get_fullfilenames(this);
    this.currentfile = 1;
else
    this.currentfile = this.currentfile + 1;
end


number = this.currentfile;
filename = this.fullfilenames(this.currentfile);

