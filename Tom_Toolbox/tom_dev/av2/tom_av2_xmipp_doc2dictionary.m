function dict=tom_av2_xmipp_doc2dictionary(docFile,mirror,dSize,dtype,mask,appmask,algParam,verbose)
% tom_av2_xmipp_doc2dictionary generates dictionary for a doc for sparse representation of data 
%  
%   dict=tom_av2_xmipp_doc2dictionary(docFile,mirror,dSize,dtype,algParam,verbose)   
%
%  PARAMETERS
%  
%    INPUT 
%     docFile             xmipp doc,sel,wildcard or stack in memory
%     mirror              (0) double the stack by mirroring every particle
%                         useful for proj libs 
%     dSize               ('auto') size of the dictionary
%                          'pca' numer of eigenvalues 
%     dtype               ('pca') dictionary type so far only pca implemented 
%                        
%     mask                ('') mask applied to the stack b4 dict calc
%     appMask             ('permute') flag for app of the mask 
%                          'multiply' 
%     algParam            ('default') alignment parameter in a struct
%                         use 'defualt' for defaut alg settings
%                         use '' to switch off
%                         algParam.iter=[5 3];
%                         algParam.template=tmpl;
%                         algParam.mask=tom_sphermask(...)
%
%     verbose             1 verbosity    
%
%    OUTPUT
%     dict               structure containig the dict
%    
%  
%  EXAMPLE
%  
%  %example for creating a dictionary from proj-match model projections
%  dict=tom_av2_xmipp_doc2dictionary('ReferenceLibrary/ref.sel',1);
%  
%  %example for creatitng a dictionay from a dataset.
%  algParam.template=tmpl;
%  algParam.iter=[5 3];
%  algParam.mask='default';
%  dict=tom_av2_xmipp_doc2dictionary('It7_Cut.sel',0,'auto','pca',mask,'permute',algParam);
%
%
%  NOTE:
%  
%  use mirror flag for proj-match algs which have mirror flag e.g.
%  xmipp2.4/spider
%  
%
%  REFERENCES
%  
%  SEE ALSO
%     tom_genDictionary,tom_av2_xmipp_dictFilt_sel
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
    mirror=0;
end;

if (nargin<3)
    dtype='pca';
end;

if (nargin<4)
    dSize='auto';
end;

if (nargin<5)
    mask='';
end;

if (nargin<6)
    appmask='permute';
end;

if (nargin<7)
    algParam='default';
end;

if (nargin<8)
    verbose=1;
end;

if (strcmp(algParam,'default'))
    algParam.iter=[5 3];
    algParam.template='sum';
    algParam.mask='default';
end;

if (isnumeric(docFile)==0)
    stack=readData(docFile);  
else
    stack=docFile;
    clear('docFile');
end;

if (mirror==1)
    stack=doubleStackByMirror(stack);
end

if (isempty(algParam)==0)
    stack=tom_os3_alignStack2(stack,algParam.template,'default',[0 0],'mean0+1std','',algParam.iter);
end;

if (isempty(mask)==0)
    stack=applyMask(stack,mask,appmask);
end;

dict=tom_genDictionary(stack,dtype,dSize);

if (isempty(algParam)==0)
    dict.algParam=algParam;
end;
 
 function stack=readData(docFile)

 [fpath,fname,fext]=fileparts(docFile);

 if (findstr(docFile,'*'))
     d=dir(docFile);
     tmp=tom_spiderread([fpath filesep d(1).name]);
     tmp=tmp.Value;
     stack=zeros(size(tmp,1),size(tmp,2),length(d));
     for i=1:length(d)
        tmp=tom_spiderread([fpath filesep d(i).name]);
        stack(:,:,i)=tmp.Value;
     end;
 else
     if (strcmp(fext,'.sel'))
         stack=tom_xmippsellread(docFile);
         stack=stack.Value;
     end;
     if (strcmp(fext,'.doc'))
         stack=tom_av2_xmipp_doc2em(docFile);
     end;
 end;

function stack=applyMask(stack,mask,flag)
    
 parfor i=1:size(stack,3)
     if (strcmp(flag,'multiply'))
        stack(:,:,i)=stack(:,:,i).*mask;
     end;
     if (strcmp(flag,'permute'))
        stack(:,:,i)=tom_permute_bg(stack(:,:,i),mask,'',1.07,7,2);
     end;
     if (mod(i,1000)==0)
        disp(num2str(i));
     end;
 end;
 
function stack=doubleStackByMirror(stack)

    
 stackMir=tom_mirror(stack,'x');
 stack=cat(3,stack,stackMir);
 
    
    
