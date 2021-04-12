function varmodel = tom_spider_create_variancemodels(paramsfile, stackfile, method, nummodels, factor, symmetry)

if nargin < 6
    symmetry = 'C1';
end

if nargin < 5
    factor = 0.2;
end

if nargin < 4
    nummodels = 2000;
end

if nargin < 3
    method = 'fixedpercentage';
end

if nargin < 2
    error('At least 2 input parameters required');
end

workdir = pwd;

%get histogram of classes
A = importdata(paramsfile);
numclasses = max(A.data(:,6));
n = histc(A.data(:,6),1:numclasses);

selection = struct();


%loop over all class numbers
for i=1:numclasses
    %find the indices of all particles in this class
    indx = find(A.data(:,6) == i);
    
    if ~isempty(indx)
        
        for j=1:nummodels
            %get random sample from class
            switch method
                case 'fixedpercentage'
                    if factor > 1 || factor < 0
                        error('Factor must be between 0 and 1.');
                    end
                    R = sort(randsample(indx,ceil(numel(indx).*factor)));
                case 'fixednumber'
                    if factor > numel(indx)
                        R = indx;
                    else
                        R = sort(randsample(indx,factor));
                    end
                    
                otherwise
                    error('Unknown method.');
            end
            
            try
                selection(j).particles = [selection(j).particles; R];
            catch
                selection(j).particles = R;
            end
            
        end
    end
    
    
end

%write doc files with particle selection for each model
for i=1:nummodels
    fid = fopen(['selection_' num2str(i) '.spi'],'wt');
    l = 1;
    for j=1:numel(selection(i).particles)
        fprintf(fid,'%g 1 %g\n',l,selection(i).particles(j));
        l = l + 1;
    end
    fclose(fid);
end

%write symmetry file
if ~strcmp(symmetry,'C1')
    
    fid = fopen('create_symfile.bat','wt');
    fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');
    fprintf(fid,'SY\nsym\n');
    switch upper(symmetry(1))
        case 'C'
            fprintf(fid, 'C\n');
        case 'D'
            fprintf(fid, 'CI\n');
        otherwise
            error('Unknown symmetry');
    end
    if isempty(str2double(symmetry(2))) || length(symmetry) > 3 || length(symmetry) < 2
        error('Unknown symmetry');
    end
    fprintf(fid, [symmetry(2) '\n\n']);
    
    fprintf(fid,'en\n');
    fclose(fid);
    
    tom_spider_run_process(workdir,'create_symfile');
    symflag = true;
else
    symflag = false;
end

%write spider bat files for each model
for i=1:nummodels
    fid = fopen(['backproject_variancemodel_' num2str(i) '.bat'],'wt');
    fprintf(fid,'MD\nTR OFF\nMD\nVB OFF\n\n');
    fprintf(fid,'BP 3F\n');
    
    [pathstr, name] = fileparts(stackfile); 
    fprintf(fid,[name '@*******\n']);
    fprintf(fid,['selection_' num2str(i) '\n']);
    fprintf(fid,[paramsfile '\n']);
    if symflag == true
        fprintf(fid,'sym\n');
    else
        fprintf(fid,'*\n');
    end
    fprintf(fid,['variance_model' num2str(i) '\n']);
    fprintf(fid,'en\n');
    fclose(fid);
end


%reconstruct the volumes
parfor i=1:nummodels
    tom_spider_run_process(workdir,['backproject_variancemodel_' num2str(i)]);
end


%calculate the variance map
h = tom_readspiderheader('variance_model1.spi');
model = zeros(h.Header.Size(1),h.Header.Size(2),h.Header.Size(3),nummodels,'single');
for i=1:nummodels
    m = tom_spiderread(['variance_model' num2str(i) '.spi']);
    model(:,:,:,i) = m.Value;
end
varmodel = var(model,0,4);


function success = tom_spider_run_process(workdir,sp_fcn)

    [s,w] = unix(['cd ' workdir ' ; /raid5/apps/titan/spider/bin/spider bat/spi @' sp_fcn]);
    %[s,w] = unix(['cd ' workdir ' ; /usr/local/apps/spider/bin/spider bat/spi @' sp_fcn]);

if findstr(w,'**** SPIDER NORMAL STOP ****')
    success = 1;
else 
    disp('***************************************************');
    disp('***************************************************');
    disp('ERROR:');
    disp('***************************************************');
    disp('***************************************************');
    disp(w);
    error('Aborted due to spider error');
end


