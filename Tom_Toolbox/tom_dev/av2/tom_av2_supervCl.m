function stCl=tom_av2_supervCl(trainGood,trainBad,partList,usePs,defocusGr,errorStopCrit,maxPatchSize)
%TOM_AV2_SUPERVCL performs a supervised classificaion on a given pickList a trainingsSet or a trained classifier must be provided
%                  
%  classVectAll=tom_av2_supervCl(trainGood,trainBad,partList,rad,szRealStack,usePs,szPsStack,maskPs,defList)
%
%PARAMETERS
%
%  INPUT
%   trainGood           pickList good particles or path to saved classifier
%   trainBad            pickList bad  particles or 'use_saved_cl'
%   partList            pickList or wildcard  which should be classified
%   usePs               (1)
%   defocusGr           ('') for no defocus groups
%                       'ctffind3-G3' for ctffind3 files 
%   errorStopCrit       (1) training is stopped if error is smaller
%   maxPatchSize        (400) max patch for initial part extraction
%   
%
%
%  OUTPUT
%   classVectAll        vector containing the classification result         
%
%EXAMPLE
%  
%  %remove Carbon with tom-pickLists without ctfGroups K2 data
%    tom_av2_particlepickergui('/fs/pool/pool-titan1/HWTF3/data/001_20150728_f22/0_micrographs/Falcon_2015*.mrc'); 
%    stCl=tom_av2_supervCl('ice.mat','carbon.mat','rawList.mat');
%    
%
%  %remove Carbon with tom-pickLists with 2 ctfGroups F2/3 and ccd data
%    %1 generate a filefilter for a ctf equla subset
%    tom_av2_ecqDefSubSet('/fs/pool/pool-titan1/HWTF3/data/001_20150728_f22/0_micrographs/Falcon_2015_*_ctffind3.log');
%    %2 generate 2 pickLists ice.mat and carbon.mat 
%    tom_av2_particlepickergui('/fs/pool/pool-titan1/HWTF3/data/001_20150728_f22/0_micrographs/Falcon_2015*.mrc');
%    % load fileiflter in tom_av2_particlepickergui
%    %classify rawList.mat
%    stCl=tom_av2_supervCl('ice.mat','carbon.mat','rawList.mat',1,'ctffind3-G2');
%  
% %remove Carbon with a pre trained classifyer
%   stCl=tom_av2_supervCl('/fs/pool/pool-bmsan-apps/app_data/tom/carbRemove/CL_F3_PixS1.4_D60e.mat','use_saved_cl','F3/test/org.mat');
%
%
%NOTE
% 
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 11/24/14
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
     usePs=1;
end;

if (nargin < 5)
    defocusGr='';
end

if (nargin < 6)
    errorStopCrit=1;
end

if (nargin < 7)
    maxPatchSize=400;
end




if (strcmp(trainBad,'use_saved_cl'))
    load(trainGood)
else
    
    plGood=load(trainGood);plGood=plGood.align2d;
    plGood=tom_av2_removeItem_align(plGood,'position','off');
    plBad=load(trainBad);plBad=plBad.align2d;
    plBad=tom_av2_removeItem_align(plBad,'position','off');
    
    if (strcmp(defocusGr,''))
        ctfGroups='';
        plGoodTmp=plGood;
        plBadTmp=plBad;
        clear('plGood','plBad');
        plGood{1}=plGoodTmp;
        plBad{1}=plBadTmp;
    else
        [ctfProgram,nrCtfGroups]=parseCtfGroupsFlag(defocusGr);
        ctfGroups=genDefocusGroups(plGood,ctfProgram,nrCtfGroups);
        plGood=splitPickListbyDefocus(plGood,ctfGroups);
        plBad=splitPickListbyDefocus(plBad,ctfGroups);
    end;
    
    for i=1:length(plGood)
        clStruct{i}=trainClassifier(plGood{i},plBad{i},maxPatchSize,usePs,errorStopCrit);
        clStruct{i}.ctfGroups=ctfGroups;
    end;

end;


d=dir(partList);
if (isempty(d))
    error([partList ' not found!']);
end;

bp=fileparts(partList);
if (isempty(bp))
    bp='.';
end;

