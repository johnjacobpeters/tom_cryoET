function tom_av2_relion_align_stack(starfile,output_stack_name,output_struct_name,binning,filter_k,max_wrirte_chunk)
%TOM_AV2_RELION_ALIGN_STACk aligns particle stack according 2 a relion
%.star file
%
%  tom_av2_relion_align_stack(starfile,output_stack_name,output_struct_name,binning,filter_k)
%  
%  
%
%PARAMETERS
%
%  INPUT
%   starfile                         *.star filename use abs filename (... for further processing)
%   output_stack_name                name of output em stack
%   output_struct_name               name of the output struct name 
%   binning                          (0) binning of the images 
%   filter_k                         (0) filter kernel (for xxl datasets 
%                                                   ...its faster to pre filter the stack and switch off the filter in tom_av2_em_classify3d)
%   max_wrirte_chunk                 (250000) max num of part per chunk
%  
%  OUTPUT
%
%EXAMPLE
%     
%  tom_av2_relion_align_stack('/fs/pool/pool-nickell3/fb/4TomFocRel/sub.star','st_out.em','st_out.mat',[128 128]);
%
%
%REFERENCES
%
%SEE ALSO
%   tom_av2_em_classify3d
%
%   created by FB 11/02/16
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

if (nargin < 4)
    binning=0;
end;

if (nargin < 5)
    filter_k=0;
end;

if (nargin < 6)
    max_wrirte_chunk=80000;
end;



[a b c]=fileparts(starfile);

if (isempty(a) || strcmp(starfile(1),'/')==0 )
    answ=questdlg('Warning rel doc path used (use abs path!) Continue anyway ?');
    if (strcmp(answ,'Cancel') || strcmp(answ,'No'))
        return;
    else
        disp(['Warning rel doc path: ' starfile]);
    end;
end;


fprintf('%s ', 'reading star file...');
st=tom_starread(starfile);
fprintf('%s \n', ['...done! ' ]); 
st=addRef(st);
doc_st=st;



if (length(st) < max_wrirte_chunk)
    [stack_alg,st]=do_align(doc_st,binning,starfile,filter_k);
    st.split_part_stack{1}=output_stack_name;
    st.split_part_mat{1}=output_struct_name;
    tom_emwritec(output_stack_name,stack_alg,'standard','single');
    save(output_struct_name,'st');
else
   
    disp(['lenght stack: ' num2str(length(doc_st)) ' > ' num2str(max_wrirte_chunk) ' ==> splitting stack'  ])
    disp(' ');
    [f_base f_name f_ext]=fileparts(output_stack_name);
    
    if (isempty(f_base))
        f_base=pwd();
    end;
    packages=tom_calc_packages(ceil(length(doc_st)./max_wrirte_chunk),length(doc_st));
    for ip=1:size(packages,1)
        tmp_name=[f_base '/' f_name '_' num2str(ip) ];
        disp(['   stack alg ==> ' num2str(packages(ip,1)) ' to ' num2str(packages(ip,2)) ' ==> ' tmp_name] );
        [stack_alg,st]=do_align(doc_st(packages(ip,1): packages(ip,2)),binning,starfile,filter_k);
        tom_emwritec([tmp_name f_ext],stack_alg,'standard','single');
        save([tmp_name '.mat'],'st');
        tmp_st.split_part_stack{ip}=[tmp_name f_ext];
        tmp_st.split_part_mat{ip}=[tmp_name '.mat'];
        disp(' ');
        disp(' ');
    end;
    [euler_ang_zxz_proj,euler_ang_zyz_proj]=conv_angles(doc_st);
    tmp_st.euler_ang_zxz_proj=euler_ang_zxz_proj;
    tmp_st.euler_ang_zyz_proj=euler_ang_zyz_proj;
    tmp_st.doc_name=st.doc_name;
    st=tmp_st;
    save(output_struct_name,'st');
end;

function st=addRef(st)

num_of_entries=size(st,1);


for i=1:num_of_entries
    allRef{i}=[num2str(round(st(i).rlnAngleRot)) '-' num2str(round(st(i).rlnAngleTilt))];
    st(i).ref=-1;
end;    
allRefU=unique(allRef);

for i=1:length(allRefU)
    idx=find(ismember(allRef,allRefU(i)));
    for ii=1:length(idx)
        st(idx(ii)).ref=i;
    end;
