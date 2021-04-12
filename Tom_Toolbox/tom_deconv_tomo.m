function [ deconv ] = tom_deconv_tomo( vol, angpix, defocus, snrfalloff, highpassnyquist )

% Parameters:
% vol - tomogram volume (or 2D image)
% angpix - angstrom per pixel
% defocus - defocus in micrometers, positive = underfocus
% snrfalloff - how fast does SNR fall off, i. e. higher values will downweight high frequencies; values like 1.0 or 1.2 seem reasonable
% highpassnyquist - fraction of Nyquist frequency to be cut off on the lower end (since it will be boosted the most)
%deconv = tom_deconv_tomo(mytomogram, 3.42*4, 6, 1.2, 0.01)


highpass = 0:1/2047:1;
highpass = min(1, highpass./highpassnyquist).*pi;
highpass = 1-cos(highpass);

snr = exp((0:-1/2047:-1).* snrfalloff.* 100./ angpix).* 1000.* highpass;
ctf = tom_ctf1d(2048, angpix*1e-10, 300e3, 2.7e-3, -defocus*1e-6, 0.07, 0,0);
wiener = ctf./(ctf.*ctf+1./snr);

s1 = -floor(size(vol,1)/2);
f1 = s1 + size(vol,1) - 1;
s2 = -floor(size(vol,2)/2);
f2 = s2 + size(vol,2) - 1;
s3 = -floor(size(vol,3)/2);
f3 = s3 + size(vol,3) - 1;

[x, y, z] = ndgrid(s1:f1,s2:f2,s3:f3);
x = x./abs(s1);
y = y./abs(s2);
z = z./max(1, abs(s3));
r = sqrt(x.^2+y.^2+z.^2);
r = min(1, r);
r = ifftshift(r);

x = 0:1/2047:1;

ramp = interp1(x,wiener,r);

deconv = real(ifftn(fftn(single(vol)).*ramp));

end
