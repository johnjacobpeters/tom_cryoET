function mergedAlign=tom_av3_mergeAlign(AlingRef,AlignComp,radius,outputFilename,classRef,classCmp,dispMode)
%TOM_AV3_MERGEALIGN merges 2 Aling lists according to ther pick coords
% 
% 
%  mergedAlign=tom_av3_mergeAlign(AlingRef,AlignComp,radius)
%  
%
%PARAMETERS
%
%  INPUT
%   AlingRef           reference Alignment list
%   AlignComp          comp Alignment list
%   radius             radis for double hit
%   outputFilename     ('') name for outputFile  
%   classRef           (0) class number in merged List for Ref 
%   classComp          (1) class number in merged List for Comp
%   dispMode           (0) diplay mode 1 to 3 
%
%  OUTPUT
%   mergedAlign        merged Align List
%
%EXAMPLE
%
% 
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 04/03/15
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
    outputFilename='';
end;

if (nargin<5)
    classRef=0;
end;

if (nargin<6)
    classCmp=1;
end;

if (nargin<7)
    dispMode=0;
end;

if (isstruct(AlingRef)==0)
    AlingRef=load(AlingRef); 
    AlingRef=AlingRef.Align;
end;

if (isstruct(AlignComp)==0)
    AlignComp=load(AlignComp);
    AlignComp=AlignComp.Align;
end;

disp(['length Ref: ' num2str(size(AlingRef,2)) ]);
disp(['length Comp: ' num2str(size(AlignComp,2)) ]);
disp(['total: ' num2str(size(AlingRef,2) + size(AlignComp,2))]);

AlingRef=setClass(AlingRef,classRef);
AlignComp=setClass(AlignComp,classCmp);

coordsRef=getCoordinates(AlingRef);
coordsComp=getCoordinates(AlignComp);
[idxMatch,~,~,idxUnRef,idxUnComp,idxOverComp]=tom_matchFeatureLists(coordsRef,coordsComp,radius,0,dispMode);
idxUnComp=cat(2,idxUnComp,idxOverComp);


if (isempty(idxMatch)==0)
    mergedOverLab=removeDoubleHitsByCC(AlingRef(1,idxMatch(:,1)),AlignComp(1,idxMatch(:,2)));
    mergedAlign=cat(2,AlingRef(1,idxUnRef),AlignComp(1,idxUnComp),mergedOverLab);
else
    mergedAlign=cat(2,AlingRef(1,idxUnRef),AlignComp(1,idxUnComp));
end;

disp(['overlapping (rad: ' num2str(radius)  '): ' num2str(length(idxMatch)) ' pairs == ' num2str(length(idxMatch).*2 ) ' particles']);
disp(['length merged ' num2str(length(mergedAlign))]);

coordsMerged=getCoordinates(mergedAlign);
tmpDist=sort(pdist(coordsMerged));

if (isempty(tmpDist))
     disp('only one Coordinate remaining so no min dist!');   
else
    disp(['min dist of merged: ' num2str(tmpDist(1))]);
end;

if (isempty(outputFilename)==0)
    Align=mergedAlign;
    save(outputFilename,'Align')
end

function Align=setClass(Align,classNr)

for i=1:size(Align,2)
    Align(1,i).Class=classNr;
end;


function mergedOverLab=removeDoubleHitsByCC(AlingRef,AlignComp)

mergedOverLab=AlingRef;
for i=1:size(AlingRef)
    if (AlingRef(1,i).CCC >= AlignComp(1,i).CCC)
        mergedOverLab(1,i)=AlingRef(1,i);
    else
        mergedOverLab(1,i)=AlignComp(1,i);
    end;
end;


function coords=getCoordinates(Align)


for i=1:size(Align,2)
    coords(i,1)=Align(1,i).Tomogram.Position.X;
    coords(i,2)=Align(1,i).Tomogram.Position.Y;
    coords(i,3)=Align(1,i).Tomogram.Position.Z;
end;



