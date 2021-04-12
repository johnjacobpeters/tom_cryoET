function [simSt,meaSt]=tom_calcAngConv(measuredAngles,bins,titleIn,numOfTrials,convNumStd,dimension)
%TOM_CALCANGCONV calculates random angular distances
%
%   [angdisMatrix,confInterval]=tom_calcAngConv(measuredAngles,bins,title)
%
%PARAMETERS
%
%  INPUT
%   measuredAngles      inputAngles
%   bins                         (0:10:180) bins for histogram  
%   titleIn                      ('') title for plots
%   numOfTrials            (1000) number of trials
%   convNumStd            (3) number of std for conv Interval 
%   dimension                ('3d') or 2d or 2d-line
%
%  OUTPUT
%    simSt                  struct containing data from simulation
%    meaSt                 struct containing data from measured data
%
%EXAMPLE
%
% load vectOutPlaneAlg/list.txt
% tom_calcAngConv(list(:,10),0:10:180,1000,'mother vs. plane');
% 
% %2d case
% tom_calcAngConv(rand(50,1).*360,0:10:180,'mother vs. plane',1000,3,'2d');
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 17/01/18
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

if (nargin<2)
    bins=0:10:180;
end;

if (nargin<3)
    titleIn='';
end;

if (nargin<4)
    numOfTrials=1000;
end;

if (nargin<5)
    convNumStd=3;
end;

if (nargin<6)
    dimension='3d';
end;


if (strcmp(dimension,'2d-line'))
    tmp=measuredAngles;
    idx=find(tmp>90);
    measuredAngles(idx)=180-tmp(idx);
end;

simSt=genSimStruct(measuredAngles,bins,numOfTrials,convNumStd,dimension);
simSt=simulateForConvidence(simSt);
meaSt=calcMeaBins(measuredAngles,bins,simSt.statBinsNorm.corrFun);


genOutput(simSt,meaSt,titleIn);

function meaSt=calcMeaBins(measuredAngles,bins,corrFun)

[meaSt.xValsBins,meaSt.angBins,meaSt.angBinsNorm]=calcBins(measuredAngles,bins,corrFun);



function simSt=genSimStruct(measuredAngles,bins,numOfTrials,convNumStd,dimension)


if (strcmp(dimension,'3d'))
    simSt.angListName='/fs/pool/pool-bmapps/allSystem/appData/uniformAngularSampling_ZXZ/angles_3_553680.em';
    simSt.planeNormal=[0 0 1];
    simSt.vector=[1 1 1];
    simSt.numOfTrials=numOfTrials;
    simSt.numOfAngles=length(measuredAngles);
    simSt.bins=bins;
    simSt.convNumStd=convNumStd;
else
    simSt.angListName='rand2d';
    simSt.planeNormal=[1 1];
    simSt.vector=[1 1];
    simSt.numOfTrials=numOfTrials;
    simSt.numOfAngles=length(measuredAngles);
    simSt.bins=bins;
    simSt.convNumStd=convNumStd;
    if (strcmp(dimension,'2d-line'))
        simSt.withDir=1;
    else
        simSt.withDir=0;
    end;
end;




function genOutput(simSt,meaSt,titleBase)

disp(' ');
disp(' ');
disp('results:  ');
disp(' ');

%nrom vs org debug plot
if ( max(size(simSt.vector)) >2)
    plotOrgVsNormalized(simSt,meaSt,titleBase,'normalized vs org');
end;

