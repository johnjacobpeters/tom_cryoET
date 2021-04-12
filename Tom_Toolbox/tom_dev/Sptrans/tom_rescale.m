function out=tom_rescale(in,newsize,mask)
%TOM_RESCALE resizes 1D,2D and 3D-data in Fourierspace
%
%   out=tom_rescale(in,newsize)
%
%PARAMETERS
%
%  INPUT
%   in                  input volume
%   newsize             new size as a vector
%   mask                (opt.) mask 4 fourier space   
%
%  OUTPUT
%   out                 rescaled volume
%
%EXAMPLE
%   in=tom_emread('Proteasome.vol');
%   out=tom_rescale(in.Value,[64 64 64]);
%
%REFERENCES
%
%SEE ALSO
%   tom_rescale3d, imresize
%
%   created by SN 05/30/05
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

in_fft=fftn(in);

in_fft_shift=fftshift(in_fft);

out=zeros(newsize);

if (nargin<3)
    mask=ones(size(out));
end;

if size(newsize,2)<3
    insize=size(in);
    insize(3)=1;
    newsize(3)=1;
else
    insize=size(in);
end;

if newsize(1)>size(in,1)
    
    out(newsize(1)./2-insize(1)./2+1:newsize(1)./2+insize(1)./2,newsize(2)./2-insize(2)./2+1:newsize(2)./2+insize(2)./2,newsize(3)./2-insize(3)./2+1:newsize(3)./2+insize(3)./2)=in_fft_shift;
    out=out.*mask;
    out=ifftshift(out);
    out=real(ifftn(out));
    
    out=out./(insize(1)./newsize(1).*insize(2)./newsize(2).*insize(3)./newsize(3));
else if newsize(1)<size(in,1)
        
        out=in_fft_shift(insize(1)./2-newsize(1)./2+1:insize(1)./2+newsize(1)./2,insize(2)./2-newsize(2)./2+1:insize(2)./2+newsize(2)./2,insize(3)./2-newsize(3)./2+1:insize(3)./2+newsize(3)./2);
        out=ifftshift(out);
        out=real(ifftn(out));
        
        out=out./(insize(1)./newsize(1).*insize(2)./newsize(2).*insize(3)./newsize(3));
    else
        out=in;
    end;
    
end;
 




%Old Code!!

% in_fft=fftn(in);
% 
% in_fft_shift=fftshift(in_fft);
% 
% out=zeros(newsize);
% 
% if (nargin<3)
%     mask=ones(size(out));
% end;
% 
% if size(newsize,2)<3
%     insize=size(in);
%     insize(3)=1;
%     newsize(3)=1;
% else
%     insize=size(in);
% end;
% 
% if newsize(1)>size(in,1)
%     out(newsize(1)./2-insize(1)./2+1:newsize(1)./2+insize(1)./2,newsize(1)./2-insize(1)./2+1:newsize(2)./2+insize(2)./2,newsize(3)./2-insize(3)./2+1:newsize(3)./2+insize(3)./2)=in_fft_shift;
%     out=out.*mask;
%     out=fftshift(out);
%     out=real(ifftn(out));
%     out=out./(insize(1)./newsize(1).*insize(2)./newsize(2).*insize(3)./newsize(3));
% else if newsize(1)<size(in,1)
%     out=in_fft_shift(insize(1)./2-newsize(1)./2+1:insize(1)./2+newsize(1)./2,insize(2)./2-newsize(2)./2+1:insize(2)./2+newsize(2)./2,insize(3)./2-newsize(3)./2+1:insize(3)./2+newsize(3)./2);
%     out=fftshift(out);
%     out=real(ifftn(out));
%     out=out./(insize(1)./newsize(1).*insize(2)./newsize(2).*insize(3)./newsize(3));
%     else        
%         out=in;    
%     end;
%     
% end;
% 
