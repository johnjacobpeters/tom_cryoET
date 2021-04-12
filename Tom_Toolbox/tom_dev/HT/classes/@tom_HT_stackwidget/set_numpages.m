function this = set_numpages(this,numpages)

set(this.slider,'Min',1,'Max',numpages,'Value',1,'SliderStep',[1./(numpages-1) 1./(numpages-1)]);
set(this.textbox,'String',['1 of ' num2str(numpages)]);

this.numpages = numpages;