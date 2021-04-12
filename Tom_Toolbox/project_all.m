%%%%%%%%%%%%%%%%%%
subtomosize=256;
peakheight=.3;
%% read in class1 from refinement job
vol_class1 = tom_mrcread('run_it020_class004.mrc');
%project class along xz axis & write it out to mrc
vol_class1_projxz = tom_project2d(vol_class1.Value, 'xz');
tom_mrcwrite(vol_class1_projxz, 'name', 'vol_class1_projxz.mrc')
%find local maxima in along the center axis
pks_class1 = findpeaks(vol_class1_projxz(:,subtomosize/2));
pks_class1 = pks_class1(pks_class1>peakheight)
%get the index for the local maximia
for i = 1:length(pks_class1)
   index_class1(i) = find (vol_class1_projxz(:,subtomosize/2) == pks_class1(i));
end

%determine peak width
index_class1_halfheight_peak1 = find (vol_class1_projxz(1:index_class1(2)+8,subtomosize/2)>pks_class1(2)/2);
class1_halfheight_peak1_width = (index_class1_halfheight_peak1(end) - index_class1_halfheight_peak1(1))*.262;

index_class1_halfheight_peak2 = find (vol_class1_projxz(index_class1(3)-8:end,subtomosize/2)>pks_class1(3)/2) + (index_class1(3)-9);
class1_halfheight_peak2_width = (index_class1_halfheight_peak2(end) - index_class1_halfheight_peak2(1))*.262;

%distance between the two peaks
class1_membrane_distance = (index_class1_halfheight_peak2(1)-index_class1_halfheight_peak1(end))*.262;
%% repeat for class2
vol_class2 = tom_mrcread('run_it020_class002.mrc');
vol_class2_projxz = tom_project2d(vol_class2.Value, 'xz');
tom_mrcwrite(vol_class2_projxz, 'name', 'vol_class2_projxz.mrc')
pks_class2 = findpeaks(vol_class2_projxz(:,subtomosize/2));
pks_class2 = pks_class2(pks_class2>peakheight)
for i = 1:length(pks_class2)
   index_class2(i) = find (vol_class2_projxz(:,subtomosize/2) == pks_class2(i));
end

%determine peak width
index_class2_halfheight_peak1 = find (vol_class2_projxz(1:index_class2(2)+8,subtomosize/2)>pks_class2(2)/2);
class2_halfheight_peak1_width = (index_class2_halfheight_peak1(end) - index_class2_halfheight_peak1(1))*.262;

index_class2_halfheight_peak2 = find (vol_class2_projxz(index_class2(3)-8:end,subtomosize/2)>pks_class2(3)/2) + (index_class2(3)-9);
class2_halfheight_peak2_width = (index_class2_halfheight_peak2(end) - index_class2_halfheight_peak2(1))*.262;

%distance between the two peaks
class2_membrane_distance = (index_class2_halfheight_peak2(1)-index_class2_halfheight_peak1(end))*.262;

%% repeat for class3
vol_class3 = tom_mrcread('run_it020_class003.mrc');
vol_class3_projxz = tom_project2d(vol_class3.Value, 'xz');
tom_mrcwrite(vol_class3_projxz, 'name', 'vol_class3_projxz.mrc')
pks_class3 = findpeaks(vol_class3_projxz(:,subtomosize/2));
pks_class3 = pks_class3(pks_class3>peakheight);
for i = 1:length(pks_class3)
   index_class3(i) = find (vol_class3_projxz(:,subtomosize/2) == pks_class3(i));
end

%determine peak width
index_class3_halfheight_peak1 = find (vol_class3_projxz(1:index_class3(2)+8,subtomosize/2)>pks_class3(2)/2);
class3_halfheight_peak1_width = (index_class3_halfheight_peak1(end) - index_class3_halfheight_peak1(1))*.262;

