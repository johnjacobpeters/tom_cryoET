function [] =inside_v_outside_pix_int(dir1Name)

%dirName is the directory of your extraction job

maskVal = tom_spheremask(ones([104 104 104]), 30, 1, [52, 52, 52]);
maskValInv = (maskVal - 1) *-1;
figure(4)
%% first directory analysis
list=dir(strcat(dir1Name,'*/*mrc')); 
mrcStats = [];
for i = 1:4%length(list)
    mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name));
    fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name));
    
    inside = mrc.Value.*maskVal;
    outside = mrc.Value.*maskValInv;
    
  
    subplot(2,4,i)
    histogram(inside(inside~=0), 100)
    xlim([-5,5])
    title(strcat('Subtomo', num2str(i), ' - inside mask'))
    xlabel('voxel intensity')
    ylabel('voxel count')
    set(gca,'FontSize',16)
    
    subplot(2,4,i+4)
    histogram(outside(outside~=0),100)
    xlim([-5,5])
    title(strcat('Subtomo', num2str(i), ' - outisde mask'))
     xlabel('voxel intensity')
    ylabel('voxel count')
    set(gca,'FontSize',16)
end