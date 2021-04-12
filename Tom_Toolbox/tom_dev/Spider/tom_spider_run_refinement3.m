function tom_spider_run_refinement3(stackfilename, reffilename, workdir, refinement_struct, maxshift, numcpus)

if isempty(stackfilename) 
    stackfilename = [workdir '/stacks/stack.spi'];
end

if isempty(reffilename) 
    reffilename = [workdir '/3D/model0.spi'];
end

h = tom_readspiderheader(stackfilename);

if nargin < 6
    numcpus =23;
end

if nargin < 5
    maxshift = 5;
end

numcpus=8;

%ringstop = h.Header.Size(1)./2-maxshift-2;
ringstop =24;

if exist([workdir '/restart.mat'],'file') ~= 2

    if nargin < 4
        refinement_struct.restrict = [0,0,0,0];
        refinement_struct.subiter = [15,15,15,15];
        refinement_struct.angles.deltatheta = [10,5,2.5,1];
        refinement_struct.angles.thetastart = [0,0,0,0];
        refinement_struct.angles.thetastop = [90,90,90,90];
        refinement_struct.angles.phistart = [0,0,0,0];
        refinement_struct.angles.phistop = [359.9,359.9,359.9,359.9];
        refinement_struct.usesym = [false, false, false, false];
    end


    %create restart structure
    %==========================================================================

    spider_restartstruct = struct();

    spider_restartstruct.ncpus = numcpus;
    spider_restartstruct.niter = sum(refinement_struct.subiter);
    spider_restartstruct.maxshift = maxshift;
    spider_restartstruct.create_directories = false;
    if sum(refinement_struct.usesym) > 0
        spider_restartstruct.create_symmetryfile = false;
    end

    r = 1;
    spider_restartstruct.angles = zeros(spider_restartstruct.niter,5);

    for k=1:spider_restartstruct.niter

        spider_restartstruct.angles(k,:) = [refinement_struct.angles.deltatheta(r),refinement_struct.angles.thetastart(r), refinement_struct.angles.thetastop(r),refinement_struct.angles.phistart(r), refinement_struct.angles.phistop(r)];
        if k==1
            spider_restartstruct.restrict(k) = 0;
        else
            spider_restartstruct.restrict(k) = refinement_struct.restrict(r);
        end
        refinement_struct.usesym(k) = refinement_struct.usesym(r);
        spider_restartstruct.iter(k).create_anglesfile = false;
        spider_restartstruct.iter(k).create_references = false;
        spider_restartstruct.iter(k).find_alignment = false;
        spider_restartstruct.iter(k).combine_alignment = false;
        spider_restartstruct.iter(k).do_alignment = false;
        spider_restartstruct.iter(k).backproject = false;
        spider_restartstruct.iter(k).filter_volume = false;
        spider_restartstruct.iter(k).sirt = false;
    
        if mod(k,refinement_struct.subiter(r)) == 0
            r = r+1;
        end

    end
else
    disp('');
    disp('**************************************');
    disp('***      Restarting refinement     ***');
    disp('**************************************'); 
    disp('');
    disp('');
    load([workdir '/restart.mat']);
end

%main program
%==========================================================================

%create directories
if spider_restartstruct.create_directories == false;
    tom_spider_create_directories(workdir);
    spider_restartstruct.create_directories = true;
    save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
end

%create symmetry file
if sum(refinement_struct.usesym) > 0 && spider_restartstruct.create_symmetryfile == false
    tom_spider_create_symfile(workdir);
    spider_restartstruct.create_symmetryfile = true;
    save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
end

package = tom_calc_packages(numcpus,h.Header.Spider.maxim);

%loop over refinement iterations
iter = 1;

