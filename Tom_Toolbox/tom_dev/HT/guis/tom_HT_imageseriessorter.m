function varargout = tom_HT_imageseriessorter(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_imageseriessorter_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_imageseriessorter_OutputFcn, ...
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
function tom_HT_imageseriessorter_OpeningFcn(hObject, eventdata, handles, varargin)

if nargin == 4
    handles.projectstruct = varargin{1};
else
    error('This GUI must be called from tom_HT_main.');
end

result = tom_HT_getmicrographgroups(handles.projectstruct);
if ~isempty(result)
    string = {'---please select---',result.name{:}};
    set(handles.popupmenu_imageseries,'String',string);
    set(handles.popupmenu_imageseries,'UserData',[-1;result.micrographgroup_id]);
else 
   
end

handles.output = hObject;

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------------
function varargout = tom_HT_imageseriessorter_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% -------------------------------------------------------------------------
% Image series select box
% -------------------------------------------------------------------------
function popupmenu_imageseries_Callback(hObject, eventdata, handles)


[seriesname,seriesid] = tom_HT_getselecteddropdownfieldindex(hObject);

if strcmp(seriesname,'---please select---') == 0
    result = tom_HT_getimageseriesresults(handles.projectstruct,seriesid);

    if ~isempty(result)
        string = {'---please select---',result.name{:}};
        set(handles.popupmenu_result,'String',string);
        set(handles.popupmenu_result,'UserData',[-1;result.experiment_id]);
    else

    end
end
guidata(hObject, handles);


% -------------------------------------------------------------------------
% button new result 
% -------------------------------------------------------------------------
function pushbutton_newresult_Callback(hObject, eventdata, handles)
prompt = {'result name:'};
dlg_title = 'Create new result';
num_lines = 1;
def = {''};
answer = inputdlg(prompt,dlg_title,num_lines,def);
string = get(handles.popupmenu_result,'String');
userdata = get(handles.popupmenu_result,'UserData');
if ~isempty(string)
    string = {string{:},answer{1}};
    set(handles.popupmenu_result,'UserData',[userdata;-1]);
else
    string = {'---please select---',answer{1}};
    set(handles.popupmenu_result,'UserData',[-1;0]);
end
set(handles.popupmenu_result,'String',string);


guidata(hObject, handles);


% -------------------------------------------------------------------------
% popupmenu result 
% -------------------------------------------------------------------------
function popupmenu_result_Callback(hObject, eventdata, handles)

[resultname,resultid] = tom_HT_getselecteddropdownfieldindex(hObject);
[seriesname,seriesid] = tom_HT_getselecteddropdownfieldindex(handles.popupmenu_imageseries);

if strcmp(seriesname,'---please select---') == 0 && strcmp(resultname,'---please select---') == 0
    layout2 = tom_HT_getselecteddropdownfieldindex(handles.popupmenu_layout);
    
    handles.imageseries = tom_HT_imageseries(handles.projectstruct,seriesid);
    numfiles = get_numberoffiles(handles.imageseries);    
    switch layout2
        case '1'
            numpages = numfiles;
            cols = 1;
        case '2x2'
            numpages = ceil(numfiles/4);
            cols = 2;
        case '3x3'
            numpages = ceil(numfiles/9);
            cols = 3;
        case '4x4'
            numpages = ceil(numfiles/16);
            cols = 4;            
        case '5x5'
            numpages = ceil(numfiles/25);
            cols = 5;           
        case '6x6'
            numpages = ceil(numfiles/36);       
            cols = 6;
        case '7x7'
            numpages = ceil(numfiles/49);       
            cols = 7;
        case '8x8'
            numpages = ceil(numfiles/64);       
            cols = 8;
        case '9x9'
            numpages = ceil(numfiles/81);       
            cols = 9;
        case '10x10'
            numpages = ceil(numfiles/100);       
            cols = 10;
    end
   
    handles.imageseries = getgoodbadresultfromdb(handles.imageseries,resultid);
    handles.imageseries = set_position(handles.imageseries,1);
    
    handles.stackwidget = tom_HT_stackwidget();
    handles.stackwidget = layout(handles.stackwidget,1000,1000,cols,cols);
    handles.stackwidget = set_numpages(handles.stackwidget,numpages);
    handles.stackwidget = normalize(handles.stackwidget);
    handles.numpages = numpages;
    handles.cols = cols;
    st = tom_HT_unserialize_string(get(handles.imageseries,'description'));
    if ~isempty(st)
        set(handles.edit_comment,'String',[st{:}]);
    else
        set(handles.edit_comment,'String',st);
    end
    
    cb = ['tom_HT_imageseriessorter(''slidercallback'',' sprintf('%5.20f',hObject) ');'];
    handles.stackwidget = set_slidercallback(handles.stackwidget,cb);
    cb = ['tom_HT_imageseriessorter(''leftclickcallback'',' sprintf('%5.20f',hObject) ');'];
    handles.stackwidget = add_leftclickcallback(handles.stackwidget,cb);
    handles = update_page(handles,1);
end

guidata(hObject, handles);


% -------------------------------------------------------------------------
% layout
% -------------------------------------------------------------------------
function popupmenu_layout_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% exit
% -------------------------------------------------------------------------
function button_exit_Callback(hObject, eventdata, handles)

handles.imageseries = set(handles.imageseries,'description',tom_HT_serialize_string(get(handles.edit_comment,'String')));
resultname = tom_HT_getselecteddropdownfieldindex(handles.popupmenu_result);
handles.imageseries = set(handles.imageseries,'resultname',resultname);
handles.imageseries = savegoodbadtodb(handles.imageseries);

try 
   delete(handles.stackwidget);
end

try
    delete(handles.imageseriessorter);
end


% -------------------------------------------------------------------------
% Update the view window
% -------------------------------------------------------------------------
function handles = update_page(handles,pageno)


handles.imageseries = set_position(handles.imageseries,(pageno-1).*handles.cols^2+1);

[handles.stackwidget, width] = get_partsize(handles.stackwidget);
handles.stackwidget = clearall(handles.stackwidget);
tom_HT_clearreadahead();

numfiles = handles.cols^2;

gb = true(handles.cols,handles.cols);

for i=1:numfiles

    [handles.imageseries,filename] = get_currentfilename(handles.imageseries);
    gb(i) = get_goodbad(handles.imageseries);
    handles.imageseries = next(handles.imageseries);
    image = tom_HT_image(handles.projectstruct);
    image = loadimage(image,filename,width);
    im = get(image,'image');
    handles.stackwidget = addparticle(handles.stackwidget,im.Value,get(image,'micrographid'));
    clear('image');

    if mod(i,handles.cols) == 0
        drawnow;
    end
end
handles.stackwidget = render_marks(handles.stackwidget,gb);


filenames = cell(numfiles,1);
for i=1:numfiles
    handles.imageseries = next(handles.imageseries);
    [handles.imageseries,filename,fullfilename] = get_currentfilename(handles.imageseries);
    filenames{i} = fullfilename;
end

tom_HT_readahead(filenames);


% -------------------------------------------------------------------------
% Slider callback
% -------------------------------------------------------------------------
function slidercallback(hObject)

handles = guidata(hObject);

sliderhandle = get(handles.stackwidget,'slider');
pageno = round(get(sliderhandle,'Value'));
handles.stackwidget = set_currentpage(handles.stackwidget,pageno);
handles = update_page(handles,pageno);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Handles left click on image to mark good or bad.
% -------------------------------------------------------------------------
function leftclickcallback(hObject)

handles = guidata(hObject);

point1 = get(gca,'currentpoint');
button = get(gcf,'selectiontype');

if strcmp(button,'normal') == true

    ud = get(gca,'UserData');

    [handles.imageseries,data] = mark_goodbad(handles.imageseries,ud(1),'toggle');
    handles.stackwidget = redraw_mark(handles.stackwidget,data,ud(2),ud(3));

    guidata(hObject, handles);

end


% -------------------------------------------------------------------------
% Create functions
% -------------------------------------------------------------------------
function popupmenu_imageseries_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_layout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_result_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_comment_Callback(hObject, eventdata, handles)
function edit_comment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




