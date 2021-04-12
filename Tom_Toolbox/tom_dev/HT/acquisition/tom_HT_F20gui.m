function varargout = tom_HT_F20gui(varargin)

% Last Modified by GUIDE v2.5 16-Jan-2008 10:11:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_HT_F20gui_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_HT_F20gui_OutputFcn, ...
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
function tom_HT_F20gui_OpeningFcn(hObject, eventdata, handles, varargin)


handles.I = imshow(zeros(1024,1024));
handles.scrollpanel = imscrollpanel(gcf,handles.I);
set(handles.scrollpanel,'Units','pixel','Position',[10 35 1024 1024]);
handles.scrollpanelapi = iptgetapi(handles.scrollpanel);
handles.imageaxis = gca;
handles.magnification = immagbox(handles.uipanel_zoom,handles.I);
set(handles.magnification,'Position',[30 13 60 20]);

try
    handles.COMS=tom_make_all_coms;
    [handles.Tiltseries, Search, Tracking, Focus, Acquisition, Slit]=tom_make_acquisition_structure(handles.COMS); % including the loading of all calibrations !
    handles.Acquisition=tom_get_state(Acquisition,handles.COMS);
catch
    warning('Could not make coms!');
end

handles.psdparams.filter_w1 = 0.025;
handles.psdparams.filter_w2 = 0.3;
handles.psdparams.decay_width = 0.02;
handles.psdparams.mask_w1 = 0.02;
handles.psdparams.mask_w2 = 0.3;

handles = helper_resetcache(handles);
handles.output = hObject;

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Output function
% -------------------------------------------------------------------------
function varargout = tom_HT_F20gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% -------------------------------------------------------------------------
% Button Get State
% -------------------------------------------------------------------------
function button_getstate_Callback(hObject, eventdata, handles)

handles.Acquisition=tom_get_state(handles.Acquisition,handles.COMS,'');

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Button Acquire
% -------------------------------------------------------------------------
function button_acquire_Callback(hObject, eventdata, handles)

handles = helper_statustext(handles,'Acquiring image...');

set(handles.checkbox_showpowerspectrum,'Value',0);

%get gui values
area = get(handles.edit_area,'String');
idx = get(handles.edit_area,'Value');
area = str2double(area{idx});
handles.Acquisition.CCD.Area = [area area];

binning  = get(handles.edit_binning,'String');
idx = get(handles.edit_binning,'Value');
binning = str2double(binning{idx});
handles.Acquisition.CCD.Binning = binning;
handles.Acquisition.CCD.Mode='single';

exptime = str2double(get(handles.edit_exposuretime,'String'));
handles.Acquisition.CCD.ExposureBaseTime = exptime;

processing = get(handles.edit_processing,'String');
idx = get(handles.edit_processing,'Value');
processing = processing{idx};

handles.Acquisition.CCD.Processing = processing;

handles = helper_lockgui(handles,'off');

%make picture
try
    tom_set_state(handles.Acquisition,handles.COMS,'noStage');
    handles.micrograph=tom_acquire_image(handles.Acquisition,handles.COMS,'noImageProcessing');
    handles.Tiltseries=tom_update_header(handles.Tiltseries,handles.Acquisition,handles.COMS);
    handles.micrograph=tom_emheader(handles.micrograph);
    handles.micrograph.Header=handles.Tiltseries.Header;
    handles.micrograph.Header.Objectpixelsize = handles.micrograph.Header.Objectpixelsize*binning;
catch
    %handles = helper_statustext(handles,'Image Acquisition failed.','error');
    %guidata(hObject, handles);
    %return;
    handles.micrograph = tom_emreadc('/fs/sally07/lv01/pool/pool-nickell/26S/em/data/271206/high/26S_40.em');
end


handles = helper_statustext(handles,'Image Acquisition completed.','success');

handles = helper_showmicrograph(handles);


if get(handles.checkbox_autosave,'Value') == 1
    handles = helper_savefile(handles);
end

handles = helper_lockgui(handles,'on');

handles = helper_resetcache(handles);


%update header info in gui
string = cell(3,1);

string{1} = handles.micrograph.Header.Voltage./1000;
string{2} = handles.micrograph.Header.Cs;
string{3} = handles.micrograph.Header.Objectpixelsize./10;

set(handles.text_header,'String',string);

set(handles.edit_defocus,'String',num2str(handles.micrograph.Header.Defocus/10000));
guidata(hObject, handles);