end;


function [euler_ang_zxz_proj,euler_ang_zyz_proj]=conv_angles(st)

num_of_entries=size(st,1);


% for i=1:num_of_entries
%     allRef{i}=[num2str(round(st(i).rlnAngleRot)) '-' num2str(round(st(i).rlnAngleTilt))];
%     st(i).ref=-1;
% end;    
% allRefU=unique(allRef);
% 
% for i=1:length(allRefU)
%     idx=find(ismember(allRef,allRefU(i)));
%     for ii=1:length(idx)
%         st(idx(ii)).ref=i;
%     end;
% end;

euler_ang_zxz=zeros(num_of_entries,3);
euler_ang_zyz=zeros(num_of_entries,3);


euler_ang_zxz_proj=zeros(max([st(:).ref]),3);
euler_ang_zyz_proj=zeros(max([st(:).ref]),3);

waitbar=tom_progress(num_of_entries,'transforming angles: ');
for i=1:num_of_entries
    ref_nr(i)=st(i).ref;
    [xx,angles] = tom_eulerconvert_xmipp(st(i).rlnAngleRot, st(i).rlnAngleTilt, st(i).rlnAnglePsi);
    euler_ang_zxz(i,:)=angles;
    euler_ang_zyz(i,:)=[st(i).rlnAngleRot, st(i).rlnAngleTilt, st(i).rlnAnglePsi];
    [aa tttemp]=tom_eulerconvert_xmipp(st(i).rlnAngleRot,st(i).rlnAngleTilt, 0);
    euler_ang_zxz_proj(st(i).ref,:)=tttemp;
    euler_ang_zyz_proj(st(i).ref,:)=[st(i).rlnAngleRot st(i).rlnAngleTilt 0];
    waitbar.update();
    part_names{i}=st(i).rlnImageName;
end;
waitbar.close;







function [stack_alg,st]=do_align(st,binning,starName,filter_k)


fprintf('%s ', ['Converting Angles: ' ]);

num_of_entries=size(st,1);


% for i=1:num_of_entries
%     allRef{i}=[num2str(round(st(i).rlnAngleRot)) '-' num2str(round(st(i).rlnAngleTilt))];
%     st(i).ref=-1;
% end;    
% allRefU=unique(allRef);
% 
% for i=1:length(allRefU)
%     idx=find(ismember(allRef,allRefU(i)));
%     for ii=1:length(idx)
%         st(idx(ii)).ref=i;
%     end;
% end;

euler_ang_zxz=zeros(num_of_entries,3);
euler_ang_zyz=zeros(num_of_entries,3);


euler_ang_zxz_proj=zeros(max([st(:).ref]),3);
euler_ang_zyz_proj=zeros(max([st(:).ref]),3);

waitbar=tom_progress(num_of_entries,'transforming angles: ');
for i=1:num_of_entries
    ref_nr(i)=st(i).ref;
    [xx,angles] = tom_eulerconvert_xmipp(st(i).rlnAngleRot, st(i).rlnAngleTilt, st(i).rlnAnglePsi);
    euler_ang_zxz(i,:)=angles;
    euler_ang_zyz(i,:)=[st(i).rlnAngleRot, st(i).rlnAngleTilt, st(i).rlnAnglePsi];
    [aa tttemp]=tom_eulerconvert_xmipp(st(i).rlnAngleRot,st(i).rlnAngleTilt, 0);
    euler_ang_zxz_proj(st(i).ref,:)=tttemp;
    euler_ang_zyz_proj(st(i).ref,:)=[st(i).rlnAngleRot st(i).rlnAngleTilt 0];
    waitbar.update();
    part_names{i}=st(i).rlnImageName;
end;
waitbar.close;

%tmp=euler_ang_zxz_proj(1:max(ref_nr));
%euler_ang_zxz_pro=tmp;





try
    particleTmp=readParticle(st(1).rlnImageName,'');
    path_flag='rel_man';
catch ME
    particleTmp=readParticle(st(1).rlnImageName,'');
    path_flag='abs_man';
end
sz_org=size(particleTmp);

if (max(size(binning))==1 )
    particleTmp=tom_bin(particleTmp,binning);
else
    particleTmp=imresize(particleTmp,binning);
end;
sz_rs=size(particleTmp);



