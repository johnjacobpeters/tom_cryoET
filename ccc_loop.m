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
%wwedge = 1;

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
    shiftOut = [inputstar(i).rlnOriginXAngst, inputstar(i).rlnOriginYAngst,inputstar(i).rlnOriginZAngst]/-2.62;
    rotateOut = [inputstar(i).rlnAnglePsi,inputstar(i).rlnAngleTilt, inputstar(i).rlnAngleRot]*-1;
    [~,fixedrotations] = tom_eulerconvert_xmipp(rotateOut(1),rotateOut(2),rotateOut(3));
    rotVol = tom_rotate(mwcorrvol2,fixedrotations,'linear');
    shiftVol = tom_shift(rotVol,shiftOut');
    
    rotMw = tom_rotate(wwedge, fixedrotations, 'linear');
    shiftMw = tom_shift(rotMw, shiftOut');
    
    mwfixedinvol1 = invol1.*shiftMw;
    cccval(i)=tom_ccc(mwfixedinvol1(round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange)),shiftVol(round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange),round(boxsize/2-zoomrange):round(boxsize/2+zoomrange)),'norm');
end
%threshold = 0.1;
removeList = find(cccval<threshold);

system(['cp ' starfile ' ' outputstar]);
for x = 1:length(removeList)
    system(['sed -i ''''  ''' '/'  strrep(inputstar(removeList(x)).rlnImageName, '/', '\/') '/d' ''' ' outputstar]);
end
