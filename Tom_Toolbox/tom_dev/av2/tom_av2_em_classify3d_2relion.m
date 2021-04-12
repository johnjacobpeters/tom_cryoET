function tom_av2_em_classify3d_2relion(cl_structName,outputFolder)
%TOM_AV2_EM_CLASSIFY3D_2RELION creates a .star file from 
%   
%
%  tom_av2_em_classify3d_2xmipp2(cl_struct,outputFolder)
%
%  
%
%PARAMETERS
%
%  INPUT
%
%  cl_structName          output form 
%  outputFolder            folder for data output
%
%  OUTPUT
%
%EXAMPLE
%  
%  %builds sel and doc for all classes and dumps it 2 xmipp_run1
%  tom_av2_em_classify3d_2relion('runCl4R1maskUbp6_18_2/data/part_st.mat','runCl4R1maskUbp6_18_2/relion');
%
%
%
%
%REFERENCES
%
%SEE ALSO
%  
% 
%
%   created by FB 08/09/09
%
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom



warning off;
mkdir(outputFolder);
warning on;

%load master
part_st_master=load(cl_structName);
part_st_master=part_st_master.st;

relion_star=part_st_master.doc_name;
class_nr=1:part_st_master.num_of_classes;
disp(['Found : ' num2str(part_st_master.num_of_classes) ' classes']);


for i=1:length(class_nr)
    all_path_out{i}=[outputFolder filesep 'classNr_' num2str(class_nr(i)) '.star'];
 end;

fprintf('%s',['reading ' relion_star]);
list=tom_starread(relion_star);
fprintf('%s \n',' ...done!');


disp(['Found ' num2str(length(list)) ' particles in '  num2str(length(part_st_master.split_part_mat)) ' chunk(s)']);
disp(' ');

all_doc='';
for ii=1:length(class_nr)
     ch_count=1;
     disp(['Processing Class nr ' num2str(class_nr(ii))]); 
    for i_chunk=1:length(part_st_master.split_part_mat)
        part_st=load(part_st_master.split_part_mat{i_chunk});
        part_st=part_st.st;
        disp(['  Processing Chunk nr ' num2str(i_chunk) ' (iter: ' num2str(size(part_st.class,1)) ')' ]);
        class_count=0;
        listSub=list(ch_count:(ch_count+length(part_st.ref_nr)-1));
        new_list=listSub;
        classes=part_st.class(size(part_st.class,1),:);
        for i=1:size(part_st.class,2)
            if (isempty(find(class_nr(ii)==classes(i),1))==0)
                class_count=class_count+1;
                new_list(class_count)=listSub(i);
             end;
        end;
        all_list{i_chunk,ii}=new_list(1:class_count);
        ch_count=ch_count+length(part_st.ref_nr);
    end;
end;
clear('new_list');

disp('Merge Chunks');
for i=1:length(class_nr)
    list_tmp='';
    for i_chunk=1:length(part_st_master.split_part_mat)
        list_tmp=cat(1,list_tmp,all_list{i_chunk,i});
    end;
    list_tmp(1).Header=list(1).Header;
   
    disp(['  writing '  all_path_out{i} ' (' num2str(length(list_tmp)) ' parts)' ]);
    tom_starwrite(all_path_out{i},list_tmp);
    
end;
disp('done!');





