function [angles,shifts,ccf_peak,partAlg,ccf_max,rotM]=tom_av3_align(ref,part,phi,psi,theta,mask,filter,mask_ccf,wedge_ref,wedge_part,nrOptSteps,cutParam)
%TOM_AV3_ALIGN performs three-dimensional alignment of two volumes ...
% taking the missing wedge of both volumes (particles) into account.
% Cross-correlation is normed between -1:1 and calculated inside a
% mask-volume.
%
%   [angles,shifts,ccf_peak,rot_part,ccf_max,angle_max,rotM]=tom_av3_align(ref,part,phi,psi,theta,mask,filter,mask_ccf,wedge_ref,wedge_part,nrOptSteps)
%
%PARAMETERS
%
%  INPUT
%   ref                 reference particle
%   part                particle to be aligned
%   phi                 vector of Euler-angles to be scanned start:increment:stop
%   psi                 vector of Euler-angles to be scanned start:increment:stop
%   theta               vector of Euler-angles to be scanned start:increment:stop
%   mask                mask volume inside the ccf is calculated
%   filter              ...
%   mask_ccf            mask volume applied to the ccf
%   wedge_ref           missing wedge volume of reference in real space
%   wedge_part          missing wedge volume of particle in real space
%   nrOptSteps          (6) number of opt steps   
%   verbose             (1) verblevel 0 no output 2 max
%   cutParam            ('') SORRY NOT IMPLEMENTED !!
%
%  OUTPUT
%   angles              corresponding angles to maximum ccc
%   shifts              corresponding shifts to maximum ccc
%   ccf_peak            maximum ccc value
%   partAlg             aligned part
%   ccf_max             full maximum ccf function
%   rotM                rotation matrix
%
%EXAMPLE
%   v=tom_av2_build_artificial26S;
%   v2=-tom_bin(v,2);
%   yyy=zeros(size(v2));
%   wedge_ref=tom_wedge(yyy,30);
%   v2_rot_wedge=tom_apply_weight_function(tom_shift(tom_rotate(v2,[0 10 20]),[0 0 0]),wedge_ref);
%   mask=tom_spheremask(ones(size(v2)));
%   [angles,shifts,ccf_peak,rot_part,ccf_max,angle_max]=tom_av3_align(v2,v2_
%   rot_wedge,[0 10 20],[0 10 20],[0 10 20],mask,filter,mask,wedge_ref,wedge_ref);
%
%   Example 2:
%   where=which('20S_full_res.em');
%   s20=tom_emread(where);
%   s20.Value=tom_filter(s20.Value,3);
%   b=-tom_bin(s20.Value,1);
%   b_rot_shift=tom_shift(tom_rotate(b,[32 -17 6]),[-4 1 3]);
%   [angles,shifts,ccf_peak,partAlg,ccf_max,angle_max]=tom_av3_align(b,b_rot_shift,[-40 20 40],[-40 20 40],[-40 20 40]);
%   PostpartAlg=tom_shift(tom_rotate(part,angles),shifts);
% 
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 20/11/13
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


%parse inputs

if (sum(size(part)==size(ref))~=3)
    error('volumes have different size!');
end;

if (nargin < 6)
    mask=tom_spheremask(ones(size(part)),(size(part,1)./2)-1);
end;

if (nargin < 7)
    filter.Apply=0; 
end;

if (nargin < 8)
    mask_ccf=ones(size(part));
end;

if (nargin < 9)
    wedge_ref='';
end;

if (nargin < 10)
    wedge_part=''; 
end;

if (nargin < 11)
    nrOptSteps=3;
end;

if (nargin < 12)
    verbose=1;
end;

if (nargin < 13)
    cutParam='';
end;

if (isempty(cutParam)==0)
     error('NOT Implemented');
end;


if isempty(cutParam)==0
    if (isfield(cutParam,'center')==0)
        cutParam.center=tom_cm(mask);
    end;
    cutParam.topLeft=cutParam.center-(floor(cutParam.size./2))+1;
end;


if (isempty(mask_ccf))
    mask_ccf=ones(size(part));
