%% new code below 


function [fnlength,fileNames, statstat]=coordinate_picker2(listName, dir, pxsz,ChimeraX_dir, levels,curindex,testindex, cmmdir)
output.findWhat = dir;

%% Code executed
[fileNames,angles,shifts,list,PickPos]=readList(listName, pxsz);
fnlength = num2str(length(fileNames));
statstat=0;
if testindex == 1
    %initialize cell
    cxc_out = cell(5,1);
    cxc_out{1} = 'open test;';
    cxc_out{2} = ['set bgColor white;volume #1 level ',levels,';'];
    cxc_out{3} = 'color radial #1.1 palette #ff0000:#ff7f7f:#ffffff:#7f7fff:#0000ff center 127.5,127.5,127.5;';
    cxc_out{4} = 'ui mousemode right "mark surface";';
    cxc_out{5} = 'ui tool show "Side View";';

    writecell(cxc_out, 'cxcchim3temp.txt')
    [status, result]=system(['sed s/\"//g ', 'cxcchim3temp.txt', ' > ', 'chim3temp.cxc']);
    [status, result]=system(['sed s/mark/\"mark/g ', 'chim3temp.cxc', ' > ', 'chim3temp2.cxc']);
    [status, result]=system(['sed s/surface\;/\surface\"/g ', 'chim3temp2.cxc', ' > ', 'chim3temp5.cxc']);
    [status, result]=system(['sed s/Side/\"Side/g ', 'chim3temp5.cxc', ' > ', 'chim3temp4.cxc']);
    [status, result]=system(['sed s/View\;/\View\"/g ', 'chim3temp4.cxc', ' > ', 'chim3temp3.cxc']);
    %getdir= pwd;
    fulldir = output.findWhat;%[getdir, '/', output.findWhat];
    tmpflnam = [fulldir,fileNames{curindex}];
    [status, result]=system(['sed s+test+', tmpflnam, '+g ', 'chim3temp3.cxc', ' > ', 'chim3cur.cxc']);
    if not(isfolder([cmmdir,'cmm_files']))
        mkdir([cmmdir,'cmm_files'])
    end
    [statstat] = pickCoord(fileNames{curindex}, ChimeraX_dir, 'chim3cur.cxc',cmmdir);
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
    end
end

function [statstat]=pickCoord(filename,ChimeraX_dir, Input_ChimeraX_command_file,cmmdir)
%% actual code

% for i = 1:length(ls(*filt.mrc))
%     print(i)
% end
[status,cmdout] = system([ChimeraX_dir '/ChimeraX ' Input_ChimeraX_command_file]);
output = strrep(filename,'.mrc','.cmm');
level = wildcardPattern + "/";
pat = asManyOfPattern(level);
outputname = extractAfter(output,pat)


if isfile('coord.cmm')
     [status,cmdout] = system(['mv coord.cmm ', cmmdir, 'cmm_files/', outputname]);
     statstat=1;
else
     disp('no coords')
     statstat=0;
end







function writeCoords(filename,outH1,output)







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
