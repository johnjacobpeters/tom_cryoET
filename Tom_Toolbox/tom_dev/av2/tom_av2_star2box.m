function tom_av2_star2box(starFileName,outputfolder,EmanBoxSize,boxExt,funny_number)
%tom_av2_star2box generates eman .box from star
%
%   tom_av2_star2box(starFileName,outputfolder)
%
%PARAMETERS
%
%  INPUT
%   starFileName      name of the relin .star file
%   outputfolder      name of the outputfolder
%   EmanBoxSize       size 4 Eman box-file
%   boxExt            (.box) extension of box files   
%   funny_number      (-3) funny number in eman box files   
%
%  OUTPUT
%   
%
%
%EXAMPLE
%
% tom_av2_star2box('sorted.star','Micrographs',160);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by SN/FB 01/24/06
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

if (nargin < 4)
    boxExt='.box';
end;
if (nargin < 5)
    funny_number=-3;
end;

dbMode=0;

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
    boxName=[outputfolder filesep MicrograhNamesUnique{i} boxExt];
    idxM=find(ismember(allMicrograhNames, MicrograhNamesUnique{i}));
    coords_x=zeros(length(idxM),1);
    coords_y=zeros(length(idxM),1);
    for ii=1:length(idxM)
        coords_x(ii)=round(star(idxM(ii)).rlnCoordinateX-round(EmanBoxSize./2));
        coords_y(ii)=round(star(idxM(ii)).rlnCoordinateY-round(EmanBoxSize./2));
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
    
    write_box(boxName,coords_x,coords_y,[EmanBoxSize EmanBoxSize],funny_number);
    
    disp(['processed  ' MicrograhNamesUnique{i} ' ' num2str(length(coords_x)) ' particles ==> ' boxName]);
    nrParts=nrParts+length(coords_x);
end;

disp(['Nr Particles in (output) .box files: ' num2str(nrParts)]);
disp(['Nr Particles in (input) .star file ' num2str(length(star)) ]);

function write_box(filename,coords_x,coords_y,box_size,funny_number)

fid=fopen(filename,'w');

for i=1:length(coords_x)
    fprintf(fid,'%d\t%d\t%d\t%d\t%d\n',coords_x(i),coords_y(i),box_size(1),box_size(2),funny_number);
end;

fclose(fid);