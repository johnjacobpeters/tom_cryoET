function [mask_final] = mask_geometric(boxsize,offset,width,thickness,curve)

%Generates geometric shapes to build mask
cyl=tom_cylindermask(ones([boxsize,boxsize,boxsize]),width,1,[round(boxsize/2),round(boxsize/2)]);
sph_top=(tom_spheremask(ones([boxsize,boxsize,boxsize]),curve,1,[round(boxsize/2),round(boxsize/2),round(boxsize/2)+offset-round(thickness/2)-curve])-1)*-1;
sph_bot=(tom_spheremask(ones([boxsize,boxsize,boxsize]),curve,1,[round(boxsize/2),round(boxsize/2),round(boxsize/2)+offset+round(thickness/2)+curve])-1)*-1;

%for the golfclub for jeremy
%sph_top=(tom_spheremask(ones([boxsize,boxsize,boxsize]),curve,1,[round(boxsize/2),round(boxsize/2),round(boxsize/2)+offset-round(thickness/2)])-1);
%sph_bot=(tom_spheremask(ones([boxsize,boxsize,boxsize]),curve,1,[round(boxsize/2),round(boxsize/2),round(boxsize/2)+thickness])-1)*-1;
%mask_final=(cyl+sph_top).*sph_bot;


%creates and displays masks
mask_final=cyl.*sph_top.*sph_bot;
%mask_final = tom_cylindermask(ones([boxsize,boxsize,boxsize]),width,1,[round(boxsize/2),round(boxsize/2)]);

%tom_volxyz(mask_final)

%imports old initial model, applies mask to old initial model, displays,
%saves
%old=tom_mrcread('mask.mrc');
%old=tom_mrcread('Extract/extract_cut/201810XX_MPI/SV4_003_dff/SV4_003_dff000013_filt.mrc');
%new = mask_final;
%test = old.Value.*new;
%tom_volxyz(test)
%tom_mrcwrite(mask_final)

%reduces to smaller box size if necessary
%cut_mask= tom_cut_out(mask_final, 'center', [256 256 256]);
%tom_volxyz(cut_mask)
%tom_mrcwrite(cut_mask)