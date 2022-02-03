%write selected particles back to star format. modification is needed... 

sel_file = 'nova2clean.mat'; % typical Align file from TOM
star_file = 'Class3D/job007/run_it050_data.star'; %template for the readout,just one of the old ones from classification should work, but this one should be longer than the length of your sel file.  
out_starfile = '20200416_cleaned2_nova_phfl.star'; %output

load(sel_file);
list = tom_starread(star_file);

for i = 1:length(Align)
        list(i).rlnImageName = Align(1,i).Filename ;
        list(i).rlnMicrographName= Align(1,i).Tomogram.Filename ;
        list(i).rlnCoordinateX = Align(1,i).Tomogram.Position.X;
        list(i).rlnCoordinateY = Align(1,i).Tomogram.Position.Y;
        list(i).rlnCoordinateZ = Align(1,i).Tomogram.Position.Z;
        %the three values below werea ll multiplied by -1 to fix a sign
        %flipping
        list(i).rlnOriginX = Align(1,i).Shift.X*-1;
        list(i).rlnOriginY = Align(1,i).Shift.Y*-1;
        list(i).rlnOriginZ = Align(1,i).Shift.Z*-1;
        [~,angles(:,i)]=tom_eulerconvert_xmipp(Align(1,i).Angle.Phi,Align(1,i).Angle.Psi,Align(1,i).Angle.Theta,'tom2xmipp');
        list(i).rlnAngleRot = angles(1,i);
        list(i).rlnAngleTilt = angles(2,i);
        list(i).rlnAnglePsi = angles(3,i);
        list(i).rlnCtfImage = Align(1,i).CTFname; %you can have longer list if you want.
       
end

for i = (length(Align)+1): length(list)
    list(length(Align)+1) = [];
 end


tom_starwrite(out_starfile,list);

        
        
 
      
    
