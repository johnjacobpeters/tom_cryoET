function varargout = tom_av2_particlepickerGui2(varargin)
% TOM_AV2_PARTICLEPICKERGUI2 MATLAB code for tom_av2_particlepickerGui2.fig
%      TOM_AV2_PARTICLEPICKERGUI2, by itself, creates a new TOM_AV2_PARTICLEPICKERGUI2 or raises the existing
%      singleton*.
%
%      H = TOM_AV2_PARTICLEPICKERGUI2 returns the handle to a new TOM_AV2_PARTICLEPICKERGUI2 or the handle to
%      the existing singleton*.
%
%      TOM_AV2_PARTICLEPICKERGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOM_AV2_PARTICLEPICKERGUI2.M with the given input arguments.
%
%      TOM_AV2_PARTICLEPICKERGUI2('Property','Value',...) creates a new TOM_AV2_PARTICLEPICKERGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tom_av2_particlepickerGui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tom_av2_particlepickerGui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tom_av2_particlepickerGui2

% Last Modified by GUIDE v2.5 23-Sep-2016 12:28:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tom_av2_particlepickerGui2_OpeningFcn, ...
    'gui_OutputFcn',  @tom_av2_particlepickerGui2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);


if nargin && ischar(varargin{1})
    if (length(dbstack)>1) %hack it here to get rid of the warning from str2func
        gui_State.gui_Callback = str2func(varargin{1});
    end;
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tom_av2_particlepickerGui2 is made visible.
function tom_av2_particlepickerGui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_av2_particlepickerGui2 (see VARARGIN)



normaLizeButtonsAndFont=1;

if (isempty(varargin))
    pickList=[];
    stackList=[];
    all_Img{1}=[];
    nrPartsTot=0;
    nrPartsCurrIImg=0;
else
    [pickList,stackList,nrPartsTot,nrPartsCurrIImg]=readInput(varargin{1},handles);
    all_Img=pickList.keys;
    initSlider(handles,length(all_Img),pickList);
    set(handles.edit_inputFileName,'String',varargin{1});
end;

initStorage(handles,pickList,stackList,all_Img,nrPartsTot,nrPartsCurrIImg); %introducing ugly globals check function for reason
renderImg();
overloadMouseButtons();
normalizeButtons(handles,normaLizeButtonsAndFont);
setGuiSizeToResolution(handles);
removeTicksFromAxis(handles); % some matlab version don't update settigns from guide makes normally no sense

% Choose default command line output for tom_av2_particlepickerGui2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes tom_av2_particlepickerGui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function removeTicksFromAxis(handles)

set(handles.axes_partClicked,'XTickLabel',[]);
set(handles.axes_partClicked,'YTickLabel',[]);

set(handles.axes_partAlg,'XTickLabel',[]);
set(handles.axes_partAlg,'YTickLabel',[]);

set(handles.axes_partAvg,'XTickLabel',[]);
set(handles.axes_partAvg,'YTickLabel',[]);

set(handles.axes_fsc,'XTickLabel',[]);
set(handles.axes_fsc,'YTickLabel',[]);





% --- Outputs from this function are returned to the command line.
function varargout = tom_av2_particlepickerGui2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderCurrImg_Callback(hObject, eventdata, handles)
% hObject    handle to sliderCurrImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateGuiNewImg(handles);



% --- Executes during object creation, after setting all properties.
function sliderCurrImg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderCurrImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_inputFileName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inputFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inputFileName as text
%        str2double(get(hObject,'String')) returns contents of edit_inputFileName as a double


% --- Executes during object creation, after setting all properties.
function edit_inputFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inputFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_inputBrowse.
function push_inputBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to push_inputBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uigetfile('*.*');
set(handles.edit_inputFileName,'String',[path filesep file]);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_pickRad_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pickRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pickRad as text
%        str2double(get(hObject,'String')) returns contents of edit_pickRad as a double


% --- Executes during object creation, after setting all properties.
function edit_pickRad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pickRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [pickList,stackList,nrPartsTot,nrPartsCurrIImg]=readInput(in,handles)


[basePath,name,ext]=fileparts(in);
d=dir(in);

if (length(d)==0);
    errordlg('no items found ...check input')
end;

inputClass=tom_determine_file_type2([basePath filesep d(1).name ]);

if (strcmp(inputClass,'mrc'))
    for i=1:length(d)
        imgList{i}=[basePath filesep d(i).name];
        coordList{i}=[];
        emptyList{i}=[];
    end;
    set(handles.chk_showParticle,'Value',1);
    set(handles.chk_alignParticle,'Value',1);
end;

if (strcmp(inputClass,'star file') ||   strcmp(inputClass,'box file'));
    for i=1:length(d)
        tmpFileName=[basePath filesep d(i).name];
        [tmpFilePath,tmpFileMid,tmpFileExt]=fileparts(tmpFileName);
        
        if (strcmp(inputClass,'star file') || strcmp(inputClass,'box file'))
             idx=strfind(tmpFileMid,'_');
             name=tmpFileMid(1:(idx(end)-1));
             if strcmp(inputClass,'box file')
                name=tmpFileMid;
             end;
             
        else
            name=tmpFileMid;
        end;
        imgList{i}=[tmpFilePath filesep name '.mrc'];
       
        %StarFile
        if (strcmp(inputClass,'star file'))
            try
                tmpStar=tom_starread(tmpFileName,'matrix');
                coord(:,1)=[tmpStar{:,1}];
                coord(:,2)=[tmpStar{:,2}];
                coordList{i}=coord;
                clear('coord');
            catch
            end;
          end;
        %BoxFile
        if (strcmp(inputClass,'box file'))
            coordTmp=importdata(tmpFileName);
            off=coordTmp(1,3)./2;
            for ii=1:size(coordTmp,1)
                coordTrans(ii,1:2)=[coordTmp(ii,1)+off coordTmp(ii,2)+off];
            end;
            coordList{i}=coordTrans;
            coordTrans=[];
        end;
        emptyList{i}=[];
    end;
end;

if (strcmp(inputClass,'mat file') );
    pl=load(in);
    align2d=pl.align2d;
    for i=1:size(align2d,2)
        allFileNames{i}=align2d(1,i).filename;
    end;
    filenamesUnique=unique(allFileNames);
    for i=1:length(filenamesUnique)
        idx=find(ismember(allFileNames,filenamesUnique{i}));
        for ii=1:length(idx)
            coordsTmp(ii,1)=align2d(1,idx(ii)).position.x;
            coordsTmp(ii,2)=align2d(1,idx(ii)).position.y;
        end;
        coordList{i}=coordsTmp;
        coordsTmp=[];
        imgList{i}=filenamesUnique{i};
        emptyList{i}=[];
    end;
end;


nrPartsTot=0;
nrPartsCurrIImg=size(coordList{1},1);
for i=1:length(coordList)
    nrPartsTot=nrPartsTot+size(coordList{i},1);
