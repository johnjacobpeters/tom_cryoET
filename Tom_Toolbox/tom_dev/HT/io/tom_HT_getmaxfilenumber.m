function maxfilename = tom_HT_getmaxfilenumber(directory)

dirlist = dir(directory);
dirlist = dirlist(3:end);

numfiles = size(dirlist,1);

numarray = zeros(numfiles,1);
for i = 1:numfiles
    if dirlist(i).isdir == 0
        numarray(i) = str2double(strtok(dirlist(i).name,'.'));
    end
end

maxfilename = max(numarray);

if isempty(maxfilename) || isnan(maxfilename)
    maxfilename = 0;
end
