function [this, width, height] = get_partsize(this)

units = get(this.axeshandles(1,1),'Units');
set(this.axeshandles(1,1),'Units','pixels');
pos = get(this.axeshandles(1,1),'Position');
width = pos(3);
height = pos(4);
set(this.axeshandles(1,1),'Units',units);