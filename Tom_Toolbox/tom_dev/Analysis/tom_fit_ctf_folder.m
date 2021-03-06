function tom_fit_ctf_folder(basepath,ext,outputpath,ctf_struct,corr_method,corr_cut_off,mtf_path,adapt_header_focus_search)
%TOM_FIT_CTF_FOLDER  fits images in a folder and corrects for ctf 
%
%   tom_fit_ctf_folder(basepath,ext,outputpath,ctf_struct,corr_method,corr_cut_off,mtf_path)
%
%     TOM_FIT_CTF_FOLDER fits images in a folder and corrects for ctf
% 
%
%
%PARAMETERS
%
%  INPUT
%   basepath                         original image
%   ext                              Fit structure from tom_fit_ctf_gui.m
%   outputpath                       outputpath for corr images 
%   ctf_struct                       struct with the information for fitting
%   corr_method                      method for phase flipping etc. 
%   corr_cut_of                      cutoff frequency in pixel
%   mtf_path                         not implemented !!!!!!!!!!!
%   adapt_header_focus_search        reads the intended defocus setting
%                                    from the image header and adapts the
%                                    defocus-search accordingly.
%                                    (0=off(default), 1=on)
%
%  OUTPUT
%
%
%EXAMPLE
%       tom_fit_ctf_folder(basepath,ext,outputpath,ctf_struct,corr_method,corr_cut_off,mtf_path)
%
%
%REFERENCES
%
%SEE ALSO
%
%   created by fb
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




if (strcmp(ext,'useWk'))
    d=dir(basepath);
    basepath=fileparts(basepath);
else
    d=dir([basepath '/*' ext]);
end;


img_size= ctf_struct.Search.ps_size;
mask_in_radius=ctf_struct.Fit.mask_inner_radius;
mask_out_radius=ctf_struct.Fit.mask_outer_radius;
mask_in = tom_spheremask(ones(img_size),mask_in_radius,0,[img_size(1)./2+1 img_size(2)./2+1 1]);
mask_out = tom_spheremask(ones(img_size),mask_out_radius,0,[img_size(1)./2+1 img_size(2)./2+1 1]);
mask=mask_out-mask_in;


EM=ctf_struct.Fit.EM;

if (exist('corr_cut_off','var')==0)
    corr_cut_off=0;
end;

if (exist('adapt_header_focus_search','var')==0)
    adapt_header_focus_search=0;
end;

try
if (exist('mtf_path','var')==0 || isempty(mtf_path))
    mtf_path='/fs/pool/pool-bmsan/apps/tom_dev/data/mtfs/old_mtfs/mtf_Eagle_SN109_200kV.mat';
    mtf=load(mtf_path);
    mtf=mtf.mtf_Eagle_SN109_200kV;
end;
catch
    disp(['cannot load mtf. set mtf=1.']);
    mtf=1;
end;

if (exist(outputpath,'dir')==0)
    mkdir(outputpath);
end;

if isfield(ctf_struct,'no_fit')==0
    fit_flag=1;
else
    fit_flag=0;
end;

if (isfield(ctf_struct,'couple'))
    couple_flag=1;
    couple_path=ctf_struct.couple.basepath;
else
   couple_flag=0;
    couple_path=''; 
end;


inner_rad_bg=ctf_struct.Search.mask_inner_radius_bg;
outer_rad_bg=ctf_struct.Search.mask_outer_radius_bg;


 adapt_header_focus_search=0;
parfor i=1:length(d)
    %for i=1:length(d)
    try
        
        Search_tmp=ctf_struct.Search;
        filename=[basepath '/' d(i).name];
        out_filename=[outputpath '/' d(i).name ];
        
        if (tom_isemfile(filename))
            in=tom_emreadc(filename);
        else
            in=tom_mrcread(filename);
           
        end;
        
        if adapt_header_focus_search==1
            Search_tmp.Dz_search=in.Header.Defocus.*(1e-10)+ctf_struct.Search.Dz_search-mean(ctf_struct.Search.Dz_search);
        end;
        
        if (tom_isemfile(filename) || tom_ismrcfile(filename))
            
            if (fit_flag~=0)
                ps=tom_calc_periodogram(double(in.Value),img_size(1),0,img_size(1)./16);
                ps=(log(fftshift(ps)));
                
                if (couple_flag~=0)
                    tmp=load([couple_path '/' d(i).name '.mat']);
                end;
                
                [decay decay_image]=calc_decay(ps,inner_rad_bg,outer_rad_bg,32);
                background_corrected_ps=double(ps-decay_image);
                
                ps=background_corrected_ps.*mask;
                warning off;
                [Fit]=tom_fit_ctf(ps,EM,Search_tmp);
                warning on;
                my_save(filename,Fit,Search_tmp,ps);
            else
                tmp_ctf_struct=my_load(filename);
                Fit=tmp_ctf_struct.Fit;
            end;
            
            if (strcmp(corr_method,'none')==0)
                if (Fit.Dz_det~=1000)
                    in.Value=tom_xraycorrect2(double(in.Value));
                    img_corr=tom_correct_for_ctf_and_mtf_new(in.Value,Fit,corr_method,corr_cut_off,mtf);
                    img_corr=tom_emheader(img_corr); % header of original micrograph, SN, 10/20/09
                    Magic=img_corr.Header.EM.Magic;
                    img_corr.Header=in.Header;
                    img_corr.Header.EM.Magic=Magic; % write floats !!!!!!!!!!!!!!!!!!!!!!!!!!
                    tom_emwritec(out_filename,img_corr);
                    
                end;
            end;
            
            
            disp([filename ' Dz: ' num2str(Fit.Dz_det.*1e6)  ' Dzd: '  num2str(Fit.Dz_delta_det .*1e6) ' Angle: ' num2str(Fit.Phi_0_det) ' done!']);
            if adapt_header_focus_search==1
                disp(['Intended Defocus: ' num2str(in.Header.Defocus.*(1e-10))  ', Search, Start: '  num2str(Search_tmp.Dz_search(1)) ' Step: ' num2str((Search_tmp.Dz_search(2)-Search_tmp.Dz_search(1))) ' Stop: ' num2str((Search_tmp.Dz_search(end)))]);
            end;
            if (strcmp(corr_method,'none')==0)
                disp([out_filename ' method: ' corr_method  ' cut off in pixels: ' num2str(corr_cut_off)  'done!']);
            end;
            
        end;
    catch Me
        disp(['error in ' filename ' ...skipping!']);
        disp(Me.message);
    end;
    
    
end;


%funny bullshit function due to matlab parfor parsing!!
function ctf_struct=my_load(filename)

try
    load([filename '.mat']);
catch
    disp([filename '.mat not found!']);
    ctf_struct.Fit.Dz=1000;
end;
ctf_struct=st_out;
clear('st_out');


function my_save(out_filename,Fit,Search,ps)

st_out.img=ps;
st_out.Fit=Fit;
st_out.Search=Search;
st_out.sel.selected=1;
st_out.sel.accepted=1;
st_out.sel.checked=0;

save([out_filename '.mat'],'st_out');

