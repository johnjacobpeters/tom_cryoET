function tom_av2_remove_background(starFileName,filt,outputRoot)
%TOM_AV2_REMOVE_BACKGROUND cuts out according to the projected 3d coordinate 
%                                           to speed up subtracted alignment
%
% 
%PARAMETERS
%
%  INPUT
%   starFileName       name of the starfile (usually the subtracted particles)
%   filt                        radius of kernel fo or maskName or mask
%   outputRoot          rootname for new particlestack and starfile
% 
%  OUTPUT
%    -
% 
%
%EXAMPLE
%
% tom_av2_remove_background('run_data.star',50,'normbg/normbg');
%
% parpool('local',12);
% tom_av2_remove_background('cutoutA.star','mask.mrc','perm/perm');
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

disp(['Reading ' starFileName]);
star=tom_starread(starFileName);
disp(['Found ' num2str(length(star))  ' particles']);


if (ischar(filt) )
    filt=tom_mrcread(filt);
    filt=filt.Value;
end;
warning off; mkdir(fileparts(outputRoot)); warning on;



poolSt=gcp;
packages=tom_calc_packages(poolSt.NumWorkers,length(star));
parfor i=1:size(packages,1)
    idx=packages(i,1):packages(i,2);
    pack{i}=reomoveBackgroundWorker(star(idx),filt,outputRoot,i,idx);
end;

stackNorm=pack{1}.stackNorm;
starNorm=pack{1}.starNorm;
for i=2:length(pack)
    stackNorm=cat(3,stackNorm,pack{i}.stackNorm);
    starNorm=cat(1,starNorm,pack{i}.starNorm);
end;

disp('writing Results');
tom_mrcwrite(stackNorm,'name',[outputRoot '.mrcs']);
tom_starwrite([outputRoot '.star'],starNorm);
disp('done!');


function pack=reomoveBackgroundWorker(star,filt,outputRoot,packId,idx)



cache.stackName='';
[img,cache,~,midOrg]=fetchImag(cache,star(1).rlnImageName,packId);
stackNorm=zeros(size(img,1),size(img,2),length(star),'single');
starNorm=star;

if (packId==1)   
    waitbar=tom_progress(length(star),'norming particles');
end;
for i=1:length(star)
    [~,particleName]=getTransFormAndName(star(i));
    [img,cache]=fetchImag(cache,particleName,packId);
    img=nromImg(img,filt,star(i));
    stackNorm(:,:,i)=img;
    newName=[sprintf('%06d',idx(i)) '@'  outputRoot '.mrcs'];
    starNorm(i).rlnImageName=newName;
    if (packId==1)
        waitbar.update();
    end;
end;
if (packId==1)
    waitbar.close;
end;

pack.stackNorm=stackNorm;
pack.starNorm=starNorm;
pack.packId=packId;
pack.idx=idx;

function [img,cache,posInStack,mid]=fetchImag(cache,particleName,packId)

[posInStack,stackName]=strtok(particleName,'@');
posInStack=str2double(posInStack);
stackName=strrep(stackName,'@','');


if (strcmp(cache.stackName,stackName)==0)
    if (packId==1)
        disp(['reading ' stackName]);
    end;
    clear cache; 
    cache=tom_mrcread(stackName);
    cache.stackName=stackName;
    if (packId==1)
        disp('done !');
        disp(' ');
    end;
end;


img=cache.Value(:,:,posInStack);
mid=floor(size(img)./2)+1;


function imgF=nromImg(img,filt,starEntry)

szfilt=size(filt);

if (szfilt(1)>1)
    [~,eulerZxZ]=tom_eulerconvert_xmipp(starEntry.rlnAngleRot,starEntry.rlnAngleTilt,0);
    maskProj=squeeze(sum(tom_rotate(filt,[eulerZxZ(1) eulerZxZ(2) eulerZxZ(3)]),3));
    maskProjAlg=tom_shift(tom_rotate(maskProj,-starEntry.rlnAnglePsi),[-starEntry.rlnOriginX -starEntry.rlnOriginY]);
    maskProjAlg=maskProjAlg>0.4;
    imgF=tom_permute_bg(img,maskProjAlg,'',1.01,10,2);
%      subplot(1,4,1); tom_imagesc(maskProjAlg); 
%     subplot(1,4,2); tom_imagesc(img>2); title('orgImg')
%     subplot(1,4,3); tom_imagesc(maskProjAlg.*tom_filter(img,2)); 
%     subplot(1,4,4); tom_imagesc(imgF); 
%     cc=tom_corr(img,maskProjAlg,'norm'); [a,b]=tom_peak(cc);a
     
else
    imgF=img-tom_filter(img,filt);
end;

function [transform,particleName]=getTransFormAndName(starLine)

transform.rotZyZ=[starLine.rlnAngleRot starLine.rlnAngleTilt starLine.rlnAnglePsi];
transform.shift=[starLine.rlnOriginX starLine.rlnOriginY];
particleName=starLine.rlnImageName;



