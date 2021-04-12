function tom_av2_centerParts(inputPartList,ref,increment,outputPartList)
%TOM_AV2_CENTERPARTS performs center of particles by a given ref
%
%   
%PARAMETERS
%
%  INPUT
%   inputPartList       partlist so far only .star implemented 
%   ref                 reference image only .mrc implemented
%   increment           (10) increment in deg
%   outputPartList      name of the outputPartList
%
%EXAMPLE
% %center avg from class5
% allRef=tom_mrcread('run3_it025_classes.mrcs'); 
% refCent=tom_av2_alignref(allRef.Value(:,:,5));
% 
% %get only particles from class 5
% 
% %istead of this command you can use relion script and stackbrowser
% !cat run3_it025_data.star | awk 'NF<3{print $0}' >  class5.star
% !cat run3_it025_data.star | awk 'NF>3{print $0}' | awk '$22==5{print$0}' >> class5.star
% 
% tom_av2_centerParts('class5.star',refCent,10,'class5Cent.star');
% 
% tom_av2_star2RelPick('class5Cent.star','Micrographs','_postCentered'); 
%
%
%REFERENCES
%
%NOTE
%reference has to be centered
%
%
%SEE ALSO
%   ...
%
%   created by FB 14/12/15
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


list=tom_starread(inputPartList);

if (ischar(ref))
    ref=tom_mrcread(ref);
end;

rotVect=[0:increment:(360-increment)];

waitbar=tom_progress(length(list),'centering particles');
parfor i=1:length(list)
    partName=list(i).rlnImageName;
    [sh(i,:),rot(i),cc(i)]=calcShift(ref,rotVect,partName); 
    waitbar.update();
end;
waitbar.close; 

align2d=allocAlign(length(list).*2);
zz=1;
for i=1:size(sh,1)
    [~,imgName]=strtok(list(i).rlnImageName,'@');
    %imgName=strrep(strrep(strrep(imgName,'@',''),'_particles.mrcs','.mrc'),'/Particles/','/');
    imgName=list(i).rlnMicrographName;
    align2d(1,zz).filename=imgName;
    align2d(1,zz).position.x=list(i).rlnCoordinateX;
    align2d(1,zz).position.y=list(i).rlnCoordinateY;
    align2d(1,zz).class = 'unCorr';
    align2d(1,zz).color = [1 0 0];
    zz=zz+1;
    list(i).rlnCoordinateX=list(i).rlnCoordinateX-sh(i,1);
    list(i).rlnCoordinateY=list(i).rlnCoordinateY-sh(i,2);
    align2d(1,zz).filename=imgName;
    align2d(1,zz).position.x=list(i).rlnCoordinateX;
    align2d(1,zz).position.y=list(i).rlnCoordinateY;
    align2d(1,zz).class = 'Corr';
    align2d(1,zz).color = [0 1 0];
    zz=zz+1;
    
end;

tom_starwrite(outputPartList,list);


function [shmax,rotmax,ccmax]=calcShift(ref,rotVect,partName)


mid=floor(size(ref)./2)+1;

[num,stackName]=strtok(partName,'@');
stackName=strrep(stackName,'@','');

mask4Peak=tom_spheremask(ones(size(ref)),round(size(ref,1)./8),size(ref,1)./10);

mask=tom_spheremask(ones(size(ref)),round(size(ref,1)./2)-5);
stack=tom_mrcread(stackName);
part=tom_filter(stack.Value(:,:,str2num(num)),3).*mask;
for i=1:length(rotVect)
    refRot=tom_filter(tom_rotate(ref,rotVect(i)),2);
    cc=tom_corr(part,refRot.*mask,'norm',mask);
    
    [~,ccc]=tom_peak(cc.*mask4Peak);
    allPeak(i)=ccc(1);
end;

[~,maxPos]=max(allPeak);
rotmax=rotVect(maxPos);

cc=tom_corr(tom_rotate(ref,rotmax).*mask,part,'norm');
[pos,ccmax]=tom_peak(cc.*mask4Peak);
shmax=mid-pos;

function align2d=allocAlign(nrPart)

for pointnumber=1:nrPart
    align2d(1,pointnumber).dataset = '';
    align2d(1,pointnumber).filename = '';
    align2d(1,pointnumber).position.x = 0;
    align2d(1,pointnumber).position.y = 0;
    align2d(1,pointnumber).class = 'default';
    align2d(1,pointnumber).radius =0;
    align2d(1,pointnumber).color = [0 1 0];
    align2d(1,pointnumber).shift.x = 0;
    align2d(1,pointnumber).shift.y = 0;
    align2d(1,pointnumber).angle = 0;
    align2d(1,pointnumber).isaligned = 0;
    align2d(1,pointnumber).ccc = 0;
    align2d(1,pointnumber).quality = 0;
    align2d(1,pointnumber).normed = 'none';
    align2d(1,pointnumber).ref_class = 0;
end










