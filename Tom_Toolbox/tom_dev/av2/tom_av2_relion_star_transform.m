function [starTrans]=tom_av2_relion_star_transform(starfile,angTrans,shiftTrans,transformedStarfileName)
%TOM_AV2_RELION_STAR_TRANSFORM transforms a starfile according to angle and
%shift
%
%  starTrans=tom_av2_relion_star_transform(starFile,angle,shift)
%  
%  
%
%PARAMETERS
%
%  INPUT
%   starfile                                    *.star filename or struct
%   angTrans                                 euler angle to rotate the particles from star file
%   shiftTrans                                shift to rotate the particles from star file
%   transformedStarfileName       filename for transformed *.star file  
%
%  OUTPUT
%    starTrans                             transformed starfile name
%
%EXAMPLE
%     
% 
% starTrans=tom_av2_relion_star_transform('myStar.star',[10 -12 30],[-1 7 12]);
%
%REFERENCES
%
%SEE ALSO
%   tom_av2_em_classify3d
%
%   created by FB 11/02/16
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

if (nargin<4)
    transformedStarfileName='';
end;

if (isstruct(starfile)==0)
    starfile=tom_starread(starfile);
end;

starTrans=starfile;

for i=1:length(starfile)
    angleOrgZyZ=[starfile(i).rlnAngleRot starfile(i).rlnAngleTilt starfile(i).rlnAnglePsi];
    [~,angleOrgZxZ]=tom_eulerconvert_xmipp(angleOrgZyZ(1),angleOrgZyZ(2),angleOrgZyZ(3));
    angleOrgZxZ=[-angleOrgZxZ(2) -angleOrgZxZ(1) -angleOrgZxZ(3)];
    shiftOrg=[starfile(i).rlnOriginX  starfile(i).rlnOriginY 0];
    
    %seq rot of angle from star File
    [newAngZxZ,orgShift]=tom_sum_rotation([angleOrgZxZ ; angTrans],[shiftOrg; 0 0 0]);
    newAngZxZ=[-newAngZxZ(2) -newAngZxZ(1) -newAngZxZ(3)];
    [~,newAngZyZ]=tom_eulerconvert_xmipp(newAngZxZ(1),newAngZxZ(2),newAngZxZ(3),'tom2xmipp');
    
    %rot of shift accordint to transform Angle
    shRot=tom_pointrotate(shiftTrans,newAngZxZ(1),newAngZxZ(2),newAngZxZ(3));
    
    %update StarFile
    starTrans(i).rlnAngleRot=newAngZyZ(1);
    starTrans(i).rlnAngleTilt=newAngZyZ(2);
    starTrans(i).rlnAnglePsi=newAngZyZ(3);
    starTrans(i).rlnOriginX=shRot(1) + orgShift(1);
    starTrans(i).rlnOriginY=shRot(2) + orgShift(2);
end;

if (isempty(transformedStarfileName)==0)
    tom_starwrite(transformedStarfileName,starTrans);
end;


