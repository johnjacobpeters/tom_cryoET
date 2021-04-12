function align2d=tom_av2_removeItem_align(align2d,field,operator,value)
%TOM_AV2_REMOVEITEM_ALIGN filters align2d list
%                  
%  align2d=tom_av2_removeItem_align(align2d,field,operator,value);
%
%PARAMETERS
%
%  INPUT
%   align2d          align2d 
%   field            field to filter
%   operator         (<>==)
%   value            value to filter         
%   
%
%  OUTPUT
%   align2d  filtered align
%
%EXAMPLE
%  
% 
%  align2d=tom_av2_removeItem_align(align2d,'position','<',1);
%  align2d=tom_av2_removeItem_align(align2d,'position','off');
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
%   created by FB 09/10/15
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


used=ones(size(align2d,2),1);

if (tom_isemfile(align2d(1,1).filename))
    tmpImg=tom_emread(align2d(1,1).filename);
else
    tmpImg=tom_mrcread(align2d(1,1).filename);
end;
sz=size(tmpImg.Value);

for i=1:size(align2d,2)
    if (strcmp(operator,'off'))
        if (align2d(1,i).position.x < 1 || align2d(1,i).position.y < 1)
            used(i)=0;
        end;
        if (align2d(1,i).position.x > sz(1) || align2d(1,i).position.y > sz(2))
            used(i)=0;
        end;
    else
        if (strcmp(field,'position'))
            call=['align2d(1,i).position.x ' operator ' ' num2str(value) ' || align2d(1,i).position.y ' operator ' ' num2str(value)  ];
            if (eval(call))
                used(i)=0;
            end;
        end;
    end;
end;
align2d=align2d(1,find(used==1));



