function varargout = tom_HT_mtfs(varargin)



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_mtfs_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_mtfs_OutputFcn, ...
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
function tom_HT_mtfs_OpeningFcn(hObject, eventdata, handles, varargin)

if nargin == 4
    handles.projectstruct = varargin{1};
else
    error('This GUI must be called from tom_HT_main.');
end

handles = get_names(handles);

handles.output = hObject;
guidata(hObject, handles);


% -------------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------------
function varargout = tom_HT_mtfs_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% -------------------------------------------------------------------------
% Close figure
% -------------------------------------------------------------------------
function button_close_Callback(hObject, eventdata, handles)

close(handles.mtfs);


% -------------------------------------------------------------------------
% Insert / Browse for mtf file
% -------------------------------------------------------------------------
function tabpanel_Insert_browse_Callback(hObject, eventdata, handles)

[FileName,PathName] = uigetfile('*.mat','Select the mtf file',pwd);

if ~isempty(FileName)
    set(handles.tabpanel_Insert_filename,'String',[PathName,FileName]);
end

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Insert / Save
% -------------------------------------------------------------------------
function tabpanel_Insert_save_Callback(hObject, eventdata, handles)

name = get(handles.tabpanel_Insert_name,'String');
description = tom_HT_serialize_string(get(handles.tabpanel_Insert_description,'String'));
filename = get(handles.tabpanel_Insert_filename,'String');

if isempty(name)
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('Enter MTF name.','Error','custom',icon,colormap,'modal');
    guidata(hObject, handles);
    return;
end

if isempty(filename)
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('Enter filename.','Error','custom',icon,colormap,'modal');
    guidata(hObject, handles);
    return;
end

if ~exist(filename,'file')
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('File does not exist or is not readable.','Error','custom',icon,colormap,'modal');
    guidata(hObject, handles);
    return;
end
    

result = exec(handles.projectstruct.conn,['SELECT mtf_id FROM mtfs WHERE name = ''' name ''' AND projects_project_id = ''' num2str(handles.projectstruct.projectid) '''']);
result = fetch(result, 1);
if rows(result) > 0
    [icon,colormap] = tom_HT_geticon('error',64);
    msgbox('The name does already exist.','Error','custom',icon,colormap,'modal');
    guidata(hObject, handles);
    return;
end

tom_HT_copyfile(filename,'mtf',handles.projectstruct.projectname,[name '.mat']);
filename = [name '.mat'];
fastinsert(handles.projectstruct.conn, 'mtfs', {'name','description','filename','projects_project_id'}, {name,description,filename,handles.projectstruct.projectid});

[icon,colormap] = tom_HT_geticon('ok',64);
msgbox('MTF created.','Success','custom',icon,colormap,'modal');

set(handles.tabpanel_Insert_name,'String','');
set(handles.tabpanel_Insert_description,'String','');
set(handles.tabpanel_Insert_filename,'String','');

handles = get_names(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Delete / Delete
% -------------------------------------------------------------------------
function tabpanel_Delete_delete_Callback(hObject, eventdata, handles)

contents = get(handles.tabpanel_Delete_selectiondelete,'String');
name = contents{get(handles.tabpanel_Delete_selectiondelete,'Value')};

exec(handles.projectstruct.conn,['DELETE FROM mtfs WHERE name = ''' name '''']);

[icon,colormap] = tom_HT_geticon('ok',64);
msgbox('MTF deleted.','Success','custom',icon,colormap,'modal');

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
result = fetch(handles.projectstruct.conn,['SELECT mtf_id,name,description,filename FROM mtfs WHERE projects_project_id = ''' num2str(handles.projectstruct.projectid) '''']);
setdbprefs('DataReturnFormat','structure');

result_header = {'mtf_id','name','description','filename'};
figure;
createTable(gcf,result_header,result,0,'Editable',false);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% get names of rows in database table
% -------------------------------------------------------------------------
function handles = get_names(handles)

result = fetch(handles.projectstruct.conn,'SELECT name FROM mtfs');
if ~isempty(result)
    set(handles.tabpanel_Delete_selectiondelete,'String',result.name);
else
    set(handles.tabpanel_Delete_selectiondelete,'String','---no mtf defined---');
end


% -------------------------------------------------------------------------
% show project details in textbox
% -------------------------------------------------------------------------
function handles = show_data(handles,name)

result = fetch(handles.projectstruct.conn,['SELECT description,filename FROM mtfs WHERE name = ''' name ''' AND projects_project_id = ''' num2str(handles.projectstruct.projectid) '''']);
if ~isempty(result)
    string = tom_HT_unserialize_string(result.description{1});
    idx = size(string,1)+1;
    string{idx} = ['filename: ' result.filename{1} ];
else
    string = '';
end

set(handles.tabpanel_Delete_deletetext,'String',string);


% -------------------------------------------------------------------------
% Create Functions
% -------------------------------------------------------------------------
function tabpanel_Insert_name_Callback(hObject, eventdata, handles)
function tabpanel_Insert_cs_Callback(hObject, eventdata, handles)
function tabpanel_Insert_voltage_Callback(hObject, eventdata, handles)
function tabpanel_Insert_description_Callback(hObject, eventdata, handles)
function tabpanel_Delete_selectiondelete_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_cs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tabpanel_Insert_voltage_CreateFcn(hObject, eventdata, handles)
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




