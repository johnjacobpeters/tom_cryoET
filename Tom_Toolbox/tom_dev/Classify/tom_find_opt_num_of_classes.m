function [optNumOfClasses,scoreVsNumOfClasses,clustRes,AlingRes]=tom_find_opt_num_of_classes(dataset,interv,evalMethod,cluster_function,cleanUpStd,cluster_params,disp_flag)
%TOM_FIND_OPT_NUM_OF_CLASSES finds the optimal number of classes
%
%   [dists_a,num_of_classes]=tom_find_opt_num_of_classes(dataset,interv,cluster_function,cluster_params,verbose)
%
%PARAMETERS
%
%  INPUT
%   dataset                      matrix with observations and featurers 
%                                      if a Aling filen is given the coordinates are
%                                      extracted
%   interv                         (2:20) amount of classes which is scanned
%   evalMethod               ('silhouette') or 
%   cluster_function        ('k-means') 
%   cluster_params          ('')  
%   cleanUpStd                (2.5) 
%   verbose                      (1)
%  
%  OUTPUT
%   optNumOfClasses     optimal number of classes
%   scoreVsNumOfClasses		   scoreVsNumOfClasses
%   clustRes
%   AlingClust
%   AlingNoClust
% 
%EXAMPLE
%  
%[optNumOfClasses,score,clustRes]= tom_find_opt_num_of_classes(data,[2:12]);
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by ... (author date)
%   updated by ...
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


if nargin < 2
    interv = 1:20;
end

if nargin < 3
    evalMethod = 'silhouette';
end

if nargin < 4
    cluster_function ='k-means';
end

if nargin < 5
    cleanUpStd=0.5;
end

if nargin < 6
    cluster_params=[];
end

if nargin < 7
    verbose=1;
end

if (ischar(dataset))
    dataset=load(dataset);
end;

if (isstruct(dataset))
    for i=1:size(dataset.Align,2)
        tmp(i,1)=dataset.Align(1,i).Tomogram.Position.X;
        tmp(i,2)=dataset.Align(1,i).Tomogram.Position.Y;
        tmp(i,3)=dataset.Align(1,i).Tomogram.Position.Z;
    end;
    AlgnIn=dataset.Align;
    dataset=tmp;
    clear('tmp');
end;

zz=1;
for i=interv
    
    %cluster it
    if (strcmp(cluster_function,'k-means'))
         [allClasses{zz} centriod{zz},sum_dist,dists{zz}] = kmeans(dataset,i);
    end;
    classes=allClasses{zz};
    %calc mean dist
    if (strcmp(evalMethod,'silhouette'))
        silh=silhouette(dataset,classes);
        m_sh=mean(silh);
        scoreVsNumOfClasses(zz,1)=i;
        scoreVsNumOfClasses(zz,2)=m_sh;
    end;
    zz=zz+1;
end;


%opt num of classes
[~,ind]=max(scoreVsNumOfClasses(:,2));
optNumOfClasses=scoreVsNumOfClasses(ind,1);


classesOpt=allClasses{ind};
allGood=[];
for i=1:optNumOfClasses
    idxCl=find(classesOpt==i);
    members=dataset(idxCl,:);
    [idxGood,centPos{i}]=refineCluster(members,cleanUpStd);
    idxAllGood{i}=idxCl(idxGood);
    allGood=cat(1,allGood, idxAllGood{i});
    clustRes.cluster(i).clustMembers=dataset(idxAllGood{i},:);
    clustRes.cluster(i).clustCenter=centPos{i};
end;
allGood=sort(allGood);

clustRes.clustMembers=dataset(allGood,:);
clustRes.NotClustMembers=dataset(find(ismember(1:size(dataset,1),allGood)==0),:);



if (verbose==1)
    disp(['opt nr of classes is: ' num2str(optNumOfClasses)]);
    figure; plot(scoreVsNumOfClasses(:,1),scoreVsNumOfClasses(:,2),'b-');
    hold on; plot(scoreVsNumOfClasses(:,1),scoreVsNumOfClasses(:,2),'ro');
    hold on; plot(scoreVsNumOfClasses(ind,1),scoreVsNumOfClasses(ind,2),'g+');
    title('classNr vs score');
    
    if (size(dataset,2)==2)
        figure; plot(dataset(:,1),dataset(:,2),'ro');
        hold on; plot(dataset(allGood,1),dataset(allGood,2),'b+');
        for i=1:length(centPos)
            plot(centPos{i}(1),centPos{i}(2),'c*');
        end;
    end;
    if (size(dataset,2)==3)
        figure; plot3(dataset(:,1),dataset(:,2),dataset(:,3),'ro');
        hold on; plot3(dataset(allGood,1),dataset(allGood,2),dataset(allGood,3),'b+');
        for i=1:length(centPos)
            plot3(centPos{i}(1),centPos{i}(2),centPos{i}(3),'c*');
        end;
    end;

end;



disp(' ');


function [idxUsed,cent]=refineCluster(members,nstd)

membersOrg=members;
idxUsed=1:size(members,1);

for i=1:3
    %cent=[mean(members(idxUsed,1)) mean(members(idxUsed,2))];
    cent=mean(members);
    diff= members-repmat(cent,size(members,1),1);
    diff=sqrt(sum(diff.*diff,2));
    diffStd=std(diff);
    diffMean=mean(diff);
    bound=diffMean+(nstd.*diffStd);
    idxUsed=find(diff<bound);
end;

disp(' ');


