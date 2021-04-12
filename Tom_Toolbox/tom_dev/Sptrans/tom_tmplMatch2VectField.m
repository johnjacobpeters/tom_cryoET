function list=tom_tmplMatch2VectField(Align,OutputFolder,repVectorSet,normalVect,colourSceme,projDir)
%tom_tmplMatch2VectField transforms a template Match result to a vector field
%   
% tom_tmplMatch2VectField()
%
%PARAMETERS
%
%  INPUT
%   Align                       align list
%   outputFolder          outputFolder
%   repVectorSet          matrix of vectors to represent the template
%   normalVect             normal vector 
%   coloutSceme           struct with information for colouring the vectors according to the angle with the normal  
%   projDir                    ('') axis to projcet the vectors usually z
%
%EXAMPLE
%   
% colourSceme.method='binary';
% colourSceme.threshold=90;
% tom_tmplMatch2VectField('Align_r16_5000p_goodparts_refined.mat','output',[30 0 0;0 30 0; 0 0 30],[0.004 0.069 1].*30,colourSceme);
%  
% colourScemeCM.method='colorMap';
% colourScemeCM.scale='auto';
% colourScemeCM.colourMap=colormap('hot');
% tom_tmplMatch2VectField('ParticleList.mat','outputCM',[30 0 0;0 30 0; 0 0 30],[0.0040926 0.068836 -0.99762].*30,colourScemeCM);
%
%
% colourScemeCM.method='colorMap';
% colourScemeCM.scale=[0 180];
% colourScemeCM.colourMap=colormap('cool');
% tom_tmplMatch2VectField('ParticleList.mat','outputCM',[30 0 0;10 30 0; 0 0 30],[0.0040926 0.068836  -0.997621].*30,colourScemeCM);
%
% colourScemeCM.method='colorMapExplicit';
% colourScemeCM.colourMap(1).colour=[1 0 0];
% colourScemeCM.colourMap(1).range=[0 80];
% colourScemeCM.colourMap(2).colour=[0.7 0.7 0.7];
% colourScemeCM.colourMap(2).range=[80 100];
% colourScemeCM.colourMap(3).colour=[0 1 0];
% colourScemeCM.colourMap(3).range=[90 180];
% tom_tmplMatch2VectField('ParticleList.mat','outputCM',[30 0 0;10 30 0; 0 0 30],[0.0040926 0.068836 -0.99762].*30,colourScemeCM);
% load outputCMRot/list.txt
% 
% %****Full Example******************
%
% %fit the plane with 4 markers
% [coeffs,normal,zOff,fitang,angNormal]=tom_fit_plane('Labels/membrane_plane1.txt','Labels/visPlane/',1,[462 462 150]+1);
% unix('chimera  data/Tomogram.em Labels/visPlane/*.bild');
%
% %aling the particle positions to normal
% tom_av3_rotateAlignPickPos('ParticleList.mat',angNormal,[462 462 150]+1,'ParticleListAlg.mat'); 
%
% %generate a repasted algned Volume 
% tom_tmplMatch2RepasteVol('ParticleList.mat','data/Template.em',[924 924 300],0,'data/VolRepasteTemplate.em');
% %align the volumes to normal 
% vol=tom_emread('data/VolRepasteTemplate.em');vRot=tom_rotate(vol.Value,angNormal); tom_emwrite('data/VolRepasteTemplateAlg.em',vRot); 
%
% %generate Vectors from Aligned Particle List 
%
% %define a color sceme
% colourScemeCM.method='colorMap';
% colourScemeCM.scale=[0 180];
% colourScemeCM.colourMap=colormap('cool');
% 
% %analyse angles of mother (rep vector1) and daughter (rep vector 2) in respect to normal (plane)
% tom_tmplMatch2VectField('ParticleListAlg.mat','vectOutPlaneAlg',[30 0 0;12 30 0],[0 0 30],colourScemeCM);
% unix('chimera data/VolRepasteTemplateAlg.em vectOutPlaneAlg/repVect_*.bild vectOutPlaneAlg/normalLocal.bild Labels/visPlane/aligned/*.bild &');
% load vectOutPlaneAlg/list.txt
% figure;  [f,x]=hist(list(:,10)); fN= f./sind(x); bar(x,fN); title('angle: mother vs plane '); 
% tom_calcAngConv(list(:,10),0:12:180,'mother vs. plane',1000,3);
% figure;  [f,x]=hist(list(:,14)); fN= f./sind(x); bar(x,fN); title('angle: daughter vs plane '); 
% tom_calcAngConv(list(:,14),0:12:180,'doughter vs. plane',1000,3);
%
% %analyse angles of mother (rep vector1) and daughter (rep vector 2) in respect to wave (2d vector)
% tom_tmplMatch2VectField('ParticleListAlg.mat','vectOutPlaneAlgWave',[30 0 0;12 30 0],[-25.9 15.1 nan],colourScemeCM);
% unix('chimera data/VolRepasteTemplateAlg.em vectOutPlaneAlgWave/repVect_*.bild vectOutPlaneAlgWave/normalLocal.bild Labels/visPlane/aligned/*.bild &');
% load vectOutPlaneAlgWave/list.txt
% figure;  hist(list(:,10)); title('angle: mother vs wave '); 
% tom_calcAngConv(list(:,10),0:10:180,'mother vs. wave',1000,3,'2d'); 
% %do not the dircection into account!
% tom_calcAngConv(list(:,10),0:10:90,'mother vs. wave',1000,3,'2d-line');
%
% figure;  hist(list(:,14)); title('angle: dauther vs wave '); 
% tom_calcAngConv(list(:,14),0:10:180,'daughther vs. wave',1000,3,'2d');
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 08/24/17
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

