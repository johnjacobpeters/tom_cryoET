function [  ] = deconv_filter_all(myDir, pixSize, defocus, snrratio)

% Parameters:
% myDir - directory containing folders with subtomograms
% pixSize - angstrom per pixel
% defocus - defocus in micrometers, positive = underfocus
%deconv_filter_all('Sherlock_jobs/Extract/job184/', 2.62, 4.5, 1.2, .01)

mySubDirs= dir(myDir);
for i= 1:length(mySubDirs)
    %if mySubDirs(i).name(1)=='T' 
    delete(fullfile(myDir, mySubDirs(i).name, '/*filt.mrc'));
        myFiles = dir(fullfile(myDir, mySubDirs(i).name,'*.mrc'));
         for k = 1:length(myFiles)
             baseFileName = myFiles(k).name;
             fullFileName = fullfile(myDir, mySubDirs(i).name, '/', baseFileName);
             fprintf(1, 'Now filtering %s\n', fullFileName);
             new_sub=tom_mrcread(fullFileName);
             subtomo_filt=tom_deconv_tomo_abs(new_sub.Value,pixSize,defocus,snrratio,.01);

             [folder, baseFileName, extension] = fileparts(fullFileName);
             newFileName=strcat(folder, '/', baseFileName, '_filt.mrc');
    
             fprintf(1, 'Now writing %s\n', newFileName);
             tom_mrcwrite(subtomo_filt,'name',newFileName,'style','classic')
         end   
    %end

end 


end