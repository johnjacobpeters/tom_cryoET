function this = clearall(this)

set(0,'CurrentFigure',this.figurehandle);

for c = 1:this.cols
    for r = 1:this.rows
        cla(this.axeshandles(r,c));
    end
end

this.imagehandles = zeros(this.rows,this.cols);