end;

partOrg=part;
[ref,part,mask,mask_ccf,wedge_ref,wedge_part]=CutAllVols(ref,part,mask,mask_ccf,wedge_ref,wedge_part,cutParam);

partAlg=part;
phi_act=phi;
psi_act=psi;
theta_act=theta;


if (verbose>1)
    [cccNoTrans,cccTrans,inishift]=initialScore(ref,partAlg,mask,filter,wedge_ref,wedge_part);
    disp(['Step Nr ' num2str(0) ':  cc: '  sprintf('%5.3f',cccNoTrans) ' angle: ' sprintf('%5.2f %5.2f %5.2f',0,0,0) '  shift: ' sprintf('%5.2f %5.2f %5.2f',0,0,0)]);
    disp(['Step Nr ' num2str(0) ':  cc: '  sprintf('%5.3f',cccTrans) ' angle: ' sprintf('%5.2f %5.2f %5.2f',0,0,0) '  shift: ' sprintf('%5.2f %5.2f %5.2f',inishift(1),inishift(2),inishift(3))]);
end;

if (verbose>0)
    disp('Alignment started!');
end;    
    
for i=1:nrOptSteps
    [anglesTmp,shiftsTmp,ccf_peak,ccf_max]=alignPart2Ref(ref,partAlg,phi_act,psi_act,theta_act,mask,filter,mask_ccf,wedge_ref,wedge_part); 
    all_angles(i,:)=[-anglesTmp(2) -anglesTmp(1) -anglesTmp(3)];
    all_shifts(i,:)=-shiftsTmp;
    [angles,shifts,rotM]=tom_sum_rotation(all_angles,all_shifts);
    partAlg=tom_shift(tom_rotate(partOrg,angles),shifts); %Transformation missing to use uncut Volmue and cut it later!! 
    partAlg=CutVol(partAlg,cutParam);
%     phi_act=phi./(2^i);
%     psi_act=psi./(2^i);
%     theta_act=theta./(2^i);
    phi_act=[-phi(2) phi(2) phi(2)]./(2^i);
    psi_act=[-psi(2) psi(2) psi(2)]./(2^i);
    theta_act=[-theta(2) theta(2) theta(2)]./(2^i);
    disp(['  Step Nr ' num2str(i) ':  cc: '  sprintf('%5.3f',ccf_peak) ' angle: ' sprintf('%5.2f %5.2f %5.2f',angles(1),angles(2),angles(3)) '  shift: ' sprintf('%5.2f %5.2f %5.2f',shifts(1),shifts(2),shifts(3))]);
end;

if (verbose>0)
    disp('Alignment done!');
end;    


function [cccNOTrans,cccTrans,shift]=initialScore(ref,part,mask,filter,wedge_ref,wedge_part)

mid=floor(size(ref)./2)+1;

part=tom_apply_filter(part,filter);
ref=tom_apply_filter(ref,filter);
if isempty(wedge_ref) && isempty(wedge_part)
    ccf=tom_corr(ref,part,'norm',mask);
else
    
    yyy=zeros(size(part));
    yyy(1,1,1) =1;
    psf_ref=real(tom_ifourier(ifftshift(fftshift(tom_fourier(yyy)).*wedge_ref)));
    psf_part=real(tom_ifourier(ifftshift(fftshift(tom_fourier(yyy)).*wedge_part)));
    ccf=tom_corr(part,ref,'norm',mask,psf_ref,psf_part);
end;
cccNOTrans=ccf(mid(1),mid(2),mid(3));
[pos,cccTrans]=tom_peak(ccf);
shift=pos-mid;


function VolCut=CutVol(Vol,cutParam)

if (isempty(Vol))
    VolCut='';
    return;
end;

if (isempty(cutParam))
    VolCut=Vol;
else
    VolCut=tom_cut_out(Vol,cutParam.topLeft,cutParam.size);
end;

function [ref,part,mask,mask_ccf,wedge_ref,wedge_part]=CutAllVols(ref,part,mask,mask_ccf,wedge_ref,wedge_part,cut_param)