%plot original Version
plotSimVsMea(simSt.xValsBins,simSt.statBins,meaSt.angBins,simSt.convNumStd,titleBase,'not normalized');
plotSimVsMea2(simSt.xValsBins,simSt.angBins',meaSt.angBins,titleBase,'not normalized');


%plot normalized Version
if ( max(size(simSt.vector)) >2)
    plotSimVsMea(simSt.xValsBins,simSt.statBinsNorm,meaSt.angBinsNorm,simSt.convNumStd,titleBase,'normalized (sin(ang))');
else
    disp(' ');
    disp('nomalisation not need equal distribution in 2d ');
end;



function plotOrgVsNormalized(simSt,meaSt,titleBase,textoutput)


titleFull=[titleBase ' ' textoutput];
plotData(simSt.xValsBins,simSt.statBins.mean,'g-');
plotData(simSt.xValsBins,simSt.statBinsNorm.mean,'r-');
title([titleFull ' rand fun']);

figure;
plotData(meaSt.xValsBins,meaSt.angBins,'g-');
plotData(meaSt.xValsBins,meaSt.angBinsNorm,'r-');
title([titleFull ' measured data']);

function plotSimVsMea2(binsX,M,meadat,titleBase,textoutput)

tom_plotConfFromObs(M,binsX,meadat,[titleBase ' ' textoutput]);


function plotSimVsMea(binsX,binsYsim,binsYmea,convNumStd,titleBase,textoutput)

titleFull=[titleBase ' ' textoutput];
plotMeanAndError(binsX,binsYsim,convNumStd);
plotData(binsX,binsYmea);
disp(textoutput);
disp(['  sum of bins measured: ' num2str(sum(binsYmea)) ' simulated: ' num2str(sum(binsYsim.mean)) ' nr bins: ' num2str(length(binsX)) ]);
title(titleFull);



function [simSt]=simulateForConvidence(simSt)


if (strcmp(simSt.angListName,'rand2d'))
    %2d case
    angMatrix=zeros(simSt.numOfAngles,simSt.numOfTrials);
    wb=tom_progress(simSt.numOfTrials,'simulation for convidence levels');
    parfor i=1:simSt.numOfTrials
        angListSub=zeros(3,simSt.numOfAngles);
        angListSub(1,:)=deg2rad(rand(simSt.numOfAngles,1).*360);
        angMatrix(:,i)=calcAllAngToNormal(angListSub,simSt.planeNormal,simSt.vector);
       if (simSt.withDir)
            tmp=angMatrix(:,i);
            idx=find(tmp>90);
            tmp(idx)=180-tmp(idx);
            angMatrix(:,i)=tmp;
       end;
        wb.update();
    end;
    close(wb);
    simSt.angMatrix=angMatrix;
else
    %3d case
    angListFull=tom_emreadc(simSt.angListName); angListFull=angListFull.Value;
    angMatrix=zeros(simSt.numOfAngles,simSt.numOfTrials);
    wb=tom_progress(simSt.numOfTrials,'simulation for convidence levels');
    parfor i=1:simSt.numOfTrials
        angListSub=getAngListSubSet(angListFull,simSt.numOfAngles);
        angMatrix(:,i)=calcAllAngToNormal(angListSub,simSt.planeNormal,simSt.vector);
        wb.update();
    end;
    close(wb);
    simSt.angMatrix=angMatrix;
end;

[simSt.xValsBins,simSt.angBins,simSt.angBinsNorm]=calcBins(simSt.angMatrix,simSt.bins);
simSt.statBins=calcBinStatistics(simSt.angBins);
[simSt.statBinsNorm,simSt.corrFun]=normalizeBinStatBySin(simSt.statBins,simSt.xValsBins);


function [statBinsNorm,corrFun]=normalizeBinStatBySin(statBins,binsX)

corrFun=calcNormFun(statBins.mean,binsX);

statBinsNorm=statBins;
statBinsNorm.mean=statBins.mean.*corrFun;
statBinsNorm.std=statBins.std.*corrFun;
statBinsNorm.stdBounds.upper=statBins.stdBounds.upper.*corrFun;
statBinsNorm.stdBounds.lower=statBins.stdBounds.lower.*corrFun;
statBinsNorm.corrFun=corrFun;



function nf=calcNormFun(vals,binsX)

%this function calcs the sind normalisation function
corrFun=(1./sind(binsX'));
cf=mean(vals)./(mean(corrFun.*vals));
nf=corrFun.*cf;


function  plotMeanAndError(xValsBins,statBins,convNumStd,newFigure,col)

if (nargin<4)
    newFigure=1;
end;

if (nargin<5)
    col='b-';
end;

if (newFigure)
    figure;
else
    hold on;
end;

plot(xValsBins,statBins.mean,col);
hold on;
errorbar(xValsBins,statBins.mean,[statBins.std.*convNumStd]);
hold off;

function plotData(xVals,angBins,col)

if (nargin<3)
    col='r-';
end;

hold on;
plot(xVals,angBins,col);
plot(xVals,angBins,'bo');
hold off;


 
function  [statBins]=calcBinStatistics(angBins)

statBins.mean=mean(angBins,2);
statBins.std=std(angBins')';

statBins.stdBounds.upper=statBins.mean+2.*statBins.std;
statBins.stdBounds.lower=statBins.mean-2.*statBins.std;



function [xValsBins,angBins,angBinsNorm]=calcBins(angMatrix,bins,corrFun)

if (nargin<3)
    corrFun='';
end;


angBins=zeros(length(bins)-1,size(angMatrix,2));
angBinsNorm=zeros(length(bins)-1,size(angMatrix,2) );


for i=1:size(angMatrix,2)
       ang=angMatrix(:,i);
       [angBins(:,i),xValsBins]=histcounts(ang,bins);
       delta=bins(2)-bins(1);
       xValsBins=xValsBins+(delta/2); % set x to center of bin
       xValsBins=xValsBins(1:end-1);
       
       if (isempty(corrFun)==0)
           corrFunNorm=corrFun;
           angBinsNorm(:,i)=angBins(:,i).*corrFunNorm; 
       end;
     
       
end;
%figure; plot(xValsBins,corrFunNorm,'ro');

function AngListSub=getAngListSubSet(angList,numOfAngles)

lenAngList=size(angList,2);
idx=randperm(lenAngList);
idx=idx(1:numOfAngles);
AngListSub=angList(:,idx);


function ang=calcAllAngToNormal(angList,planeNormal,vector)

if (max(size(vector))==2 )
    vector=[vector 0];
    planeNormal=[planeNormal 0];
end;

ang=zeros(size(angList,2),1);

for i=1:size(angList,2)
    angTmp=rad2deg(angList(:,i));
    vectorRot=tom_pointrotate(vector,angTmp(1),angTmp(2),angTmp(3));
    ang(i)=calcAngToNormal(vectorRot,planeNormal);
end;


function ang=calcAngToNormal(v,vN)

projMask=(isnan(vN)==0);
v=v.*projMask;
vN(isnan(vN))=0;

dpN=sum(v.*vN)./(norm(v).*norm(vN));
ang=rad2deg(acos(dpN));