end;

pickList=containers.Map(imgList,coordList);
stackList=containers.Map(imgList,emptyList);



function renderAlignmentPanel()

global storage_particlepickerGui2


handles=storage_particlepickerGui2.handles;

showParticle=get(handles.chk_showParticle,'Value');
if (showParticle==0)
    return;
end;

part=storage_particlepickerGui2.partStack.currPart;
partAlg=storage_particlepickerGui2.partStack.currPartAlg;

avg=storage_particlepickerGui2.partStack.avg;

filtParamAvg=str2double(get(handles.edit_fAvgParam1,'String'));
appfiltAvg=get(handles.chk_useFiltAvg,'Value');
fType=get(handles.pop_fAvgType,'String');
fType=fType{get(handles.pop_fAvgType,'Value')};

filtParamMicrograph=str2double(get(handles.edit_fmicroParam1,'String'));
appfiltMicrograph=get(handles.chk_useFiltMicrograph,'Value');

if (isempty(part))
    axes(handles.axes_partClicked);
    imgeSc(ones(48,48));
    axes(handles.axes_partAlg);
    imgeSc(ones(48,48));
else
    if (appfiltMicrograph)
        axes(handles.axes_partClicked);
        imgeSc(tom_filter(part,filtParamMicrograph));
        axes(handles.axes_partAlg);
        imgeSc(tom_filter(partAlg,filtParamMicrograph));
    else
        axes(handles.axes_partClicked);
        imgeSc(part);
        axes(handles.axes_partAlg);
        imgeSc(partAlg);
    end;
end;

axes(handles.axes_partAvg);
if (isempty(avg))
    imgeSc(ones(48,48));
else
    if (appfiltAvg)
        if (strcmp(fType,'cernel ')) 
            imgeSc(tom_filter(avg,filtParamAvg));
        end;
        if  (strcmp(fType,'sqrt(fsc) '))
            if (isempty(storage_particlepickerGui2.partStack.fscFilt))
                imgeSc(tom_filter(avg,5));
            else
                imgeSc(tom_apply_weight_function(avg,storage_particlepickerGui2.partStack.fscFilt));
            end;
        end;
        
       else
        imgeSc(avg);
    end;
end;

plotFsc(storage_particlepickerGui2.handles.axes_fsc,storage_particlepickerGui2.partStack.fscFun);


function updateGuiNewImg(handles,slPos)

global  storage_particlepickerGui2;

if (nargin<2)
    slPos=round(get(handles.sliderCurrImg,'Value'));
end;

%filebrowser 
set(handles.sliderCurrImg,'Value',slPos);
set(handles.pop_fileBrFileName,'Value',slPos);
set(handles.pop_fileBrPath,'Value',slPos);
set(handles.text_fileBrInfo,'String',[num2str(slPos) ' of  '  num2str(length(storage_particlepickerGui2.pickList.list.keys))]);

list=storage_particlepickerGui2.pickList.list.keys;
imgName=list{get(handles.sliderCurrImg,'Value')};
storage_particlepickerGui2.currImg.name=imgName;

%info
all_point=storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name);
storage_particlepickerGui2.pickList.currImgCount=size(all_point,1);
tmpString=['class: default: pats on current image:' num2str(storage_particlepickerGui2.pickList.currImgCount)  ...
    ' parts total: ' num2str(storage_particlepickerGui2.pickList.totalCount)];
set(storage_particlepickerGui2.handles.listb_info,'String',tmpString);

renderImg();



function renderImg(readAndFilt)

if (nargin<1)
    readAndFilt=1;
end;

global storage_particlepickerGui2

handles=storage_particlepickerGui2.handles;
imgName=storage_particlepickerGui2.currImg.name;

if (isempty(imgName))
    return;
end;

if (readAndFilt==1)
    img=readImg(imgName);
    if (get(handles.chk_useFiltMicrograph,'Value')==1)
        img=tom_filter(img,str2double(get(handles.edit_fmicroParam1,'String')));
    end;
else
    img=getimage(handles.axesCurrImg)';
end;

axes(handles.axesCurrImg); imgeSc(img);
all_points=storage_particlepickerGui2.pickList.list(imgName);

showMarks=get(handles.chk_showMarks,'Value');
if (isempty(all_points)==0 && showMarks)
    renderPoints(all_points(:,1),all_points(:,2));
end;




function [im,sz]=readImg(imgName)

global storage_particlepickerGui2

type=tom_determine_file_type2(imgName);

if (strcmp(type,'mrc'))
    im=tom_mrcread(imgName);
else
    [~,~,ext]=fileparts(imgName);
    if (strcmp(ext,'.mrc'))
         im=tom_mrcread(imgName);
    end;
    
end;



im=im.Value;
sz=size(im);
storage_particlepickerGui2.currImg.sz=sz;
storage_particlepickerGui2.currImg.val=im;




function renderPoints(x,y,operator)

if (nargin<3)
    operator='add';
end;

global storage_particlepickerGui2

handles=storage_particlepickerGui2.handles;
showMarks=get(handles.chk_showMarks,'Value');

if (showMarks==0)
    return;
end;

if (strcmp(operator,'add'))
     hold on; plot(x,y,'r+'); hold off;
end;

if (strcmp(operator,'redraw'))
    try
        all_point=storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name);
        ch=storage_particlepickerGui2.handles.axesCurrImg.Children;
        zz=0;
        for i=1:length(ch)
            if (strcmp(ch(i).Type,'line'))
                zz=zz+1;
                idxPointH(zz)=i;
            end;
        end;
        delete(ch(idxPointH));
        hold on; plot(all_point(:,1),all_point(:,2),'r+'); hold off;
    catch Me
       disp(['render problem ' Me.message]);
       pause(0.1);
    end;
 end;


if (strcmp(operator,'remove'))
    
end;

if (strcmp(operator,'hideAll'))
    hMarkers=handles.axesCurrImg.Children;
    set(hMarkers(1),'Visible','off');
end;


tmpString=['class: default: pats on current image:' num2str(storage_particlepickerGui2.pickList.currImgCount)  ...
    ' parts total: ' num2str(storage_particlepickerGui2.pickList.totalCount)];
set(storage_particlepickerGui2.handles.listb_info,'String',tmpString);




function setGuiSizeToResolution(handles)

screenSize = get(0,'screensize');
if (screenSize(3)==3840)
    set(handles.figure1,'Position',[38.1250 13.0000 343.7500 118.3750]);
end;
if (screenSize(3)==2560)
    set(handles.figure1,'Position',[33.7500   54.3750  236.1250   75.0000]);
end;
if (screenSize(3)==1920)
    set(handles.figure1,'Position',[33.7500 63.6875 208.0000 65.6875]);
end;




function imgeSc(img)

h=imagesc(img');
axis image;
colormap gray;
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])


