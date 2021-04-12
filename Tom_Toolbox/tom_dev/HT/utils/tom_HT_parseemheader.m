function info = tom_HT_parseemheader(filename)

h = tom_reademheader(filename);


[datestring,pos] = strtok(char(h.Header.Comment), ';');
[pos,remain] = strtok(pos,';');
[xx,nominal] = strtok(remain,';');
[nominal,cluster] = strtok(nominal,'!');
nominal = nominal(2:end);
cluster = cluster(2:end);
[pos_x,remain] = strtok(pos,' ');
[pos_y,pos_z] = strtok(remain,' ');

fitted_def=h.Header.FocusIncrement;

info.pos(1)=str2double(pos_x);
info.pos(2)=str2double(pos_y);
info.pos(3)=str2double(pos_z);
info.mesured_def=str2double(nominal);
info.intended_def=h.Header.Defocus./10000;
info.fitted_def=fitted_def./10000;
info.cluster=str2double(cluster);
info.filename=filename;
info.objectpixelsize = h.Header.Objectpixelsize;

info.date = datestring;

if (h.Header.Marker_X==999)
    info.isinterp=1;
else
    info.isinterp=0;
end

if (fitted_def~=1)
    info.isfitted=1;
else
    info.isfitted=0;
end

if isempty(findstr(nominal,';'))==0
    info.mesured_def=-5;
    info.fitted_def=1;
    info.isfitted=0;
end

if isempty(info.mesured_def)
    info.isfitted=0;
    info.mesured_def=-5;
    info.fitted_def=1;
end

if (info.isinterp==1)
    info.isfitted=0;
    info.fitted_def=1;
end