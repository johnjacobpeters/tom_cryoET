function tom_HT_addjavapath()

settings = tom_HT_settings();
tmp_j_path=javaclasspath;

if (isempty(find(ismember(tmp_j_path,[settings.code_basedir 'java/TableSorter.jar']))))
    javaaddpath([settings.code_basedir 'java/TableSorter.jar']);
end;
if (isempty(find(ismember(tmp_j_path,settings.db.jdbc_connector))))
    javaaddpath(settings.db.jdbc_connector);
end;