function initSlider(handles,nrImg,pickList)

global storage_particlepickerGui2;

sliderHandle=handles.sliderCurrImg;

set(sliderHandle,'Min',1);
set(sliderHandle,'Value',1);
set(sliderHandle,'Max',nrImg);
if (nrImg==1)
    sliderStep=[0 0];
    set(sliderHandle,'Visible','off');
else
    sliderStep = [1, 1] ./(nrImg - 1);
    set(sliderHandle,'Visible','on');
end;

set(sliderHandle,'SliderStep',sliderStep);
set(handles.text_fileBrInfo,'String',[num2str(1) ' of ' num2str(nrImg) ]);
tmpImgNames=pickList.keys;
for i=1:length(tmpImgNames)
    [imgPath{i},imgName{i}]=fileparts(tmpImgNames{i});
end;
set(handles.pop_fileBrFileName,'String',imgName);
set(handles.pop_fileBrPath,'String',imgPath);

function overloadMouseButtons()

global storage_particlepickerGui2

% set function to call on mouse click
set(storage_particlepickerGui2.handles.figure1, 'WindowButtonDownFcn', @clicker);
 set(storage_particlepickerGui2.handles.figure1,'Pointer','crosshair');

function clicker(h,~)

[point,buttonUsed]=getMouseInput(h);

if (isempty(point))
    return;
end;
  
if (strcmp(buttonUsed,'left'))
    addPointToPickList(point);
    renderPoints(point(1),point(2)); %change interface
    particle=boxParticle(point);
    addParticleToParticleStack(particle);
    alignAndAverageParticle(particle);
    renderAlignmentPanel(); 
end;

if (strcmp(buttonUsed,'right'))
    removedPointId=removePointFromPickList(point);
    renderPoints('','','redraw');
    removedParticle=removeParticleFromParticleStack(removedPointId);
    alignAndSubtractParticle(removedPointId,removedParticle);
    setActParticleToEnd();
    renderAlignmentPanel();
end;


function partalg=alignAndAverageParticle(particle)


global storage_particlepickerGui2;
handles=storage_particlepickerGui2.handles;
alignParticleFlag=get(handles.chk_alignParticle,'Value');
demoMode=get(handles.chk_demo,'Value');

if (demoMode==1)
    rotTransIter=1;
else
    rotTransIter=3;
end;

if (alignParticleFlag==0)
    return;
end;

if (isempty(storage_particlepickerGui2.partStack.avg)==0)
    [mask,mask_cc_rot,mask_cc_trans]=genMasks();
    ref=filterImg(storage_particlepickerGui2.partStack.avg);
    [angle,shift,~,partalg]=tom_av2_align(ref,particle,mask,mask_cc_rot,mask_cc_trans,'',rotTransIter,demoMode);
    half=addPartToAvg(partalg);
    addAlgParamToList([angle(1) shift(1:2)' half]);
    calcRes();
else
    partalg=particle;
    half=addPartToAvg(partalg);
    addAlgParamToList([0 0 0 half]);
end;
storage_particlepickerGui2.partStack.currPartAlg=partalg;
    

function half=addPartToAvg(partalg)


global storage_particlepickerGui2;

if (isempty(storage_particlepickerGui2.partStack.avg))
    storage_particlepickerGui2.partStack.avg=partalg;
else
    storage_particlepickerGui2.partStack.avg=storage_particlepickerGui2.partStack.avg+partalg;
end;
    
if (storage_particlepickerGui2.pickList.totalCountHalf1 ==storage_particlepickerGui2.pickList.totalCountHalf2)
    if (isempty(storage_particlepickerGui2.partStack.avgH1))
        storage_particlepickerGui2.partStack.avgH1=partalg;
    else
        storage_particlepickerGui2.partStack.avgH1=storage_particlepickerGui2.partStack.avgH1+partalg;
    end;
    storage_particlepickerGui2.pickList.totalCountHalf1 =storage_particlepickerGui2.pickList.totalCountHalf1+1;
    half=1;
else
     if (isempty(storage_particlepickerGui2.partStack.avgH2))
        storage_particlepickerGui2.partStack.avgH2=partalg;
    else
        storage_particlepickerGui2.partStack.avgH2=storage_particlepickerGui2.partStack.avgH2+partalg;
    end;
    storage_particlepickerGui2.pickList.totalCountHalf2 =storage_particlepickerGui2.pickList.totalCountHalf2+1;
    half=2;
end;



function alignAndSubtractParticle(removedPartId,removedParticle)

global storage_particlepickerGui2;

handles=storage_particlepickerGui2.handles;
showParticleChk=get(handles.chk_showParticle,'Value'); 
algParticleChk=get(handles.chk_alignParticle,'Value');
if (showParticleChk==0 || algParticleChk==0)
    return;
end;

algParamRemoved=removeAlgParameterFromAlgList(removedPartId);
if (isempty(algParamRemoved))
    return;
end;
removedParticleAlg=alignParticlebyParam(removedParticle,algParamRemoved);
subtractParticle(removedParticleAlg,algParamRemoved(4));
calcRes();


function setActParticleToEnd()

global storage_particlepickerGui2;

partSt=storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name);

if (isempty(partSt) || isfield(partSt,'partStack')==0)
    return;
end;


if (isempty(partSt.partStack))
    storage_particlepickerGui2.partStack.currPart=[];
    storage_particlepickerGui2.partStack.currPartAlg=[];
else
    part=partSt.partStack(:,:,end);
    storage_particlepickerGui2.partStack.currPart=part;
    if (isfield(partSt,'algParam')==0)
        return;
    end;  
    algParam= partSt.algParam(end,:);
    partAlg=alignParticlebyParam(part,algParam);
    storage_particlepickerGui2.partStack.currPartAlg=partAlg;
end;

function subtractParticle(partalg,halfId)

global storage_particlepickerGui2;

if (storage_particlepickerGui2.pickList.totalCount>0)
    if (isempty(storage_particlepickerGui2.partStack.avg))
        return;
    else
        storage_particlepickerGui2.partStack.avg=storage_particlepickerGui2.partStack.avg-partalg;
    end;
else
    storage_particlepickerGui2.partStack.avg=[];
    storage_particlepickerGui2.partStack.avgH1=[];
    storage_particlepickerGui2.pickList.totalCountHalf1=0;
    storage_particlepickerGui2.partStack.avgH2=[];
    storage_particlepickerGui2.pickList.totalCountHalf2=0;
    return;
end;

if (halfId==1)
    if (isempty(storage_particlepickerGui2.partStack.avgH1))
        return;
    else
        storage_particlepickerGui2.partStack.avgH1=storage_particlepickerGui2.partStack.avgH1-partalg;
        storage_particlepickerGui2.pickList.totalCountHalf1 =storage_particlepickerGui2.pickList.totalCountHalf1-1;
    end;
end
if (halfId==2)
    if (isempty(storage_particlepickerGui2.partStack.avgH2))
        return;
    else
        storage_particlepickerGui2.partStack.avgH2=storage_particlepickerGui2.partStack.avgH2-partalg;
        storage_particlepickerGui2.pickList.totalCountHalf2 =storage_particlepickerGui2.pickList.totalCountHalf2-1;
    end;
end;



function imgFilt=filterImg(img)

global storage_particlepickerGui2;
handles=storage_particlepickerGui2.handles;


fType=get(handles.pop_refineFiltType,'String');
fType=fType{get(handles.pop_refineFiltType,'Value')};
fparam1=str2double(get(handles.edit_refineFiterParam1,'String'));
fparam2=str2double(get(handles.edit_refineFiterParam2,'String'));
pixS=str2double(get(handles.edit_pixS,'String'));


if (strcmp(fType,'const-lowpas'))
    imgFilt=tom_filter2resolution(img,pixS,fparam1);
    return;
end;

if (isempty(storage_particlepickerGui2.partStack.fscFilt))
    imgFilt=tom_filter2resolution(img,pixS,60);
else
    imgFilt=tom_apply_weight_function(img,storage_particlepickerGui2.partStack.fscFilt);
end;







function [res,filt,fsc]=calcRes()
 
global storage_particlepickerGui2;    

handles=storage_particlepickerGui2.handles;

fType=get(handles.pop_refineFiltType,'String');
fType=fType{get(handles.pop_refineFiltType,'Value')};
fparam1=str2double(get(handles.edit_refineFiterParam1,'String'));
fparam2=str2double(get(handles.edit_refineFiterParam2,'String'));
pixS=str2double(get(handles.edit_pixS,'String'));

h1=storage_particlepickerGui2.partStack.avgH1;
h2=storage_particlepickerGui2.partStack.avgH2;

if (storage_particlepickerGui2.pickList.totalCount<2)
    storage_particlepickerGui2.partStack.fscFun=[];
    storage_particlepickerGui2.partStack.fscFilt=[];
    return;
end;

if (isempty(h1) || isempty(h2))
     storage_particlepickerGui2.partStack.fscFilt=[];
     storage_particlepickerGui2.partStack.fscFun=[];
else
    if (strcmp(fType,'adapt. sqrt(fsc) non GS '))
        [~,~,~,maskFsc]=genMasks();
        [fsc,f,v05,v03,v14]=tom_fsc(h1.*maskFsc,h2.*maskFsc,round(size(h1,1)./2),pixS);
        for i=1:length(fsc)
            if (fsc(i)<0.01)
                break;
            end;
        end;
        fsc(i:end)=0;
        fscOrg=fsc;
        fsc=((2*fsc)./(fsc+1)).^0.75 ;
        
        res=v05;
        szp=size(tom_cart2polar(h1));
        tmpW=repmat(fsc,szp(2),1)';
        filt=tom_polar2cart(tmpW);
        clear('fsc');
        fsc(:,2)=fscOrg;
        fsc(:,1)=f;
        
        storage_particlepickerGui2.partStack.fscFilt=filt;
        storage_particlepickerGui2.partStack.fscFun=fsc;
    end;
    
end;


function stackIdx=pointIdxToStackIdx(pointIdx)

global storage_particlepickerGui2;

currImgNum=get(storage_particlepickerGui2.handles.sliderCurrImg,'Value');

ll=storage_particlepickerGui2.pickList.list.keys;
offSet=0;
for i=1:currImgNum-1
    offSet=offSet+size(storage_particlepickerGui2.pickList.list(ll{i}),1);
end;
stackIdx=pointIdx+offSet;

function idxNeighbour=removePointFromPickList(point)

global storage_particlepickerGui2;

idxNeighbour=getNearestPoint(point(1),point(2));

all_pointTmp=storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name);

