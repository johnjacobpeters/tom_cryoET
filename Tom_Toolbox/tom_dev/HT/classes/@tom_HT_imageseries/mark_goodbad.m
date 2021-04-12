function [this,data] = mark_goodbad(this,micrographid,data)

if nargin < 4
    redrawflag = false;
end

idx = find(this.micrographids == micrographid);

if ischar(data) && strcmp(data,'toggle') == 1
    if this.goodbad(idx) == true
        data = false;
    else
        data = true;
    end
end
    
this.goodbad(idx) = data;

