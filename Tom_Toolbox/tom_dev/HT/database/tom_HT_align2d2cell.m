function [al_cell filenames]=tom_HT_align2d2cell(align2d,package)


for i=package(1):package(2)
    al_cell{i,1}=1;
    al_cell{i,2}=1;
    al_cell{i,3}=align2d(1,i).ccc;
    al_cell{i,4}=align2d(1,i).position.y;
    al_cell{i,5}=align2d(1,i).position.x;
    al_cell{i,6}=1;
    al_cell{i,7}=align2d(1,i).class;
    al_cell{i,8}=align2d(1,i).quality;
    filenames{i}=align2d(1,i).filename;
end;



