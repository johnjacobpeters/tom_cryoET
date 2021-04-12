function manager = makeUIModeManager(makeDefaultModeCurrent)
%makeUIModeManager Mode manager for managing toolbar items, menu items, modes.
%   MANAGER = makeUIModeManager(makeDefaultModeCurrent) creates a mutually
%   exclusive mode manager and a default mode. MANAGER is a structure of function
%   handles that allows you to work with the mode manager..
%  
%   MANAGER.activateDefaultMode activates the default mode.
%
%   MANAGER.addMode(button,menuItem,makeThisModeCurrent) adds a mode to the mode
%   manager such that the button's 'State' property and the menuItem's 'Checked'
%   property stay in sync and when either is turned on, the corresponding mode
%   is activated by calling the function stored in the function handle
%   makeThisModeCurrent. When either the menu item or the toolbar button is
%   turned off, makeDefaultModeCurrent is called.
%
%   See also makeExclusiveModeManager, 
  
%   Copyright 2005 The MathWorks, Inc.  
%   $Revision $  $Date $
  
  modeManager = makeExclusiveModeManager;
  
  activateDefaultMode = modeManager.addMode(makeDefaultModeCurrent,...
                                            identityFcn);

  manager.activateDefaultMode = activateDefaultMode;
  manager.addMode             = @addMode;

  %-------------------------------------------------        
  function activateMode = addMode(button,menuItem,makeThisModeCurrent)

    mode = makeModeFcns(button,menuItem,makeThisModeCurrent);
    activateMode = modeManager.addMode(mode.turnOnMode,...
                                       mode.turnOffMode);
    set(button,'ClickedCallback',@toggleMode)
    set(menuItem,'Callback',@toggleMode)
    
      %------------------------------------
      function toggleMode(varargin) %#ok varargin needed by HG caller

        src = varargin{1};
        srcType = get(src,'Type');
        if strcmp(srcType,'uimenu')
          % If you just clicked on a menu item, it has the 'Checked' 
          % status from previously.
          selectedProperty = 'Checked';
          currentlyOn = strcmp(get(src,selectedProperty),'on');          
          turnOnThisMode = ~currentlyOn;
        else
          % If you just clicked on a toggle button, 
          % it already has the 'State' updated.
          selectedProperty = 'State';
          currentlyOn = strcmp(get(src,selectedProperty),'on');
          turnOnThisMode = currentlyOn;
        end
          
        if turnOnThisMode
          % turn on
          activateMode();         %#ok need parentheses to call function handle
        else 
          % turn off
          activateDefaultMode();  %#ok need parentheses to call function handle
        end
         
      end

  end % setUpMode

  %-------------------------------------------------        
  function f = makeModeFcns(button,menuItem,makeThisModeCurrent)
   
    f.turnOnMode  = @turnOnMode;
    f.turnOffMode = @turnOffMode;    

    %-------------------    
    function turnOnMode
    
      toggleOffToOn(button,'State')
      toggleOffToOn(menuItem,'Checked')

      makeThisModeCurrent();
    
    end
  
    %-------------------
    function turnOffMode

      toggleOnToOff(button,'State')
      toggleOnToOff(menuItem,'Checked')      

      makeDefaultModeCurrent()
    
      end
    
  end

end

%--------------------------------
function  toggleOffToOn(src,prop)

  if strcmp(get(src,prop),'off')
    set(src,prop,'on')  
  end

end

%--------------------------------
function  toggleOnToOff(src,prop)

  if strcmp(get(src,prop),'on')
    set(src,prop,'off')  
  end

end