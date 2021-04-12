function over = isOver(x,y,pos)
%isOver Returns true if the coordinates fall within the object position.
%   OVER = isOver(X,Y,POS) calculates whether coordinate (X,Y) falls
%   inside the position rectangle defined by POS where POS = [XMIN YMIN
%   WIDTH HEIGHT].

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:50:26 $

  xmin = pos(1);
  xmax = pos(1) + pos(3);
  ymin = pos(2);
  ymax = pos(2) + pos(4);
  
  if (x >= xmin) && (x <= xmax) && ...
           (y >= ymin) && (y <= ymax)
      over = true;
  else
      over = false;
  end
  
end

