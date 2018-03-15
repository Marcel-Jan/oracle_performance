# Marcel-Jan's repository of Oracle database performance scripts

Welcome to my repository of Oracle performance scripts. I've used them a lot in the past when I was an Oracle DBA and they helped me solve many performance issues. 

Unfortunately I won't update these scripts anymore. After 20 years I left the world of Oracle and became a Hadoop specialist in March 2017. Read more about my new adventures here: http://marcel-jan.eu/datablog


## Scripts in this repository

### sql_sql_id.sql
Retrieves a lot of information about a SQL statement, based on SQL_ID.

### sqlperf.sql
Previously known as sql_sql_id_html.sql. Same as sql_sql_id.sql, but with HTML output. You need the Diagnostics Pack if you want to run this! It will run anyway, but usage will be counted as usage of AWR in dba_feature_usage_statistics!
See my explanation of the output of this script here: https://mjsoracleblog.wordpress.com/2014/02/10/a-walkthrough-through-sqlperf-1-6-output-video/

### sqlperf_noawr.sql
sqlperf.sql for the Diagnostic Pack impaired. Does the same as sqlperf.sql, except every query that would count as Diagnostics Pack use.

### sqlstats.sql
Previously known as stats_sql_id_html.sql. A script for table/index statistics for objects accessed in the execution plan. You need the Diagnostics Pack if you want to run this! It will run anyway, but usage will be counted as usage of AWR in dba_feature_usage_statistics!

### sql_old_hash.sql
Similar to sql_sql_id.sql, to use if you don't have the sql_id, but do have the old hash values found in Statspack.

### sql_plan_baselines.sql
Retrieves information concerning the use of SQL plan baselines.

### trace_column.sql
If you quickly need to trace one or more sessions based on username, program or whatever in v$session. Read more about this script here: https://mjsoracleblog.wordpress.com/2015/05/25/trace-column-1-3/

### ora1555.sql
Use this to find out information about SQL's mentioned in ORA-1555 messages.

### top10sql_plan.sql
Show the 10 SQL statements in the shared pool

### top10sql_plan9i.sql
Still had this somewhere. You'll never know when it comes in handy, although hopefully not ;)
