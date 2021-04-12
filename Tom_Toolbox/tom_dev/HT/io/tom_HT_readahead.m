function tom_HT_readahead(files)



%con=pnet('tcpconnect','localhost',9999);
con = tcpip('localhost',21332);

if con == -1
    return;
end
fopen(con);

for i=1:length(files)
    %pnet(con,'printf', 'readf\t%s\n',files{i});
    fwrite(con,sprintf('readf\t%s\n',files{i}));
end
%pnet(con,'close');
fclose(con);