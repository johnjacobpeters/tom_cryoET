function [angles shifts ccc refidx ref_out mirror, stack_out] = tom_HT_align2d(refs,stack,mask_im,mask_cc_rot,mask_cc_trans,filter,binning,iterrefine,iteralign,mirrorflag,demo,waitbarflag)


numparticles = size(stack,3);

%bin references
if binning > 0 && ~isscalar(refs)
    refs_bin = zeros(size(refs,1)./2^binning,size(refs,2)./2^binning,size(refs,3),'single');
    parfor (i=1:numrefs)
        refs_bin(:,:,i) = tom_binc(refs(:,:,i),binning);
    end
    refs = refs_bin;
end

%bin particles
if binning > 0
    stack_bin = zeros(size(stack,1)./2^binning,size(stack,2)./2^binning,numparticles,'single');
    parfor (i=1:numparticles)
        stack_bin(:,:,i) = tom_binc(stack(:,:,i),binning);
    end
    stack = stack_bin;
end

%create random references if no refs are given
if isscalar(refs)
    refnum = refs;
    classes = uint8(ceil(rand(numparticles,1).*refnum));
    imsize = size(stack,1);
    refs = zeros(imsize,imsize,refnum,'single');
    parfor (i=1:refnum)
        idx = find(classes==i);
        refs(:,:,i) = sum(stack(:,:,idx),3);
    end
    
end

im_sz=single(size(refs,1));
middle_im=single(floor(im_sz./2)+1);
numrefs = size(refs,3);
if waitbarflag == 1
    figure(55);tom_dspcub(refs);drawnow;
end

parfor (i=1:numrefs)
    refs(:,:,i) = tom_norm(refs(:,:,i),'mean0+1std');
end

parfor (i=1:numparticles)
    stack(:,:,i) = tom_norm(stack(:,:,i),'mean0+1std');
end


if isempty(mask_im)
    mask_im = tom_sphere([im_sz,im_sz], im_sz./2, 3);
end

if isempty(mask_cc_rot)
    mask_cc_rot = true(size(tom_cart2polar(true(im_sz))));
end

if isempty(mask_cc_trans)
    mask_cc_trans = tom_sphere([im_sz,im_sz], im_sz./4, 3);
end

angles = zeros(numparticles,iterrefine,'single');
shifts = zeros(numparticles,iterrefine,2,'single');
ccc = zeros(numparticles,iterrefine,'single');
refidx = zeros(numparticles,iterrefine,'uint8');
ref_out = zeros(im_sz,im_sz,iterrefine,numrefs,'single');

mirror = false(numparticles,iterrefine);

stack_out = zeros(im_sz,im_sz,numparticles,'single');

workload = numparticles.*iterrefine;
fraction = ceil(workload./100);

worklauf = 1;

%loop over refinement runs
for iter_refine = 1:iterrefine

    %loop over particles
    parfor (particleidx = 1:numparticles)
        
        oldccval = 0;
        im = stack(:,:,particleidx);
        im_initial = im;
        %loop over references
        for refnum=1:numrefs
            
            ref = refs(:,:,refnum);
            
            for mirrorloop = 1:2

                if mirrorloop == 2 && mirrorflag == 1
                    im = tom_mirror(im_initial,'y');
                elseif mirrorloop == 2
                    continue;
                end

                angle_vect=zeros(iteralign,3,'single');
                trans_vect=zeros(iteralign,3,'single');

                im = im .* mask_im;

                if demo ~= 0
                    %demo_al(ref,'ref',0);
                    %demo_al(im,'im',0);
                end
                
                %loop over alignment runs
                for iter_align = 1:iteralign

                    im_org=im;

                    % determine rotation angle by polar xcorrelation
                    im_polar = tom_cart2polar(im);
                    ref_polar = tom_cart2polar(ref);
                    ccf_rot = tom_corr(im_polar,ref_polar,'norm');
                    ccf_rot = ccf_rot .* mask_cc_rot;
                    ccc_pos_rot = tom_peak(ccf_rot,'spline');
                    ccf_rot_sz = size(ccf_rot,2);
                    angle = (360./ccf_rot_sz).*((ccf_rot_sz./2+1)-ccc_pos_rot(2));
                    im_rot = tom_rotate(im_org,-angle);
                    im_rot=im_rot.*mask_im;

                    % determine translation angle by cartesian xcorrelation
                    ccf_trans = tom_corr(im_rot,ref,'norm');
                    ccf_trans = ccf_trans.*mask_cc_trans;
                    ccc_pos_trans = tom_peak(ccf_trans,'spline');
                    shift = ccc_pos_trans - middle_im;

                    if demo ~= 0
                        %demo_al(ref_polar,'ref_polar',0);
                        %demo_al(im_polar,'im_polar',0);
                        %demo_al(ccf_rot,'ccf_rot',ccc_pos_rot);
                        %demo_al(ref,'ref_rot',0);
                        %demo_al(im_rot,'im_rot',0);
                        %demo_al(ccf_trans,'ccf_trans',ccc_pos_trans);
                    end

                    % store all subsequent rotations and translations
                    angle_vect(iter_align,1) = angle;
                    trans_vect(iter_align,1) = shift(1);
                    trans_vect(iter_align,2) = shift(2);

                    % add all subsequent rotations and translations
                    [angle_out shift_out] = tom_sum_rotation(-angle_vect,trans_vect,'rot_trans');
                    aligned_part_sum = tom_shift(tom_rotate(im_initial,angle_out(1)),[shift_out(1) shift_out(2)]);

                    im = aligned_part_sum;

                    if demo ~= 0
                        %demo_al(aligned_part_sum,'im_alg',iter_align);
                    end

                end

                ccf = tom_corr(aligned_part_sum,ref,'norm');
                ccf = ccf .* mask_cc_trans;
                [ccc_pos cccval] = tom_peak(ccf,'spline');

                %save position, angle, cccval and reference number if ccc val
                %is higher than all runs before
                if cccval > oldccval
                    stack_out(:,:,particleidx) = aligned_part_sum;
                    angles(particleidx,iter_refine) = angle_out(1);
                    shifts(particleidx,iter_refine,:) = shift_out(1:2)';
                    refidx(particleidx,iter_refine) = refnum;
                    ccc(particleidx,iter_refine) = cccval;
                    oldccval = cccval;
                    if mirrorflag == 1 && mirrorloop == 2
                        mirror(particleidx,iter_refine) = true;
                    end
                end

            end

            if waitbarflag == 1 && mod(particleidx.*iter_refine,fraction) == 0
                %percent = worklauf./workload;
                %tom_HT_waitbar(percent, ['Iteration ' num2str(iter_refine) ' of ' num2str(iterrefine)]);
            end    
            
        end

        %worklauf = worklauf + 1;
        
    end

    %create averages as new references
    parfor (i=1:numrefs)
        parts = find(refidx(:,iter_refine)==i);
        if ~isempty(parts)
            ref = sum(stack_out(:,:,parts),3);
            ref = tom_norm(ref,'mean0+1std');
            refs(:,:,i) = ref;
            ref_out(:,:,iter_refine,i) = ref;
        end  
    end

    if waitbarflag == 1
       figure(55);tom_dspcub(squeeze(ref_out(:,:,iter_refine,:)));drawnow;
    end
    disp(['Iteration ' num2str(iter_refine) ' done.']);
    
