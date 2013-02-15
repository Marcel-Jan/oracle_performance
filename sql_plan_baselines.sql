------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve a lot of information about sql plan baselines
--
--      Script      sql_plan_baselines.sql
--      Run as      DBA
--
--      Purpose     This script will retrieve a lot of info about sql plan baselines
--
--      Input       Beginning execution_name, ending execution_name
--
--      Author      M. Krijgsman
--
--      Remarks     None.
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     08 dec 2012 M. Krijgsman   Initial version
--                                         Used queries from amongst others http://blog.yannickjaquier.com/oracle/automatic-sql-tuning-task-overview.html
--      1.1     14 dec 2012 M. Krijgsman   Added query to find rationale behind plan.
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

prompt =============================================
prompt =                                           =
prompt =          sql_plan_baselines.sql           =
prompt =  This script will retrieve information    =
prompt =         about sql plan baselines          =
prompt =                                           =
prompt =          (Version 11g or higher)          =
prompt =                                           =
prompt =============================================
prompt

spool baselines_&l_dbname._&datetime..txt

prompt =============================================
prompt =                                           =
prompt =     Output of sql_plan_baselines.sql      =
prompt =                                           =
prompt =============================================


prompt This instance.
prompt -----------------------------------

col instance_name for a16
col status for a16

select instance_name, instance_number, status 
from v$instance;


prompt
prompt

prompt Parameters for sql plan baselines.
prompt -----------------------------------

col name for a40
col value for a15

select inst_id, name, value
from gv$parameter where name like '%baseline%'
order by inst_id, name;

prompt
prompt

prompt Advisor execution types
prompt -----------------------------------

col advisor_name for a30
col execution_type FOR a20
col execution_description FOR a50
SELECT * 
FROM dba_advisor_execution_types;

prompt
prompt

prompt Advisor tasks
prompt -----------------------------------

col task_name for a30
col description FOR a50
col execution_type FOR a20

SELECT task_name,description,execution_type 
FROM dba_advisor_tasks 
WHERE advisor_name='SQL Tuning Advisor';


prompt
prompt

prompt Autotask clients.
prompt -----------------------------------

col client_name for a40
col status for a20

SELECT client_name, status, max_duration_last_30_days
FROM DBA_AUTOTASK_CLIENT;


prompt
prompt

prompt SQL Tuning Advisor parameters
prompt --------------------------------------------------

col PARAMETER_NAME for a40
col DESCRIPTION FOR a100
col parameter_value FOR a15
SELECT parameter_name,parameter_value,is_default,description
FROM DBA_ADVISOR_PARAMETERS
WHERE task_name='SYS_AUTO_SQL_TUNING_TASK'
ORDER BY parameter_name;


prompt
prompt

prompt Runs of sql tuning advisor autotask in last 7 days
prompt --------------------------------------------------

col job_start_time for a45
col job_duration for a40
col job_status for a16

SELECT job_start_time, job_status, job_duration
FROM DBA_AUTOTASK_JOB_HISTORY
WHERE client_name='sql tuning advisor'
AND job_start_time >= SYSDATE -7
ORDER BY job_start_time DESC;

prompt
prompt

prompt sql tuning advisor autotask status and errors
prompt --------------------------------------------------

prompt In case of an ORA-13639 message the task took longer than
prompt the TIME_LIMIT (autotask) parameter. See [ID 1363111.1]
prompt 

col execution_name for a15
col execution_start for a25
col status for a16
col error_message FOR a70

SET lines 200 pages 1000
SELECT execution_name,
       TO_CHAR(execution_start,'dd-mon-yyyy hh24:mi:ss') execution_start,
       status,
       error_message
FROM dba_advisor_executions
WHERE task_name='SYS_AUTO_SQL_TUNING_TASK'
ORDER BY execution_id ASC;

prompt

accept v_exec    default '' -
  prompt 'Please provide an EXECUTION_NAME: '

prompt


SET lines 200 pages 1000
SET LONG 999999999
col report for a200
SELECT DBMS_AUTO_SQLTUNE.REPORT_AUTO_TUNING_TASK('&v_exec','&v_exec','TEXT','ALL','SUMMARY') report FROM dual;

prompt

accept v_object_id    default '' -
  prompt 'Please provide an object_id: '


