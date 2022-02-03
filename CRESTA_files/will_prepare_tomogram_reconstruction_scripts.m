%% will_prepare_tomogram_reconstruction_scripts
% A script to read in a tomo_list and prepare a set of reconstruction
% scripts. The script will then set up scripts for parallel reconstruction
% on the cluster. 
%
% The script will start by generating a bin-1 tomogram. Additional binnings
% can be performed. They will be binned serially, i.e. bin 1,2,4 will be
% done by binning 2 from 1, and 4 from 2. 
%
% The reconstruction workflow is from Flo's lsf_reconstruct_final scripts,
% from 20141205. The reconstruction makes use of IMOD, and assumes you've
% already performed the subtomogram alignment in etomo. 
%
% WW 09-2016

%% Inputs

% Tilt-stack inputs
prefix = '0';
suffix = '_dose-filt';
digits = 2;
main_folder = '/fs/gpfs03/lv03/pool/pool-plitzko/will_wan/gasv/tomo/full/';
tomo_list = 'temp_list.txt';
tomo_dir = '/fs/gpfs03/lv03/pool/pool-plitzko/will_wan/gasv/tomo/full/bin';

% Alternate IMOD options
source_imod = 1;
source_command = '/fs/gpfs03/lv03/pool/pool-plitzko/will_wan/software/imod_4.9.4_RHEL6-64_CUDA8.0/IMOD/IMOD-linux.sh';

% Copy headers? (requires a beta-imod)
copy_headers = 1;

% Aligned stack parameters
ali_check = 0;                   % (1-yes/0-no/2-skip stack generation) If no, any stacks will be overwritten
tomosize1 = 3696;
tomosize2 = 3696;
interpolation = 'cubic';      % Linear, cubic or nearest (neighbour)  interpolation

% Gold bead erasing
erase_gold = 1;
goldradius = 26;

% Taper stack
taper = 1;
n_taper_pixels = 100;

% CTF correction
ctfcorr = 0;
pixelsize = 2.26;
ccs = 2.7; 
voltage = 300;
amplitudecontrast = 0.07;
deftolerance = 25;
interwidth = 4;
maxwidth = 1024;

% Reconstruct tomogram
rec_tomo = 1;
cos_str = 0;

% Rotate tomogram
rot_tomo = 1;

% Bin?
bins = [];

% Antialiasing mode
antialias = 5;

% Batch size (number of tomograms per core)
batch_num = 1;





%% Parse inputs
disp('Initializing');

% Read in tomo_list
tomolist = dlmread([main_folder,tomo_list]);
n_tomos = size(tomolist,1);


% Number of jobs
n_jobs = ceil(n_tomos/batch_num);

% Get indices for batches
job_array = zeros(n_jobs,2);
for i = 1:n_jobs
    job_array(i,1) = (batch_num*(i-1))+1;
    job_array(i,2) = job_array(i,1)+batch_num-1;
end
if job_array(end,2) > n_tomos
    job_array(end,2) = n_tomos;
end

if strcmp(interpolation,'cubic')
    interpolation = [];
elseif strcmp(interpolation, 'linear')
    interpolation = '-linear';
elseif strcmp(interpolation, 'nearest')
    interpolation = '-nearest';
else
    error('Achtung!!! Invalid interpolation method!')
end

%% Generate reconstruction scripts
disp('Writing out tomogram scripts');

