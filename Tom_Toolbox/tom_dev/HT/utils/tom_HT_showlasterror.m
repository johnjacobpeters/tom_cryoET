function tom_HT_showlasterror()

%rethrow(lasterror)
err = lasterror();
disp(err.message);

for i=1:length(err.stack)
    disp(err.stack(i,1));
end