if (nargin<6)
    projDir='';
end;

list=readInputList(Align,size(repVectorSet,1));
list=transFormList(list,repVectorSet,normalVect);
genOutputFilesChimera(list,OutputFolder,repVectorSet,normalVect,colourSceme,projDir);
genOutputText(list,OutputFolder);

function genOutputText(list,OutputFolder)

filename=[OutputFolder filesep 'list.txt'];

fid=fopen(filename,'wt');
for i=1:size(list,1)
    fprintf(fid,['%s\n'],num2str(list(i,:)) );
end;
fclose(fid);

function genOutputFilesChimera(list,OutputFolder,repVectorSet,normalVect,colourSceme,projDir)


warning off; mkdir(OutputFolder); warning on;

zzC=7;
positions=list(:,4:6);
%positions=zeros(size(positions));
for i=1:size(repVectorSet,1)
    filename=[OutputFolder filesep 'repVect_' num2str(i) '.bild'];
    vectors=list(:,zzC:zzC+2);
    angles=list(:,zzC+3);
    genChimeraBildFile(filename,positions,vectors,angles,colourSceme,projDir);
    zzC=zzC+4;
end;

%plot local normals
normalVect(isnan(normalVect))=0;
vectors=repmat(normalVect,size(list,1),1);
scemeNormal.method='static';
scemeNormal.colour=[0.7 0.7 0.7];
filename=[OutputFolder filesep 'normalLocal.bild'];
genChimeraBildFile(filename,positions,vectors,zeros(size(list,1),1),scemeNormal,projDir);

filename=[OutputFolder filesep 'normalGlobal.bild'];
genChimeraBildFile(filename,mean(positions),normalVect,0,scemeNormal,projDir);


function genChimeraBildFile(filename,positions,vectors,angles,colourSceme,projDir)

