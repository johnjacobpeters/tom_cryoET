function this = layout(this,width,height,rows,cols)

if isempty(this.figurehandle)
    this.figurehandle = figure('Units','pixels','Position',[50 50 width height+30],'Toolbar','none','Menubar','none');
end

this.rows = rows;
this.cols = cols;

axeswidth = floor(width ./ cols);
axesheight = floor(height ./ rows);

this.axeshandles = zeros(rows,cols);


for c = 1:cols
    for r = 1:rows
        left = (c-1) .* axeswidth;
        bottom = (rows - r) .* axesheight;
        this.axeshandles(r,c) = axes('Units','pixels','Position',[left bottom+30 axeswidth axesheight]);
        axis off;
        axis image;
    end
end
this.slider = uicontrol('Style', 'slider', 'Min',0,'Max',1,'Position', [5 5 width-150 20], 'Callback', '');
this.textbox = uicontrol('Style','text','Position',[width-140 5 135 20],'String','');

this.imagehandles = zeros(this.rows,this.cols);