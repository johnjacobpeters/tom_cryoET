function [cccval] = ccc_loop(starfile, cccvol1in, threshold, boxsize, zoomrange, mswedge)
% star file and mask name
%starfile = 'testmini.star';
outputstar = strrep(starfile, '.star','_out.star');
inputstar = tom_starreadrel3(starfile);
%cccvol1in = 'mask.mrc';
invol1 = tom_mrcread(cccvol1in);
invol1 = invol1.Value;

wwedge = tom_mrcread(mswedge);
wwedge = wwedge.Value;


% create output star and add ccc value
% system(['cp ' starfile  ' ' strrep(starfile,'.star','_ccc.star')]);
% system('tail -3 testmini.star > test2mini.star');
% [status,columnNum] = system ('awk ''{print NF; exit}'' test2mini.star');
% columnNum = columnNum +1;
%  system([

% looping through each mrc, apply rots and shift, calculating ccc
cccval = zeros(length(inputstar),1);

for i= 1:length(inputstar)
    invol2 = tom_mrcread(inputstar(i).rlnImageName);
    invol2 = invol2.Value;
    mwcorrvol2 = invol2.*wwedge;
    shiftOut = [inputstar(i).rlnOriginXAngst, inputstar(i).rlnOriginYAngst,inputstar(i).rlnOriginZAngst]*-1;
    rotateOut = [inputstar(i).rlnAngleRot, inputstar(i).rlnAngleTilt, inputstar(i).rlnAnglePsi]*-1;
    shiftVol = tom_shift(mwcorrvol2,shiftOut');
    rotVol = tom_rotate(shiftVol,rotateOut,'linear');
    shiftMw = tom_shift(wwedge, shiftOut');
    rotMw = tom_rotate(shiftMw, rotateOut, 'linear');
    invol1 = invol1.*rotMw;
    cccval(i)=tom_ccc(invol1(round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange)),rotVol(round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange)),'norm');
end
%threshold = 0.1;
removeList = find(cccval<threshold);

system(['cp ' starfile ' ' outputstar]);
for x = 1:length(removeList)
    system(['sed -i ''''  ''' '/'  strrep(inputstar(removeList(x)).rlnImageName, '/', '\/') '/d' ''' ' outputstar]);
end
