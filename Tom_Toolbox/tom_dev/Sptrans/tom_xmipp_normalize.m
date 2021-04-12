function img_out = tom_xmipp_normalize(img,method,mask,demoMode)
%TOM_XMIPP_NORMALIZE is the matlab version xmipp_normalize(..'Ramp')
% fits a 2d plane and subtracts it from the input image
%
%   img_out = tom_xmipp_normalize(img,method,mask);
%
%PARAMETERS
%
%  INPUT
%   img                 2D image
%   method              normalization method, valid choices are: 
%                       'RAMP'
%   mask                (spherical with r-1) mask 4 background
%                        background pixels should be 1 !!!
%                        tom_sphermask has to be inverted!!
%   demoMode            (0) use 1 to switch on
%   
%  OUTPUT
%   img_out             normalized image
%
%EXAMPLE
%   mask = tom_sphere(size(img),size(img,1)./2-1)==0;
%   img_out = tom_xmipp_normalize(img,'Ramp',mask);
%
%REFERENCES
%
%   
%
%SEE ALSO
%   
%
%   created by fb 02/17/2014
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

%check for correct number of input and output arguments
narginchk(2, 4);
nargoutchk(1, 1);

szImg=size(img);
idxImg=1:szImg(1)*szImg(2);
if nargin < 3 || isempty(mask)
    mask=tom_spheremask(ones(szImg),round(szImg(1)./2)-1)==0;
end


if nargin < 4
    demoMode=0;
end


%check if image and mask are of the same dimensions
if sum(size(img)==size(mask)) < 2
    error('Image and mask are of unequal size');
end

%check if image and mask are 2D
if ~ismatrix(img) || ~ismatrix(mask)
    error('Image and mask must be 2D arrays');
end

method=lower(method);

%check 4 valid methods
if (strcmp(method,'ramp')==0) 
    error('only ramp implemented so far!');
end;


idxMask= mask>0;
if (std(img(idxMask))==0)
    img_out=img;
    return;
end;

if (strcmp(method,'ramp'))
    img=tom_norm(img,'mean0+1std');
    
    data=zeros(length(idxImg),3);
    %transfer data in x,y,z point format
    [data(:,1),data(:,2)]=ind2sub(szImg,idxImg);
    data(:,3)=img(idxImg);
    %fit normal,d 4 HNF
    [normVect,d]= fitBgPlane(data(idxMask,:), demoMode);
    if (normVect(3)==0)
       normVect(3)=1; 
    end;
    %calc gradient image
    img_grad= ((-1.*data(:,1).*normVect(1))+ (-1.*data(:,2).*normVect(2)) + (-1.*d) )./ normVect(3);
    img_grad=reshape(img_grad,szImg);
    %subtract grad image
    img_out=img-img_grad;
end;



function [n,d] = fitBgPlane(data, show_graph)

idxUse=1:size(data,1);
nStd=3.5;
for i=1:3
    mData=mean(data(idxUse,3));
    stdData=std(data(idxUse,3));
    idxUseOld=idxUse;
    thrUpper=mData + (nStd.*stdData);
    thrLower=mData - (nStd.*stdData);
    idxUse= find( ((data(:,3) < thrUpper) .* (data(:,3) > thrLower) ));
    if (length(idxUse)==length(idxUseOld))
        break;
    end;
end;
data=data(idxUse,:);

can_solve=zeros(3,1);
n=zeros(3,3);
for i = 1:3
    X = data;
    X(:,i) = 1;
    
    X_m = X' * X;
    if det(X_m) == 0
        can_solve(i) = 0;
        continue;
    end
    can_solve(i) = 1;
    
    % Construct and normalize the normal vector
    coeff = (X_m)^-1 * X' * data(:,i);
    c_neg = -coeff;
    c_neg(i) = 1;
    coeff(i) = 1;
    n(:,i) = c_neg / norm(coeff);
end

if sum(can_solve) == 0
    disp('Planar fit to the data caused a singular matrix ==> no correction applied');
    n=[0 0 0];
    d=0;
    return;
end

% Calculating residuals for each fit
center = mean(data);
off_center = [data(:,1)-center(1) data(:,2)-center(2) data(:,3)-center(3)];
residual_sum=zeros(3,1);
for i = 1:3
    if can_solve(i) == 0
        residual_sum(i) = NaN;
        continue
    end
    residuals = off_center * n(:,i);
    residual_sum(i) = sum(residuals .* residuals);
end

% Find the lowest residual index
best_fit = find(residual_sum == min(residual_sum));

% Possible that equal mins so just use the first index found
n = n(:,best_fit(1));

%calculate d (dist from origin)
dx=n(1).*data(:,1).*-1;
dy=n(2).*data(:,2).*-1;
dz=n(3).*data(:,3).*-1;
ds=dx+dy+dz;
d=mean(ds);


if show_graph
     
    figure;
    range = max(max(data) - min(data)) / 20;
    mid_pt = (max(data) - min(data)) / 2 + min(data);
    xlim = [-1 1]*range + mid_pt(1);
    ylim = [-1 1]*range + mid_pt(2);
    zlim = [-1 1]*range + mid_pt(3);
    
    L=plot3(data(:,1),data(:,2),data(:,3),'ro','Markerfacecolor','r'); % Plot the original data points
    hold on;
   
    dataReCalc(:,3)= ((-1.*data(:,1).*n(1))+ (-1.*data(:,2).*n(2)) + (-1.*d) )./ n(3);
    hold on; plot3(data(:,1),data(:,2),dataReCalc(:,3),'b+'); hold off;
    
    norm_data = [mean(data); mean(data) + (n' * range)];
    % Plot the original data points
    
    hold on;
    %L=plot3(norm_data(:,1),norm_data(:,2),norm_data(:,3),'b-','LineWidth',3);
    set(get(get(L,'parent'),'XLabel'),'String','x','FontSize',14,'FontWeight','bold')
    set(get(get(L,'parent'),'YLabel'),'String','y','FontSize',14,'FontWeight','bold')
    set(get(get(L,'parent'),'ZLabel'),'String','z','FontSize',14,'FontWeight','bold')
    title(sprintf('Normal Vector: <%0.3f, %0.3f, %0.3f>',n),'FontWeight','bold','FontSize',14)
    grid on;
    axis square;
    hold off;
    
end;