% -------------------------------------------------------------------------
% Button Browse for directory
% -------------------------------------------------------------------------
function button_browse_Callback(hObject, eventdata, handles)

PathName = uigetdir('Select directory to store micrographs');

if PathName == 0
    return;
end

set(handles.edit_directory,'String',PathName);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Button Save Micrograph
% -------------------------------------------------------------------------
function button_save_Callback(hObject, eventdata, handles)

handles = helper_savefile(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% Checkbox show power spectrum
% -------------------------------------------------------------------------
function checkbox_showpowerspectrum_Callback(hObject, eventdata, handles)

if get(hObject,'Value') == 1
    handles = helper_calcpsd(handles);
else
    handles = helper_showmicrograph(handles);
end

guidata(hObject, handles);


% -------------------------------------------------------------------------
% defocus input field
% -------------------------------------------------------------------------
function edit_defocus_Callback(hObject, eventdata, handles)

handles = helper_circles(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button defocus decrease
% -------------------------------------------------------------------------
function button_defocusdec_Callback(hObject, eventdata, handles)

defocus = str2double(get(handles.edit_defocus,'String'));
defocusstep = str2double(get(handles.edit_defocusstep,'String'));
set(handles.edit_defocus,'String',num2str(defocus+defocusstep));

handles = helper_circles(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button defocus increase
% -------------------------------------------------------------------------
function button_defocusinc_Callback(hObject, eventdata, handles)

defocus = str2double(get(handles.edit_defocus,'String'));
defocusstep = str2double(get(handles.edit_defocusstep,'String'));
set(handles.edit_defocus,'String',num2str(defocus-defocusstep));

handles = helper_circles(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox psd show rings
% -------------------------------------------------------------------------
function checkbox_psd_showrings_Callback(hObject, eventdata, handles)

if get(handles.checkbox_showpowerspectrum,'Value') == 1
    handles = helper_circles(handles);
end

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button fit magnification
% -------------------------------------------------------------------------
function button_fitmag_Callback(hObject, eventdata, handles)

handles = helper_lockgui(handles,'off');

mag = handles.scrollpanelapi.findFitMag();
handles.scrollpanelapi.setMagnification(floor(mag.*100)./100);

handles = helper_lockgui(handles,'on');

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox show contrast tool
% -------------------------------------------------------------------------
function checkbox_contrast_Callback(hObject, eventdata, handles)

handles = helper_lockgui(handles,'off');

if get(hObject,'Value') == 1
    handles.contrasttool = imcontrast(handles.scrollpanel);
else
    try
        delete(handles.contrasttool);
    end
end

handles = helper_lockgui(handles,'on');

guidata(hObject, handles);


% -------------------------------------------------------------------------
% input filter value
% -------------------------------------------------------------------------
function edit_filter_Callback(hObject, eventdata, handles)

handles = helper_showmicrograph(handles);

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox show overview
% -------------------------------------------------------------------------
function checkbox_overview_Callback(hObject, eventdata, handles)

handles = helper_lockgui(handles,'off');
handles = helper_statustext(handles,'Generating Overview...');   

if get(handles.checkbox_overview,'Value') == 1
    handles.overview = imoverviewpanel(handles.uipanel_overview,handles.I);
else
    delete(handles.overview);
end

handles = helper_lockgui(handles,'on');
handles = helper_statustext(handles,'Ready','success'); 

guidata(hObject, handles);


% -------------------------------------------------------------------------
% checkbox show overview
% -------------------------------------------------------------------------
function button_embrowse_Callback(hObject, eventdata, handles)


tom_embrowse('dir',get(handles.edit_directory,'String'));

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button fit defocus
% -------------------------------------------------------------------------
function button_fit_Callback(hObject, eventdata, handles)

if isempty(handles.psd)
    handles = helper_calcpsd(handles);
    set(handles.checkbox_showpowerspectrum,'Value',1);
end

handles = helper_lockgui(handles,'off');
handles = helper_statustext(handles,'Fitting CTF...');   
handles.micrograph.Header.Dz = str2double(get(handles.edit_defocus,'String')).*10000;

psd.Value = handles.psd;
psd.Header = handles.micrograph.Header;
Dz = tom_ctffitter2(psd);
set(handles.edit_defocus,'String',num2str(Dz/10000));
handles = helper_circles(handles);

handles = helper_lockgui(handles,'on');
handles = helper_statustext(handles,'Ready','success'); 

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button autofocus
% -------------------------------------------------------------------------
function button_autofocus_Callback(hObject, eventdata, handles)

handles = helper_lockgui(handles,'off');
handles = helper_statustext(handles,'Autofocusing...');   

tom_set_state(handles.Acquisition,handles.COMS,'noStage');
set(handles.COMS.CoreAutomation.AutoFocus,'Defocus',str2double(get(handles.edit_intendeddefocus,'String')).*1e-6);
invoke(handles.COMS.CoreAutomation.AutoFocus,'perform',handles.Focus.Optics.Defocus.Value,1,3);   

% show focus image
try
    neg_tilt=get(handles.COMS.CoreAutomation.AutoFocus.NegativeTiltImage,'Pixmap');
    pos_tilt=get(handles.COMS.CoreAutomation.AutoFocus.PositiveTiltImage,'Pixmap');
    ccf=get(handles.COMS.CoreAutomation.AutoFocus.CrossCorrelation.CrossCorrelationImage,'Pixmap');

    if isempty(findobj('Name','Focus'));
        figure; set(gcf,'MenuBar','none')
        set(gcf,'Position', [857 358 404 579],'Name','Focus');  %Position on the left side
    else
        figure(findobj('Name','Focus'));
    end
    subplot(3,1,1);
    tom_imagesc(neg_tilt);drawnow expose;
    subplot(3,1,2);
    tom_imagesc(pos_tilt);drawnow expose;
    subplot(3,1,3);
    tom_imagesc(ccf);drawnow expose;

    handles = helper_statustext(handles,'Ready','success'); 
    
catch
    disp(lasterror);
    handles = helper_statustext(handles,'FEI Focus images not available!','error'); 
end

handles = helper_lockgui(handles,'on');

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button auto euzentric height
% -------------------------------------------------------------------------
function button_auto_euzheight_Callback(hObject, eventdata, handles)

handles = helper_lockgui(handles,'off');
handles = helper_statustext(handles,'Auto Euzentric Height...');   

tom_set_state(handles.Acquisition,handles.COMS,'noStage');
angle = ceil(str2double(get(handles.edit_euzangle,'String')));
set(handles.COMS.CoreAutomation.AutoEucentricHeight.Settings,'StageTilt',angle);
invoke(handles.COMS.CoreAutomation.AutoEucentricHeight,'Perform');

handles = helper_lockgui(handles,'on');
handles = helper_statustext(handles,'Ready','success'); 

guidata(hObject, handles);


% -------------------------------------------------------------------------
% button tune psd enhance parameters
% -------------------------------------------------------------------------
function button_psdparams_Callback(hObject, eventdata, handles)

prompt = {'bandpass low:','bandpass high:','decay width:','mask low:','mask high:'};
dlg_title = 'PSD enhance parameters';
num_lines = 1;
def = {num2str(handles.psdparams.filter_w1),num2str(handles.psdparams.filter_w2),num2str(handles.psdparams.decay_width),num2str(handles.psdparams.mask_w1),num2str(handles.psdparams.mask_w2)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

handles.psdparams.filter_w1 = str2double(answer{1});
handles.psdparams.filter_w2 = str2double(answer{2});
handles.psdparams.decay_width = str2double(answer{3});
handles.psdparams.mask_w1 = str2double(answer{4});
handles.psdparams.mask_w2 = str2double(answer{5});

if get(handles.checkbox_showpowerspectrum,'Value') == 1
    handles = helper_calcpsd(handles);
end

guidata(hObject,handles);


% -------------------------------------------------------------------------
% checkbox show pixel info
% -------------------------------------------------------------------------
function checkbox_pixelinfo_Callback(hObject, eventdata, handles)

if get(hObject,'Value') == 1
    handles.impixelinfo = impixelinfo;
else
    try
        delete(handles.impixelinfo);
    end
end

guidata(hObject,handles);


% -------------------------------------------------------------------------
% helper: save micrograph
% -------------------------------------------------------------------------
function handles = helper_savefile(handles)

handles = helper_lockgui(handles,'off');

handles = helper_statustext(handles,'Saving file...');

handles.micrograph.Header.Defocus = num2str(get(handles.edit_defocus))*10000;

directory = get(handles.edit_directory,'String');
filename = get(handles.edit_filename,'String');
filenumber = ceil(str2double(get(handles.edit_filenumber,'String')));

if isempty(directory)
    errordlg('Select a directory first.');
    return;
end

if isempty(filename)
    errordlg('Choose a filename first.');
    return;
end

if isempty(filenumber) 
    errordlg('Choose a filename first.');
    return;
end

try
tom_emwrite([directory filesep filename num2str(filenumber) '.em'],handles.micrograph);
set(handles.edit_filenumber,'String',num2str(filenumber+1));
catch
    handles = helper_statustext(handles,'File could not be saved.','error');
    handles = helper_lockgui(handles,'on');
    return;
end
handles = helper_statustext(handles,'File saved.','success');

handles = helper_lockgui(handles,'on');


% -------------------------------------------------------------------------
% helper: show micrograph
% -------------------------------------------------------------------------
function handles = helper_showmicrograph(handles)

handles = helper_lockgui(handles,'off');

for i=1:7
    try
        api = iptgetapi(handles.circle(i));
        api.delete();
    end
end

try
    delete(handles.contrasttool);
end
    
radius = str2double(get(handles.edit_filter,'String'));

if radius > 1
    handles = helper_statustext(handles,'Filtering micrograph...');
    h = fspecial('average',[radius radius]);
    handles.scrollpanelapi.replaceImage(imfilter(handles.micrograph.Value',h));
    handles = helper_statustext(handles,'Filtering completed.','success');
else
    handles = helper_statustext(handles,'Rendering micrograph...');
    handles.scrollpanelapi.replaceImage(handles.micrograph.Value');
end

handles = helper_statustext(handles,'Rendering micrograph...');

mag = handles.scrollpanelapi.findFitMag();
handles.scrollpanelapi.setMagnification(mag);

[s1,s2] = size(handles.micrograph.Value);
mean=sum(sum(handles.micrograph.Value(1:4:end,1:4:end)))./((s1/4).*(s2/4));
std=std2(handles.micrograph.Value(1:4:end,1:4:end));


string{1} = ['mean: ' num2str(round(mean))];
string{2} = ['dose:  not calibrated'];
set(handles.text_imstat,'String',string);

if get(handles.checkbox_contrast,'Value') == 1
    handles.contrasttool = imcontrast(handles.scrollpanel);
else
    try
        delete(handles.contrasttool);
    end
end


set(handles.imageaxis,'Clim',[mean-2.*std mean+2.*std]);

try
    delete(handles.overview);
end

if get(handles.checkbox_overview,'Value') == 1
    handles.overview = imoverviewpanel(handles.uipanel_overview,handles.I);
end

handles = helper_statustext(handles,'Ready','success');

handles = helper_lockgui(handles,'on');


% -------------------------------------------------------------------------
% helper: set status text
% -------------------------------------------------------------------------
function handles = helper_statustext(handles,text,type)

if nargin < 3
    type = '';
end

set(handles.text_status,'String',text);

switch type
    case 'error'
        color = [1 0 0];
    case 'success'
        color = [0 .8 0];
    case 'warning'
        color = [1 1 0];
    otherwise
        color = [0 0 0];
end

set(handles.text_status,'ForegroundColor',color);
drawnow update;


% -------------------------------------------------------------------------
% helper: calculate and display power spectrum
% -------------------------------------------------------------------------
function handles = helper_calcpsd(handles)

handles = helper_lockgui(handles,'off');

try
    delete(handles.overview);
end

handles = helper_statustext(handles,'Calculating Power Spectrum...');

if isempty(handles.origpsd)
    handles.origpsd = tom_calc_periodogram(handles.micrograph.Value,256,false,32);
end

try
    handles.psd = tom_psd_enhance(handles.origpsd,true,true,handles.psdparams.filter_w1,handles.psdparams.filter_w2,handles.psdparams.decay_width,handles.psdparams.mask_w1,handles.psdparams.mask_w2);
catch
    handles = helper_statustext(handles,'Calculation of Power Spectrum failed.','error');
    handles = helper_lockgui(handles,'on');
    return;
end
handles = helper_statustext(handles,'Calculation of Power Spectrum completed.','success');

[s1,s2] = size(handles.psd);
mean=sum(sum(handles.psd))./((s1/4).*(s2/4));
std=std2(handles.psd);

handles.scrollpanelapi.replaceImage(handles.psd);
mag = handles.scrollpanelapi.findFitMag();
handles.scrollpanelapi.setMagnification(mag);

set(handles.imageaxis,'Clim',[mean-2.*std mean+2.*std]);

handles = helper_circles(handles);

handles = helper_lockgui(handles,'on');


% -------------------------------------------------------------------------
% helper: calculate and display power spectrum
% -------------------------------------------------------------------------
function handles = helper_resetcache(handles)

handles.origpsd = [];


% -------------------------------------------------------------------------
% helper: lock / unlock gui
% -------------------------------------------------------------------------
function handles = helper_lockgui(handles,flag)

if nargin < 2
    flag = 'on';
end

set(handles.edit_binning,'Enable',flag);
set(handles.edit_area,'Enable',flag);
set(handles.edit_processing,'Enable',flag);
set(handles.button_acquire,'Enable',flag);

set(handles.edit_directory,'Enable',flag);
set(handles.edit_filename,'Enable',flag);
set(handles.edit_filenumber,'Enable',flag);
set(handles.button_browse,'Enable',flag);
set(handles.button_save,'Enable',flag);
set(handles.checkbox_autosave,'Enable',flag);
set(handles.checkbox_showpowerspectrum,'Enable',flag);
set(handles.edit_defocus,'Enable',flag);
set(handles.edit_defocusstep,'Enable',flag);
set(handles.button_defocusdec,'Enable',flag);
set(handles.button_defocusinc,'Enable',flag);
set(handles.button_fitmag,'Enable',flag);
set(handles.edit_exposuretime,'Enable',flag);
set(handles.checkbox_contrast,'Enable',flag);
set(handles.checkbox_overview,'Enable',flag);
set(handles.edit_filter,'Enable',flag);
set(handles.checkbox_psd_showrings,'Enable',flag);
set(handles.button_getstate,'Enable',flag);
set(handles.button_embrowse,'Enable',flag);
set(handles.button_fit,'Enable',flag);
set(handles.button_autofocus,'Enable',flag);
set(handles.button_auto_euzheight,'Enable',flag);
set(handles.edit_euzangle,'Enable',flag);
set(handles.edit_intendeddefocus,'Enable',flag);
set(handles.button_psdparams,'Enable',flag);
set(handles.checkbox_pixelinfo,'Enable',flag);

drawnow update;


% -------------------------------------------------------------------------
% helper: draw circles
% -------------------------------------------------------------------------
function handles = helper_circles(handles)

handles = helper_lockgui(handles,'off');

if get(handles.checkbox_psd_showrings,'Value') == 1
    binning  = get(handles.edit_binning,'String');
    idx = get(handles.edit_binning,'Value');
    binning = str2double(binning{idx});
    sz = 256;
    defocus = str2double(get(handles.edit_defocus,'String'));
    qzero = tom_ctfzero(defocus,handles.micrograph.Header.Objectpixelsize/10, handles.micrograph.Header.Voltage/1000,sz*2/binning, handles.micrograph.Header.Cs);

    if ~isfield(handles,'fcn')
        handles.fcn = makeConstrainToRectFcn('imellipse', [sz sz], [sz sz]);
    end
    
    for i=1:7
        try
            api = iptgetapi(handles.circle(i));
            api.setPosition([(sz/2+1)-qzero(i)/2 (sz/2+1)-qzero(i)/2 qzero(i) qzero(i)]);
        catch
            handles.circle(i) = imellipse(handles.imageaxis, [(sz/2+1)-qzero(i)/2 (sz/2+1)-qzero(i)/2 qzero(i) qzero(i)]);
            api = iptgetapi(handles.circle(i));
            api.setResizable(false);
            api.setColor([1 0 0]);
            api.setPositionConstraintFcn(handles.fcn);
        end
    end
end

handles = helper_lockgui(handles,'on');


% -------------------------------------------------------------------------
% Create functions / Unused Callbacks
% -------------------------------------------------------------------------
function edit_binning_Callback(hObject, eventdata, handles)
function edit_area_Callback(hObject, eventdata, handles)
function edit_processing_Callback(hObject, eventdata, handles)
function edit_area_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_processing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_binning_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_filename_Callback(hObject, eventdata, handles)
function edit_filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_filenumber_Callback(hObject, eventdata, handles)
function edit_filenumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_directory_Callback(hObject, eventdata, handles)
function edit_directory_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox_autosave_Callback(hObject, eventdata, handles)
function edit_defocus_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_defocusstep_Callback(hObject, eventdata, handles)
function edit_defocusstep_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_filter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_exposuretime_Callback(hObject, eventdata, handles)
function edit_exposuretime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_euzangle_Callback(hObject, eventdata, handles)
function edit_euzangle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_intendeddefocus_Callback(hObject, eventdata, handles)
function edit_intendeddefocus_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




