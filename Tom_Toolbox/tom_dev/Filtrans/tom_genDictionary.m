function dict=tom_genDictionary(stack,dtype,dSize,verbose)
% tom_genDictionary generates dictionary for sparse representation of data 
%  
%  dict=tom_genDictionary(stack,dtype,dSize,verbose)    
%
%  PARAMETERS
%  
%    INPUT 
%     stack               stack of 2d-images 
%     dtype               ('pca') dictionary type so far only pca implemented 
%     dSize               ('auto') size of the dictionary
%                                  'pca' numer of eigenvalues 
%     verbose             1 verbosity    
%
%    OUTPUT
%     dict               structure containig the dict
%    
%  
%  EXAMPLE
%    
%  dict=tom_genDictionary(stack,'pca',5,1);
%
%  REFERENCES
%  
%  SEE ALSO
%     ...
%  
%     created by FB 01/24/06
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

if (nargin<2)
   dtype='pca'; 
end;
    
if (nargin<3)
   dSize='auto'; 
end;

if (nargin<4)
   verbose=1; 
end;


stack=single(stack);
szOrg=size(stack);
stack=reshape(stack,size(stack,1).*size(stack,2),size(stack,3));
stack=stack';


if (strcmp(dtype,'pca'))
    implementation='matlab-subfun';
    %implementation='matlab-pca';
    
    if (strcmp(implementation,'matlab-pca'))
        [eigvs,score,latent]=pca(stack,'NumComponents',dSize,'Algorithm','eig','Economy',false);
        eigvs=tom_xraycorrect(eigvs);
        dict.Mean=mean(stack);
    end;
    if (strcmp(implementation,'matlab-subfun'))
        if (strcmp(dSize,'auto'))
            numOfeig=150;
        else
            numOfeig=dSize;
        end;
        % center the data
        [stack,dict.Mean]=centerData(stack);
        covM=cov(stack);
        if (verbose==1)
            options.disp=verbose;
        else
            options.disp=0;
        end;
        [dict.D,dict.Dscore]=eigs(double(covM),numOfeig,'lm',options);
        clear('covM');
        dict=reduceEigs(dict,dSize);
        %dict=processDict(dict,szOrg);
    end;
    dict.OrgSize=szOrg;
    dict.type='pca';
end;

function dict=reduceEigs(dict,dSize)

[~,idx] = sort(diag(dict.Dscore), 'descend');
dict.D = dict.D(:, idx);

if (strcmp(dSize,'auto'))
    idx=max(find(diag(dict.Dscore)>0.001));
    dict.D=dict.D(:,1:idx);
    dict.Dscore=dict.Dscore(:,1:idx);
end;

function [stack,meanPerDim]=centerData(stack)

vWeights=ones(size(stack,1),1);
meanPerDim = classreg.learning.internal.wnanmean(stack, vWeights);
stack = bsxfun(@minus,stack,meanPerDim);

function dict=processDict(dict,orgSize)

for i=1:size(dict.D,2)
    dict.D(:,i)=reshape(tom_xraycorrect2(reshape(dict.D(:,i),[orgSize(1) orgSize(2)])),[orgSize(1)*orgSize(2) 1]);
end;

dict.Mean=reshape(tom_xraycorrect2(reshape(dict.Mean,[orgSize(1) orgSize(2)])),[orgSize(1)*orgSize(2) 1]);


