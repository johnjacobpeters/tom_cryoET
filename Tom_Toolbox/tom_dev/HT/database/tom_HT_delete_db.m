function tom_HT_delete_db(conn_data)

if nargin < 2
    conn_data.dbname='single_particle2';
end;

persistent firstrun;
if isempty(firstrun)
    tom_HT_addjavapath();
    firstrun = 1;
end

settings = tom_HT_settings(conn_data.dbname);
logintimeout(settings.db.driver, settings.db.logintimeout);
settings.db.url='jdbc:mysql://prometheus/single_particle2?username=root&password=matlab';
conn = database(conn_data.dbname,settings.db.username,settings.db.password,settings.db.driver,settings.db.url);

if ~isempty(conn.Message)
    error(['Cannot connect to database: ' conn.Message]);
end

if isconnection(conn) == 0
    error('Cannot connect to database');
end
setdbprefs('DataReturnFormat','structure');
setdbprefs('ErrorHandling','report');

disp('Connection to database successful!');

disp('deleting tables!');

tables=['Centroid,Stack,angles,autopick_conformation,experiment,man_sel_exp,man_sel_exp_descr,man_sel_exp_has_man_sel_sel,' ... 
        'man_sel_exp_has_particles,man_sel_sel,particles,particles_has_pca_experiment,pca_exp_descr,pca_experiment,' ... 
        'pca_experiment_has_pca_selection,pca_selection,result_slot'];
    
query=['delete from Centroid']; 
exec(conn,query);


query=['delete from Stack']; 
exec(conn,query);

query=['delete from angles']; 
exec(conn,query);

query=['delete from autopick_conformation']; 
exec(conn,query);

query=['delete from experiment']; 
exec(conn,query);

query=['delete from man_sel_exp']; 
exec(conn,query);

query=['delete from man_sel_exp_descr']; 
exec(conn,query);

query=['delete from man_sel_exp_has_man_sel_sel']; 
exec(conn,query);

query=['delete from man_sel_exp_has_particles']; 
exec(conn,query);

query=['delete from man_sel_sel']; 
exec(conn,query);

query=['delete from particles']; 
exec(conn,query);

query=['delete from particles_has_pca_experiment']; 
exec(conn,query);

query=['delete from pca_exp_descr']; 
exec(conn,query);

query=['delete from pca_experiment']; 
exec(conn,query);

query=['delete from pca_experiment_has_pca_selection']; 
exec(conn,query);

query=['delete from pca_selection']; 
exec(conn,query);

query=['delete from result_slot']; 
exec(conn,query);

query=['delete from pre_experiment']; 
exec(conn,query);




































