function [errorSt]=tom_av3_compareAlign(refList,compList,matchFlag,verbose)
%TOM_AV3_COMPAREALIGN compares 2 alignment listst
%  [angles,shifts,ccf_peak,rot_part,ccf_max,angle_max,rotM]=tom_av3_align(ref,part,phi,psi,theta,mask,filter,mask_ccf,wedge_ref,wedge_part,nrOptSteps)
%
%PARAMETERS
%
%  INPUT
%   refList               reference Align List
%   compList              compare Align List
%   matchFlag             ('Full-FileName') match by entry in Filename
%                         'Order' match by oder
%                         'Filename' match by filename path will be removed
%
%   verbose               ([0 0]) use [1 1] for graphical and 
%
%
%  OUTPUT
%   errorSt               structure containing the erros
%   idx                   idx of matched structures
%
%EXAMPLE
%  
% errors=tom_av3_compareAlign(refList,compList);
% 
% 
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 19/03/15
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
    matchFlag='Full-FileName';
end;

if (nargin<4)
    verbose=[1 1];
end;

if (isstruct(refList)==0)
    load(refList);
    refList=Align;
end;

if (isstruct(compList)==0)
    load(compList);
    compList=Align;
end;

idx=matchLists(refList,compList,matchFlag);


if (verbose(1)==1)
    disp([num2str(length(idx)) ' of '  num2str(size(refList,2)) ' could be matched with compList(' num2str(size(compList,2)) ')' ]);
end;
  
compListSorted=compList(1,idx);

for i=1:size(refList,2)
    errorSt(i)=calcErrors(refList(1,i),compListSorted(1,i));
end;



if (verbose(1))
    disp(' ');
    disp(' ');
    disp('Error Stat:')
    disp(' ');
    disp('Rotation Error:');
    tom_dev([errorSt(:).angError]);
    disp(' ');
    disp('Shift Error:');
    tom_dev([errorSt(:).shError]);
    disp(' ');
    disp('Class Error:');
    tom_dev([errorSt(:).classError]);
    disp(' ');
    disp('Pos Error:');
    tom_dev([errorSt(:).posError]);
    disp(' ');
end;

if (verbose(2))
    figure;
    subplot(1,4,1); hist([errorSt(:).angError]); title('Rotation Error');
    subplot(1,4,2); hist([errorSt(:).shError]); title('Shift Error');
    subplot(1,4,3); hist([errorSt(:).classError]); title('Classification Error');
    subplot(1,4,4); hist([errorSt(:).posError]); title('Position Error');
end;




function st=calcErrors(ref,comp)

st.angError=tom_angular_distance([ref.Angle.Phi ref.Angle.Psi ref.Angle.Theta],[comp.Angle.Phi comp.Angle.Psi comp.Angle.Theta]);
st.shError=pdist([ref.Shift.X ref.Shift.Y ref.Shift.Z;comp.Shift.X comp.Shift.Y comp.Shift.Z]);
st.posError=pdist([ref.Tomogram.Position.X ref.Tomogram.Position.Y ref.Tomogram.Position.Z;comp.Tomogram.Position.X comp.Tomogram.Position.Y comp.Tomogram.Position.Z]);
st.classError=ref.Class~=comp.Class;

if (st.angError>70)
    disp(' ');
end;



function idx=matchLists(refList,compList,matchFlag)

for i=1:size(refList,2)
    nameTmp=refList(1,i).Filename;
    if (strcmp(matchFlag,'Filename'))
        [~,fName,fext]=fileparts(nameTmp);
        nameTmp=[fName fext];
    end;
    namesRef{i}=nameTmp;
end;

for i=1:size(compList,2)
    nameTmp=compList(1,i).Filename;
    if (strcmp(matchFlag,'Filename'))
        [~,fName,fext]=fileparts(nameTmp);
        nameTmp=[fName fext];
    end;
    namesComp{i}=nameTmp;
end;

[~,idx]=ismember(namesRef,namesComp);



















