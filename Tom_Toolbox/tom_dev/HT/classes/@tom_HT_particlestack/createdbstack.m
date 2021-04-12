function this = createdbstack(this,name,comment)

fastinsert(this.projectstruct.conn,'particle_groups',{'name','description','date','radius'},{name,comment,datestr(now),32});
result = exec(this.projectstruct.conn,'SELECT LAST_INSERT_ID() AS lastid');
lastid = fetch(result);
fastinsert(this.projectstruct.conn,'particle_groups_has_projects',{'particle_groups_partgroup_id','projects_project_id'},{lastid.Data.lastid,this.projectstruct.projectid})
this.stackid = lastid.Data.lastid;