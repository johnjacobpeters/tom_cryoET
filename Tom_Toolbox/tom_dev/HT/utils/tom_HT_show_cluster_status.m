function tom_HT_show_cluster_status(flag)
%TOM_SHOW_CLUSTER_STATUS creates ...
%
%   tom_show_cluster_status(flag)
%
%PARAMETERS
%
%  INPUT
%   flag                ...
%  
%  OUTPUT
%
%EXAMPLE
%   tom_show_cluster_status(...);
%   creates ...
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   created by ... (author date)
%   updated by ...
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


if nargin==0
    flag='on';
end;

if strcmp(flag,'on')
    x_coord=1;
    for i=9:12
        unix(['ssh -Y cluster' sprintf('%02d',i) ' gkrellm -g +' num2str(x_coord) '+25 &']); 
        x_coord=x_coord+200;
        pause(.5);
    end;
    
else

    unix('ssh cluster09 killall gkrellm &');
    pause(.5);
    unix('ssh cluster10 killall gkrellm &');
    pause(.5);
    unix('ssh cluster11 killall gkrellm &');
    pause(.5);
    unix('ssh cluster12 killall gkrellm &');
    pause(.5);
end;
