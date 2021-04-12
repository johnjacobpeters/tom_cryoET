function tom_av2_xmipp_doc2star(docfileName,starFileName,targetFlav,pickListName,Info,matchdoc2pickList)
% tom_av2_xmipp_doc2star(docfileName,starFileName,targetFlav,pickListName,Info)
%  
%     star_st=tom_starread(filename,outputFlavour)
%  
%  PARAMETERS
%  
%    INPUT
%     docfileName       filename of the doc of sel file to be tranformed
%     starFileName      name of the output star file 
%     targetFlav        ('relion') flavour of the gnerated star file (xmipp3.0 or relion)  
%     pickListName      ('') name of the matlab picklist needed for ctf param
%     Info              ('') flag 2 trigger which information is used in startfile         
%     matchdoc2pickList ('byPartIdx') or 'byOrder'     
%
%    OUTPUT
%     
%                          
%  
%  EXAMPLE
%      
%  Info.particle=1;
%  Info.micrograph=1;
%  Info.defocus=1;
%  Info.pickPos=1;
%  Info.alignment=0;
%
%  tom_av2_xmipp_doc2star('parts_ai2.doc','myTrans.star','relion','pick.mat',Info);
%
%  REFERENCES
%  
%  NOTE:
%  
%
%  SEE ALSO
%      tom_xmippdocread,tom_spiderread
%  
%     created by FB 04/12/13
%  
%     Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%     Journal of Structural Biology, 149 (2005), 227-234.
%  
%     Copyright (c) 2004-2007
%     TOM toolbox for Electron Tomography
%     Max-Planck-Institute of Biochemistry
%     Dept. Molecular Structural Biology
%     82152 Martinsried, Germany
%     http://www.biochem.mpg.de/tom
% 

if (nargin<3)
    targetFlav='relion';
end;

if (nargin<4)
    pickListName='';
end;

if (nargin<5)
    if (isempty(pickListName))
         Info.particle=1;
    else
         Info.particle=1;
         Info.micrograph=1;
         Info.defocus=1;
         Info.pickPos=1;
         Info.alignment=0;
    end;
end;

if (nargin<6)
    matchdoc2pickList='byPartIdx';
end;

[doc,align2d,doc2alignMatchIdx]=readInputFiles(docfileName,pickListName,matchdoc2pickList);

Header=genHeader(Info,targetFlav);
dataMatrix=genDataMatrix(Info,doc,align2d,targetFlav,doc2alignMatchIdx);
tom_starwrite(starFileName,dataMatrix,Header);


function [doc,align2d,matchIdx]=readInputFiles(docfileName,pickListName,matchdoc2pickList)

matchIdx='';
[a,b,c]=fileparts(docfileName);

if (strcmp(c,'.doc'))
    doc=tom_xmippdocread(docfileName);
else
    sel=importdata(docfileName);
    for i=1:length(sel.textdata)
        doc(i).name=sel.textdata{i};
        [a b c]=fileparts(doc(i).name);
        num=strfind(b,'_');
        part_idx=str2double(b(max(num)+1:end));
        doc(i).part_idx=part_idx;
    end;
end;

if (isempty(pickListName))
    align2d='';
else
    load(pickListName);
end;

if (strcmp(matchdoc2pickList,'byPartIdx'))
    matchIdx=[doc(:).part_idx];
end;

if (strcmp(matchdoc2pickList,'byOrder'))
    matchIdx=1:size(align2d,2);
end;

if (isnumeric(matchdoc2pickList))
    matchIdx=matchdoc2pickList;
end;

if (isempty(matchIdx))
    error('wrong settings 4 match Flag!!');
end;



function Head=genHeader(Info,targetFlav)


if (strcmp(targetFlav,'relion'))
    
    Head.title='data_';
    Head.isLoop=1;
    
    ColumnCount=0;
   
    if (Info.particle)
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnImageName #' num2str(ColumnCount)];
    end;
    
    if (Info.micrograph)
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnMicrographName #' num2str(ColumnCount)];
    end;
    
    if (Info.defocus)
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnDefocusU #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnDefocusV #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnDefocusAngle #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnVoltage #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnSphericalAberration #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnAmplitudeContrast #' num2str(ColumnCount)];
   end;
    
    if (Info.alignment)
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnAngleRot #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnAngleTilt #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnAnglePsi #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnOriginX #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnOriginY #' num2str(ColumnCount)];
    end;
    
    if (Info.pickPos)
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnCoordinateX #' num2str(ColumnCount)];
        ColumnCount=ColumnCount+1;
        Head.fieldNames{ColumnCount}=['_rlnCoordinateY #' num2str(ColumnCount)];
   end;
    
end;

function dataMatrix=genDataMatrix(Info,doc,align2d,targetFlav,matchIdx)

ColumnCount=0;

if (Info.defocus || Info.pickPos)
    data=extractData(align2d,doc,targetFlav);
end;

if (Info.particle)
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)={doc(:).name};
end;

if (Info.micrograph)
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)={align2d(1,matchIdx).filename};
end;

if (Info.defocus)
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell(data(:,1));
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell(data(:,2));
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell(data(:,3));
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell(data(:,4));
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell(data(:,5));
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell(data(:,6));
end;

if (Info.alignment)
    %to be done!!!
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell([doc(:).rot]);
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell([doc(:).tilt]);
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell([doc(:).psi]);
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell([doc(:).xoff]);
    ColumnCount=ColumnCount+1;
    dataMatrix(:,ColumnCount)=num2cell([doc(:).yoff]);
end;

if (Info.pickPos)
    ColumnCount=ColumnCount+1;
    for i=1:length(matchIdx)
        dataMatrix{i,ColumnCount}=align2d(1,matchIdx(i)).position.x;
        dataMatrix{i,ColumnCount+1}=align2d(1,matchIdx(i)).position.y;
    end;
    ColumnCount=ColumnCount+1;
end;




function data=extractData(align2d,doc,targetFlav)
astig_flag=1;

if (strcmp(targetFlav,'relion'))
    data=zeros(length(doc),8);
    filename_old='';
    for i=1:length(doc)
        filename=strrep(align2d(1,i).filename,'_corr/','/');
        if (strcmp(filename,filename_old)==0)
            load([filename '.mat']);
            filename_old=filename;
        end;
        if (astig_flag==1)
            dz_u=-1.*st_out.Fit.Dz_det.*1e10+((-st_out.Fit.Dz_delta_det.*1e10)./2);
            dz_v=-1.*st_out.Fit.Dz_det.*1e10-((-st_out.Fit.Dz_delta_det.*1e10)./2);
            ang=st_out.Fit.Phi_0_det+135;
        else
            dz_u=st_out.Fit.Dz_det.*1e10;
            dz_v=st_out.Fit.Dz_det.*1e10;
            ang=0;
        end;
        data(i,:)=[dz_u dz_v ang st_out.Fit.EM.Voltage/1000 st_out.Fit.EM.Cs.*1000 st_out.Fit.amplitude_contrast_det(1) align2d(1,i).position.x align2d(1,i).position.y];
    end;
end;




    

