function result = tom_HT_getimageseriesresults(projectstruct,seriesid)

if ischar(seriesid)
    setdbprefs('DataReturnFormat','numeric');
    seriesid = tom_HT_getimageseriesid_from_name(projectstruct,seriesid);
    setdbprefs('DataReturnFormat','structure');
end

result = fetch(projectstruct.conn,['SELECT DISTINCT e.experiment_id,e.name FROM res_imageseriessort ris JOIN (results r, experiment e) ON (ris.results_result_id=r.result_id AND r.experiment_id=e.experiment_id) WHERE ris.micrograph_groups_micrographgroup_id = ' num2str(seriesid)]);

