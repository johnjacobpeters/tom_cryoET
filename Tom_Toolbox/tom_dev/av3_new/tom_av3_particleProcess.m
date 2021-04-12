function tom_av3_particleProcess(partListIn,partListOut,findWhat,replaceWith,operations,parameters,alignmentFlag)
%   tom_av3_particleProcess(partListIn,partListOut,findWhat,replaceWith,operations,parameters)
%  
%    tom_av3_particleProcess(partListIn,partListOut,findWhat,replaceWith,operations,parameters)
%  
%  PARAMETERS
%  
%    INPUT
%     partListIn          filename for input particle List
%     partListOut         filename for output particle List                          
%     findWhat            string from input that should be replaced 
%     replaceWith         replacement string
%     operations          operation to be performed on individual particles
%                         e.g. 'align','cut'
%     parameters          parameter cell for the operations 
%     alignmentFlag       ('inverse')       
%    
%    OUTPUT
%    -
%
%  EXAMPLE
%    
%   orgPath='/fs/pool/pool-sakata/Marc/26S_insitu/yeast_W303a/template_matching/'
%   newPath='/fs/pandora/pub/4Beck/fromMarc/test/'
%   tom_av3_particleProcess('aligned_pl_iterNew.xml','aligned_pl_iter6Processed.xml',orgPath,newPath,{'align';'cut'},{{'rot+shift'};{40 40 40}});
%
%  NOTE:
%                            operations:  paramters:
%                           'align'      'rot+shift','rot','shift' 
%                           'cut'         size e.g. {40 40 40}  
%  
%
%  REFERENCES
%  
%  SEE ALSO
%     ...
%  
%     created by fb okt.2011
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



if nargin < 7
    alignmentFlag='inverse';
end


Align=loadList(partListIn);
AlignNew=Align;

waitbar=tom_progress(size(Align,2),['processing partlist']); 
for i=1:size(Align,2)
    AlignNew(1,i)=processParticle(Align(1,i),findWhat,replaceWith,operations,parameters,alignmentFlag);
    waitbar.update();
end;
waitbar.close();

Align=AlignNew;
writeList(partListOut,Align);


function writeList(partListOut,Align)

[~,~,ext]=fileparts(partListOut);

if (strcmp(ext,'.mat')) 
    disp('Writing new list tom format');
    save(partListOut,'Align');
end;

if (strcmp(ext,'.xml')) 
    disp('Writing new list in pytom format');
    tom_pytomXmlPartlist_write(partListOut,Align);
end;



function Align=loadList(partListIn)

if (isstruct(partListIn))
    Align=partListIn;
    exit;
end;

[~,~,ext]=fileparts(partListIn);

if (strcmp(ext,'.xml'))
    [~,Align]=tom_pytomXmlPartlist_read(partListIn);
end;

if (strcmp(ext,'.mat'))
    load(partListIn);
end;



function AlignNew=processParticle(Align,findWhat,replaceWith,operations,parameters,alignmentFlag)

name=Align.Filename;
newName=strrep(name,findWhat,replaceWith);

shift =[Align.Shift.X Align.Shift.Y Align.Shift.Z];
angle =[Align.Angle.Phi Align.Angle.Psi Align.Angle.Theta];
particle = tom_emreadc(name); particle = particle.Value;
particle=applyOperationstoParticle(particle,operations,parameters,shift,angle,alignmentFlag);

if (strcmp(name,newName)==0)
    [fold]=fileparts(newName);
    if (exist(fold,'dir')==0)
        mkdir(fold);
    end
    tom_emwritec(newName,particle);
else
    error(['cannot find ' findWhat ' in ' name]);
end;

AlignNew=updateAlign(Align,operations,parameters,newName);



function AlignNew=updateAlign(Align,operations,parameters,newName)

AlignNew=Align;
AlignNew.Filename=newName;

idx=find(ismember(operations,'align'));

algFlag=parameters{idx}{1};

switch algFlag
    case 'rot+shift'
        AlignNew.Angle.Phi=0;
        AlignNew.Angle.Psi=0;
        AlignNew.Angle.Theta=0;
        AlignNew.Shift.X=0;
        AlignNew.Shift.Y=0;
        AlignNew.Shift.Z=0;
    case 'rot'
        AlignNew.Angle.Phi=0;
        AlignNew.Angle.Psi=0;
        AlignNew.Angle.Theta=0;
    case 'shift'
        AlignNew.Shift.X=0;
        AlignNew.Shift.Y=0;
        AlignNew.Shift.Z=0;
end;



function particle=applyOperationstoParticle(particle,operations,parameters,shift,angle,alignmentFlag)


for i=1:length(operations)
    switch operations{i}
        case 'align'
            particle=alignPart(particle,angle,shift,parameters{i},alignmentFlag);
        case 'cut'
            particle=cutPart(particle,parameters{i});
        otherwise
            error(['unkown operation: '  operations{i}]);
    end
end;


function  particle=alignPart(particle,angle,shift,parameter,alignmentFlag)

algParam=parameter{1};

switch alignmentFlag
    case  'inverse'
        shift=shift.*-1;
        angle=[angle(2) angle(1) angle(3)].*-1;
    case 'dircet'
        shift=shift;
        angle=[angle(2) angle(1) angle(3)];
    otherwise
        error(['unkown alignmentFlag: ' alignmentFlag]);
end

switch algParam
    case 'rot+shift'
        particle = tom_rotate(tom_shift(particle,shift),angle);
    case 'rot'
        particle = tom_rotate(particle,angle);
    case 'shift'
        particle = tom_shift(particle,shift);
    otherwise
        error(['unkown alignment parameter: ' parameters]);
end;


function particle=cutPart(particle,parameter)

cutSz=[parameter{1} parameter{2} parameter{3}];

particle=tom_cut_out(particle,'center',cutSz);




