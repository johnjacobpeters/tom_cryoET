function tom_av2_star2RelPick(starFileName,outputfolder,postfix,stretch,verbose)
%tom_av2_star2RelPick transforms  relion .star coordinate files
%
%   tom_av2_star2box(starFileName,outputfolder)
%
%PARAMETERS
%
%  INPUT
%   starFileName      name of the relin .star file
%   outputfolder       name of the outputfolder
%   postfix               ('_manualpick')
%   stretch               struct for iso scale stretching
%   verbose              (1) verbose flag
%
%  OUTPUT
%   
%
%
%EXAMPLE
%
% tom_av2_star2RelPick('sorted.star','Micrographs');
%
%stretch.angle=151.9; 
%stretch.majorScale=1.03; 
%stretch.minorScale=1;
%stretch.imgSize=[3710 3838];
%
%tom_av2_star2RelPick('sorted.star','0_micrographsScale','_autopick',stretch);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 01/24/06
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

if (nargin < 3)
    postfix='_manualpick';
end;

if (nargin < 4)
    stretch='';
end;

if (nargin < 5)
    verbose=1;
end;

dbMode=0;

ext='.star';

star=tom_starread(starFileName);

for i=1:length(star)
    [~,fname]=fileparts(star(i).rlnMicrographName);
    allMicrograhNames{i}=fname;
end;
MicrograhNamesUnique=unique(allMicrograhNames);

if (dbMode==1)
    figure;
end;

nrParts=0;
for i=1:length(MicrograhNamesUnique)
    starName=[outputfolder filesep MicrograhNamesUnique{i} postfix ext];
    idxM=find(ismember(allMicrograhNames, MicrograhNamesUnique{i}));
    coords_x=zeros(length(idxM),1);
    coords_y=zeros(length(idxM),1);
    for ii=1:length(idxM)
        coords_x(ii)=round(star(idxM(ii)).rlnCoordinateX);
        coords_y(ii)=round(star(idxM(ii)).rlnCoordinateY);
        if (isempty(stretch)==0)
            [coords_x(ii),coords_y(ii)]=transForm(coords_x(ii), coords_y(ii),stretch.angle,stretch.majorScale,stretch.minorScale,stretch.imgSize);
        end;
        
        if (coords_x<0)
            error([ star(idxM(ii)).rlnMicrographName ' negative X coordinate ' ]);
        end;
        if (coords_y<0)
            error([ star(idxM(ii)).rlnMicrographName ' negative Y coordinate ' ]);
        end;
     end;
    
     if (dbMode)
        img=tom_mrcread(['aligned' filesep MicrograhNamesUnique{i} '.mrc']);
        tom_imagesc(tom_filter(img.Value,7));
        hold on; plot(coords_x+round(EmanBoxSize./2),coords_y+round(EmanBoxSize./2),'ro'); hold off;
    end;
    
    write_star(starName,coords_x,coords_y);
    
    if (verbose==1)
        disp(['processed  ' MicrograhNamesUnique{i} ' ' num2str(length(coords_x)) ' particles ==> ' starName]);
    end;
    nrParts=nrParts+length(coords_x);
end;

disp(['Nr Particles in (output) .star files: ' num2str(nrParts)]);
disp(['Nr Particles in (input) .star file ' num2str(length(star))]);


function [xTr,yTr]=transForm(x,y,angle,majorScale,minorScale,imgSize)

imgSize=round(imgSize./2)+1;

%transForm cosy
xTr=(x-imgSize(1)); 
yTr=(y-imgSize(2));
r=tom_pointrotate2d([xTr yTr],angle);
 
%scale cosy
xTr=r(1).*majorScale;
yTr=r(2).*minorScale;
 
%transForm cosy back
r=tom_pointrotate2d([xTr yTr],-angle);
xTr=(r(1)+imgSize(1)); 
yTr=(r(2)+imgSize(2));




function write_star(name,coords_x,coords_y)


fid=fopen(name,'wt');
fprintf(fid,'\n');
fprintf(fid,'data_\n');
fprintf(fid,'\n');
fprintf(fid,'loop_\n'); 
fprintf(fid,'_rlnCoordinateX #1\n'); 
fprintf(fid,'_rlnCoordinateY #2\n');
for i=1:length(coords_x)
    fprintf(fid,' %f %f \n',coords_x(i),coords_y(i));
end;
fclose(fid);


