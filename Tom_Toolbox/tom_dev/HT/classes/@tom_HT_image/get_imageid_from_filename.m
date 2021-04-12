function id = get_imageid_from_filename(this,micrographname)

result = fetch(this.projectstruct.conn,['SELECT micrograph_id FROM micrographs WHERE filename = ''' micrographname '''']);

id = result.micrograph_id;