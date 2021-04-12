function doc=tom_av2_xmipp_docUniqueRef(doc,outputName)
%TOM_AV2_XMIPPUNIQUEREF creates unique ref numbers in docFile
%
%   doc=tom_av2_xmipp_docUniqueRef(doc)
%
%PARAMETERS
%
%  INPUT
%   doc                 input xmipp doc-file
%   outputName          ('') output Filen Name
%  
%  OUTPUT
%   doc                 output xmipp doc-file
%
%EXAMPLE
%   read image
%
%REFERENCES
%
%SEE ALSO
%   tom_xmippdocread
%
%   created by FB 03/20/15
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

if (nargin<2)
    outputName='';
end;


if (isstruct(doc)==0)
    doc=tom_xmippdocread(doc);
end;



allRot=[doc(:).rot];
allTilt=[doc(:).tilt];

rotTilt=[allRot; allTilt]';
rotTiltUnique=unique(rotTilt,'rows');



for i=1:size(rotTiltUnique,1)
    idx=find(ismember(rotTilt,rotTiltUnique(i,:),'rows'));
    for ii=1:length(idx)
        doc(idx(ii)).ref=i;
    end;
end;


tom_xmippdocwrite(outputName,doc);




