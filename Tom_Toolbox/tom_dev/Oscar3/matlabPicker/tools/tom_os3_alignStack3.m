function [avgFilt,stackAlg,paramAlg,allAvgUnFilt,allRes,fscFilter,fscFun,avgHalfsUnf]= tom_os3_alignStack3(stack,pixS,reference,discard,adaptiveFilter,maxRes,mask,maxIter,maxShift,maxRot,preNorm)
%TOM_OS3_alignStack3 performs iterative rotational, translational alignment of an imageStack (im) relative to reference (ref)
%
%   [avg,stackAlg,paramAlg,allAvg]= tom_os3_alignStack3(stack,pixS,reference,mask,preNorm)
%
%PARAMETERS
%
%  INPUT
%   stack                    stack to be aligned
%   pixS                     (1) pixelsize inAng
%   reference             (1) numOfSeed or reference image(s) or image stack
%   discard                (0.15) amount of particles to be discarted in in %/100
%   adaptiveFilter       ('goldStandard') or '2-halfsets' or fixed in Ang
%                               bandpass
%   maxRes                ('nyquist') or a given res in Ang
%   mask                    ('default') mask for reference
%   maxIter                 (30)  max number of iter                              
%   maxShift               (15)   max shift 
%   maxRot                 (360) max rot
%   preNorm               ('none') mean0 and 1 std on background
%
%                              
%
%  OUTPUT
%   avgFilt               average filterd by fsc
%   stackAlg            aligned stack
%   paramAlg          alignmetn param
%   allAvgUnFilt       allAverages
%   allRes                all Resolution values;
%   fscFilter             weiht function from fsc for filtering
%   fscFun               fscCurve 
%   avgHalfsUnf      last iter avg Halfs            
%
%
%EXAMPLE
%
%
%[avg,stackAlg,algParam,allAvg,allRes,fscFilter,faxFun,avgHalfsUnf]=tom_os3_alignStack3(stack,1.4,1,0.15,'2-halfsets);
%
%
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 140916
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


if (nargin<1)
    error('no inut Stack given');
end;

if (nargin<2)
    pixS=1;
end;

if (nargin<3)
    reference=1;
end;

if (nargin<4)
    discard=0.07;
end;

if (nargin<5)
    adaptiveFilter='goldStandard';
end

if (nargin<6)
    maxRes='nyquist';
end

if (nargin<7)
    mask='default';
end

if (nargin<8)
    maxIter=30;
end

if (nargin<9)
    maxShift=15;
end

if (nargin<10)
    maxRot=360;
end

if (nargin<11)
    preNorm='';
end

if (nargin<12)
    demo=1;
end



iter4RotTrans=3;
nrItNoGain=4;

[stack,szStack]=readStack(stack);
[mask,mask_rot,mask_trans]=genMasks(szStack,maxRot,maxShift,mask);
[stack,stackOrder]=splitStack(stack);
seeds=genInitialSeeds(stack,reference,pixS,adaptiveFilter);
oldSeeds=seeds;

if (demo)
    h=figure;
end;

for itNr=1:maxIter
    
    for ih=1:length(stack)
        [stackAlg{ih},PramAlg{ih}]=alignAllparts(stack{ih},seeds{ih},mask,mask_rot,mask_trans,iter4RotTrans,ih);
        avg{ih}=genAverages(stackAlg{ih},PramAlg{ih}(4,:),PramAlg{ih}(5,:),size(seeds{ih},3),discard);
    end;
    
    avg=alignAvgs(avg,pixS,mask,adaptiveFilter);
    allAvgUnFilt{itNr}=avg;
    [res,filter4Avg,fscFun]=calcRes(avg{1},avg{2},pixS,adaptiveFilter);
    avg=addAndApplySeeds(avg,adaptiveFilter);
    seeds=filterSeeds(avg,filter4Avg,pixS,adaptiveFilter);
    seeds=applyLearnRate(seeds,oldSeeds);
    
    oldSeeds=seeds;
    allRes(itNr)=res;
    
    disp([num2str(itNr) ': resolution ' num2str(res) ]);
    if (demo)
         imagesc((seeds{1}+seeds{2})'); axis image; colormap hot; drawnow;
         set(h,'Name',[num2str(itNr) ': resolution ' num2str(res) ]);
    end;
    
    isConv=checkConvergence(allRes,nrItNoGain);
    if (isConv)
        break;
    end;
    
end;
avgHalfsUnf=allAvgUnFilt{end};

[stackAlg,paramAlg,allAvgUnFilt]=orderOutput(stackAlg,PramAlg,stackOrder,allAvgUnFilt);
avgFilt=seeds{1}+seeds{2};
fscFilter=filter4Avg;

close(h);


function[stackAlg,ParamAlg,allAvgUnFilt]=orderOutput(stackAlgSp,ParamAlgSp,stackOrder,allAvgUnFiltSp)

sz1=size(stackAlgSp{1});
sz2=size(stackAlgSp{2});

stackAlg=zeros(sz1(1),sz1(2),sz1(3)+sz2(3),'single');
ParamAlg=zeros(6,sz1(3)+sz2(3));

stackAlg(:,:,stackOrder{1})=single(stackAlgSp{1});
stackAlg(:,:,stackOrder{2})=single(stackAlgSp{2});

ParamAlg(:,stackOrder{1})=ParamAlgSp{1};
ParamAlg(:,stackOrder{2})=ParamAlgSp{2};

for i=1:length(allAvgUnFiltSp)
    allAvgUnFilt{i}=allAvgUnFiltSp{i}{1}+allAvgUnFiltSp{i}{2};
end;


function conv=checkConvergence(allRes,nrIterNoGain)

conv=0;
if (length(allRes)>nrIterNoGain+1)
    vect=allRes(end-nrIterNoGain:end)-allRes(end);
    if ( abs((sum(vect)./nrIterNoGain)) <0.2)
        conv=1;
    end;
end;

function seeds=applyLearnRate(seeds,oldSeeds)

tmpSeeds=seeds;
for ih=1:2
    seeds{ih}=(0.7.*tmpSeeds{ih}+(0.3.*oldSeeds{ih}));
end;


function seeds=filterSeeds(seeds,filter4Avg,pixS,adaptiveFilter)

if (isnumeric(adaptiveFilter))
    seeds{1}=tom_filter2resolution(seeds{1},pixS,adaptiveFilter);
    seeds{2}=tom_filter2resolution(seeds{2},pixS,adaptiveFilter);
    return;
end;
    
seeds{1}=tom_apply_weight_function(seeds{1},filter4Avg);
seeds{2}=tom_apply_weight_function(seeds{2},filter4Avg);
 


function seeds=addAndApplySeeds(seeds,adaptiveFilter)

if (strcmp(adaptiveFilter,'2-halfsets'))
    sumTmp=seeds{1}+seeds{2};
    seeds{1}=sumTmp;
    seeds{2}=sumTmp;
end;


function avg=alignAvgs(avg,pixS,mask,adaptiveFilter)

if (isnumeric(adaptiveFilter) || strcmp(adaptiveFilter, '2-halfsets' ))
    return;
end;
    
ref=avg{1};
part=avg{2};

ref=tom_filter2resolution(ref,pixS,40);

[~,~,~,algPart]=tom_av2_align(ref,part,mask);

avg{2}=algPart;

function [res,filter4Avg,fscFun]=calcRes(img1,img2,pixS,adaptiveFilter) 

if (isnumeric(adaptiveFilter))
    res='';
    filter4Avg='';
    fscFun='';
    return;
end;

mask4fsc=tom_spheremask(ones(size(img1)),round(size(img1,1)./2)-8,5);

[fsc,f,v05,~,v014]=tom_fsc(img1.*mask4fsc,img2.*mask4fsc,round(size(img1,1)./2),pixS,0);

for i=1:length(fsc)
    if (fsc(i)<0.01)
        break;
    end;
end;
fsc(i:end)=0;
fscOrg=fsc;

if (strcmp(adaptiveFilter,'2-halfsets'))
    fsc=((2*fsc)./(fsc+1)).^0.75 ;
    
    res=v05;
end;

if (strcmp(adaptiveFilter,'goldStandard'))
    fsc=sqrt((2*fsc)./(fsc+1)) ;
    res=v014;
end;

szp=size(tom_cart2polar(img1));
tmpW=repmat(fsc,szp(2),1)';
filter4Avg=tom_polar2cart(tmpW);
fscFun(:,1)=f;
fscFun(:,2)=fscOrg;

function [stackOut,order]=splitStack(stack)

pack=tom_calc_packages(2,size(stack,3));
rr=randperm(size(stack,3));

idxP1=rr(pack(1,1):pack(1,2));
idxP2=rr(pack(2,1):pack(2,2));
%idxP2=idxP2(1:length(idxP1));
order{1}=idxP1;
order{2}=idxP2;

stackOut{1}=stack(:,:,idxP1);
stackOut{2}=stack(:,:,idxP2);

function [stackAlg,algPram]=alignAllparts(stack,seeds,mask,mask_rot,mask_trans,iter4RotTrans,ih)
 
szStack=size(stack);

numPart=szStack(3);
stackAlg=zeros(szStack,'single');
algPram=zeros(5,numPart);

parfor i=1:numPart %loop over all particles
    part=stack(:,:,i);
    [partAlg,algPram(:,i)]=aling_particle(part,seeds,mask,mask_rot,mask_trans,iter4RotTrans);
    stackAlg(:,:,i)=partAlg;
end;
algPram(6,:)=ih;

function avg=genAverages(stackAlg,refNr,cc,nrSeeds,discard)


ccSort=sort(cc);

if (length(cc)>15)
    idx=round(length(cc).*discard);
    if (idx<1)
        idx=1;
    end;
    if (idx>=length(cc))
        idx=length(cc)-2;
    end;
    thr=ccSort(idx);
else
    thr=-1;
end;


%parfor i=1:nrSeeds
for i=1:nrSeeds
    idx=find((refNr==i).*(ccSort>thr) );
    num_per_class=length(idx);
    if (num_per_class==0)
        num_per_class=1;
    end;
    tmpl(:,:,i)=sum(stackAlg(:,:,idx),3);
    avg(:,:,i)=tmpl(:,:,i)./num_per_class;
end;




function [stack,szStack]=readStack(stack)

if (isstruct(stack))
    stack=stack.Value;
end;
szStack=size(stack);

function [mask,mask_rot,mask_trans]=genMasks(szStack,maxRot,maxShift,mask)

tmpGr=ones(szStack(1),szStack(2));

if (strcmp(mask,'default'))
    mask=tom_spheremask(tmpGr,round(szStack(1)./2)-3,2);
end;
    
if (maxRot==360)
    tmpCart=tom_cart2polar(tmpGr);
    mask_rot=ones(size(tmpCart));
end;

if (maxRot<360)
    tmpCart=tom_cart2polar(tmpGr);
    mask_rot=zeros(size(tmpCart));
    disp('sorry not implemented so far !');
end;

mask_trans=tom_spheremask(tmpGr,maxShift,5);

    
function [partAlg,pramAlg]=aling_particle(part,tmpl,mask,mask_rot,mask_trans,iterations)


sz_t=size(tmpl);
if (length(sz_t)==2)
    sz_t(3)=1;
end;
    
angle_tmp=zeros(sz_t(3),3);
shift_tmp=zeros(3,sz_t(3));
aligned_part_tmp=zeros(sz_t);
cc_tmp=zeros(sz_t(3),1);
filter_param.Apply=0;
demo=0;

for i=1:sz_t(3)
    ref=tmpl(:,:,i);
    [angle_tmp(i,:),shift_tmp(:,i),cc_tmp(i),aligned_part_tmp(:,:,i)]=tom_av2_align(ref,part,mask,mask_rot,mask_trans,filter_param,iterations,demo);
end;


%determine maximum of all references
[cc,pos]=max(cc_tmp);
angle=angle_tmp(pos,1);
shift=shift_tmp(1:2,pos)';
partAlg=aligned_part_tmp(:,:,pos);

pramAlg=[angle shift pos cc];
        
        
function seeds=genInitialSeeds(stack,reference,pixS,adaptiveFilter)

if (size(reference,2)>1)
    seeds{1}=reference;
    seeds{2}=reference;    
    return;
end;
        
for ih=1:length(stack)
    pack=tom_calc_packages(reference,size(stack{ih},3));
    seeds{ih}=zeros(size(stack{ih},1),size(stack{ih},2),reference);
    for i=1:size(pack,1)
        seeds{ih}(:,:,i)=sum(stack{ih}(:,:,pack(i,1):pack(i,2)),3);
        seeds{ih}(:,:,i)=tom_filter2resolution(seeds{ih}(:,:,i),pixS,60);
    end;
end;

if (strcmp(adaptiveFilter,'2-halfsets'))
    sumTmp=seeds{1}(:,:,1)+seeds{2}(:,:,1);
    seeds{1}(:,:,1)=sumTmp;
    seeds{2}(:,:,1)=sumTmp;
end;

        
        