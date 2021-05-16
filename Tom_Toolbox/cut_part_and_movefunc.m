%% unlike another script, this one cut the particle from the particles not tomograms, which induced interpolation. 
% adjusted for relion (crt f 2.62)
function []=cut_part_and_movefunc(maskName_h1, listName, dir, out, boxsize, pxsz, filter, grow, normalizeit, sdRange, sdShift,blackdust,whitedust)

%maskName_h1='20210309erasecln.mrc';
%listName='20210201_201810XX_ZYZ.star';
%listName='20210201_20190321_ZYZ.star';
%listName='20210201_201906_ZYZ.star';
%listName='20210201_201909_ZYZ.star';
%listName='20210201_20191105_ZYZcor226.star';
%listName='20210201_20191108_ZYZ.star';
%output.findWhat='Extract/extract_test/201810XX_MPI/';
%output.findWhat='Extract/extract_test/20190321_MPI/';
%output.findWhat='Extract/extract_test/20190611_MPI/';
%output.findWhat='Extract/extract_test/20190920_MPI/';
%output.findWhat='Extract/extract_test/20191105_MPI/';
%output.findWhat='Extract/extract_test/20191108_MPI/';
output.findWhat = dir;
output.rplaceWith{1}=out;
%pxsz=str2double(pxsz)
%grow=str2double(grow);
%output.rplaceWith{1}='Extract/extract_test/20190611_MPI_cut_erasetest/';
%2.62 below has been changed!!!

offSetCenter = [0 0 0]; %in Respect to (unbinned) average
boxsize = [boxsize boxsize boxsize];
orig_size = [boxsize boxsize boxsize];


%% Code
[fileNames,angles,shifts,list,PickPos]=readList(listName, pxsz);
maskh1=tom_mrcread(maskName_h1); maskh1=maskh1.Value;

waitbar=tom_progress(length(fileNames),['found: ' num2str(length(fileNames))]); 
parfor i=1:length(fileNames)
    [outH1, posNew(:,i)]=processParticle(fileNames{i},angles(:,i)',shifts(:,i),maskh1,PickPos(:,i)',offSetCenter,boxsize,filter,grow, normalizeit, sdRange, sdShift,blackdust,whitedust);
    writeParticle(fileNames{i},outH1, output);
    waitbar.update;
end;
waitbar.close();

%genStarFiles(list,listName,output, posNew);

disp('done ');
% disp('relion_reconstruct --i XXX_1.star --o rec2.mrc --3d_rot --maxres 30 --angpix 2.7 --j 7 ');
% disp('to check !!!');

function genStarFiles(list,listName,output,newPos)

[a,b,c]=fileparts(listName);
for ii=1:length(output.rplaceWith)
    
    listNew=list;
    for  i=1:length(listNew)
        listNew(i).rlnImageName=strrep(list(i).rlnImageName,output.findWhat,output.rplaceWith{ii});
       listNew(i).rlnCoordinateX = newPos(1,i);
       listNew(i).rlnCoordinateY = newPos(2,i);
       listNew(i).rlnCoordinateZ = newPos(3,i);
    end;
    if (isempty(a))
        tom_starwrite([ b '_cut_right' num2str(ii) c],listNew);
    else
        tom_starwrite([a filesep b '_cut' num2str(ii) c],listNew);
    end
end



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
    end;
end;
disp(' ');

function [outH1,posNew]=processParticle(filename,tmpAng,tmpShift,maskh1,PickPos,offSetCenter,boxsize, filter,grow, normalizeit, sdRange, sdShift,blackdust,whitedust)

volTmp=tom_mrcread(filename); volTmp=volTmp.Value;
maskh1Trans=tom_shift(tom_rotate(maskh1,tmpAng),tmpShift');
maskh1Trans=maskh1Trans>0.14;
%maskh1Trans = maskh1Trans(105:296, 105:296,105:296);
%maskh2Trans = maskh2Trans(105:296, 105:296,105:296);

vectTrans=tom_pointrotate(offSetCenter,tmpAng(1),tmpAng(2),tmpAng(3))+tmpShift';
posNew=(round(vectTrans)+PickPos)';
%topLeft = round(vectTrans)+orig_size/2 -boxsize/2;
topLeft = [0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%outH1=tom_permute_bg(volTmp,maskh1Trans,'',0,0,3);
%outH1=tom_permute_bg(volTmp,maskh1Trans,'',1.1,5,3);
%outH1=tom_maskWithNoise(volTmp,maskh1Trans,-15,1);

%cut and filter

if filter == 1
    outH1=tom_maskWithFil(volTmp,maskh1Trans, sdRange, sdShift,blackdust,whitedust);
    outH1=tom_permute_bg(outH1,maskh1Trans,'',grow,5,3);
else
    outH1=tom_permute_bg(volTmp,maskh1Trans,'',grow,5,3);
end
outH1 = tom_cut_out(outH1,topLeft,boxsize);
if normalizeit == 1
    outH1 = normalize(outH1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vectTrans=tom_pointrotate(offSetCenter,tmpAng(1),tmpAng(2),tmpAng(3))+tmpShift';

%posNew=round(vectTrans)+PickPos;

%topLeft = round(vectTrans)-boxsize/2+[90 90 90];

%



%tom_vol2chimera(tom_filter(volTmp,20),single(maskh1Trans),single(maskh2Trans));
%tom_vol2chimera(tom_filter(volTmp,20),tom_shift(tom_rotate(maskh1,tmpAng),tmpShift')); 
%tom_vol2chimera(tom_filter(tom_rotate(tom_shift(volTmp,-tmpShift'),[-tmpAng(2) -tmpAng(1) -tmpAng(3)]),20),single(maskh1));

 

function writeParticle(filename,outH1,output)

nameLeft=strrep(filename,output.findWhat,output.rplaceWith{1});


pFoldLeft=fileparts(nameLeft);


warning off; mkdir(pFoldLeft); warning on;



if (strcmp(nameLeft,filename))
    error(['check output find what: ' filename ' == ' nameLeft])
end;





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

