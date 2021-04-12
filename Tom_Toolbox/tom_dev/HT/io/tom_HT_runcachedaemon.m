function tom_HT_runcachedaemon()

settings = tom_HT_settings();

if settings.cachedaemon.use == 1

    disp('starting file readahead cache daemon...');
    %status = system([settings.code_basedir '/io/cached.pl ' num2str(settings.cachedaemon.port) ' &']);
    status=system('/fs/pool/pool-bmsan-apps/tom_dev/HT/io/cached.pl&');
    if status ~= 0
        warning('Problem starting daemon.');
    end
end