stCl.classVect='';
stCl.OrgpickList='';
for i=1:length(d)
    pl=load([bp filesep d(i).name]);
    pickList=pl.align2d;
    pickList=tom_av2_removeItem_align(pickList,'position','<',1); 
    if (isempty(clStruct{i}.ctfGroups))
        pickListTmp=pickList;
        clear('pickList');
        pickList{1}=pickListTmp;
    else
        pickList=splitPickListbyDefocus(pickList,clStruct{i}.ctfGroups); 
    end;
    
    for idef=1:length(pickList)
        classVect{idef}=clsssifyDataSet(clStruct{idef},pickList{idef});
        [listGood{idef},listBad{idef}]=splitPickListbyClass(pickList{idef},classVect{idef});
    end;
    stCl=wirteOutput(listGood,listBad,bp,d(i).name,classVect,clStruct);
end;


function pickListSplitted=splitPickListbyDefocus(pickList,ctfGroups)

defocus=extractDefocusfromPickList(pickList,ctfGroups.ctfProgram); 

grouNr=zeros(length(defocus),1);
for i=1:length(defocus)
   [minVal,minPos]=min(abs([ctfGroups.cent-defocus(i)]));
   groupNr(i)=minPos;
end;

for i=1:length(ctfGroups.cent)
    idx=find(groupNr==i);
    pickListSplitted{i}=pickList(1,idx);
end;





function ctfGroups=genDefocusGroups(pickList,ctfProgram,nrCtfGroups)


defocus=extractDefocusfromPickList(pickList,ctfProgram); 

[groupVect,cent]=kmeans(unique(defocus),nrCtfGroups);
ctfGroups.cent=sort(cent);
ctfGroups.ctfProgram=ctfProgram;
ctfGroups.nrCtfGroups=nrCtfGroups;





function defocus=extractDefocusfromPickList(pickList,ctfProgram)

if (strcmp(ctfProgram,'ctffind3'))
    for i=1:size(pickList,2)
        imgPl{i}=pickList(1,i).filename;
        ctfPl{i}=strrep(pickList(1,i).filename,'.mrc','_ctffind3.log');
    end;
    imgU=unique(imgPl);
    ctfPlU=unique(ctfPl);
    checkFiles(imgU,'pickList');
    checkFiles(ctfPlU,'transformed pickList (.mrc ==> _ctffind3.log)' );
    ctfVals=tom_av2_ctffind_parselog(ctfPlU);
end;

defocus=zeros(size(pickList,2),1);
for i=1:length(imgU)
    idxPl=find(ismember(imgPl,imgU{i}));
    logFileName=strrep(imgU{i},'.mrc','_ctffind3.log');
    idxdefList=ismember(ctfVals(:,1),logFileName);
    def=unique(ctfVals{idxdefList,2});
    if (length(def)>1)
        error('imageNames not unique!!');
    end;
    defocus(idxPl)=def;
end;


function checkFiles(list,name)

for i=1:length(list)
    if (exist(list{i},'file')==0)
        disp(['check ' name]);
        error(['file ' list{i} ' from ' name  ' not found!']);
    end;
end;

function [stackGoodBad,groupsGoodBad,fNamesGoodBad]=catStacks(stackTrainGood,stackTrainGoodFnames,stackTrainBad,stackTrainBadFnames)

stackGoodBad=cat(3,stackTrainGood,stackTrainBad);
groupsGoodBad=zeros(size(stackGoodBad,3),1);
groupsGoodBad(1:size(stackTrainGood,3))=1;
fNamesGoodBad=cat(2,stackTrainGoodFnames,stackTrainBadFnames);
clear('stackTrainGood','stackTrainBad');


function clStruct=trainClassifier(trainGood,trainBad,patchSize,usePs,errorStopCrit)


[stackTrainGood,stackTrainGoodFnames]=pickList2Stack(trainGood,patchSize,usePs);
[stackTrainBad,stackTrainBadFnames]=pickList2Stack(trainBad,patchSize,usePs);

[stackGoodBad,groupsGoodBad,fNamesGoodBad]=catStacks(stackTrainGood,stackTrainGoodFnames,stackTrainBad,stackTrainBadFnames);

disp('********************');
disp('Training started!');
disp(' ');


