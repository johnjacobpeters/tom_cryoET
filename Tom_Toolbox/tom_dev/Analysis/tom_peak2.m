function [pos,val,in] = tom_peak2(in,replace,valReplace,angle)
% TOM_PEAK determines the coordinates and value of the maximum of an array
%
% PARAMETERS
%  INPUT
%   in       array  3d
%   replace  volume to replace a opt
%   angle    rotate replace befor pasting 
%
%  OUTPUT
%   pos       coordinates of the maximum 
%   val       value of the maximum
%   out       array with all elements set to zero in the circle R
%
%
% EXAMPLE
%
%
%REFERENCES
%
% SEE ALSO
%    TOM_LIMIT, TOM_PASTE
%   created by AL 11/09/02
%   updated by FF 10/11/04
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
%

if (nargin<3)
    valReplace=0;
end;

if (nargin<4);
   angle=[0 0 0]; 
end;


if nargin>1
    szRepl=size(replace);
end;


if nargin>2
    replace=tom_rotate(replace,angle);
end;

[val,pos]=max(in(:));

[pos(1),pos(2),pos(3)]=ind2sub(size(in),pos);

if nargin>1
     tmp4Ind=zeros(size(in),'uint8');
     tmp4Ind=tom_paste(tmp4Ind,replace,round(pos-(szRepl./2)));
     idx=find(tmp4Ind);
     clear('tmp4Ind');
     in(idx)=valReplace;
end;











