function Align=tom_av3_allocAlign(numOfEntries)
%tom_av3_allocAlign allocates default Align Struct
%
%   Align=tom_av3_allocAlign(numOfEntries)
%
%PARAMETERS
%
%  INPUT
%   numOfEntries    number of entries
%
%  OUTPUT
%   Align          Align struct for tom_av3_stackbrowser
%
%EXAMPLE
%   
%   Align=tom_av3_allocAlign(500)
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by fb mm/dd/yy
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



run=1;
for i=1:numOfEntries
    
    Align(run,i).Filename ='';
    Align(run,i).Tomogram.Filename = '';
    Align(run,i).Tomogram.Header = '';
    Align(run,i).Tomogram.Position.X = -1;
    Align(run,i).Tomogram.Position.Y = -1;
    Align(run,i).Tomogram.Position.Z = -1;
    Align(run,i).Tomogram.Regfile = '';
    Align(run,i).Tomogram.Offset = [0 0 0];     %Offset from Tomogram
    Align(run,i).Tomogram.Binning = 0;    %Binning of Tomogram
    Align(run,i).Tomogram.AngleMin = 0;
    Align(run,i).Tomogram.AngleMax = 0;
    Align(run,i).Shift.X = 0; %Shift of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Shift.Y = 0;
    Align(run,i).Shift.Z = 0;
    Align(run,i).Angle.Phi = 0; %Rotational angles of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Angle.Psi = 0;
    Align(run,i).Angle.Theta = 0;
    Align(run,i).Angle.Rotmatrix = []; %Rotation matrix filled up with function tom_align_sum, not needed otherwise
    Align(run,i).CCC = -1; % cross correlation coefficient of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Class = -1;
    Align(run,i).ProjectionClass = 0;
    Align(run,i).NormFlag = 0; %is particle phase normalized?
    Align(run,i).Filter = [0 0]; %is particle filtered with bandpass?
end;