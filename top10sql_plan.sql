------------------------------------------------------------------------------------------------------------------------------------------------------
--      Show the 10 SQL statements in the shared pool
--
--      Script      top10sql_plan.sql
--      Run as      DBA
--
--      Purpose     This script will show the top 10 SQLs in memory. If you choose one SQL_ID from the
--                  list, it will show a lot of information about this SQL, like execution plan
--                  sample bind variables and information about sql plan baselines.
--
--      Input       sql_id, child_number
--
--      Author      M. Krijgsman
--
--      Remarks     None.
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     10 feb 2012 M. Krijgsman   Initieel
--      1.1	    03 mei 2012 M. Krijgsman   top 10 SQLs per instance tonen.
--      1.2	    07 mei 2012 M. Krijgsman   SQL's van andere instances tonen, daarna die van de huidige instance. 
--                                         Daar kies je een sql_id van. Toont nu alleen childs per instance.
--      1.3     25 jul 2012 M. Krijgsman   v$sql_bind_capture gegevens toegevoegd.
--      1.4     01 aug 2012 M. Krijgsman   Bind mismatch info toegevoegd.
--      1.5     19 okt 2012 M. Krijgsman   Bind variable commando's voor SQL*Plus van sample binds.
--      1.6     21 nov 2012 M. Krijgsman   English version, hash value info, sql plan baseline info included.
--      1.6.1   23 nov 2012 M. Krijgsman   Indication in "Different versions of the query" what is on this node
------------------------------------------------------------------------------------------------------------------------------------------------------

store set your_sqlplus_env.sql REPLACE

set linesize 255
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


prompt
prompt

prompt Top 10 queries on OTHER nodes
prompt (because the problem might not be at this instance)
prompt ---------------------------------------------------


select rank_elap_per_exec, elapsed_per_exec , inst_id, sql_id, elapsed_time, executions, cpu_time, applic_wait_time, user_io_wait_time
from (
	select  inst_id,
		sql_id, 
		trunc(elapsed_time/1000000,1) elapsed_time,
		executions,
		trunc(cpu_time/1000000,1) cpu_time, 
		trunc(application_wait_time/1000000,1) applic_wait_time,
		trunc(user_io_wait_time/1000000,1) user_io_wait_time, 
		trunc(concurrency_wait_time/1000000,1) concurr_time,
		trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) elapsed_per_exec,
	RANK() OVER (ORDER BY trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) desc) rank_elap_per_exec
	from gv$sql
	WHERE inst_id not in (select instance_number FROM v$instance)
)
where rank_elap_per_exec<11
order by rank_elap_per_exec
/

prompt
prompt

prompt Top 10 queries op THIS node
prompt -----------------------------------


select rank_elap_per_exec, elapsed_per_exec , inst_id, sql_id, elapsed_time, executions, cpu_time, applic_wait_time, user_io_wait_time
from (
	select  inst_id,
		sql_id, 
		trunc(elapsed_time/1000000,1) elapsed_time,
		executions,
		trunc(cpu_time/1000000,1) cpu_time, 
		trunc(application_wait_time/1000000,1) applic_wait_time,
		trunc(user_io_wait_time/1000000,1) user_io_wait_time, 
		trunc(concurrency_wait_time/1000000,1) concurr_time,
		trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) elapsed_per_exec,
	RANK() OVER (ORDER BY trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) desc) rank_elap_per_exec
	from gv$sql
	WHERE inst_id= (select instance_number FROM v$instance)
)
where rank_elap_per_exec<11
order by rank_elap_per_exec
/

accept sql_id    default '' -
  prompt 'Please provide the sql_id: '


spool top10sql_plan_&l_dbname._&datetime..txt

prompt =============================================
prompt =                                           =
prompt =  This file was created with:              =
prompt =  top10sql_plan.sql                        =
prompt =  version 1.8 (2013)                       =
prompt =                                           =
prompt =  dbname: &l_dbname                            =
prompt =  SQL_ID: &sql_id                    =
prompt =  date:   &datetime                   =
prompt =                                           =
prompt =============================================
prompt

prompt This instance.
prompt -----------------------------------

