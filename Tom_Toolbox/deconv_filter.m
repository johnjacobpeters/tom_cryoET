function [ decfil ] = deconv_filter(myDir, pixSize, defocus)

myFiles = dir(fullfile(myDir,'*.mrc'));

for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);

  fprintf(1, 'Now filtering %s\n', fullFileName);
  new_sub=tom_mrcread(fullFileName);
  subtomo_filt=tom_deconv_tomo(new_sub.Value,pixSize,defocus,1.2,.01);

  [folder, baseFileName, extension] = fileparts(fullFileName);
  newFileName=strcat(folder, '/', baseFileName, '_filt.mrc');
 
  fprintf(1, 'Now writing %s\n', newFileName);
  tom_mrcwrite(subtomo_filt,'name',newFileName,'style','classic')

end
end