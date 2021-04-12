function this = saveobj(this)

settings = tom_HT_settings();


if this.maskid ~= 0
    
else
    fastinsert(this.projectstruct.conn,'masks',{'filename','name','description','date','size_x','size_y'},{this.filename,this.name,this.description,datestr(now),this.size.x,this.size.y});
end

this.projectstruct.conn = [];