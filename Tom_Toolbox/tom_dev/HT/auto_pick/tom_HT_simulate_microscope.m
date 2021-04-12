function tom_HT_simulate_microscope(input_dir,output_dir,interval)

dircell = tom_HT_getdircontents(input_dir,{'em'},true);

for i=1:size(dircell,2)

    [status,message] = copyfile([input_dir '/' dircell{i}],[output_dir '/' dircell{i}],'f');
    if status ~= 1
        error(message);
    end

    [status,message] = fileattrib([output_dir '/' dircell{i}],'+w','u g');
    if status ~= 1
        error(message);
    end
    
    tom_HT_setcrc([output_dir '/' dircell{i}]);
    
    disp(['Copied file ' dircell{i}]);
    pause(interval);
end