all_point(1:(idxNeighbour-1),:)=all_pointTmp(1:(idxNeighbour-1),:);
all_point=cat(1,all_point,all_pointTmp(idxNeighbour+1:end,:));
storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name)=all_point;

storage_particlepickerGui2.pickList.totalCount=storage_particlepickerGui2.pickList.totalCount-1;
storage_particlepickerGui2.pickList.currImgCount=storage_particlepickerGui2.pickList.currImgCount-1;






function removedParticle=removeParticleFromParticleStack(idxNeighbour)

global storage_particlepickerGui2;

handles=storage_particlepickerGui2.handles;
showParticle=get(handles.chk_showParticle,'Value'); 

if (showParticle==0)
    removedParticle=[];
    return;
end;

partSt=storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name);
all_partTmp=partSt.partStack;
removedParticle=all_partTmp(:,:,idxNeighbour);

if (size(all_partTmp,3)>1)
    all_part=all_partTmp(:,:,1:(idxNeighbour-1));
    all_part=cat(3,all_part,all_partTmp(:,:,idxNeighbour+1:end,:));
    partSt.partStack=all_part;
end;

if (size(all_partTmp,3)==1)
    partSt.partStack=[];
end;


storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name)=partSt;



function algParamRemoved=removeAlgParameterFromAlgList(idxNeighbour,removedPart,lastPart)


global storage_particlepickerGui2;

partSt=storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name);

if (isfield(partSt,'algParam')==0)
    algParamRemoved=[];
    return;
end;

all_paramTmp=partSt.algParam;

if (size(all_paramTmp,1)>1)
    all_param=all_paramTmp(1:(idxNeighbour-1),:);
    all_param=cat(1,all_param,all_paramTmp(idxNeighbour+1:end,:));
end;

if (size(all_paramTmp,1)==1)
    all_param=[];
end;
    
partSt.algParam=all_param;
storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name)=partSt;

algParamRemoved=all_paramTmp(idxNeighbour,:);



function algParticle=alignParticlebyParam(particle,algParam)

if (isempty(algParam))
    algParticle=[];
    return;
end;

algParticle=tom_shift(tom_rotate(particle,algParam(1)),algParam(2:3));


function [idx]=getNearestPoint(pointx,pointy)

global storage_particlepickerGui2

all_point=storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name);

idx=tom_nearestpoint([pointx pointy],all_point);






function [mask,mask_cc_rot,mask_cc_trans,mask4fsc]=genMasks()

global storage_particlepickerGui2;

radius=str2num(get(storage_particlepickerGui2.handles.edit_pickRad,'String'));

if (isempty(storage_particlepickerGui2.maskCache))
    partSz=[radius radius].*2;
    tmpGr=ones(partSz);
    mask=tom_spheremask(tmpGr,radius-3,3);
    mask_cc_rot=ones(size(tom_cart2polar(tmpGr)));
    mask_cc_trans=tom_spheremask(tmpGr,(radius.*0.5),radius.*0.1);
    mask4fsc=tom_spheremask(tmpGr,(radius)-8,5);
    storage_particlepickerGui2.maskCache.mask=mask;
    storage_particlepickerGui2.maskCache.mask_cc_rot=mask_cc_rot;
    storage_particlepickerGui2.maskCache.mask_cc_trans=mask_cc_trans;
    storage_particlepickerGui2.maskCache.mask4fsc=mask4fsc;
