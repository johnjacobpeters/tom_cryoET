function st_out=tom_HT_feidebug_perfmon_read2(filename,filter_st,flag,replace_val)
%TOM_HT_FEIDEBUG_PERFMON_READ2 reads a microsoft perfmon file text file
%
%   st_out=tom_HT_feidebug_perfmnon_read2(filename,flag,replace_val)
%
%PARAMETERS
%
%  INPUT
%   filename            filename
%   filter_st           structure for reducin the lines (filter_st.metho=all)  
%   filter_st.method    'all' reads all Values       
%                       'time_frame' reads a certain time frame    
%   filter_st.time_frame time frame in Minutes       
%   filter_st.time       starting time
%
%
%
%   flag                flag for replacing non numeric Values ('nearest' or
%                       'replace_by')      
%   replace_val         Value to replace 
%   
%  
%  OUTPUT
%   st_out               structure containing the information of the
%                        perfmon file
%
%EXAMPLE
%  (1) t=tom_HT_feidebug_perfmon_read2('perfmon.txt_000003.tsv'); reads whole file and replaces non numeric Values by neareast neighbour 
%  (2) f_st.method='all'; t=tom_HT_feidebug_perfmon_read2('perfmon.txt_000003.tsv',f_st,'replace_by',-1); reads whole file and replaces non numeric Values by -1 
%  (3) f_st.method='time_frame'; f_st.time='29-Nov-2007 07:31:22'; fst.time_frame=60;  
%      t=tom_HT_feidebug_perfmon_read2('perfmon.txt_000003.tsv',f_st,'replace_by',-1); reads whole file and replaces non numeric Values by -1 
%
%REFERENCES
%
%SEE ALSO
%   tom_HT_feidebug
%
%   
%   fb 03/12/007
%
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


if nargin < 2
    filter_st.method='all';
end;

if nargin < 3
    flag='nearest';
end;
    
if nargin < 4
    replace_val=NaN;
end;

ss=importdata(filename);

if strcmp(filter_st.method,'all')
    lines_vect=1:size(ss,1);
end;

line=ss{1,:};
rest=line;
for i=1:1000
   [val rest]=strtok(rest,'"');
    titles{i}=val;
   [val rest]=strtok(rest,'"');
   if (isempty(rest))
        break;
   end;
end;

errorcount=0;
error_per_column=zeros(size(titles,2),1);


if (strcmp(filter_st.method,'all')==0)
    if (strcmp(filter_st.method,'time_frame'))
        filter_st.time_frame=round(filter_st.time_frame);
        tmp_dates=grep_dates(ss);
        min_date=tmp_dates(1);
        max_date=tmp_dates(length(tmp_dates)-1);
        start=datenum(filter_st.time)-(filter_st.time_frame.*6.9444e-04.*1);
        stop=datenum(filter_st.time)+(filter_st.time_frame.*6.9444e-04.*1);
        if (start < min_date)
            start=min_date;
        end;
        if (stop > max_date)
            stop=max_date;
        end;
        lines_vect=find(tmp_dates > start & tmp_dates < stop);
        disp('');
    end;
    
end;

countt=2;
for ii=2:size(ss,1)
    line=ss{ii,:};
    rest=line;
    
    if (isempty(find(lines_vect==ii))==0 )
        for i=1:1000
            [val rest]=strtok(rest,'"');
            if i==1
                st_out.dates{countt-1}=val;
            else
                if ~isnan(str2double(val))
                   st_out.data(countt-1,i-1)=str2num(val);
                else
                    if strcmp(flag,'nearest')==1
                        st_out.data(countt-1,i-1)=find_next_value(ss,ii,i);
                    end;
                    if strcmp(flag,'replace_by')==1
                        st_out.data(countt-1,i-1)=replace_val;
                    end;
                    errorcount=errorcount+1;
                    error_per_column(i-1)=error_per_column(i-1)+1;
                end;
            end;
            [val rest]=strtok(rest,'"');
            if (isempty(rest))
                break;
            end;
        end;
        countt=countt+1;
    end;

end;


st_out.titles=titles;
st_out.error_per_column=error_per_column';
st_out.total_error=errorcount;

if (st_out.total_error > 0)
    disp(['Warning: data ' num2str(errorcount) ' times not numeric!'] );
    disp('Replaced by nearest neighbour');
end;

disp('');


function val=find_next_value(data,ii,count)

disp('');

if ii > 2
    line=data{ii-1,:};
    rest=line;
    for i=1:1000
        [val rest]=strtok(rest,'"');
        [vall rest]=strtok(rest,'"');
        if (i==count)
            break;
        end;
    end;
     if ~isnan(str2double(val))
        val=str2num(val);
        return;
    end;
end;


if ii < size(data,1)-1
    line=data{ii+1,:};
    rest=line;
    for i=1:1000
        [val rest]=strtok(rest,'"');
        [vall rest]=strtok(rest,'"');
        if (i==count)
            break;
        end;
    end;
    if  ~isnan(str2double(val))
        val=str2num(val);
        return;
    end;
end;

val=0;


function tmp_dates=grep_dates(ss)

tmp_dates=ones(size(ss,1),1);

for ii=2:size(ss,1)
    line=ss{ii,:};
    rest=line;
    [val rest]=strtok(rest,'"');
    tmp_dates(ii-1)=datenum(val);
end;



