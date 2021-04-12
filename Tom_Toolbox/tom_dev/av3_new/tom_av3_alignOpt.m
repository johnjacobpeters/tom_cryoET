function [rot,shift,score,partAlg]=tom_av3_alignOpt(ref,part,initialAngle,mask,sampleVect,maxRot,ccMask4Shift,dispLevel,options)
%TOM_AV3_ALIGN performs three-dimensional alignment of two volumes
% useing fmincon optimizer
% 
%  [rot,shift,score,partAlg]=tom_av3_alignOpt(ref,part,options)
%  
%
%PARAMETERS
%
%  INPUT
%   ref                 reference particle
%   part                particle to be aligned
%   initialAngle        initial angle for opt
%   mask                mask to focus alignment   
%   sampleVect            ('') struct to sample with mult start points            
%   maxRot              max rotation anlong quad axis  
%   ccMask4Shift        mask for restricting shift
%   dispLevel           ([0 0]) display level for text and figures
%   options             option 4 cc
%
%  OUTPUT
%   angle              corresponding angles to maximum ccc
%   shift              corresponding shifts to maximum ccc
%   score              maximum ccc value
%   partAlg            aligned part
%
%EXAMPLE
%
% ref=tom_rotate(tom_cylindermask(ones(64,64,64),8),[270 90 90]);
% ref(1:12,:,:)=0;
% ref(end-12:end,:,:)=0;
% ref=ref+tom_spheremask(ones(size(vol)),5,0,[41 41 41]);
% 
% 
% vol=tom_rotate(tom_shift(ref,[-1 -2 3]),[5 6 -7]);
% [rot,shift,score,partAlg]=tom_av3_alignOpt(ref,vol,[0 0 0]);
%  dist=tom_angular_distance([-6 -5 7],rot)
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

if (nargin<3)
    initialAngle=[0 0 0];
end;

if (nargin<4)
    mask=tom_spheremask(ones(size(part)),round(size(part,1)./2)-1);
end;

if (nargin<5 || isempty(sampleVect))
   sampleVect=[1 3];
end;

if (nargin<6 || isempty(maxRot) )
    maxRot=30;
end;

if (nargin<7 ||  isempty(ccMask4Shift))
    ccMask4Shift=tom_spheremask(ones(size(part)),round(size(part,1)./2)-1);
end;

if (nargin<8)
    dispLevel=[0 0];
end;

if (nargin<9)
   
    options = optimoptions('fmincon');
    
   
    %options = optimoptions(options,'TolFun',1.0000e-06);
    %options = optimoptions(options,'TolX', 1.0000e-04);
    
    options = optimoptions(options,'TolFun',1.0000e-04);
    options = optimoptions(options,'TolX', 5.0000e-04);
    
    
   
    options = optimoptions(options,'DiffMaxChange', 40);
    options = optimoptions(options,'DiffMinChange', 0.0001);
    options = optimoptions(options,'FinDiffRelStep', 1.0000e-05);
    options = optimoptions(options,'Hessian', {  'lbfgs' 20 });
    
     options = optimoptions(options,'Display', 'off');
    if (dispLevel(1)==2 || dispLevel(1)==3 )
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'Diagnostics', 'on');
    end;
    
    if (dispLevel(2)==2 || dispLevel(2)==3)
        options = optimoptions(options,'PlotFcns', {  @optimplotx @optimplotfunccount @optimplotfval @optimplotconstrviolation @optimplotstepsize @optimplotfirstorderopt myPlf});
    end;
end;

poleAngle=[90 90 90];
maskIdx=find(mask>0);


Aineq=[0 0 0]; % ?? check and docu
bineq=50; % ?? check and docu

initialAngleOrg=initialAngle;
for i=1:sampleVect(1)
    [partTrans,AllAngleTrans(i,:)]=transform2Pole(part,initialAngle,poleAngle);
    fref=normAndFourier(ref,maskIdx,mask);
    
    f=@(x)localCost(x,fref,partTrans,mask,maskIdx,ccMask4Shift,poleAngle,maxRot,dispLevel);
    
    startAng=poleAngle;
    
    [rot(i,:),score(i)] = fmincon(f,startAng,Aineq,bineq,[],[],[],[],[],options);
    initialAngle=tom_sum_rotation([initialAngleOrg;rand(1,3).*sampleVect(2)*0.4],[0 0 0;0 0 0]);
end;
[~,posmin]=min(score);
rot=rot(posmin,:);
angTrans=AllAngleTrans(posmin,:);
rot=reTransformAngle(angTrans,rot);

