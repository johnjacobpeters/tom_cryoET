function volFilt=tom_filterZ(vol,kernelSize,volNameOut)
%TOM_FILTERZ performs z-slice averageing
%
%    volFilt=tom_filterZ(vol,kernelSize)
%
%PARAMETERS
%
%  INPUT
%   vol                                input Volume  
%   kernelSize                    amount of z-slices to be averaged
%   volNameOut                 (opt.)output volume Name   
% 
%  OUTPUT
%
%   volFilt	                 filtered volume
%
%EXAMPLE
%   %avg 5 slices
%   vol=tom_mrcread('test.mrc');
%   volFilt=tom_filterZ(vol,5);
%  
%   %avg 10 slices read from file and write to file
%   tom_filterZ('myTomo.mrc',10,'myTomoFilt.mrc');
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 04/06/17
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

if (nargin <3)
    volNameOut='';
end;

if (isnumeric(vol)==0)
    vName=vol;
    clear('vol');
    disp(['reading: ' vName]);
    if (tom_isemfile(vName))
        vol=tom_emread(vName);
        vol=vol.Value;
    else
        vol=tom_mrcread(vName);
        vol=vol.Value;
    end;
    disp(' ');
end;

volFilt=zeros(size(vol),'single');
hKz=round(kernelSize./2);

waitbar=tom_progress(size(vol,3),'filtering '); 
for iz=1:size(vol,3)
    startInd=iz-hKz;
    if (startInd<1);
        startInd=1;
    end;
    stopInd=iz+hKz;
    if (stopInd>size(vol,3))
        stopInd=size(vol,3);
    end;
    tmpVol=vol(:,:,startInd:stopInd);
    volFilt(:,:,iz)=sum(tmpVol,3)./size(tmpVol,3);
    waitbar.update();
end;
waitbar.close;
 
if (isempty(volNameOut)==0)
    disp(['writing to: ' volNameOut]);
    tom_mrcwrite(volFilt,'name',volNameOut);
    disp(' done!');
end;
