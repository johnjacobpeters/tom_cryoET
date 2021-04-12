function [Align]=tom_av3_extr_cl_tomCorr3d(filename,outputfold)




 
keyPhraseClassMemStart='particles for class ';
keyPhrseClassMemStop='# Sum of correlation values:';


fid=fopen(filename,'r');
partLines=getParticleLines(fid,keyPhraseClassMemStart,keyPhrseClassMemStop);
partList=parseParticleLines(partLines);
Align=partList2Align(partList);
writeClassLists(outputfold,partList);

function writeClassLists(outputfold,partList)

if isempty(outputfold)==0
    mkdir(outputfold);
end;


for i=1:length(partList)
    fid=fopen([outputfold filesep 'class' num2str(i) '.txt'],'wt');
    fid2=fopen([outputfold filesep 'classParts' num2str(i) '.txt'],'wt');
    classNr=partList{i};
    for ii=1:length(classNr)
        [a,b,c]=fileparts(classNr{ii});
        fprintf(fid,'%s\n',classNr{ii});
        fprintf(fid2,'%s\n',[b c]);
    end;
    fclose(fid);
    fclose(fid2);
end;
    



function AllAlign=partList2Align(partList)

for i=1:length(partList)
    classList=partList{i};
    Align=allocAlign(length(classList));
    for ii=1:length(classList)
        Align(1,ii).Filename=classList{ii};
    end;
    AllAlign{i}=Align;
end;


function [partList]=parseParticleLines(partLines)

for i=1:length(partLines)
    classLines=partLines{i};
    for ii=1:length(classLines)
        tmpLine=classLines{ii};
        start=strfind(tmpLine,'("')+2;
        stop=strfind(tmpLine,'").')-1;
        partList{i}{ii}=tmpLine(start:stop);
    end;
end;


function partLines=getParticleLines(fid,keyPhraseClassMemStart,keyPhrseClassMemStop)


classCount=0;
partCountClass=0;
insidepart=0;
for i=1:100000
    lineTmp=fgetl(fid);
    if (lineTmp==-1)
        break;
    end;
    if (strfind(lineTmp,keyPhraseClassMemStart))
        classCount=classCount+1;
        partCountClass=1;
        insidepart=1;
        continue;
    end;
    if (strfind(lineTmp,keyPhrseClassMemStop))
        insidepart=0;
        
    end;
    if (insidepart==1)
        partLines{classCount}{partCountClass}=lineTmp;
        partCountClass=partCountClass+1;
    end;
    
end;

function Align=allocAlign(numOfEntries)

run=1;
for i=1:numOfEntries
    
    Align(run,i).Filename = '';
    Align(run,i).Tomogram.Filename = '';
    Align(run,i).Tomogram.Header = '';
    Align(run,i).Tomogram.Header.Size=[64 64 64];
    Align(run,i).Tomogram.Position.X = 0; %Position of particle in Tomogram (values are unbinned)
    Align(run,i).Tomogram.Position.Y = 0;
    Align(run,i).Tomogram.Position.Z = 0;
    Align(run,i).Tomogram.Regfile = '';
    Align(run,i).Tomogram.Offset = 0;     %Offset from Tomogram
    Align(run,i).Tomogram.Binning = 0;    %Binning of Tomogram
    Align(run,i).Tomogram.AngleMin = -60;
    Align(run,i).Tomogram.AngleMax = 60;
    Align(run,i).Shift.X =0; %Shift of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Shift.Y =0;
    Align(run,i).Shift.Z = 0;
    Align(run,i).Angle.Phi = 0; %Rotational angles of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).Angle.Psi = 0;
    Align(run,i).Angle.Theta =0;
    Align(run,i).Angle.Rotmatrix = []; %Rotation matrix filled up with function tom_align_sum, not needed otherwise
    Align(run,i).CCC = 0; % cross correlation coefficient of particle, will be filled by tom_av3_extract_anglesshifts
    Align(run,i).PeakVal=0;
    Align(run,i).Class = 0;
    Align(run,i).ProjectionClass = 0;
    Align(run,i).NormFlag = 0; %is particle phase normalized?
    Align(run,i).Filter = [0 0]; %is particle filtered with bandpass?
    
    
end;
        
disp('ff');