if (isempty(cut_param))
    return;
end;

ref=CutVol(ref,cut_param);
part=CutVol(part,cut_param);
mask=CutVol(mask,cut_param);
mask_ccf=CutVol(mask_ccf,cut_param);
wedge_ref=CutVol(wedge_ref,cut_param);
wedge_part=CutVol(wedge_part,cut_param);


function [angles,shifts,ccf_peak,ccf_max]=alignPart2Ref(ref,part,phi,psi,theta,mask,filter,mask_ccf,wedge_ref,wedge_part) 

part=tom_apply_filter(part,filter);

if isempty(wedge_part)==0
    yyy=zeros(size(part));
    yyy(1,1,1) =1;
    psf_part=real(tom_ifourier(ifftshift(fftshift(tom_fourier(yyy)).*wedge_part)));
end;

if isempty(wedge_ref)==0
    wedge_ref=ones(size(ref));
end;

demo_mode=0;
if (demo_mode==1)
    h1=figure;set(h1,'DoubleBuffer','on');set(h1,'Position',[106   543   627   507]); set(h1,'Name','ref_rot');
    h2=figure; set(h2,'DoubleBuffer','on');set(h2,'Position',[104    34   629   426]); set(h2,'Name','part');
    h3=figure; set(h3,'DoubleBuffer','on');set(h3,'Position',[739   544   622   506]); set(h3,'Name',['ccf ' ]);
end;

offset=[0 0 0;270 90 0];
%offset=[0 0 0];
angList4Scan=genAngList4Scan(phi,psi,theta,offset);
ccf_max=ones(size(angList4Scan,1),1).*-1;

wb=tom_progress(size(angList4Scan,1),'scanning angles');
for zz=1:size(angList4Scan,1)
    [rotmatrix]=tom_angles2rotmatrix(angList4Scan(zz,:));
    ref_rot=tom_rotate(ref,[rotmatrix]);
    if isempty(wedge_ref) && isempty(wedge_part)
        ref_rot=tom_apply_filter(ref_rot,filter);
        ccf=tom_corr(ref_rot.*mask,part.*mask,'norm',mask);
        if (demo_mode==1)
            figure(h1);tom_dspcub(ref_rot);
            figure(h2);tom_dspcub(part);
            figure(h3);tom_dspcub(ccf);
            drawnow;
        end;
    else
        wedge_ref_rot=tom_rotate(wedge_ref,[i_phi i_psi i_theta]);
        psf_ref=real(tom_ifourier(ifftshift(fftshift(tom_fourier(yyy)).*wedge_ref_rot)));
        ref_rot=tom_apply_filter(ref_rot,filter);
        ref_rot=ref_rot.*mask;
        part=part.*mask;
        ccf=tom_corr(ref_rot,part,'norm',mask,psf_ref,psf_part);
        if (demo_mode==1)
            figure(h1);tom_dspcub(ref_rot);
            figure(h2);tom_dspcub(part);
            figure(h3);tom_dspcub(ccf);
            drawnow;
        end;
    end;
    [~,ccf_max(zz)]=tom_peak(ccf.*mask_ccf);     
    wb.update();
end;
wb.close;      
clear('wb'); 

[val,posMax]=max(ccf_max);
angles=angList4Scan(posMax,:);


%get subpixel
rot_ref=tom_rotate(ref,angles);
ccf_s=tom_corr(rot_ref.*mask,part.*mask,'norm',mask);
[pos,ccf_peak]=tom_peak(ccf_s.*mask_ccf,'spline');

shifts=pos-(floor(size(part)./2)+1);

function angList4Scan=genAngList4Scan(phi,psi,theta,offset)

zz=1;
for ii=1:size(offset,1)
    for i_phi=phi(1):phi(2):phi(3)
        for i_psi=psi(1):psi(2):psi(3)
            for i_theta=theta(1):theta(2):theta(3)
                angList4Scan(zz,:)=[i_phi+offset(ii,1) i_psi+offset(ii,2) i_theta+offset(ii,3)];
                zz=zz+1;
            end;
        end;
    end;
end;





