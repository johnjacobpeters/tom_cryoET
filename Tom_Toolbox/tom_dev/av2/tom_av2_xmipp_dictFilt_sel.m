function [stack,stackOrg]=tom_av2_xmipp_dictFilt_sel(f_sel,dict,dIdx,algParam,findWhat,replWith,appto,new_sel,verbose)
%tom_av2_xmipp_dictFilt_sel filters particles in .sel according 2 given dict
%
%   [stack,stackOrg]=tom_av2_xmipp_dictFilt_sel(f_sel,dict,dIdx,algParam,findWhat,replWith,appto,new_sel)
%
%  
%PARAMETERS
%
%  INPUT
%   f_sel         input sel,doc or stack in memory
%   dict          dictionary struct
%   dIdx          ('full') index defining which part of the dict is used
%   algParam      ('fromDict') alignment parameters from dict are used
%                            use '' for no alg
%                            use 'default' for defautl alg
%                  algParam.iter=[5 3];
%                  algParam.template=tmpl;
%                  algParam.mask=tom_sphermask(...)    
%
%   findWhat      ('') string to be replaced 
%   replWith      ('') rplacement str      
%   appto         ('lastFold') or 'fullPath'   
%   new_sel       ('') name of the new .sel file                     
%   buffSz        ('default')  uses 5GB of particles buffer sz in GB
%   verbose       (1) veobose  
%
%  INPUT
%   stack         filtered stack in memory
%   stackOrg      aligned org stack in memory
%
%EXAMPLE
%  
% [fstack,OrgStack]=tom_av2_xmipp_dictFilt_sel('It7_Cut.sel',dict,1:50);
%   
%
%REFERENCES
%
%SEE ALSO
%  
% tom_av2_xmipp_doc2dictionary
%
%  
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


if (nargin<3)
   dIdx='full'; 
end;

if (nargin<4)
   algParam='fromDict';
end;

if (nargin<5)
   findWhat='';
end;

if (nargin<6)
   replWith='';
end;

if (nargin<7)
   appto='lastFold';
end;

if (nargin<8)
   new_sel='';
end;

if (nargin<9)
   buffSz='default';
end;

if (nargin<10)
   verbose=1;
end;

if (strcmp(buffSz,'default'))
    buffSz=5;
end;

algParam=genAlgParamStruct(algParam,dict);
chunks=calcChunks(f_sel,buffSz);

if (length(chunks) > 1 && nargout > 0 )
    disp(['warinig stack and stackOrg in memory will only have length of the last chunk!!!!!' ]);
end;

for i=1:length(chunks)
    
    partNames=chunks{i};
    stack=readStack(partNames,verbose);
    if (isempty(algParam)==0)
        stack=tom_os3_alignStack2(stack,algParam.template,algParam.mask,[0 0],'mean0+1std','',algParam.iter);
    end;
    if (nargout > 1)
        stackOrg=stack;
    end;
    stack=tom_dict_filter(stack,dict,dIdx);
    
    if (isempty(findWhat)==0 && isempty(replWith)==0 && isempty(appto)==0 && isempty(new_sel)==0 )
        partNamesOut=adaptPartNames(partNames,findWhat,replWith,appto);
        writeStack(partNamesOut,stack,new_sel)
    end;
end;


function chunks=calcChunks(f_sel,buffSz)


if (isnumeric(f_sel)==0)
    sel=importdata(f_sel);
    sel=sel.textdata;
    tmpPart=tom_spiderread(sel{1});
    clear('tt');
    k=whos('tmpPart');
    chunkLength=(buffSz.*(1024.*1024.*1024))./k.bytes;
    [~,sizeStack]= unix(['cat ' f_sel ' |  wc -l ']);
    sizeStack=str2double(sizeStack);
    nrChunks=ceil(sizeStack./chunkLength);
    if (nrChunks==0)
        nrChunks=1;
    end;
    packages=tom_calc_packages(nrChunks,sizeStack);
    for i=1:size(packages,1)
        tmp=sel(packages(i,1):packages(i,2));
        chunks{i}=tmp;
    end;
else
   chunks{1}=f_sel;
end;





function algParam=genAlgParamStruct(algParam,dict)

if strcmp(algParam,'fromDict')
    if (isfield(dict,'algParam'))
        clear('algParam');
        algParam.template=[];
        algParam.template=reshape(dict.Mean,[dict.OrgSize(1) dict.OrgSize(2)]);
        algParam.mask=dict.algParam.mask;
        algParam.iter=[1 4];
    else
        algParam='';
    end;
end;

if strcmp(algParam,'default')
    algParam.template='sum';
    algParam.mask='default';
    algParam.iter=[5 3];
end;


function stack=readStack(chunk,verbose)

if (isnumeric(chunk)==0)
    if (verbose==1)
        disp('reading Stack');
    end;
    tmp=tom_spiderread(chunk{1});
    tmp=tmp.Value;
    stack=zeros(size(tmp,1),size(tmp,2),length(chunk));
    for i=1:length(chunk)
        tmp=tom_spiderread(chunk{i});
        stack(:,:,i)=tmp.Value;
    end;
else
    stack=chunk;
    clear('chunk');
end;
if (verbose==1)
     disp('done Reading Stack');
end;

function partNamesOut=adaptPartNames(partNames,findWhat,replWith,appto)

for i=1:length(partNames)
    if (strcmp(appto,'fullPath'))
        partNamesOut{i}=strrep(partNames{i},findWhat,replWith);
    else
        [foldername,filename,f_ext]=fileparts(partNames{i});
        new_fold_name=[foldername(1:max(strfind(foldername,'/'))-1 ) strrep([foldername(max(strfind(foldername,'/')):end) '/'],findWhat,replWith)];
        if(exist(new_fold_name,'dir')==0)
            mkdir(new_fold_name);
        end;
        partNamesOut{i}=[new_fold_name filename f_ext];  
    end;
    
end;

if (strcmp(appto,'fullPath'))
    new_fold_name=fileparts(partNamesOut{i});
    if(exist(new_fold_name,'dir')==0)
        mkdir(new_fold_name);
    end;
end;  


function writeStack(partNames,stack,fsel)

disp('writing data');

maskBg=tom_spheremask(ones(size(stack,1),size(stack,2)),floor(size(stack,1)./2))==0;

fid=fopen(fsel,'wt');
for i=1:length(partNames)
    tmp=tom_norm(stack(:,:,i),'mean0+1std',maskBg);
    tom_spiderwrite(partNames{i},tmp);
    fprintf(fid,'%s 1\n',partNames{i});
end;
fclose(fid);




