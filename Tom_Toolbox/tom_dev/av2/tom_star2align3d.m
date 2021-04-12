function Align=tom_star2align3d(starFileName,AlignFileName,bin)
%tom_star2align3d transform relion star file to tom Aling
%
%    Align=tom_star2align3d(starFileName,AlignFileName)
%
%
%PARAMETERS
%
%  INPUT
%   starFileName         name of input star file
%   AlignFileName       (otp.) name of Aling file
%   bin                          (opt.) binning factor      
%  
%  OUTPUT
%   Align          Align st
%
%
%EXAMPLE
%
% Align=tom_star2align3d('myFile.star');
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


if (nargin<2)
    AlignFileName='';
end;


star=tom_starread(starFileName);

Align=tom_av3_allocAlign(length(star));



for i=1:length(star)
    Align(1,i).Tomogram.Position.X=round(star(i).rlnCoordinateX./bin);
    Align(1,i).Tomogram.Position.Y=round(star(i).rlnCoordinateY./bin);
    Align(1,i).Tomogram.Position.Z=round(star(i).rlnCoordinateZ./bin);
    [~,eu]=tom_eulerconvert_xmipp(star(i).rlnAngleRot,star(i).rlnAngleTilt,star(i).rlnAnglePsi);
    Align(1,i).Angle.Phi=eu(1);
    Align(1,i).Angle.Psi=eu(2);
    Align(1,i).Angle.Theta=eu(3);
end;

if (isempty(AlignFileName)==0)
    save(AlignFileName,'Align');
end;

