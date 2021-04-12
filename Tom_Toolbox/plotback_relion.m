

function plotback_relion(listName, ref, output)
%%% this function is used to plotback the relion refinement/classfication result back to tomogram. 
%%% you need to change the size of tomogram according to your project
%%% this script assume you have fullsize relion result and want to plot back to bin4 for visulization. 
%%% Qiang Guo @ 26-07-2019

ref = tom_mrcread(ref);
ref = ref.Value;
ref_bin = tom_rescale3d(ref,size(ref)/4);
list=tom_starread(listName);

%%% empty volume of tomogram size
org1 = zeros(104,104,104);


%creat empty Align file
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
    
end

% fill in the Align file 
    for i=1:length(list)
        fileNames{i}=list(i).rlnImageName;
        Align(1,i).Tomogram.Position.X = list(i).rlnCoordinateX;
        Align(1,i).Tomogram.Position.Y = list(i).rlnCoordinateY;
        Align(1,i).Tomogram.Position.Z = list(i).rlnCoordinateZ;
        shifts(:,i)=[-list(i).rlnOriginX -list(i).rlnOriginY -list(i).rlnOriginZ];
        [~,angles(:,i)]=tom_eulerconvert_xmipp(list(i).rlnAngleRot,list(i).rlnAngleTilt,list(i).rlnAnglePsi);
        Align(1,i).Filename=fileNames{i};
        Align(1,i).Angle.Phi=angles(1,i);
        Align(1,i).Angle.Psi=angles(2,i);
        Align(1,i).Angle.Theta=angles(3,i);
        Align(1,i).Shift.X = shifts(1,i); %Shift of particle, will be filled by tom_av3_extract_anglesshifts
        Align(1,i).Shift.Y = shifts(2,i);
        Align(1,i).Shift.Z = shifts(3,i);
    end;
   
    
    %%start project back vols, 

    
    
    
    for i = 1:size(Align,2)
        
    %%% get bin4 positions and shifts
           
            peakpos=[Align(1,i).Tomogram.Position.X  Align(1,i).Tomogram.Position.Y Align(1,i).Tomogram.Position.Z]/4;
            tmpShift=[Align(i).Shift.X Align(i).Shift.Y Align(i).Shift.Z]/4;
           
    
                
       %%% pastes average back in
       
       
                tmpRot=tom_shift(tom_rotate(ref_bin,[Align(i).Angle.Phi Align(i).Angle.Psi Align(i).Angle.Theta]),tmpShift);
                topLeft=round(peakpos-(size(ref_bin,2)./2));
                org1=tom_paste2(org1,tmpRot,topLeft,'max');
                
                disp([num2str(i) ' out of ' num2str(size(Align,2)) ' done'])
              
         
    end
    %org1=org1
    tom_mrcwrite(org1,'name',output);
    
    clear Align

