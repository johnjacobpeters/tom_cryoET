function this = savegoodbadtodb(this)

set(this.projectstruct.conn,'AutoCommit','off');

numrows = length(this.goodbad);
fraction = ceil(numrows./100);


%new experiment
if this.resultid == 0 || this.resultid == -1
    fastinsert(this.projectstruct.conn,'experiment',{'name','date','description','experiment_types_experiment_type_id'},{this.resultname,datestr(now),this.description,this.experimenttypeid});
    exec(this.projectstruct.conn,'SET @expid = LAST_INSERT_ID()');
    for i=1:numrows
        exec(this.projectstruct.conn,['INSERT INTO results (experiment_types_experiment_type_id,experiment_id) VALUES (' num2str(this.experimenttypeid) ',@expid)']);
        exec(this.projectstruct.conn,'SET @resid = LAST_INSERT_ID()');
        exec(this.projectstruct.conn,['INSERT INTO res_imageseriessort (results_result_id,micrograph_groups_micrographgroup_id,micrographs_micrograph_id,goodbad) VALUES (@resid,' num2str(this.micrographgroupid) ',' num2str(this.micrographids(i)) ',' num2str(this.goodbad(i)) ')']);
        exec(this.projectstruct.conn,'INSERT INTO results_has_experiment (results_result_id,experiment_id) VALUES (@resid,@expid)');
        if mod(i,fraction) == 0
           tom_HT_waitbar(i./numrows, [num2str(i), ' of ', num2str(numrows), ' rows saved.']);
        end   
    end
%update experiment
else
    if ischar(this.description)
        this.description = {this.description};
    end
    update(this.projectstruct.conn,'experiment',{'description','date'},{[this.description{:}],datestr(now,'yyyy-mm-dd HH:MM:SS')},['WHERE experiment_id = ' num2str(this.resultid)]);
    wherestring = cell(length(this.goodbad),1);
    for i=1:numrows
        wherestring{i} = ['WHERE micrographs_micrograph_id=' num2str(this.micrographids(i))];
    end
    update(this.projectstruct.conn,'res_imageseriessort',{'goodbad'},double(this.goodbad),wherestring);
end

commit(this.projectstruct.conn);
set(this.projectstruct.conn,'AutoCommit','on');
tom_HT_waitbar(1,'Finished.');