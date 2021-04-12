function  tom_HT_copy_files_ln(base_path,new_path,flag)
%
%example: 
%

dd=dir(base_path);

zz=1;
for i=3:length(dd)
    if (isnan(str2double(dd(i).name))==0)
        fold_names{zz}=dd(i).name;
        zz=zz+1;
    end;
end;


zz=1;
for i=1:length(fold_names)
    dd=dir([base_path '/' fold_names{i}]);
    for ii=3:length(dd)
        if (dd(ii).isdir)
            if (strfind(dd(ii).name,flag))
                dd2=dir([base_path '/' fold_names{i} '/' dd(ii).name]);
                for iii=3:length(dd2)
                    if (tom_isemfile([base_path '/' fold_names{i} '/' dd(ii).name '/' dd2(iii).name]) )
                        str{zz}=['ln -s ' base_path '/' fold_names{i} '/' dd(ii).name '/' dd2(iii).name ' ' new_path num2str(zz) '.em' ];
                        zz=zz+1;
                    end;
                end;
            
                
            end;
        end;
    end;
end;

save([new_path 'protocol.mat'],'str');

for i=1:length(str)
    disp(str{i});
    unix(str{i});
end;

disp('end');

