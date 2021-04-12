function hout = imoverviewpanel(varargin)
%IMOVERVIEWPANEL Overview tool panel for image displayed in scroll panel.
%   HPANEL = IMOVERVIEWPANEL(HPARENT, HIMAGE) creates an Overview tool panel
%   associated with the image specified by the handle HIMAGE, called the target
%   image. HIMAGE must be contained in a scroll panel created by
%   IMSCROLLPANEL. HPARENT is a handle to the figure or uipanel object that will
%   contain the Overview tool panel. IMOVERVIEWPANEL returns HPANEL, a handle to
%   the Overview tool uipanel object.
%
%   The Overview tool is a navigation aid for images displayed in a scroll
%   panel. IMOVERVIEWPANEL creates the tool in a uipanel object that can be
%   embedded in a figure or uipanel object. The tool displays the target image
%   in its entirety, scaled to fit.  Over this scaled version of image, the tool
%   draws a rectangle, called the detail rectangle, that shows the portion of
%   the target image that is currently visible in the scroll panel. To view
%   portions of the image that are not currently visible in the scroll panel,
%   move the detail rectangle in the Overview tool.
%
%   Note 
%   ----
%   To create an Overview tool in a separate figure, use IMOVERVIEW.
%   
%   Example
%   -------
%
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('tissue.png'); 
%       hSP = imscrollpanel(hFig,hIm);
%       set(hSP,'Units','normalized',...
%               'Position',[0 .5 1 .5])
%
%       hOvPanel = imoverviewpanel(hFig,hIm);
%       set(hOvPanel,'Units','Normalized',...
%                    'Position',[0 0 1 .5])
%
%   See also IMOVERVIEW, IMRECT, IMSCROLLPANEL.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2006/11/08 17:49:24 $

   iptchecknargin(2, 2, nargin, mfilename);
   parent = varargin{1};
   himage = varargin{2};
   
   iptcheckhandle(parent,{'figure','uipanel','uicontainer'},mfilename,'HPARENT',1)
   iptcheckhandle(himage,{'image'},mfilename,'HIMAGE',2)
  
   hScrollpanel = checkimscrollpanel(himage,mfilename,'HIMAGE');
   apiScrollpanel = iptgetapi(hScrollpanel);
   
   hScrollpanelAx = findobj(hScrollpanel,'Type','Axes');
   
   hOverviewPanel = uipanel('Parent',parent,...
                            'BorderType','none',...
                            'DeleteFcn',@deleteOverview);

   hOverviewAx = createAxesFromTargetAxes(hScrollpanelAx,hOverviewPanel);
   hOverviewIm = createImageFromTargetImage(himage, hOverviewAx);
   
   hFig = ancestor(himage,'figure');
   hOverviewFig = ancestor(hOverviewIm, 'figure');
   if ndims(get(himage, 'CData')) == 2
       set(hOverviewFig, 'Colormap', get(hFig, 'Colormap'));
   end
   
   hDetailRect = imrect(hOverviewAx, ...
                       apiScrollpanel.getVisibleImageRect());
  
   % In extreme aspect ratio situations, the detail rect can be difficult to
   % drag.  This is because the rect's ButtonDownFcn is not getting called,
   % even though hittest thinks it should.  A workaround is to turn off
   % clipping on the HG objects that make up the detail rect.  See g229481.
   set(findobj(hDetailRect), 'Clipping', 'off');
   
   apiDetailRect = iptgetapi(hDetailRect);
   apiDetailRect.addNewPositionCallback(@detailDragged);
   apiDetailRect.setDragConstraintFcn(@constrainDetail);
   apiDetailRect.setResizable(false);

   linkAx = linkprop([hScrollpanelAx hOverviewAx],'CLim');

   set(hOverviewAx,...
       'Units','normalized',...
       'Position',[0 0 1 1]);

   apiScrollpanel.addNewLocationCallback(@updateDetail);
   
   setappdata(hOverviewPanel,'linkAxListener',linkAx)
   
   if (nargout==1)
       hout = hOverviewPanel;
   end

   %-------------------------------
   function detailDragged(varargin)

     if exist('apiDetailRect','var') % geck this to nested functions
         posDetail = apiDetailRect.getPosition();
         apiScrollpanel.setVisibleLocation(posDetail(1),posDetail(2));

         % force update, see: g295731, g301382, g303455
         %drawnow expose 
     end
     
   end

   %------------------------------------------
   function pos = constrainDetail(proposedPos)

     imModel = getimagemodel(hOverviewIm);
     pos = constrainRect(proposedPos, getImageWidth(imModel), ...
                         getImageHeight(imModel));
   end

   %------------------------------
   function updateDetail(varargin)

     newpos = apiScrollpanel.getVisibleImageRect();
     apiDetailRect.setPosition(newpos);

   end

  %---------------------------------
  function deleteOverview(src,event)
  
    clear scrollpanelListener
  
  end
  
end

%-----------------------------------------------------------------------
function haxes = createAxesFromTargetAxes(targetAxes,parent)
  
  struct         = getCommonAxesProperties;
      
  struct.Clim    = get(targetAxes,'Clim');
  struct.Parent  = parent;
  struct.Units   = get(targetAxes,'Units');
  struct.Visible = get(targetAxes,'Visible');
  struct.XLim    = get(targetAxes,'XLim');
  struct.YLim    = get(targetAxes,'YLim');

  haxes = axes(struct);
  
end