end

if waitbarflag == 1
    close(figure(55));
end

% demo options
function demo_al(im,flag,val)

if isempty(findobj('tag','demo_align2d'))
    figure;
    set(gcf,'tag','demo_align2d');
    set(gcf,'Position',[6 32 766 1092]);
    set(gcf,'Name','tom_av2_alignment_demo');
    set(gcf,'DoubleBuffer','on');
    %     set(gcf,'Toolbar','none');
    %     set(gcf,'MenuBar','none');
    drawnow;
else
    figure(findobj('tag','demo_align2d'));
end

if strcmp(flag,'im')
    subplot(9,3,1); tom_imagesc(im,'noinfo');title('particle');axis off;
    drawnow;

elseif strcmp(flag,'ref')
    subplot(9,3,3); tom_imagesc(im,'noinfo');
    title('reference');axis off;
    drawnow;

elseif strcmp(flag,'im_polar')
    subplot(9,3,4); tom_imagesc(im,'noinfo');title('particle polar');axis off;
    drawnow;

elseif strcmp(flag,'ref_polar')
    subplot(9,3,6); tom_imagesc(im,'noinfo');
    title('reference polar');axis off;
    drawnow;

elseif strcmp(flag,'ccf_rot')
    subplot(9,3,8); tom_imagesc(im,'noinfo');title('xcf polar');axis off;
    hold on; plot(val(1),val(2),'r+'); hold off;
    drawnow;

elseif strcmp(flag,'im_rot')
    subplot(9,3,10); tom_imagesc(im,'noinfo');title('particle rotated');axis off;
    drawnow;

elseif strcmp(flag,'ref_rot')
    subplot(9,3,12); tom_imagesc(im,'noinfo');
    title('reference');axis off;
    drawnow;

elseif strcmp(flag,'ccf_trans')
    subplot(9,3,14); tom_imagesc(im,'noinfo');title('xcf trans');axis off;
    hold on; plot(val(1),val(2),'r+'); hold off;
    drawnow;

elseif strcmp(flag,'im_alg')
    if val<10
        subplot(9,3,15+val);
        tom_imagesc(im,'noinfo');
        title(['particle rot&trans, it: ' num2str(val)]);axis off;
    else
        subplot(9,3,18);
        tom_imagesc(im,'noinfo');
        title(['particle rot&trans, it: ' num2str(val)]);axis off;
    end;
    drawnow;

elseif strcmp(flag,'im_alg_final')
    subplot(9,3,25);
    tom_imagesc(im,'noinfo');
    title('particle rot&trans, final');axis off;
    drawnow;

elseif strcmp(flag,'im_alg_sum')
    subplot(9,3,26);
    tom_imagesc(im,'noinfo');
    title('particle rot&trans, finalsum');axis off;
    drawnow;

elseif strcmp(flag,'im_alg_diff')
    subplot(9,3,27);
    tom_imagesc(im,'noinfo');
    title('particle rot&trans, difference');axis off;
    drawnow;

elseif strcmp(flag,'new_ref_rotated_trans')
    subplot(9,3,21); tom_imagesc(im,'noinfo');
    title('new reference rot&trans');axis off;
    drawnow;
end

