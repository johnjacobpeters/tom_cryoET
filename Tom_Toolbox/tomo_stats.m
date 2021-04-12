dir1Name = '/Volumes/atbmac16/TOMO_PROJ/20190611_MPI/RELION/Tomograms/';


%dirName is the directory of your extraction job


%% first directory analysis
list=dir(strcat(dir1Name,'Tomo*')); 
mrcStats = [];
for i = 1:length(list)
    mrc = tom_mrcread(strcat(list(i).folder, '/', list(i).name, '/', list(i).name, '.mrc'));
    fprintf(1, 'Now analyzing %s\n', strcat(list(i).folder, '/', list(i).name, '/', list(i).name, '.mrc'));
    mrcStats(i).name = list(i).name;
    mrcStats(i).mean = mean2(mrc.Value);
    mrcStats(i).stddev = std2(mrc.Value);
end

%calculate stats for first dir
mrcAvg1 = vertcat(mrcStats.mean);
mrcStd1 = vertcat(mrcStats.stddev);


 
