function [cc,vol_list] = tom_av3_ccmat(particlefilename, appendix, npart, mask,hipass,lowpass,ibin,alg_param,cutParam)
% TOM_AV3_CCCMAT computes correlation- matrix of densities 
%
%
%   [cc,vol_list] = tom_av3_ccmat(particlefilename, appendix, npart, mask,hipass,lowpass,ibin,alg_param,cutParam)
%
% PARAMETERS
%  INPUT
%   particlefilename    filename of 3D-particles to be correlated
%                           'particlefilename'_#no.em or
%                           'particlefilename'_#no.mrc
%   appendix            appendix for files - em or mrc or hdf
%   npart               number of densities (=last index)
%   mask                ('') mask 4 calc of cc mat - make sure dims are all right! ... use '' 2 swich off  
%   hipass              (-1) hipass - for X-corr use -1 to switch off
%   lowpass             (-1) lowpass - for X-corr use -1 to switch off
%   ibin                (0) binning 
%   alg_param           ('') parmeters 4 3d Alignment
%                            alg_param.implemetation so far only tom suppoert
%                            alg_param.angScan scanning range 4 phi psi and theta
%                            alg_param.mask mask 4 alignment
%
%   cutParam            ('') cut a cubic around the center form cutParam                                  
%                            for speeding up alignment and classification 
%                            use the center of mask (opt. and alg_parma.mask)
%                            NOTE: large shifts can induce artefacts 
%                            %if mask radius*2 ~= cut.size 
%                            cutParma.size size of the box 
%                            cutParma.center center of the box
%  OUTPUT
%   ccc                 cross correlation matrix
%   vol_list            list of use volumes ...for further processing
%
% EXAMPLE
% %example without alignment
% mask = tom_spiderread('/fs/sandy03/lv04/pool/pool-titan1/CWT/combined/rec/projm_29_31__34_HiATPyS1mcl_39/output/models/mask_refine.spi');
% mask=mask.Value;
% cc = tom_av3_ccmat('/fs/sandy03/lv04/pool/pool-titan1/CWT/combined/rec/projm_29_31__34_HiATPyS1mcl_39/output/models/align/model_aligned', ...
%        'mrc', 7, mask,0,100,2);
% tree = linkage(squareform(1-cc),'average');
% dendrogram(tree, 'ColorThreshold', .08);
%
%%example with alignment
% mask = tom_spiderread('/fs/sandy03/lv04/pool/pool-titan1/CWT/combined/rec/projm_29_31__34_HiATPyS1mcl_39/output/models/mask_refine.spi');
% mask=mask.Value;
% alg_param.implemetation='tom';
% alg_param.angScan=[-10 5 10];
% alg_param.mask=mask;
%
% cc = tom_av3_ccmat('/fs/sandy03/lv04/pool/pool-titan1/CWT/combined/rec/projm_29_31__34_HiATPyS1mcl_39/output/models/align/model_aligned', ...
%        'mrc', 7, mask,0,100,2,alg_param);
% tree = linkage(squareform(1-cc),'average');
% dendrogram(tree, 'ColorThreshold', .08);
%
%
%
%
% SEE ALSO
%   av3_cccmat, TOM_CORR, TOM_ORCD,tom_tree2chimera
%
%   Copyright (c) 2005-2012
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/foerster
%
%
if nargin < 4
    mask = '';
end;

if nargin < 5
    hipass = -1;
end;

if nargin < 6
    lowpass = -1;
end;

if nargin < 7
    ibin = 0;
end;

if ibin>0
    mask = tom_bin(mask,ibin)>0;
end;

if (nargin < 8)
    alg_param='';
end;

if (nargin < 9)
    cutParam='';
end;

if isempty(cutParam)==0
    tmpPart=readParticle(particlefilename,1,appendix);
    cutParam.topLeft=cutParam.center-(floor(cutParam.size./2))+1;
    if (isempty(find((cutParam.topLeft)<=0) )==0)
        error('Negative or 0 topLeft coordinate');
    end;
    if (isempty(find(([(cutParam.topLeft+cutParam.size)] > size(tmpPart.Value))) )==0)
        error('topLeft + size > size of particle');
    end;
