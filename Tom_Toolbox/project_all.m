%%%%%%%%%%%%%%%%%%
subtomosize=256;
peakheight=.3;
%% read in class from refinement job
vol_name = 'job1414/run_it010_class001.mrc';
vol_class1 = tom_mrcread(vol_name);
vol_class1 = vol_class1.Value;
% vol_class1fl = rescale(vol_class1,-1,1);
% vol_class1fl = vol_class1fl(:,118:138,:);
% vol_class1_projxzfl = tom_project2d(vol_class1fl, 'xz');
% total = sum(sum(sum(vol_class1)));

%%normalize class
mean_class1 = mean(vol_class1(:));
std_class1 = std(vol_class1(:));
norm_class1 = vol_class1 - mean_class1;
norm_class1 = norm_class1*(1/std_class1);

%%make virtual slice and project
norm_slice_class1 = norm_class1(:,118:138,:);
norm_vol_class1_projxz = tom_project2d(norm_slice_class1, 'xz');

vol_class1 = vol_class1(:,118:138,:);
%project class along xz axis & write it out to mrc
vol_class1_projxz = tom_project2d(vol_class1, 'xz');
tom_mrcwrite(vol_class1_projxz, 'name', strrep(vol_name, '.mrc','_xz.mrc'))
% %find local maxima in along the center axis
% pks_class1 = findpeaks(vol_class1_projxz(:,subtomosize/2));
% pks_class1 = pks_class1(pks_class1>peakheight);
%get the index for the local maximia
% for i = 1:length(pks_class1)
%    index_class1(i) = find (vol_class1_projxz(:,subtomosize/2) == pks_class1(i));
% end

%determine peak width
% index_class1_halfheight_peak1 = find (vol_class1_projxz(1:index_class1(2)+8,subtomosize/2)>pks_class1(2)/2);
% class1_halfheight_peak1_width = (index_class1_halfheight_peak1(end) - index_class1_halfheight_peak1(1))*.262;
% 
% index_class1_halfheight_peak2 = find (vol_class1_projxz(index_class1(3)-8:end,subtomosize/2)>pks_class1(3)/2) + (index_class1(3)-9);
% class1_halfheight_peak2_width = (index_class1_halfheight_peak2(end) - index_class1_halfheight_peak2(1))*.262;
% 
% %distance between the two peaks
% class1_membrane_distance = (index_class1_halfheight_peak2(1)-index_class1_halfheight_peak1(end))*.262;

%% plot traces
% class 1
figure(1)
dt=((vol_class1_projxz(:,subtomosize/2) + vol_class1_projxz(:,subtomosize/2+1) + vol_class1_projxz(:,subtomosize/2+2) + vol_class1_projxz(:,subtomosize/2+3) + vol_class1_projxz(:,subtomosize/2+4) + vol_class1_projxz(:,subtomosize/2+5) + vol_class1_projxz(:,subtomosize/2+6) + vol_class1_projxz(:,subtomosize/2+7) + vol_class1_projxz(:,subtomosize/2+8) + vol_class1_projxz(:,subtomosize/2+9) + vol_class1_projxz(:,subtomosize/2+10) + vol_class1_projxz(:,subtomosize/2-1) + vol_class1_projxz(:,subtomosize/2-2) + vol_class1_projxz(:,subtomosize/2-3) + vol_class1_projxz(:,subtomosize/2-4) + vol_class1_projxz(:,subtomosize/2-5) + vol_class1_projxz(:,subtomosize/2-6) + vol_class1_projxz(:,subtomosize/2-7) + vol_class1_projxz(:,subtomosize/2-8) + vol_class1_projxz(:,subtomosize/2-9) + vol_class1_projxz(:,subtomosize/2-10))/21);
dt = flipud(dt);
dt = normalize(dt);
p = plot(dt);
set(gca,'FontSize',12)
set(gca,'xtick',[])
%set(gca,'ytick',[])
%set(gca,'Visible','off')
set(p,'linewidth',7)
axis([0 256 -4 4])
saveas (gcf, strrep(vol_name, '.mrc','_plot.png'));
%set(gca,'Visible','off')
%export_fig (strrep(vol_name, '.mrc','_plot2'), '-dpng', '-transparent', '-r300')

%% plot projections
vol_class1_projxz_rot = imrotate(norm_vol_class1_projxz, 0);
%vol_class1_projxz_rot = vol_class1_projxz_rot/total;
imwrite (mat2gray(vol_class1_projxz_rot), strrep(vol_name, '.mrc','_xzrot.png'),'PNG');
% vol_class2_projxz_rot = imrotate(vol_class2_projxz, 90);
% imwrite (vol_class2_projxz_rot, 'class2_xz.png')
% vol_class3_projxz_rot = imrotate(vol_class3_projxz, 90);
% imwrite (vol_class3_projxz_rot, 'class3_xz.png')
figure(2)
I=imread(strrep(vol_name, '.mrc','_xzrot.png'));
imshow(I)%, [0 1])


%close ALL