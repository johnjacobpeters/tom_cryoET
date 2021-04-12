function varargout = tom_HT_paint(varargin)
% TOM_HT_PAINT M-file for tom_HT_paint.fig
%      TOM_HT_PAINT, by itself, creates a new TOM_HT_PAINT or raises the existing
%      singleton*.
%
%      H = TOM_HT_PAINT returns the handle to a new TOM_HT_PAINT or the handle to
%      the existing singleton*.
%
%      TOM_HT_PAINT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOM_HT_PAINT.M with the given input arguments.
%
%      TOM_HT_PAINT('Property','Value',...) creates a new TOM_HT_PAINT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tom__HT_paint_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tom_HT_paint_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tom_HT_paint

% Last Modified by GUIDE v2.5 10-Jan-2008 11:38:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_paint_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_paint_OutputFcn, ...
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


% -------------------------------------------------------------------
% Opening function
% -------------------------------------------------------------------handle
function tom_HT_paint_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

handles.circlenum = 0;
handles.rectanglenum = 0;
handles.gaussiannum = 0;
handles.cosinenum = 0;

guidata(hObject, handles);


% -------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------
function varargout = tom_HT_paint_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
guidata(hObject, handles);


% -------------------------------------------------------------------
% Callback functions
% -------------------------------------------------------------------

% -------------------------------------------------------------------
% Load object button
% -------------------------------------------------------------------
function load_button_Callback(hObject, eventdata, handles)

[FileName,PathName] = uigetfile({'*.mat';'*.*'},'Pick an object');
fn=[ PathName FileName ];

guidata(hObject, handles);

% -------------------------------------------------------------------
% Save object button
% -------------------------------------------------------------------
function save_button_Callback(hObject, eventdata, handles)

[FileName,PathName] = uiputfile({'*.mat';'*.*'},'Save object as');
fn=[PathName FileName];
if ~isempty(fn)
    save(fn);
    %save(fn,handles.m);
    disp('Object saved');
end

% -------------------------------------------------------------------
% Generate button
% -------------------------------------------------------------------

function button_generate_Callback(hObject, eventdata, handles)


if (~isfield(handles, 'x_mask_param'))
    handles.m=tom_HT_mask(64,64);
    set(handles.pic,'XLimMode','manual','XLim',[0 64],'YLimMode','manual','YLim',[0 64],'XTickMode','auto','YTickMode','auto');
else
    handles.m=tom_HT_mask(handles.x_mask_param,handles.y_mask_param);
    set(handles.pic,'XLimMode','manual','XLim',[0 handles.x_mask_param],'YLimMode','manual','YLim',[0 handles.y_mask_param],'XTickMode','auto','YTickMode','auto');
end
guidata(hObject, handles);


