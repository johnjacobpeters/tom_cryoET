function this = redraw_mark(this,data,r,c)

if data == true
    if this.markhandles(r,c) ~= 0
        delete(this.markhandles(r,c));
        this.markhandles(r,c) = 0;
    end
else
    set(this.figurehandle,'CurrentAxes',this.axeshandles(r,c));
    this.markhandles(r,c) = drawcross();
end
