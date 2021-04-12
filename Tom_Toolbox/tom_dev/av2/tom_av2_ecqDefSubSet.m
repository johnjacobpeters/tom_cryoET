function tom_av2_ecqDefSubSet(wk,numOfImages,ctfProgram,fileFilterName)
%TOM_AV2_ECPDEFSUBSET generates a subset of images with equal defocus
%                     distribution useful generation defocus dependend
%                     training sets
%                  
%  tom_av2_ecqDefSubSet(wk,ctfProgram,fileFilterName);
%
%PARAMETERS
%
%  INPUT
%   wk               wildcard of the images
%   numOfImages      (50) number of images in filefilter
%   fileFilterName   ('./filefilterECQ.mat') path for the output filefilter
%   ctfProgram       ('ctffind3') name of the ctfprogram
%   
%
%  OUTPUT
%   
%
%EXAMPLE
%  
% 
%  tom_av2_ecqDefSubSet('/fs/pool/pool-titan1/HWTF3/data/001_20150728_f22/0_micrographs/Falcon_2015_*_ctffind3.log');
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
%   created by FB 09/09/15
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
    numOfImages=50;
end;

if (nargin<3)
    fileFilterName='filefilterECQ.mat';
end;

if (nargin<4)
    ctfProgram='ctffind3';
end;


nrGr=10;

ctf=tom_av2_ctffind_parselog(wk);
def=[ctf{:,2}];
fileName=ctf(:,1);

[groupV,cent]=kmeans(def',nrGr);
uGroups=unique(groupV);
p=tom_calc_packages(length(uGroups),numOfImages);
nrPerGroup=p(:,3);

zz=1;
for i=1:length(uGroups)
    idx=find(groupV==uGroups(i));
    rr=randperm(length(idx));
    if (nrPerGroup(i)>length(rr))
        nrG=length(rr);
    else
        nrG=nrPerGroup(i);
    end;
    idxUsed=idx(rr(1:nrG));
    for ii=1:length(idxUsed)
        disp([num2str(def(idxUsed(ii))) ] );
        tmpF=fileName{idxUsed(ii)};
        [~,b,c]=fileparts(tmpF);
        listOfImg{zz}=strrep([b c],'_ctffind3.log','.mrc');
        zz=zz+1;
    end;
end;


d=dir(wk);

for i=1:length(d)
    nameImg=strrep(d(i).name,'_ctffind3.log','.mrc');
    particlepicker.filelist{i}=nameImg;
    if (isempty(find(ismember(nameImg,listOfImg))))    
        particlepicker.filefilter{i}=0;
    else
        particlepicker.filefilter{i}=1;
    end;
 end;


save(fileFilterName,'particlepicker');
















