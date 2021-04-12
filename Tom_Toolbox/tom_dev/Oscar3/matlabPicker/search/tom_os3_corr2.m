function [ccf,cache]=tom_os3_corr2(vol,template,templateMask,flag,tolS,cache)
%TOM_OS3_CORR performes loal normalized crosscorrealion 
%
%   ccf=tom_os3_corr2(vol,template,templateMask)
%
%PARAMETERS
%
%  INPUT
%   vol               search Volume
%   template          template 
%   templateMask      mask 4 template
%   flag              ('FLCF')
%   tolS              smallest value 4 std-Volume   
%   cache             cache for spped up 
%
% OUTput
%   ccf              correlation function
%   cache            cache struct for speed up  
%   
%EXAMPLE
%
%  ccf=tom_os3_corr2(vol,template,maskTemplate)
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 19/02/15
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
    flag='FLCF';
end;

if (nargin<5)
    tolS=0.15;
end;

if (nargin<6)
    cache='';
end;


if (isfield(cache,'volStd')==0)
    maskPadded=tom_os3_pasteCenter(zeros(size(vol)),templateMask);
    [cache.volStd,cache.smallValIdx]=getVolStd(vol,maskPadded,tolS);
end;

if (isfield(cache,'fvol')==0)
    cache.fvol=fftn(vol);
end;

templateNormed = tom_os3_normUnderMask(template,templateMask).*templateMask;
templateNormedPad=tom_os3_pasteCenter(zeros(size(vol)),templateNormed);
ftemplate=fftn(templateNormedPad);

templateMaskNumOfSamples=length(find(templateMask==1));

if (strcmp(flag,'FLCF'))
    ccf =  cache.fvol .* conj(ftemplate);
    ccf = single(real(ifftshift(ifftn(ccf))));
    ccf = ccf./templateMaskNumOfSamples;
    ccf=ccf./cache.volStd;
    ccf(cache.smallValIdx)=-1;
end;




function [volStd,idxSmall]=getVolStd(vol,mask,tolS)

fmask=fftn(mask);
maskNumOfSamples=length(find(mask==1));

meanVol = real(ifftshift(ifftn(fftn(vol).*fmask))./maskNumOfSamples);
%tom_dev(vol,'adf',mask);
%disp(num2str(meanVol(129,129,129)));


volStd = real(ifftshift(ifftn(fftn(vol.*vol).*fmask)));
volStd = (volStd ./ (maskNumOfSamples)) - (meanVol.*meanVol);
volStd = max(volStd,0);
volStd = sqrt(volStd);
%disp(num2str(volStd(129,129,129)));

if (isempty(tolS)==0)
    idxSmall=find(abs(volStd)<tolS);
end;
volStd(idxSmall)=1;




