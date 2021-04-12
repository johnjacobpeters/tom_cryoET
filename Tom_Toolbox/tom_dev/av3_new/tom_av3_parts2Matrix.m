function [obsMatrix,vol_list,sz]=tom_av3_parts2Matrix(basePath,partIdx,ext,filt,mask)
%tom_av3_parts2Matrix reads particles and reashapes into 2d obseravation
%matirx
%
%   [obsMatrix,vol_list]=tom_av3_parts2Matrix(basePath,partIdx,ext)
%
%PARAMETERS
%
%  INPUT
%   basePath                basepath to the particles
%   partIdx                 array of particle indices
%   ext                     extension of particles 
%   filt                    lowpass in pix
%   mask                    mask4Parts      
%
%  OUTPUT
%   obsMatrix              matrix of observation in matlab-convention 
%   vol_list               list of volumes      
%   sz                     size of volumes
%
%EXAMPLE
%
% [obsMatrix,vol_list]=tom_av3_parts2Matrix('vols/vol_',1:20,'em');
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 20/11/13
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
    filt=0;
end;


volTmp=tom_emread([basePath num2str(partIdx(1)) '.' ext]);
volTmp=volTmp.Value;
sz=size(volTmp);
obsMatrix=zeros(length(partIdx),sz(1).*sz(2).*sz(3));
for i=1:length(partIdx)
    inputName=[basePath num2str(i) '.' ext]; 
    tmp=tom_emread(inputName); 
     tmp=tmp.Value;
     if (filt>0)
        tmp=tom_bandpass(tmp,0,filt,3);
     end;
     tmp=tmp.*mask;
     obsMatrix(i,:)=reshape(tmp,[sz(1).*sz(2).*sz(3)],1);
     vol_list{i}=inputName;
end;


