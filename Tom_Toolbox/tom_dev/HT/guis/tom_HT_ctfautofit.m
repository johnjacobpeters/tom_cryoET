function varargout = tom_HT_ctfautofit(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_ctfautofit_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_ctfautofit_OutputFcn, ...
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
function tom_HT_ctfautofit_OpeningFcn(hObject, eventdata, handles, varargin)


handles.svmStruct = [];
handles.output = hObject;

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------------
function varargout = tom_HT_ctfautofit_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% -------------------------------------------------------------------------
% button load svm training set
% -------------------------------------------------------------------------
function button_svmload_Callback(hObject, eventdata, handles)

[FileName,PathName] = uigetfile({'*.mat'},'Select file to open');

if FileName == 0
    return;
end
s = load([PathName '/' FileName]);
handles.svmStruct = s.svmStruct;

set(handles.text_svmstatus,'String','training set loaded','ForegroundColor',[0 1 0]);
set(handles.checkbox_svmenable,'Enable','on','Value',1);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button create svm training set
% -------------------------------------------------------------------------
function button_svmtrain_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button browse
% -------------------------------------------------------------------------
function button_browse_Callback(hObject, eventdata, handles)

PathName = uigetdir('Select directory to open');

if PathName == 0
    return;
end

set(handles.edit_directory,'String',PathName);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button start autofitting
% -------------------------------------------------------------------------
function button_start_Callback(hObject, eventdata, handles)

directory = get(handles.edit_directory,'String');
min_freq = str2double(get(handles.edit_minfreq,'String'));
max_freq = str2double(get(handles.edit_maxfreq,'String'));
enhance_min = str2double(get(handles.edit_enhancemin,'String'));
enhance_max = str2double(get(handles.edit_enhancemax,'String'));
enhance_weight = str2double(get(handles.edit_enhanceweight,'String'));
psdsize = str2double(get(handles.edit_psdsize,'String'));
innermask = str2double(get(handles.edit_innermask,'String'));
outermask = str2double(get(handles.edit_outermask,'String'));

set(handles.text_fitstatus,'String','running','ForegroundColor',[0 1 0]);
if get(handles.checkbox_svmenable,'Value') == 1
    tom_HT_autoprocess_ctf(directory,min_freq,max_freq,enhance_min,enhance_max,enhance_weight,psdsize,innermask,outermask,handles.svmStruct,handles);
else
    tom_HT_autoprocess_ctf(directory,min_freq,max_freq,enhance_min,enhance_max,enhance_weight,psdsize,innermask,outermask,[],handles);
end

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button stop autofitting
% -------------------------------------------------------------------------
function button_stop_Callback(hObject, eventdata, handles)

set(handles.text_fitstatus,'String','stopping...','ForegroundColor',[1 1 0]);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Unused Callbacks / Create functions
% -------------------------------------------------------------------------
function listbox_messages_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_directory_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_psdsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_enhanceweight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_enhancemax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_enhancemin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_maxfreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_minfreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function listbox_messages_Callback(hObject, eventdata, handles)
function edit_minfreq_Callback(hObject, eventdata, handles)
function edit_maxfreq_Callback(hObject, eventdata, handles)
function edit_enhancemin_Callback(hObject, eventdata, handles)
function edit_enhancemax_Callback(hObject, eventdata, handles)
function edit_enhanceweight_Callback(hObject, eventdata, handles)
function edit_psdsize_Callback(hObject, eventdata, handles)
function edit_directory_Callback(hObject, eventdata, handles)
function checkbox_svmenable_Callback(hObject, eventdata, handles)
function edit_innermask_Callback(hObject, eventdata, handles)
function edit_innermask_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_outermask_Callback(hObject, eventdata, handles)
function edit_outermask_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


