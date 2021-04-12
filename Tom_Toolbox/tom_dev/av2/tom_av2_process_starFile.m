function starStNew=tom_av2_process_starFile(starFile,useField,findWhat,replaceWith,appplyTo,commandString,outputStarfile,verbose)
%TOM_AV2_PROCESS_STARFILE processes particles in star file according 2
%                         a given command string
%
%   tom_av2_process_starFile(starFile,useFiled,findWhat,replaceWith,commandString,outputStarfile)
%
%  PARAMETERS
%
%  INPUT
%   starFile        filename of the input star file
%   useField        fieldname of the star file containing the filename of the particle 
%   findWhat        string in the star which should be replaced
%   replaceWith     new string (according 2 find and replace in a text editor)
%   appplyTo        ('1st-folder') or 'full-path'   
%   commandString   matlab command that should be applied 2 all entries in
%                   star file
%   outputStarfile  ('') name of the new star file 
%   verbose         (1) use 0 to switch off          
%
%EXAMPLE
%  
%  %renormalize to background in a new location (works only for one root location)
%  findWhat='/fs/pool/pool-titan1/CWT/data/06__10042011_3/log/parts/high_corr_64/';
%  replceWith='/fs/fs03/lv15/pool/pool-nickell3/fb/4star/testOutput/';
%  commandString='mask=tom_spheremask(ones(64,64,64),31)==0; img=tom_norm(img,''mean0+1std'');'; 
%  tom_av2_process_starFile('myTrans.star','rlnImageName',findWhat,replceWith,'full-path',commandString,'new.star');
%
%  %rescale particle and write to new root folder with generic sub-folders
%  %(makes only sense if particles are organized according to their
%  %projects and are unique !!! pPROJECTNUMBER_PARTICLENUMGER.EXTENSION) for e.g p3_115.spi 
%  findWhat='GenericXPath';
%  replceWith='/fs/pool/pool-nickell3/fb/4star/testOutput/';
%  commandString='img=tom_rescale(img,[128 128]);'; 
%  tom_av2_process_starFile('myTrans.star','rlnImageName',findWhat,replceWith,'full-path',commandString,'new.star');
%
%  %cut out particles and write the new particles in a folder on the same
%  %level _cut added (all particles have to be in a parts folder) 
%  findWhat='/parts/';
%  replceWith='/parts_cut/';
%  commandString='tom_cut_out(img,''center'',[32 32 32]);'
%  tom_av2_process_starFile('myTrans.star','rlnImageName',findWhat,replceWith,'1st-folder',commandString,'new.star');
%
%
%NOTE
% 
% commandString has to be like commandString='img=OPERTION(img);'
% 
%  if ' is used use '' to mask 
%
% e.g renomalize
% commandString='img=tom_norm(img,'mean0+1std');'
% 
% e.g binning
% commandString='img=tom_bin(img,2);'
%
% e.g rotation
% commandString='img=tom_rotate(img,30);'
% 
%
%REFERENCES
%
%SEE ALSO
%   tom_aling2d
%
%   
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


if (nargin<7)
    outputStarfile='';
end;

if (nargin<8)
    verbose=1;
end;

show_param(starFile,useField,findWhat,replaceWith,appplyTo,commandString,outputStarfile,verbose);

starSt=tom_starread(starFile);
starStNew=starSt;


tic;
for i=1:length(starSt)
    OrgParticleName=starSt(i).(useField);
    OrgParticleName=checkOrgParticle(OrgParticleName);
    NewParticleName=genNewParticleName(OrgParticleName,findWhat,replaceWith,appplyTo);
    
    if (isempty(NewParticleName) || isempty(OrgParticleName))
        continue;
    end;
    
    img=tom_spiderread(starSt(i).(useField));
    img=img.Value;
    
    eval(commandString);
    
    writeNewPart(NewParticleName,img,OrgParticleName,verbose)
    starStNew(i).(useField)=NewParticleName;
    
    progress(i,verbose);
