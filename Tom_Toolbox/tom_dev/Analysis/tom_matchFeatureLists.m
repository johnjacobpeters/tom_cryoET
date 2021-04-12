function [idxMatchedPair,allDistPair,idxMatchedFull,idxUnMatchedRef,idxUnMatchedComp,idxOverMatchedComp]=tom_matchFeatureLists(refList,compList,maxDist,verbose,dispFlag)
%TOM_MATCHFEATURELISTS matches oberservations within a certain distance
%
%   [matchIdx,]=tom_matchFeatureLists(listCell,dist)
%
%PARAMETERS
%
%  INPUT
%   refList            reference list
%   compList           lists to be matched with reference
%   maxDist            max distance
%   verbose            (0) use 1 to switch ont 
%   dispFlag           (0) 0: no display
%                          1: plot points and pairs
%                          2: plot hirachical clustering 
%                          3: plot all
%
%  OUTPUT
%   idxMatchedPair         pairs found between ref and comp within maxDist
%                             1st row corresponds to matched ref idx
%                             2nd row corresponds to matched comp idx
%   allDistPair            distance vector for pairs
%   idxMatchedFull         clusters found between ref and comp within maxDist 
%   idxunMatchedRef        references wit no matching entry in comp
%   idxunMatchedComp       comp with no matching entry in ref  
%   idxoverMatchedComp     entries in comp which have
%                          (1) smaller distance to a ref than maxDist   
%                          (2) a neibour comp entrie which is closer to the same ref point    
%
%EXAMPLE
%  
% %example 2d 
% refList=[-1.5 -1.5; 2 2;4 4; 0 0];
% compList=[2.2 2.2; 4 3.5; 0 0.5; 5 5; 0.15 0.15];
%
% [idxMatchedPair,allDistPair,idxMatchedFull,idxUnMatchedRef,idxUnMatchedComp,idxOverMatchedComp]=tom_matchFeatureLists(refList,compList,1,1,3);
%
% %example 3d 
% refList=[-1.5 -1.5 1; 2.2 2.2 2.2;4 4 2; 0 0 1];
% compList=[2 2 2; 4 3.5 0; 0 0.5 2; 5 5 1; 0.15 0.15 1];
%
% [idxMatchedPair,allDistPair,idxMatchedFull,idxUnMatchedRef,idxUnMatchedComp,idxOverMatchedComp]=tom_matchFeatureLists(refList,compList,2,1,3);
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 02/25/15
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


if (nargin<4)
    verbose=0;
end;

if (nargin<5)
    dispFlag=0;
end;

tmpList=cat(1,refList,compList);
tmpDist=pdist(tmpList);
tree=linkage(tmpDist,'single');
classVect = cluster(tree,'cutoff',maxDist,'criterion','distance');

[idxMatchedPair,allDistPair,idxMatchedFull,idxOverMatchedComp,idxUnMatchedRef,idxUnMatchedComp]=getMatches(tree,classVect,size(refList,1),tmpDist);
if (isempty(idxMatchedPair)==0)
    [idxMatchedPair,allDistPair,idxMatchedFull]=sortPairIdx(idxMatchedPair,allDistPair,idxMatchedFull);
end;

plotResults(compList,refList,tree,maxDist,idxMatchedPair,idxOverMatchedComp,idxUnMatchedRef,idxUnMatchedComp,dispFlag);
dispText(allDistPair,idxMatchedPair,idxOverMatchedComp,idxUnMatchedRef,idxUnMatchedComp,refList,compList,verbose);




function [idxMatchedPair,allDistPair,idxMatchedFull,overMatchedComp,unMatchedRef,unMatchedComp]=getMatches(tree,classVect,lenRef,allDist)

classesU=unique(classVect);

allDist=squareform(allDist);


zzFull=1;
zzPair=1;
zzOver=1;
zzUnRef=1;
zzUnComp=1;

