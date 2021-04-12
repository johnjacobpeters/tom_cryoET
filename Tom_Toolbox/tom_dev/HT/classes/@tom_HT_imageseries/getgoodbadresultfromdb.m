function this = getgoodbadresultfromdb(this,expid)

if ischar(expid)
    this.resultname = expid;
    setdbprefs('DataReturnFormat','numeric');
    expid = fetch(this.projectstruct.conn,['SELECT experiment_id FROM experiment WHERE name = ''' expid '''']);
    setdbprefs('DataReturnFormat','structure');
else
    res = fetch(this.projectstruct.conn,['SELECT name,description FROM experiment WHERE experiment_id = ''' num2str(expid) '''']);
    if ~isempty(res)
        this.resultname = res.name;
        this.description = res.description;
    end
end

if ~isempty(expid)
    this.resultid = expid(1);
end

if this.resultid ~= 0
    result = fetch(this.projectstruct.conn,['SELECT ris.goodbad FROM res_imageseriessort ris JOIN (results r,experiment e) ON (ris.results_result_id= r.result_id AND r.experiment_id=e.experiment_id) WHERE e.experiment_id = ' num2str(this.resultid)]);
    if ~isempty(result)
        this.goodbad = cell2mat(result.goodbad);
    else
        this.goodbad = ones(get_numberoffiles(this),1);
    end
    
end

