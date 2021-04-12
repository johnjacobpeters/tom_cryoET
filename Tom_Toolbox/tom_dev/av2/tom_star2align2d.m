function align2d=tom_star2align2d(starFileIn,newImgRoot,newImgExt,outputName,flavour,coordinate_file_suffix)
% tom_star2doc transforms a star file into a align2d file
%  
%     align2d=tom_star2align2d(starFile,newImgRoot,newImgExt,outputName,flavour)
%  
%  PARAMETERS
%  
%    INPUT
%     starFileIn                   filename or struct of the starfile which should be transformed
%     newImgRoot                 ('') new root of the images 
%     newImgExt                  ('') new image extnesion 
%     outputName                 ('') outputfilename
%     flavour                    ('relion') so far only relion implemented!
%     coordinate_file_suffix     ('_autopick.star') opt for reading relionpickLists     
% 
%    OUTPUT
%      align2d          output align2d      
%                          
%  
%  EXAMPLE
%     %all particles are from one datasete
%     tom_star2align2d('cut_data.star','/fs/pool/pool-sakata/Marc/SPR/T1F2/data/001_141104__11BeF2/high/','.em','pick_high.mat');
%     
%     %particles from mult datasets
%     tom_star2align2d('select2D_run2.star','/log/partsRelionTmp/high/Particles/','/high/','pick_high.mat','relion-Find&Replace');
%    
%     %all read relion pickLists
%     tom_star2align2d('aligned/myImg*_single.star','/fs/test/data/high/','.mrc','pick_test.mat','relion','_single.star');
%   
%
%
%  REFERENCES
%  
%  NOTE:
%  
%
%  SEE ALSO
%      tom_av2_xmipp_doc2star,tom_starread,tom_xmippdocread,tom_starwrite
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


if (nargin < 4)
    outputName='';
end;

if (nargin < 5)
    flavour='relion';
end;

if (nargin < 6)
    coordinate_file_suffix='_autopick.star';
end;

d=dir(starFileIn);

if (isempty(d))
    error(['no files in: ' starFileIn]);
end;

disp(['found ' num2str(length(d)) ' star files in ' starFileIn] );


[a,b,c]=fileparts(starFileIn);
if (isempty(a))
    rootPath='';
else
    rootPath=[a filesep];
end;

alignAll='';
for iff=1:length(d)
    starFile=[rootPath d(iff).name];
    
    if (isstruct(starFile))
        star_st=starFile;
        clear(starFile);
    else
        star_st=tom_starread(starFile,'struct');
    end;
    
    if (isfield(star_st,'rlnMicrographName')==0);
        microName=[strrep(starFile,coordinate_file_suffix,'') '.mrc'];
        if (strcmp(strrep(starFile,coordinate_file_suffix,''),starFile)==1)
            error(['wrong relion coordinate_file_suffix: ' coordinate_file_suffix]);
        end;
        [~,tmpName,c]=fileparts(microName);
        
        microName=[newImgRoot filesep tmpName c];
        for i=1:length(star_st)
            star_st(i).rlnMicrographName=microName;
        end;
    end;
    
    disp(['Input star file Length: ' num2str(length(star_st))]);
    align2d=allocAlign2d(length(star_st));
    for i=1:length(star_st)
        align2d(1,i)=tansFormEntry(star_st(i),align2d(1,i),newImgRoot,newImgExt,flavour);
    end;
    alignAll=cat(2,alignAll,align2d);
    disp(['tot number: ' num2str(size(alignAll,2)) ]);
    if mod(iff,10)==0
        disp([num2str(iff) ' of ' num2str(length(d)) ]);
    end;
end;
align2d=alignAll;
disp(['output align file Length: ' num2str(size(align2d,2))]);

if (isempty(outputName)==0)
    disp(['writing to: ' outputName]);
    save(outputName,'align2d','-v7.3');
end;


function alignEntry=tansFormEntry(starEntry,alignEntry,newImgRoot,newImgExt,flavour)

if (strcmp(flavour,'relion'))
    alignEntry.position.x = starEntry.rlnCoordinateX;
    alignEntry.position.y = starEntry.rlnCoordinateY;
    
    alignEntry.radius = 0;
    if (isempty(newImgRoot))
        alignEntry.filename=starEntry.rlnMicrographName;
    else
        [~,imgName]=fileparts(starEntry.rlnMicrographName);
        alignEntry.filename=[newImgRoot filesep imgName newImgExt];
    end;
end;



if (strcmp(flavour,'relion-Find&Replace'))
    alignEntry.position.x = starEntry.rlnCoordinateX;
    alignEntry.position.y = starEntry.rlnCoordinateY;
    alignEntry.radius = 0;
    if (isempty(newImgRoot))
        alignEntry.filename=starEntry.rlnMicrographName;
    else
        [~,imgName]=fileparts(starEntry.rlnMicrographName);
        [~,baseP]=strtok(starEntry.rlnImageName,'@');
        baseP=strrep(baseP,'@','');
        baseP=fileparts(baseP);
        if (newImgRoot(end)=='/')
           newImgRoot=newImgRoot(1:(end-1));  
        end;
        basePOld=baseP;
        baseP=strrep(baseP,newImgRoot,newImgExt);
        if (strcmp(baseP,basePOld))
          warning('find and replace template not found ...check your template');   
        end;
        alignEntry.filename=[baseP filesep  imgName  '.em'];
        alignEntry.filename=strrep(alignEntry.filename,'//','/');
    end;
end;




function align2d=allocAlign2d(nrEntries)


for pointnumber=1:nrEntries
    align2d(1,pointnumber).dataset = '';
    align2d(1,pointnumber).filename = '';
    align2d(1,pointnumber).position.x = 0;
    align2d(1,pointnumber).position.y = 0;
    align2d(1,pointnumber).class = 'default';
    align2d(1,pointnumber).radius = 0;
    align2d(1,pointnumber).color = [0 1 0];
    align2d(1,pointnumber).shift.x = 0;
    align2d(1,pointnumber).shift.y = 0;
    align2d(1,pointnumber).angle = 0;
    align2d(1,pointnumber).isaligned = 0;
    align2d(1,pointnumber).ccc = 0;
    align2d(1,pointnumber).quality = 0;
    align2d(1,pointnumber).normed = 'none';
    align2d(1,pointnumber).ref_class = 0;
end







