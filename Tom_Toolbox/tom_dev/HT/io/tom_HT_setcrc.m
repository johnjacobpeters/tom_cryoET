function tom_HT_setcrc(em_file)


pathcrc = fileparts(which('tom_HT_setcrc'));
    
if ~tom_isemfile(em_file)
    error('This is not an em file');
end

%get crc from em file
if strcmp(computer,'PCWIN')
    [s,w] = system([pathcrc '\cksum.exe ' em_file]);
else
    [s,w] = unix(['cksum ' em_file]);
end
   
if s == 0
   checksum = str2double(strtok(w));
else
    error('Could not checksum file');
end

%write crc file
[path,name] = fileparts(em_file);
if ~isempty(path)
    crcname = [path '/' name '.crc'];
else
    crcname = [name '.crc'];
end

fid = fopen(crcname,'wt');

fprintf(fid,'%d',checksum);

fclose(fid);