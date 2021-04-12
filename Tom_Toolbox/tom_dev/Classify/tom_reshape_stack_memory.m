function img_out=tom_reshape_stack_memory(stack,binning,mask,normstr,useSamp,filt)
%TOM_RESHAPE_STACK_MEMORY reshapes stack
%
%   img_out=tom_reshape_stack_memory(stack,binning,mask,normstr);
%PARAMETERS
%
%  INPUT
%   stack               stack of particles
%   binning             (0) binning
%   mask                ('no_mask') mask
%   normstr             ('no_norm') or 'mean0+1std' '3std' 
%                       
%   useSamp             ('allSamples') reduce size of reshape stack by
%                        using only samples inside the mask 
%                        use 'insideMask' to switch on
%   filt                ('no_filter') filter kernel  
% 
%  OUTPUT
%   img_out             reshaped stack
%
%EXAMPLE
%   img_out=tom_reshape_stack_memory(stack,1);
%   
%   img_out=tom_reshape_stack_memory(stack,0,tom_spheremask(64,64,10),'no_norm','insideMask');         
%  
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by ... fb(eckster) anno 2008
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
    binning=0;
end;

if nargin < 3
   mask='no_mask';
end;

if nargin < 4
    normstr='no_norm';
end;

if nargin < 5
    useSamp='allSamples';
end;

if nargin < 6
   filt='noFilt';
end;


if (strcmp(mask,'no_mask'))
    mask=ones(size(stack,1),size(stack,2));
end;

binning=round(binning);

sz=size(stack);

if (length(binning)==1)
    if (binning >0)
        sz(1)=floor(sz(1)./2^binning);
        sz(2)=floor(sz(2)./2^binning);
    end;
else
    sz=[binning sz(3)];
end;


if (length(binning)==1)
    mask=tom_bin(mask,binning);
else
    mask=tom_rescale(mask,binning);
end;

if (strcmp(useSamp,'allSamples'))
    img_out=zeros(sz(1).*sz(2),sz(3));
else
    idxMask=find(mask>0.8);
    img_out=zeros(length(idxMask),sz(3));
end;

for i=1:sz(3)
    if (strcmp(filt,'noFilt')==0)
        tmp=tom_filter(stack(:,:,i),filt);
    else
        tmp=stack(:,:,i);
    end;
    if (length(binning)==1)
        tmp=tom_bin(tmp,binning);
    else
        tmp=tom_rescale(tmp,binning);
    end;
        
    if strcmp(normstr,'no_norm')==0
        tmp=tom_norm((tmp+2).*2,normstr,mask);
    end;
    if (strcmp(useSamp,'allSamples'))
        tmp=tmp.*mask;
        img_out(:,i)=reshape(tmp,sz(1).*sz(2),'');
    else
        img_out(:,i)=tmp(idxMask);
    end;
end;