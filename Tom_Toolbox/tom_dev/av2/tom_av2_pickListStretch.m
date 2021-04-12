function tom_av2_pickListStretch(listIn,outputFold,outputPostFix,angle,majorScale,minorScale,imgSize)
%tom_av2_pickListStretch streches coordinate according to res change
%
%   tom_av2_pickListStretch(listIn,listOut,angle,major_scale,minorScale,imgSize)
%
%PARAMETERS
%
%  INPUT
%   listIn                  wk of relion star files
%   outputFold        outputFolder
%   outputPostFix   reloutputPostfix
%   angle                 mask for both, reference and image
%   majorScale        mask for polar xcorellation function, rotation alignment
%   minorScale        mask for polar xcorellation function, translation alignment
%   imgSize              size of micrograph
%    
%                       
%  
%  OUTPUT
%
%
%EXAMPLE
%   
%  
% tom_av2_pickListStretch('0_micrographs/*_sort.star','0_micrographs_Corr/','_corr2',151.9,1.03,1.00,[3710 3838]); 
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 07/01/16
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


d=dir(listIn);
[inPath,inName]=fileparts(listIn);
inName=strrep(inName,'*','');

waitbar=tom_progress(length(d),[listIn '  ' num2str(length(d)) ' files']);
for i=1:length(d)
    tmpList=tom_starread([inPath filesep d(i).name]);
    tmpListNew=tmpList;
    [~,name,ext]=fileparts(d(i).name);
    
    outputName=[outputFold filesep strrep(name,inName,'') outputPostFix ext];
    for ii=1:length(tmpList)
        [xTr(ii),yTr(ii)]=transForm(tmpList(ii).rlnCoordinateX,tmpList(ii).rlnCoordinateY,angle,majorScale,minorScale,imgSize);
        tmpListNew(ii).rlnCoordinateX=xTr(ii);
        tmpListNew(ii).rlnCoordinateY=yTr(ii);
        x(ii)=tmpList(ii).rlnCoordinateX;
        y(ii)=tmpList(ii).rlnCoordinateY;
    end;
    tom_starwrite(outputName,tmpListNew);
    waitbar.update;
end;
waitbar.close;



function [xTr,yTr]=transForm(x,y,angle,majorScale,minorScale,imgSize)

imgSize=round(imgSize./2)+1;

%transForm cosy
xTr=(x-imgSize(1)); 
yTr=(y-imgSize(2));
r=tom_pointrotate2d([xTr yTr],angle);
 
%scale cosy
xTr=r(1).*majorScale;
yTr=r(2).*minorScale;
 
%transForm cosy back
r=tom_pointrotate2d([xTr yTr],-angle);
xTr=(r(1)+imgSize(1)); 
yTr=(r(2)+imgSize(2));





