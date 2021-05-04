function [cccvalue] = calculate_ccc(listName,pxsz, corrvol)

volume = tom_mrcread('mask.mrc');
volume = volume.Value;
[fileNames,angles,shifts,list,PickPos]=readList(listName, pxsz);
cccvalue=[];
tmpVol = [];
for i=1:length(fileNames)
    %disp(fileNames{i})
    tmpVol = tom_mrcread(fileNames{i});
    tmpVol = tmpVol.Value;
    cccvalue(i)=tom_ccc(tmpVol,volume);
end


disp('done ');

function [fileNames,angles,shifts,list,PickPos]=readList(listName,pxsz)

[~,~,ext]=fileparts(listName);

if (strcmp(ext,'.star'))
    list=tom_starreadrel3(listName);
    Align=allocAlign(length(list));
    for i=1:length(list)
        fileNames{i}=list(i).rlnImageName;
        PickPos(:,i)=[list(i).rlnCoordinateX list(i).rlnCoordinateY list(i).rlnCoordinateZ];
        shifts(:,i)=[-list(i).rlnOriginXAngst/pxsz -list(i).rlnOriginYAngst/pxsz -list(i).rlnOriginZAngst/pxsz];
        [~,angles(:,i)]=tom_eulerconvert_xmipp(list(i).rlnAngleRot,list(i).rlnAngleTilt,list(i).rlnAnglePsi);
        %[angles(:,i)]=[list(i).rlnAngleRot,list(i).rlnAngleTilt,list(i).rlnAnglePsi];
        Align(1,i).Filename=fileNames{i};
        Align(1,i).Angle.Phi=angles(1,i);
        Align(1,i).Angle.Psi=angles(2,i);
        Align(1,i).Angle.Theta=angles(3,i);
        angles(:,i)=[Align(1,i).Angle.Psi,Align(1,i).Angle.Phi,Align(1,i).Angle.Theta];
        Align(1,i).Shift.X = shifts(1,i); %Shift of particle, will be filled by tom_av3_extract_anglesshifts
        Align(1,i).Shift.Y = shifts(2,i);
        Align(1,i).Shift.Z = shifts(3,i);
    end
end
end

function Align=allocAlign(nr)

run=1;
for i=1:nr
    Align(run,i).Filename = '';
    Align(run,i).Tomogram.Filename = '';
    Align(run,i).Tomogram.Header = '';
    Align(run,i).Tomogram.Position.X =0; %Position of particle in Tomogram (values are unbinned)
    Align(run,i).Tomogram.Position.Y = 0;
    Align(run,i).Tomogram.Position.Z = 0;
    Align(run,i).Tomogram.Regfile = '';
    Align(run,i).Tomogram.Offset = 0;     %Offset from Tomogram
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
    Align(run,i).CCC = 0; % cross correlation coefficient of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Class = 0;
    Align(run,i).ProjectionClass = 0;
    Align(run,i).NormFlag = 0; %is particle phase normalized?
    Align(run,i).Filter = [0 0]; %is particle filtered with bandpas
    
end
end


end