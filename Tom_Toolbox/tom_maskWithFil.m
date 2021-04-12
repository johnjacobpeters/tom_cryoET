function in=tom_maskWithFil(in,mask,std2fil, std2shift)
%TOM_MASKWITHNOISE replaces pixels outside mask with noise
%   
%
% out=tom_maskWithNoise(in,mask,noiseMean,noiseStd)
%
%  TOM_MASKWITHNOISE replaces pixels outside mask with noise
%  
%  
%
%PARAMETERS
%
%  INPUT
%   in                   input image/volume
%   mask              mask to det structure
%   noiseMean     mean of noise 
%   noiseStd         std of noise
%
%  OUTPUT
% 
%  out                mask signal 
%
%EXAMPLE
%     
% im=tom_emread('mona.em');
% mask=tom_spheremask(ones(size(im.Value)),round(min(size(im.Value))./4));
% out=tom_maskWithNoise(im,mask,1,2);
% figure; tom_imagesc(out);
%
% out=tom_permute_bg(im,mask,'tmp.spi',1.008,40,2);
%
%REFERENCES
%
%SEE ALSO
%   tom_av2_em_classify3d
%
%   created by FB 08/09/09
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

in_flag='.em';

if (nargin < 3)
    noiseMean=0;
end;

if (nargin < 4)
    noiseStd=1;
end;

if (ischar(in))
    if (tom_isemfile(in))
        in=tom_emread(in);
        in_flag='em';
    else
        in=tom_spiderread(in);
        in_flag='spi';
    end;
end;

if (ischar(mask))
    disp(['Mask: ' mask]);
    if (tom_isemfile(mask))
        mask=tom_emread(mask);
    else
        mask=tom_spiderread(mask);
    end;
end;

if (isstruct(in))
    in=in.Value;
end;

if (isstruct(mask))
    mask=mask.Value;
end;


indd=find(mask < 0.1);
ind_mean = mean2(in(indd));
ind_std = std2(in(indd));

indd2 = find(in(indd)>(ind_mean+std2fil*ind_std));
in(indd(indd2)) = in(indd(indd2))-std2shift*ind_std;

%indd2 = find(in(indd)<(ind_mean-std2fil*ind_std));
%in(indd(indd2)) = in(indd(indd2))+std2shift*ind_std;