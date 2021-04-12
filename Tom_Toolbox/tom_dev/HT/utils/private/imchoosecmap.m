function hout = imchoosecmap(varargin)
%IMCHOOSECMAP Choose colormap dialog box.
%  HOUT = IMCHOOSECMAP(HCLIENTFIG, DYNAMIC_BEHAVIOR, HOBJ) displays a dialog box
%  where the user can select a colormap from a list of MATLAB colormap functions
%  or workspace variables, or enter a valid MATLAB expression.  The colormap is
%  applied to the figure with the handle HCLIENTFIG.
%
%  DYNAMIC_BEHAVIOR can be set to TRUE or FALSE to indicate whether the client
%  figure's colormap will be updates when a new list item is selected.  The
%  default DYNAMIC_BEHAVIOR value is TRUE.
%
%  HOBJ is a handle to a uicontrol.  When specified, the string property of HOBJ
%  will change to the selected colormap string instead of changing the
%  HCLIENTFIG's colormap.
%
%   Example
%   -------
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       imshow('cameraman.tif');
%       imchoosecmap(hFig);

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/06/04 21:11:16 $



[hClientFig,dynamic_behavior,hObj] = parse_inputs(varargin{:});

% if hObj is not passed in, we will update the figure's colormap
act_on_figure = isempty(hObj);
user_canceled = true;

hCMapFig = figure('Toolbar','none',...
    'Menubar','none',...
    'NumberTitle','off',...
    'IntegerHandle','off',...
    'Tag','imChooseCMap',...
    'Visible','off',...
    'HandleVisibility','callback',...
    'Name','Choose Colormap',...
    'WindowStyle','modal',...
    'Resize','off');


% needed extra room for the edit box
if act_on_figure
    extra_height = 35;
else
    extra_height = 0;
end

%Layout management
fig_height = 260+extra_height;
fig_width  = 250;
fig_size = [fig_width fig_height];
left_margin = 10;
right_margin = 10;
spacing = 5;
default_panel_width = fig_width - left_margin -right_margin;
button_size = [60 25];
b_type = 'none';

last_selected_value = 0;