param=genParameterSet(patchSize.*0.6,'initial');
tic;
parfor i=1:length(param)
%for i=1:length(param)
  result{i}=trainWorker(stackGoodBad,groupsGoodBad,fNamesGoodBad,param{i},i);
end;
toc;
for i=1:length(result)
    corssVal_error(i)=result{i}.error;
    usedPatchSize(i)=result{i}.preCut(1);
end;
[errTmp,b]=min(corssVal_error);
idxTmp=find(corssVal_error==errTmp);
minPatch=min(usedPatchSize(idxTmp));
idxOpt=find([(corssVal_error==errTmp).*(usedPatchSize==minPatch)]);
b=idxOpt(1);
errTmp=corssVal_error(b);



disp(['Selected settings ' num2str(b) ' for classification with an error of ' num2str(corssVal_error(b).*100) ]);

if ((errTmp*100) >= errorStopCrit)
    
    param=genParameterSet(patchSize,param{b});
    tic;
    parfor i=1:length(param)
        result{i}=trainWorker(stackGoodBad,groupsGoodBad,fNamesGoodBad,param{i},i);
    end;
    toc;
    for i=1:length(result)
        corssVal_error(i)=result{i}.error;
    end;
    [~,b]=min(corssVal_error);
    disp(['Selected settings ' num2str(b) ' for classification with an error of ' num2str(corssVal_error(b).*100) ]);
    
end;

maskRad=round(result{b}.maskDiameter./2);
sz=result{b}.preCut;
maskTmpPsBig=tom_spheremask(ones(sz(1),sz(2)),maskRad(2));
maskTmpPsSmall=tom_spheremask(ones(sz(1),sz(2)),maskRad(1))==0;
maskPs=maskTmpPsBig.*maskTmpPsSmall;

clStruct.svmStruct=result{b}.svmStruct;
clStruct.maskPs=maskPs;
clStruct.patchSize=patchSize;
clStruct.rescale=result{b}.rescale;
clStruct.preCut=result{b}.preCut;
clStruct.usePs=usePs;

disp('Training done!');
disp('********************');
disp(' ');

function param=genParameterSet(patchSize,flag)

if (strcmp(flag,'initial'))
    preCut=[1 0.7 0.5];
    rescale=[0.85 0.65];
    maskDiameter=[0.8 0.6 0.5];
    zz=1;
    for iC=preCut
        for iRs=rescale
            for iMD=maskDiameter
                param{zz}.preCut=round(iC.*patchSize);
                param{zz}.rescale=round(iRs.*param{zz}.preCut);
                
                if (mod(param{zz}.rescale,2)==1)
                    param{zz}.rescale=param{zz}.rescale+1;
                end;
                param{zz}.maskDiameter=round([0 iMD.*param{zz}.preCut]);
                param{zz}.svmKernel='linear';
                zz=zz+1;
            end;
        end;
    end;
end;

if (isstruct(flag))
    
    preCut=flag.preCut;
    rescale=flag.rescale;
    maskDiameter2=[flag.maskDiameter(2)./1.3 flag.maskDiameter(2) flag.maskDiameter(2).*1.3];
    maskDiameter1=[0 4 8];
    zz=1;
    for id1=maskDiameter1
        for id2=maskDiameter2
            param{zz}.preCut=preCut;
            param{zz}.rescale=rescale;
            if (mod(param{zz}.rescale,2)==1)
                param{zz}.rescale=param{zz}.rescale+1;
            end;
            param{zz}.maskDiameter=round([id1 id2]);
            param{zz}.svmKernel='linear';
            zz=zz+1;
        end;
    end;
    
end;



function classVect=clsssifyDataSet(clStruct,partList)


maxNr=15000;


nrPack=ceil(round(size(partList,2))./maxNr);
packages=tom_calc_packages(nrPack,size(partList,2));

for i=1:size(packages,1)
    disp(['classify package ' num2str(i) ' of ' num2str(size(packages,1)) ]);
    idx=packages(i,1):packages(i,2);
    classVect(idx)=classifySubSet(partList(1,idx),clStruct);
end;


disp('done!')


function classVect=classifySubSet(partList,clStruct)


