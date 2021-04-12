function [planeCoeffs,normal,zoff,fitresult,normalAngle]=tom_fit_plane(coords,visOutputFolder,matlabVis,visRotationCenter)
%tom_tmplMatch2VectField transforms a template Match result to a vector field
%   
% tom_tmplMatch2VectField()
%
%PARAMETERS
%
%  INPUT
%   coords                       coords matrix in x y z or coord filename
%   visOutputFolder        ('') foldername for chimera vis output data
%   matlabVis                  (0) flag for matlab visualisation 
%   visRotationCenter     ('local') rotation center for plane in aligned
%                                                   folder
%                                       usually you use the center+1 of your tomogram   
%                                       'local' means the center of the
%                                       markers is used
%   
%
%  OUTPUT
%   planeCoeffs               coefficients for plane equation
%   normal                       normal vector of the plane    
%   zoff                            zoffset 
%   fitresult                     result from matlab fitting
%   normalAngle              zxz euler angle to rotate the plane paralell to xy
%
%EXAMPLE
%   
% vect=[91   872   218; 853   862   220; 84    67   162; 882    57   165];
% [coeffs,normal,zOff,fit,angle]=tom_fit_plane(vect,'visPlane',1);
% 
%%from text file
% unix('echo 91   872   218 > myCooord.txt'); unix('echo 853   862   220 >> myCooord.txt'); 
% unix('echo 84    67   162 >> myCooord.txt'); unix('echo  882    57   165 >> myCooord.txt'); 
% [coeffs,normal,zOff,fit,angle]=tom_fit_plane('myCooord.txt','visPlane',1);
%
%%use rotation center of the tomogram for alignment  
%[coeffs,normal,zOff,fitang,angNormal]=tom_fit_plane('Labels/membrane_plane1.txt','Labels/visPlane/',1,[463   463   151]);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 08/24/17
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

if (nargin<2)
    visOutputFolder='';
end;

if (nargin<3)
    matlabVis=0;
end;

if (nargin<4)
    visRotationCenter='local';
end;

if (ischar(coords))
    coords=load(coords);
end;
 
[planeCoeffs,zoff,fitresult,normal]=doFit(coords,visOutputFolder,matlabVis);

disp(fitresult);
normal=normal./norm(normal);
disp(['normal: ' num2str(normal) ]);

normalAngle=calcAngleFromNormal(normal);
disp(['normal angle: ' num2str(normalAngle) ]);

coordsRot=rotateCoords(coords,normalAngle,visRotationCenter);
doFit(coordsRot,[visOutputFolder filesep 'aligned'],0);

if (isempty(visOutputFolder)==0)
    stPlane.planeCoeffs=planeCoeffs;
    stPlane.normal=normal;
    stPlane.fitresult=fitresult;
    stPlane.normalAngle=normalAngle;
    save([visOutputFolder filesep 'result.mat'],'stPlane');
end;

function coordsRot=rotateCoords(coords,normalAngle,visRotationCenter)

if (strcmp(visRotationCenter,'local'))
    midx=floor((max(coords(:,1))-min(coords(:,1)))./2)+1;
    midy=floor((max(coords(:,2))-min(coords(:,2)))./2)+1;
    midz=floor((max(coords(:,3))-min(coords(:,3)))./2)+1;
    mid=[midx midy midz];
else
    mid=visRotationCenter;
end;

for i=1:size(coords,1)
   coordsRot(i,:)=tom_pointrotate(coords(i,:)-mid,normalAngle(1),normalAngle(2),normalAngle(3))+mid;
end;


function [planeCoeffs,zoff,fitresult,normal]=doFit(coords,visOutputFolder,matlabVis)

[fitresult, gof] = createFit(coords(:,1),coords(:,2) ,coords(:,3),matlabVis);
planeCoeffs=[fitresult.p10 fitresult.p01 1 fitresult.p00];
zoff=fitresult.p00;
normal=[fitresult.p10 fitresult.p01 -1];
genVis(fitresult,coords,visOutputFolder,matlabVis);


function normalAngle=calcAngleFromNormal(normal)


