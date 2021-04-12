function this = render_marks(this,data)

for c = 1:this.cols
    for r = 1:this.rows
        set(this.figurehandle,'CurrentAxes',this.axeshandles(r,c));
        if data(r,c) == true
            this.markhandles(r,c) = 0;
        else
            this.markhandles(r,c) = drawcross();
        end
    end
end





