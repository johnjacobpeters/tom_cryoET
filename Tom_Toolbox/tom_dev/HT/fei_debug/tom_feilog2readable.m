function tom_feilog2readable(filename)

unix('touch logfile_readable.log');
i=1;


while 1

    unix(['cp ' filename ' ' filename '_copyfile']);

    
    fid = fopen([filename '_copyfile'],'rt');
    fid2 = fopen('logfile_readable.log','a+t');
    fseek(fid2,0,'eof');
    if i>1
        fid3 = fopen([filename '_copyfile_prev'],'rt');
        fseek(fid3,0,'eof');
        logpos = ftell(fid3);
        fclose(fid3);
    else
        logpos = 0;
        i=2;
    end
    
    fseek(fid,logpos-1,'bof');
    
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        idx = find(double(tline)~=0);
        if ~isempty(tline(idx))
            fprintf(fid2,'%s %s\n',datestr(now),tline(idx));
            s = sprintf('%s %s\n',datestr(now),tline(idx));
            disp(s);
        end
    end

    fclose(fid);
    fclose(fid2);

    unix(['cp ' filename '_copyfile ' filename '_copyfile_prev']);
    
    pause(1);
end

  