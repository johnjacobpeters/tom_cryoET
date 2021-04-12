function [diff_star,angDist,shDist]=tom_av2_star_diff(star1,star2,absDistance,outputDiffStarName,outputExtStarRoot,fieldnameAngDist,fieldnameEucShDist)
%tom_av2_xmipp_doc_diff subtracts 2 star files
%
%   diff_star=tom_av2_star_diff(star1,star2,outputstar)
%
%PARAMETERS
%
%  INPUT
%   star1                  input relion star-file (filename or struct)
%   star2                  input relion star-file (filename or struct) 
%   absDistance            (0) use abs for subtraction  
%   outputDiffStarName     ('') output star fileName (empty means no output)
%   outputExtStarRoot      ('') output star fileName root (empty means no output)
%   fieldnameAngDist       ('rlnKurtosisExcessValue')
%   fieldnameEucShDist     ('rlnLensStability')
%  
%  OUTPUT
%    diff_star             struct in mem of diff star        
%    angDist  
%    shDist
%EXAMPLE
%   
% diff_star=tom_av2_star_diff('star1.star','star2.star');
%
% [diff_star,angDist,shDist]=tom_av2_star_diff('d256_mask26S_loc1_it000_data.star','d256_mask26S_loc1_it010_data.star',1,'diff.star','ext_','fbAngDist','fbEucShd');
%
%REFERENCES
%
%SEE ALSO
%   
%
%   created by FB 14/01/16
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

if (nargin < 3)
    absDistance=0;
end;

if (nargin < 4)
    outputDiffStarName='';
end;

if (nargin < 5)
    outputExtStarRoot='';
end;

if (nargin < 6)
    fieldnameAngDist='rlnKurtosisExcessValue';
end;

if (nargin < 7)
    fieldnameEucShDist='rlnLensStability';
end;


if (isstruct(star1)==0)
    disp('* Read star file 1 *');
    star1Name=star1;
    star1=tom_starread(star1);
end;

if (isstruct(star2)==0)
   disp('* Read star file 2 *');
   star2Name=star2;
   star2=tom_starread(star2);
end;

if length(star1)~=length(star2)
    error('** ERROR: doc files are of different length **');
end;

disp('* Start Analysis ... *');
all_fields=fieldnames(star1);
all_fields2=fieldnames(star2);
all_fields=intersect(all_fields,all_fields2);


zz=1;
for i=1:length(all_fields)
    if ((isnumeric(getfield(star1(1),all_fields{i})))  )
        numeric_fields{zz}=all_fields{i};
        zz=zz+1;
    end;
end;
diff_star=star1;

waitbar=tom_progress(length(numeric_fields),'calc differences'); 
for i=1:length(numeric_fields)
    for ii=1:length(diff_star)
        valTmp=getfield(star1(ii),numeric_fields{i})-getfield(star2(ii),numeric_fields{i});
        if (absDistance)
            valTmp=abs(valTmp);
        end;
        diff_star(ii)=setfield(diff_star(ii),numeric_fields{i},valTmp);
    end;
    waitbar.update();
end;
waitbar.close;  
clear('waitbar');


for i=1:length(diff_star)
    %alloc memory
    diff_star(i).(fieldnameAngDist)=0;
    diff_star(i).(fieldnameEucShDist)=0;
    %
    star1(i).(fieldnameAngDist)=0;
    star1(i).(fieldnameEucShDist)=0;
    %
    star2(i).(fieldnameAngDist)=0;
    star2(i).(fieldnameEucShDist)=0;
end;

angDist=zeros(length(diff_star),1,'single');
shDist=zeros(length(diff_star),1,'single');

disp(' ');
waitbar=tom_progress(length(diff_star),'calc angDist and shift dist'); 
parfor i=1:length(diff_star)
    %eucledian distance shifts
    tmp_sh_1=[star1(i).rlnOriginX star1(i).rlnOriginY];
    tmp_sh_2=[star2(i).rlnOriginX star2(i).rlnOriginY];
    tmp_euShDist=sqrt(sum( ((tmp_sh_1-tmp_sh_2).^2)) );
   
    
    %angular distance
    tmp_ang_1=[star1(i).rlnAngleRot star1(i).rlnAngleTilt star1(i).rlnAnglePsi];
    tmp_ang_2=[star2(i).rlnAngleRot star2(i).rlnAngleTilt star2(i).rlnAnglePsi];
    tmp_angDist=tom_angular_distance(tmp_ang_1,tmp_ang_2,'zyz');
    
    if (absDistance)
        tmp_angDist=abs(tmp_angDist);
    end;
    
    diff_star(i).(fieldnameAngDist)=tmp_angDist;
    diff_star(i).(fieldnameEucShDist)=tmp_euShDist;
    
    star1(i).(fieldnameAngDist)=tmp_angDist;
    star2(i).(fieldnameAngDist)=tmp_angDist;
    star1(i).(fieldnameEucShDist)=tmp_euShDist;
    star2(i).(fieldnameEucShDist)=tmp_euShDist;
    angDist(i)=tmp_angDist;
    shDist(i)=tmp_euShDist;
    
    waitbar.update;    
    
end;
waitbar.close;  


if (isempty(outputDiffStarName)==0)
    disp('writing diff star');
    diff_star(1).Header.fieldNames{end+1}=['_' fieldnameAngDist ' #' num2str(length(diff_star(1).Header.fieldNames)+1)];
    diff_star(1).Header.fieldNames{end+1}=['_' fieldnameEucShDist ' #' num2str(length(diff_star(1).Header.fieldNames)+1)];
    tom_starwrite(outputDiffStarName,diff_star);
end;

if (isempty(outputExtStarRoot)==0)
    disp('writing extended star');
    [a1,b1,c1]=fileparts(star1Name);
    [a2,b2,c2]=fileparts(star2Name);
    star1(1).Header.fieldNames{end+1}=['_' fieldnameAngDist ' #' num2str(length(star1(1).Header.fieldNames)+1)];
    star1(1).Header.fieldNames{end+1}=['_' fieldnameEucShDist ' #' num2str(length(star1(1).Header.fieldNames)+1)];
    tom_starwrite([outputExtStarRoot b1 c1],star1);
    star2(1).Header.fieldNames{end+1}=['_' fieldnameAngDist ' #' num2str(length(star2(1).Header.fieldNames)+1)];
    star2(1).Header.fieldNames{end+1}=['_' fieldnameEucShDist ' #' num2str(length(star2(1).Header.fieldNames)+1)];
    tom_starwrite([outputExtStarRoot b2 c2],star2);
end;





