function varargout = tom_HT_feidebug(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_feidebug_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_feidebug_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function tom_HT_feidebug_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for tom_HT_feidebug
handles.output = hObject;

set(gcf,'CurrentAxes',handles.axes_em);
axis off;


set(gcf,'CurrentAxes',handles.axes_left);
axis off;

set(gcf,'CurrentAxes',handles.axes_right);
axis off;


% Update handles structure
guidata(hObject, handles);



function varargout = tom_HT_feidebug_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% -------------------------------------------------------------------------
% button sigma
% -------------------------------------------------------------------------
function edit_sigma_Callback(hObject, eventdata, handles)


% -------------------------------------------------------------------------
% button select outliers
% -------------------------------------------------------------------------
function button_outliers_Callback(hObject, eventdata, handles)

sigma = str2double(get(handles.edit_sigma,'String'));
st = std(handles.vect);
me = mean(handles.vect);

vect2 = handles.vect - me;
idx = find(abs(vect2)> sigma*st); 

set(handles.listbox_outliers,'String',num2cell(idx))

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit input dir
% -------------------------------------------------------------------------
function edit_inputdir_Callback(hObject, eventdata, handles)


handles = helper_loaddir(handles);
guidata(hObject, handles);


% -------------------------------------------------------------------------
% button browse
% -------------------------------------------------------------------------
function button_browse_Callback(hObject, eventdata, handles)

PathName = uigetdir('Select a directory to open');

if PathName == 0
    return;
end

set(handles.edit_inputdir,'String',PathName);

handles = helper_loaddir(handles);
guidata(hObject, handles);


% -------------------------------------------------------------------------
% button reload
% -------------------------------------------------------------------------
function button_reload_Callback(hObject, eventdata, handles)

handles = helper_loaddir(handles);
guidata(hObject, handles);


% -------------------------------------------------------------------------
% listbox outliers
% -------------------------------------------------------------------------
function listbox_outliers_Callback(hObject, eventdata, handles)


contents = get(hObject,'String'); 
idx = contents{get(hObject,'Value')};
handles = helper_show_outlier(handles,str2double(idx));


guidata(hObject, handles);


% -------------------------------------------------------------------------
% button show left
% -------------------------------------------------------------------------
function button_showleft_Callback(hObject, eventdata, handles)

[xx,name] = fileparts(handles.dircell{handles.idx});
im = imread([get(handles.edit_inputdir,'String') '/db_scrt/' name '_left.png']);

imtool(im);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button show right
% -------------------------------------------------------------------------
function button_showright_Callback(hObject, eventdata, handles)

[xx,name] = fileparts(handles.dircell{handles.idx});
im = imread([get(handles.edit_inputdir,'String') '/db_scrt/' name '_right.png']);

imtool(im);


guidata(hObject, handles);


% -------------------------------------------------------------------------
% button show em
% -------------------------------------------------------------------------
function button_showem_Callback(hObject, eventdata, handles)

em = tom_HT_fileread([get(handles.edit_inputdir,'String') '/high/' handles.dircell{handles.idx}]);

imtool(em.Value);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit filter list
% -------------------------------------------------------------------------
function edit_filter_Callback(hObject, eventdata, handles)

limit = str2double(get(hObject,'String'));
string = get(handles.listbox_logfile,'String');

string_out = {};
j=1;
for i=1:size(string,1)
    num = strtok(string(i,:));
    num = num{:};
    num = str2double(num(2:end-1));
    if num < limit+1 && num > 0
        string_out{j} = strtrim(string{i});
        j=j+1;
    end
end

set(handles.listbox_logfile,'String',string_out);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button save 
% -------------------------------------------------------------------------
function button_save_Callback(hObject, eventdata, handles)

string = get(handles.listbox_logfile,'String');

[FileName,PathName] = uiputfile({'*.txt'},'Select a filename');

if FileName == 0
    return;
end

fid = fopen([PathName,FileName],'wt');
for i=1:size(string,1)
    fwrite(fid,string{i});
    fprintf(fid,'\n');
end

fclose(fid);

edit([PathName,FileName]);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button previous
% -------------------------------------------------------------------------
function button_prev_Callback(hObject, eventdata, handles)

handles = helper_show_outlier(handles,handles.idx-1);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button next
% -------------------------------------------------------------------------
function button_next_Callback(hObject, eventdata, handles)

handles = helper_show_outlier(handles,handles.idx+1);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% listbox stats
% -------------------------------------------------------------------------
function listbox_stats_Callback(hObject, eventdata, handles)


handles = helper_plotstats(handles);


guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit stats threshold
% -------------------------------------------------------------------------
function edit_threshold_Callback(hObject, eventdata, handles)


st = abs(handles.st.diff);

idx = find(st > str2double(get(hObject,'String')));

set(handles.listbox_stats,'Value',idx);
handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit time window
% -------------------------------------------------------------------------
function edit_timewindow_Callback(hObject, eventdata, handles)

handles = helper_getstats(handles);
handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox show normed
% -------------------------------------------------------------------------
function checkbox_shownormed_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit time window
% -------------------------------------------------------------------------
function checkbox_smoothed_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit time window
% -------------------------------------------------------------------------
function checkbox_trend_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit smooth
% -------------------------------------------------------------------------
function edit_smooth_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox eliminate outliers
% -------------------------------------------------------------------------
function checkbox_outliers_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit number of iterations
% -------------------------------------------------------------------------
function edit_iterations_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox legend
% -------------------------------------------------------------------------
function checkbox_legend_Callback(hObject, eventdata, handles)


handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% edit std
% -------------------------------------------------------------------------
function edit_std_Callback(hObject, eventdata, handles)

handles = helper_plotstats(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button filter stats
% -------------------------------------------------------------------------
function button_filter_Callback(hObject, eventdata, handles)

string = get(handles.edit_filter_stats,'String');
val = get(handles.listbox_stats,'Value');
st = handles.st.titles;
st = st(val+1);
idx = strfind(st,string);

idx = cellfun(@isempty, idx);
if get(handles.checkbox_filter_invert,'Value') == 0
    idx = ~idx;
end

set(handles.listbox_stats,'Value',val(idx>0));

handles = helper_plotstats(handles);
    
guidata(hObject, handles);


% -------------------------------------------------------------------------
% helper: load directory
% -------------------------------------------------------------------------
function handles = helper_loaddir(handles)

handles.dircell = tom_HT_getdircontents([get(handles.edit_inputdir,'String') '/high'],{'em'},true);
handles = helper_calc_stats(handles);


% -------------------------------------------------------------------------
% helper: calc statistics
% -------------------------------------------------------------------------
function handles = helper_calc_stats(handles)

if isempty(handles.dircell)
    return;
end

filename = [get(handles.edit_inputdir,'String') '/db_scrt/'];
for i=1:length(handles.dircell)
    [xx,name] = fileparts(handles.dircell{i});
    im = imread([filename name '_left.png']);
    im = sum(im,3);
    if i == 1
        meanimg = im;
    else
        meanimg = meanimg + im;
    end
end
meanimg = meanimg ./ i;

vect = zeros([length(handles.dircell),1],'single');
    
if get(handles.radiobutton_mean,'Value') == 1
    
    
    for i=1:length(handles.dircell)
        [xx,name] = fileparts(handles.dircell{i});
        im = imread([filename name '_left.png']);
        im = sum(im,3);
        tmp = meanimg - im;
        vect(i) = sum(sum(tmp));
    end

else
    for i=1:length(handles.dircell)
        [xx,name] = fileparts(handles.dircell{i});
        im = imread([filename name '_left.png']);
        im = sum(im,3);
        tmp = meanimg - im;
        vect(i) = sum(sum(tmp));
    end
end

set(gcf,'CurrentAxes',handles.axes_histo);
[handles.n handles.xout] = hist(vect,20);
bar(handles.xout,handles.n);
handles.vect = vect;



% -------------------------------------------------------------------------
% helper: show outliers
% -------------------------------------------------------------------------
function handles = helper_show_outlier(handles,idx)

set(handles.listbox_logfile,'Value',1)
set(handles.listbox_unique,'Value',1)

em = tom_HT_fileread([get(handles.edit_inputdir,'String') '/high/' handles.dircell{idx}],'thumbnail',400);

set(gcf,'CurrentAxes',handles.axes_em);
tom_imagesc(em.Value);

set(gcf,'CurrentAxes',handles.axes_left);
[xx,name] = fileparts(handles.dircell{idx});
im = imread([get(handles.edit_inputdir,'String') '/db_scrt/' name '_left.png']);
imagesc(im);

set(gcf,'CurrentAxes',handles.axes_right);
im = imread([get(handles.edit_inputdir,'String') '/db_scrt/' name '_right.png']);
imagesc(im);

d = strtok(char(em.Header.Comment'),';');
set(handles.text_date,'String',d);
d = datenum(d);
handles.d = d;
d2 = datestr(d,14);

xxx = datestr(d,'mm-dd-yyyy');

test = datestr(d,'mm');
if str2double(test(1)) == 0
    xxx = xxx(2:end);
end

test = datestr(d,'dd');
if str2double(test(1)) == 0
    xxx2 = xxx(1:3);
    xxx = [xxx2 xxx(5:end)];
end


[m2,s2] = unix(['cat fei_db-' xxx '.txt | dos2unix | sed -n ''s/^[0-9]\{8\}' char(9) '[0-9: APM]*' char(9) '\[[0-9]*\] \(.*\)$/\1/p'' | sed ''s/^[0-9]\{1,2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9]\{3\} \(.*\)$/\1/'' | sort | uniq -c | sort -n']);

i=1;
ss2 = '';
remain = s2;
while true
   [str, remain] = strtok(remain, 10);
   if isempty(str),  break;  end
   ss2{i} = sprintf('%s', str);
   i=i+1;
end

    
[m,s] = unix(['grep ''' char(9) '' strtrim(d2(1:6)) ''' -C ' get(handles.edit_lines,'String') ' fei_db-' xxx '.txt']);


s = strrep(s, 13, '');
s = strrep(s, 09,' ');
remain = s;

i=1;
ss = '';
while true
   [str, remain] = strtok(remain, 10);
   if isempty(str),  break;  end
   ss{i} = sprintf('%s', str);
   i=i+1;
end

numcount = 0;
numcount2 =0;
numcount3 = 0;
liness = {};
j2=1;
for j=1:size(ss,2)
    errflag = 1;
    for i=1:size(ss2,2)
        [num,search] = strtok(ss2{i});
        if isempty(findstr(ss{j},strtrim(search))) == 0
            ss{j} = ['(' num ') ' ss{j}];
            errflag = 0;
            numcount(j) = str2double(num);
            if ~isempty(search)
                x = findstr(s,search);
                numcount3(j2) = length(x);
                liness{j2} = ['(' num2str(numcount3(j2)) ' of ' num ') ' search]; 
                numcount2(j2) = str2double(num);
                j2=j2+1;
                
            end
        end
    end
    if errflag ==1
        ss{j} = ['(0) ' ss{j}];
    end
end

set(handles.listbox_logfile,'String',ss);



set(gcf,'CurrentAxes',handles.axes_histo2);


[liness,index] = unique(liness);
bar(unique(numcount));
[xx,indx] = sort(numcount2(index));
set(handles.listbox_unique,'String',liness(indx));


handles.idx = idx;

set(gcf,'CurrentAxes',handles.axes_em);
axis off;


set(gcf,'CurrentAxes',handles.axes_left);
axis off;

set(gcf,'CurrentAxes',handles.axes_right);
axis off;


handles = helper_getstats(handles);

handles.idx = idx;


% -------------------------------------------------------------------------
% helper: get stats
% -------------------------------------------------------------------------
function handles = helper_getstats(handles)

x = dir('*.tsv');

f_st.method = 'time_frame';
f_st.time = datestr(handles.d,'mm/dd/yyyy HH:MM:SS');
f_st.time_frame = str2double(get(handles.edit_timewindow,'String'));

st = tom_HT_feidebug_perfmon_read2([get(handles.edit_inputdir,'String') '/' x(1).name],f_st);
st = tom_HT_feidebug_calc_diff(st,50,[2 20 0]);

s = {};
for i=2:size(st.data,2)+1
    s{i-1} = [strrep(st.titles{i},'\\TITAN52331100\','') '(' num2str(st.error_per_column(i)) ') (' num2str(st.diff(i-1)) ')'];
end

set(gcf,'CurrentAxes',handles.axes_diff_histo);
hist(abs(st.diff),15);

set(handles.listbox_stats,'String',s);
handles.st = st;


% -------------------------------------------------------------------------
% helper: plot stats
% -------------------------------------------------------------------------
function handles = helper_plotstats(handles)

selected = get(handles.listbox_stats,'Value');


set(gcf,'CurrentAxes',handles.axes_stats);
cla;
a = [0 1 0;1 0 0;0 0 1;1 1 0;0 1 1;.5 0 0;0 .5 0;0 0 .5; .5 .5 0; 0 0.5 .5;.25 0 0;0 .25 0; 0 0 .25; .25 .25 0; 0 .25 .25;0 1 0;1 0 0;0 0 1;1 1 0;0 1 1;.5 0 0;0 .5 0;0 0 .5; .5 .5 0; 0 0.5 .5;.25 0 0;0 .25 0; 0 0 .25; .25 .25 0; 0 .25 .25;0 1 0;1 0 0;0 0 1;1 1 0;0 1 1;.5 0 0;0 .5 0;0 0 .5; .5 .5 0; 0 0.5 .5;.25 0 0;0 .25 0; 0 0 .25; .25 .25 0; 0 .25 .25;0 1 0;1 0 0;0 0 1;1 1 0;0 1 1;.5 0 0;0 .5 0;0 0 .5; .5 .5 0; 0 0.5 .5;.25 0 0;0 .25 0; 0 0 .25; .25 .25 0; 0 .25 .25;0 1 0;1 0 0;0 0 1;1 1 0;0 1 1;.5 0 0;0 .5 0;0 0 .5; .5 .5 0; 0 0.5 .5;.25 0 0;0 .25 0; 0 0 .25; .25 .25 0; 0 .25 .25;0 1 0;1 0 0;0 0 1;1 1 0;0 1 1;.5 0 0;0 .5 0;0 0 .5; .5 .5 0; 0 0.5 .5;.25 0 0;0 .25 0; 0 0 .25; .25 .25 0; 0 .25 .25];
hold on;
for i=1:length(selected)

    dat = handles.st.data(:,selected(i));
    if get(handles.checkbox_shownormed,'Value') == 1
        dat = tom_norm(dat,'mean0+1std');
    end

    if get(handles.checkbox_outliers,'Value') == 1
        dat = tom_eliminate_outlayers(dat,str2double(get(handles.edit_std,'String')),str2double(get(handles.edit_iterations,'String')),1);
    end

    
    if get(handles.checkbox_smoothed,'Value') == 1
        dat = smooth(dat,str2double(get(handles.edit_smooth,'String')));
    end


    plot(gca,dat,'Color',a(i,:));
end

axis tight;
legend(handles.st.titles{selected+1});
if get(handles.checkbox_legend,'Value') == 1 
    legend('show');
else
    legend('hide');
end


s = {};
t = [];
j = 1;
for i=1:size(handles.st.data,1);
    if mod(i,floor(size(handles.st.data,1)./10)) == 0
       s{j} = handles.st.dates{i}(11:end-4);
       t(j) = i;
       j = j + 1;
    end
end
set(gca,'XTickLabel',s,'XTick',t);



% -------------------------------------------------------------------------
% create functions
% -------------------------------------------------------------------------
function edit_inputdir_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_outliers_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_sigma_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_logfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_logfile_Callback(hObject, eventdata, handles)
function edit_lines_Callback(hObject, eventdata, handles)
function edit_lines_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_repeats_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_unique_Callback(hObject, eventdata, handles)
function listbox_unique_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_filter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_stats_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_timewindow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_smooth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_iterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_std_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_filter_stats_Callback(hObject, eventdata, handles)
function edit_filter_stats_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox_filter_invert_Callback(hObject, eventdata, handles)