for i = 1:n_jobs
    
    % Initialize script ouptut
    script_output = fopen([main_folder,'tomo_reconstruct_',num2str(i)],'w');
    fprintf(script_output,['#!/bin/bash \n\n','echo $HOSTNAME\n','set -e \n','set -o nounset \n\n']);
    
    % Alternate IMOD Source
    if source_imod == 1
        fprintf(script_output,[['source ',source_command],'\n\n']);
    end

    % Restrict to single processor
    fprintf(script_output,'export IMOD_PROCESSORS="1"\n\n');
    
    % Loop through tomograms for each job
    for j = job_array(i,1):job_array(i,2)

        % Go to tomogram directory
        tomonum = sprintf(['%0',num2str(digits),'d'],(tomolist(j))); % Tomogram number string
        tomodir = [main_folder,prefix,tomonum,'/']; % Tomogram directory
        fprintf(script_output,['cd ',tomodir,'\n']);

        % Make header directory
        if copy_headers == 1
            if ~exist([tomodir,'headers'],'dir');
                mkdir([tomodir,'headers']);
            end
        end


        % Read in tilt.com
        fid = fopen([tomodir,'tilt.com']);
        tiltcom = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);

        % Parse out thickness
        idx_thick = find(~cellfun('isempty',strfind(tiltcom{1},'THICKNESS')),1,'first');
        thick = eval(tiltcom{1}{idx_thick}(10:end));

        % Parse out shift
        idx_shift = find(~cellfun('isempty',strfind(tiltcom{1},'SHIFT')),1,'first');
        shift = eval(tiltcom{1}{idx_shift}(11:end));

        % Parse out scaling
        idx_scale = find(~cellfun('isempty',strfind(tiltcom{1},'SCALE')),1,'first');
        scale = eval(tiltcom{1}{idx_scale}(11:end));


        % Create aligned stack
        if ali_check == 1
            if ~exist([tomodir,sprintf(['%0',num2str(digits),'d'],(tomolist(j))),'.ali'],'file')
                fprintf(script_output,['newstack -input ',tomonum,suffix,'.st -output ',tomonum,suffix,'.ali -xform *_fid.xf -size ',num2str(tomosize1),',',num2str(tomosize2),' -bin 1 -origin ',interpolation,'\n']);
                if (copy_headers == 1) && (erase_gold == 0) && (taper == 0)
                    fprintf(script_output,['copyheader ',tomonum,suffix,'.ali ./headers/',tomonum,suffix,'.ali.header','\n']);                end
            end
        elseif ali_check == 0
            fprintf(script_output,['newstack -input ',tomonum,suffix,'.st -output ',tomonum,suffix,'.ali -xform *_fid.xf -size ',num2str(tomosize1),',',num2str(tomosize2),' -bin 1 -origin ',interpolation,'\n']);
            if (copy_headers == 1) && (erase_gold == 0) && (taper == 0)
                fprintf(script_output,['copyheader ',tomonum,suffix,'.ali ./headers/',tomonum,suffix,'.ali.header','\n']);
            end
        end



        % Erase gold
        if erase_gold == 1
           fprintf(script_output,['ccderaser -input ',tomonum,suffix,'.ali -output ',tomonum,suffix,'.ali -ModelFile ',tomonum,suffix,'_erase.fid -BetterRadius ',num2str(goldradius),' -PolynomialOrder 0 -MergePatches -ExcludeAdjacent -CircleObjects /','\n']);
           if (copy_headers == 1) && (taper == 0)
                fprintf(script_output,['copyheader ',tomonum,suffix,'.ali ./headers/',tomonum,suffix,'.ali.header','\n']);
            end
        end

        % MRC Taper
        if taper == 1
            fprintf(script_output,['mrctaper -t ',num2str(n_taper_pixels),' ',tomonum,suffix,'.ali\n']);
            if copy_headers == 1
                fprintf(script_output,['copyheader ',tomonum,suffix,'.ali ./headers/',tomonum,suffix,'.ali.header','\n']);
            end
        end

        % CTF correction
        if ctfcorr == 1
            fprintf(script_output,['ctfphaseflip -input ',tomonum,suffix,'.ali -output ',tomonum,suffix,'_ctfcorr.ali -angleFn ',tomonum,suffix,'.tlt -defFn setfocus.txt  -defTol ',num2str(deftolerance),' -iWidth ',num2str(interwidth),' -maxWidth ',num2str(maxwidth),' -pixelSize ',num2str(pixelsize),' -volt ',num2str(voltage),' -cs ',num2str(ccs),' -ampContrast ',num2str(amplitudecontrast),'\n']);
            if copy_headers == 1
                fprintf(script_output,['copyheader ',tomonum,suffix,'_ctfcorr.ali ./headers/',tomonum,suffix,'_ctfcorr.ali.header','\n']);
            end
        end

        % Tomogram reconstruction
        if rec_tomo == 1
            if ctfcorr == 1
                fprintf(script_output,['tilt -InputProjections ',tomonum,suffix,'_ctfcorr.ali -OutputFile ',tomonum,'_full.rec -IMAGEBINNED 1 -TILTFILE *.tlt -THICKNESS ',num2str(thick),' -XAXISTILT 0.0 -XTILTFILE ',tomonum,suffix,'.xtilt -PERPENDICULAR -MODE 1 -FULLIMAGE ',num2str(tomosize1),',',num2str(tomosize2),' -SUBSETSTART 0,0 -AdjustOrigin -UseGPU 0 -ActionIfGPUFails 1,2 -COSINTERP ',num2str(cos_str),' -SHIFT 0.0,',num2str(shift),'\n']);
                if copy_headers == 1
                    fprintf(script_output,['copyheader ',tomonum,'_full.rec ./headers/',tomonum,'_full.rec.header','\n']);
                end
            elseif ctfcorr == 0
                fprintf(script_output,['tilt -InputProjections ',tomonum,suffix,'.ali -OutputFile ',tomonum,'_full.rec -IMAGEBINNED 1 -TILTFILE *.tlt -THICKNESS ',num2str(thick),' -XAXISTILT 0.0 -XTILTFILE ',tomonum,suffix,'.xtilt -PERPENDICULAR -MODE 1 -FULLIMAGE ',num2str(tomosize1),',',num2str(tomosize2),' -SUBSETSTART 0,0 -AdjustOrigin -UseGPU 0 -ActionIfGPUFails 1,2 -COSINTERP ',num2str(cos_str),' -SHIFT 0.0,',num2str(shift),'\n']);
                if copy_headers == 1
                    fprintf(script_output,['copyheader ',tomonum,'_full.rec ./headers/',tomonum,'_full.rec.header','\n']);
                end
            elseif ctfcorr == 2
                fprintf(script_output,['tilt -InputProjections ',tomonum,suffix,'_ctfcorr.ali -OutputFile ',tomonum,'_full.rec -IMAGEBINNED 1 -TILTFILE *.tlt -THICKNESS ',num2str(thick),' -XAXISTILT 0.0 -XTILTFILE ',tomonum,suffix,'.xtilt -PERPENDICULAR -MODE 1 -FULLIMAGE ',num2str(tomosize1),',',num2str(tomosize2),' -SUBSETSTART 0,0 -AdjustOrigin -UseGPU 0 -ActionIfGPUFails 1,2 -COSINTERP ',num2str(cos_str),' -SHIFT 0.0,',num2str(shift),'\n']);
                if copy_headers == 1
                    fprintf(script_output,['copyheader ',tomonum,'_full.rec ./headers/',tomonum,'_full.rec.header','\n']);
                end
            end
        end

        % Rotate tomogram
        if rot_tomo == 1
            fprintf(script_output,['trimvol -rx ',tomonum,'_full.rec ',tomo_dir,'1/',tomonum,'.rec','\n']);
            if copy_headers == 1
                fprintf(script_output,['copyheader ',tomo_dir,'1/',tomonum,'.rec ./headers/',tomonum,'.rec.header','\n']);            
            end
        end

        % Binning
        if round(bins) ~= 0
            % Number of bins
            n_bins = numel(bins);

            % First binning
            fprintf(script_output,['binvol -bin ',num2str(bins(1)),' -antialias ',num2str(antialias),' ',tomo_dir,'1/',tomonum,'.rec ',tomo_dir,num2str(bins(1)),'/',tomonum,'.rec','\n']);
            if copy_headers == 1
                fprintf(script_output,['copyheader ',tomo_dir,num2str(bins(1)),'/',tomonum,'.rec ./headers/',tomonum,'_bin',num2str(bins(1)),'.rec.header','\n']);
            end

            % Additional binnings
            if n_bins > 1
                for j = 2:n_bins

                    % Next binning
                    fprintf(script_output,['binvol -bin ',num2str(round(bins(j)/bins(j-1))),' -antialias ',num2str(antialias),' ',tomo_dir,num2str(bins(j-1)),'/',tomonum,'.rec ',tomo_dir,num2str(bins(j)),'/',tomonum,'.rec ','\n']);
                    if copy_headers == 1
                        fprintf(script_output,['copyheader ',tomo_dir,num2str(bins(j)),'/',tomonum,'.rec ./headers/',tomonum,'_bin',num2str(bins(j)),'.rec.header','\n']);
                    end
                end
            end
        end


        % Cleanup
        fprintf(script_output,['rm -rf *_full.rec *~ *.ali','\n']);



    end
    
    % Close file
    fclose(script_output);

    % Make script executable
    system(['chmod +x ',main_folder,'tomo_reconstruct_',num2str(i)]);

    disp(['Parallel script ',num2str(i),' of ',num2str(n_jobs),' generated!']);

end