while iter<spider_restartstruct.niter
    disp(' ');
    disp(' ');
    disp('*****************************');    
    disp(['Iteration ' num2str(iter) ' of ' num2str(spider_restartstruct.niter)]);
    disp('*****************************');
    
    restrict_iter = spider_restartstruct.restrict(iter);
    angles_iter = spider_restartstruct.angles(iter,:);

    if restrict_iter == 0
        restrict_iter  = [];
    end
    
    %create angles file
    if spider_restartstruct.iter(iter).create_anglesfile == false
        tom_spider_create_anglesfile(workdir,angles_iter,iter);
        spider_restartstruct.iter(iter).create_anglesfile = true;
        save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
    end
    
    %project references
    if spider_restartstruct.iter(iter).create_references == false
        numang = tom_spider_create_references(workdir,iter);
        spider_restartstruct.iter(iter).create_references = true;  
        save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
    end
    
    %finding alignment parameters
    if spider_restartstruct.iter(iter).find_alignment == false
        disp('    Finding alignment...');
        if exist('numang','var') ~= 1
            numang = tom_spider_find_max_key([workdir '/logs/refangles' num2str(iter) '.spi']);
        end

        parfor (i=1:numcpus)
            p = [package(i,1:2),i];
            tom_spider_find_alignment(workdir,iter,numang,restrict_iter,maxshift,ringstop,p);
        end
        spider_restartstruct.iter(iter).find_alignment = true; 
        save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
    end
    
    %combining alignment parameters
    if spider_restartstruct.iter(iter).combine_alignment == false
        tom_spider_combine_alignment(workdir,iter,numcpus);
        spider_restartstruct.iter(iter).combine_alignment = true;
        save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
    end
    
    %aligning particles
    if spider_restartstruct.iter(iter).do_alignment == false
        disp('    Applying alignment...');
        parfor (i=1:numcpus)
            p = [package(i,1:2),i];
            tom_spider_align_particles(workdir,iter,p);
        end
        spider_restartstruct.iter(iter).do_alignment = true;  
        save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
    end
    
    %backprojection of new model
    if spider_restartstruct.iter(iter).sirt == false
        %tom_spider_sirt(workdir,iter,refinement_struct.usesym(iter));
        spider_restartstruct.iter(iter).sirt = true;
    end
    
    if spider_restartstruct.iter(iter).backproject == false
        tom_spider_backproject(workdir,iter,true,refinement_struct.usesym(iter));
        spider_restartstruct.iter(iter).backproject = true; 
        save([workdir '/restart.mat'],'spider_restartstruct','refinement_struct');
    end
    
    %test for Bushido error
    tmp1 = tom_spiderread([workdir '/3D/model' num2str(iter) '.spi']);
    if max(max(max(tmp1.Value))) > 1e6 || (mean(mean(mean(tmp1.Value))) == 0 && max(max(max(tmp1.Value))) == 0 && min(min(min(tmp1.Value))))
        disp('Reconstruction error, beat up system administrator, restarting current iteration.')
        spider_restartstruct.iter(iter).create_references = false;
        spider_restartstruct.iter(iter).find_alignment = false;
        spider_restartstruct.iter(iter).combine_alignment = false;
        spider_restartstruct.iter(iter).do_alignment = false;
        spider_restartstruct.iter(iter).backproject = false;
        spider_restartstruct.iter(iter).create_anglesfile = false;
        spider_restartstruct.iter(iter).filter_volume = false;
        spider_restartstruct.iter(iter).sirt = false;
        continue;
    end
    
    %calculate resolution and filter volume 
    if spider_restartstruct.iter(iter).filter_volume == false
        tmp1 = tom_spiderread([workdir '/3D/model' num2str(iter) '_half1.spi']);
        tmp2 = tom_spiderread([workdir '/3D/model' num2str(iter) '_half2.spi']);
        res = tom_compare(tmp1.Value,tmp2.Value,h.Header.Size(1)./2);
        par.interpolation = 'linear';
        ind = tom_crossing(res(:,9),[],0.5,par);

        if isempty(ind)
            disp('Reconstruction error, beat up system administrator, restarting current iteration.')
            spider_restartstruct.iter(iter).create_references = false;
            spider_restartstruct.iter(iter).find_alignment = false;
            spider_restartstruct.iter(iter).combine_alignment = false;
            spider_restartstruct.iter(iter).do_alignment = false;
            spider_restartstruct.iter(iter).backproject = false;
            spider_restartstruct.iter(iter).create_anglesfile = false;
            spider_restartstruct.iter(iter).filter_volume = false;
            spider_restartstruct.iter(iter).sirt = false;
            continue;
        else
            ind = ind(end);
        end

        ind = ind./h.Header.Size(1);
        %ind = .3;
        tom_spider_filter_volume(workdir,iter,ind);
        spider_restartstruct.iter(iter).filter_volume = true;
    end
    
    iter = iter+1;
    
end



%--------------------------------------------------------------------------
% find highest key in spider doc file
%--------------------------------------------------------------------------
function maxkey = tom_spider_find_max_key(docfile)

fid = fopen(docfile,'rt');
lastline = '';

while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end
    lastline = tline;
