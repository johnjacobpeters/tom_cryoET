function this = loadimages(this,imagedata,userdata)

if isempty(imagedata)
    return;
end

set(0,'CurrentFigure',this.figurehandle);

this.imagehandles = zeros(this.rows,this.cols);

l = 1;

datasize = size(imagedata,3);

for c = 1:this.cols
    for r = 1:this.rows
        set(this.figurehandle,'CurrentAxes',this.axeshandles(r,c));
        this.imagehandles(r,c) = imagesc(imagedata(:,:,l));
        axis off;
        colormap gray;
        set(gca,'UserData',userdata(l));
        set(gca,'ButtonDownFcn',this.leftcb);
        set(this.imagehandles(r,c),'ButtonDownFcn',this.leftcb);
        this = add_contextmenu(this,r,c);
        l = l + 1;
        if datasize < l
            break;
        end
    end
    if datasize < l
        break;
    end
end