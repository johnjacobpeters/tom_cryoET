function this = normalize(this)

set(this.figurehandle,'Units','normalized');

for c = 1:this.cols
    for r = 1:this.rows
        set(this.axeshandles,'Units','normalized');
    end
end