% we will be inheriting the background color from the UIPANEL
% (it seems to use the correct native window color
bg_color = [];
buttons = [];
SUCCESS = true;
FAILURE = false;

set(hCMapFig,'Position',getCenteredClientPosition);

% Get workspace variables
if ~isdeployed
    workspace_vars = evalin('base','whos');
end

custom_bottom_margin = 185+extra_height;
custom_top_margin = 10;
hRadioButton = [];
hRadioPanel = createRadioPanel;

custom_top_margin = fig_height - custom_bottom_margin + spacing;
custom_bottom_margin = 40+extra_height;
display_panel(1) = createCMapFcnPanel;

if ~isdeployed
    display_panel(2) = createCMapVarPanel;
end

hEvalPanel = [];
% if we are acting on figure, then we create the edit box panel
if act_on_figure
    custom_top_margin = fig_height - custom_bottom_margin; + spacing;
    custom_bottom_margin = 15+extra_height;
    hEvalPanel = createEvalPanel;
    hObj = findobj(hEvalPanel,'Type','uicontrol','style','edit');
end

custom_top_margin = fig_height - custom_bottom_margin;
custom_bottom_margin = 10;
createButtonPanel;

hImage = [];
if act_on_figure
    original_colormap = get(hClientFig,'Colormap');
    hImage = imhandles(hClientFig);
    iptwindowalign(hClientFig,'right',hCMapFig,'left');
    iptwindowalign(hClientFig,'top',hCMapFig,'top');
else
    original_colormap = get(hObj,'String');
end

% make the first panel visible
set(display_panel(1),'Visible','on');
set(hRadioPanel,'Visible','on');
set(hEvalPanel,'Visible','on');

% make the dialog window visible
set(hCMapFig,'Visible','on');

set(hCMapFig,'DeleteFcn',@deleteFcn);
set(hCMapFig,'KeyPressFcn',@handleEnterOrEsc);

% return the handle to the dialog if the caller requests it
if nargout > 0
    hout = hCMapFig;
end

if ~isempty(hImage)
    reactToImageChangesInFig(hImage,@deleteFcn);
end


    %------------------------------------
    function [hClientFig,dynamic_behavior,hObj] = parse_inputs(varargin)

        % At least one input argument
        iptchecknargin(1, 3, nargin, mfilename);


        % client needs to be a figure
        hClientFig = varargin{1};
        dynamic_behavior = true;
        hObj = [];

        iptcheckhandle(hClientFig,{'figure'},mfilename,'HCLIENT',1);

        % by default the dynamic_behavior is turned ON.
        if nargin > 1
            dynamic_behavior = varargin{2};
            iptcheckinput(dynamic_behavior,{'logical'},{'scalar'},...
                mfilename,'DYNAMIC_BEHAVIOR',2);
        end

        if nargin > 2
            hObj = varargin{3};
            is_uicontrol = ishandle(hObj) && strcmp(get(hObj,'Type'),'uicontrol');

            if ~is_uicontrol
                eid = sprintf('Images:%s:invalidObject',mfilename);
                error(eid,'Expected HOBJ to be a uicontrol object.');
            end

        end

    end %parse_inputs

    %-------------------------------
    function deleteFcn(src,evt) %#ok<INUSD>

        if user_canceled
            if act_on_figure
                set(hClientFig,'Colormap',original_colormap);
            else
                set(hObj,'String',original_colormap);
            end

        end

        if ishandle(hCMapFig)
            delete(hCMapFig);
        end


    end %deleteFcn

    %-------------------------------
    function handleEnterOrEsc(src,evt) %#ok<INUSD>

        key_pressed = get(src,'CurrentKey');

        enter_or_esc = strcmpi(key_pressed,{'return','escape'});

        if ~any(enter_or_esc)
            return
        end

        if enter_or_esc(1) % Escape was pressed

            % pass OK button to the callback function
            doButtonPress(buttons(1),[]);

        else % Enter was pressed

            % pass cancel button to it's callback function
            doButtonPress(buttons(2),[]);

        end

    end %deleteFcn


    %-------------------------------
    function pos = getPanelPos
        % determine the panel position based on the current custom_bottom_margin
        % and the custom_top_margin

        height = fig_height - custom_bottom_margin - custom_top_margin;
        pos = [left_margin, custom_bottom_margin, default_panel_width, height];

    end %getPanelPos

    %---------------------------------
    function pos = getCenteredClientPosition
        % returns the position of the import dialog
        % centered on the client (figure)

        client_position = getpixelposition(hClientFig);
        lower_left_pos = client_position(1:2) + (fig_size * 0.5);
        pos = [lower_left_pos fig_size];

    end % getCenteredClientPosition



    %---------------------------------
    function radio_group = createRadioPanel

        panelPos = getPanelPos;
        radio_group = uibuttongroup('Parent',hCMapFig,...
            'Tag','radioPanel',...
            'Units','pixels',...
            'TitlePosition','lefttop',...
            'Title','Source',...
            'BorderType',b_type,...
            'Visible','off');

        set(radio_group,'Position',panelPos);

        bg_color = get(radio_group,'BackgroundColor');
        set(hCMapFig,'Color',bg_color);

        hRadioButton = zeros(1,2);

        hRadioButton(1) = uicontrol('parent',radio_group,...
            'Style','radiobutton',...
            'Units','pixels',...
            'Tag','cmapFcnRButton',...
            'BackgroundColor',bg_color,...
            'String','MATLAB colormap functions');

        hRadioButton(2) = uicontrol('parent',radio_group,...
            'Style','radiobutton',...
            'Units','pixels',...
            'Tag','cmapVarRButton',...
            'BackgroundColor',bg_color,...
            'String','Workspace variables');

        label_extent = get(hRadioButton(1),'Extent');

        if isdeployed
            set(hRadioButton(2),'Enable','off');
        end


        rbutton_width = label_extent(3) + 25;
        rbutton_height  = 20;
        rbutton_posX = right_margin;
        rbutton_posY = spacing;
        rbutton_position = [rbutton_posX, rbutton_posY, rbutton_width, rbutton_height];

        set(hRadioButton(2),'Position',rbutton_position);

        rbutton_posY = rbutton_posY + spacing + rbutton_height;
        rbutton_position = [rbutton_posX, rbutton_posY, rbutton_width, rbutton_height];
        set(hRadioButton(1),'Position',rbutton_position);

        set(radio_group,'SelectionChangeFcn',@showPanel);


    end %createRadioPanel


    %---------------------------------
    function showPanel(src,evt) %#ok<INUSL>
        % makes the panel associated with the selected radio button
        % visible

        % The evt.NewValue is the currently selected radio button in the
        % uibutton group.
        tag = get(evt.NewValue,'tag');
        panel_tag = strrep(tag,'RButton','Panel');
        selected_panel = findobj(display_panel,'Tag',panel_tag);

        set(display_panel(display_panel ~= selected_panel),'Visible','off');
        set(selected_panel,'Visible','on');

        getColormap;

    end

    %---------------------------------
    function hPanel = createCMapFcnPanel
        % This panel is for the list of MATLAB Colormap functions.
        panelPos = getPanelPos;

        hPanel = uipanel('parent',hCMapFig,...
            'Tag','cmapFcnPanel',...
            'Units','pixels',...
            'BorderType',b_type,...
            'Position',panelPos,...
            'Visible','off');


        hLabel = uicontrol('parent',hPanel,...
            'Style','text',...
            'Units','Pixels',...
            'String','Colormap functions:',...
            'BackgroundColor',bg_color,...
            'HorizontalAlignment','left');

        label_extent = get(hLabel,'Extent');
        label_height = label_extent(4);
        label_posX = left_margin;
        label_posY = panelPos(4) - spacing - label_height;
        label_position = [label_posX,label_posY,label_extent(3),label_height];

        set(hLabel,'Position',label_position);

        hList = uicontrol('parent',hPanel,...
            'Style','listbox',...
            'Value',1,...
            'BackgroundColor','white',...
            'Units','pixels',...
            'Tag','cmapFcnList');

        list_posX = left_margin;
        list_posY = 2*spacing;
        list_width = panelPos(3) - left_margin - right_margin;
        list_height = label_posY - 2*spacing;
        list_position = [list_posX,list_posY,list_width,list_height];

        set(hList,'Position',list_position);

        cmap_str = getColormapFcnList;
        set(hList,'String',cmap_str(:,1));

        set(hList,'Callback',@callGetColormap);

    end %createCMapFcnPanel

    %---------------------------------
    function hPanel = createCMapVarPanel
        % This panel is for the list of variables in the MATLAB workspace
        % that have size mx3.

        panelPos = getPanelPos;

        hPanel = uipanel('parent',hCMapFig,...
            'Tag','cmapVarPanel',...
            'Units','pixels',...
            'BorderType',b_type,...
            'Position',panelPos,...
            'Visible','off');

        setChildColorToMatchParent(hPanel,hCMapFig);

        hLabel = uicontrol('parent',hPanel,...
            'Style','text',...
            'Units','Pixels',...
            'String','Variables:',...
            'BackgroundColor',bg_color,...
            'HorizontalAlignment','left');

        label_extent = get(hLabel,'Extent');
        label_height = label_extent(4);
        label_posX = left_margin;
        label_posY = panelPos(4) - spacing - label_height;
        label_position = [label_posX,label_posY,label_extent(3),label_height];

        set(hLabel,'Position',label_position);

        hList = uicontrol('parent',hPanel,...
            'Style','listbox',...
            'Value',1,...
            'BackgroundColor','white',...
            'Units','pixels',...
            'Tag','cmapVarList');

        list_posX = left_margin;
        list_posY = 2*spacing;
        list_width = panelPos(3) - left_margin - right_margin;
        list_height = label_posY-2*spacing;
        list_position = [list_posX,list_posY,list_width,list_height];

        set(hList,'Position',list_position);
        set(hList,'Callback',@callGetColormap);

        varInd = filterWorkspaceVars(workspace_vars,'colormap');
        varList = {'', workspace_vars(varInd).name};
        set(hList,'String',varList);

    end %createCMapVarPanel


    %------------------------------------------------
    function hPanel = createEvalPanel

        % Creates the eval panel

        panelPos = getPanelPos;

        hPanel = uipanel('parent',hCMapFig,...
            'Units','Pixels',...
            'Tag','cmapEvalPanel',...
            'BorderType',b_type,...
            'Position',panelPos,...
            'Visible','off');


        hEvalLabel = uicontrol('parent',hPanel,...
            'Style','Text',...
            'String','Evaluate Colormap:',...
            'HorizontalAlignment','left',...
            'BackgroundColor',bg_color,...
            'Units','pixels');

        label_extent = get(hEvalLabel,'extent');
        posY = 0;
        label_position = [left_margin, posY, label_extent(3:4)];

        set(hEvalLabel,'Position',label_position);


        max_width = panelPos(3)-left_margin-right_margin-label_extent(3)-spacing;
        edit_width = min([panelPos(3)-label_extent(3)-left_margin*2,...
            max_width]);

        edit_pos = [left_margin + label_extent(3) + spacing,...
            posY,edit_width, 20];

        hEvalEdit = uicontrol('parent',hPanel,...
            'Style','edit',...
            'Tag','cmapEvalEdit',...
            'Units','pixels',...
            'HorizontalAlignment','left',...
            'Callback',@(varargin) getColormap,...
            'Position',edit_pos);

        if ~isdeployed
            set(hEvalEdit,'BackgroundColor','white',...
                'Enable','on');
        else
            set(hEvalEdit,'BackgroundColor',[0.8 0.8 0.8],...
                'Enable','off');
        end
    end % createEvalPanel

    %---------------------------------
    function createButtonPanel
        % This panel contains the OK, Cancel and apply buttons

        panelPos = getPanelPos;
        hButtonPanel = uipanel('parent',hCMapFig,...
            'Tag','buttonPanel',...
            'Units','pixels',...
            'Position',panelPos,...
            'BorderType',b_type);


        % add buttons
        button_strs_n_tags = {'OK', 'okButton';...
            'Cancel','cancelButton'};

        num_of_buttons = length(button_strs_n_tags);

        button_spacing = (panelPos(3)-(num_of_buttons * button_size(1)))/(num_of_buttons+1);
        posX = button_spacing;
        posY = 0;
        buttons = zeros(num_of_buttons,1);

        for n = 1:num_of_buttons
            buttons(n) = uicontrol('parent',hButtonPanel,...
                'Style','pushbutton',...
                'String',button_strs_n_tags{n,1},...
                'BackgroundColor',bg_color,...
                'Tag',button_strs_n_tags{n,2});


            set(buttons(n),'Position',[posX, posY, button_size]);
            set(buttons(n),'Callback',{@doButtonPress});
            posX = posX + button_size(1) + button_spacing;

        end

    end % createButtonPanel


    %------------------------------
    function callGetColormap(src,evt) %#ok<INUSD>

        ind = get(src,'Value');

        if isempty(ind)
            % There is no item in the list
            return
        end

        double_click = strcmp(get(hCMapFig, 'SelectionType'), 'open');
        clicked_same_list_item = ind ~= 1 && last_selected_value == ind;
        stat = getColormap;

        if double_click && clicked_same_list_item && stat
            user_canceled = false;
            close(hCMapFig);
        end

        last_selected_value = ind;

    end % callGetColormap

    %------------------------------
    function doButtonPress(src,evt) %#ok<INUSD>
        % callback function for the OK and Cancel buttons

        tag = get(src,'tag');

        switch tag
            case 'okButton'
                if getColormap
                    user_canceled = false;
                    close(hCMapFig);
                end

            case 'cancelButton'
                if act_on_figure
                    set(hClientFig,'Colormap',original_colormap);
                else
                    set(hObj,'String',original_colormap);
                end
                close(hCMapFig);

        end

    end %doButtonPress


    %------------------------------
    function status = getColormap

        status = SUCCESS;
        default_colormap_length = 256;

        % get the handle of the active panel i.e. the panel
        % that's associated with the selected radio button
        tag = get(get(hRadioPanel,'SelectedObject'),'tag');
        panel_tag = strrep(tag,'RButton','Panel');
        active_panel = findobj(display_panel,'Tag',panel_tag);

        % get the handle of the list box, its current value and string.
        hList = findobj(active_panel,'Type','uicontrol','Style','listbox');
        cmap_str = get(hList,'String');
        % removes trailing spaces from the string
        cmap_str = strtrim(cmap_str);

        selected_ind = get(hList,'Value');

        % store this value so that we can revert to it in case of an error.
        previous_selected_ind = selected_ind;

        % determine if it is the function list or the variable list
        is_function_list = strcmpi('cmapFcnRButton',tag);

        % determine who the caller objects are
        caller_type = get(gcbo,'type');

        is_caller_uicontrol = strcmp(caller_type,'uicontrol');

        is_caller_button = is_caller_uicontrol && ...
            strcmp(get(gcbo,'Style'),'pushbutton');

        is_caller_listbox = is_caller_uicontrol && ...
            strcmp(get(gcbo,'Style'),'listbox');

        is_caller_editbox = is_caller_uicontrol && ...
            strcmp(get(gcbo,'Style'),'edit');

        is_caller_figure = strcmpi(get(gcbo,'Type'),'figure');

        if is_caller_editbox || is_caller_button || is_caller_figure

            % if the buttons are pressed, we select the blank list item.
            str = get(hObj,'String');

            if ~isdeployed
                previous_selected_ind = selected_ind;
                selected_ind = 1;
            end
            selected_str = str;

        else %list box was the caller

            % if first item in the list was selected, set the figure
            % colormap to it's original colormap
            if selected_ind == 1
                set(hObj,'String','');
                setFigColormap(original_colormap);
                return;
            end

            % get the string from the list item
            if iscell(cmap_str)
                selected_str = cmap_str{selected_ind};
            else
                selected_str = cmap_str;
            end

            if is_function_list
                % we want to use a 256 element colormap by default
                % and this is what will get displayed
                selected_str = sprintf('%s(%d)',selected_str,...
                    default_colormap_length);
            end
        end

        set(hObj,'String',selected_str);

        if ~dynamic_behavior && is_caller_listbox
            return
        end

        % get the selected string and evaluate it.
        % EVALIN traps any errors if a third argument is passed and this argument
        % is evaluated.  Here we just return a string "errorOccurred".

        if ~isdeployed
            if isempty(selected_str)
                return;
            end
            cmap_out = evalin('base',sprintf('%s;',selected_str),'''errorOccurred''');

            if strcmpi(cmap_out,'errorOccurred')
                error_str = lasterr;
                errordlg(error_str,'Error setting colormap','modal');
                status = FAILURE;

                % selected whatever was previously selected in the list
                set(hList,'Value',previous_selected_ind);
                return
            end
            set(hList,'Value',selected_ind);

        else
            % In this case, the function_list is the only list

            % The list box is the only caller since the edit box
            % is disabled.
            cmap_fcn = getColormapFcnList(selected_ind,2);

            % if there was no selection and OK was clicked
            % cmap_fcn will be empty
            if isempty(cmap_fcn)
                cmap_out = original_colormap;
            else
                cmap_out = cmap_fcn(default_colormap_length);
            end

        end

        status = setFigColormap(cmap_out);

    end %getColormap

    %--------------------------------
    function stat = setFigColormap(new_cmap)

        stat = true;

        if act_on_figure
            % set the client colormap
            try
                iptcheckmap(new_cmap,'setFigColormap','new_cmap',1);
                set(hClientFig,'Colormap',new_cmap);
            catch
                error_str = 'Colormap must be an M-by-3 array of RGB color intensities';
                errordlg(error_str,'Error setting colormap','modal');
                stat = false;
                return
            end

        end

    end %setFigColormap


end %imchoosecmap

%---------------------------------------------------------
function cmap_strs_and_fcns = getColormapFcnList(varargin)

cmap_store = {'','';...
    'autumn',@autumn;...
    'bone',@bone;...
    'colorcube',@colorcube;...
    'cool',@cool;...
    'copper',@copper;...
    'flag',@flag;...
    'gray',@gray;...
    'hot',@hot;...
    'hsv',@hsv;...
    'jet',@jet;...
    'lines',@lines;...
    'pink',@pink;...
    'prism',@prism;...
    'spring',@spring;...
    'summer',@summer;...
    'white',@white;...
    'winter',@winter};

switch nargin
    case 0
        cmap_strs_and_fcns = cmap_store;
    case 2
        cmap_strs_and_fcns = cmap_store{varargin{:}};
end

end %getColormapFcnList