idxMatchedPair=[];
allDistPair=[];
idxMatchedFull=[];
overMatchedComp=[];
unMatchedRef=[];
unMatchedComp=[];


for i=1:length(classesU)
   idxTmp=find(classVect==classesU(i));
   
   if (length(idxTmp)==1)
       if (idxTmp<=lenRef)
          unMatchedRef(zzUnRef)=idxTmp;
          zzUnRef=zzUnRef+1;
       else
          unMatchedComp(zzUnComp)=idxTmp-lenRef;
          zzUnComp=zzUnComp+1;
       end;
       continue;
   end;
   
   [idxMatchedFull,zzFull]=getFullIndex(idxTmp,lenRef,zzFull);
   
   if (length(idxTmp)>2)
        refIdx=idxTmp(find(idxTmp<=lenRef));
        if (length(refIdx)>1)
            error('inter Reference Cluster are not implemented !!');
        end;
        [idxTmp,overMatchedComp]=getSmallestDistAndRest(allDist,refIdx,idxTmp,overMatchedComp,lenRef);
   end;
   
   lineNr=find((tree(:,1)==idxTmp(1))+(tree(:,1)==idxTmp(1)));
   idxTmpTrans=idxTmp(find(idxTmp>lenRef))-lenRef;
   idxMatchedPair(zzPair,:)=[idxTmp(find(idxTmp<=lenRef)) idxTmpTrans];
   allDistPair(zzPair)=allDist(idxTmp(1),idxTmp(2));
   zzPair=zzPair+1;
   
end;

function [idxMatchedFull,zzFull]=getFullIndex(idxTmp,lenRef,zzFull)

idxTmpTrans=idxTmp(find(idxTmp>lenRef))-lenRef;
refIdx=idxTmp(find(idxTmp<=lenRef));
if (length(refIdx)>1)
    error('inter Reference Cluster are not implemented !!');
end;

