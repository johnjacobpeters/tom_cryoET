function success = tom_spider_proj(workdir, modelfile, refanglesfile,projstackfile)

fid = fopen([workdir '/create_projections.bat'],'wt');
h = tom_readspiderheader(modelfile);

x = importdata(refanglesfile);

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');
fprintf(fid,'MD\nSET MP\n0\n\n');

fprintf(fid,'PJ 3Q\n');
fprintf(fid,[modelfile '\n']);
fprintf(fid,[num2str(h.Header.Size(1)) '\n']);
fprintf(fid,['(1-' num2str(size(x.data,1)) ')\n']);
fprintf(fid,[refanglesfile '\n']);
fprintf(fid,[projstackfile '@*****\n\n']);
fprintf(fid,'en\n');

fclose(fid);


[s,w] = unix(['cd ' workdir ' ; /usr/local/apps/spider/bin/spider bat/spi @create_projections']);
if findstr(w,'**** SPIDER NORMAL STOP ****')
    success = 1;
else 
    success = 0;
    disp('***************************************************');
    disp('***************************************************');
    disp('ERROR:');
    disp('***************************************************');
    disp('***************************************************');
    disp(w);
    error('Aborted due to spider error');
end