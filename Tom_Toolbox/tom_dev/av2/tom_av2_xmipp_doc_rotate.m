function new_doc=tom_av2_xmipp_doc_rotate(doc,transAngle,outputdoc,verbose)
%TOM_AV2_XMIPP_DOC_ROTATE rotates a doc file by a given angle
%
%  new_doc=tom_av2_xmipp_doc_rotate(doc,transAngle,outputdoc)
%  
%
%PARAMETERS
%
%  INPUT
%   doc            input doc as struct or filename
%   transAngle     transoform angle
%   output_doc     (optional) filename of the output doc-file 
%   verbose        (1) verbose flag (0 for silent)
%
%  OUTPUT
%   new_doc        rotated doc file
%
%EXAMPLE
%  
%   new_doc=tom_av2_xmipp_doc_rotate(docit1,[270 90 -43]);
%   
%
%REFERENCES
%
%SEE ALSO
%   
%   by fb 
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

if (nargin<3)
   outputdoc='';
end;
if (nargin<4)
   verbose=1;
end;

if (isstruct(doc)==0)
    if verbose==1
        disp('**  Reading doc file  **');
    end;
    doc=tom_xmippdocread(doc);
end;

if verbose==1
    disp('**  Flip2Tilt on doc file  **');
end;
doc=tom_av2_xmipp_flip2tilt(doc);
new_doc=doc;

if verbose==1
    disp('**  Rotating doc file  **');
end;
for i=1:length(doc)
    tmp_ang=[doc(i).rot doc(i).tilt doc(i).psi];
    tmp_angrot=seqRotZyZ(tmp_ang,transAngle,'InverseTransAng');
    new_doc(i).rot=tmp_angrot(1);
    new_doc(i).tilt=tmp_angrot(2);
    new_doc(i).psi=tmp_angrot(3);
end;
new_doc=tom_av2_xmipp_flip2tilt(new_doc,'',1);

if (isempty(outputdoc)==0)
    if verbose==1
        disp('**  Writing doc file  **');
    end;
    tom_xmippdocwrite(outputdoc,new_doc);
end;


function endAngle=seqRotZyZ(startAngle,TransAngle,flag)

if (strcmp(flag,'InverseTransAng'))
    [~,euler]=tom_eulerconvert_xmipp(startAngle(1),startAngle(2),startAngle(3));
    euler_sum=tom_sum_rotation([-euler(2) -euler(1) -euler(3);TransAngle],[0 0 0;0 0 0]);
    [~,endAngle]=tom_eulerconvert_xmipp(-euler_sum(2),-euler_sum(1),-euler_sum(3),'tom2xmipp');
end;




