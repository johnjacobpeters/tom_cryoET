function tom_plotConfFromObs(obsMatrix,featureX,measured,titleIn)
%TOM_PLOTCONFFROMOBS plot conf intervals from observation Matrix
%   
% tom_plotConfFromSim(obsMatrix)
%
%PARAMETERS
%
%  INPUT
%   observationMatrix      matrix of observations dim1 obs dim2 features
%   featureX                      x-Axis for plotting   
%   measured                    measured data
%   title                             ('') title for plot 
%
%  OUTPUT
%
%
%EXAMPLE
%
% tom_plotConfFromObs(M,xM,meaSt.angBins,'mother vs plane');
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

convNumStd=3;

figure;  
hold on;
for i=1:size(obsMatrix,1)
     lineTmp=obsMatrix(i,:);
     lineTmp=lineTmp;%-rand(size(lineTmp));
     pp = spline(featureX,lineTmp);
     xrs=featureX:0.5:featureX(end);
     yy=ppval(pp,xrs);
     pl = plot(featureX,lineTmp,'b-','LineWidth',0.8); 
     %pl = plot(xrs,yy,'b-','LineWidth',0.8,'Color',[0.0148    0.3225    0.6627]); 
     pl.Color(4)=0.07; 
end;
%hold off;

meanM=mean(obsMatrix,1);
stdM=std(obsMatrix);

errorbar(featureX,meanM,[stdM.*convNumStd],'LineWidth',2,'Color',[0.0750    0.4562    0.4688]);
upperStd(1,:)=stdM.*convNumStd+meanM;
lowerStd(1,:)=-stdM.*convNumStd+meanM;
plot(featureX,upperStd(1,:),'--','Color',[0.0750    0.4562    0.4688]);
plot(featureX,lowerStd(1,:),'--','Color',[0.0750    0.4562    0.4688]);


upperStd(1,:)=stdM.*(convNumStd-1)+meanM;
lowerStd(1,:)=-stdM.*(convNumStd-1)+meanM;
plot(featureX,upperStd(1,:),'--','Color',[0.0750    0.4562    0.4688]);
plot(featureX,lowerStd(1,:),'--','Color',[0.0750    0.4562    0.4688]);

hold on;
pl = plot(featureX,measured,'b-','LineWidth',2,'Color',[1 0 0]); 
plot(featureX,measured,'ko');
hold off;
title(titleIn);

