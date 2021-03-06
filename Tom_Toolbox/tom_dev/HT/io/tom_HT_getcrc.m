function crc = tom_HT_getcrc(em_file)

if ~tom_isemfile(em_file)
    error('This is not an em file');
end

%get crc from em file
[path,name] = fileparts(em_file);
if ~isempty(path)
    crcname = [path '/' name '.crc'];
else
    crcname = [name '.crc'];
end

fid = fopen(crcname,'rt');

crc = fscanf(fid,'%d',1);

fclose(fid);