else
    mask=storage_particlepickerGui2.maskCache.mask;
    mask_cc_rot=storage_particlepickerGui2.maskCache.mask_cc_rot;
    mask_cc_trans=storage_particlepickerGui2.maskCache.mask_cc_trans;
    mask4fsc=storage_particlepickerGui2.maskCache.mask4fsc;
end;


function normalizeButtons(handles,normaLizeButtonsAndFont)

if (normaLizeButtonsAndFont)
    hFig=handles.figure1;
    hAxes = findall(hFig,'type','axes');
    hText = findall(hAxes,'type','text');
    hUIControls = findall(gcf,'type','uicontrol');
    set([hAxes; hText;hUIControls],'units','normalized','fontunits','normalized');
end;


function [point,buttonUsed]=getMouseInput(h)

global storage_particlepickerGui2;

imgHandle=storage_particlepickerGui2.handles.axesCurrImg;
imgSz=storage_particlepickerGui2.currImg.sz;
if (isempty(imgSz))
    point='';
    buttonUsed='';
    return;
end;

buttonUsed='left';

point=get(imgHandle,'currentpoint');
point=point(1,1:2);
point=correctPointCoordinates(point,imgSz);
buttonUsedTmp=get(h, 'selectiontype');

if (strcmp(buttonUsedTmp,'normal'))
    buttonUsed='left';
end;

if (strcmp(buttonUsedTmp,'alt'))
    buttonUsed='right';
end;

if (strcmp(buttonUsedTmp,'extend'))
    buttonUsed='middle';
end;




function addPointToPickList(point)

global storage_particlepickerGui2

all_point=storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name);
all_point=cat(1,all_point,point);
storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name)=all_point;

storage_particlepickerGui2.pickList.totalCount=storage_particlepickerGui2.pickList.totalCount+1;
storage_particlepickerGui2.pickList.currImgCount=size(all_point,1);

function addAlgParamToList(param)

global storage_particlepickerGui2

all_partSt=storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name);
if (isfield(all_partSt,'algParam'))
    all_param=all_partSt.algParam; 
else
    all_param=[];
end;
all_param=cat(1,all_param,param);

all_partSt.algParam=all_param;
storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name)=all_partSt;



function addParticleToParticleStack(particle)


if (isempty(particle))
    return;
end;

global storage_particlepickerGui2

all_partSt=storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name);
if (isempty(all_partSt))
    all_part=[];
else
    all_part=all_partSt.partStack;
end;
all_part=cat(3,all_part,particle);

all_partSt.partStack=all_part;
storage_particlepickerGui2.partStack.list(storage_particlepickerGui2.currImg.name)=all_partSt;



function point=correctPointCoordinates(point,sz)

maxDiff=10;

if (point(1)<-maxDiff) || (point(1) >(sz(1)+maxDiff))
    point=[];
    return;
end;

if (point(2)<-maxDiff )|| (point(2) >(sz(2)+maxDiff))
    point=[];
    return;
end;

if (point(1)<1)
    point(1)=1;
end;

if (point(2)<1 )
    point(2)=1;
end;

if (point(1)>sz(1))
    point(1)=sz(1);
end;

if (point(2)>sz(2))
    point(2)=sz(2);
end;



function [particle,part_sz]=boxParticle(point)

normFlag='mean0+1std';
rad_fact=1;

global storage_particlepickerGui2;

handles=storage_particlepickerGui2.handles;
showParticle=get(handles.chk_showParticle,'Value'); %to be removed

if (showParticle==0)
    particle=[];
    part_sz=[];
    return;
end;

radius=str2num(get(handles.edit_pickRad,'String'));
img=storage_particlepickerGui2.currImg.val;


x=point(1);
y=point(2);

part_sz=[(radius).*2 (radius).*2];

[inside_flag,start_cut,size_cut,dir_flag]=check_cutout(x,y,radius,size(img));

%cut out particle
try
    particle = tom_cut_out(img,start_cut,size_cut+1);
    if (size(particle,1) > (radius*2))
        particle=particle(1:radius*rad_fact*2,:);
    end;
    if (size(particle,2) > (radius*2))
        particle=particle(:,1:radius*rad_fact*2);
    end;
    
catch Me
    disp(Me);
    warning('could not cut particle');
end;
particle = single(particle);

if (sum(size(particle)==((round(radius*rad_fact)*2)))~=2)
    try
        particle=tom_taper2(particle,[part_sz(1) part_sz(2)],dir_flag);
    catch
        disp(['warning cannot taper ' num2str(part_sz)])
    end;
end;

if (isempty(normFlag)==0)
    particle=tom_norm(particle,normFlag);
end;

storage_particlepickerGui2.partStack.currPart=particle;

function initStorage(handles,pickList,stackList,all_Img,nrPartsTot,nrPartsCurrIImg)

%globals used to be able to readout and Store picking pos from mouse 
%"as far as i know"  no chance to do it without !! 

global storage_particlepickerGui2

storage_particlepickerGui2=[];
storage_particlepickerGui2.pickList.list=pickList;
storage_particlepickerGui2.pickList.totalCount=nrPartsTot;
storage_particlepickerGui2.pickList.totalCountHalf1=0;
storage_particlepickerGui2.pickList.totalCountHalf2=0;
storage_particlepickerGui2.pickList.currImgCount=nrPartsCurrIImg;


storage_particlepickerGui2.currImg.name=all_Img{1};
storage_particlepickerGui2.currImg.sz=[];
storage_particlepickerGui2.currImg.val=[];

storage_particlepickerGui2.partStack.list=stackList;
storage_particlepickerGui2.partStack.avg=[];
storage_particlepickerGui2.partStack.avgH1=[];
storage_particlepickerGui2.partStack.avgH2=[];
storage_particlepickerGui2.partStack.fscFilt=[];
storage_particlepickerGui2.partStack.fscFun=[];
storage_particlepickerGui2.partStack.algParam=[];
storage_particlepickerGui2.partStack.currPart=[];
storage_particlepickerGui2.partStack.currPartAlg=[];

storage_particlepickerGui2.maskCache=[];
storage_particlepickerGui2.handles=handles;


function [inside_flag,start_cut,size_cut,dir_flag]=check_cutout(x,y,radius,imsize)

inside_flag=1;

rad_fact=1;

start_cut(1)=x-round(rad_fact*radius);
start_cut(2)=y-round(rad_fact*radius);
start_cut(3)=1;