end;


cc = zeros(npart,npart);
parfor indpart1 = 1:npart
%for indpart1 = 1:npart    
    cc(indpart1,:)=corr_worker(indpart1,particlefilename, appendix, npart, mask,hipass,lowpass,ibin,alg_param,cutParam);
    disp(['Correlation computed for particle no ' num2str(indpart1) ' ...']);
end;

cc=symMatrix(cc,npart);

if (nargout > 1)
    for indpart1 = 1:npart
        vol_list{indpart1}=[particlefilename '' num2str(indpart1) '.' appendix];
    end;
end;

function cc=corr_worker(indpart1,particlefilename, appendix, npart, mask,hipass,lowpass,ibin,alg_param,cutParam)

mask4Corr=CutImg(mask,cutParam);
part1=readParticle(particlefilename,indpart1,appendix);
[part1,part1NoMask]=preProcParticle(part1,ibin,hipass,lowpass,'','',mask4Corr,cutParam);


for indpart2 =indpart1:npart
    part2=readParticle(particlefilename,indpart2,appendix);
    part2=preProcParticle(part2,ibin,hipass,lowpass,alg_param,part1NoMask,mask4Corr,cutParam);
    cc(1,indpart2) = corrParts(part1,part2,mask4Corr);
end;

function val=corrParts(part1,part2,mask)

if (isempty(mask))
    ccf=tom_corr(part1,part2,'norm');
else
    ccf=tom_corr(part1,part2,'norm',mask);
end;
[pos,val]=tom_peak(ccf,'spline');
    

function ImgCut=CutImg(Img,cutParam)

if (isempty(cutParam))
    ImgCut=Img;
else
    ImgCut=tom_cut_out(Img,cutParam.topLeft,cutParam.size);
end;

function part=readParticle(particlefilename,indpart,appendix)

if strcmp(appendix,'em')
    name = [particlefilename '' num2str(indpart) '.em'];
    part = tom_emread(name);
elseif strcmp(appendix,'mrc')
    name = [particlefilename '' num2str(indpart) '.mrc'];
    part = tom_mrcread(name);
elseif strcmp(appendix,'hdf')
    name = [particlefilename '' num2str(indpart) '.hdf'];
    part = tom_eman2_read(name);
else
    error('appendix must be em,hdf or mrc');
end;



function [part,partNoMask]=preProcParticle(part,ibin,hipass,lowpass,alg_param,ref,mask4ccMat,cutParam)

if ibin > 0
    part = tom_bin(part2.Value,ibin);
else
    part = part.Value;
end;
if (lowpass~=-1)
    part = tom_bandpass(part,hipass,lowpass,5);
end;

part=CutImg(part,cutParam);


if (isempty(alg_param)==0)
    
    
    %part=tom_av3_align_xmipp(ref,part,alg_param(1,:),alg_param(1,:),alg_param(1,:),alg_param(2,:),alg_mask);
    if (strcmp(alg_param.implemetation,'tom'))
        if (isfield(alg_param,'mask')==1)
            alg_param.mask=CutImg(alg_param.mask,cutParam);
            [angles,shifts]=tom_av3_align(ref,part,alg_param.angScan,alg_param.angScan,alg_param.angScan,alg_param.mask);
        else
            [angles,shifts]=tom_av3_align(ref,part,alg_param.angScan,alg_param.angScan,alg_param.angScan);
        end;
       
        part=tom_shift(tom_rotate(part,angles),shifts);
    end;
end;

partNoMask=part;
if (isempty(mask4ccMat))
    part = partNoMask;
else
    part = part.*mask4ccMat;
end;



function cc=symMatrix(cc,npart)

%symmetrize matrices
for indpart1 = 1:npart
    cc(indpart1,indpart1) = 1;
    for kk = indpart1:npart-1
        indpart2 = kk + 1;
        cc(indpart2,indpart1) = cc(indpart1,indpart2);
    end;
end;


