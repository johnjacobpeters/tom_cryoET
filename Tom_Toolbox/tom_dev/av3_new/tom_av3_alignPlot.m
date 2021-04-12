function tom_av3_alignPlot(Align,field,plottingFlavour,flag)
%TOM_AV3_ALIGNPLOT plots feature from ALIGN file
% 
% 
%  tom_av3_alignPlot(Align)
%  
%
%PARAMETERS
%
%  INPUT
%   Align              align struct
%   field              field to plot   
%   plottingFlavour    e.g. points
%   flag               e.g. b1
% 
%  OUTPUT
%
%
%EXAMPLE
%
%  tom_av3_alignPlot(Align,'position','points');
%  tom_av3_alignPlot(Align,'position','volume','b1');
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 21/07/15
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

if (isstruct(Align)==0)
    load(Align);
end;


if (strcmp(field,'position'))
    pos=zeros(size(Align,2),3);
    cc=zeros(size(Align,2),1);
    for i=1:size(Align,2)
        pos(i,:)=[Align(1,i).Tomogram.Position.X Align(1,i).Tomogram.Position.Y  Align(1,i).Tomogram.Position.Z];
        cc(i)=Align(1,i).CCC;
    end;
    if (strcmp(plottingFlavour,'points'))
        figure; plot3(pos(:,1),pos(:,2),pos(:,3),'ro');
    end;
    if (strcmp(plottingFlavour,'volume'))
        if (strcmp(flag,'b1'))
            volNameOrg=strrep(Align(1,1).Tomogram.Filename,'B0','B1');
            f=2;
        else
           volNameOrg=Align(1,1).Tomogram.Filename;
           f=1;
        end;
        h=tom_reademheader(volNameOrg);
        volP=zeros(h.Header.Size','single');
        for i=1:size(pos,1)
           
            volP(round(pos(i,1)./f),round(pos(i,2)./f),round(pos(i,3)./f))=cc(i);
        end;
        volpName='tmpPoints.em';
        tom_emwrite(volpName,volP); 
        t=tom_emread(volNameOrg);
        tom_emwrite('tmpVol.em',tom_filter(t.Value,5));
        unix(['chimera tmpVol.em tmpPoints.em']);
    end;
    disp(' ');
end;
