error_idx=zeros(num_of_entries,1);


if (isempty(gcp))
    pool.NumWorkers=1;
else
    pool=gcp;
end
packages=tom_calc_packages(pool.NumWorkers,num_of_entries);
warning off; mkdir('XXXtmpTomFocXXX'); warning on;

parfor i=1:size(packages,1)
 %for i=1:size(packages,1)  
    idx=packages(i,1):packages(i,2);
    alignPartWorker(st(idx),euler_ang_zyz(idx,:),binning,filter_k,sz_org,sz_rs,'XXXtmpTomFocXXX',i);
end;

stack_alg=[];
waitbar=tom_progress(size(packages,1),'combining chunks: ');
for i=1:size(packages,1)
    tmpChunk=tom_emread(['XXXtmpTomFocXXX' filesep 'chunk_' num2str(i) '.em']);
    stack_alg=cat(3,stack_alg,tmpChunk.Value);
    waitbar.update();
end;
warning off; rmdir('XXXtmpTomFocXXX','s'); warning on;
waitbar.close;

disp([num2str(length(find(error_idx==1)) ) ' errors in alignment!']);

stOrg=st;

clear('st');

st.ref_nr=ref_nr';
st.euler_ang_zxz=euler_ang_zxz;
st.euler_ang_zyz=euler_ang_zyz;
st.euler_ang_zxz_proj=euler_ang_zxz_proj;
st.error_idx=error_idx;
st.part_names=part_names;
st.doc_name=starName;
st.euler_ang_zyz_proj=euler_ang_zyz_proj;
st.pre_filter_k=filter_k;
st.orgList=stOrg;

   
function alignPartWorker(st,euler_ang_zyz,binning,filter_k,orgImgSize,imgSize,tmpFold,packNr)

num_of_entries=length(st);

if (packNr==1)
    fprintf('%s ', ['Allocating Memory: ' ]);
end;

stack_alg=zeros(imgSize(1),imgSize(2),num_of_entries,'single');

if (packNr==1)
    fprintf('%s \n','done!');
    waitbar=tom_progress(num_of_entries,'Aligning Stack: ');
end;


cache='';
for i=1:num_of_entries
    
    try
        [im.Value,cache]=readParticle(st(i).rlnImageName,cache);
        part_names{i}=st(i).rlnImageName;
    catch ME
        disp(['Error: cannot read file: ' tmp_name ' ' ME.message ]);
        im.Value=rand(sz_org(1),sz_org(2));
        error_idx(i)=1;
    end;
    
    if (max(size(binning))==1 )
        im.Value=tom_bin(im.Value,binning);
    else
        im.Value=imresize(im.Value,binning);
    end;
    
    im.Value=tom_norm(im.Value,'mean0+1std');
    
    if (max(size(binning))==1 )
        tmp_sh=[st(i).rlnOriginX st(i).rlnOriginY]./(2^binning);
    else
        tmp_sh=[st(i).rlnOriginX st(i).rlnOriginY]./(orgImgSize(1)./binning(1));
    end;
    
    im_tmp_alg=tom_rotate(tom_shift(im.Value,tmp_sh), euler_ang_zyz(i,3));
    
    
    if (filter_k > 0)
        stack_alg(:,:,i)=single(tom_filter(im_tmp_alg,filter_k));
    else
        stack_alg(:,:,i)=single(im_tmp_alg);
    end;
    
    if (packNr==1)
        waitbar.update();
    end;
end;
if (packNr==1)
    waitbar.close;
end;

tom_emwrite([tmpFold filesep 'chunk_' num2str(packNr) '.em'],stack_alg);




function [particle,cache]=readParticle(entryName,cache)

[posInMrcStack,mrcStackName]=strtok(entryName,'@');
posInMrcStack=str2double(posInMrcStack);
mrcStackName=strrep(mrcStackName,'@','');

if (isempty(cache))
    cache.mrcStackName=mrcStackName;
    tmp=tom_mrcread(mrcStackName);
    cache.data=tmp.Value;
end;

if (strcmp(cache.mrcStackName,mrcStackName)==0)
    cache.mrcStackName=mrcStackName;
    tmp=tom_mrcread(mrcStackName);
    cache.data=tmp.Value;
end

particle=cache.data(:,:,posInMrcStack);






