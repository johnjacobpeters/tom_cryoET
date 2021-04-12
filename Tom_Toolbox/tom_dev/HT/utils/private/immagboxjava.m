function [cb, cb_api] = immagboxjava
%IMMAGBOXJAVA Create magnification combo box for scrollpanel.
%   This function is not documented and may be removed in a future release.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2006/12/10 20:03:37 $

%   [CB,CB_API] = IMMAGBOXJAVA creates a disabled magnification combo box that
%   is not yet associated with a scrollpanel. To associate it with a
%   scrollpanel, use CB_API.setScrollpanel(sp_api).

cb_api.setMag = @setMag;
cb_api.setScrollpanel = @setScrollpanel;

import com.mathworks.toolbox.images.MagnificationComboBox;
cb = awtcreate('com.mathworks.toolbox.images.MagnificationComboBox');

awtinvoke(cb,'setEnabled(Z)',true);

% initialize for function scope
sp_api = [];
cb_listeners = {};

    %---------------------------------------
    function setScrollpanel(scrollpanel_api)
        % Hook so that the mag combo box can be attached to a scrollpanel after
        % creation.
        sp_api = scrollpanel_api;

        % have to call cbSetMag twice to force initialization of magnification
        % box.
        cbSetMag(sp_api.getMagnification()) % initialize mag
        cbSetMag(sp_api.getMagnification()) % initialize mag

        awtinvoke(cb,'setEnabled(Z)',true);
        
        cb_listeners{end+1} = handle.listener(handle(cb),...
            'ActionPerformed',@reactToEditBoxChange); %#ok
        
        cb_listeners{end+1} = handle.listener(handle(cb),...
            'PopupMenuWillBecomeInvisible',@updateMag); %#ok      
        % %#ok because the listeners must persist beyond the scope of this
        % function. Even tho we don't access the list directly, it is used.
        
        hTextEditor = handle(cb.getEditor().getEditorComponent());
        cb_listeners{end+1} = handle.listener(hTextEditor, 'FocusLost',...
            @refreshMag); 
        
        sp_api.addNewMagnificationCallback(@setMag);

    end

    %---------------------------
    % Callback for Focus Lost Event 
    % restores textbox value to value in MagCB member variable
    function refreshMag(varargin) %#ok varargin needed for HG caller
        
       cbUpdateString;

    end

    %---------------------------
    function updateMag(varargin) %#ok varargin needed for HG caller

        index = cb.getSelectedIndex;

        if (index==0) % Fit-To-Window

            %workaround to geck 230808 (assertions from JIT)
            dummyVariable1 = sp_api;             %#ok workaround
            dummyVariable2 = sp_api.findFitMag;  %#ok workaround
            %end of workaround

            newMag = sp_api.findFitMag();
            cbSetMag(newMag)
            cbUpdateString;  % needed to convert to percentage string

        else
           % User  selected a percentage from the combo-box list
           oldMag = cb.getMag();
           newMag = cb.getSelectedMagnification();
           
           if (~isempty(oldMag) && ~isempty(newMag))
               if magPercentsDiffer(newMag, oldMag)
                   setMag(newMag)
               end
           end           
        end

        updateScrollpanel(newMag);

    end % updateMag

    %---------------------------------------
    function reactToEditBoxChange(src,event) %#ok src not needed

        if strcmp('comboBoxEdited',event.JavaEvent.getActionCommand()) 

            hTextEditor = handle(cb.getEditor().getEditorComponent());
            if (hTextEditor.hasFocus())  
                
                newMag = parseEditBox();
                updateScrollpanel(newMag) 
                
            end     % end  if has focus           
        end     % end if comboBoxEdited
    end     % end reactToEditBoxChange

    %---------------------------------------
    function newMag = parseEditBox(varargin) %#ok varargin needed for HG caller

        % get value of combobox member variable
        currentMag = cb.getMag();   
        % get value entered in textBox, as a fraction
        newMag = cb.findMagnification();   
        
        % make sure input data exists
        % if either field is empty, combobox state is suspect - don't call
        % it!
        if (~isempty(currentMag) && ~isempty(newMag))           
            if magPercentsDiffer(currentMag, newMag)
                % only update the value in the combobox if it's different
                cbSetMag(newMag)
            else
                % update the string for consistent formatting
                % maybe the % got deleted
                cbUpdateString();
            end
        end

    end

    %---------------------------------
    function updateScrollpanel(newMag)

        currentMag = sp_api.getMagnification();
        % make sure input data exists
        % if either field is empty, combobox state is suspect - don't call
        % it!        
        if (~isempty(currentMag) && ~isempty(newMag))
            % Only call setMagnification if the magnification changed.        
            if magPercentsDiffer(currentMag, newMag)
                sp_api.setMagnification(newMag);
            end
        end
        
        
    end

    %------------------------
    function cbSetMag(newMag)

        awtinvoke(cb,'setMag(D)',newMag);

    end

    %------------------------
    function cbUpdateString

        awtinvoke(cb,'updateString');

    end

    %----------------------
    function setMag(newMag)
    % Hook so this combo box can receive messages that it can act 
    % on in a thread safe way.

        iptcheckinput(newMag,{'numeric'},...
            {'real','scalar','nonempty','nonnan','finite',...
            'positive','nonsparse'},'setMag','newMag',1)

        cbSetMag(newMag)

    end

end