size_cut(1)=2.*round(rad_fact*radius)-1;
size_cut(2)=2.*round(rad_fact*radius)-1;
size_cut(3)=0;

dir_flag=[0 0];

if (start_cut(1) < 1)
    inside_flag=0;
    size_cut(1)=size_cut(1)+start_cut(1);
    start_cut(1)=1;
    dir_flag(1)=-1;
end;

if (start_cut(2) < 1)
    inside_flag=0;
    size_cut(2)=size_cut(2)+start_cut(2);
    start_cut(2)=1;
    dir_flag(2)=-1;
end;

if (x+rad_fact*radius > imsize(1))
    inside_flag=0;
    size_cut(1)=round(rad_fact*radius)+(imsize(1)-x)-1;
    dir_flag(1)=1;
end;

if ((y+rad_fact*radius> imsize(2)) )
    inside_flag=0;
    size_cut(2)=round(rad_fact*radius)+(imsize(2)-y)-1;
    dir_flag(2)=1;
end;






function edit_filtParamMicrograph_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filtParamMicrograph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filtParamMicrograph as text
%        str2double(get(hObject,'String')) returns contents of edit_filtParamMicrograph as a double

renderImg;
renderAlignmentPanel;


% --- Executes during object creation, after setting all properties.
function edit_filtParamMicrograph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filtParamMicrograph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in chk_useFiltMicrograph.
function chk_useFiltMicrograph_Callback(hObject, eventdata, handles)
% hObject    handle to chk_useFiltMicrograph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_useFiltMicrograph

renderImg;
renderAlignmentPanel;

% --- Executes on button press in push_refineAlg.
function push_refineAlg_Callback(hObject, eventdata, handles)
% hObject    handle to push_refineAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global storage_particlepickerGui2

numIter=str2num(get(handles.edit_refineNumIter,'String'));
fType=get(handles.pop_refineFiltType,'String');
fType=fType{get(handles.pop_refineFiltType,'Value')};
fparam1=str2double(get(handles.edit_refineFiterParam1,'String'));
fparam2=str2double(get(handles.edit_refineFiterParam2,'String'));
pixS=str2double(get(handles.edit_pixS,'String'));
discard=str2double(get(handles.edit_refineDiscard,'String'))./100;


if (strcmp(fType,'const-lowpass'))
    fType=fparam1;
end;

if (strcmp(fType,'adapt. sqrt(fsc) non GS '))
    fType='2-halfsets';
end;

if (strcmp(fType,'adapt. sqrt(fsc) GS '))
    fType='goldStandard';
end;



mask=genMasks;


tmpStack=listToContStack(storage_particlepickerGui2.partStack.list);

ref=filterImg(storage_particlepickerGui2.partStack.avg);

[avg,stackAlg,algParam,allAvg,allRes,fscFilter,fscFun,avgHalfsUnf]=tom_os3_alignStack3(tmpStack,pixS,ref,discard,fType,'nyquist',mask,numIter);
storage_particlepickerGui2.partStack.avg=sum(stackAlg,3);
updatePartStackalgParam(storage_particlepickerGui2.partStack.list,algParam([1 2 3 6],:)');
storage_particlepickerGui2.partStack.fscFilt=fscFilter;
storage_particlepickerGui2.partStack.avgH1=avgHalfsUnf{1}.*size(stackAlg,3);
storage_particlepickerGui2.partStack.avgH2=avgHalfsUnf{2}.*size(stackAlg,3);
storage_particlepickerGui2.partStack.fscFun=fscFun;

renderAlignmentPanel;

function plotFsc(axes_fsc,fscFun)

if (isempty(fscFun))
    axes(axes_fsc); imagesc(ones(5,5));
else
    axes(axes_fsc); plot(fscFun(:,1),fscFun(:,2),'r-'); hold on; plot(fscFun(:,1),fscFun(:,2),'b+'); hold off;
end;
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])


function updatePartStackalgParam(list,algParam)

global storage_particlepickerGui2


allImg=list.keys;
zz=0;
for i=1:length(allImg)
    partStackPerImg=list(allImg{i});
    if (isempty(partStackPerImg)==0)
        if (isfield(partStackPerImg,'algParam'))
            for ii=1:size(partStackPerImg.algParam,1)
                zz=zz+1; 
                partStackPerImg.algParam(ii,:)=algParam(zz,:);
            end;
         end;
    end;
    list(allImg{i})=partStackPerImg;
end;



function stack=listToContStack(list)

allImg=list.keys;
stack=[];

for i=1:length(allImg)
    partStackPerImg=list(allImg{i});
    if (isempty(partStackPerImg)==0)
        if (isfield(partStackPerImg,'partStack'))
            stack=cat(3,stack,partStackPerImg.partStack);
        end;
    end;
end;



% --- Executes on button press in pushCenterAvg.
function pushCenterAvg_Callback(hObject, eventdata, handles)
% hObject    handle to pushCenterAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global storage_particlepickerGui2


ref=filterImg(storage_particlepickerGui2.partStack.avg);
storage_particlepickerGui2.partStack.avg=tom_av2_alignref(ref);
renderAlignmentPanel;



function edit_refineNumIter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_refineNumIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_refineNumIter as text
%        str2double(get(hObject,'String')) returns contents of edit_refineNumIter as a double


% --- Executes during object creation, after setting all properties.
function edit_refineNumIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_refineNumIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_refineFiterParam1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_refineFiterParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_refineFiterParam1 as text
%        str2double(get(hObject,'String')) returns contents of edit_refineFiterParam1 as a double


% --- Executes during object creation, after setting all properties.
function edit_refineFiterParam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_refineFiterParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_refineFiterParam2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_refineFiterParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_refineFiterParam2 as text
%        str2double(get(hObject,'String')) returns contents of edit_refineFiterParam2 as a double


% --- Executes during object creation, after setting all properties.
function edit_refineFiterParam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_refineFiterParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_refineFiltType.
function pop_refineFiltType_Callback(hObject, eventdata, handles)
% hObject    handle to pop_refineFiltType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_refineFiltType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_refineFiltType


% --- Executes during object creation, after setting all properties.
function pop_refineFiltType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_refineFiltType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filtParamAverage_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filtParamAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filtParamAverage as text
%        str2double(get(hObject,'String')) returns contents of edit_filtParamAverage as a double

renderAlignmentPanel;

% --- Executes during object creation, after setting all properties.
function edit_filtParamAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filtParamAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_useFiltAvg.
function chk_useFiltAvg_Callback(hObject, eventdata, handles)
% hObject    handle to chk_useFiltAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_useFiltAvg

renderAlignmentPanel;

% --- Executes on button press in chk_showMarks.
function chk_showMarks_Callback(hObject, eventdata, handles)
% hObject    handle to chk_showMarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_showMarks

renderImg(0);

% --- Executes on button press in chk_showParticle.
function chk_showParticle_Callback(hObject, eventdata, handles)
% hObject    handle to chk_showParticle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_showParticle


