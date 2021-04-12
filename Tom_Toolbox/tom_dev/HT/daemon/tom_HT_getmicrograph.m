function tom_HT_getmicrograph(source,destination)


[status,message] = copyfile(source,destination,'f');
if status ~= 1
    error(message);
end

[status,message] = fileattrib(destination,'+w','u g');
if status ~= 1
    error(message);
end

%get crc checksum of original file
%TODO

%get crc checksum of copied file
[s,w] = unix(['cksum ' destination]);
if s == 0
   checksum_dest = str2double(strtok(w));
else
    error('Could not checksum file');
end