stack=pickList2Stack(partList,clStruct.patchSize,clStruct.usePs);
stack=single(stack);
sz=size(stack);
stack=tom_cut_out(stack,'center',[clStruct.preCut sz(3)]);
stack=tom_reshape_stack_memory(stack,clStruct.rescale,clStruct.maskPs,'no_norm','insideMask');
poolSt=gcp;
if (isempty(poolSt)==0)
    packages=tom_calc_packages(poolSt.NumWorkers,sz(3));
else
    packages=tom_calc_packages(1,sz(3));
end;

parfor i=1:size(packages,1)
    if (isfield(clStruct,'svmStruct'))
        idxtmp=packages(i,1):packages(i,2);
        classVectTmp{i}=predict(clStruct.svmStruct,stack(:,idxtmp)');
    end;
end;
classVect=[];
for i=1:length(classVectTmp)
    classVect=cat(1,classVect,classVectTmp{i});
end;




function [listGood,listBad]=splitPickListbyClass(partList,classVect)


idxGood=find(classVect==1);
idxBad=find(classVect==0);

listGood=partList(1,idxGood);
listBad=partList(1,idxBad);

disp(['size good: ' num2str(length(idxGood)) ' of ' num2str(size(partList,2)) ]);
disp(['size bad: ' num2str(length(idxBad)) ' of ' num2str(size(partList,2)) ]);

disp('done!');


function result=trainWorker(stack,groups,fnames,param,i)

preCut=[param.preCut param.preCut];
rescale=[param.rescale param.rescale];
maskRad=round(param.maskDiameter./2);
svmKernel=param.svmKernel;
stack=tom_cut_out(stack,'center',[preCut size(stack,3)]);
sz=size(stack);

train2TestRatio=0.7;

maskTmpPsBig=tom_spheremask(ones(sz(1),sz(2)),maskRad(2));
maskTmpPsSmall=tom_spheremask(ones(sz(1),sz(2)),maskRad(1))==0;
maskPs=maskTmpPsBig.*maskTmpPsSmall;

stack=tom_reshape_stack_memory(stack,rescale,maskPs,'no_norm','insideMask');

for iTry=1:3
    splitVect=splitTrainTestByFileName(groups,fnames,train2TestRatio);
    idxTr=find(splitVect==0);
    svmStruct=fitcsvm(stack(:,idxTr)',groups(idxTr),'KernelFunction',svmKernel,'OutlierFraction',0.04,'KernelScale','auto');
    idxTest=find(splitVect==1);
    resVectTest=predict(svmStruct,stack(:,idxTest)');
    inVectTest=groups(idxTest);
    tmpErrorAll(iTry)=length(find((resVectTest-inVectTest)))./length(resVectTest);
end;


%CVSVMModel4CrossVal = crossval(svmStruct,'Holdout',0.3);
%tmpError=kfoldLoss(CVSVMModel4CrossVal);

stdError=std(tmpErrorAll);
tmpError=mean(tmpErrorAll);

if (isnumeric(tmpError))
    strError=num2str(tmpError.*100);
    strstdError=num2str(stdError.*100);
else
    strError=tmpError;
    tmpError=Inf;
end;

result.error=tmpError;
result.maskRad=maskRad;
result.preCut=preCut;
result.rescale=rescale;
result.svmStruct=svmStruct;
result.svmKernel=svmKernel;
result.maskDiameter=param.maskDiameter;

disp([num2str(i) ': CrossVal error: ' strError '(std:' num2str(strstdError) ') ' '% boxSz ' num2str(preCut)  ' PsSize: ' num2str(result.rescale) ' maskRad: ' num2str(result.maskRad) ' kernel: ' result.svmKernel]);

function splitVect=splitTrainTestByFileName(groups,fnames,train2TestRatio)

splitVect=zeros(length(fnames),1);

fnamesGoodUnique=unique(fnames(groups==1));
fnamesBadUnique=unique(fnames(groups==0));
[fnamesTrainGood,fnamesTestGood]=splitTrainTest(fnamesGoodUnique,train2TestRatio);
[fnamesTrainBad,fnamesTestBad]=splitTrainTest(fnamesBadUnique,train2TestRatio);

testNames=cat(2,fnamesTestGood,fnamesTestBad);

idxTest=[];
for i=1:length(testNames)
    idx=find(ismember(fnames,testNames{i}));
    idxTest=cat(2,idxTest,idx);
end;
splitVect(idxTest)=1;


function [fnamesTrain,fnamesTest]=splitTrainTest(fnames,train2TestRatio)

trainEnd=round((length(fnames).*train2TestRatio));
rv=randperm(length(fnames));
rvTrain=rv(1:trainEnd);
rvTest=rv((trainEnd+1):end);
fnamesTrain=fnames(rvTrain);
fnamesTest=fnames(rvTest);


function stCl=wirteOutput(listGoodGr,listBadGr,listBasePaht,fileName,classVectGR,clStruct)

disp(' ');

[a,b,c]=fileparts(fileName);

if strcmp(c,'.mat')
    
    listGood='';
    listBad='';
    classVect='';
    for iGr=1:length(listGoodGr)
        listGood=cat(2,listGood,listGoodGr{iGr});
        listBad=cat(2,listBad,listBadGr{iGr});
    end;
    
    for i=1:size(listGood,2)
        listGood(1,i).class='good';
        listGood(1,i).color=[0 1 0];
    end;
    for i=1:length(classVectGR)
        classVect=cat(2,classVect,classVectGR{i});
    end;
    
    align2d=listGood;
    
    disp(['writing good to ' listBasePaht filesep b '-good' c]);
    save([listBasePaht filesep b '-good' c],'align2d','-v7.3');
    disp(['writing bad to ' listBasePaht filesep b '-bad' c]);
    
    for i=1:size(listBad,2)
        listBad(1,i).class='bad';
        listBad(1,i).color=[1 0 0];
    end;
    align2d=listBad;
    save([listBasePaht filesep b '-bad' c],'align2d','-v7.3');
    align2d=cat(2,listGood,listBad);
    save([listBasePaht filesep b '-good-bad' c],'align2d','-v7.3');
    tom_av2_align_reorg([listBasePaht filesep b '-good-bad' c],[listBasePaht filesep b '-good-bad' c]);
    stCl.classVect{i}=classVect;
    stCl.OrgpickList{i}=fileName;
    save([listBasePaht filesep b '-classifyer' c],'clStruct');
end;

    
function [stack,filenames,nrImg]=pickList2Stack(pickList,patchSize,usePs)     


if (isstruct(pickList))
    plTmp=pickList;
else
    [~,~,ext]=fileparts(pickList);
    
    if (strcmp(ext,'.mat'))
        plTmp=load(pickList);
        plTmp=plTmp.align2d;
    end;
    
    disp(' ');
    disp('==================================');
    disp(['extracting particles from: ' pickList]);
    disp('==================================');
    disp(' ');
    
end;

rad=round(patchSize(1)./2);

boxSize=round(patchSize(1).*0.6);
if (mod(boxSize,2)==1)
    boxSize=boxSize+1;
end;

stack=tom_av2_xmipp_picklist2stack(plTmp,'','',rad,'gradient&mean0+1std',0,[boxSize boxSize]);
for i=1:size(plTmp,2)
    filenames{i}=plTmp(1,i).filename;
end;

nrImg=length(unique(filenames));

if (usePs)
    psStack=zeros(size(stack));
    for i=1:size(stack,3)
        tmp=log(tom_ps(stack(:,:,i)));
        if (size(tmp,1)~=boxSize)
            tmp=tom_rescale(tmp,[boxSize boxSize]);
        end;
        psStack(:,:,i)=tmp;
    end;
    stack=psStack;
end;


function [ctfProgram,nrGroups]=parseCtfGroupsFlag(flag)

[ctfProgram,nrGroups]=strtok(flag,'-');
nrGroups=str2double(strrep(nrGroups,'-G',''));


function test=catPl(dd,bp)

verbose=1;
load([bp '/' dd(1).name]);

test=align2d;

for i=2:length(dd)
   
    load([bp '/' dd(i).name]);
   
    if (size(align2d,2)>0)
        test=cat(2,test,align2d);
    else
        disp(['warnig ' dd(i).name ' is empty']);
    end;
    
    if (mod(i,100)==0)
        if (verbose > 0)
            disp([num2str(i) ' lists loaded']);
        end;
    end;
end;