idxMatchedFull{zzFull}=[refIdx idxTmpTrans'];
zzFull=zzFull+1;

function [idxTmp,overMatchedComp]=getSmallestDistAndRest(allDist,refIdx,idxTmp,overMatchedComp,lenRef)


idxTmpOrg=idxTmp;
dTmp=ones(length(idxTmp),1)*Inf;
for i=1:length(idxTmp)
    if (idxTmp(i)==refIdx)
        continue;
    end;
    dTmp(i)=allDist(refIdx,idxTmp(i));
   
end;
[~,idx]=min(dTmp);
idxTmp=[refIdx idxTmp(idx)];

overMatchedComp=cat(1,overMatchedComp,idxTmpOrg(find(ismember(idxTmpOrg,idxTmp)==0))-lenRef );


function dispText(allDistPair,idxMatchedPair,idxOverMatchedComp,idxUnMatchedRef,idxUnMatchedComp,refList,compList,verbose)

if (verbose==1)
    disp(['matched: ref ' num2str(round(size(idxMatchedPair,1)./size(refList,1).*100))  ' % of ref' ' meanDist ' num2str(mean(allDistPair)) ]);
    disp(['unmatched: ref ' num2str(round(length(idxUnMatchedRef)./size(refList,1).*100))  ' % of ref']);
    disp(['overmatched: comp ' num2str(round(length(idxOverMatchedComp)./size(compList,1).*100))  ' % of comp' ]);
    disp(['unmatched: comp ' num2str(round(length(idxUnMatchedComp)./size(compList,1).*100))  ' % of comp' ]);
end;



function plotResults(compList,refList,tree,maxDist,idxMatchedPair,idxOverMatchedComp,idxUnMatchedRef,unMatchedComp,dispFlag)


if (dispFlag==2 ||dispFlag==3 )
    figure; dendrogram(tree,size(tree,1)+1,'ColorThreshold',maxDist);
end;

if (dispFlag==1 ||dispFlag==3 )
    figure;
    if (size(compList,2)==2)
        for i=1:size(idxMatchedPair,1)
            %plot pairs
            hold on;
            zz=1;
            gh{zz}=plot(refList(idxMatchedPair(:,1),1),refList(idxMatchedPair(:,1),2),'r+');
            zz=zz+1;
            gh{zz}=plot(compList(idxMatchedPair(i,2),1),compList(idxMatchedPair(i,2),2),'ro');
            zz=zz+1;
            gh{zz}=plot([refList(idxMatchedPair(i,1),1),compList(idxMatchedPair(i,2),1)],[refList(idxMatchedPair(i,1),2),compList(idxMatchedPair(i,2),2)],'c-'); hold off;
            zz=zz+1;
            hold off;
            %plot overMatched
            hold on;
            gh{zz}=plot(compList(idxOverMatchedComp,1),compList(idxOverMatchedComp,2),'k*');
            zz=zz+1;
            hold off;
            %plot unMatch comb
            hold on;
            gh{zz}=plot(compList(unMatchedComp,1),compList(unMatchedComp,2),'b*');
            zz=zz+1;
            hold off;
            %plot unMatch comb
            hold on;
            gh{zz}=plot(refList(idxUnMatchedRef,1),refList(idxUnMatchedRef,2),'m*');
            zz=zz+1;
            hold off;
        end;
    end;
    if (size(compList,2)==3)
        for i=1:size(idxMatchedPair,1)
            %plot pairs
            hold on;
            zz=1;
            gh{zz}=plot3(refList(idxMatchedPair(:,1),1),refList(idxMatchedPair(:,1),2),refList(idxMatchedPair(:,1),3),'g+');
            zz=zz+1;
            gh{zz}=plot3(compList(idxMatchedPair(i,2),1),compList(idxMatchedPair(i,2),2),compList(idxMatchedPair(i,2),3),'ro');
            zz=zz+1;
            gh{zz}=plot3([refList(idxMatchedPair(i,1),1),compList(idxMatchedPair(i,2),1)],[refList(idxMatchedPair(i,1),2),compList(idxMatchedPair(i,2),2)],[refList(idxMatchedPair(i,1),3),compList(idxMatchedPair(i,2),3)],'c-'); hold off;
            zz=zz+1;
            hold off;
            %plot overMatched
            hold on;
            gh{zz}=plot3(compList(idxOverMatchedComp,1),compList(idxOverMatchedComp,2),compList(idxOverMatchedComp,3),'k*');
            zz=zz+1;
            hold off;
            %plot unMatch comb
            hold on;
            gh{zz}=plot3(compList(unMatchedComp,1),compList(unMatchedComp,2),compList(unMatchedComp,3),'b*');
            zz=zz+1;
            hold off;
            %plot unMatch comb
            hold on;
            gh{zz}=plot3(refList(idxUnMatchedRef,1),refList(idxUnMatchedRef,2),refList(idxUnMatchedRef,3),'m*');
            zz=zz+1;
            hold off;
        end;
    end;
    if (exist('gh','var'))
        legText={'matched pair ref';'matched pair comp';'matched pairs';'overMatched comp';'unMatched comp';'unMatched ref'};
        ghTmp=[];
        zz=1;
        for i=1:length(gh)
            if (isempty(gh{i})==0)
                ghTmp=cat(1,ghTmp,gh{i});
                legTextTmp{zz}=legText{i};
                zz=zz+1;
            end;
        end;
        legend(ghTmp,legTextTmp);
    end;
 end;



function [idxMatchedPair,allDistPair,idxMatchedFull]=sortPairIdx(idxMatchedPair,allDistPair,idxMatchedFull)

[~,idxTmp]=sort(idxMatchedPair(:,1));

idxMatchedPair=idxMatchedPair(idxTmp,:);
allDistPair=allDistPair(idxTmp);
idxMatchedFull=idxMatchedFull(idxTmp);







