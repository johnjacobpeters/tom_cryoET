function largefonts(state)
% LARGEFONTS ON   Turn on large fonts
% LARGEFONTS OFF  Turn off large fonts
% LARGEFONTS      Toggle large fonts
% LARGEFONTS FS   Turn on large fonts, with font size FS.  

% Get largefonts preferences
FS = getpref('LargeFonts');
if isempty(FS)  % Create preferences if necessary
    setpref('LargeFonts','State','Off'); 
end;

% Parse input arguments
if nargin==0            % Toggle state
    state = lower(getpref('LargeFonts','State'));
    switch state
        case 'on'
            state = 'off';
        case 'off'
            state = 'on';
    end;
elseif ~isstr(state)  % Specified font size.  Turn on.
    FontSize = state;
    state = 'on';       % Turn on
else                    % Go to specified state
    state= lower(state);
end;

if ~exist('FontSize','var')
    FontSize = 35;      % Default size for large fonts
end;

%% Toggle font sizes
switch state
    case 'on'
        % Big-
        com.mathworks.services.FontPrefs.setCodeFont(java.awt.Font('Monospaced',java.awt.Font.BOLD,FontSize))
        com.mathworks.services.FontPrefs.setTextFont(java.awt.Font('SansSerif',java.awt.Font.BOLD,FontSize))
        setpref('LargeFonts','State','On');

      case 'off'
          % Small-
          com.mathworks.services.FontPrefs.setCodeFont(java.awt.Font('Monospaced',java.awt.Font.PLAIN,14))
          com.mathworks.services.FontPrefs.setTextFont(java.awt.Font('SansSerif',java.awt.Font.PLAIN,14))
          setpref('LargeFonts','State','Off');

end;