prompt
prompt

prompt Rationale behind execution plans
prompt --------------------------------

select rec_id, to_char(attr5) 
from dba_advisor_rationale 
where execution_name = '&v_exec' 
and object_id = &v_object_id and rec_id > 0 
order by rec_id; 

prompt
prompt

prompt Number of sql plan baselines
prompt ----------------------------

select a.baselines, b.enabled, c.ACCEPTED, d.NOT_ACCEPTED, e.fixed, f.EXECUTED
from 
	(select count(*) BASELINES
   from DBA_SQL_PLAN_BASELINES) a
, (select count(*) ENABLED
   from DBA_SQL_PLAN_BASELINES
   WHERE enabled='YES') b
, (select count(*) ACCEPTED
   from DBA_SQL_PLAN_BASELINES
   WHERE accepted='YES') c
, (select count(*) NOT_ACCEPTED
   from DBA_SQL_PLAN_BASELINES
   WHERE accepted='NO') d
, (select count(*) FIXED
   from DBA_SQL_PLAN_BASELINES
   WHERE fixed='YES') e
, (select count(*) EXECUTED
   from DBA_SQL_PLAN_BASELINES
   where executions>0) f
/

prompt
prompt

prompt The age of sql plan baselines
prompt -----------------------------

select a.last_modified, a.accepted, b.not_accepted
from 
   (SELECT trunc(last_modified, 'MM') last_modified,  count(*) accepted
    FROM dba_sql_plan_baselines
    WHERE accepted='YES'
    GROUP BY trunc(last_modified, 'MM'), accepted
    ORDER BY trunc(last_modified, 'MM') , accepted) a
, (SELECT trunc(last_modified, 'MM') last_modified,  count(*) not_accepted
    FROM dba_sql_plan_baselines
    WHERE accepted='NO'
    GROUP BY trunc(last_modified, 'MM'), accepted
    ORDER BY trunc(last_modified, 'MM'), accepted) b
WHERE a.last_modified=b.last_modified
/


prompt
prompt

prompt The age of executed sql plan baselines
prompt --------------------------------------

SELECT trunc(last_modified, 'MM') last_modified,  count(*) executed
    FROM dba_sql_plan_baselines
    WHERE executions>0
    GROUP BY trunc(last_modified, 'MM')
    ORDER BY trunc(last_modified, 'MM')
/


prompt
prompt

prompt Number of sql plan baselines and modules
prompt ----------------------------------------

col module for a50
col last_modified for a22

SELECT TRUNC(last_modified) last_modified, module, accepted,  count(*) 
FROM dba_sql_plan_baselines
WHERE module NOT IN ('DBMS_SCHEDULER',  'OEM',  'OMS',
'Oracle Enterprise Manager.Metric Engine', 'emagent_SQL_oracle_database',
'emagent_SQL_rac_database', 'emagent_AQMetrics')
GROUP BY TRUNC(last_modified), module, accepted
ORDER BY TRUNC(last_modified), module, accepted;

prompt
prompt

prompt Not accepted sql plan baselines with lower cost
prompt -----------------------------------------------

col plan_name for a50
select a.plan_name, a.enabled, a.accepted, a.fixed
, a.optimizer_cost cost_a, b.optimizer_cost cost_b
from dba_sql_plan_baselines a
,    dba_sql_plan_baselines b
where a.SIGNATURE = b.SIGNATURE
and a.optimizer_cost>100
and a.enabled='YES'
and a.accepted='YES'
and b.enabled='YES'
and b.accepted='NO'
and a.optimizer_cost>b.optimizer_cost
order by a.optimizer_cost
/

prompt
prompt

prompt Oldest sql plan baselines per module
prompt ------------------------------------

col module for a50
col min_last_modified for a30
SELECT module, min(last_modified) min_last_modified , accepted
FROM dba_sql_plan_baselines
WHERE module NOT IN ('DBMS_SCHEDULER',  'OEM',  'OMS',
'Oracle Enterprise Manager.Metric Engine', 'emagent_SQL_oracle_database',
'emagent_SQL_rac_database', 'emagent_AQMetrics')
GROUP BY module, accepted
ORDER BY module, min(last_modified) , accepted;


spool off

@your_sqlplus_env.sql