end;

if (isempty(outputStarfile)==0)
    tom_starwrite(outputStarfile,starStNew);
end

function progress(count,verbose)

if (verbose>0)
    if (mod(count,1000)==0)
        toc;
        disp(num2str(count));
        tic;
    end;
end;

function writeNewPart(newPartName,img,OldPartName,verbose)


newFold=fileparts(newPartName);

if(exist(newFold,'dir')==0)
    mkdir(newFold);
    if (verbose > 0)
        disp(['generating Folder: ' newFold]);
    end;
end;

if (strcmp(newPartName,OldPartName)==1)
    error(['new name: ' newPartName ' == old name: ' OldPartName]);
end;
tom_spiderwrite(newPartName,img);


function OrgParticleName=checkOrgParticle(OrgParticleName)

if (exist(OrgParticleName,'file')==0)
    OrgParticleName='';
    disp([OrgParticleName ' not found ...skipping']);
end;



function newPartName=genNewParticleName(OrgPartName,findWhat,replaceWith,appplyTo)

[foldernameOrg,filenameOrg,f_extOrg]=fileparts(OrgPartName);
   

if (strcmp(findWhat,'GenericXPath'))
    PartNameRoot=strtok(filenameOrg,'_');
    newPartName=[replaceWith filesep PartNameRoot filesep filenameOrg f_extOrg];
else
    if (isempty(strfind(foldernameOrg,findWhat)))
        disp(['Warning: Token ' replaceWith ' not found in ' foldernameOrg  '...skipping']);
        newPartName='';
        return
    end;
    if (strcmp(appplyTo,'1st-folder'))
        newFolderName=[foldernameOrg(1:max(strfind(foldernameOrg,'/'))-1 ) strrep([foldername(max(strfind(foldernameOrg,'/')):end) '/'],findWhat,replaceWith)];
    end;
    if (strcmp(appplyTo,'full-path'))
        newFolderName=strrep(foldernameOrg,findWhat,replaceWith);
    end;
    newPartName=[newFolderName filenameOrg f_extOrg];
end;

newPartName=strrep(newPartName,'//','/');


function show_param(starFile,useField,findWhat,replaceWith,appplyTo,commandString,outputStarfile,verbose)


log_file_name='';

logStat='info: ';

my_disp(' ','',1,log_file_name);
my_disp('======================================>',logStat,1,log_file_name);
my_disp(['starFile: ' starFile],logStat,1,log_file_name);
my_disp(['useField: ' useField],logStat,1,log_file_name);
my_disp(['findWhat: ' findWhat],logStat,1,log_file_name);
my_disp(['replaceWith: ' replaceWith],logStat,1,log_file_name);
my_disp(['appplyTo: ' appplyTo],logStat,1,log_file_name);
my_disp(['commandString: ' commandString],logStat,1,log_file_name);
my_disp(['outputStarfile: ' outputStarfile],logStat,1,log_file_name);
my_disp(['verbose: ' num2str(verbose)],logStat,1,log_file_name);
my_disp('<======================================',logStat,1,log_file_name);
my_disp(' ','',1,log_file_name);

function my_disp(message,status,out_screen,out_fileName,date)

if (nargin < 2)
    status='';
end;

if (nargin < 3)
    out_screen=1;
end;

if (nargin < 4)
    out_fileName='';
end;

if (nargin <5)
    date=0;
end;

if (date==0)
    mdate='';
else
    mdate=[datestr(now) ' '];
end;

Cmessage=[status mdate message];

if (out_screen==1)
    if (strfind(status,'error'))
        disp(' ');
    end;
    disp(Cmessage);
    if (strfind(status,'error'))
        disp('Number of Processed Particles:        ');
        pause(2);
    end;
 end;

if (isempty(out_fileName)==0)
    fid=fopen(out_fileName,'a');
    fprintf(fid,'%s\n',Cmessage);
    fclose(fid);
end;



