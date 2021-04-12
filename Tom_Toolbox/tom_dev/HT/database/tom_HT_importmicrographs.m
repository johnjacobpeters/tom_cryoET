function tom_HT_importmicrographs(projectstruct,dirname,seriesid,waitbarflag)

if nargin < 4
    waitbarflag = 0;
end

dircell = tom_HT_getdircontents(dirname,{'em'},waitbarflag);


result = fetch(projectstruct.conn,['SELECT name FROM micrograph_groups WHERE micrographgroup_id = ''' num2str(seriesid) '''']);

settings = tom_HT_settings();
outputdir = [settings.data_basedir '/' projectstruct.projectname '/micrographs/'];
maxfilename = tom_HT_getmaxfilenumber([outputdir '/' result.name{1}]);

set(projectstruct.conn,'AutoCommit','off');

numfiles = size(dircell,2);
filetransactionslist = cell(numfiles);

%if waitbarflag == 1
%    h = waitbar(0,'Importing micrographs...');
%end

fraction = ceil(numfiles./100);

for i=1:numfiles
    filename = [dirname '/' dircell{i}];
    outfilename = [result.name{1} '/' num2str(i+maxfilename) '.em'];
    try
        info = tom_HT_getimageparameters(filename,waitbarflag);
        tom_HT_copyfile(filename,'micrograph',projectstruct.projectname,outfilename);
        filetransactionslist{i} = outfilename;
        fastinsert(projectstruct.conn,'micrographs',{'micrograph_groups_micrographgroup_id','filename','Dz_nominal','dose','stagepos_x','stagepos_y','stagepos_z','objectpixelsize','date'},{seriesid,outfilename,info.Dz_nominal,info.dose,info.stagepos.x,info.stagepos.y,info.stagepos.z,info.objectpixelsize,info.date});
    catch
        warning('An error has occured, rolling back insert...');
        rollback(projectstruct.conn);
        for j=1:length(filetransactionslist)
            if ~isempty(filetransactionslist{j})
                delete([outputdir '/' filetransactionslist{j}]);
            end
        end
        tom_HT_showlasterror();
        break;
    end
    if waitbarflag == 1 && mod(i,fraction) == 0
        %waitbar(i./numfiles,h,[num2str(i), ' of ', num2str(numfiles), ' files imported.']);
        tom_HT_waitbar(i./numfiles, [num2str(i), ' of ', num2str(numfiles), ' files imported.']);
    end
end

commit(projectstruct.conn);
set(projectstruct.conn,'AutoCommit','on');

%if waitbarflag == 1
%    close(h);
%end
tom_HT_waitbar(1,'Finished.');