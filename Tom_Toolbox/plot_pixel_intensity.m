function [mrcAvg, mrcStd] =plot_pixel_intensity(dir1Name,dir2Name,dir3Name)%, dir4Name)

%dirName is the directory of your extraction job


% first directory analysis
list=dir(strcat(dir1Name,'*/*/*mrc')); 
mrcStats = [];
for i = 1:length(list)
    mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name));
    fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name));
    mrcStats(i).mean = mean2(mrc.Value);
    mrcStats(i).stddev = std2(mrc.Value);
end

%calculate stats for first dir
mrcAvg1 = vertcat(mrcStats.mean);
mrcStd1 = vertcat(mrcStats.stddev);

%% second directory analysis
list=dir(strcat(dir2Name,'*/*/*mrc')); 
mrcStats = [];
for i = 1:length(list)
    mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name));
    fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name));
    mrcStats(i).mean = mean2(mrc.Value);
    mrcStats(i).stddev = std2(mrc.Value);
end
%calculate stats for second dir
mrcAvg2 = vertcat(mrcStats.mean);
mrcStd2 = vertcat(mrcStats.stddev);

%% third directory analysis
list=dir(strcat(dir3Name,'*/*/*mrc')); 
mrcStats = [];
for i = 1:length(list)
    mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name));
    fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name));
    mrcStats(i).mean = mean2(mrc.Value);
    mrcStats(i).stddev = std2(mrc.Value);
end
%calculate stats for third dir
mrcAvg3 = vertcat(mrcStats.mean);
mrcStd3 = vertcat(mrcStats.stddev);

%% fourth directory analysis
%list=dir(strcat(dir4Name,'*/*mrc')); 
%mrcStats = [];
% for i = 1:length(list)
%     mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name));
%     fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name));
%     mrcStats(i).mean = mean2(mrc.Value);
%     mrcStats(i).stddev = std2(mrc.Value);
% end
%calculate stats for fourth dir
% mrcAvg4 = vertcat(mrcStats.mean);
% mrcStd4 = vertcat(mrcStats.stddev);

%% plot data
%Combine datsets
mrcAvg = [mrcAvg1;mrcAvg2;mrcAvg3];%;mrcAvg4];
mrcStd = [mrcStd1;mrcStd2;mrcStd3];%;mrcStd4];
group = [ones(size(mrcAvg1)); 2*ones(size(mrcAvg2)); 3*ones(size(mrcAvg3))];%; 4*ones(size(mrcAvg3))];
labels = {'Extract_256', 'Extract_cyl', 'Extract_disk'};%, '>1.5 std fil'};
%labels = {dir1Name, dir2Name};
%labels = {'Without normalization in extraction', 'With normalization in extraction', 'Noise without normalization', 'Noise with normalization'};

meanbp= figure;
boxplot(mrcAvg,group)
ylabel('mean pixel intensity of subtomograms')
title('Mean pixel intensity of non-normalized and normalized subtomograms')
set(gca,'XTickLabel',labels)
set(gca,'FontSize',16)

stdbp= figure;
boxplot(mrcStd,group)
ylabel('stddev of mean pixel intensity of subtomograms')
title('StdDev of mean pixel intensity of non-normalized and normalized subtomograms')
set(gca,'XTickLabel',labels)
set(gca,'FontSize',16)
 
