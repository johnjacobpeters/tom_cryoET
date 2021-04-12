function tom_HT_clearreadahead()

con=pnet('tcpconnect','localhost',9999);

if con == -1
    return;
end
pnet(con,'printf', 'clear\n');
pnet(con,'close');