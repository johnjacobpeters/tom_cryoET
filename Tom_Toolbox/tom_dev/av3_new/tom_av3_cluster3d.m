function tom_av3_cluster3d(particleBuffer,numOfClasses,outpufolder,numIter,lpf,seeds,seedsWedge,learnRate)


dpart=dir([particleBuffer filesep 'parts' filesep '*.*']);
dwedge=dir([particleBuffer filesep 'wedge' filesep '*.*']);

zz_part=0;
zz_wedge=0;
for i=1:length(dpart)
    if (dpart(i).isdir==0)
        zz_part=zz_part+1;
        particleList{zz_part}=[particleBuffer filesep 'parts' filesep dpart(i).name];
    end;
    if (length(dwedge) >= i)
        if (dwedge(i).isdir==0)
            zz_wedge=zz_wedge+1;
            wedgeList{zz_wedge}=[particleBuffer filesep 'wedge' filesep dwedge(i).name];
        end;
    end;
end;
if (zz_wedge==0)
    wedgeList='';
end;

numOfParts=length(particleList);

if (isempty(seeds))
    classVect=genInitialClassVect(numOfClasses,numOfParts);
    %classVect=[1:3 1:3 1:3 1:3 1:3 1:3 1:3 1:3 1:3 1:3];
    %classVect=cat(2,classVect,classVect,classVect);
    [seeds,seedsWedge]=genClassAverages(classVect,particleList,wedgeList,learnRate(1));
    writeCents(outpufolder,seeds,seedsWedge,0,lpf);
    
end;

%run ExMax

for i=1:numIter
    disp(['processing ' num2str(i)]);
    
    classVect=classify(particleList,wedgeList,seeds,seedsWedge,lpf);
    
    [seeds,seedsWedge]=genClassAverages(classVect,particleList,wedgeList,learnRate(i));
    writeCents(outpufolder,seeds,seedsWedge,i,lpf);
    dispStat(classVect);
end;

function dispStat(classVect)

u_classVect=unique(classVect);

for i=1:length(u_classVect)
    nr(i)=length(find(classVect==u_classVect(i)));
end;
disp(nr);



function writeCents(outputfolder,CentVols,CentWedges,iterNum,lpf)

if (exist(outputfolder,'dir')==0)
    mkdir(outputfolder);
end;
masklp=tom_spheremask(ones(size(CentVols{1})),lpf(1),lpf(2));
for i=1:length(CentVols)
    if (isempty(CentWedges))
         centWei=CentVols{i};
    else
        weiTmp= wedgeSum2weightFun(CentWedges{i});
        centWei=tom_apply_weight_function(CentVols{i},weiTmp.*masklp);
    end;
    tom_emwrite([outputfolder '/it' num2str(iterNum) '_cl_' num2str(i) '.em'],centWei);
end;


function v=genInitialClassVect(numOfClasses,numOfParts)

%v=randi(numOfClasses,1,numOfParts)';
%  for i=1:numOfParts
%     v(i)=randi(numOfClasses);
%  end;

packages=tom_calc_packages(numOfClasses,numOfParts);
v=[];
for i=1:size(packages,2)
    tmp=repmat(i,1,packages(i,3));
    v=cat(2,v,tmp);
end;
v=v(randperm(numOfParts));

disp(' '); 

function [CentVols,CentWedges]=genClassAverages(classVect,particleList,wedgeList,learnRate)

uclasses=unique(classVect);

for i=1:length(uclasses)
    partIdx=find(classVect==uclasses(i));
    CentVols{i}=averageList(particleList(partIdx));
    if (isempty(wedgeList))
        CentWedges='';
    else
        CentWedges{i}=averageList(wedgeList(partIdx));
        CentWedges{i}=tom_filter(CentWedges{i},2);
    end;
end;
CentVols=applyLearnRate(CentVols,learnRate);
if isempty(wedgeList)==0
    CentWedges=applyLearnRate(CentWedges,learnRate);
end;

function volsWei=applyLearnRate(vols,rate)


for i=1:length(vols)
    idx=find(ismember(1:length(vols),i)==0);
    tmp=zeros(size(vols{1}));
    for ii=1:length(idx);
        tmp=tmp+(vols{idx(ii)}.*rate);
    end;
    volsWei{i}=tmp+vols{i};
end;


function classVect=classify(particleList,wedgeList,CentVols,CentWedges,lpf)

part_tmp=tom_emreadc(particleList{1});
part_tmp=part_tmp.Value;
masklp=tom_spheremask(ones(size(part_tmp)),lpf(1),lpf(2));
maskrs=tom_spheremask(ones(size(part_tmp)),round(size(part_tmp,1)./2)-2,2);

for i=1:length(particleList)
   
    parttmp=tom_emreadc(particleList{i});
    parttmp=parttmp.Value;
    if (isempty(wedgeList))
        wedgetmp='';
    else
        wedgetmp=tom_emreadc(wedgeList{i});
        wedgetmp=wedgetmp.Value;
    end;
    
    for ii=1:length(CentVols)
        if (isempty(CentWedges)==0 )
            partWei=tom_apply_weight_function(parttmp,CentWedges{ii}.*masklp).*maskrs;
        else
            partWei=parttmp;
        end;
        if (isempty(wedgetmp)==0 )
            centWei=tom_apply_weight_function(CentVols{ii},wedgetmp.*masklp).*maskrs;
        else
            centWei=CentVols{ii};
        end;
        
        ccf=tom_corr(partWei,centWei,'norm',maskrs);
        [pos,val]=tom_peak(ccf);
        valtmp(ii)=val(1);
        postmp(ii,:)=pos(1,:);
    end;
    [~,tmpcl]=max(valtmp);
    classVect(i)=tmpcl(1);
    alltmp(:,i)=valtmp;
end;
disp(' ');

function avg=averageList(particleList)

avg=tom_emread(particleList{1});
avg=avg.Value;
for i=2:length(particleList)
    volTmp=tom_emread(particleList{i});
    avg=avg+volTmp.Value;
end;
avg=avg./i;

function wedge=wedgeSum2weightFun(wedge)

wedge = 1./wedge;
rind = find(wedge > 1000);
wedge(rind) = 0;% take care for inf
wedge=tom_filter(wedge,2);
mask=tom_spheremask(ones(size(wedge)),round(size(wedge,1)./2)-4,3);