% -------------------------------------------------------------------
% Mask size in x dimension
% -------------------------------------------------------------------
function x_edit_Callback(hObject, eventdata, handles)
handles.x_mask_param=str2num(get(handles.x_edit,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------
% Mask size in y dimension
% -------------------------------------------------------------------
function y_edit_Callback(hObject, eventdata, handles)
handles.y_mask_param=str2num(get(handles.y_edit,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------
% Button Circle
% -------------------------------------------------------------------
function togglebutton_circle_Callback(hObject, eventdata, handles)
handles.item='circle';

set(handles.edit_param1,'visible','on','String','33');
set(handles.text_param1,'visible','on','String','Center X');
set(handles.edit_param2,'visible','on','String','33');
set(handles.text_param2,'visible','on','String','Center Y');
set(handles.edit_param3,'visible','on','String','31');
set(handles.text_param3,'visible','on','String','Radius');
set(handles.edit_param4,'visible','on','String','1');
set(handles.text_param4,'visible','on','String','Sigma');
set(handles.togglebutton_rec,'Value',[0.0]);
set(handles.togglebutton_gaussian,'Value',[0.0]);
set(handles.togglebutton_raised_cosine,'Value',[0.0]);

guidata(hObject, handles);

% -------------------------------------------------------------------
% Button Rectangle
% -------------------------------------------------------------------
function togglebutton_rec_Callback(hObject, eventdata, handles)
handles.item='rectangle';

set(handles.edit_param1,'visible','on','String','2');
set(handles.text_param1,'visible','on','String','Leftupper X');
set(handles.edit_param2,'visible','on','String','3');
set(handles.text_param2,'visible','on','String','Leftupper Y');
set(handles.edit_param3,'visible','on','String','4');
set(handles.text_param3,'visible','on','String','Width');
set(handles.edit_param4,'visible','on','String','5');
set(handles.text_param4,'visible','on','String','Height');
set(handles.togglebutton_circle,'Value',[0.0]);
set(handles.togglebutton_gaussian,'Value',[0.0]);
set(handles.togglebutton_raised_cosine,'Value',[0.0]);

guidata(hObject, handles);

% -------------------------------------------------------------------
% Button Gaussian
% -------------------------------------------------------------------
function togglebutton_gaussian_Callback(hObject, eventdata, handles)
handles.item='gaussian';

set(handles.edit_param1,'visible','on','String','2');
set(handles.text_param1,'visible','on','String','Center X');
set(handles.edit_param2,'visible','on','String','2');
set(handles.text_param2,'visible','on','String','Center Y');
set(handles.edit_param3,'visible','on','String','2');
set(handles.text_param3,'visible','on','String','Sigma');
set(handles.edit_param4,'visible','off','String','');
set(handles.text_param4,'visible','off','String','');
set(handles.togglebutton_circle,'Value',[0.0]);
set(handles.togglebutton_rec,'Value',[0.0]);
set(handles.togglebutton_raised_cosine,'Value',[0.0]);

guidata(hObject, handles);

% -------------------------------------------------------------------
% Button Raised Cosine
% -------------------------------------------------------------------
function togglebutton_raised_cosine_Callback(hObject, eventdata, handles)
handles.item='raised_cosine';

set(handles.edit_param1,'visible','on','String','');
set(handles.text_param1,'visible','on','String','Center X');
set(handles.edit_param2,'visible','on','String','');
set(handles.text_param2,'visible','on','String','Center Y');
set(handles.edit_param3,'visible','on','String','');
set(handles.text_param3,'visible','on','String','R1');
set(handles.edit_param4,'visible','on','String','');
set(handles.text_param4,'visible','on','String','R2');
set(handles.togglebutton_circle,'Value',[0.0]);
set(handles.togglebutton_rec,'Value',[0.0]);
set(handles.togglebutton_gaussian,'Value',[0.0]);

guidata(hObject, handles);


% -------------------------------------------------------------------
% Edit Parameter 1
% -------------------------------------------------------------------
function edit_param1_Callback(hObject, eventdata, handles)
handles.param1=str2num(get(handles.edit_param1,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------
% Edit Parameter 2
% -------------------------------------------------------------------
function edit_param2_Callback(hObject, eventdata, handles)
handles.param2=str2num(get(handles.edit_param2,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------
% Edit Parameter 3
% -------------------------------------------------------------------
function edit_param3_Callback(hObject, eventdata, handles)
handles.param3=str2num(get(handles.edit_param3,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------
% Edit Parameter 4
% -------------------------------------------------------------------
function edit_param4_Callback(hObject, eventdata, handles)
handles.param4=str2num(get(handles.edit_param4,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------
% Edit Parameter 5
% -------------------------------------------------------------------
function edit_param5_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------
% OK Button
% -------------------------------------------------------------------
function button_ok_Callback(hObject, eventdata, handles)

handles.param1=str2num(get(handles.edit_param1,'String'));
handles.param2=str2num(get(handles.edit_param2,'String'));
handles.param3=str2num(get(handles.edit_param3,'String'));
handles.param4=str2num(get(handles.edit_param4,'String'));

handles.m=add_maskparams(handles.m,handles.item,handles.param1,handles.param2,handles.param3,handles.param4);

handles = helper_rendermask(handles);

string = get(handles.listbox_objects,'String');

idx = length(string)+1;

switch handles.item
    case 'circle'
        handles.circlenum = handles.circlenum + 1;
        string{idx} = ['Circle_' num2str(handles.circlenum)];
    case 'rectangle'
        handles.rectanglenum = handles.rectanglenum + 1;
        string{idx} = ['Rectangle_' num2str(handles.rectanglenum)];
    case 'gaussian'
        handles.gaussiannum = handles.gaussiannum + 1;
        string{idx} = ['Gaussian_' num2str(handles.gaussiannum)];
    case 'raised_cosine'
        handles.cosinenum = handles.cosinenum + 1;
        string{idx} = ['Raised Cosine_' num2str(handles.cosinenum)];
end

set(handles.listbox_objects,'String',string);

guidata(hObject, handles);

% -------------------------------------------------------------------
% Object listbox
% -------------------------------------------------------------------
function listbox_objects_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% -------------------------------------------------------------------
% Delete object button
% -------------------------------------------------------------------
function delete_button_Callback(hObject, eventdata, handles)

selected = get(handles.listbox_objects,'Value');
prev_str = get(handles.listbox_objects,'String');

handles.m = delete_maskparams(handles.m, selected);

handles = helper_rendermask(handles);

len=length(prev_str);

if len > 0
   idx = 1:len;
   new_str = prev_str(find(idx ~= selected),1);
   set(handles.listbox_objects, 'String', new_str, 'Value', 1);
end

guidata(hObject, handles);

% -------------------------------------------------------------------
% Modify object button
% -------------------------------------------------------------------
function modify_button_Callback(hObject, eventdata, handles)



guidata(hObject, handles);

% -------------------------------------------------------------------
% Button Exit
% -------------------------------------------------------------------
function pushbutton_exit_Callback(hObject, eventdata, handles)
close(handles.tom_HT_paint);



% -------------------------------------------------------------------
% Helper: Render mask
% -------------------------------------------------------------------
function handles = helper_rendermask(handles)

handles.m=constructmask(handles.m);

set(handles.tom_HT_paint,'Currentaxes',handles.pic);
set(handles.pic,'XTickMode','auto');
imagesc(get(handles.m,'mask'));axis xy;colormap gray;



% -------------------------------------------------------------------
% Create functions
% -------------------------------------------------------------------

function edit_param1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_param2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_param3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_param4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_param5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function listbox_objects_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function y_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

