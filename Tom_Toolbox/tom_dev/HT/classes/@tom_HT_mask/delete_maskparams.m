function this = delete_maskparams(this,idx)

if idx == length(this.params)
    this.params = this.params(1:end-1);
else

    for i=idx:length(this.params)-1
        this.params(i).vals = this.params(i+1).vals;
        this.params(i).name = this.params(i+1).name;
    end

end