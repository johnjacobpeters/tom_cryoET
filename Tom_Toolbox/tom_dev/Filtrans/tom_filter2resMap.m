function fmap=tom_filter2resMap(map,resmap,pixs,groups,minRes,outputName,smooth,minBfactor)
%TOM_FILTER2RESMAP filters a volume to a given resolution Map (comp blockfilt)
%
%
%   fmap=tom_filter2resMap(map,resmap,pixs,groups)
%
%PARAMETERS
%
%  INPUT
%   map                  input 3D volume
%   resmap               input 3D resmap
%   pixs                 objectpixelsize in Angstrom  
%   groups               (2.5:0.2:50) resolutionGroups
%                                     for speedup use minRes:incre:maxRes  
%                                     e.g. single particle 2.5:0.2:12
%                                     e.g. cell tomography 20:0.5:50  
%   minRes               (max(groups)) default is the maximum of the resolution groups
%                                      sometimes it can be helpful to give a 2A offset to the groups%                                     
%   outputName           (opt.) name of the filtered volume 
%   smooth               (2) smoothing in voxels for four. filter mask
%   minBfactor           (0) experimental flag helps to get more homogenius threshold by setting to 200 for the low freq 
%  
%
%  OUTPUT
%   fmap                 filtered volume
%
%EXAMPLE
% 
% %standard blockfilt behaviour 
% filt=tom_filter2resMap('map4filt.em','resCorr.em',1.4,[3.5:0.1:7]);
% 
% %exp setup 
% filt=tom_filter2resMap('map4filt.em','resCorr.em',1.4,[3.5:0.1:6],7,'filt.mrc',2,250);
%
%REFERENCES
%
%SEE ALSO
%
%   created by fb 14/03/16 
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
    groups=[2.5:0.2:50];
end;

if (nargin<5)
   minRes=max(groups);
end;

if (nargin<6)
   outputName=''; 
end;

if (nargin<7)
   smooth=2; 
end;

if (nargin<8)
   minBfactor=0; 
end;

[map,resmap]=readInputs(map,resmap);

fmap=tom_filter2resolution(map,pixs,minRes,smooth);

if (minBfactor~=0)
    fmap=tom_apply_bfactor(fmap,pixs,minBfactor,1,[minRes Inf]);
end;

waitbar=tom_progress(length(groups),'filtering to res.'); 
for i=1:length(groups)
    if (i==1)
        idx=find(resmap<groups(i));
    end;
    if (i>1) && (i<length(groups))
        idx=find((resmap(:)>groups(i-1)) .* (resmap(:)<groups(i)));
    end;
    voltmp=tom_filter2resolution(map,pixs,groups(i),smooth);
    fmap(idx)=voltmp(idx);
    waitbar.update();
end;
waitbar.close;

writeOutput(fmap,outputName);

function writeOutput(fmap,outputName)

if (isempty(outputName)==0)
    [~,~,c]=fileparts(outputName);
    if (strcmp(c,'.em'))
        tom_emwrite(outputName,fmap);
    end;
    if (strcmp(c,'.mrc'))
        tom_mrcwrite(fmap,'name',outputName);
    end;
end;


function [map,resmap]=readInputs(map,resmap)

if (ischar(map))
    if (tom_isemfile(map))
        map=tom_emread(map);
        map=map.Value;
    end;
end;

if (ischar(map))
    if (tom_ismrcfile(map))
        map=tom_mrcread(map);
        map=map.Value;
    end;
end;

if (ischar(resmap))
    if (tom_isemfile(resmap))
        resmap=tom_emread(resmap);
        resmap=resmap.Value;
    end;
end;

if (ischar(resmap))
    if (tom_ismrcfile(resmap))
        resmap=tom_mrcread(resmap);
        resmap=resmap.Value;
    end;
end;
 
