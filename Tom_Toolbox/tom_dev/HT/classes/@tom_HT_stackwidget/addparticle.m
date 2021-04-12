function this = addparticle(this,data,userdata)

if nargin < 3
    userdata =[];
end

set(0,'CurrentFigure',this.figurehandle);

x = 0;
for c = 1:this.cols
    for r = 1:this.rows
        if this.imagehandles(r,c) == 0
            set(this.figurehandle,'CurrentAxes',this.axeshandles(r,c));
            this.imagehandles(r,c) = imagesc(data);
            axis off;
            colormap gray;
            set(gca,'UserData',[userdata,r,c]);
            set(gca,'ButtonDownFcn',this.leftcb);
            set(this.imagehandles(r,c),'ButtonDownFcn',this.leftcb);
            this = add_contextmenu(this,r,c);
            x = 1;
            break;
        end
    end
    if x == 1
        break;
    end
end
