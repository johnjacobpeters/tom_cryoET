function [average,weiInv,weiOrg,avgNoWei]=tom_av3_average(motl,method,threshold,iclass,waitbarflag,dropPartsPath,smallestCorrVal)
%TOM_AV3_AVERAGE averages subtomograms
%
%   average=tom_av3_average(motl,method,threshold,iclass,waitbarflag)
%
%   tom_av3_average is designed for averaging subtomogram 
%   (PARTICLEFILENAME = 'filename'_#no.em) using the parameters of the
%   MOTL. If THRESHOLD is specified only particle with a CCC >
%   thresold*mean(ccc) are included into the average. If ICLASS is
%   specified only particles of this class will be included into the
%   average. 
%
%   ALIGN                ALIGN structure (see tom_AV3_TRANS_ROT_ALIG for format)
%   method              all angles and shifts can be applied:
%                       'direct' as is, or
%                       'inverse' angles Phi and Psi are flipped and change
%                       its signum. Translation also changes its signum.
%
%PARAMETERS
%
%  INPUT
%   motl                ...
%   method              ...
%   threshold           ...
%   iclass              ...
%   waitbarflag         ...
%   dropPartsPath        
%  OUTPUT
%   average             ...
%
%EXAMPLE
%   ... = tom_av3_average(...);
%   creates ...
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FF 03/31/05
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

if nargin < 2
    method = 'inverse';
end;

if nargin<3
    threshold = -1;
end;

if nargin<4
    iclass = 0;
end;

if nargin < 5
    waitbarflag = 0;
end

if (nargin <6)
    dropPartsPath='';
end;

if (nargin <7)
    smallestCorrVal=0.15;
end;


if waitbarflag == 1
    h = waitbar(0,'Creating average particle');
end

indx = find (tom_substr2stream(motl,'CCC') >= 0); 
meanv = mean(tom_substr2stream(motl,'CCC',indx));% find ultimate solution!!!!


try
    tsize = motl(1).Tomogram.Header.Size';
catch
    prompt = {'Enter templatesize x:','Enter templatesize y:','Enter templatesize z:'};
    dlg_title = 'Missing template size';
    num_lines = 1;
    def = {'','',''};
    answer = inputdlg(prompt,dlg_title,num_lines,def,'on');
    tsize = [str2num(answer{1}), str2num(answer{2}), str2num(answer{3})];
end

%avmatrix = zeros(tsize);

itomo_old = 0;
icount = 0;
%loop over all particles in motl-list

if (isempty(dropPartsPath)==0)
    warning off; mkdir(dropPartsPath); warning on;
    warning off; mkdir([dropPartsPath '/wedge']); warning on;
    warning off; mkdir([dropPartsPath '/parts']); warning on;
    
end;

for indpart = 1:size(motl,2)
    if  ((motl(indpart).CCC)>=threshold*meanv) && (motl(indpart).Class == iclass) 
        icount = icount +1;
        itomo = motl(indpart).Filename;
        xshift = motl(indpart).Shift.X;
        yshift =motl(indpart).Shift.Y;
        zshift = motl(indpart).Shift.Z;
        tshift = [xshift yshift zshift];
        phi= motl(indpart).Angle.Phi;
        psi=motl(indpart).Angle.Psi;
        the=motl(indpart).Angle.Theta;
        ifile = indpart; %????
        name=motl(indpart).Filename;
        
        try
            particle = tom_emreadc(name); 
        catch Me
            Me.message;
            disp(['cannot read: '  name]);    
        end;
        
        particle = particle.Value;
        
        if icount == 1
            wei = zeros(size(particle,1),size(particle,2),size(particle,3));
            average = wei;
            mask4wedge=tom_spheremask(ones(size(particle)),round(size(particle,1)./2)-2,2);
        end;
        
        
        maxangle = motl(indpart).Tomogram.AngleMin;
        minangle = motl(indpart).Tomogram.AngleMax;
        %FIXME
        if maxangle == 0
            maxangle = 65;
        end
        
        if minangle == 0
            minangle = -65;
        end
        
        
        wedge = tom_av3_wedge(particle,minangle,maxangle);
        itomo_old = itomo;
        %        end;
        if isequal(method,'inverse')
            particle = double(tom_rotate(tom_shift(particle,-tshift),[-psi -phi -the]));
        elseif isequal(method,'direct')
            particle = double(tom_rotate(tom_shift(particle,tshift),[phi psi the]));
        elseif isequal(method,'direct_dd')
            particle = double(tom_shift(tom_rotate(particle,[phi psi the]),tshift));
        else %sum
            particle = double(tom_shift(tom_rotate(particle,motl(indpart).Angle.Rotmatrix),tshift));
        end;
        
        particle = tom_norm(particle,1);
        
        average = average + particle;
        
        
        if isequal(method,'inverse')
            tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
        elseif isequal(method,'direct')
            tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[phi psi the])),0.5,1,'z'),0,0.5);
        elseif isequal(method,'direct_dd')
            tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[phi psi the])),0.5,1,'z'),0,0.5);
        else
            %rotation matrix
            tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,motl(indpart).Angle.Rotmatrix)),0.5,1,'z'),0,0.5);
        end;
        
        if (isempty(dropPartsPath)==0)
            [fpath,fname,fext]=fileparts(name);
            tom_emwrite([dropPartsPath '/parts/' filesep fname fext],particle);
            tom_emwrite([dropPartsPath '/wedge/' filesep fname fext],tmpwei.*mask4wedge);
        end;
        
        wei = wei + tmpwei;
        if waitbarflag == 1
            waitbar(indpart./size(motl,2),h,[num2str(indpart), ' of ', num2str(size(motl,2)), ' files done.']);
        elseif waitbarflag == 0
            disp(['Particle no ' num2str(ifile) ' added to average'  ]);
        end
    end;%if - threshold
end;
% lowp = floor(size(average,1)/2)-3;
% wei = 1./wei;
% rind = find(wei > 1000);
% wei(rind) = 0;% take care for inf
% average = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average)).*wei,lowp))));
avgNoWei=average;
weiOrg=wei.*tom_spheremask(ones(size(wei)),(size(wei,1)/2)-1);

wei=tom_norm(wei,1);
wei(find(wei==0))=1;
wei(find(wei<smallestCorrVal))=smallestCorrVal;
weiInv=1./wei;

weiInv=tom_filter(weiInv,2);
weiInv=weiInv.*mask4wedge;
average = tom_apply_weight_function(average,weiInv);

% weiInverted=wei;
% rind=find(wei<200);
% weiInverted(rind)=200;
% 
% weiInverted=(1./weiInverted).*mask4wedge;
% 
% average = 

if waitbarflag == 0
    disp(['Averaging finished - ' num2str(icount) ' particles averaged ... '  ]);
elseif waitbarflag == 1
    close(h);
end