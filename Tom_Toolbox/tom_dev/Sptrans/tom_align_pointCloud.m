function [param,cloud_model_alg,vol_model]=tom_align_pointCloud(cloud_tmpl,cloud_model,mid,do_refl,do_scale,vol_model)
%tom_align_pointCloud aligns 2 pointclouds by rotation and translation 
%
%    [param cloud_model_alg]=tom_align_pointCloud(cloud_tmpl,cloud_model)
%
%PARAMETERS
%
%  INPUT
%   cloud_tmpl                  template cloud
%   cloud_model                 model cloud (will be aligned in respect 2 template)
%   mid                         ([0 0 0])mid of Coordinate System 
%                               rotatio is performed around this point
%                               ...useful for Volume registration check example 
%   do_refl                     (false)
%   do_scale                    (false)
%   vol_model                   ('') volume that shoule be transformed according to cloud_model 
%
%  OUTPUT
%   param                  alignment parameters shift and rotation matrix
%   cloud_model_alg        aligned point cloud
%   vol_model              aligned volume
% 
%NOTE
% 
% points in template and model must match !!
% this means:
% cloud_model(1,:) must be the transformed version of cloud_tmpl(1,:)
% cloud_model(2,:) must be the transformed version of cloud_tmpl(2,:)
% ...
%
%EXAMPLE
% 
% transAngle=[-45 170 -90];
% transShift=[5 -8 3];
% %transShift=[0 0 0];
% ModelPoints=[20 20 20; 45 45 45; 20 45 45; 45 20 45;45 45 20 ;33 33 33];
% mid=[33 33 33];
% nrPoints=size(ModelPoints,1);
% midMatrix=repmat(mid,nrPoints,1);
% %rotate around the middle
% ModelPointsTrans=tom_pointrotate(ModelPoints-midMatrix,transAngle(1),transAngle(2),transAngle(3))+midMatrix;
% ModelPointsTrans=ModelPointsTrans + repmat(transShift,nrPoints,1);
% 
% %build model Volumes
% VolModel=zeros(64,64,64);
% VolModelTrans=zeros(64,64,64);
% for i=1:5
%     VolModel(ModelPoints(i,1),ModelPoints(i,2),ModelPoints(i,3))=1;
%     VolModelTrans(round(ModelPointsTrans(i,1)),round(ModelPointsTrans(i,2)),round(ModelPointsTrans(i,3)))=1;
% end;
% 
% %Align points
% [paramFromPointCloud,palg,volAlg]=tom_align_pointCloud(ModelPoints,ModelPointsTrans,mid,false,false,VolModelTrans);
%
% %Apply alignment 2 ModelPointsTrans
% ModelPointsTransToOrg=(ModelPointsTrans*paramFromPointCloud.transform.T) + paramFromPointCloud.transform.c; 
% 
% %Apply alignment 2 Model Volume
% VolModelTransToOrg=tom_rotate(VolModelTrans,inv(paramFromPointCloud.transform.T));
% VolModelTransToOrg=tom_move(VolModelTransToOrg,round(paramFromPointCloud.transform.c(1,:)));
%
% %Check results
% figure; 
% plot3(ModelPoints(:,1),ModelPoints(:,2),ModelPoints(:,3),'b+');
% hold on; plot3(ModelPointsAppTr(:,1),ModelPointsAppTr(:,2),ModelPointsAppTr(:,3),'ro'); hold off;
% hold on; plot3(ModelPointsTrans(:,1),ModelPointsTrans(:,2),ModelPointsTrans(:,3),'g+'); hold off;
% 
% tom_vol2chimera(tom_filter(VolModel,2),tom_filter(VolModelTransToOrg,2),tom_filter(volAlg,2));
% vmtmp=VolModel>0.2;
% vTrtmp=VolModelTransToOrg>0.2;
% for i=1:nrPoints
%   [a1,b,vmtmp]=tom_peak(vmtmp,3);
%   [a2,b,vTrtmp]=tom_peak(vTrtmp,3);
%   disp(['point: ' num2str(i) ' Model ' num2str(a1) ' Transformed ' num2str(a2)]);
% end;
% 
%
%REFERENCES
%
%SEE ALSO
%   
%  tom_volume2PointCloud
%
%   created by FB 01/24/12
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

if (nargin < 3)
    mid=[0 0 0];
end;

if (nargin < 4)
    do_refl=false;
end;

if (nargin < 5)
    do_scale=false;
end;

if (nargin < 6)
    vol_model='';
end;

if (size(cloud_tmpl,1) > size(cloud_model,1))
   warning('size cloud_tmpl > size cloud_model check results');
   cloud_tmpl=cloud_tmpl(1:size(cloud_model,1),:);
end;
if (size(cloud_tmpl,1) < size(cloud_model,1))  
    warning('size cloud_tmpl < size cloud_model check results');
    cloud_model=cloud_model(1:size(cloud_tmpl,1),:);  
end;

nrPoints=size(cloud_tmpl,1);
midMatrix=repmat(mid,nrPoints,1);


cloud_tmpl=cloud_tmpl-midMatrix;
cloud_model=cloud_model-midMatrix;


[D,cloud_model_alg,transform]=procrustes(cloud_tmpl,cloud_model,'Reflection',do_refl,'Scaling',do_scale);

param.transform=transform;
param.D=D;

cloud_model_alg=cloud_model_alg+midMatrix;

if (isempty(vol_model)==0)
    vol_model=tom_rotate(vol_model,inv(param.transform.T));
    vol_model=tom_move(vol_model,round(param.transform.c(1,:)));
end;


