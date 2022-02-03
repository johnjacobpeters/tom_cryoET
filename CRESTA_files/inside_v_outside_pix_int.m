function [mrcStats] =inside_v_outside_pix_int(dir1Name)

%dirName is the directory of your extraction job

%maskVal = tom_spheremask(ones([256 256 256]), 30, 1, [128, 128, 128]);
maskVal = tom_mrcread('2021051275708mask.mrc');
maskVal = maskVal.Value;
maskVal(maskVal<1)=NaN;

maskVal2 = tom_mrcread('2021051275708mask.mrc');
maskValInv = (maskVal2.Value - 1) *-1;
maskValInv(maskValInv<1)=NaN;


%% first directory analysis
list=dir(strcat(dir1Name,'*/*mrc')); 
mrcStats = {};
for i = 1:length(list)
    mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name));
    fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name));
    
    inside = mrc.Value.*maskVal;
    outside = mrc.Value.*maskValInv;
    outside = outside(50:206,50:206,50:206);
    mrcStats(i).inside=inside;
    mrcStats(i).outside=outside;
    mrcStats(i).insidemean = mean2(mrcStats(i).inside(~isnan(mrcStats(i).inside)));
    mrcStats(i).insidestd = std2(mrcStats(i).inside(~isnan(mrcStats(i).inside)));
    mrcStats(i).outsidemean = mean2(mrcStats(i).outside(~isnan(mrcStats(i).outside)));
    mrcStats(i).outsidestd = std2(mrcStats(i).outside(~isnan(mrcStats(i).outside)));
%     subplot(2,4,i-40)
%     histogram(inside(~isnan(inside)), 100)
%     xlim([-100,100])
%     title(strcat('Subtomo', num2str(i), ' - inside mask'))
%     xlabel('voxel intensity')
%     ylabel('voxel count')
%     set(gca,'FontSize',16)
%     
%     subplot(2,4,i+4-40)
%     histogram(outside(~isnan(outside)),100)
%     xlim([-100,100])
%     title(strcat('Subtomo', num2str(i), ' - outisde mask'))
%      xlabel('voxel intensity')
%     ylabel('voxel count')
%     set(gca,'FontSize',16)
end
%figure(1)
%boxplot(mrcStats().insidemean)

%figure(2)
%boxplot(outside)