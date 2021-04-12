function Align=tom_av3_filterAlignByMask(Align,mask,filenameOut)
%TOM_INSIDE_MASK reduces align list by the given mask
%
%  Align=tom_inside_mask(Align,mask)
%
%PARAMETERS
%
%  INPUT
%   Align                   Align list filename or in memory
%   mask                   mask filename or in memory
%   filenameOut        () reduced alignment file
%  
%  OUTPUT
%
%  AlignRed     reduce Align list
%
%EXAMPLE
%
% tom_av3_filterAlignByMask('ParticleList.mat','maskdel.em','PartListInsideMask.mat');
%
%REFERENCES
%
%SEE ALSO
%    tom_inside_mask();
%
%   created by FB 15/01/18
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


if (isstruct(Align)==0)
    load(Align);
end;

if (isnumeric(mask)==0)
    mask=tom_emread(mask);
    mask=mask.Value;
end;

pos=zeros(size(Align,2),3);

idxMask=find(mask>0.5);
zz=1;
wb=tom_progress(size(Align,2));
for i=1:size(Align,2)
    pos(1)=Align(1,i).Tomogram.Position.X;
    pos(2)=Align(1,i).Tomogram.Position.Y;
    pos(3)=Align(1,i).Tomogram.Position.Z;
    
    
    tmp=zeros(size(mask),'int8');
    tmp(pos(1),pos(2),pos(3))=1;
    idxPoint=find(tmp);
    pointIsInsideMask=isempty(find(ismember(idxMask,idxPoint)))==0;
    
    if (pointIsInsideMask)
        pointIdx(zz)=i;
        zz=zz+1;
    end;
    
    wb.update();
end;
wb.close;

disp(['reduced pickList form ' num2str(size(Align,2)) ' to ' num2str(length(pointIdx))  ' by mask']);

Align=Align(1,pointIdx);

if (isempty(filenameOut)==0)
    save(filenameOut,'Align');
end;













