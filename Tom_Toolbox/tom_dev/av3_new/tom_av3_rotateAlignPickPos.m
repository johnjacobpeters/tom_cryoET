function AlignRot=tom_av3_rotateAlignPickPos(Align,angle,mid,outputName,posMask)
%tom_av3_rotateAlignPickPos rotates the pick coordinates
% 
% 
%  AlignRot=tom_av3_rotateAlignPickPos(Align,angle,outputName)
%  
%
%PARAMETERS
%
%  INPUT
%   Align                     particle List
%   angle                    zxz euler angle
%   mid                       mid of cosy for rotation usually the (n/2)+1
%                                of tomogram
%   outputName         ('') outputname for alignment file
%   posMask               ([1 1 1])  
%
%  OUTPUT
%   AlignRot               rotated particle List
%
%EXAMPLE
%  
%  [coeffs,normal,zOff,fitang,angNormal]=tom_fit_plane('Labels/membrane_plane1.txt','Labels/visPlane/',1);
%  AlignRot=tom_av3_rotateAlignPickPos('ParticleList.mat',angNormal,[462 462 150]+1,'ParticleListAlg.mat');
%  vol=tom_emread('data/VolRepasteTemplate.em');
%  volRot=tom_rotate(vol.Value,angNormal);
%  tom_emwrite('data/VolRepasteTemplateAlg.em',volRot);
%  colourScemeCM.method='colorMap';
%  colourScemeCM.scale=[0 180];
%  colourScemeCM.colourMap=colormap('cool');
%  tom_tmplMatch2VectField('ParticleListAlg.mat','outputCMRot',[30 0 0;10 30 0; 0 0 30],[0 0 1].*30,colourScemeCM);
%  
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 04/03/15
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

if (nargin<5)
    posMask=[1 1 1];
end;

if (ischar(Align))
    load(Align);
end;


AlignRot=Align;
for i=1:size(Align,2)
    pos=[Align(1,i).Tomogram.Position.X Align(1,i).Tomogram.Position.Y  Align(1,i).Tomogram.Position.Z];
    pos=pos-mid;
    posRot=tom_pointrotate(pos,angle(1),angle(2),angle(3));
    posRot=posRot+mid;
    posRot=posRot.*posMask;
    AlignRot(1,i).Tomogram.Position.X = posRot(1);
    AlignRot(1,i).Tomogram.Position.Y = posRot(2); 
    AlignRot(1,i).Tomogram.Position.Z = posRot(3);
    angTmp=[AlignRot(1,i).Angle.Phi AlignRot(1,i).Angle.Psi AlignRot(1,i).Angle.Theta];
    angNew=tom_sum_rotation([angTmp;angle],[0 0 0; 0 0 0]);
    AlignRot(1,i).Angle.Phi =angNew(1);
    AlignRot(1,i).Angle.Psi =angNew(2);
    AlignRot(1,i).Angle.Theta =angNew(3);
    
    tmpSH=[AlignRot(1,i).Shift.X AlignRot(1,i).Shift.Y AlignRot(1,i).Shift.Z];
    newSH=tom_pointrotate(pos,tmpSH(1),tmpSH(2),tmpSH(3));
    AlignRot(1,i).Shift.X =newSH(1);
    AlignRot(1,i).Shift.Y =newSH(2);
    AlignRot(1,i).Shift.Z =newSH(3); 
end;
    

if (isempty(outputName)==0)
    Align=AlignRot;
    save(outputName,'Align');
end;

