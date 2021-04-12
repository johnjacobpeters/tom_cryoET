function result = tom_HT_classifyctfs(psd,masksize,masksize_outer,svmStruct)

psdsize = size(psd);

mask = tom_sphere(psdsize,masksize);
mask = (mask==0);
mask_outer  = tom_sphere(psdsize,masksize_outer);
mask = mask.*mask_outer;

psd = psd.*mask;
psd = tom_cart2polar(psd);
psd = sum(psd,2)./(size(psd,2));
%psd = tom_bandpass(psd,5,50);
psd = tom_norm(psd','mean0+1std');

result = svmclassify(svmStruct, psd(masksize:masksize_outer));


