------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve a lot of information about query performance, based on sql_id
--
--      Script      sql_sql_id_html.sql
--      Run as      DBA
--
--      Purpose     This script will retrieve a lot of info about a query, based on sql_id and create a HTML report
--
--      Input       sql_id, child_number
--
--      Author      M. Krijgsman
--
--      Remarks     !! A Diagnostics Pack license is required for this script !!
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     10 apr 2013 M. Krijgsman   First version, based on sql_sql_id.sql version 1.9
------------------------------------------------------------------------------------------------------------------------------------------------------

store set your_sqlplus_env.sql REPLACE

set linesize 3000
set feedback off
set verify off
set pause off
set timing off
set echo off
set heading on
set pages 999
set trimspool on
set newpage none
set define on

column vl_dbname     new_value l_dbname       noprint
column v_datetime    new_value datetime       noprint

select lower(name) vl_dbname from v$database;
select to_char(sysdate, 'YYYYMMDDHH24MISS') v_datetime from dual;

prompt =============================================
prompt =                                           =
prompt =            sql_sql_id_html.sql            =
prompt =  This script will retrieve all kinds of   =
prompt =  information about SQLs based on sql_id   =
prompt =                                           =
prompt =          (Version 10g or higher)          =
prompt =                                           =
prompt =============================================
prompt


accept sql_id    default '' -
  prompt 'Please provide the sql_id: '

prompt This instance.
prompt -----------------------------------

col instance_name for a16
col status for a16

select instance_name, instance_number, status 
from v$instance;


prompt
prompt

prompt Different versions of the query.
prompt -----------------------------------

prompt (This should return only a handful of rows, or no binds have been used)
prompt

column vl_inst_id     new_value l_inst_id       noprint
select instance_number vl_inst_id from v$instance;

col sql_id for a20
col last_active_time for a16
col last_load_time for a20
col instance for a16

select a.sql_id, a.child_number
, case 
   when a.inst_id = &l_inst_id then 'THIS ONE'
   else (select instance_name 
         from gv$instance 
         where instance_number=a.inst_id) 
   end instance, a.last_load_time
, to_char(a.last_active_time, 'DD-MON HH24:MI:SS') last_active_time
,      a.loaded_versions, a.open_versions, a.users_opening
from gv$sql a
where sql_id='&sql_id';

prompt
prompt

prompt When the query has been runned from a different instance, run this script there.
prompt

prompt

accept childnr    default '' -
prompt 'To what child_number is this case related?: '

prompt




spool sql_id_&l_dbname._&sql_id._&datetime..html

/* head '-
  <title>SQL report for &sql_id on &l_dbname</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    tr,td             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;} -
    table             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;} -
    th                {font:bold 9pt  Arial,Helvetica,sans-serif; color:#314299; background:#befdfd;} -
    h1                {font:bold 12pt Arial,Helvetica,sans-serif; color:#003399; background-color:White;} -
    h2                {font:bold 10pt Arial,Helvetica,sans-serif; color:#FF9933; background-color:White;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' */

set heading off

