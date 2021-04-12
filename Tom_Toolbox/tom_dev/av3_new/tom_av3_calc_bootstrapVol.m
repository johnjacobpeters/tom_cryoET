function tom_av3_calc_bootstrapVol(Align,partsPerBootstrap,nrBootstrap,outputFolder)
%tom_av3_calc_bootstrapVol calculates bootstrap volumes 
%
%  tom_av3_calc_bootstrapVol(Align,partsPerBootstrap,nrBootstrap,outputFolder)
% 
%
%PARAMETERS
%
%  INPUT
%   Align                Align Struct or filename
%   partsPerBootstrap    (200)  num of parts per bootstrap      
%   nrBootstrap          (2000) total number of bootstrap vols
%   outputFolder         ('bootStrapVol') filename 
%   outputFormat         (.em) or .mrc
%  
%  OUTPUT
%  -
%
%EXAMPLE
%    
%
%  tom_av3_calc_bootstrapVol(Align,350,500,'test');
%
%
% REFERENCES
%
%   
%
%SEE ALSO
%   tom_av3_calc_variance
%
%   created by FB (feat) Heinz Schenk 06/07/15
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
    partsPerBootstrap=200;
end;

if (nargin<3)
    nrBootstrap=2000;
end;

if (nargin<4)
    outputFolder='bootStrapVol';
end;

if (nargin<5)
    outputFormat='.em';
end;


if (isstruct(Align)==0)
    Align=load(Align);
    Align=Align.Align;
end;


warning off; mkdir(outputFolder); warning on;

lenAlign=size(Align,2);

for i=1:nrBootstrap
    tmpVect=randperm(lenAlign);
    allIdx{i}=tmpVect(1:partsPerBootstrap);
end;



parfor i=1:length(allIdx)
    AlignTmp=Align(1,allIdx{i});
    avg=tom_av3_average3(AlignTmp);
    if (strcmp(outputFormat,'.em'))
        tom_emwrite([outputFolder filesep 'bs_' num2str(i) '.em'],avg);
    end;
    if (strcmp(outputFormat,'.mrc'))
        tom_emwrite(avg,'name',[outputFolder filesep 'bs_' num2str(i) '.mrc']);
    end;
end;













