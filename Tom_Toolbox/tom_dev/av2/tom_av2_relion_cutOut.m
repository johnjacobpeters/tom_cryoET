function tom_av2_relion_cutOut(starFileName,center3d,boxSize,outputRoot,dontCutParts)
%TOM_AV2_RELION_CUTOUT cuts out according to the projected 3d coordinate 
%                                           to speed up subtracted alignment
%
% 
%PARAMETERS
%
%  INPUT
%   starFileName       name of the starfile (usually the subtracted particles)
%   center3d              center in 3d of the remaining structure (after subtraction)
%   boxSize                new size of the particles
%   outputRoot           rootname for new particlestack and starfile
%   dontCutParts       (0)don't cut particles gen start file only 
%
%  OUTPUT
%    -
% 
%
%EXAMPLE
%
% tom_av2_relion_cutOut('run_data.star',[193 186 279],[128 128],'Cutout/cutout');
%
%
%  %to check and for starting model use: 
%  %relion_reconstruct --i Cutout/cutout.star --o myStart.mrc --maxres 6.5 --j 25 --ctf --ctf_intact_first_peak --sym c1
%   
%  
% %maybe you need to renorm
% %relion_preprocess --norm --bg_radius 63  --operate_on Cutout/cutout.star --operate_out  Cutout/cutoutNorm.star
%
%NOTE
%
%The entire particle stack will be read to memory.
%Best practice is to use hpcl700x or hpcl400x they have 512G of Ram and
%they are not used interactively
%
%
%
%
%REFERENCES
%
%SEE ALSO
%   tom_starread,starwrite
%
%   created by FB 05/10/17
%   
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

if (nargin<5)
    dontCutParts=0;
end;




disp(' ');
disp(['Reading ' starFileName]);
star=tom_starread(starFileName);
disp(['Found ' num2str(length(star))  ' particles']);
starCut=star;
warning off; mkdir(fileparts(outputRoot)); warning on;

if (dontCutParts==1)
    disp('Running in star only mode');
    for i=1:length(star)
         newName=[sprintf('%06d',i) '@'  outputRoot '.mrcs'];
         starCut(i).rlnImageName=newName;
         starCut(i).rlnOriginX=starCut(i).rlnOriginX-round(starCut(i).rlnOriginX);  
         starCut(i).rlnOriginY=starCut(i).rlnOriginY-round(starCut(i).rlnOriginY);
    end;
    warning off; mkdir(fileparts(outputRoot)); warning on;   
    tom_starwrite([outputRoot '.star'],starCut);
    return;
end;


stackCut=zeros(boxSize(1),boxSize(2),length(star),'single');
szStackCut=whos('stackCut');

[~,particleName]=getTransFormAndName(star(1));
cache.stackName='';
[~,cache,~,midOrg]=fetchImag(cache,particleName,szStackCut.bytes);

 


waitbar=tom_progress(length(star),'Cutting particles');
errorCount=0;
for i=1:length(star)
    [transform,particleName]=getTransFormAndName(star(i));
    center_trans=projectCenter(center3d,transform,midOrg);
    [img,cache]=fetchImag(cache,particleName,szStackCut.bytes);
    [img,errorCount]=cutImage(img,center_trans,boxSize,errorCount);
    stackCut(:,:,i)=img;
    newName=[sprintf('%06d',i) '@'  outputRoot '.mrcs'];
    starCut(i).rlnImageName=newName;
    starCut(i).rlnOriginX=starCut(i).rlnOriginX-round(starCut(i).rlnOriginX);  
    starCut(i).rlnOriginY=starCut(i).rlnOriginY-round(starCut(i).rlnOriginY);
    waitbar.update();
end;
waitbar.close;
disp(['nr tapered particles: ' num2str(errorCount) ]);

disp('writing Results');
tom_mrcwrite(stackCut,'name',[outputRoot '.mrcs']);
tom_starwrite([outputRoot '.star'],starCut);
disp('done!');
 
 
function [img,errorCount]=cutImage(img,center_trans,boxSize,errorCount)

img=tom_cut_out(img,center_trans-floor(boxSize./2),boxSize);
if (size(img,1)<boxSize(1)|| size(img,2)<boxSize(2) )
    img=tom_taper(img,boxSize);
    errorCount=errorCount+1;
end;
 
if (size(img,1)>boxSize(1)|| size(img,2)>boxSize(2) )
     img=tom_cut_out(img,'center',boxSize);
    errorCount=errorCount+1;
end;
  



function [img,cache,posInStack,mid]=fetchImag(cache,particleName,szStackSmall)

[posInStack,stackName]=strtok(particleName,'@');
posInStack=str2double(posInStack);
stackName=strrep(stackName,'@','');


if (strcmp(cache.stackName,stackName)==0)
    chkMemory(stackName,szStackSmall);
    clear cache; 
    cache=tom_mrcread(stackName);
    cache.stackName=stackName;
    disp('done !');
    disp(' ');
end;


img=cache.Value(:,:,posInStack);
mid=floor(size(img)./2)+1;


function chkMemory(stackName,szStackSmall)

szStackSmallH=round(szStackSmall./(1024.*1024.*1024),1);

[~,szStack]=unix(['ls -lrth ' stackName ' | awk ''{print $5}''']);
szStackH=szStack(1:(end-1));
[~,szStack]=unix(['ls -lrt ' stackName ' | awk ''{print $5}''']);
szStack=str2double(szStack);

[~,szMax]=unix(['free -h | head -2 | awk ''{print $2}'' | tail -1']);
szMaxH=szMax(1:(end-1));
[~,szMax]=unix(['free -b| head -2 | awk ''{print $2}'' | tail -1']);
szMax=str2double(szMax);
[~,fname,fext]=fileparts(stackName);

szTot=szStackSmall+szStack;
szTotH=round(szTot./(1024.*1024.*1024),1);

if (szTot >=szMax.*0.9)
    disp([ fname fext  '(' szStackH  ')  +  CutStack('  num2str(szStackSmallH) 'G) = ' num2str(szTotH)  'G >  ' szMaxH]);
    error(['too less memory split ' stackName]);
else 
    disp([ fname fext  '(' szStackH  ')  +  CutStack('  num2str(szStackSmallH) 'G) = ' num2str(szTotH) 'G <  ' szMaxH ' ok!']);
end;

disp(['Reading  ' fname fext ' (' szStackH  ') to cache (' szMaxH  ')  ']);
disp(['  ...can take a while ']);

function [imgSz,mid]=getImageInfo(starLine)

[~,stackName]=strtok(starLine.rlnImageName,'@');
stackName=strrep(stackName,'@','');
stackHeader=tom_mrcread(stackName,'le',1);


imgSz=[stackHeader.nx stackHeader.ny stackHeader.nz];
mid=floor(imgSz./2)+1;


function [transform,particleName]=getTransFormAndName(starLine)

transform.rotZyZ=[starLine.rlnAngleRot starLine.rlnAngleTilt starLine.rlnAnglePsi];
transform.shift=[starLine.rlnOriginX starLine.rlnOriginY];
particleName=starLine.rlnImageName;



function center_trans=projectCenter(center,transform,mid)

[~,angZxZ]=tom_eulerconvert_xmipp(transform.rotZyZ(1),transform.rotZyZ(2),transform.rotZyZ(3));   
center_trans=tom_pointrotate(center-[mid(1) mid(2) mid(2)],angZxZ(1),angZxZ(2),angZxZ(3));
center_trans=center_trans+[mid(1) mid(2) mid(2)];
center_trans=center_trans(1:2);
center_trans=center_trans-round(transform.shift);




