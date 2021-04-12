function stack=tom_dict_filter(stack,dict,dIdx,verbose)
% tom_genDictionary generates dictionary for sparse representation of data 
%  
% stack=tom_dict_filter(stack,dict,dIdx,verbose)
%
%  PARAMETERS
%  
%    INPUT 
%     stack               stack of 2d-images 
%     dict                dictionary structure
%     dIdx                ('full') index for using only a subset of the dict 
%     verbose             (1) verbosity    
%
%    OUTPUT
%     stack               filtered stack
%    
%  
%  EXAMPLE
%    
%  fstack=tom_dict_filter(stack,dict);
%
%  REFERENCES
%  
%  SEE ALSO
%     tom_genDictionary,tom_av2_xmipp_dictFilt_sel,tom_av2_xmipp_doc2dictionary
%  
%     created by SN/FB 01/24/06
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
%
%
%

if (nargin <3)
    dIdx='full';
end;

if (nargin <4)
    verbose=1;
end;


szOrg=[size(stack,1) size(stack,2) size(stack,3)];
stack=reshape(stack,[size(stack,1)*size(stack,2) size(stack,3)]);
stack=stack';

if (strcmp(dict.type,'pca'))
    if (strcmp(dIdx,'full'))
        dIdx=1:size(dict.D,2);
    end;
    if (verbose)
        disp('calculating weights X ...')
    end;
    Score=bsxfun(@minus,stack,dict.Mean)/dict.D(:,1:max(dIdx))';
    if (verbose)
        disp('weights X done!')
    end;
    stack=Score(:,dIdx)*dict.D(:,dIdx)';
    stack = bsxfun(@plus,stack,dict.Mean);
    stack=reshape(stack',szOrg);
end;


