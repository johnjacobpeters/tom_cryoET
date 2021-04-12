function [corrresMap,corrVol]=tom_correctResMap(resMap,modelMask,boxSize,overAllRes,corrFudge,outputResMapName,minRes)
%TOM_CORRECTresMap corrects a resolutiom map (from e.g. blockfilt) for
%solvent errors
%
%
%   corr=tom_correctResMap(resMap,boxSize,corrFudge)
%
%PARAMETERS
%
%  INPUT
%   resMap                          input 3D resMap
%   modelMask                    binary Mask of the corrected Model  
%   boxSize                          boxSize from blockfilt  
%   overAllRes                     resolution of the half sets
%   corrFudge                     (2.2) usually to map mean decay to the resolution dcay
%   outputResMapName     (opt.) outputname
%   minRes                          (3.5) 
%
%  OUTPUT
%   corrresMap           corrected resMap
%
%EXAMPLE
%
% [corrresMap,corrVol]=tom_correctResMap('resMap.mrc','maskModelCut.mrc',20,3.9,2.5,'resMapCorrected.mrc');
% 
%
%REFERENCES
%
%SEE ALSO
%
%   created by fb 14/03/16 
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

if (nargin < 5)
    corrFudge=2.2;
end;

if (nargin < 6)
    outputResMapName='';
end;

if (nargin < 7)
    minRes=-1;
end;

[resMap,modelMask]=readMaps(resMap,modelMask);

mask4Mean=tom_spheremask(ones(size(resMap)),(round(boxSize)./2)+3);
meanVol=tom_os3_mean(single(modelMask),mask4Mean);

idxUsed=find(modelMask>0);
idxNotUsed=find(modelMask==0);

disp(['Mean Resolution b4 overall Res correction: ' num2str(mean(resMap(idxUsed)))]);
resMap(idxUsed)=(resMap(idxUsed)-mean(resMap(idxUsed))) + overAllRes;
disp(['Mean Resolution overall Res corrected: ' num2str(mean(resMap(idxUsed)))]);

corrVol=meanVol*corrFudge;
corrVol(idxUsed)=corrVol(idxUsed)-mean(corrVol(idxUsed));
corrVol(idxUsed)=corrVol(idxUsed)+1;
corrVol(idxNotUsed)=1;

corrresMap=resMap.*corrVol;

if (minRes>-1)
    idxMinRes=find(corrresMap<=minRes);
    corrresMap(idxMinRes)=minRes;
end;

if (isempty(outputResMapName)==0)
    [~,~,ext]=fileparts(outputResMapName);
    if (strcmp(ext,'.em'))
        tom_emwrite(outputResMapName,corrresMap);
    end;
    if (strcmp(ext,'.mrc'))
        tom_mrcwrite(corrresMap,'name',outputResMapName);
    end;
    if (strcmp(ext,'.spi'))
        tom_spiderwrite(outputResMapName,corrresMap);
    end;
end;

function [resMap,modelMask]=readMaps(resMap,modelMask)

if (ischar(resMap))
    if (tom_ismrcfile(resMap))
        tmp=tom_mrcread(resMap);
    end;
    if (tom_isemfile(resMap))
        tmp=tom_emread(resMap);
    end;
    if (tom_isspiderfile(resMap))
        tmp=tom_spiderread(resMap);
    end;
    resMap=tmp.Value;
end;

if (ischar(modelMask))
    if (tom_ismrcfile(modelMask))
        tmpM=tom_mrcread(modelMask);
    end;
    if (tom_isemfile(modelMask))
        tmpM=tom_emread(modelMask);
    end;
    if (tom_isspiderfile(modelMask))
        tmpM=tom_spiderread(modelMask);
    end;
    modelMask=tmpM.Value;
end;


