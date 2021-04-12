function tom_HT_create_experiments()

conn = tom_HT_opendb();

fastinsert(conn,'experiment_types',{'name'},{'imageseriessorting'});

tom_HT_closedb(conn);