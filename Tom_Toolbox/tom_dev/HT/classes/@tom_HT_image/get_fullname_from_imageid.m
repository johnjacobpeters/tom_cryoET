function fullname = get_fullname_from_imageid(this,micrographid)

result = fetch(this.projectstruct.conn,['SELECT filename FROM micrographs WHERE micrograph_id = ' num2str(micrographid)]);

settings = tom_HT_settings();

fullname = [settings.data_basedir,'/',this.projectstruct.projectname,'/micrographs/' result.filename{1}];