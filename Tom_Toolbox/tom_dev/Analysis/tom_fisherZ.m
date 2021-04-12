function z=tom_fisherZ(r)
% TOM_FISCHERZ computs z transform of correaltion values r
%
%    z=tom_fisherZ(r)
%
% PARAMETERS
%   INPUT
%    r                  input correlation values r
%
%   OUTPUT
%    z                  z transform of r
% 
%
%EXAMPLE
%
%
%
%SEE ALSO
%
%   created by FF 03/30/04
%   updated by ...
%
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


r=r(:);
z=.5.*log((1+r)./(1-r));