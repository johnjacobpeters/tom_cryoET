function dircell = tom_HT_getdircontents(directory,typecell,waitbarflag)

if nargin < 3
    waitbarflag = 0;
end

if nargin == 1
    error('no type cell given');
elseif nargin == 0
    error('no directory name given');
end

%if waitbarflag == 1
%    h = waitbar(0,'Getting directory list...');
%end

dirlist = dir(directory);
dirlist = dirlist(3:end);
files = size(dirlist,1);
fraction = ceil(files./100);

j=1;
for i = 1:files
    if dirlist(i).isdir == 0
        if sum(cellfun(@(s)strcmp(s,'em'),typecell)) > 0
            if tom_isemfile([directory '/' dirlist(i).name]) == 1
                dircell{j} = dirlist(i).name;
                j = j+1;
            end
        elseif sum(cellfun(@(s)strcmp(s,'spi'),typecell)) > 0
            if tom_isspiderfile([directory '/' dirlist(i).name]) == 1
                dircell{j} = dirlist(i).name;
                j = j+1;
            end
        end
    end
    if waitbarflag == 1 && mod(i,fraction) == 0
        %waitbar(i./files,h,[num2str(i), ' of ', num2str(files), ' files scanned.']);
        tom_HT_waitbar(i./files, [num2str(i), ' of ', num2str(files), ' files scanned.']);
    end
end


%if waitbarflag == 1
    tom_HT_waitbar(1,'finished');
%end

if ~exist('dircell','var') 
    if waitbarflag == 1
        errordlg('No files of specified type could be found in this directory.');
        dircell={};
        return;
    else
        error('No files of specified type could be found in this directory.');
    end
end

dircell = sort_nat(dircell);


