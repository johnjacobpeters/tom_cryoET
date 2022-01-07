ChimeraX_dir = '/Applications/ChimeraX-1.3.app/Contents/bin';
Input_ChimeraX_command_file = '/Users/johnpeters/Desktop/Lab/chimera3.cxc';


for i = 1:length(ls(*filt.mrc))
    print(i)
end
%[status,cmdout] = system([ChimeraX_dir '/ChimeraX ' Input_ChimeraX_command_file]);


open /Users/johnpeters/Desktop/Lab/tom_cryoET-main/Extract/extract_tomo/201810XX_MPI/SV5_001_dff/SV5_001_dff000006a_filt.mrc;
set bgColor white;
volume #1 level 0.7;
color radial #1.1 palette #ff0000:#ff7f7f:#ffffff:#7f7fff:#0000ff center 127.5,127.5,127.5
