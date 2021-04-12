function vol=tom_tmplMatch2RepasteVol(Align,template,szTomo,shScale,outputName)            
%tom_tmplMatch2RepasteVol pastes templates under the angles of the given
%list
%   
% vol=tom_tmplMatch2RepasteVol(Align,template,szTomo,shScale,outputName) 
%
%PARAMETERS
%
%  INPUT
%   Align                       align list
%   template                 template to paste
%   szTomo                   size of the tomogram
%   shScale                   scale factor for shifts
%   outputName            name of the repasted volume
% 
%EXAMPLE
%   
% 
% tom_tmplMatch2RepasteVol(Align,templ,[924 924 300],0,'data/VolRepasteTemplate.em');
% 
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
  
if (ischar(Align))
    al=load(Align);
    Align=al.Align;
end;
if (ischar(template))
    template=tom_emread(template);
    template=template.Value;
end;


volume= zeros(szTomo);
offSetTopLeft=floor(size(template)./2)-1;

wb=tom_progress(size(Align,2),['pasting ' num2str(size(Align,2)) ' volumes']);
 for i = 1:size(Align,2)
    
    pos=[Align(1,i).Tomogram.Position.X  Align(1,i).Tomogram.Position.Y Align(1,i).Tomogram.Position.Z];
    tmpShift=[Align(i).Shift.X Align(i).Shift.Y Align(i).Shift.Z];
    tmpShift=tmpShift.*shScale;
    angle=[Align(i).Angle.Phi Align(i).Angle.Psi Align(i).Angle.Theta];
    
   % templateAlign=tom_shift(tom_rotate(template,angle),tmpShift);
    templateAlign=tom_rotate(template,angle);
    topLeft=round(pos-offSetTopLeft);
    volume=tom_paste2(volume,templateAlign,topLeft,'max');
    wb.update();
    
end
 tom_emwrite(outputName, volume);

    





    