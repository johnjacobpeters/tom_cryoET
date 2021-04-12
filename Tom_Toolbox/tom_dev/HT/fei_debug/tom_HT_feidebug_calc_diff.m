function struct=tom_HT_feidebug_calc_diff(struct,smooth_val,elm_outl)
%TOM_HT_FEIDEBUG_CALC_DIV clacs mean diff
%
%   struct=tom_HT_feidebug_calc_div(strcu,,smooth_val,elm_outl)
%
%PARAMETERS
%
%  INPUT
%   struct               input structure from tom_HT_feidebug_perfmon_read2
%   smooth_val           value for smoothing  
%   elm_outl             eliminates outlayers [1 2 3]     
%                        1: n-times standard deviation
%                        2: number of iterations 
%                        3: verbose Flag       
%
%  OUTPUT
%   struct               structure containing the information of the
%                        perfmon file + mean derivative
%
%EXAMPLE
%  
%
%REFERENCES
%
%SEE ALSO
%   tom_HT_feidebug
%
%   
%   fb 03/12/007
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





if nargin < 2
    smooth_val=0;
end;
    
if nargin < 3
    elm_outl=[0 0 0];
end;

nr_rows=size(struct.data,2);

for i=1:nr_rows
   tmp=struct.data(:,i);
   if (elm_outl(1)~= 0)
        tmp=tom_eliminate_outlayers(tmp,elm_outl(1),elm_outl(2),elm_outl(3));
   end;
   
   if (smooth_val ~= 0)
        tmp=smooth(tmp,smooth_val);
   end;
   dirv_tmp=diff(tmp);    
   
   struct.diff(i)=mean(dirv_tmp); 
end;