rotX_theta=atand(normal(2)./normal(3));
rotAngX=[0 0 rotX_theta];
vx=tom_pointrotate(normal,rotAngX(1),rotAngX(2),rotAngX(3));
rotY_theta=atand(vx(1)./vx(3));
rotAngY=[-90 -270 -rotY_theta];

normalAngle=tom_sum_rotation([rotAngX;rotAngY],[0 0 0;0 0 0]);


function genVis(fitresult,coords,visOutputFolder,matlabVis)

[xf,yf,zf,xfH,yfH,zfH]=samplePlane(fitresult,coords,matlabVis);
if (isempty(visOutputFolder)==0)
    genChimeraOutput(xf,yf,zf,xfH,yfH,zfH,coords,visOutputFolder);
end;

function genChimeraOutput(xf,yf,zf,xfH,yfH,zfH,coords,visOutputFolder)

warning off; mkdir(visOutputFolder); warning on;
fid=fopen([visOutputFolder filesep 'normals.bild'],'wt');
for i=1:length(xf)
    colStr=['.color  0.7 0.7 0.7']; 
    angStr=['.arrow ' num2str([xf(i) yf(i) zf(i) xfH(i) yfH(i) zfH(i) 1.5]) ];
    fprintf(fid,'%s\n',colStr);
    fprintf(fid,'%s\n',angStr);
end;
fclose(fid);

fid=fopen([visOutputFolder filesep 'plane.bild'],'wt');
for i=1:length(xf)
    colStr=['.color  0.7 0.7 0.7']; 
    angStr=['.sphere ' num2str([xf(i) yf(i) zf(i) 3.5]) ];
    fprintf(fid,'%s\n',colStr);
    fprintf(fid,'%s\n',angStr);
end;
fclose(fid);

fid=fopen([visOutputFolder filesep 'markers.bild'],'wt');
for i=1:size(coords,1)
    colStr=['.color  1 1 0']; 
    angStr=['.sphere ' num2str([coords(i,1) coords(i,2) coords(i,3) 7.5]) ];
    fprintf(fid,'%s\n',colStr);
    fprintf(fid,'%s\n',angStr);
end;
fclose(fid);



function [xf,yf,zf,xfH,yfH,zfH]=samplePlane(fitresult,coords,matlabVis)

numSamp=80;

increX=round((max(coords(:,1))-min(coords(:,1)))./numSamp);
increY=round((max(coords(:,2))-min(coords(:,2)))./numSamp);

sampX=min(coords(:,1)):increX:(max(coords(:,1))-1);
sampY=min(coords(:,2)):increY:(max(coords(:,2))-1);
lenVect=max(coords(:,3))-min(coords(:,3))*0.2;

normalOrg=[fitresult.p10 fitresult.p01 -1];
normal=(normalOrg./norm(normalOrg)).*lenVect;

zz=1;
for x=sampX
    for y=sampY
        xf(zz)=x;
        yf(zz)=y;
        zf(zz)=fitresult.p10.*x + fitresult.p01.*y + fitresult.p00;
        xfH(zz)=x+normal(1);
        yfH(zz)=y+normal(2);
        zfH(zz)=zf(zz)+normal(3);
        zz=zz+1;
    end;
end;

if (matlabVis)
    QnormalX=ones(length(xf),1).*normal(1);
    QnormalY=ones(length(xf),1).*normal(2);
    QnormalZ=ones(length(xf),1).*normal(3);
    quiver3(xf,yf,zf,QnormalX',QnormalY',QnormalZ',1); axis image;
    hold on;
    for i=1:size(coords)
        plot3(coords(i,1),coords(i,2),coords(i,3),'ro','Markersize',5);
    end;
    hold off;
end;


disp(' ');

function [fitresult, gof] = createFit(x, y, z,doVis)

%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( x, y, z );

% Set up fittype and options.
ft = fittype( 'poly11' );

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft );

if (doVis==1)
    % Plot fit with data.
    figure( 'Name', 'untitled fit 1' );
    h = plot( fitresult, [xData, yData], zData );
    legend( h, 'untitled fit 1', 'z vs. x, y', 'Location', 'NorthEast' );
    % Label axes
    xlabel x
    ylabel y
    zlabel z
    grid on
    view( -89.9, 10.8 );
end;

