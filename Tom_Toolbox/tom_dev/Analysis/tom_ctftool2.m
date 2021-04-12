function varargout = tom_ctftool2(varargin)
% TOM_CTFTOOL2 MATLAB code for tom_ctftool2.fig
%      TOM_CTFTOOL2, by itself, creates a new TOM_CTFTOOL2 or raises the existing
%      singleton*.
%
%      H = TOM_CTFTOOL2 returns the handle to a new TOM_CTFTOOL2 or the handle to
%      the existing singleton*.
%
%      TOM_CTFTOOL2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOM_CTFTOOL2.M with the given input arguments.
%
%      TOM_CTFTOOL2('Property','Value',...) creates a new TOM_CTFTOOL2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tom_ctftool2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tom_ctftool2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tom_ctftool2

% Last Modified by GUIDE v2.5 02-Jul-2015 16:02:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_ctftool2_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_ctftool2_OutputFcn, ...
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


% --- Executes just before tom_ctftool2 is made visible.
function tom_ctftool2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_ctftool2 (see VARARGIN)

% Choose default command line output for tom_ctftool2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tom_ctftool2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tom_ctftool2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function e_folderName_Callback(hObject, eventdata, handles)
% hObject    handle to e_folderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_folderName as text
%        str2double(get(hObject,'String')) returns contents of e_folderName as a double


% --- Executes during object creation, after setting all properties.
function e_folderName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_folderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in br_folder.
function br_folder_Callback(hObject, eventdata, handles)
% hObject    handle to br_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wk=get(handles.e_wildCard,'String');

[name,path]=uigetfile(wk);

set(handles.e_folderName,'String',[path]);
set(handles.e_fileName,'String',[name]);
handles=updateGui(handles);
guidata(hObject, handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1



function e_wildCard_Callback(hObject, eventdata, handles)
% hObject    handle to e_wildCard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_wildCard as text
%        str2double(get(hObject,'String')) returns contents of e_wildCard as a double


% --- Executes during object creation, after setting all properties.
function e_wildCard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_wildCard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_fileName_Callback(hObject, eventdata, handles)
% hObject    handle to e_fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_fileName as text
%        str2double(get(hObject,'String')) returns contents of e_fileName as a double


% --- Executes during object creation, after setting all properties.
function e_fileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





%Helper Function 

function handles=updateGui(handles)

filename=[get(handles.e_folderName,'String') filesep get(handles.e_fileName,'String')];
ft=tom_determine_file_type2(filename);
if (strcmp(ft,'em'))
    im=tom_emread(filename);
end;
if (strcmp(ft,'mrc'))
    im=tom_mrcread(filename);
end;



axes(handles.ax_OrgImage); tom_imagesc(tom_filter(im.Value,5));
psOrgCut=tom_cut_out(log(tom_ps(im.Value)+10),'center',[2048 2048]);
axes(handles.ax_OrgPS); tom_imagesc(tom_filter(psOrgCut,2));

axes(handles.ax_Periodogram); pp=tom_calc_periodogram(im.Value);
ps=(log(fftshift(pp)));
[decay decay_image]=calc_decay(ps,9,128,32);
ps=ps-decay_image;
tom_imagesc(tom_cut_out(ps,'center',[128 128]));

%polarOrg=tom_cart2polar(psOrgCut); figure; plot(tom_filter(sum(polarOrg,2),3),'r-');


% [Fit]=tom_fit_ctf(ps,EM,Search_tmp);








