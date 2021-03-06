function varargout = tom_HT_main(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_main_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_main_OutputFcn, ...
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
function tom_HT_main_OpeningFcn(hObject, eventdata, handles, varargin)

if nargin == 5
    handles.projectstruct = struct();
    handles.projectstruct.conn = varargin{1};
    handles.projectstruct.projectid = varargin{2};
    result = fetch(handles.projectstruct.conn,['SELECT name, datadir FROM projects WHERE project_id = ''' num2str(handles.projectstruct.projectid) '''']);
    if ~isempty(result)
        handles.projectstruct.projectname = result.name{1};
        handles.projectstruct.datadir = result.datadir{1};
    else 
        error('Could not find project.');
    end
else
    error('Run tom_HT_openproject to access a project.');
end

set(handles.projectname,'String',handles.projectstruct.projectname);

tom_HT_runcachedaemon();

handles.timer = timer('ExecutionMode','FixedRate','TimerFcn', 'ping(handles.projectstruct.conn)', 'Period',3600); 

handles.output = hObject;
guidata(hObject, handles);


% -------------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------------
function varargout = tom_HT_main_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% -------------------------------------------------------------------------
% references
% -------------------------------------------------------------------------
function button_references_Callback(hObject, eventdata, handles)


guidata(hObject, handles);


% -------------------------------------------------------------------------
% masks
% -------------------------------------------------------------------------
function button_masks_Callback(hObject, eventdata, handles)

tom_HT_maskeditor(handles.projectstruct);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% filters
% -------------------------------------------------------------------------
function button_filters_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% persons
% -------------------------------------------------------------------------
function button_people_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% literature
% -------------------------------------------------------------------------
function button_literature_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% symmetry
% -------------------------------------------------------------------------
function button_symmetry_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% norming methods
% -------------------------------------------------------------------------
function button_norm_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% micrographs
% -------------------------------------------------------------------------
function button_micrographs_Callback(hObject, eventdata, handles)

tom_HT_micrographs(handles.projectstruct);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% microscopes
% -------------------------------------------------------------------------
function button_microscopes_Callback(hObject, eventdata, handles)

tom_HT_microscopes(handles.projectstruct);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% particle stacks
% -------------------------------------------------------------------------
function button_stacks_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% image series
% -------------------------------------------------------------------------
function button_imageseries_Callback(hObject, eventdata, handles)

tom_HT_micrographgroups(handles.projectstruct);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% MTFs
% -------------------------------------------------------------------------
function button_mtfs_Callback(hObject, eventdata, handles)

tom_HT_mtfs(handles.projectstruct);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment 2d alignment
% -------------------------------------------------------------------------
function button_2dalignment_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% -------------------------------------------------------------------------
% experiment image series sorting
% -------------------------------------------------------------------------
function button_imageseriessorter_Callback(hObject, eventdata, handles)

tom_HT_imageseriessorter(handles.projectstruct);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment manual particle picking
% -------------------------------------------------------------------------
function button_manualpicker_Callback(hObject, eventdata, handles)

tom_HT_particlepicker(handles.projectstruct)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment automatic particle picking
% -------------------------------------------------------------------------
function button_autopicker_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment CTF determination
% -------------------------------------------------------------------------
function button_ctfdetermination_Callback(hObject, eventdata, handles)

guidata(hObject, handles);



% -------------------------------------------------------------------------
% experiment xmipp 2d ml alignment
% -------------------------------------------------------------------------
function button_xmipp_2dalign_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment 3d reconstruction
% -------------------------------------------------------------------------
function button_3dreconstruction_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment xmipp 3d ml reconstruction
% -------------------------------------------------------------------------
function button_xmipp_3dreconstruction_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment pca
% -------------------------------------------------------------------------
function button_pca_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment kerdensom
% -------------------------------------------------------------------------
function button_kerdensom_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


% -------------------------------------------------------------------------
% experiment browser
% -------------------------------------------------------------------------
function button_expbrowser_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% -------------------------------------------------------------------------
% item browser
% -------------------------------------------------------------------------
function button_itembrowser_Callback(hObject, eventdata, handles)

tom_HT_filebrowser(handles.projectstruct);

guidata(hObject, handles);