col instance_name for a16
col status for a16

select instance_name, instance_number, status 
from v$instance;


prompt This instance.
prompt -----------------------------------

col instance_name for a16
col status for a16

select instance_name, instance_number, status 
from v$instance;

prompt
prompt

prompt Top 10 queries on OTHER nodes
prompt ---------------------------------------------------


select rank_elap_per_exec, elapsed_per_exec , inst_id, sql_id, elapsed_time, executions, cpu_time, applic_wait_time, user_io_wait_time
from (
	select  inst_id,
		sql_id, 
		trunc(elapsed_time/1000000,1) elapsed_time,
		executions,
		trunc(cpu_time/1000000,1) cpu_time, 
		trunc(application_wait_time/1000000,1) applic_wait_time,
		trunc(user_io_wait_time/1000000,1) user_io_wait_time, 
		trunc(concurrency_wait_time/1000000,1) concurr_time,
		trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) elapsed_per_exec,
	RANK() OVER (ORDER BY trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) desc) rank_elap_per_exec
	from gv$sql
	WHERE inst_id not in (select instance_number FROM v$instance)
)
where rank_elap_per_exec<11
order by rank_elap_per_exec
/

prompt
prompt

prompt Top 10 queries op THIS node
prompt -----------------------------------


select rank_elap_per_exec, elapsed_per_exec , inst_id, sql_id, elapsed_time, executions, cpu_time, applic_wait_time, user_io_wait_time
from (
	select  inst_id,
		sql_id, 
		trunc(elapsed_time/1000000,1) elapsed_time,
		executions,
		trunc(cpu_time/1000000,1) cpu_time, 
		trunc(application_wait_time/1000000,1) applic_wait_time,
		trunc(user_io_wait_time/1000000,1) user_io_wait_time, 
		trunc(concurrency_wait_time/1000000,1) concurr_time,
		trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) elapsed_per_exec,
	RANK() OVER (ORDER BY trunc((elapsed_time/decode(executions, 0,1, executions))/1000000,1) desc) rank_elap_per_exec
	from gv$sql
	WHERE inst_id= (select instance_number FROM v$instance)
)
where rank_elap_per_exec<11
order by rank_elap_per_exec
/



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
  
prompt Different versions of the query.
prompt -----------------------------------

col last_active_time for a16
col last_load_time for a20

select sql_id, child_number, inst_id, last_load_time
,      hash_value, old_hash_value, plan_hash_value
from gv$sql
where sql_id='&sql_id';

prompt
prompt

prompt SQL vs. SQL Plan Baselines.
prompt -----------------------------------

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

prompt SQL Plan Baseline information.
prompt -----------------------------------

col sql_handle for a30
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

prompt SQL Profile information.
prompt -----------------------------------

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

prompt SQL Profile metadata.
prompt -----------------------------------

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

prompt SQL, profiles and baselines.
prompt -----------------------------------

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

prompt Executions, number of rows.
prompt -----------------------------------

prompt

select executions, parse_calls, loads, rows_processed, sorts
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt

prompt Response time, cpu time and wait time (in seconds).
prompt ---------------------------------------------------

prompt

select trunc(elapsed_time/1000000,1) elapsed_time, trunc(application_wait_time/1000000,1) applic_wait_time, trunc(cpu_time/1000000,1) cpu_time
, trunc(user_io_wait_time/1000000,1) user_io_wait_time, trunc(concurrency_wait_time/1000000,1) concurr_time
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt

prompt Memory and disk reads.
prompt -----------------------

prompt

select buffer_gets, disk_reads, (sharable_mem+persistent_mem+runtime_mem) sql_area_used
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt

prompt Who ran the query?
prompt ------------------------------

prompt

col username for a20
col parsing_schema_name for a20
col module for a40
col action for a20
col service for a20

select u.username, s.PARSING_SCHEMA_NAME, s.SERVICE, s.MODULE, s.ACTION
from v$sql s
,    dba_users u
where s.sql_id='&sql_id'
and s.child_number=&childnr
and u.user_id=s.PARSING_USER_ID;

prompt
prompt

prompt Bind aware, sharable?
prompt ------------------------------

