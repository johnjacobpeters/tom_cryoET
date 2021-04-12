function tom_pytomXmlPartlist_write(filename,Align)
%tom_pytomXmlPartlist_write writes Align to xml python
%
%   tom_pytomXmlPartlist_write(Align,filename)
%
%PARAMETERS
%
%  INPUT
%   filename          output filename
%   Align             Align struct    
%
%  OUTPUT
%
%EXAMPLE
%  
% tom_pytomXmlPartlist_write('test.xml',Align);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 17/11/15
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




if (isstruct(Align)==0)
    load(Align);
end;


%create xml-list
fid=fopen(filename,'wt');
fprintf(fid,'<!-- PyTom Version: 0.963 -->\n');
fprintf(fid,'<ParticleList>\n');

for i =1:size(Align,2)
    fprintf(fid,'<Particle Filename="%s">\n',Align(1,i).Filename);
    fprintf(fid,'  <Rotation X="%f" Paradigm="ZXZ" Z1="%f" Z2="%f"/>\n',Align(1,i).Angle.Theta,Align(1,i).Angle.Phi,Align(1,i).Angle.Psi);
    fprintf(fid,'  <Shift Y="%f" X="%f" Z="%f"/>\n',Align(1,i).Shift.Y,Align(1,i).Shift.X,Align(1,i).Shift.Z);
    fprintf(fid,'  <PickPosition Origin="" Y="%f" Z="%f" X="%f"/>\n',Align(1,i).Tomogram.Position.Y,Align(1,i).Tomogram.Position.Z,Align(1,i).Tomogram.Position.X);
    fprintf(fid,'  <Wedge Type="SingleTiltWedge">\n');
    fprintf(fid,'    <SingleTiltWedge Smooth="0.0" Angle1="%f" CutoffRadius="0.0" Angle2="%f">\n',Align(1,i).Wedge.Angle1,Align(1,i).Wedge.Angle2);
    fprintf(fid,'      <TiltAxisRotation Z1="0.0" Z2="0.0" X="0.0"/>\n');
    fprintf(fid,'    </SingleTiltWedge>\n');
    fprintf(fid,'  </Wedge>\n');
    fprintf(fid,'  <Score Type="FRMScore" RemoveAutocorr="False" Value="0">\n');
    fprintf(fid,'    <PeakPrior Smooth="-1.0" Radius="0.0" Filename=""/>\n');
    fprintf(fid,'  </Score>\n');
    if (isnumeric(Align(1,i).Class))
        fprintf(fid,'  <Class Name="%d"/>\n',Align(1,i).Class);
    else
        fprintf(fid,'  <Class Name="%s"/>\n',Align(1,i).Class);
    end;
    fprintf(fid,'</Particle>\n');
end


fprintf(fid,'</ParticleList>\n');
fclose(fid);













