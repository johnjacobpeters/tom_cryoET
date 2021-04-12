function settings = tom_HT_settings(Flag)

if nargin < 1
    Flag='matlab';
end;



if strcmp(Flag,'single_particle')
    settings.acquisition_basedir = '/fs/titan/test_negative_stain';
    settings.data_basedir = '/fs/pool/pool-nickell/280308/';
    settings.code_basedir = '/fs/pool/pool-bmsan-apps/tom_dev/HT/';
    %settings.db.jdbc_connector = '/usr/share/jdbc-mysql/lib/jdbc-mysql.jar';
    settings.db.jdbc_connector = '/fs/pool/pool-bmsan-pub/4Florian_beck/jdbc-mysql.jar';
    settings.db.driver = 'com.mysql.jdbc.Driver';
    settings.db.logintimeout = 5;
    %settings.db.url = 'jdbc:mysql://localhost/single_particle?username=root&password=matlab';
    settings.db.url='jdbc:mysql://prometheus/single_particle?username=root&password=matlab';
    %settings.db.url = 'jdbc:mysql://localhost/single_particle2?username=root&password=matlab';
    settings.db.username = 'root';
    settings.db.password = 'matlab';
    settings.cachedaemon.use = 1;
    settings.cachedaemon.port = 9999;
end;

if strcmp(Flag,'single_particle2')
    settings.acquisition_basedir = '/fs/titan/test_negative_stain';
    settings.data_basedir = '/fs/pool/pool-nickell2/DB_Single_Particle/';
    settings.code_basedir = '/fs/pool/pool-bmsan-apps/tom_dev/HT/';
    %settings.db.jdbc_connector = '/usr/share/jdbc-mysql/lib/jdbc-mysql.jar';
    settings.db.jdbc_connector = '/fs/pool/pool-bmsan-pub/4Florian_beck/jdbc-mysql.jar';
    settings.db.driver = 'com.mysql.jdbc.Driver';
    settings.db.logintimeout = 5;
    %settings.db.url = 'jdbc:mysql://localhost/single_particle?username=root&password=matlab';
    %settings.db.url = 'jdbc:mysql://localhost/single_particle2?username=root&password=matlab';
    settings.db.url='jdbc:mysql://prometheus/single_particle2?username=root&password=matlab';
    settings.db.username = 'root';
    settings.db.password = 'matlab';
    settings.cachedaemon.use = 1;
    settings.cachedaemon.port = 9999;
end;


if strcmp(Flag,'matlab')
    settings.acquisition_basedir = '/fs/titan/test_negative_stain';
    settings.data_basedir = '/fs/pool/pool-nickell/databasetest/';
    settings.code_basedir = '/fs/pool/pool-bmsan-apps/tom_dev/HT/';
    settings.db.jdbc_connector = '/usr/share/jdbc-mysql/lib/jdbc-mysql.jar';
    settings.db.driver = 'com.mysql.jdbc.Driver';
    settings.db.logintimeout = 5;
    settings.db.url = 'jdbc:mysql://localhost/matlab?username=root&password=matlab';
    settings.db.username = 'root';
    settings.db.password = 'matlab';
    settings.cachedaemon.use = 1;
    settings.cachedaemon.port = 9999;
end;


