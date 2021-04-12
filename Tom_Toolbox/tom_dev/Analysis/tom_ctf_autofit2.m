function xdz = tom_ctf_autofit2(directory,min_freq,max_freq,enhance_filter_min,enhance_filter_max,enhance_weight)
% TOM_CTF_AUTOFIT searches for em images in a given directory and tries to
% do a CTF fit on each image. If successful the new defocus value is
% written to the header field "FocusIncrement", on failure the nominal
% value is copied.
%
% tom_ctf_autofit(directory, threshold, filterval)
%
%
%  INPUT
%
%  directory    The full path to the directory containing the images
%  threshold    The maximum difference between fitted and nominal defocus
%               in mu (optional) (default: 2)
%  filterval    The kernel size for a real space quadratic kernel to be
%               applied to each image before CTF fitting (optional) (default 1)
%  startval     start defocus value in nm (optional)
%
%  OUTPUT
%
%EXAMPLE
%   tom_ctf_autofit(...);
%   creates ...
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by AK 09/11/06
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

%matlabpool titan 6

dircell = tom_HT_getdircontents(directory,{'em'});

xdz = zeros(length(dircell),3,'single');
%figure;
%h = axes;
%set(h,'XLim',[1 length(dircell)]);

parfor (i=1:length(dircell))
    
    file = dircell{i};

    header = tom_emreadc([directory '/' file]);
    Dz = header.Header.Defocus;
    voltage = header.Header.Voltage./1000;
    objectpixelsize = header.Header.Objectpixelsize;
    Cs = header.Header.Cs;
    Ca = 2;
    ctfmodelsize = 0;

    st = tom_xmipp_adjust_ctf(tom_calc_periodogram(header.Value,256),Dz,voltage,objectpixelsize,ctfmodelsize,Cs,min_freq,max_freq,Ca,enhance_filter_min,enhance_filter_max,enhance_weight);
    
        
    xdz(i,:) = ([(st.DeltafV + st.DeltafU)./2 header2.Header.FocusIncrement (st.DeltafV + st.DeltafU)./2-header2.Header.FocusIncrement]);

    header.Header.FocusIncrement = (st.DeltafV + st.DeltafU)./2;
    tom_writeemheader([directory '/' file], header.Header);
    disp(file);
    %disp(xdz(i,:));
    %plot(xdz(:,3)./10);drawnow;
end