index_class3_halfheight_peak2 = find (vol_class3_projxz(index_class3(3)-8:end,subtomosize/2)>pks_class3(3)/2) + (index_class3(3)-9);
class3_halfheight_peak2_width = (index_class3_halfheight_peak2(end) - index_class3_halfheight_peak2(1))*.262;

%distance between the two peaks
class3_membrane_distance = (index_class3_halfheight_peak2(1)-index_class3_halfheight_peak1(end))*.262;

%% plot traces
% class 1
figure(1)
plot (vol_class1_projxz(:,subtomosize/2));
hold on
for i = 1:length (pks_class1)
    plot (index_class1(i),pks_class1(i),'-*', 'MarkerSize', 15)
end
%text(floor(median(index_class1_halfheight_peak1))-5, double(floor(pks_class1(2)/2))-3 , strcat(num2str(round(class1_halfheight_peak1_width,1)),' nm'), 'FontSize', 18)
%text(floor(median(index_class1_halfheight_peak2))-5, double(floor(pks_class1(3)/2))-3 , strcat(num2str(round(class1_halfheight_peak2_width,1)),' nm'), 'FontSize', 18)
%text(floor((index_class1_halfheight_peak1(end)+index_class1_halfheight_peak2(1))/2)-5, double(floor(pks_class1(3)/2))-5 , strcat(num2str(round(class1_membrane_distance,1)),' nm'), 'Color', 'red','FontSize', 18)

%class 2 
figure(2)
plot (vol_class2_projxz(:,subtomosize/2));
hold on
for i = 1:length (pks_class2)
    plot (index_class2(i),pks_class2(i),'-*', 'MarkerSize', 15)
end
%text(floor(median(index_class2_halfheight_peak1))-5, double(floor(pks_class2(2)/2))-3 , strcat(num2str(round(class2_halfheight_peak1_width,1)),' nm'), 'FontSize', 18)
%text(floor(median(index_class2_halfheight_peak2))-5, double(floor(pks_class2(3)/2))-3 , strcat(num2str(round(class2_halfheight_peak2_width,1)),' nm'), 'FontSize', 18)
%text(floor((index_class2_halfheight_peak1(end)+index_class2_halfheight_peak2(1))/2)-5, double(floor(pks_class2(3)/2))-5 , strcat(num2str(round(class2_membrane_distance,1)),' nm'), 'Color', 'red','FontSize', 18)

%class 3
figure(3)
plot (vol_class3_projxz(:,subtomosize/2));
hold on
for i = 1:length (pks_class3)
    plot (index_class3(i),pks_class3(i),'-*', 'MarkerSize', 15)
end
%text(floor(median(index_class3_halfheight_peak1))-5, double(floor(pks_class3(2)/2))-3 , strcat(num2str(round(class3_halfheight_peak1_width,1)),' nm'), 'FontSize', 18)
%text(floor(median(index_class3_halfheight_peak2))-5, double(floor(pks_class3(3)/2))-3 , strcat(num2str(round(class3_halfheight_peak2_width,1)),' nm'), 'FontSize', 18)
%text(floor((index_class3_halfheight_peak1(end)+index_class3_halfheight_peak2(1))/2)-5, double(floor(pks_class3(3)/2))-5 , strcat(num2str(round(class3_membrane_distance,1)),' nm'), 'Color', 'red','FontSize', 18)

%% plot projections
vol_class1_projxz_rot = imrotate(vol_class1_projxz, 90);
imwrite (vol_class1_projxz_rot, 'class1_xz.png');
vol_class2_projxz_rot = imrotate(vol_class2_projxz, 90);
imwrite (vol_class2_projxz_rot, 'class2_xz.png')
vol_class3_projxz_rot = imrotate(vol_class3_projxz, 90);
imwrite (vol_class3_projxz_rot, 'class3_xz.png')
figure(4)
imshow('class1_xz.png')
figure(5)
imshow('class2_xz.png')
figure(6)
imshow('class3_xz.png')

autoArrangeFigures()