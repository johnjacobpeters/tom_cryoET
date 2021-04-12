function varargout = tom_HT_micrographgroups(varargin)



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_micrographgroups_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_micrographgroups_OutputFcn, ...
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


% -------------------------------------------------------------------------
% Opening function
% -------------------------------------------------------------------------
function tom_HT_micrographgroups_OpeningFcn(hObject, eventdata, handles, varargin)

if nargin == 4
    handles.projectstruct = varargin{1};
else
    error('This GUI must be called from tom_HT_main.');
end

set(handles.tabpanel_Insert_date,'String',date);

result = fetch(handles.projectstruct.conn,'SELECT name FROM microscopes');
if ~isempty(result)
    set(handles.tabpanel_Insert_microscope,'String',result.name);
else
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('No microscopes defined. Define a microscope first.','Error','custom',icon,colormap,'modal');
    error('No microscopes defined. Define a microscope first.');
end


result = fetch(handles.projectstruct.conn,'SELECT name FROM mtfs');
if ~isempty(result)
    idx = size(result.name,1)+1;
    result.name{idx} = 'NULL';
    set(handles.tabpanel_Insert_mtf,'String',result.name);
else
    set(handles.tabpanel_Insert_mtf,'String','NULL');
end


handles = get_names(handles);

handles.output = hObject;
guidata(hObject, handles);


% -------------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------------
function varargout = tom_HT_micrographgroups_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% -------------------------------------------------------------------------
% Close figure
% -------------------------------------------------------------------------
function button_close_Callback(hObject, eventdata, handles)

close(handles.micrographgroups);

% -------------------------------------------------------------------------
% Insert / Set Date
% -------------------------------------------------------------------------
function tabpanel_Insert_setdate_Callback(hObject, eventdata, handles)

date = get(handles.tabpanel_Insert_date,'String');
if isempty(date)
    date = datevec(uigetdate());
else
    date = datevec(uigetdate(date));
end
date(4:6) = 0;
date = datestr(date);
set(handles.tabpanel_Insert_date,'String',date);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Insert / Save
% -------------------------------------------------------------------------
function tabpanel_Insert_save_Callback(hObject, eventdata, handles)

name = get(handles.tabpanel_Insert_name,'String');
description = tom_HT_serialize_string(get(handles.tabpanel_Insert_description,'String'));
date = get(handles.tabpanel_Insert_date,'String');

contents = get(handles.tabpanel_Insert_microscope,'String');
microscope = contents{get(handles.tabpanel_Insert_microscope,'Value')};
result = fetch(handles.projectstruct.conn,['SELECT microscope_id FROM microscopes WHERE name = ''' microscope ''''],1);
microscope = result.microscope_id;

contents = get(handles.tabpanel_Insert_mtf,'String');
mtf = contents{get(handles.tabpanel_Insert_mtf,'Value')};
if strcmp(mtf,'NULL') == 0
    result = fetch(handles.projectstruct.conn,['SELECT mtf_id FROM mtfs WHERE name = ''' mtf ''''],1);
    mtf = result.mtf_id;
else
    mtf = NaN;
end

if isempty(name)
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('Enter project name.','Error','custom',icon,colormap,'modal');
    guidata(hObject, handles);
    return;
end


result = exec(handles.projectstruct.conn,['SELECT micrographgroup_id FROM micrograph_groups WHERE name = ''' name '''']);
result = fetch(result, 1);
if rows(result) > 0
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('The name does already exist.','Error','custom',icon,colormap,'modal');
    guidata(hObject, handles);
    return;
end

fastinsert(handles.projectstruct.conn, 'micrograph_groups', {'microscopes_microscope_id','mtfs_mtf_id','name','description','date'}, {microscope,mtf,name,description,date});
result = exec(handles.projectstruct.conn,'SELECT LAST_INSERT_ID() AS lastid');
lastid = fetch(result);
fastinsert(handles.projectstruct.conn,'micrograph_groups_has_projects',{'micrograph_groups_micrographgroup_id','projects_project_id'}, {lastid.Data.lastid,handles.projectstruct.projectid});

tom_HT_createimageseriesdir(handles.projectstruct.projectname,name);

[icon,colormap] = tom_HT_geticon('ok',64);
msgbox('Group created.','Success','custom',icon,colormap,'modal');

set(handles.tabpanel_Insert_name,'String','');
set(handles.tabpanel_Insert_description,'String','');
set(handles.tabpanel_Insert_date,'String',date);

handles = get_names(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Delete / Delete
% -------------------------------------------------------------------------
function tabpanel_Delete_delete_Callback(hObject, eventdata, handles)

contents = get(handles.tabpanel_Delete_selectiondelete,'String');
name = contents{get(handles.tabpanel_Delete_selectiondelete,'Value')};

exec(handles.projectstruct.conn,['DELETE FROM micrograph_groups WHERE name = ''' name '''']);

[icon,colormap] = tom_HT_geticon('ok',64);
msgbox('Group deleted.','Success','custom',icon,colormap,'modal');

handles = get_names(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Delete / Selection box 
% -------------------------------------------------------------------------
function tabpanel_Delete_selectiondelete_Callback(hObject, eventdata, handles)

contents = get(hObject,'String');
name = contents{get(hObject,'Value')};
handles = show_data(handles,name);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% View / View Table
% -------------------------------------------------------------------------
function tabpanel_View_displaytable_Callback(hObject, eventdata, handles)

setdbprefs('DataReturnFormat','cellarray');
result = fetch(handles.projectstruct.conn,'SELECT micrograph_groups.*, microscopes.name FROM micrograph_groups, microscopes WHERE micrograph_groups.microscopes_microscope_id = microscopes.microscope_id');
setdbprefs('DataReturnFormat','structure');

result_header = {'micrographgroup_id','microscope_id','mtf_id','name','description','date','microscope'};
figure;
createTable(gcf,result_header,result,0,'Editable',false);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% get names of rows in database table
% -------------------------------------------------------------------------
function handles = get_names(handles)

result = fetch(handles.projectstruct.conn,'SELECT name FROM micrograph_groups');
if ~isempty(result)
    set(handles.tabpanel_Delete_selectiondelete,'String',result.name);
else
    set(handles.tabpanel_Delete_selectiondelete,'String','---no groups defined---');
end


% -------------------------------------------------------------------------
% show project details in textbox
% -------------------------------------------------------------------------
function handles = show_data(handles,name)

result = fetch(handles.projectstruct.conn,['SELECT description,date FROM micrograph_groups WHERE name = ''' name '''']);
if ~isempty(result)
    string = tom_HT_unserialize_string(result.description{1});
    idx = size(string,1)+1;
    string{idx} = result.date{1};
else
    string = '';
end

set(handles.tabpanel_Delete_deletetext,'String',string);


% -------------------------------------------------------------------------
% Create Functions
% -------------------------------------------------------------------------
function tabpanel_Insert_microscope_Callback(hObject, eventdata, handles)
function tabpanel_Insert_mtf_Callback(hObject, eventdata, handles)
function tabpanel_Insert_name_Callback(hObject, eventdata, handles)
function tabpanel_Insert_date_Callback(hObject, eventdata, handles)
function tabpanel_Insert_description_Callback(hObject, eventdata, handles)
function tabpanel_Delete_selectiondelete_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_date_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_description_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_microscope_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_mtf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



