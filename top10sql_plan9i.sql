------------------------------------------------------------------------------------------------------------------------------------------------------
--      Show the 10 SQL statements in the shared pool
--
--      Script      top10sql_plan9i.sql
--      Run as      DBA
--
--      Purpose     This script will show the top 10 SQLs in memory. If you choose one hash value from the
--                  list, it will show information about this SQL, like execution plan.
--
--      Input       hash_value, child_number
--
--      Author      M. Krijgsman
--
--      Remarks     You need a dynamic plan table (as seen below).
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     19 jun 2012 M. Krijgsman   Initieel
--      1.1     15 feb 2013 M. Krijgsman   English version.
------------------------------------------------------------------------------------------------------------------------------------------------------

/*

-- Required table in the SYS schema:

create or replace view dynamic_plan_table
as
select
	rawtohex(address) || '_' || child_number statement_id
,	sysdate timestamp
,	operation
,	options
,	object_node
,	object_owner
,	object_name
,	0 object_instance
,	optimizer
,	search_columns
,	id
,	parent_id
,	position
,	cost
,	cardinality
,	bytes
,	other_tag
,	partition_start
,	partition_stop
,	partition_id
,	other
,	distribution
,	cpu_cost
,	io_cost
,	temp_space
,	access_predicates
,	filter_predicates
from v$sql_plan;

*/


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


accept hash_value    default '' -
  prompt 'Geef de hash_value op: '


prompt
prompt

spool top10sql_plan_&l_dbname._&datetime..txt

prompt =============================================
prompt =                                           =
prompt =  This file was created with:              =
prompt =  top10sql_plan9i.sql                      =
prompt =  version 1.8 (2013)                       =
prompt =                                           =
prompt =  dbname: &l_dbname                            =
prompt =  SQL_ID: &hash_value                     =
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

prompt
prompt

prompt Top 10 queries op ANDERE nodes
prompt ------------------------------

select rank_elap_per_exec, elapsed_per_exec , inst_id, hash_value, plan_hash_value, elapsed_time, executions, cpu_time
from (
	select  inst_id,
		hash_value,
		plan_hash_value,
		trunc(elapsed_time/1000000,1) elapsed_time,
		executions,
		trunc(cpu_time/1000000,1) cpu_time, 
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

prompt Top 10 queries op DEZE node
prompt ---------------------------


select rank_elap_per_exec, elapsed_per_exec , inst_id, hash_value, plan_hash_value, elapsed_time, executions, cpu_time
from (
	select  inst_id,
		hash_value,
		plan_hash_value,
		trunc(elapsed_time/1000000,1) elapsed_time,
		executions,
		trunc(cpu_time/1000000,1) cpu_time, 
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

col last_active_time for a16
col last_load_time for a20

select hash_value, child_number, rawtohex(address)||'_'||child_number rawsqladres, inst_id, last_load_time, loaded_versions, open_versions, users_opening
from gv$sql
where hash_value='&hash_value'
and   inst_id= (select instance_number FROM v$instance);

prompt
prompt

prompt When the query has been runned from a different instance, run this script there.
prompt

prompt

accept childnr    default '' -
  prompt 'Welk child_number is aan de case gerelateerd?: '
  

prompt Executions, number of rows.
prompt -----------------------------------

prompt

select executions, parse_calls, loads, rows_processed, sorts
from v$sql
where hash_value='&hash_value'
and   child_number=&childnr;

prompt
prompt

prompt Memory and disk reads.
prompt -----------------------

prompt

select buffer_gets, disk_reads, (sharable_mem+persistent_mem+runtime_mem) sql_area_used
from v$sql
where hash_value='&hash_value'
and   child_number=&childnr;

prompt
prompt

prompt Who ran the query?
prompt ------------------------------

prompt

col module for a20
col action for a20
col service for a20
select u.username, s.MODULE, s.ACTION, s.REMOTE
from v$sql s
,    dba_users u
where s.hash_value='&hash_value'
and u.user_id=s.PARSING_USER_ID
and   child_number=&childnr;

prompt
prompt

set long 50000

prompt
prompt

prompt Full text of the query (up to 50000 characters).
prompt ---------------------------------------------------

prompt

select sql_text
from v$sql
where hash_value=&hash_value
and   child_number=&childnr;

prompt
prompt

prompt The next step might lead to hangs or internal errors in Oracle 9i.
pause  Continue or ctrl-C ? 


prompt Execution plan van de query.
prompt ----------------------------

prompt


col rawsqladres new_value v_rawsqladres noprint

select rawtohex(address)||'_'||child_number rawsqladres
from v$sql 
where hash_value=&hash_value
and   child_number=&childnr;

prompt


select * from table(DBMS_XPLAN.DISPLAY ('DYNAMIC_PLAN_TABLE', '&v_rawsqladres', 'TYPICAL'));


spool off

@your_sqlplus_env.sql
