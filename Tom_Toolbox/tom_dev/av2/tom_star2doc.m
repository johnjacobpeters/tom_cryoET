function docst=tom_star2doc(starFile,outputFilename,flavour,transTap)
% tom_star2doc transforms a star file into a doc-file
%  
%     docst=tom_star2doc(starFile,outputFilename,flavour,transTap)
%  
%  PARAMETERS
%  
%    INPUT
%     starFile           filename or struct of the starfile file 2 be transformed
%     docFile            outputfilename 
%                        use '' for no output  
%     flavour            ('relion') 
%     transTap           ('') matlab struct matching the values
%                             check source for docu! 
%    OUTPUT
%      docFile          output docFile struct      
%                          
%  
%  EXAMPLE
%     tom_star2doc('cut_stars4test/run_3cl_it025_data_cl1.star,'cl1Cut.doc');
%
%  REFERENCES
%  
%  NOTE:
%  
%
%  SEE ALSO
%      tom_av2_xmipp_doc2star,tom_starread,tom_xmippdocread
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

if (nargin < 3)
    flavour='relion';
end;

if (nargin < 4)
    transTap='';
end;

star_st=tom_starread(starFile,'struct');
if (isempty(transTap))
    transTap=genTransfromTable(flavour);
end;
docst=tom_av2_xmipp_empty_doc(length(star_st));
docst=transForm(star_st,docst,transTap);

if (isempty(outputFilename)==0)
    tom_xmippdocwrite(outputFilename,docst);
end;



function docst=transForm(star_st,docst,transTap)

angLookUp='';

for i=1:length(star_st)
    for colNr=1:length(transTap)
        StarFieldName=transTap{colNr}.from;
        StarFieldTransFun=transTap{colNr}.transfun;
        tmpValue=extractValueFromStarSt(star_st(i),StarFieldName,StarFieldTransFun);
        docst(i).(transTap{colNr}.to)=tmpValue;
    end;
    docst(i)=transForm2xmippValueSpace(docst(i));
    docst(i)=extractParticleIndex(docst(i));
    [angLookUp,refNr]=getRefNr(angLookUp,[docst(i).rot docst(i).tilt]);
    docst(i).ref=refNr;
    docst(i).run_num=i;
end;

if (length(unique(docst(i).part_idx))==length(docst(i).part_idx) )
    docst(1).part_idx_unique=1;
else
    docst(1).part_idx_unique=0;
end;



function tmpValue=extractValueFromStarSt(star_stEntry,StarField,transfun)

if (isempty(findstr(StarField,':fixVal:')) )
    tmpValue=star_stEntry.(StarField);
else
    tmpValue=strrep(StarField,':fixVal:','');
    if (isnan(str2double(tmpValue))==0)
        tmpValue=str2double(tmpValue);
    end;
end;

if (isempty(transfun)==0)
    eval(transTap{colNr}.transfun);
end;


function docstEntry=extractParticleIndex(docstEntry)

num=strfind(docstEntry.name,'_');
tmpIdx=strtok(strrep(docstEntry.name(num(end):end),'_',''),'.');
docstEntry.part_idx=str2double(tmpIdx);

function docstEntry=transForm2xmippValueSpace(docstEntry)
 
if (docstEntry.tilt > 90)
    transAng=transformFull2Flip([docstEntry.rot docstEntry.tilt docstEntry.psi]);
    docstEntry.rot=transAng(1);
    docstEntry.tilt= transAng(2);
    docstEntry.psi=transAng(3);
    docstEntry.flip=1;
end;

if (docstEntry.psi<0);
    docstEntry.psi=360+docstEntry.psi;
end;     



function transTap=genTransfromTable(flavour)


if (strcmp(flavour,'relion'))
    zz=1;
    transTap{zz}.from=':fixVal:0';
    transTap{zz}.to='flip';
    transTap{zz}.transfun='';
    zz=zz+1;
    transTap{zz}.from='rlnOriginX';
    transTap{zz}.to='xoff';
    transTap{zz}.transfun='';
    zz=zz+1;
    transTap{zz}.from='rlnOriginY';
    transTap{zz}.to='yoff';
    transTap{zz}.transfun='';
    zz=zz+1;
    transTap{zz}.from='rlnAngleRot';
    transTap{zz}.to='rot';
    transTap{zz}.transfun='';
    zz=zz+1;
    transTap{zz}.from='rlnAngleTilt';
    transTap{zz}.to='tilt';
    transTap{zz}.transfun='';
    zz=zz+1;
    transTap{zz}.from='rlnAnglePsi';
    transTap{zz}.to='psi';
    transTap{zz}.transfun='';
    zz=zz+1;
    transTap{zz}.from='rlnImageName';
    transTap{zz}.to='name';
    transTap{zz}.transfun='';
end;


function ang_sum_zyz=transformFull2Flip(ang)

trans_angle=[0 180 0]; %zyz
[~,trans_angle_zxz]=tom_eulerconvert_xmipp(trans_angle(1),trans_angle(2),trans_angle(3));

[rotM ang_zxz]=tom_eulerconvert_xmipp(ang(1),ang(2),ang(3));
[euler_sum_zxz shift_out rott]=tom_sum_rotation([ang_zxz; trans_angle_zxz],[0 0 0;0 0 0]);
[rotM ang_sum_zyz]=tom_eulerconvert_xmipp(euler_sum_zxz(1),euler_sum_zxz(2),euler_sum_zxz(3),'tom2xmipp');


function [angLookUp,refNr]=getRefNr(angLookUp,ang)

if (isempty(angLookUp))
    clear('angLookUp');
    idx=1;
    angLookUp(idx,:)=[ang(1) ang(2)];
else
    idx=find(sum(angLookUp==repmat(ang,size(angLookUp,1),1),2)==2);
end

if (isempty(idx))
    refNr=size(angLookUp,1)+1;
    angLookUp(refNr,:)=[ang(1) ang(2)];
else
    refNr=idx(1);
end;