prompt

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

SELECT substr(version, 1, instr(version, '.', 1,2)-1) version
FROM PRODUCT_COMPONENT_VERSION
where product like '%Database%';

prompt
prompt

prompt Bind mismatches (10.2)
prompt ------------------------------

prompt (If an ORA-00904 occurs, this wasn't a 10.2 database)

prompt '

set heading off
set linesize 80

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
                             WHERE  sql_id = '&sql_id');

prompt
prompt

prompt Bind mismatches (11.1)
prompt ------------------------------

prompt (If an ORA-00904 occurs, this wasn't a 11.1 database)

prompt '

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
                                       WHERE  sql_id = '&sql_id');

prompt
prompt

prompt Bind mismatches (11.2)
prompt ------------------------------

prompt (If an ORA-00904 occurs, this wasn't a 11.2 database)

prompt '

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
                                       WHERE  sql_id = '&sql_id');

set heading on
set linesize 255


prompt
prompt

prompt Content of bind variabeles (use as example)
prompt ----------------------------------------------------

prompt

col name for a10
col value_string for a30
col datatype_string for a20

select child_number, name, position, value_string, datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
order by position;

prompt

prompt Bind variables as SQL*Plus commands 
prompt ----------------------------------------------------

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

set heading on

prompt
prompt

prompt Values of bind variables of other childs
prompt ----------------------------------------------------

prompt

col name for a10
col value_string for a30
col datatype_string for a20

select child_number, name, position, value_string, datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number <> &childnr
order by child_number, position;


set long 50000

prompt
prompt

prompt Full text of the query (up to 50000 characters).
prompt ---------------------------------------------------

prompt

select sql_fulltext
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt

prompt Execution plan of the query.
prompt ----------------------------

prompt

SELECT plan_table_output
FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'TYPICAL'));

prompt
prompt

prompt All execution plans in sql plan baselines.
prompt ------------------------------------------

prompt

column v_sql_handle     new_value l_sql_handle       noprint

select distinct plan.SQL_HANDLE v_sql_handle
from dba_sql_plan_baselines plan
,    gv$sql sql
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=plan.SIGNATURE;

SELECT * FROM TABLE(dbms_xplan.display_sql_plan_baseline(sql_handle=>'&l_sql_handle'));


prompt
prompt

prompt Dropping associated SQL plan baselines.
prompt (Based on SQL_HANDLE gives an error, but works.
prompt  Not much success based on PLAN_NAME yet.)
prompt ------------------------------------------

prompt
prompt Based on SQL_HANDLE
prompt

select distinct 'select sys.dbms_spm.DROP_SQL_PLAN_BASELINE('''||sql_handle||''') from dual;'
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);

prompt
prompt Based on PLAN_NAME
prompt

select 'select sys.dbms_spm.DROP_SQL_PLAN_BASELINE(''plan_name=>'||plan_name||''') from dual;'
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);


prompt
prompt

prompt Generated statement to purge your SQL statement
prompt from the shared pool.
prompt ------------------------------------------

prompt

select 'exec sys.dbms_shared_pool.purge('''||address||', '||hash_value||''', ''c'')'
from v$sql
where sql_id = '&sql_id'
and child_number=&childnr;

prompt
prompt

pause Diagnostics Pack license available? (if no, press Ctrl-C)

prompt
prompt

prompt History of query response time.
prompt ------------------------------------------

alter session set NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI:SS.FF';

col BEGIN_INTERVAL_TIME for a40
select a.BEGIN_INTERVAL_TIME
,  a.INSTANCE_NUMBER
 , b.PLAN_HASH_VALUE
 , b.FORCE_MATCHING_SIGNATURE
 , b.executions_delta
 , round(b.ELAPSED_TIME_DELTA/decode(b.EXECUTIONS_DELTA,0,1,b.EXECUTIONS_DELTA)/1000000,2) tijd 
from   dba_hist_snapshot a, 
       dba_hist_sqlstat b 
where  a.snap_id=b.snap_id 
and    b.sql_id='&sql_id' 
order by a.BEGIN_INTERVAL_TIME
/


spool off

@your_sqlplus_env.sql
