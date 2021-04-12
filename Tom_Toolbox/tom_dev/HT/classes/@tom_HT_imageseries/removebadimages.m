function this = removebadimages(this)

if ~isempty(this.goodbad)
    
    this.filenames = this.filenames(this.goodbad);
    if ~isempty(this.fullfilenames) 
        this.fullfilenames = this.fullfilenames(this.goodbad);
    end
    this.micrographids = this.micrographids(this.goodbad);
    this.goodbad = nonzeros(this.goodbad);  
end