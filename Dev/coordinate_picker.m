ChimeraX_dir = '/Applications/ChimeraX-1.3.app/Contents/bin';
Input_ChimeraX_command_file = '/Users/johnpeters/Desktop/Lab/chimera3.cxc';


for i = 1:length(ls(*filt.mrc))
    print(i)
end
%[status,cmdout] = system([ChimeraX_dir '/ChimeraX ' Input_ChimeraX_command_file]);

