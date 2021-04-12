function ctfCell=tom_av2_ctffind_parselog(wk,label)
%TOM_AV2_CTFFIND_PARSELOG performs parsing of the outputfiles from ctffind
%
%   ctfStruct=tom_av2_ctffind_parselog(wk)
%
%PARAMETERS
%
%  INPUT
%   wk                  wildcard of micrographs to be parsed
%                       or cell of micrographs 
%   label               labesl for parsing
%  
%  OUTPUT
%   ctfCell             cell containing the informatio of the log-files
%
%EXAMPLE
%   
% ctfCell=tom_av2_ctffind_parselog('*.log');
% ctfCell=tom_av2_ctffind_parselog({'img1_ctffind.log;img1_ctffind.log'});
%
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by FB 07/09/15
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
    label{1}='Estimated defocus values';
    label{2}='Estimated azimuth of astigmatism';
    label{3}='Score   ';
    label{4}='Thon rings with good fit up to';
end;

if (iscell(wk))
    names=wk;
else
    [fpath,fname,fext]=fileparts(wk);
    d=dir(wk);
    for i=1:length(d)
        names{i}=[fpath filesep d(i).name];
    end;
end;

parfor i=1:length(names)
    ctfCell(i,:)=get_values(names{i},label);
end;


function str=get_values(name,label)
%get values for lables

call=['cat ' name ' | grep "' label{1} '" | awk ''{split($0,a,":"); print a[2]}'''];
[a,tmpStr]=unix(call);
[def1,tmpStr]=strtok(tmpStr); 
def1=str2double(def1)./1e4;
tmpStr=strrep(strrep(tmpStr,'Angstoms',''),',','');
[def2,tmpStr]=strtok(tmpStr); 
def2=str2double(def2)./1e4;


call=['cat ' name ' | grep "' label{2} '" | awk ''{split($0,a,":"); print a[2]}'''];
[a,tmpStr]=unix(call);
[angle,tmpStr]=strtok(tmpStr);
angle=str2double(angle);

call=['cat ' name ' | grep "' label{3} '" | awk ''{split($0,a,":"); print a[2]}'''];
[a,tmpStr]=unix(call);
score=str2double(tmpStr);

call=['cat ' name ' | grep "' label{4} '" | awk ''{split($0,a,":"); print a[2]}'''];
[a,tmpStr]=unix(call);
[rings,tmpStr]=strtok(tmpStr);
rings=str2double(rings);

str{1}=name;
str{2}=def1;
str{3}=def2;
str{4}=angle;
str{5}=score;
str{6}=rings;











   




