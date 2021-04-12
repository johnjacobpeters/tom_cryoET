function lastid = tom_HT_lastinsertid(conn)

result = exec(conn,'SELECT LAST_INSERT_ID() AS lastid');
lastid = fetch(result);
lastid = lastid.Data.lastid;