[shift,score,partAlg]=ShiftAndScore(ref,part,rot,mask,ccMask4Shift,nargout);




function f = localCost(x,ref,vol,mask,maskIdx,mask4CC,initialAngle,maxRot,dispLevel)

vol=tom_rotate(vol,[x(1) x(2) x(3)]);

cc=corr_local(ref,vol,mask,maskIdx);
[posT,val]=tom_peak(cc.*mask4CC,'spline');
f=double(val(1).*-1);
angDist=tom_angular_distance(initialAngle,[x(1) x(2) x(3)]);

if (angDist>maxRot)
    diffAng=angDist-maxRot;
    quot=(diffAng+1);
    if (f<=0)
        fact=(1./quot)*1.5;
    end;
    if (f>0)
        fact=quot./1.5;
    end;
    f=f.*fact;
    if (f(1)==0)
        f=f+0.05;
    end;
end;

if (dispLevel(1)==1 || dispLevel(1)==3)
    disp(['AngularDistance:' num2str(angDist) ' f: ' num2str(f) ' angle: ' num2str(x(1)) ' '  num2str(x(2)) ' '  num2str(x(3)) ]);
end;

if (dispLevel(2)==1 || dispLevel(2)==3)
    midSl=floor(size(vol)./2)+1;
    refR=tom_ifourier(ref);
    sh=round(posT-midSl);
    vol=vol.*mask;
    vol=tom_move(vol,sh);
   
    subplot(3,3,1); imagesc(refR(:,:,midSl(3)));axis image; colormap gray;  title('ref');
    subplot(3,3,2); imagesc(squeeze(refR(:,midSl(2),:))); axis image; colormap gray; title('ref');
    subplot(3,3,3); imagesc(squeeze(refR(midSl(1),:,:))); axis image; colormap gray;title('ref');
    
    subplot(3,3,4); imagesc(vol(:,:,midSl(3)));axis image; colormap gray;  title('part');
    subplot(3,3,5); imagesc(squeeze(vol(:,midSl(2),:))); axis image; colormap gray; title('part');
    subplot(3,3,6); imagesc(squeeze(vol(midSl(1),:,:))); axis image; colormap gray;title('part');
    subplot(3,3,7); hold on; plot(f,'ro'); hold off;
    drawnow;
%     fh=get(gcf);
%     if (isempty(fh.UserData))
%         fh.UserData=1;
%     else
%         fh.UserData=fh.UserData+1;
%     end;
%     iter=fh.UserData;
    %subplot(3,3,7); hold on; plot(iter,f,'r-'); hold off;
end;



function rot=reTransformAngle(initialAngleTrans,rot)

rot=tom_sum_rotation([initialAngleTrans;rot],[0 0 0;0 0 0]);


function fref=normAndFourier(ref,maskIdx,mask)

ref=norm_inside_mask(ref,maskIdx,mask);
fref=tom_fourier(ref);


function [shift,score,partAlg]=ShiftAndScore(ref,part,rot,mask,maskCC,nargOut)

mid=floor(size(part)./2)+1;
partAlg=tom_rotate(part,rot);

cc=tom_corr(ref.*mask,partAlg.*mask,'norm',mask);
[pos,score]=tom_peak(cc.*maskCC,'spline');
shift=mid-pos;

if (nargOut>3)
    partAlg=tom_shift(partAlg,shift);
end;


function ccf = corr_local(a,b,mask,maskIdx)

n=length(maskIdx);
b=norm_inside_mask(b,maskIdx,mask);
ccf = real(ifftshift(tom_ifourier(a.*conj(tom_fourier(b)))))./n;



function normed_vol=norm_inside_mask(vol,maskIdx,mask)

mea=mean(vol(maskIdx));
st=std(vol(maskIdx));
normed_vol=((vol-mea)./st).*mask;


function [vol,angTrans]=transform2Pole(vol,initialAngle,poleAngle)

angTrans=tom_sum_rotation([initialAngle(1) initialAngle(2) initialAngle(3); poleAngle.*-1],[0 0 0;0 0 0]);
vol=tom_rotate(vol,angTrans);


%lagacy and don't know!!

% function stop = myoutfun(x,optimValues,state)
% stop = false;
% % Check if user has requested to stop the optimization.
% stop = getappdata(hObject,'optimstop');
% myPlf=@(x,optimValues,state)myPlotFun(x,optimValues,state);
% 
% 
% function stop = myPlotFun(x,optimValues,state)
% stop = false;
% 
% dist=tom_angular_distance(x(1),x(2),x(3));
% 



 