prompt  <TITLE>SQL report for &sql_id on &l_dbname</TITLE>
prompt  <STYLE TYPE="text/css">
prompt    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    tr,td             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    table             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    th                {font:bold 9pt  Arial,Helvetica,sans-serif; color:#314299; background:#befdfd;}
prompt    h1                {font:bold 12pt Arial,Helvetica,sans-serif; color:#003399; background-color:White;}
prompt    h2                {font:bold 10pt Arial,Helvetica,sans-serif; color:#FF9933; background-color:White;}
prompt    a                 {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt  </STYLE>

prompt    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
prompt    <script type="text/javascript">
prompt      google.load("visualization", "1", {packages:["corechart"]});
prompt      google.setOnLoadCallback(drawChart);
prompt      function drawChart() {
prompt        var data = google.visualization.arrayToDataTable([
prompt          ['Date', 'Executions', 'Responsetime']
select
',['''||
	BEGIN_INTERVAL_TIME
||''','||
	EXECUTIONS
||','||
	RESPONSETIME
||']'
from	(select trunc(a.BEGIN_INTERVAL_TIME, 'HH24') BEGIN_INTERVAL_TIME
 , sum(b.executions_delta) executions
 , round(sum(b.ELAPSED_TIME_DELTA)/decode(sum(b.EXECUTIONS_DELTA),0,1,sum(b.EXECUTIONS_DELTA))/1000000,2) responsetime 
from   dba_hist_snapshot a, 
       dba_hist_sqlstat b 
where  a.snap_id=b.snap_id 
and    a.instance_number=b.instance_number
and    b.sql_id='&sql_id' 
group by trunc(a.BEGIN_INTERVAL_TIME, 'HH24')
order by trunc(a.BEGIN_INTERVAL_TIME, 'HH24'))
;
prompt        ]);
prompt
prompt var options = {
prompt title: 'Response time',
prompt chxt: 'x,y,r',
prompt width: 1600,
prompt titleTextStyle: {color: 'black'},
prompt isStacked: true
prompt              }
prompt
prompt        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
prompt        chart.draw(data, options);
prompt      }
prompt
prompt    </script>
prompt  </head>

prompt <body text="#000000" bgcolor="#FFFFFF" link="#0000FF"
prompt    vlink="#000080" alink="#FF0000">

set markup html on spool on preformat off entmap on

--body   'BGCOLOR="#C5CDC5"' table 'WIDTH="90%" BORDER="1"' 


set    markup html on entmap off
set    head off

set markup HTML ON ENTMAP OFF
prompt <h1>SQL report, based on sql_id.</h1>
prompt <p>This file was created with:
prompt sql_sql_id_html.sql
prompt version 1.0 (2013)
prompt 
prompt dbname: &l_dbname
prompt SQL_ID: &sql_id
prompt date:   &datetime
prompt </p>
set markup HTML ON ENTMAP ON

set heading on

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>This instance.</h2>
set markup HTML ON ENTMAP ON

col instance_name for a20
col status for a20

select instance_name, instance_number, status 
from v$instance;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Different versions of the query.</h2>
prompt <p>(This should return only a handful of rows, or no binds have been used)</p>

set markup HTML ON ENTMAP ON

col sql_id for a20
col last_active_time for a16
col last_load_time for a20
col instance for a16

select a.sql_id, a.child_number
, case 
   when a.inst_id = &l_inst_id then 'THIS ONE'
   else (select instance_name 
         from gv$instance 
         where instance_number=a.inst_id) 
   end instance, a.last_load_time
, to_char(a.last_active_time, 'DD-MON HH24:MI:SS') last_active_time
,      a.loaded_versions, a.open_versions, a.users_opening
from gv$sql a
where sql_id='&sql_id';


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Childs and hash values.</h2>
set markup HTML ON ENTMAP ON

col last_active_time for a16
col last_load_time for a20

select sql_id, child_number, inst_id, last_load_time
,      hash_value, old_hash_value, plan_hash_value
from gv$sql
where sql_id='&sql_id';

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Full text of the query (up to 50000 characters).</h2>
set markup HTML ON ENTMAP ON

set long 50000

select sql_fulltext
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>SQL text from AWR memory (just in case it is not in memory anymore.)</h2>
set markup HTML ON ENTMAP ON


select *
from sys.WRH$_SQLTEXT 
where sql_id='&sql_id';

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>SQL vs. SQL Plan Baselines.</h2>
set markup HTML ON ENTMAP ON

col sql_id for a20
col plan_name for a35
col created for a30

select sql.sql_id, sql.child_number, sql.inst_id, sql.force_matching_signature, bl.plan_name, bl.enabled, bl.accepted, bl.fixed, bl.optimizer_cost
from gv$sql sql
,    dba_sql_plan_baselines bl
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=bl.SIGNATURE;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>SQL Plan Baseline information.</h2>
set markup HTML ON ENTMAP ON

col SQL_HANDLE for a30
col origin for a16
col last_modified for a30
col last_verified for a30

select sql_handle, plan_name, origin, created, last_modified, last_verified
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>SQL Profile information.</h2>
set markup HTML ON ENTMAP ON

col name for a30
col task_exec_name for a16
col category for a10

select sql.sql_id, prof.name, prof.category, prof.created, prof.task_exec_name, prof.status
from DBA_SQL_PROFILES prof
,    gv$sql sql
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=prof.SIGNATURE;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>SQL Profile metadata.</h2>
set markup HTML ON ENTMAP ON

set heading off
col outline_hints for a132

select extractvalue(value(d), '/hint') as outline_hints
from xmltable('/*/outline_data/hint' passing 
	(select xmltype(other_xml) as xmlval
   from v$sql_plan
	 where sql_id='&sql_id'
   and child_number=&childnr
   and other_xml is not null
  )
) d;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>SQL, profiles and baselines.</h2>
set markup HTML ON ENTMAP ON

set heading on

col sql_profile for a30
col sql_patch for a30
col sql_plan_baseline for a35

select sql_id, child_number, inst_id, sql_profile, sql_plan_baseline, sql_patch
from gv$sql
where sql_id='&sql_id'
and   child_number=&childnr
order by sql_id, inst_id, child_number;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Executions, number of rows.</h2>
set markup HTML ON ENTMAP ON

select executions, parse_calls, loads, rows_processed, sorts
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Response time, cpu time and wait time (in seconds).</h2>
set markup HTML ON ENTMAP ON

select trunc(elapsed_time/1000000,1) elapsed_time, trunc(application_wait_time/1000000,1) applic_wait_time, trunc(cpu_time/1000000,1) cpu_time
, trunc(user_io_wait_time/1000000,1) user_io_wait_time, trunc(concurrency_wait_time/1000000,1) concurr_time
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Memory and disk reads.</h2>
set markup HTML ON ENTMAP ON

select buffer_gets, disk_reads, (sharable_mem+persistent_mem+runtime_mem) sql_area_used
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Who ran the query?</h2>
set markup HTML ON ENTMAP ON

col username for a30
col PARSING_SCHEMA_NAME for a30
col module for a40
col action for a30
col service for a30
select u.username, s.PARSING_SCHEMA_NAME, s.SERVICE, s.MODULE, s.ACTION
from v$sql s
,    dba_users u
where s.sql_id='&sql_id'
and s.child_number=&childnr
and u.user_id=s.PARSING_USER_ID;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Bind aware, sharable?</h2>
set markup HTML ON ENTMAP ON

col IS_OBSOLETE for a11
col IS_BIND_SENSITIVE for a17
col IS_BIND_AWARE for a13
col IS_SHAREABLE for a12

select IS_OBSOLETE, IS_BIND_SENSITIVE, IS_BIND_AWARE, IS_SHAREABLE     
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Adaptive cursor sharing.</h2>
set markup HTML ON ENTMAP ON

col PREDICATE for a30

select inst_id, sql_id, child_number, predicate,range_id, low, high
from GV$SQL_CS_SELECTIVITY 
where sql_id = '&sql_id'
order by inst_id, child_number;

prompt
prompt

select * from GV$SQL_CS_HISTOGRAM
where sql_id = '&sql_id'
order by inst_id, child_number;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Bind mismatches (10.2)</h2>
prompt <p>(If an ORA-00904 occurs, this wasn't a 10.2 database)</p>  -- '
set markup HTML ON ENTMAP ON

SELECT substr(version, 1, instr(version, '.', 1,2)-1) version
FROM PRODUCT_COMPONENT_VERSION
where product like '%Database%';

set heading off
set linesize 80

set markup HTML OFF ENTMAP OFF
prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT           'UNBOUND_CURSOR:            '||SUM(TO_NUMBER(DECODE(unbound_cursor,'Y',1,'N','0'))),
                 'SQL_TYPE_MISMATCH:         '||SUM(TO_NUMBER(DECODE(sql_type_mismatch,'Y',1,'N','0'))),
                 'OPTIMIZER_MISMATCH:        '||SUM(TO_NUMBER(DECODE(optimizer_mismatch,'Y',1,'N','0'))),
                 'OUTLINE_MISMATCH:          '||SUM(TO_NUMBER(DECODE(outline_mismatch,'Y',1,'N','0'))),
                 'STATS_ROW_MISMATCH:        '||SUM(TO_NUMBER(DECODE(stats_row_mismatch,'Y',1,'N','0'))),
                 'LITERAL_MISMATCH:          '||SUM(TO_NUMBER(DECODE(literal_mismatch,'Y',1,'N','0'))),
                 'SEC_DEPTH_MISMATCH:        '||SUM(TO_NUMBER(DECODE(sec_depth_mismatch,'Y',1,'N','0'))),
                 'EXPLAIN_PLAN_CURSOR:       '||SUM(TO_NUMBER(DECODE(explain_plan_cursor,'Y',1,'N','0'))),
                 'BUFFERED_DML_MISMATCH:     '||SUM(TO_NUMBER(DECODE(buffered_dml_mismatch,'Y',1,'N','0'))),
                 'PDML_ENV_MISMATCH:         '||SUM(TO_NUMBER(DECODE(pdml_env_mismatch,'Y',1,'N','0'))),
                 'INST_DRTLD_MISMATCH:       '||SUM(TO_NUMBER(DECODE(inst_drtld_mismatch,'Y',1,'N','0'))),
                 'SLAVE_QC_MISMATCH:         '||SUM(TO_NUMBER(DECODE(slave_qc_mismatch,'Y',1,'N','0'))),
                 'TYPECHECK_MISMATCH:        '||SUM(TO_NUMBER(DECODE(typecheck_mismatch,'Y',1,'N','0'))),
                 'AUTH_CHECK_MISMATCH:       '||SUM(TO_NUMBER(DECODE(auth_check_mismatch,'Y',1,'N','0'))),
                 'BIND_MISMATCH:             '||SUM(TO_NUMBER(DECODE(bind_mismatch,'Y',1,'N','0'))),
                 'DESCRIBE_MISMATCH:         '||SUM(TO_NUMBER(DECODE(describe_mismatch,'Y',1,'N','0'))),
                 'LANGUAGE_MISMATCH:         '||SUM(TO_NUMBER(DECODE(language_mismatch,'Y',1,'N','0'))),
                 'TRANSLATION_MISMATCH:      '||SUM(TO_NUMBER(DECODE(translation_mismatch,'Y',1,'N','0'))),
                 'ROW_LEVEL_SEC_MISMATCH:    '||SUM(TO_NUMBER(DECODE(row_level_sec_mismatch,'Y',1,'N','0'))),
                 'ROW_LEVEL_SEC_MISMATCH:    '||SUM(TO_NUMBER(DECODE(insuff_privs,'Y',1,'N','0'))),
                 'INSUFF_PRIVS_REM:          '||SUM(TO_NUMBER(DECODE(insuff_privs_rem,'Y',1,'N','0'))),
                 'REMOTE_TRANS_MISMATCH:     '||SUM(TO_NUMBER(DECODE(remote_trans_mismatch,'Y',1,'N','0'))),
                 'LOGMINER_SESSION_MISMATCH: '||SUM(TO_NUMBER(DECODE(logminer_session_mismatch,'Y',1,'N','0'))),
                 'INCOMP_LTRL_MISMATCH:      '||SUM(TO_NUMBER(DECODE(incomp_ltrl_mismatch,'Y',1,'N','0'))),
                 'OVERLAP_TIME_MISMATCH:     '||SUM(TO_NUMBER(DECODE(overlap_time_mismatch,'Y',1,'N','0'))),
                 'SQL_REDIRECT_MISMATCH:     '||SUM(TO_NUMBER(DECODE(sql_redirect_mismatch,'Y',1,'N','0'))),
                 'MV_QUERY_GEN_MISMATCH:     '||SUM(TO_NUMBER(DECODE(mv_query_gen_mismatch,'Y',1,'N','0'))),
                 'USER_BIND_PEEK_MISMATCH:   '||SUM(TO_NUMBER(DECODE(user_bind_peek_mismatch,'Y',1,'N','0'))),
                 'TYPCHK_DEP_MISMATCH:       '||SUM(TO_NUMBER(DECODE(typchk_dep_mismatch,'Y',1,'N','0'))),
                 'NO_TRIGGER_MISMATCH:       '||SUM(TO_NUMBER(DECODE(no_trigger_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_CURSOR:          '||SUM(TO_NUMBER(DECODE(flashback_cursor,'Y',1,'N','0'))),
                 'ANYDATA_TRANSFORMATION:    '||SUM(TO_NUMBER(DECODE(anydata_transformation,'Y',1,'N','0'))),
                 'INCOMPLETE_CURSOR:         '||SUM(TO_NUMBER(DECODE(incomplete_cursor,'Y',1,'N','0'))),
                 'TOP_LEVEL_RPI_CURSOR:      '||SUM(TO_NUMBER(DECODE(top_level_rpi_cursor,'Y',1,'N','0'))),
                 'DIFFERENT_LONG_LENGTH:     '||SUM(TO_NUMBER(DECODE(different_long_length,'Y',1,'N','0'))),
                 'LOGICAL_STANDBY_APPLY:     '||SUM(TO_NUMBER(DECODE(logical_standby_apply,'Y',1,'N','0'))),
                 'LOGICAL_STANDBY_APPLY:     '||SUM(TO_NUMBER(DECODE(diff_call_durn,'Y',1,'N','0'))),
                 'BIND_UACS_DIFF:            '||SUM(TO_NUMBER(DECODE(bind_uacs_diff,'Y',1,'N','0'))),
                 'PLSQL_CMP_SWITCHS_DIFF:    '||SUM(TO_NUMBER(DECODE(plsql_cmp_switchs_diff,'Y',1,'N','0'))),
                 'CURSOR_PARTS_MISMATCH:     '||SUM(TO_NUMBER(DECODE(cursor_parts_mismatch,'Y',1,'N','0'))),
                 'STB_OBJECT_MISMATCH:       '||SUM(TO_NUMBER(DECODE(stb_object_mismatch,'Y',1,'N','0'))),
                 'ROW_SHIP_MISMATCH:         '||SUM(TO_NUMBER(DECODE(row_ship_mismatch,'Y',1,'N','0'))),
                 'PQ_SLAVE_MISMATCH:         '||SUM(TO_NUMBER(DECODE(pq_slave_mismatch,'Y',1,'N','0'))),
                 'TOP_LEVEL_DDL_MISMATCH:    '||SUM(TO_NUMBER(DECODE(top_level_ddl_mismatch,'Y',1,'N','0'))),
                 'MULTI_PX_MISMATCH:         '||SUM(TO_NUMBER(DECODE(multi_px_mismatch,'Y',1,'N','0'))),
                 'BIND_PEEKED_PQ_MISMATCH:   '||SUM(TO_NUMBER(DECODE(bind_peeked_pq_mismatch,'Y',1,'N','0'))),
                 'MV_REWRITE_MISMATCH:       '||SUM(TO_NUMBER(DECODE(mv_rewrite_mismatch,'Y',1,'N','0'))),
                 'ROLL_INVALID_MISMATCH:     '||SUM(TO_NUMBER(DECODE(roll_invalid_mismatch,'Y',1,'N','0'))),
                 'OPTIMIZER_MODE_MISMATCH:   '||SUM(TO_NUMBER(DECODE(optimizer_mode_mismatch,'Y',1,'N','0'))),
                 'PX_MISMATCH:               '||SUM(TO_NUMBER(DECODE(px_mismatch,'Y',1,'N','0'))),
                 'MV_STALEOBJ_MISMATCH:      '||SUM(TO_NUMBER(DECODE(mv_staleobj_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_TABLE_MISMATCH:  '||SUM(TO_NUMBER(DECODE(flashback_table_mismatch,'Y',1,'N','0'))),
                 'LITREP_COMP_MISMATCH:      '||SUM(TO_NUMBER(DECODE(litrep_comp_mismatch,'Y',1,'N','0')))
FROM   v$sql_shared_cursor
WHERE  address IN (SELECT address
                   FROM   v$sqlarea
                   WHERE  sql_id = '&sql_id')
/

prompt </pre>

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Bind mismatches (11.1)</h2>
prompt <p>(If an ORA-00904 occurs, this wasn't a 11.1 database)</p> -- '
set markup HTML OFF ENTMAP OFF

prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT           'UNBOUND_CURSOR:                '||SUM(TO_NUMBER(DECODE(unbound_cursor,'Y',1,'N','0'))),
                 'SQL_TYPE_MISMATCH:             '||SUM(TO_NUMBER(DECODE(sql_type_mismatch,'Y',1,'N','0'))),
                 'OPTIMIZER_MISMATCH:            '||SUM(TO_NUMBER(DECODE(optimizer_mismatch,'Y',1,'N','0'))),
                 'OUTLINE_MISMATCH:              '||SUM(TO_NUMBER(DECODE(outline_mismatch,'Y',1,'N','0'))),
                 'STATS_ROW_MISMATCH:            '||SUM(TO_NUMBER(DECODE(stats_row_mismatch,'Y',1,'N','0'))),
                 'LITERAL_MISMATCH:              '||SUM(TO_NUMBER(DECODE(literal_mismatch,'Y',1,'N','0'))),
                 'FORCE_HARD_PARSE:              '||SUM(TO_NUMBER(DECODE(force_hard_parse,'Y',1,'N','0'))),
                 'EXPLAIN_PLAN_CURSOR:           '||SUM(TO_NUMBER(DECODE(explain_plan_cursor,'Y',1,'N','0'))),
                 'BUFFERED_DML_MISMATCH:         '||SUM(TO_NUMBER(DECODE(buffered_dml_mismatch,'Y',1,'N','0'))),
                 'PDML_ENV_MISMATCH:             '||SUM(TO_NUMBER(DECODE(pdml_env_mismatch,'Y',1,'N','0'))),
                 'INST_DRTLD_MISMATCH:           '||SUM(TO_NUMBER(DECODE(inst_drtld_mismatch,'Y',1,'N','0'))),
                 'SLAVE_QC_MISMATCH:             '||SUM(TO_NUMBER(DECODE(slave_qc_mismatch,'Y',1,'N','0'))),
                 'TYPECHECK_MISMATCH:            '||SUM(TO_NUMBER(DECODE(typecheck_mismatch,'Y',1,'N','0'))),
                 'AUTH_CHECK_MISMATCH:           '||SUM(TO_NUMBER(DECODE(auth_check_mismatch,'Y',1,'N','0'))),
                 'BIND_MISMATCH:                 '||SUM(TO_NUMBER(DECODE(bind_mismatch,'Y',1,'N','0'))),
                 'DESCRIBE_MISMATCH:             '||SUM(TO_NUMBER(DECODE(describe_mismatch,'Y',1,'N','0'))),
                 'LANGUAGE_MISMATCH:             '||SUM(TO_NUMBER(DECODE(language_mismatch,'Y',1,'N','0'))),
                 'TRANSLATION_MISMATCH:          '||SUM(TO_NUMBER(DECODE(translation_mismatch,'Y',1,'N','0'))),
                 'ROW_LEVEL_SEC_MISMATCH:        '||SUM(TO_NUMBER(DECODE(row_level_sec_mismatch,'Y',1,'N','0'))),
                 'INSUFF_PRIVS:                  '||SUM(TO_NUMBER(DECODE(insuff_privs,'Y',1,'N','0'))),
                 'INSUFF_PRIVS_REM:              '||SUM(TO_NUMBER(DECODE(insuff_privs_rem,'Y',1,'N','0'))),
                 'REMOTE_TRANS_MISMATCH:         '||SUM(TO_NUMBER(DECODE(remote_trans_mismatch,'Y',1,'N','0'))),
                 'LOGMINER_SESSION_MISMATCH:     '||SUM(TO_NUMBER(DECODE(logminer_session_mismatch,'Y',1,'N','0'))),
                 'INCOMP_LTRL_MISMATCH:          '||SUM(TO_NUMBER(DECODE(incomp_ltrl_mismatch,'Y',1,'N','0'))),
                 'OVERLAP_TIME_MISMATCH:         '||SUM(TO_NUMBER(DECODE(overlap_time_mismatch,'Y',1,'N','0'))),
                 'EDITION_MISMATCH:              '||SUM(TO_NUMBER(DECODE(edition_mismatch,'Y',1,'N','0'))),
                 'MV_QUERY_GEN_MISMATCH:         '||SUM(TO_NUMBER(DECODE(mv_query_gen_mismatch,'Y',1,'N','0'))),
                 'USER_BIND_PEEK_MISMATCH:       '||SUM(TO_NUMBER(DECODE(user_bind_peek_mismatch,'Y',1,'N','0'))),
                 'TYPCHK_DEP_MISMATCH:           '||SUM(TO_NUMBER(DECODE(typchk_dep_mismatch,'Y',1,'N','0'))),
                 'NO_TRIGGER_MISMATCH:           '||SUM(TO_NUMBER(DECODE(no_trigger_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_CURSOR:              '||SUM(TO_NUMBER(DECODE(flashback_cursor,'Y',1,'N','0'))),
                 'ANYDATA_TRANSFORMATION:        '||SUM(TO_NUMBER(DECODE(anydata_transformation,'Y',1,'N','0'))),
                 'INCOMPLETE_CURSOR:             '||SUM(TO_NUMBER(DECODE(incomplete_cursor,'Y',1,'N','0'))),
                 'TOP_LEVEL_RPI_CURSOR:          '||SUM(TO_NUMBER(DECODE(top_level_rpi_cursor,'Y',1,'N','0'))),
                 'DIFFERENT_LONG_LENGTH:         '||SUM(TO_NUMBER(DECODE(different_long_length,'Y',1,'N','0'))),
                 'LOGICAL_STANDBY_APPLY:         '||SUM(TO_NUMBER(DECODE(logical_standby_apply,'Y',1,'N','0'))),
                 'DIFF_CALL_DURN:                '||SUM(TO_NUMBER(DECODE(diff_call_durn,'Y',1,'N','0'))),
                 'BIND_UACS_DIFF:                '||SUM(TO_NUMBER(DECODE(bind_uacs_diff,'Y',1,'N','0'))),
                 'PLSQL_CMP_SWITCHS_DIFF:        '||SUM(TO_NUMBER(DECODE(plsql_cmp_switchs_diff,'Y',1,'N','0'))),
                 'CURSOR_PARTS_MISMATCH:         '||SUM(TO_NUMBER(DECODE(cursor_parts_mismatch,'Y',1,'N','0'))),
                 'STB_OBJECT_MISMATCH:           '||SUM(TO_NUMBER(DECODE(stb_object_mismatch,'Y',1,'N','0'))),
                 'CROSSEDITION_TRIGGER_MISMATCH: '||SUM(TO_NUMBER(DECODE(crossedition_trigger_mismatch,'Y',1,'N','0'))),
                 'PQ_SLAVE_MISMATCH:             '||SUM(TO_NUMBER(DECODE(pq_slave_mismatch,'Y',1,'N','0'))),
                 'TOP_LEVEL_DDL_MISMATCH:        '||SUM(TO_NUMBER(DECODE(top_level_ddl_mismatch,'Y',1,'N','0'))),
                 'MULTI_PX_MISMATCH:             '||SUM(TO_NUMBER(DECODE(multi_px_mismatch,'Y',1,'N','0'))),
                 'BIND_PEEKED_PQ_MISMATCH:       '||SUM(TO_NUMBER(DECODE(bind_peeked_pq_mismatch,'Y',1,'N','0'))),
                 'MV_REWRITE_MISMATCH:           '||SUM(TO_NUMBER(DECODE(mv_rewrite_mismatch,'Y',1,'N','0'))),
                 'ROLL_INVALID_MISMATCH:         '||SUM(TO_NUMBER(DECODE(roll_invalid_mismatch,'Y',1,'N','0'))),
                 'OPTIMIZER_MODE_MISMATCH:       '||SUM(TO_NUMBER(DECODE(optimizer_mode_mismatch,'Y',1,'N','0'))),
                 'PX_MISMATCH:                   '||SUM(TO_NUMBER(DECODE(px_mismatch,'Y',1,'N','0'))),
                 'MV_STALEOBJ_MISMATCH:          '||SUM(TO_NUMBER(DECODE(mv_staleobj_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_TABLE_MISMATCH:      '||SUM(TO_NUMBER(DECODE(flashback_table_mismatch,'Y',1,'N','0'))),
                 'LITREP_COMP_MISMATCH:          '||SUM(TO_NUMBER(DECODE(litrep_comp_mismatch,'Y',1,'N','0'))),
                 'PLSQL_DEBUG:                   '||SUM(TO_NUMBER(DECODE(plsql_debug,'Y',1,'N','0'))),
                 'LOAD_OPTIMIZER_STATS:          '||SUM(TO_NUMBER(DECODE(load_optimizer_stats,'Y',1,'N','0'))),
                 'ACL_MISMATCH:                  '||SUM(TO_NUMBER(DECODE(acl_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_ARCHIVE_MISMATCH:    '||SUM(TO_NUMBER(DECODE(flashback_archive_mismatch,'Y',1,'N','0'))),
                 'LOCK_USER_SCHEMA_FAILED:       '||SUM(TO_NUMBER(DECODE(lock_user_schema_failed,'Y',1,'N','0'))),
                 'REMOTE_MAPPING_MISMATCH:       '||SUM(TO_NUMBER(DECODE(remote_mapping_mismatch,'Y',1,'N','0'))),
                 'LOAD_RUNTIME_HEAP_FAILED:      '||SUM(TO_NUMBER(DECODE(load_runtime_heap_failed,'Y',1,'N','0'))),
                 'HASH_MATCH_FAILED:             '||SUM(TO_NUMBER(DECODE(hash_match_failed,'Y',1,'N','0')))
FROM   v$sql_shared_cursor
WHERE  address IN (SELECT address
                   FROM   v$sqlarea
                   WHERE  sql_id = '&sql_id')
/
prompt </pre>

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Bind mismatches (11.2)</h2>
prompt <p>(If an ORA-00904 occurs, this wasn't a 11.2 database)</p>  -- '

set markup HTML OFF ENTMAP OFF
prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT           'UNBOUND_CURSOR:                 '||SUM(TO_NUMBER(DECODE(unbound_cursor,'Y',1,'N','0'))),
                 'SQL_TYPE_MISMATCH:              '||SUM(TO_NUMBER(DECODE(sql_type_mismatch,'Y',1,'N','0'))),
                 'OPTIMIZER_MISMATCH:             '||SUM(TO_NUMBER(DECODE(optimizer_mismatch,'Y',1,'N','0'))),
                 'OUTLINE_MISMATCH:               '||SUM(TO_NUMBER(DECODE(outline_mismatch,'Y',1,'N','0'))),
                 'STATS_ROW_MISMATCH:             '||SUM(TO_NUMBER(DECODE(stats_row_mismatch,'Y',1,'N','0'))),
                 'LITERAL_MISMATCH:               '||SUM(TO_NUMBER(DECODE(literal_mismatch,'Y',1,'N','0'))),
                 'FORCE_HARD_PARSE:               '||SUM(TO_NUMBER(DECODE(force_hard_parse,'Y',1,'N','0'))),
                 'EXPLAIN_PLAN_CURSOR:            '||SUM(TO_NUMBER(DECODE(explain_plan_cursor,'Y',1,'N','0'))),
                 'BUFFERED_DML_MISMATCH:          '||SUM(TO_NUMBER(DECODE(buffered_dml_mismatch,'Y',1,'N','0'))),
                 'PDML_ENV_MISMATCH:              '||SUM(TO_NUMBER(DECODE(pdml_env_mismatch,'Y',1,'N','0'))),
                 'INST_DRTLD_MISMATCH:            '||SUM(TO_NUMBER(DECODE(inst_drtld_mismatch,'Y',1,'N','0'))),
                 'SLAVE_QC_MISMATCH:              '||SUM(TO_NUMBER(DECODE(slave_qc_mismatch,'Y',1,'N','0'))),
                 'TYPECHECK_MISMATCH:             '||SUM(TO_NUMBER(DECODE(typecheck_mismatch,'Y',1,'N','0'))),
                 'AUTH_CHECK_MISMATCH:            '||SUM(TO_NUMBER(DECODE(auth_check_mismatch,'Y',1,'N','0'))),
                 'BIND_MISMATCH:                  '||SUM(TO_NUMBER(DECODE(bind_mismatch,'Y',1,'N','0'))),
                 'DESCRIBE_MISMATCH:              '||SUM(TO_NUMBER(DECODE(describe_mismatch,'Y',1,'N','0'))),
                 'LANGUAGE_MISMATCH:              '||SUM(TO_NUMBER(DECODE(language_mismatch,'Y',1,'N','0'))),
                 'TRANSLATION_MISMATCH:           '||SUM(TO_NUMBER(DECODE(translation_mismatch,'Y',1,'N','0'))),
                 'BIND_EQUIV_FAILURE:             '||SUM(TO_NUMBER(DECODE(bind_equiv_failure,'Y',1,'N','0'))),
                 'INSUFF_PRIVS:                   '||SUM(TO_NUMBER(DECODE(insuff_privs,'Y',1,'N','0'))),
                 'INSUFF_PRIVS_REM:               '||SUM(TO_NUMBER(DECODE(insuff_privs_rem,'Y',1,'N','0'))),
                 'REMOTE_TRANS_MISMATCH:          '||SUM(TO_NUMBER(DECODE(remote_trans_mismatch,'Y',1,'N','0'))),
                 'LOGMINER_SESSION_MISMATCH:      '||SUM(TO_NUMBER(DECODE(logminer_session_mismatch,'Y',1,'N','0'))) ,
                 'INCOMP_LTRL_MISMATCH:           '||SUM(TO_NUMBER(DECODE(incomp_ltrl_mismatch,'Y',1,'N','0'))),
                 'OVERLAP_TIME_MISMATCH:          '||SUM(TO_NUMBER(DECODE(overlap_time_mismatch,'Y',1,'N','0'))),
                 'EDITION_MISMATCH:               '||SUM(TO_NUMBER(DECODE(edition_mismatch,'Y',1,'N','0'))),
                 'MV_QUERY_GEN_MISMATCH:          '||SUM(TO_NUMBER(DECODE(mv_query_gen_mismatch,'Y',1,'N','0'))),
                 'USER_BIND_PEEK_MISMATCH:        '||SUM(TO_NUMBER(DECODE(user_bind_peek_mismatch,'Y',1,'N','0'))),
                 'TYPCHK_DEP_MISMATCH:            '||SUM(TO_NUMBER(DECODE(typchk_dep_mismatch,'Y',1,'N','0'))),
                 'NO_TRIGGER_MISMATCH:            '||SUM(TO_NUMBER(DECODE(no_trigger_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_CURSOR:               '||SUM(TO_NUMBER(DECODE(flashback_cursor,'Y',1,'N','0'))),
                 'ANYDATA_TRANSFORMATION:         '||SUM(TO_NUMBER(DECODE(anydata_transformation,'Y',1,'N','0'))),
--                 'INCOMPLETE_CURSOR:              '||SUM(TO_NUMBER(DECODE(incomplete_cursor,'Y',1,'N','0'))),
                 'TOP_LEVEL_RPI_CURSOR:           '||SUM(TO_NUMBER(DECODE(top_level_rpi_cursor,'Y',1,'N','0'))),
                 'DIFFERENT_LONG_LENGTH:          '||SUM(TO_NUMBER(DECODE(different_long_length,'Y',1,'N','0'))),
                 'LOGICAL_STANDBY_APPLY:          '||SUM(TO_NUMBER(DECODE(logical_standby_apply,'Y',1,'N','0'))),
                 'DIFF_CALL_DURN:                 '||SUM(TO_NUMBER(DECODE(diff_call_durn,'Y',1,'N','0'))),
                 'BIND_UACS_DIFF:                 '||SUM(TO_NUMBER(DECODE(bind_uacs_diff,'Y',1,'N','0'))),
                 'PLSQL_CMP_SWITCHS_DIFF:         '||SUM(TO_NUMBER(DECODE(plsql_cmp_switchs_diff,'Y',1,'N','0'))),
                 'CURSOR_PARTS_MISMATCH:          '||SUM(TO_NUMBER(DECODE(cursor_parts_mismatch,'Y',1,'N','0'))),
                 'STB_OBJECT_MISMATCH:            '||SUM(TO_NUMBER(DECODE(stb_object_mismatch,'Y',1,'N','0'))),
                 'CROSSEDITION_TRIGGER_MISMATCH : '||SUM(TO_NUMBER(DECODE(crossedition_trigger_mismatch,'Y',1,'N','0'))),
                 'PQ_SLAVE_MISMATCH:              '||SUM(TO_NUMBER(DECODE(pq_slave_mismatch,'Y',1,'N','0'))),
                 'TOP_LEVEL_DDL_MISMATCH:         '||SUM(TO_NUMBER(DECODE(top_level_ddl_mismatch,'Y',1,'N','0'))),
                 'MULTI_PX_MISMATCH:              '||SUM(TO_NUMBER(DECODE(multi_px_mismatch,'Y',1,'N','0'))),
                 'BIND_PEEKED_PQ_MISMATCH:        '||SUM(TO_NUMBER(DECODE(bind_peeked_pq_mismatch,'Y',1,'N','0'))),
                 'MV_REWRITE_MISMATCH:            '||SUM(TO_NUMBER(DECODE(mv_rewrite_mismatch,'Y',1,'N','0'))),
                 'ROLL_INVALID_MISMATCH:          '||SUM(TO_NUMBER(DECODE(roll_invalid_mismatch,'Y',1,'N','0'))),
                 'OPTIMIZER_MODE_MISMATCH:        '||SUM(TO_NUMBER(DECODE(optimizer_mode_mismatch,'Y',1,'N','0'))),
                 'PX_MISMATCH:                    '||SUM(TO_NUMBER(DECODE(px_mismatch,'Y',1,'N','0'))),
                 'MV_STALEOBJ_MISMATCH:           '||SUM(TO_NUMBER(DECODE(mv_staleobj_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_TABLE_MISMATCH:       '||SUM(TO_NUMBER(DECODE(flashback_table_mismatch,'Y',1,'N','0'))),
                 'LITREP_COMP_MISMATCH:           '||SUM(TO_NUMBER(DECODE(litrep_comp_mismatch,'Y',1,'N','0'))),
                 'PLSQL_DEBUG:                    '||SUM(TO_NUMBER(DECODE(plsql_debug,'Y',1,'N','0'))),
                 'LOAD_OPTIMIZER_STATS:           '||SUM(TO_NUMBER(DECODE(load_optimizer_stats,'Y',1,'N','0'))),
                 'ACL_MISMATCH:                   '||SUM(TO_NUMBER(DECODE(acl_mismatch,'Y',1,'N','0'))),
                 'FLASHBACK_ARCHIVE_MISMATCH:     '||SUM(TO_NUMBER(DECODE(flashback_archive_mismatch,'Y',1,'N','0'))),
                 'LOCK_USER_SCHEMA_FAILED:        '||SUM(TO_NUMBER(DECODE(lock_user_schema_failed,'Y',1,'N','0'))),
                 'REMOTE_MAPPING_MISMATCH:        '||SUM(TO_NUMBER(DECODE(remote_mapping_mismatch,'Y',1,'N','0'))),
                 'LOAD_RUNTIME_HEAP_FAILED:       '||SUM(TO_NUMBER(DECODE(load_runtime_heap_failed,'Y',1,'N','0'))),
                 'HASH_MATCH_FAILED:              '||SUM(TO_NUMBER(DECODE(hash_match_failed,'Y',1,'N','0'))),
                 'PURGED_CURSOR:                  '||SUM(TO_NUMBER(DECODE(purged_cursor,'Y',1,'N','0'))),
                 'BIND_LENGTH_UPGRADEABLE:        '||SUM(TO_NUMBER(DECODE(bind_length_upgradeable,'Y',1,'N','0')))
FROM   v$sql_shared_cursor
WHERE  address IN (SELECT address
                   FROM   v$sqlarea
                   WHERE  sql_id = '&sql_id')
/

prompt </pre>

set heading on
set linesize 255

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Content of bind variabeles (use as example).</h2>
set markup HTML ON ENTMAP ON

col name for a10
col value_string for a30
col datatype_string for a20

select child_number, name, position, value_string, datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
order by position;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Bind variables as SQL*Plus commands.</h2>
set markup HTML ON ENTMAP ON

set heading off

select 'variable '||replace(name, ':', 'BIND_')||' '||datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
order by position;

prompt

select 'exec '||replace(name, ':', ':BIND_')||' := '||value_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
and datatype_string NOT LIKE '%CHAR%'
and datatype_string NOT IN ('DATE', 'CLOB')
order by position;

select 'exec '||replace(name, ':', ':BIND_')||' := '''||value_string||''''
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
and (datatype_string LIKE '%CHAR%'
     OR datatype_string IN ('DATE', 'CLOB'))
order by position;



prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Values of bind variables of other childs.</h2>
set markup HTML ON ENTMAP ON

set heading on
col name for a10
col value_string for a30
col datatype_string for a20

select child_number, name, position, value_string, datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number <> &childnr
order by child_number, position;

set heading off

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Execution plan of the query.</h2>

set markup HTML OFF ENTMAP OFF

prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT plan_table_output
FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'TYPICAL'));
prompt </pre>

set markup HTML ON ENTMAP OFF
prompt
prompt
prompt
prompt <h2>All execution plans in sql plan baselines.</h2>
prompt <p>Run as DBA to see this.</p>
set markup HTML ON ENTMAP ON

column v_sql_handle     new_value l_sql_handle       noprint

set markup HTML OFF ENTMAP OFF

prompt <pre xml:space="preserve" class="oac_no_warn">
select distinct plan.SQL_HANDLE v_sql_handle
from dba_sql_plan_baselines plan
,    gv$sql sql
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=plan.SIGNATURE;
prompt </pre>

prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT * FROM TABLE(dbms_xplan.display_sql_plan_baseline(sql_handle=>'&l_sql_handle'));
prompt </pre>


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Dropping associated SQL plan baselines.</h2>
prompt <p>(Based on SQL_HANDLE gives an error, but works.
prompt Not much success based on PLAN_NAME yet.)</p>


select distinct 'select sys.dbms_spm.DROP_SQL_PLAN_BASELINE('''||sql_handle||''') from dual;' "Based on SQL_HANDLE"
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);

prompt

select 'select sys.dbms_spm.DROP_SQL_PLAN_BASELINE(''plan_name=>'||plan_name||''') from dual;' "Based on PLAN_NAME"
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);


prompt
prompt
prompt
prompt <h2>Generated statement to purge your SQL statement from the shared pool.</h2>

select 'exec sys.dbms_shared_pool.purge('''||address||', '||hash_value||''', ''c'')'
from v$sql
where sql_id = '&sql_id'
and child_number=&childnr;

prompt
prompt

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>History of query response time.</h2>
set markup HTML ON ENTMAP ON

alter session set NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI:SS.FF';

set headin on

col BEGIN_INTERVAL_TIME for a40
col FORCE_MATCHING_SIGNATURE for 9999999999999999999999
select a.BEGIN_INTERVAL_TIME
,  a.INSTANCE_NUMBER
 , b.PLAN_HASH_VALUE
 , b.FORCE_MATCHING_SIGNATURE
 , b.executions_delta
 , round(b.ELAPSED_TIME_DELTA/decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)/1000000,2) tijd 
from   dba_hist_snapshot a, 
       dba_hist_sqlstat b 
where  a.snap_id=b.snap_id 
and    a.instance_number=b.instance_number
and    b.sql_id='&sql_id' 
order by a.BEGIN_INTERVAL_TIME
/

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Query response time graph.</h2>


prompt <div id="chart_div" style="width: 700px; height: 500px;"></div>

spool off

@your_sqlplus_env.sql
