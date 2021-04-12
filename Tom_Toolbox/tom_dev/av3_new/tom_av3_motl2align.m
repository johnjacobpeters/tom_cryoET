function Align=tom_av3_motl2align(motl,partBaseName,ext,tomoFileName,tomoBinnig,tomoOffset)
%TOM_AV3_MOTL2ALIGN transform a motl 2 a Align List
%
%   Align=tom_av3_motl2align(motl,partBaseName,ext,tomoFileName,tomoBinnig,tomoOffset)
%
%PARAMETERS
%
%  INPUT
%   motl            motiveList 
%   partBaseName    ('part_') baseName 4 Particles 
%   ext             ('.em') extension 4 Particles  
%   tomoFileName    ('') filename of tomo
%   tomoBinnig      (0)  binning of tomo
%   tomoOffset      ([0 0 0]) offset from tomo 4 backpro
%
%  OUTPUT
%   Align          Align struct for tom_av3_stackbrowser
%
%EXAMPLE
%   
%   Align=tom_av3_motl2align(motl,'/fs/pool/parts/part_','.em','./myTomo.em',0);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by .. mm/dd/yy
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

if (isnumeric(motl)==0)
    motl=tom_emread(emfile);
    motl=motl.Value;
end;

if (nargin<2)
    partBaseName='part_';
end;

if (nargin<3)
    ext='.em';
end;

if (nargin<4)
    tomoFileName='';
end;

if (nargin<5)
    tomoFileName='';
end;

if (nargin<6)
    tomoOffset=[0 0 0];
end;



run=1;
for i=1:size(motl,2)
    
    Align(run,i).Filename =[partBaseName num2str(motl(4,i)) ext];
    Align(run,i).Tomogram.Filename = tomoFileName;
    Align(run,i).Tomogram.Header = '';
    Align(run,i).Tomogram.Position.X = motl(8,i);
    Align(run,i).Tomogram.Position.Y = motl(9,i);
    Align(run,i).Tomogram.Position.Z = motl(10,i);
    Align(run,i).Tomogram.Regfile = '';
    Align(run,i).Tomogram.Offset = tomoOffset;     %Offset from Tomogram
    Align(run,i).Tomogram.Binning = tomoBinnig;    %Binning of Tomogram
    Align(run,i).Tomogram.AngleMin = 0;
    Align(run,i).Tomogram.AngleMax = 0;
    Align(run,i).Shift.X = motl(11,i); %Shift of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Shift.Y = motl(12,i);
    Align(run,i).Shift.Z = motl(13,i);
    Align(run,i).Angle.Phi = motl(17,i); %Rotational angles of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Angle.Psi = motl(18,i);
    Align(run,i).Angle.Theta = motl(19,i);
    Align(run,i).Angle.Rotmatrix = []; %Rotation matrix filled up with function tom_align_sum, not needed otherwise
    Align(run,i).CCC = motl(1,i); % cross correlation coefficient of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Class = motl(20,i);
    Align(run,i).ProjectionClass = 0;
    Align(run,i).NormFlag = 0; %is particle phase normalized?
    Align(run,i).Filter = [0 0]; %is particle filtered with bandpass?
    
%     if (mod(i,100)==0)
%         disp([num2str(i) ' of ' num2str(size(motl,2)) ' done!']);
%     end;
end;