end

maxkey = textscan(lastline, '%u', 1);
maxkey = maxkey{1};


%--------------------------------------------------------------------------
% create symmetry file
%--------------------------------------------------------------------------
function tom_spider_create_directories(workdir)

disp('Creating directories');

if exist(workdir,'dir') ~= 7
    mkdir(workdir);
end
if exist([workdir '/logs'],'dir') ~= 7
    mkdir([workdir '/logs']);
end
if exist([workdir '/stacks'],'dir') ~= 7
    mkdir([workdir '/stacks']);
end
if exist([workdir '/3D'],'dir') ~= 7
    mkdir([workdir '/3D']);
end
%unix(['chmod -R 777 ' workdir]);


%--------------------------------------------------------------------------
% create symmetry file
%--------------------------------------------------------------------------
function tom_spider_create_symfile(workdir)

disp('Creating symmetry file');

if exist([workdir '/sym.spi'],'file') == 2
    delete([workdir '/sym.spi']);
end

fid = fopen([workdir '/create_symfile.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');

fprintf(fid,'SY\nsym\nCI\n2\n\n');
fprintf(fid,'en\n');

fclose(fid);

tom_spider_run_process(workdir,'create_symfile');


%--------------------------------------------------------------------------
% Create angular increment file
%--------------------------------------------------------------------------
function numang = tom_spider_create_anglesfile(workdir,angles,iter)

disp('    Creating angles file');

if exist([workdir '/logs/refangles' num2str(iter) '.spi'],'file') == 2
    delete([workdir '/logs/refangles' num2str(iter) '.spi']);
end

fid = fopen([workdir '/create_anglesfile.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');

fprintf(fid,'VO EA\n');
fprintf(fid,[num2str(angles(1)) '\n']);
fprintf(fid,['(' num2str(angles(2)) ',' num2str(angles(3)) ')\n']);
fprintf(fid,['(' num2str(angles(4)) ',' num2str(angles(5)) ')\n']);
fprintf(fid,['logs/refangles' num2str(iter) '\n\n']);
fprintf(fid,'en\n');


fclose(fid);

tom_spider_run_process(workdir,'create_anglesfile');

if nargout == 1
    numang = tom_spider_find_max_key([workdir '/logs/refangles' num2str(iter) '.spi']);
end


%--------------------------------------------------------------------------
% Project references
%--------------------------------------------------------------------------
function numang = tom_spider_create_references(workdir,iter)

h = tom_readspiderheader([workdir '/3D/model' num2str(iter-1) '.spi']);
numang = tom_spider_find_max_key([workdir '/logs/refangles' num2str(iter) '.spi']); 

disp(['    Creating ' num2str(numang) ' references']);

fid = fopen([workdir '/create_projections.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');
fprintf(fid,'MD\nSET MP\n0\n\n');

fprintf(fid,'PJ 3Q\n');
fprintf(fid,['3D/model' num2str(iter-1) '\n']);
fprintf(fid,[num2str(h.Header.Size(1)) '\n']);
fprintf(fid,['(1-' num2str(numang) ')\n']);
fprintf(fid,['logs/refangles' num2str(iter) '\n']);
fprintf(fid,['stacks/references' num2str(iter) '@*****\n\n']);
fprintf(fid,'en\n');

fclose(fid);

try
    tom_spider_run_process(workdir,'create_projections');
catch
    tom_spider_run_process(workdir,'create_projections');
end
    

%--------------------------------------------------------------------------
% merge alignment parameters
%--------------------------------------------------------------------------
function tom_spider_combine_alignment(workdir,iter,numcpu)

disp(['    Combining ' num2str(numcpu) ' alignment parameter files']);
if numcpu>1

fid = fopen([workdir '/combine_alignment.bat'],'wt');

if exist([workdir '/logs/alignmentparams' num2str(iter) '.spi'],'file') == 2
    delete([workdir '/logs/alignmentparams' num2str(iter) '.spi']);
end

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');

fprintf(fid,'DOC MERGE\n');
fprintf(fid,['logs/alignmentparams' num2str(iter) '_1\n']);
fprintf(fid,['logs/alignmentparams' num2str(iter) '_2\n']);
fprintf(fid,['logs/alignmentparams' num2str(iter) '\n']);
fprintf(fid,'0\n\n');

for i=3:numcpu
    fprintf(fid,'DOC MERGE\n');
    fprintf(fid,['logs/alignmentparams' num2str(iter) '\n']);
    fprintf(fid,['logs/alignmentparams' num2str(iter) '_' num2str(i) '\n']);
    fprintf(fid,['logs/alignmentparams' num2str(iter) '\n']);
    fprintf(fid,'0\n\n');
end

fprintf(fid,'en\n');

fclose(fid);

try
    tom_spider_run_process(workdir,'combine_alignment');
catch
    tom_spider_run_process(workdir,'combine_alignment');
end


else
    copyfile(['logs/alignmentparams' num2str(iter) '_1.spi'],['logs/alignmentparams' num2str(iter) '.spi'] );
    
    
end;



%--------------------------------------------------------------------------
% find alignment parameters
%--------------------------------------------------------------------------
function tom_spider_find_alignment(workdir,iter,numang,restrict,maxshift,ringstop,package)

%disp(['    Finding alignment for particles ' num2str(package(1)) ' - ' num2str(package(2))]);

if exist([workdir 'logs/alignmentparams' num2str(iter) '_' num2str(package(3)) '.spi'],'file') == 2
    delete([workdir 'logs/alignmentparams' num2str(iter) '_' num2str(package(3)) '.spi']);
end

fid = fopen([workdir '/find_alignment_' num2str(package(3)) '.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');

fprintf(fid,'AP SH\n');
fprintf(fid,['stacks/references' num2str(iter) '@*****\n']);
fprintf(fid,['(1-' num2str(numang) ')\n']);
fprintf(fid,['(' num2str(maxshift) ',1)\n']);
fprintf(fid,['(1,' num2str(ringstop) ')\n']);
fprintf(fid,['logs/refangles' num2str(iter) '\n']);
if isempty(restrict)
    fprintf(fid,'stacks/stack@*******\n');
else
   fprintf(fid,['stacks/stack_aligned' num2str(iter-1) '@*******\n']);
end
fprintf(fid,['(' num2str(package(1)) '-' num2str(package(2)) ')\n']);

if isempty(restrict)
    fprintf(fid,'*\n(0)\n');
else
    fprintf(fid,['logs/alignmentparams' num2str(iter-1) '\n']);
    fprintf(fid,['(' num2str(restrict) ',0)\n']);
end
fprintf(fid,'(1)\n');
fprintf(fid,['logs/alignmentparams' num2str(iter) '_' num2str(package(3)) '\n\n']);
fprintf(fid,'en\n');

fclose(fid);

try
    tom_spider_run_process(workdir,['find_alignment_' num2str(package(3))]);
catch
    tom_spider_run_process(workdir,['find_alignment_' num2str(package(3))]);
end


%--------------------------------------------------------------------------
% align particles according to alignment parameter file
%--------------------------------------------------------------------------
function tom_spider_align_particles(workdir,iter,p)

%disp(['    Applying alignment for particles ' num2str(p(1)) ' - ' num2str(p(2))]);

fid = fopen([workdir '/align_particles_' num2str(p(3)) '.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');

fprintf(fid,['DO [iter]=' num2str(p(1)) ',' num2str(p(2)) '\n']);
fprintf(fid,'UD IC [iter],[dummy],[dummy],[dummy],[dummy],[dummy],[ROT],[SX],[SY]\n');
fprintf(fid,['logs/alignmentparams' num2str(iter) '\n\n']);

fprintf(fid,'RT SQ\n');
fprintf(fid,'stacks/stack@{*******[iter]}\n');
fprintf(fid,['stacks/stack_aligned' num2str(iter) '@{*******[iter]}\n']);
fprintf(fid,'([ROT],1.0)\n');
fprintf(fid,'([SX],[SY])\n');

fprintf(fid,'ENDDO\n');

fprintf(fid,['UD ICE\nlogs/alignmentparams' num2str(iter) '\n\n']);

fprintf(fid,'en\n');

fclose(fid);

try
    tom_spider_run_process(workdir,['align_particles_' num2str(p(3))]);
catch
    tom_spider_run_process(workdir,['align_particles_' num2str(p(3))]);
    fid = fopen('/fs/pool/pool-nickell/tmp/ioerrors.txt','at');
    fprintf(fid,datestr(now));
    fclose(fid);
end

%--------------------------------------------------------------------------
% align particles according to alignment parameter file
%--------------------------------------------------------------------------
function tom_spider_filter_volume(workdir,iter,cutoff)

%copyfile([workdir '/3D/model' num2str(iter) '.spi'],[workdir '/3D/model' num2str(iter) '_unfiltered.spi']);
unix(['cp ' workdir '/3D/model' num2str(iter) '.spi ' workdir '/3D/model' num2str(iter) '_unfiltered.spi']);

lo = cutoff - 0.05;
hi = cutoff + 0.05;
disp(['    Filtering volume at cutoff ' num2str(cutoff)]);
fid = fopen([workdir '/filter_volume.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');

fprintf(fid,'FQ\n');
fprintf(fid,['3D/model' num2str(iter) '_unfiltered\n']);
fprintf(fid,['3D/model' num2str(iter) '\n']);
fprintf(fid,'7\n');
fprintf(fid,[num2str(lo) ',' num2str(hi) '\n\n']);
fprintf(fid,'EN\n');

try
    tom_spider_run_process(workdir,'filter_volume');
catch
    tom_spider_run_process(workdir,'filter_volume');
end

fclose(fid);


%--------------------------------------------------------------------------
% align particles according to alignment parameter file
%--------------------------------------------------------------------------
function tom_spider_backproject(workdir,iter,resolutionflag,symflag)

disp('    Backprojection of new model');

h = tom_readspiderheader([workdir '/stacks/stack.spi']);

fid = fopen([workdir '/backproject.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');
fprintf(fid,'MD\nSET MP\n0\n\n');

if resolutionflag == true
    fprintf(fid,'BP 32F\n');
else
    fprintf(fid,'BP 3F\n');
end

fprintf(fid,['stacks/stack_aligned' num2str(iter) '@*******\n']);
fprintf(fid,['(1-' num2str(h.Header.Spider.maxim) ')\n']);
fprintf(fid,['logs/alignmentparams' num2str(iter) '\n']);

if symflag == true
    fprintf(fid,'sym\n');
else
    fprintf(fid,'*\n');
end

fprintf(fid,['3D/model' num2str(iter) '\n']);

if resolutionflag == true
    fprintf(fid,['3D/model' num2str(iter) '_half1\n']);
    fprintf(fid,['3D/model' num2str(iter) '_half2\n']);
else

end

fprintf(fid,'en\n');

fclose(fid);

try
    tom_spider_run_process(workdir,'backproject');
catch
    tom_spider_run_process(workdir,'backproject');
end

%--------------------------------------------------------------------------
% align particles according to alignment parameter file
%--------------------------------------------------------------------------
function tom_spider_sirt(workdir,iter,symflag)

disp('    Creating of new model using SIRT');

h = tom_readspiderheader([workdir '/stacks/stack.spi']);

fid = fopen([workdir '/sirt.bat'],'wt');

fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');
fprintf(fid,'MD\nSET MP\n0\n\n');

fprintf(fid,'BP RP\n');

fprintf(fid,['stacks/stack_aligned' num2str(iter) '@*******\n']);
fprintf(fid,['(1-' num2str(h.Header.Spider.maxim) ')\n']);
fprintf(fid,[num2str(h.Header.Size(1)./2-2) '\n']);
fprintf(fid,['logs/alignmentparams' num2str(iter) '\n']);

if symflag == true
    fprintf(fid,'sym\n');
else
    fprintf(fid,'*\n');
end

fprintf(fid,['3D/model' num2str(iter) '_sirt\n']);
fprintf(fid,'(0.2e-5,0)\n');
fprintf(fid,'(60,0)\n');
fprintf(fid,'(.5,.5)\n');
fprintf(fid,'(.5)\n');

fprintf(fid,'en\n');

fclose(fid);

try
    tom_spider_run_process(workdir,'sirt');
catch
    tom_spider_run_process(workdir,'sirt');
end


%--------------------------------------------------------------------------
% run spider process
%--------------------------------------------------------------------------
function success = tom_spider_run_process(workdir,sp_fcn)


[s,w] = unix(['cd ' workdir ' ; /raid5/apps/titan/spider/bin/spider bat/spi @' sp_fcn]);
%[s,w] = unix(['cd ' workdir ' ; /usr/local/apps/spider/bin/spider bat/spi @' sp_fcn]);

if findstr(w,'**** SPIDER NORMAL STOP ****')
    success = 1;
else 
    success = 0;
    disp('***************************************************');
    disp('***************************************************');
    disp('ERROR:');
    disp('***************************************************');
    disp('***************************************************');
    disp(w);
    error('Aborted due to spider error');
end

