function angDist=tom_angular_distance(euler1,euler2,conv)
%TOM_ANGULAR_DISTANCE calculates the angular distance between 2 rotations
%   angDist=tom_angular_distance(euler1,euler2,conv)
%
%PARAMETERS
%
%  INPUT
%   euler1           euler angle 1
%   euler2           euler angle 2
%   conv             ('zxz') convention 4 roation
%                            or zyz
%
%EXAMPLE
%   
%  distInZXZ=tom_angular_distance([91 162 272],[85 153 251]);
%  
%  %check 4 zyz
%  [~,euler1ZYZ]=tom_eulerconvert_xmipp(91,162,272,'tom2xmipp');
%  [~,euler2ZYZ]=tom_eulerconvert_xmipp(85,153,251,'tom2xmipp');
%  distInZYZ=tom_angular_distance(euler1ZYZ,euler2ZYZ,'zyz');
%  disp(' ')
%  disp(['Dist zxz: ' num2str(distInZXZ) ' Dist zyz: ' num2str(distInZYZ) ]);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by SN/FB 01/24/06
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


%parse inputs
if (nargin<3)
    conv='zxz';
end;


if (strcmp(conv,'zyz'))
    [~,euler1]=tom_eulerconvert_xmipp(euler1(1),euler1(2),euler1(3));
    [~,euler2]=tom_eulerconvert_xmipp(euler2(1),euler2(2),euler2(3));
end;


[~,~,M1]=tom_sum_rotation(euler1,[0 0 0]);
[~,~,M2]=tom_sum_rotation(euler2,[0 0 0]);


Mrest=M1\M2; %equal to mult with inv(M)

Qrest=qGetQInt(Mrest);

angDist=acosd(Qrest(1)).*2;

if (angDist>180)
    angDist=360-angDist;
end;

if (angDist<-180)
    angDist=360+angDist;
end;



function Q = qGetQInt( R )
% qGetQ: converts 3x3 rotation matrix into equivalent quaternion
% Q = qGetQ( R );

[r,c] = size( R );
if( r ~= 3 | c ~= 3 )
    fprintf( 'R must be a 3x3 matrix\n\r' );
    return;
end

% [ Rxx, Rxy, Rxz ] = R(1,1:3); 
% [ Ryx, Ryy, Ryz ] = R(2,1:3);
% [ Rzx, Rzy, Rzz ] = R(3,1:3);

Rxx = R(1,1); Rxy = R(1,2); Rxz = R(1,3);
Ryx = R(2,1); Ryy = R(2,2); Ryz = R(2,3);
Rzx = R(3,1); Rzy = R(3,2); Rzz = R(3,3);

w = sqrt( trace( R ) + 1 ) / 2;

% check if w is real. Otherwise, zero it.
if( imag( w ) > 0 )
     w = 0;
end

x = sqrt( 1 + Rxx - Ryy - Rzz ) / 2;
y = sqrt( 1 + Ryy - Rxx - Rzz ) / 2;
z = sqrt( 1 + Rzz - Ryy - Rxx ) / 2;

[element, i ] = max( [w,x,y,z] );

if( i == 1 )
    x = ( Rzy - Ryz ) / (4*w);
    y = ( Rxz - Rzx ) / (4*w);
    z = ( Ryx - Rxy ) / (4*w);
end

if( i == 2 )
    w = ( Rzy - Ryz ) / (4*x);
    y = ( Rxy + Ryx ) / (4*x);
    z = ( Rzx + Rxz ) / (4*x);
end

if( i == 3 )
    w = ( Rxz - Rzx ) / (4*y);
    x = ( Rxy + Ryx ) / (4*y);
    z = ( Ryz + Rzy ) / (4*y);
end

if( i == 4 )
    w = ( Ryx - Rxy ) / (4*z);
    x = ( Rzx + Rxz ) / (4*z);
    y = ( Ryz + Rzy ) / (4*z);
end

Q = [ w; x; y; z ];