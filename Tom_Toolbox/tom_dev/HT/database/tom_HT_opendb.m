function conn = tom_HT_opendb(dbname)

if nargin < 1
    dbname='HT';
end;

persistent firstrun;
if isempty(firstrun)    
    tom_HT_addjavapath();
    firstrun = 1;
end

settings = tom_HT_settings(dbname);
logintimeout(settings.db.driver, settings.db.logintimeout); 
conn = database(dbname,settings.db.username,settings.db.password,settings.db.driver,settings.db.url);

if ~isempty(conn.Message)
    error(['Cannot connect to database: ' conn.Message]);
end

if isconnection(conn) == 0
    error('Cannot connect to database');
end

setdbprefs('DataReturnFormat','structure');
setdbprefs('ErrorHandling','report');