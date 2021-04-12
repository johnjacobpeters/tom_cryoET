function over_scrollbars = isOverScrollbars(cpx,cpy,hScrollpanel)
%isOverScrollbars Returns true if over the scrollbars.
%   OVER = isOverScrollbars(X,Y,H_SCROLLPANEL) calculates whether coordinate
%   (X,Y) falls inside the scrollbars or corner frame of the scroll panel
%   H_SCROLLPANEL. 

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/05/24 03:33:14 $

  % Temporarily disable ResizeFcn to avoid recursion
  actualResizeFcn = get(hScrollpanel,'ResizeFcn');
  set(hScrollpanel,'ResizeFcn','')

  hSliders = findobj(hScrollpanel,'Type','Uicontrol','Style','slider');
  isVisible = @(h) strcmp( get(h,'Visible'), 'on');
  
  % Defining logical variable to pass to getpixelposition.  We want to call
  % getpixelposition recursively so that mouse position and slider/frame
  % positions are compared relative to figure.
  isRecursive = true;
  
  slider1_pos = getpixelposition(hSliders(1),isRecursive);
  over_slider1 = isVisible(hSliders(1)) && isOver(cpx,cpy,slider1_pos);
  
  slider2_pos = getpixelposition(hSliders(2),isRecursive);
  over_slider2 = isVisible(hSliders(2)) && isOver(cpx,cpy,slider2_pos);
  
  hFrame = findobj(hScrollpanel,'Type','Uicontrol','Style','frame');
  frame_pos = getpixelposition(hFrame,isRecursive);
  over_frame = isVisible(hFrame) && isOver(cpx,cpy,frame_pos);
      
  over_scrollbars = over_slider1 || over_slider2 || over_frame;

  % Restore ResizeFcn
  set(hScrollpanel,'ResizeFcn',actualResizeFcn)
  
end
