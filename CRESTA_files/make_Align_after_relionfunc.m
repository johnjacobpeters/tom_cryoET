% this function is using relion result to generate bin4 particles/Align file for tom_av3 verification 
% need to change the binning size and cropping size 

function make_Align_after_relionfunc(stackstar, pxsz)
starName = stackstar; %star file need to be checked
list=tom_starreadrel3(starName);
matfile_align = './Align.mat'; % output Align file 
%create empty Align file
run=1;
for i=1:length(list)
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
    Align(run,i).CTFname = ''; %test, ctf file information 
    
end

% fill in the Align file 
    for i=1:length(list)
        Align(run,i).Tomogram.Filename = list(i).rlnMicrographName;
        fileNames{i}=list(i).rlnImageName;
        Align(1,i).Tomogram.Position.X = list(i).rlnCoordinateX;
        Align(1,i).Tomogram.Position.Y = list(i).rlnCoordinateY;
        Align(1,i).Tomogram.Position.Z = list(i).rlnCoordinateZ;
        shifts(:,i)=[-list(i).rlnOriginXAngst -list(i).rlnOriginYAngst -list(i).rlnOriginZAngst];
        [~,angles(:,i)]=tom_eulerconvert_xmipp(list(i).rlnAngleRot,list(i).rlnAngleTilt,list(i).rlnAnglePsi);
        [filename,ext]= strtok(fileNames{i},'.');
        Align(1,i).Filename=[filename,'.em'];
        Align(1,i).Angle.Phi=angles(1,i);
        Align(1,i).Angle.Psi=angles(2,i);
        Align(1,i).Angle.Theta=angles(3,i);
        Align(1,i).Shift.X = shifts(1,i)/pxsz; %Shift of particle, will be filled by tom_av3_extract_anglesshifts
        Align(1,i).Shift.Y = shifts(2,i)/pxsz;
        Align(1,i).Shift.Z = shifts(3,i)/pxsz;
        %Align(1,i).CCC = list(i).rlnLogLikeliContribution; 
        Align(1,i).CTFname = list(i).rlnCtfImage; % test,ctf file information
    end
   
        save(matfile_align,'Align');
        dc_particles(list); 
    
end


% filter and binning the tomograms, crop them if needed. 
function dc_particles(list)
for i=1:length(list)
    list(i).rlnImageName;
    par = tom_mrcread(list(i).rlnImageName);
    par = par.Value;    
    %crop = zeros(30,30,30); %size of cut out
    %crop=tom_cut_out(dcpar,'center',size(crop));
    [filename,ext]= strtok(list(i).rlnImageName,'.');
    dc_out=[filename,'.em'];
    tom_emwrite(dc_out,par); % change to dcpar if no cropping is needed
end


    
 
   
end
