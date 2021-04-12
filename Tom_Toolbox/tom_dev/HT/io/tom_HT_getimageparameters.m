function out = tom_HT_getimageparameters(filename,guiflag)

if nargin < 2
    guiflag = 0;
end

if ~exist(filename,'file')
    if guiflag == 1
        [icon,colormap] = tom_HT_geticon('error',64);
        msgbox(['File ' filename ' does not exist.'],'Error','custom',icon,colormap,'modal');
        return;
    else
        error(['File ' filename ' does not exist.']);
    end
end 

if tom_isemfile(filename) == 1
    
    info = tom_HT_parseemheader(filename);
    % TODO % Calculate dose of the EM images
    out.dose = 0;
    out.objectpixelsize = info.objectpixelsize;
    out.stagepos.x = info.pos(1);
    out.stagepos.y = info.pos(2);    
    out.stagepos.z = info.pos(3);
    out.Dz_nominal = info.intended_def;
    out.date = info.date;
    
else
    if guiflag == 1
        [icon,colormap] = tom_HT_geticon('error',64);
        msgbox(['File ' filename ' is not parsable.'],'Error','custom',icon,colormap,'modal');
        return;
    else
        error(['File ' filename ' is not parsable.']);
    end
end