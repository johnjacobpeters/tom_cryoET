function skel = tom_skeleton3D(vol,mask)
%TOM_SKELETON3D calculates a 3d skeleton from binary volume
%
%  skel = tom_skeleton3D(vol,mask)
%
%PARAMETERS
%
%  INPUT
%   vol              binary volume which should be processed          
%   mask          mask for volume 
%  
%  OUTPUT
%   skel          skeleton
%  
%
%EXAMPLE
%   cyl=tom_cylindermask(ones(64,64,64),5);
%   skel=tom_skeleton3D(cyl>0.5);
%   figure; tom_dspcub(cyl,1);
%   figure; tom_dspcub(skel,1);
%
%REFERENCES
%
%SEE ALSO
%   ...
%
%   copied from matlab file exchanged by FB 25/06/18 
%   For more information, see
%   href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/43400-skeleton3d')">Skeleton3D</a> at the MATLAB File Exchang
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
%


skel=vol;

skel=padarray(skel,[1 1 1]);

if(nargin==2)
    spare=mask;
    spare=padarray(spare,[1 1 1]);
end

% fill lookup table
eulerLUT = FillEulerLUT;

width = size(skel,1);
height = size(skel,2);
depth = size(skel,3);

unchangedBorders = 0;

while( unchangedBorders < 6 )  % loop until no change for all six border types
    unchangedBorders = 0;
    for currentBorder=1:6 % loop over all 6 directions
        cands=false(width,height,depth, 'like', skel);
        switch currentBorder
            case 4
                x=2:size(skel,1); % identify border voxels as candidates
                cands(x,:,:)=skel(x,:,:) - skel(x-1,:,:);
            case 3
                x=1:size(skel,1)-1;
                cands(x,:,:)=skel(x,:,:) - skel(x+1,:,:);
            case 1
                y=2:size(skel,2);
                cands(:,y,:)=skel(:,y,:) - skel(:,y-1,:);
            case 2
                y=1:size(skel,2)-1;
                cands(:,y,:)=skel(:,y,:) - skel(:,y+1,:);
            case 6
                z=2:size(skel,3);
                cands(:,:,z)=skel(:,:,z) - skel(:,:,z-1);
            case 5
                z=1:size(skel,3)-1;
                cands(:,:,z)=skel(:,:,z) - skel(:,:,z+1);
        end
        
        % if excluded voxels were passed, remove them from candidates
        if(nargin==2)
            cands = cands & ~spare;
        end
        
        % make sure all candidates are indeed foreground voxels
        cands = cands(:)==1 & skel(:)==1;
        
        noChange = true;
                    
        if any(cands)
            cands = find(cands);
            % get subscript indices of candidates
            [x,y,z]=ind2sub([width height depth],cands);
            
            % get 26-neighbourhood of candidates in volume
            nhood = pk_get_nh(skel,cands);
            
            % remove all endpoints (exactly one nb) from list
            di1 = sum(nhood,2)==2;
            nhood(di1,:)=[];
            cands(di1)=[];
            x(di1)=[];
            y(di1)=[];
            z(di1)=[];
            
            % remove all non-Euler-invariant points from list
            di2 = ~p_EulerInv(nhood, eulerLUT);
            nhood(di2,:)=[];
            cands(di2)=[];
            x(di2)=[];
            y(di2)=[];
            z(di2)=[];
            
            % remove all non-simple points from list
            di3 = ~p_is_simple(nhood);
%             nhood(di3,:)=[];
%             cands(di3)=[];
            x(di3)=[];
            y(di3)=[];
            z(di3)=[];
            
            
            % if any candidates left: divide into 8 independent subvolumes
            if (~isempty(x))
                x1 = logical(mod(x,2));
                x2 = ~x1;
                y1 = logical(mod(y,2));
                y2 = ~y1;
                z1 = logical(mod(z,2));
                z2 = ~z1;
                ilst(1).l = x1 & y1 & z1;
                ilst(2).l = x2 & y1 & z1;
                ilst(3).l = x1 & y2 & z1;
                ilst(4).l = x2 & y2 & z1;
                ilst(5).l = x1 & y1 & z2;
                ilst(6).l = x2 & y1 & z2;
                ilst(7).l = x1 & y2 & z2;
                ilst(8).l = x2 & y2 & z2;
                
