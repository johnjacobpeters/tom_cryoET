function savetodb(this)

settings = tom_HT_settings();

if this.maskid ~= 0
    
else
    maxno = tom_HT_getmaxfilenumber([settings.data_basedir '/' this.projectstruct.datadir '/masks/']);
    this.filename = [num2str(maxno + 1) '.mat'];
end

mask = this; 
save([settings.data_basedir '/' this.projectstruct.datadir '/masks/' this.filename],'mask');

