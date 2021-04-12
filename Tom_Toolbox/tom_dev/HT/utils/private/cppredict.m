function predicted = cppredict(pick,inputPoints,basePoints,predictBase,constrainInputPoint,constrainBasePoint)
%CPPREDICT Predict match for a new control point.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/10 20:03:34 $

% constrainInputPoint and constrainBasePoint are boundary constraint
% functions used to clip predicted points within the extent of the image
% base/input image boundaries.

nvalidpairs = size(inputPoints,1);

if nvalidpairs < 2
  % this is an assertion in case caller sends over too few pairs
  eid = sprintf('Images:%s:tooFewPairs',mfilename);                
  error(eid,'Too few pairs, no method for predicting points.');    

else
  % predict
  switch nvalidpairs
    case 2
      method = 'linear conformal';
    case 3
      method = 'affine';
    otherwise
      method = 'projective';
  end

    t = cp2tform(inputPoints,basePoints,method);

    xy = pick;
    if predictBase
      % predict base
      predicted = tformfwd(xy,t);
      predicted = constrainBasePoint(predicted);
    else
      % predict input
      predicted = tforminv(xy,t);
      predicted = constrainInputPoint(predicted);
    end
    
end
