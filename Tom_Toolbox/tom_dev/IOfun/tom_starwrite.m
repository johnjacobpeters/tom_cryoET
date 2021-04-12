function tom_starwrite(filename,data,Header)
% tom_starwrite writes star files
%  
%     tom_starwrite(filename,data,header)
%  
%  PARAMETERS
%  
%    INPUT
%     filename         filename of the star file
%     data             data in ('struct') or 'matrix' form 
%     header           needed if data was given in matrix form  
%
%    OUTPUT
%     
%                          
%  
%  EXAMPLE
%       tom_starwrite('my_star.star',star_st,Head);
%
%  REFERENCES
%  
%  NOTE:
%  
%
%  SEE ALSO
%      tom_xmippdocread,tom_spiderread
%  
%     created by FB 04/12/13
%  
%     Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%     Journal of Structural Biology, 149 (2005), 227-234.
%  
%     Copyright (c) 2004-2007
%     TOM toolbox for Electron Tomography
%     Max-Planck-Institute of Biochemistry
%     Dept. Molecular Structural Biology
%     82152 Martinsried, Germany
%     http://www.biochem.mpg.de/tom
% 

if (isstruct(data)==0 && nargin<3)
    error('Header needed if data is given in matrix form!!');
end;

if (nargin < 3)
    Header=data(1).Header;
end;

fid = fopen(filename,'wt');

writeHeader(fid,Header);
writeData(fid,data);

function writeData(fid,data)

if (isstruct(data))
    if (isfield(data,'Header'))
        data=rmfield(data,'Header');
    end;
    fieldnamesData=fieldnames(data);
    NumOfColumns=length(fieldnamesData);
    NumOfRows=length(data);
    dataIsStruct=1;
else
    NumOfColumns=size(data,2);
    NumOfRows=size(data,1);
    dataIsStruct=0;
end;

for ii=1:NumOfRows
    for i=1:NumOfColumns
        if (dataIsStruct)
            item=data(ii).(fieldnamesData{i});
        else
           item=data{ii,i};
        end;
        if (isnumeric(item))
            fprintf(fid,'%f ',item);
        else
            fprintf(fid,'%s ',item);
        end;
        if (i==NumOfColumns)
            fprintf(fid,'\n');
        end;
    end;
end;



function writeHeader(fid,Header)

fprintf(fid,'%s\n', Header.title);
if (Header.isLoop==1)
    fprintf(fid,'%s\n','loop_');
end;

for i=1:length(Header.fieldNames)
     fprintf(fid,'%s\n',Header.fieldNames{i});
end;