%                 idx = [];
                
                % do parallel re-checking for all points in each subvolume
                for i = 1:8                    
                    if any(ilst(i).l)
                        idx = ilst(i).l;
                        li = sub2ind([width height depth],x(idx),y(idx),z(idx));
                        skel(li)=0; % remove points
                        nh = pk_get_nh(skel,li);
                        di_rc = ~p_is_simple(nh);
                        if any(di_rc) % if topology changed: revert
                            skel(li(di_rc)) = true;
                        else
                            noChange = false; % at least one voxel removed
                        end
                    end
                end
            end
        end
        
        if( noChange )
            unchangedBorders = unchangedBorders + 1;
        end
        
    end
end

% get rid of padded zeros
skel = skel(2:end-1,2:end-1,2:end-1);
end





function EulerInv =  p_EulerInv(img,LUT)
if numel(LUT) > 255
    error('skeleton3D:p_EulerInv:LUTwithTooManyElems', 'LUT with 255 elements expected');
end
% Calculate Euler characteristic for each octant and sum up
eulerChar = zeros(size(img,1),1, 'like', LUT);
% Octant SWU
bitorTable = uint8([128; 64; 32; 16; 8; 4; 2]);
n = ones(size(img,1),1, 'uint8');
n(img(:,25)==1) = bitor(n(img(:,25)==1), bitorTable(1));
n(img(:,26)==1) = bitor(n(img(:,26)==1), bitorTable(2));
n(img(:,16)==1) = bitor(n(img(:,16)==1), bitorTable(3));
n(img(:,17)==1) = bitor(n(img(:,17)==1), bitorTable(4));
n(img(:,22)==1) = bitor(n(img(:,22)==1), bitorTable(5));
n(img(:,23)==1) = bitor(n(img(:,23)==1), bitorTable(6));
n(img(:,13)==1) = bitor(n(img(:,13)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant SEU
n = ones(size(img,1),1, 'uint8'); 
n(img(:,27)==1) = bitor(n(img(:,27)==1), bitorTable(1));
n(img(:,24)==1) = bitor(n(img(:,24)==1), bitorTable(2));
n(img(:,18)==1) = bitor(n(img(:,18)==1), bitorTable(3));
n(img(:,15)==1) = bitor(n(img(:,15)==1), bitorTable(4));
n(img(:,26)==1) = bitor(n(img(:,26)==1), bitorTable(5));
n(img(:,23)==1) = bitor(n(img(:,23)==1), bitorTable(6));
n(img(:,17)==1) = bitor(n(img(:,17)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant NWU
n = ones(size(img,1),1, 'uint8'); 
n(img(:,19)==1) = bitor(n(img(:,19)==1), bitorTable(1));
n(img(:,22)==1) = bitor(n(img(:,22)==1), bitorTable(2));
n(img(:,10)==1) = bitor(n(img(:,10)==1), bitorTable(3));
n(img(:,13)==1) = bitor(n(img(:,13)==1), bitorTable(4));
n(img(:,20)==1) = bitor(n(img(:,20)==1), bitorTable(5));
n(img(:,23)==1) = bitor(n(img(:,23)==1), bitorTable(6));
n(img(:,11)==1) = bitor(n(img(:,11)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant NEU
n = ones(size(img,1),1, 'uint8'); 
n(img(:,21)==1) = bitor(n(img(:,21)==1), bitorTable(1));
n(img(:,24)==1) = bitor(n(img(:,24)==1), bitorTable(2));
n(img(:,20)==1) = bitor(n(img(:,20)==1), bitorTable(3));
n(img(:,23)==1) = bitor(n(img(:,23)==1), bitorTable(4));
n(img(:,12)==1) = bitor(n(img(:,12)==1), bitorTable(5));
n(img(:,15)==1) = bitor(n(img(:,15)==1), bitorTable(6));
n(img(:,11)==1) = bitor(n(img(:,11)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant SWB
n = ones(size(img,1),1, 'uint8'); 
n(img(:, 7)==1) = bitor(n(img(:, 7)==1), bitorTable(1));
n(img(:,16)==1) = bitor(n(img(:,16)==1), bitorTable(2));
n(img(:, 8)==1) = bitor(n(img(:, 8)==1), bitorTable(3));
n(img(:,17)==1) = bitor(n(img(:,17)==1), bitorTable(4));
n(img(:, 4)==1) = bitor(n(img(:, 4)==1), bitorTable(5));
n(img(:,13)==1) = bitor(n(img(:,13)==1), bitorTable(6));
n(img(:, 5)==1) = bitor(n(img(:, 5)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant SEB
n = ones(size(img,1),1, 'uint8'); 
n(img(:, 9)==1) = bitor(n(img(:, 9)==1), bitorTable(1));
n(img(:, 8)==1) = bitor(n(img(:, 8)==1), bitorTable(2));
n(img(:,18)==1) = bitor(n(img(:,18)==1), bitorTable(3));
n(img(:,17)==1) = bitor(n(img(:,17)==1), bitorTable(4));
n(img(:, 6)==1) = bitor(n(img(:, 6)==1), bitorTable(5));
n(img(:, 5)==1) = bitor(n(img(:, 5)==1), bitorTable(6));
n(img(:,15)==1) = bitor(n(img(:,15)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant NWB
n = ones(size(img,1),1, 'uint8'); 
n(img(:, 1)==1) = bitor(n(img(:, 1)==1), bitorTable(1));
n(img(:,10)==1) = bitor(n(img(:,10)==1), bitorTable(2));
n(img(:, 4)==1) = bitor(n(img(:, 4)==1), bitorTable(3));
n(img(:,13)==1) = bitor(n(img(:,13)==1), bitorTable(4));
n(img(:, 2)==1) = bitor(n(img(:, 2)==1), bitorTable(5));
n(img(:,11)==1) = bitor(n(img(:,11)==1), bitorTable(6));
n(img(:, 5)==1) = bitor(n(img(:, 5)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);
% Octant NEB
n = ones(size(img,1),1, 'uint8'); 
n(img(:, 3)==1) = bitor(n(img(:, 3)==1), bitorTable(1));
n(img(:, 2)==1) = bitor(n(img(:, 2)==1), bitorTable(2));
n(img(:,12)==1) = bitor(n(img(:,12)==1), bitorTable(3));
n(img(:,11)==1) = bitor(n(img(:,11)==1), bitorTable(4));
n(img(:, 6)==1) = bitor(n(img(:, 6)==1), bitorTable(5));
n(img(:, 5)==1) = bitor(n(img(:, 5)==1), bitorTable(6));
n(img(:,15)==1) = bitor(n(img(:,15)==1), bitorTable(7));
eulerChar = eulerChar + LUT(n);

EulerInv = false(size(eulerChar), 'like', img);
EulerInv(eulerChar==0) = true;

end

function is_simple = p_is_simple(N)

% copy neighbors for labeling
n_p = size(N,1);
is_simple = true(n_p, 1, 'like', N);

cube = zeros(n_p, 26, 'uint8');
cube(:, 1:13)=N(:, 1:13);
cube(:, 14:26)=N(:,15:27);

label = 2*ones(n_p, 1, 'uint8');

% for all points in the neighborhood
for i=1:26
    
    idx = cube(:,i) == 1 & is_simple;
    
    if any(idx)
        
        % start recursion with any octant that contains the point i
        switch( i )
            
            case {1,2,4,5,10,11,13}
                cube(idx,:) = p_oct_label(1, label, cube(idx,:) );
            case {3,6,12,14}
                cube(idx,:) = p_oct_label(2, label, cube(idx,:) );
            case {7,8,15,16}
                cube(idx,:) = p_oct_label(3, label, cube(idx,:) );
            case {9,17}
                cube(idx,:) = p_oct_label(4, label, cube(idx,:) );
            case {18,19,21,22}
                cube(idx,:) = p_oct_label(5, label, cube(idx,:) );
            case {20,23}
                cube(idx,:) = p_oct_label(6, label, cube(idx,:) );
            case {24,25}
                cube(idx,:) = p_oct_label(7, label, cube(idx,:) );
            case 26
                cube(idx,:) = p_oct_label(8, label, cube(idx,:) );
        end

        label(idx) = label(idx)+1;
        del_idx = label>=4;
        
        if any(del_idx)
            is_simple(del_idx) = false;
        end
    end
end
end

function nhood = pk_get_nh(img,i)

width = size(img,1);
height = size(img,2);
depth = size(img,3);

[x,y,z]=ind2sub([width height depth],i);

nhood = false(length(i),27, 'like', img);

for xx=1:3
    for yy=1:3
        for zz=1:3
            w=sub2ind([3 3 3],xx,yy,zz);
            idx = sub2ind([width height depth],x+xx-2,y+yy-2,z+zz-2);
            nhood(:,w)=img(idx);
        end
    end
end
end

function cube = p_oct_label(octant, label, cube)

% check if there are points in the octant with value 1
if( octant==1 )
    
    % set points in this octant to current label
    % and recurseive labeling of adjacent octants
    idx = cube(:,1) == 1;
    if any(idx)
        cube(idx,1) = label(idx);
    end
    
    idx = cube(:,2) == 1;
    if any(idx)
        cube(idx,2) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
    end
    
    idx = cube(:,4) == 1;
    if any(idx)
        cube(idx,4) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
    end
    
    idx = cube(:,5) == 1;
    if any(idx)
        cube(idx,5) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end
    
    idx = cube(:,10) == 1;
    if any(idx)
        cube(idx,10) = label(idx);
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
    end
    
    idx = cube(:,11) == 1;
    if any(idx)
        cube(idx,11) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end
    
    idx = cube(:,13) == 1;
    if any(idx)
        cube(idx,13) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end
    
end

if( octant==2 )
    
    idx = cube(:,2) == 1;
    if any(idx)
        cube(idx,2) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
    end

    idx = cube(:,5) == 1;
    if any(idx)
        cube(idx,5) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end

    idx = cube(:,11) == 1;
    if any(idx)
        cube(idx,11) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end

    idx = cube(:,3) == 1;
    if any(idx)
        cube(idx,3) = label(idx);
    end

    idx = cube(:,6) == 1;
    if any(idx)
        cube(idx,6) = label(idx);
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end
    
    idx = cube(:,12) == 1;
    if any(idx)
        cube(idx,12) = label(idx);
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end

    idx = cube(:,14) == 1;
    if any(idx)
        cube(idx,14) = label(idx);
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end

end

if( octant==3 )
    
    idx = cube(:,4) == 1;
    if any(idx)
        cube(idx,4) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
    end

    idx = cube(:,5) == 1;
    if any(idx)
        cube(idx,5) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end

    idx = cube(:,13) == 1;
    if any(idx)
        cube(idx,13) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end

    idx = cube(:,7) == 1;
    if any(idx)
        cube(idx,7) = label(idx);
    end

    idx = cube(:,8) == 1;
    if any(idx)
        cube(idx,8) = label(idx);
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end
    
    idx = cube(:,15) == 1;
    if any(idx)
        cube(idx,15) = label(idx);
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end

    idx = cube(:,16) == 1;
    if any(idx)
        cube(idx,16) = label(idx);
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end
    
end

if( octant==4 )
    
    idx = cube(:,5) == 1;
    if any(idx)
        cube(idx,5) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
    end

    idx = cube(:,6) == 1;
    if any(idx)
        cube(idx,6) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
    end

    idx = cube(:,14) == 1;
    if any(idx)
        cube(idx,14) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end
    
    idx = cube(:,8) == 1;
    if any(idx)
        cube(idx,8) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
    end

    idx = cube(:,16) == 1;
    if any(idx)
        cube(idx,16) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end

    idx = cube(:,9) == 1;
    if any(idx)
        cube(idx,9) = label(idx);
    end

    idx = cube(:,17) == 1;
    if any(idx)
        cube(idx,17) = label(idx);
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end

end

if( octant==5 )
    
    idx = cube(:,10) == 1;
    if any(idx)
        cube(idx,10) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
    end

    idx = cube(:,11) == 1;
    if any(idx)
        cube(idx,11) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end
    
    idx = cube(:,13) == 1;
    if any(idx)
        cube(idx,13) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end

    idx = cube(:,18) == 1;
    if any(idx)
        cube(idx,18) = label(idx);
    end

    idx = cube(:,19) == 1;
    if any(idx)
        cube(idx,19) = label(idx);
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end

    idx = cube(:,21) == 1;
    if any(idx)
        cube(idx,21) = label(idx);
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end

    idx = cube(:,22) == 1;
    if any(idx)
        cube(idx,22) = label(idx);
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end

end

if( octant==6 )
    
    idx = cube(:,11) == 1;
    if any(idx)
        cube(idx,11) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
    end

    idx = cube(:,12) == 1;
    if any(idx)
        cube(idx,12) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
    end

    idx = cube(:,14) == 1;
    if any(idx)
        cube(idx,14) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end
    
    idx = cube(:,19) == 1;
    if any(idx)
        cube(idx,19) = label(idx);
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
    end


    idx = cube(:,22) == 1;
    if any(idx)
        cube(idx,22) = label(idx);
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end
    
    idx = cube(:,20) == 1;
    if any(idx)
        cube(idx,20) = label(idx);
    end

    idx = cube(:,23) == 1;
    if any(idx)
        cube(idx,23) = label(idx);
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end
 
end

if( octant==7 )
    
    idx = cube(:,13) == 1;
    if any(idx)
        cube(idx,13) = label(idx);
        cube(idx,:) = p_oct_label(1,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
    end

    idx = cube(:,15) == 1;
    if any(idx)
        cube(idx,15) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
    end

    idx = cube(:,16) == 1;
    if any(idx)
        cube(idx,16) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end

    idx = cube(:,21) == 1;
    if any(idx)
        cube(idx,21) = label(idx);
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
    end

    idx = cube(:,22) == 1;
    if any(idx)
        cube(idx,22) = label(idx);
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end

    idx = cube(:,24) == 1;
    if any(idx)
        cube(idx,24) = label(idx);
    end
    
    idx = cube(:,25) == 1;
    if any(idx)
        cube(idx,25) = label(idx);
        cube(idx,:) = p_oct_label(8,label(idx),cube(idx,:));
    end
end

if( octant==8 )
    
    idx = cube(:,14) == 1;
    if any(idx)
        cube(idx,14) = label(idx);
        cube(idx,:) = p_oct_label(2,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end

    idx = cube(:,16) == 1;
    if any(idx)
        cube(idx,16) = label(idx);
        cube(idx,:) = p_oct_label(3,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end
    
    idx = cube(:,17) == 1;
    if any(idx)
        cube(idx,17) = label(idx);
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end
    
    idx = cube(:,22) == 1;
    if any(idx)
        cube(idx,22) = label(idx);
        cube(idx,:) = p_oct_label(5,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end
    
    idx = cube(:,17) == 1;
    if any(idx)
        cube(idx,17) = label(idx);
        cube(idx,:) = p_oct_label(4,label(idx),cube(idx,:));
    end
    
    idx = cube(:,23) == 1;
    if any(idx)
        cube(idx,23) = label(idx);
        cube(idx,:) = p_oct_label(6,label(idx),cube(idx,:));
    end
    
    idx = cube(:,25) == 1;
    if any(idx)
        cube(idx,25) = label(idx);
        cube(idx,:) = p_oct_label(7,label(idx),cube(idx,:));
    end
    
    idx = cube(:,26) == 1;
    if any(idx)
        cube(idx,26) = label(idx);
    end
end
end


function LUT = FillEulerLUT

LUT = zeros(255,1, 'int8');

LUT(1)  =  1;
LUT(3)  = -1;
LUT(5)  = -1;
LUT(7)  =  1;
LUT(9)  = -3;
LUT(11) = -1;
LUT(13) = -1;
LUT(15) =  1;
LUT(17) = -1;
LUT(19) =  1;
LUT(21) =  1;
LUT(23) = -1;
LUT(25) =  3;
LUT(27) =  1;
LUT(29) =  1;
LUT(31) = -1;
LUT(33) = -3;
LUT(35) = -1;
LUT(37) =  3;
LUT(39) =  1;
LUT(41) =  1;
LUT(43) = -1;
LUT(45) =  3;
LUT(47) =  1;
LUT(49) = -1;
LUT(51) =  1;

LUT(53) =  1;
LUT(55) = -1;
LUT(57) =  3;
LUT(59) =  1;
LUT(61) =  1;
LUT(63) = -1;
LUT(65) = -3;
LUT(67) =  3;
LUT(69) = -1;
LUT(71) =  1;
LUT(73) =  1;
LUT(75) =  3;
LUT(77) = -1;
LUT(79) =  1;
LUT(81) = -1;
LUT(83) =  1;
LUT(85) =  1;
LUT(87) = -1;
LUT(89) =  3;
LUT(91) =  1;
LUT(93) =  1;
LUT(95) = -1;
LUT(97) =  1;
LUT(99) =  3;
LUT(101) =  3;
LUT(103) =  1;

LUT(105) =  5;
LUT(107) =  3;
LUT(109) =  3;
LUT(111) =  1;
LUT(113) = -1;
LUT(115) =  1;
LUT(117) =  1;
LUT(119) = -1;
LUT(121) =  3;
LUT(123) =  1;
LUT(125) =  1;
LUT(127) = -1;
LUT(129) = -7;
LUT(131) = -1;
LUT(133) = -1;
LUT(135) =  1;
LUT(137) = -3;
LUT(139) = -1;
LUT(141) = -1;
LUT(143) =  1;
LUT(145) = -1;
LUT(147) =  1;
LUT(149) =  1;
LUT(151) = -1;
LUT(153) =  3;
LUT(155) =  1;

LUT(157) =  1;
LUT(159) = -1;
LUT(161) = -3;
LUT(163) = -1;
LUT(165) =  3;
LUT(167) =  1;
LUT(169) =  1;
LUT(171) = -1;
LUT(173) =  3;
LUT(175) =  1;
LUT(177) = -1;
LUT(179) =  1;
LUT(181) =  1;
LUT(183) = -1;
LUT(185) =  3;
LUT(187) =  1;
LUT(189) =  1;
LUT(191) = -1;
LUT(193) = -3;
LUT(195) =  3;
LUT(197) = -1;
LUT(199) =  1;
LUT(201) =  1;
LUT(203) =  3;
LUT(205) = -1;
LUT(207) =  1;

LUT(209) = -1;
LUT(211) =  1;
LUT(213) =  1;
LUT(215) = -1;
LUT(217) =  3;
LUT(219) =  1;
LUT(221) =  1;
LUT(223) = -1;
LUT(225) =  1;
LUT(227) =  3;
LUT(229) =  3;
LUT(231) =  1;
LUT(233) =  5;
LUT(235) =  3;
LUT(237) =  3;
LUT(239) =  1;
LUT(241) = -1;
LUT(243) =  1;
LUT(245) =  1;
LUT(247) = -1;
LUT(249) =  3;
LUT(251) =  1;
LUT(253) =  1;
LUT(255) = -1;
end



% function nhood = pk_get_nh_idx(img,i)
% 
% width = size(img,1);
% height = size(img,2);
% depth = size(img,3);
% 
% [x,y,z]=ind2sub([width height depth],i);
% 
% nhood = zeros(length(i),27);
% 
% for xx=1:3
%     for yy=1:3
%         for zz=1:3
%             w=sub2ind([3 3 3],xx,yy,zz);
%             nhood(:,w) = sub2ind([width height depth],x+xx-2,y+yy-2,z+zz-2);
%         end;
%     end;
% end;


