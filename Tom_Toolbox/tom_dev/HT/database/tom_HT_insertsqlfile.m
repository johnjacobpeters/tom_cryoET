function tom_ht_insertsqlfile(conn,filename)

fid = fopen(filename,'rt');
sqlstring = fread(fid,'char');
fclose(fid);

curs = exec(conn,char(sqlstring'));

if ~isempty(curs.Message)
    error(curs.Message);
end