% --- Executes on button press in chk_alignParticle.
function chk_alignParticle_Callback(hObject, ~, handles)
% hObject    handle to chk_alignParticle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_alignParticle


% --- Executes on selection change in pop_pickClass.
function pop_pickClass_Callback(hObject, eventdata, handles)
% hObject    handle to pop_pickClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_pickClass contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_pickClass


% --- Executes during object creation, after setting all properties.
function pop_pickClass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_pickClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in popAddClass.
function popAddClass_Callback(hObject, eventdata, handles)
% hObject    handle to popAddClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_refineDiscard_Callback(hObject, eventdata, handles)
% hObject    handle to edit_refineDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_refineDiscard as text
%        str2double(get(hObject,'String')) returns contents of edit_refineDiscard as a double


% --- Executes during object creation, after setting all properties.
function edit_refineDiscard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_refineDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_inputFileLoad.
function push_inputFileLoad_Callback(hObject, eventdata, handles)
% hObject    handle to push_inputFileLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global storage_particlepickerGui2

inp=get(handles.edit_inputFileName,'String');

[pickList,stackList,nrTot,nrCurrImg]=readInput(inp,handles);
all_Img=pickList.keys;
initSlider(handles,length(all_Img),pickList);

 initStorage(handles,pickList,stackList,all_Img,nrTot,nrCurrImg);
% storage_particlepickerGui2.pickList.list=pickList;
% storage_particlepickerGui2.currImg.name=all_Img{1};

renderImg();


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_savePIckList.
function push_savePIckList_Callback(hObject, eventdata, handles)
% hObject    handle to push_savePIckList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

coordSuffix=get(handles.edit_output_coordSuffix,'String');
pickListType=get(handles.pop_outputType,'String');
pickListType=pickListType{get(handles.pop_outputType,'Value')};

radius=str2double(get(handles.edit_pickRad,'String'));

class=get(handles.pop_outputclass,'String');
classID=get(handles.pop_outputclass,'Value');
className=class{get(handles.pop_outputclass,'Value')};


global storage_particlepickerGui2;

listLinear=genLinearPickList(storage_particlepickerGui2.pickList.list);

pathInputList=fileparts(listLinear{1});

if (strcmp(pickListType,'relion-star files'))
    fold=uigetdir(pathInputList);
    writeAllRelionStarFiles(storage_particlepickerGui2.pickList.list,fold,coordSuffix);
end;

if (strcmp(pickListType,'eman-box files'))
    fold=uigetdir(pathInputList);
    writeAllEmanBoxFiles(storage_particlepickerGui2.pickList.list,fold,coordSuffix,radius.*2);
end;

if (strcmp(pickListType,'tom-pickList '))
    [fileName,filePath]=uiputfile('pickList.mat','*.mat');
    writeTomPickList(listLinear,[filePath filesep fileName],radius);
end;

function writeTomPickList(listLinear,fileName,radius)

for i=1:size(listLinear,1)
    align2d(1,i).dataset = '';
    align2d(1,i).filename =  listLinear{i,1};
    align2d(1,i).position.x =listLinear{i,2}(1);
    align2d(1,i).position.y = listLinear{i,2}(2);
    align2d(1,i).class = 'default';
    align2d(1,i).radius = radius;
    align2d(1,i).color = [0 1 0];
    align2d(1,i).shift.x = 0;
    align2d(1,i).shift.y = 0;
    align2d(1,i).angle = 0;
    align2d(1,i).isaligned = 0;
    align2d(1,i).ccc = 0;
    align2d(1,i).quality = 0;
    align2d(1,i).normed = 'none';
    align2d(1,i).ref_class = 0;
end
save(fileName,'align2d');


function writeAllEmanBoxFiles(list,fold,coordSuffix,boxSz)

funny=-1;

allImg=list.keys;

for i=1:length(allImg)
    [~,b]=fileparts(allImg{i});
    outputName=[fold filesep b coordSuffix];
    coords=list(allImg{i});
    writeEmanBoxFile(outputName,coords,boxSz)
end;

function writeEmanBoxFile(name,coords,boxSz)

if (isempty(coords))
    return;
end;

del=char(9);
off=round(boxSz/2);
fid=fopen(name,'wt');
for i=1:size(coords,1)
    fprintf(fid, '%d%s%d%s%d%s%d\n',round(coords(i,1)-off),del,round(coords(i,2)-off),del,boxSz,del,boxSz);
end;
fclose(fid);


function writeAllRelionStarFiles(list,fold,coordSuffix)

allImg=list.keys;


for i=1:length(allImg)
    [~,b]=fileparts(allImg{i});
    outputName=[fold filesep b coordSuffix];
    coords=list(allImg{i});
    writeRelionStarFile(outputName,coords);
end;



function writeRelionStarFile(name,coords)

if (isempty(coords))
    return;
end;

fid=fopen(name,'wt');
fprintf(fid,'\n');
fprintf(fid,'data_\n');
fprintf(fid,'\n');
fprintf(fid,'loop_\n'); 
fprintf(fid,'_rlnCoordinateX #1\n'); 
fprintf(fid,'_rlnCoordinateY #2\n');
for i=1:size(coords,1)
    fprintf(fid,' %f %f \n',coords(i,1),coords(i,2));
end;
fclose(fid);




function listLinear=genLinearPickList(listIndex)


allImg=listIndex.keys;

zz=0;
for i=1:length(allImg)
    coord=listIndex(allImg{i});   
    for ii=1:size(coord,1)
        zz=zz+1;
        listLinear{zz,1}=allImg{i};
        listLinear{zz,2}=coord(ii,1:2);
        %listLinear{i,3}=coord(3);
    end;
    
end;


% --- Executes on selection change in pop_fileBrFileName.
function pop_fileBrFileName_Callback(hObject, eventdata, handles)
% hObject    handle to pop_fileBrFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_fileBrFileName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_fileBrFileName

pos=get(handles. pop_fileBrFileName,'Value');
updateGuiNewImg(handles,pos);

% --- Executes during object creation, after setting all properties.
function pop_fileBrFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_fileBrFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_fileBrPath.
function pop_fileBrPath_Callback(hObject, eventdata, handles)
% hObject    handle to pop_fileBrPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_fileBrPath contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_fileBrPath

pos=get(handles.pop_fileBrPath,'Value');
updateGuiNewImg(handles,pos);

% --- Executes during object creation, after setting all properties.
function pop_fileBrPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_fileBrPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_outputclass.
function pop_outputclass_Callback(hObject, eventdata, handles)
% hObject    handle to pop_outputclass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_outputclass contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_outputclass


% --- Executes during object creation, after setting all properties.
function pop_outputclass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_outputclass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_fmicroRmOut.
function chk_fmicroRmOut_Callback(hObject, eventdata, handles)
% hObject    handle to chk_fmicroRmOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_fmicroRmOut


