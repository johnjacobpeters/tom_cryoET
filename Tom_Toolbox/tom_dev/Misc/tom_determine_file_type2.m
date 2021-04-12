function [type]=tom_determine_file_type2(filename)
%tom_determine_file_type determines the type of the file given.
%
%   [type]=tom_determine_file_type(filename);
%
%   Works with or without extension. 
%
%  INPUT
%   filename:    name of the file
%
%  OUTPUT
%   type:       type of the file; e.g. 'em' for an EM-file, 'png' for a
%               PNG file etc. A Matlab file has type 'MAT-File'.
%               'unknown' is returned when the file type couldn't be determined. 
%
%EXAMPLE
%               [type]=tom_determine_file_type('exo.em')
%
%               type =
%
%               em
%
%               [type]=tom_determine_file_type('HPI.tif')
%
%               type =
%
%               tif
%
%
%REFERENCES
%
%SEE ALSO
%     TOM_EMWRITE, TOM_EMHEADER, TOM_READEMHEADER
%
%   created by SN 11/03/08
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

if tom_isemfile(filename)==1; type='em';return; end;
if tom_ismrcfile(filename)==1; type='mrc';return; end;
if tom_isimagicfile(filename)==1; type='imagic';return; end;
if tom_isxmipp_fscfile(filename)==1; type='xmipp_fsc';return; end;
if tom_isdm3file(filename)==1; type='dm3';return; end;
if tom_ishpcllogfile(filename)==1; type='HPCL logfile';return; end;
if tom_ishpcllogfile(filename)==1; type='HPCL logfile';return; end;
if tom_iseman2h5file(filename)==1; type='e2h5'; return; end;
if tom_isspiderfile(filename)==1; type='spider'; return; end;

[pathstr,name,ext]=fileparts(filename);
if isequal(ext,'.m'); type='Matlab file';return; end;
if isequal(ext,'.c'); type='C file';return; end;
if isequal(ext,'.cpp'); type='C++ file';return; end;
if isequal(ext,'.h'); type='Header file';return; end;
if isequal(ext,'.txt'); type='Text file';return; end;
if isequal(ext,'.doc'); type='Doc file';return; end;
if isequal(ext,'.sel'); type='xmipp_sel';return; end;
if isequal(ext,'.py'); type='Python script';return; end;
if isequal(ext,'.pdf'); type='PDF file';return; end;
if isequal(ext,'.pdb'); type='PDB file';return; end;
if isequal(ext,'.py'); type='Python file';return; end;
if isequal(ext,'.f3d'); type='f3d';return; end;
if isequal(ext,'.star'); type='star file';return; end;
if isequal(ext,'.box'); type='box file';return; end;
if isequal(ext,'.mat'); type='mat file';return; end;

try i=imfinfo(filename);
    type=i.Format;
    return;
catch
    try
    warning off; type=matfinfo(filename); warning on;
    catch;
    end;
    if isempty(type)    
        if tom_isspiderfile(filename)==1; type='spider';return; end;        
        type='unknown';
        return;
    else
        return;
    end;
end;