fid=fopen(filename,'wt');
for i=1:size(vectors,1)
    vectStart=positions(i,:);
    vectEnd=vectStart+vectors(i,:);
    if (strcmp(projDir,'z'))
        vectStart(3)=0;
        vectEnd(3)=0;
    end;
    
    colFromAng=genVectColour(angles(i),colourSceme,angles);
    colStr=['.color ' num2str(colFromAng)]; 
    angStr=['.arrow ' num2str([vectStart vectEnd 1.5]) ];
    fprintf(fid,'%s\n',colStr);
    fprintf(fid,'%s\n',angStr);
end;
fclose(fid);


function rgbCol=genVectColour(angle,colourSceme,allAngles)

if (nargin<3)
    allAngles='';
end;

if (strcmp(colourSceme.method,'binary'))
    if (angle < colourSceme.threshold)
        rgbCol=[1 0 0];
    else
        rgbCol=[0 1 0];
    end;
end;

if (strcmp(colourSceme.method,'static'))
    rgbCol=colourSceme.colour;
end;

if (strcmp(colourSceme.method,'colorMap'))
    if (strcmp(colourSceme.scale,'auto'))
        minAngle=min(allAngles);
        maxAngle=max(allAngles);
    end;
     if (isnumeric(colourSceme.scale))
        minAngle=colourSceme.scale(1);
        maxAngle=colourSceme.scale(2);
    end;
    
    angleNorm=(angle-minAngle)./(maxAngle-minAngle); 
    idx=round(angleNorm.*size(colourSceme.colourMap,1)) ;
    if (idx<1)
        idx=1;
    end;
     if (idx>size(colourSceme.colourMap,1))
        idx=size(colourSceme.colourMap,1);
    end;
    
    rgbCol=colourSceme.colourMap(idx,:);
end;

if (strcmp(colourSceme.method,'colorMapExplicit'))
    rgbCol='';
    for i=1:length(colourSceme.colourMap)
        minBound=colourSceme.colourMap(i).range(1);
        maxBound=colourSceme.colourMap(i).range(2);
        if ((angle>=minBound) && (angle<=maxBound))
            rgbCol=colourSceme.colourMap(i).colour;
            break;
        end;
    end;
    if (isempty(rgbCol))
        warning([num2str(angle) ' out of range check your boundaries setting to 0.7 0.7 0.7 (gray)' ]);
        rgbCol=[0.7 0.7 0.7];
    end;
end;




function list=transFormList(list,repVectorSet,normalVector)

for i=1:size(repVectorSet,1)
    repVectorSetLen(i)=norm(repVectorSet(i,:));
end;

for i=1:size(list,1)
    zzC=7;
    for ii=1:size(repVectorSet,1)
        angle=[list(i,1) list(i,2) list(i,3)];
        vRot=rotateVector(repVectorSet(ii,:),angle);
        angle=calcAngToNormal(vRot,normalVector);
        list(i,zzC:zzC+3)=[vRot angle];
        zzC=zzC+4;
    end;
end;


function ang=calcAngToNormal(v,vN)

projMask=(isnan(vN)==0);
v=v.*projMask;
vN(isnan(vN))=0;

dpN=sum(v.*vN)./(norm(v).*norm(vN));
ang=rad2deg(acos(dpN));


function vRot=rotateVector(repVector,angle)

vRot=tom_pointrotate(repVector,angle(1),angle(2),angle(3));
% vRotNorm=vRot./sqrt(sum(vRot.*vRot));
%list(i,7:9)=vRotNorm.*repVectorLen;



function list=readInputList(Align,numRepVect)

if (isstruct(Align)==0)
    load(Align); 
end;

list=zeros(size(Align,2),(numRepVect*4)+6);
for i=1:size(Align,2)
    angle=[Align(1,i).Angle.Phi Align(1,i).Angle.Psi Align(1,i).Angle.Theta];
    pos=[Align(1,i).Tomogram.Position.X Align(1,i).Tomogram.Position.Y Align(1,i).Tomogram.Position.Z];
    list(i,1:3)=angle;
    list(i,4:6)=pos;
end;