% --- Executes on selection change in pop_outputType.
function pop_outputType_Callback(hObject, eventdata, handles)
% hObject    handle to pop_outputType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_outputType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_outputType

val=get(handles.pop_outputType,'Value');

if (val==1)
    set(handles.edit_output_coordSuffix,'String','_manualpick.star');
     set(handles.edit_output_coordSuffix,'Enable','on');
end;

if (val==2)
    set(handles.edit_output_coordSuffix,'String','.box');
 set(handles.edit_output_coordSuffix,'Enable','on');
end;

if (val==3)
    set(handles.edit_output_coordSuffix,'String','');
    set(handles.edit_output_coordSuffix,'Enable','off');
end;

if (val==4)
    set(handles.edit_output_coordSuffix,'String','');
    set(handles.edit_output_coordSuffix,'Enable','off');
 end;
 

% --- Executes during object creation, after setting all properties.
function pop_outputType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_outputType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_deletePosOnCurrImg.
function push_deletePosOnCurrImg_Callback(hObject, eventdata, handles)
% hObject    handle to push_deletePosOnCurrImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global storage_particlepickerGui2;

allPointOnImg=storage_particlepickerGui2.pickList.list(storage_particlepickerGui2.currImg.name);

h = waitbar(0,'deleting Particles');
for i=1:size(allPointOnImg,1)
    
    point=allPointOnImg(i,:);
    removedPointId=removePointFromPickList(point);
    removedParticle=removeParticleFromParticleStack(removedPointId);
    alignAndSubtractParticle(removedPointId,removedParticle);
    waitbar(i./size(allPointOnImg,1),h);
end;
setActParticleToEnd();

renderImg;
renderAlignmentPanel;
renderPoints('','','update');
try
    close(h);
catch
end;

disp(' ');

% --- Executes on button press in push_deleteAllPos.
function push_deleteAllPos_Callback(hObject, eventdata, handles)
% hObject    handle to push_deleteAllPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global storage_particlepickerGui2;

asw=questdlg('delete all positions ?');
input=get(handles.edit_inputFileName,'String');

if (strcmp(asw,'Yes'))
    pickList=storage_particlepickerGui2.pickList.list;
    stackList=storage_particlepickerGui2.partStack.list;
    all_Img=pickList.keys;
    for i=1:length(all_Img)
        pickList(all_Img{i})=[];
        stackList(all_Img{i})=[];
    end;
    initStorage(handles,pickList,stackList,all_Img,0,0);
    renderImg;
    renderAlignmentPanel;
    renderPoints('','','update');
    return;
end;




% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listb_info.
function listb_info_Callback(hObject, eventdata, handles)
% hObject    handle to listb_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listb_info contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listb_info


% --- Executes during object creation, after setting all properties.
function listb_info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listb_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fmicroParam2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fmicroParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fmicroParam2 as text
%        str2double(get(hObject,'String')) returns contents of edit_fmicroParam2 as a double


% --- Executes during object creation, after setting all properties.
function edit_fmicroParam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fmicroParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fmicroParam1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fmicroParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fmicroParam1 as text
%        str2double(get(hObject,'String')) returns contents of edit_fmicroParam1 as a double

renderImg();
renderAlignmentPanel();

% --- Executes during object creation, after setting all properties.
function edit_fmicroParam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fmicroParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_fmicroType.
function pop_fmicroType_Callback(hObject, eventdata, handles)
% hObject    handle to pop_fmicroType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_fmicroType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_fmicroType

renderImg();


% --- Executes during object creation, after setting all properties.
function pop_fmicroType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_fmicroType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_useFiltAvg.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to chk_useFiltAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_useFiltAvg



function edit_fAvgParam2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fAvgParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fAvgParam2 as text
%        str2double(get(hObject,'String')) returns contents of edit_fAvgParam2 as a double


% --- Executes during object creation, after setting all properties.
function edit_fAvgParam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fAvgParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fAvgParam1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fAvgParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fAvgParam1 as text
%        str2double(get(hObject,'String')) returns contents of edit_fAvgParam1 as a double

renderAlignmentPanel;



% --- Executes during object creation, after setting all properties.
function edit_fAvgParam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fAvgParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_fAvgType.
function pop_fAvgType_Callback(hObject, eventdata, handles)
% hObject    handle to pop_fAvgType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_fAvgType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_fAvgType


renderAlignmentPanel;


% --- Executes during object creation, after setting all properties.
function pop_fAvgType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_fAvgType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fAvgbFactor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fAvgbFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fAvgbFactor as text
%        str2double(get(hObject,'String')) returns contents of edit_fAvgbFactor as a double


% --- Executes during object creation, after setting all properties.
function edit_fAvgbFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fAvgbFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9



function edit_output_coordSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_output_coordSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_output_coordSuffix as text
%        str2double(get(hObject,'String')) returns contents of edit_output_coordSuffix as a double


% --- Executes during object creation, after setting all properties.
function edit_output_coordSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_output_coordSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pickRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pickRad as text
%        str2double(get(hObject,'String')) returns contents of edit_pickRad as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pickRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in popConfMark.
function popConfMark_Callback(hObject, eventdata, handles)
% hObject    handle to popConfMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_partStack.
function push_partStack_Callback(hObject, eventdata, handles)
% hObject    handle to push_partStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 
global storage_particlepickerGui2;

tmpStack=listToContStack(storage_particlepickerGui2.partStack.list);
figure; tom_dspcub(tmpStack);



function edit_pixS_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pixS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pixS as text
%        str2double(get(hObject,'String')) returns contents of edit_pixS as a double


% --- Executes during object creation, after setting all properties.
function edit_pixS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pixS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_classifyStack.
function push_classifyStack_Callback(hObject, eventdata, handles)
% hObject    handle to push_classifyStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global storage_particlepickerGui2;



nrCl=inputdlg({'Enter number of classes'},'classify',1,{'4'});
nrCl=str2double(nrCl{1});
pixS=str2double(get(handles.edit_pixS,'String'));
mask=genMasks;


tmpStack=listToContStack(storage_particlepickerGui2.partStack.list);
avg=tom_filter(storage_particlepickerGui2.partStack.avg,3);
[allSt]=tom_os3_alignStack2(tmpStack,avg,'default',[0 0],'mean0+1std','',[1 3]);
clV=tom_pca_and_k_means(allSt,nrCl,[1 8],1);
for i=1:nrCl
    clStack(:,:,i)=tom_norm(tom_filter(sum(allSt(:,:,find(clV==i)),3),3),'mean0+1std');
end;
figure; tom_dspcub(clStack);

% --- Executes on button press in chk_demo.
function chk_demo_Callback(hObject, eventdata, handles)
% hObject    handle to chk_demo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_demo
