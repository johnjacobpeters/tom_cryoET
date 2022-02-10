%% new code below ..needs total reworking
% adjusted for relion (crt f 2.62)
function []=coordinate_picker(cubesize, listName, dir, out, boxsize, pxsz)
output.findWhat = dir;


%% old Code
[fileNames,angles,shifts,list,PickPos]=readList(listName, pxsz);
maskh1=zeros(boxsizeog, boxsizeog, boxsizeog); 
maskh1(round((boxsizeog-cubesize)/2):boxsizeog-round((boxsizeog-cubesize)/2),round((boxsizeog-cubesize)/2):boxsizeog-round((boxsizeog-cubesize)/2),round((boxsizeog-cubesize)/2):boxsizeog-round((boxsizeog-cubesize)/2))=1;

waitbar=tom_progress(length(fileNames),['found: ' num2str(length(fileNames))]); 
parfor i=1:length(fileNames)
    [outH1, posNew(:,i)]=processParticle(fileNames{i},angles(:,i)',shifts(:,i),maskh1,PickPos(:,i)',offSetCenter,boxsizeog,cubesize);
    writeParticle(fileNames{i},outH1, output);
    waitbar.update;
end
waitbar.close();

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
        Align(1,i).Filename=fileNames{i};
        Align(1,i).Angle.Phi=angles(1,i);
        Align(1,i).Angle.Psi=angles(2,i);
        Align(1,i).Angle.Theta=angles(3,i);
        Align(1,i).Shift.X = shifts(1,i); %Shift of particle, will be filled by tom_av3_extract_anglesshifts
        Align(1,i).Shift.Y = shifts(2,i);
        Align(1,i).Shift.Z = shifts(3,i);
    end
end
disp(' ');

function [outH1,posNew]=processParticle(filename,tmpAng,tmpShift,maskh1,PickPos,offSetCenter,boxsizeog, cubesize)

volTmp=tom_mrcread(filename); volTmp=volTmp.Value;
maskh1Trans=tom_shift(tom_rotate(maskh1,tmpAng),tmpShift');
maskh1Trans=maskh1Trans>0.14;


vectTrans=tom_pointrotate(offSetCenter,tmpAng(1),tmpAng(2),tmpAng(3))+tmpShift';
posNew=(round(vectTrans)+PickPos)';
topLeft = [round((boxsizeog-cubesize)/2),round((boxsizeog-cubesize)/2),round((boxsizeog-cubesize)/2)];
%topLeft = [0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cut and filter
outH1=volTmp;
outH1 = tom_cut_out(outH1,topLeft,[cubesize cubesize cubesize]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function writeParticle(filename,outH1,output)

nameLeft=strrep(filename,output.findWhat,output.rplaceWith{1});


pFoldLeft=fileparts(nameLeft);


warning off; mkdir(pFoldLeft); warning on;



if (strcmp(nameLeft,filename))
    error(['check output find what: ' filename ' == ' nameLeft])
end

<<<<<<< HEAD




tom_mrcwrite(outH1,'name',nameLeft);





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






%% actual code

ChimeraX_dir = '/Applications/ChimeraX-1.3.app/Contents/bin';
Input_ChimeraX_command_file = '/Users/johnpeters/Documents/GitHub/tom_cryoET/Dev/chimera3.cxc';


% for i = 1:length(ls(*filt.mrc))
%     print(i)
% end
[status,cmdout] = system([ChimeraX_dir '/ChimeraX ' Input_ChimeraX_command_file]);



<<<<<<< Updated upstream
=======

=======
>>>>>>> 0ce2c4c627ebaf72781d2a2fe72daf0986be11da
>>>>>>> Stashed changes
