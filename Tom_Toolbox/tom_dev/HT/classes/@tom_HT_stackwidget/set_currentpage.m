function this = set_currentpage(this,pageno)

set(this.textbox,'String',[num2str(pageno) ' of ' num2str(this.numpages)]);