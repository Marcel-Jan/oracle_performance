------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve statistics data based on the execution plan, retrieved by sql_id
--
--      Script      stats_sql_id_html.sql
--      Run as      DBA
--
--      Purpose     This script will retrieve a lot of statistics data sql_id and create a HTML report
--
--      Input       sql_id, child_number
--
--      Author      M. Krijgsman
--
--      Remarks     !! A Diagnostics Pack license is required for this script !!
--
--                  !! WARNING: Some of the queries in this script are resource intensive !!
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     Oct 29 2013 M. Krijgsman   First version, based on sql_sql_id_html.sql
--      1.1     Nov 19 2013 M. Krijgsman   Tiny little bugfix (removing annoying spaces in sql_fulltext)
------------------------------------------------------------------------------------------------------------------------------------------------------

column v_datetime    new_value datetime       noprint
select to_char(sysdate, 'YYYYMMDDHH24MISS') v_datetime from dual;

store set /tmp/your_sqlplus_env_&datetime..sql REPLACE

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

select lower(name) vl_dbname from v$database;


prompt =============================================
prompt =                                           =
prompt =            stats_sql_id_html.sql          =
prompt =  This script will retrieve data on stats  =
prompt =    on objects in execution plans found    =
prompt =                 by sql_id                 =
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




spool stats_&l_dbname._&sql_id._&datetime..html

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

prompt  <TITLE>Stats report for &sql_id on &l_dbname</TITLE>
prompt  <STYLE TYPE="text/css">
prompt    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    tr,td             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    table             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    th                {font:bold 9pt  Arial,Helvetica,sans-serif; color:#314299; background:#befdfd;}
prompt    h1                {font:bold 12pt Arial,Helvetica,sans-serif; color:#003399; background-color:White;}
prompt    h2                {font:bold 10pt Arial,Helvetica,sans-serif; color:#FF9933; background-color:White;}
prompt    h4                {font:bold 9pt Arial,Helvetica,sans-serif; color:Grey; background-color:White;}
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

prompt <body text="#000000" bgcolor="#FFFFFF" link="#0000FF"
prompt    vlink="#000080" alink="#FF0000">

set markup html on spool on preformat off entmap on

--body   'BGCOLOR="#C5CDC5"' table 'WIDTH="90%" BORDER="1"' 


set    markup html on entmap off
set    head off

set markup HTML ON ENTMAP OFF
prompt <h1>Stats report, based on sql_id.</h1>
prompt <p>This file was created with:
prompt stats_sql_id_html.sql
prompt version 1.1 (2013)
prompt 
prompt dbname: &l_dbname
prompt SQL_ID: &sql_id
prompt date:   &datetime
prompt </p>

set markup HTML OFF ENTMAP OFF

prompt <center>
prompt 	<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#314299"><b>Report Index</b></font>
prompt 	<hr align="center" width="250">
prompt <table width="90%" border="1">  
prompt 	<tr><th colspan="4">Query and execution plan</th></tr>  
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#sqltext">Full text of the query</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#execplan">Execution plan</a></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 	</tr>  
prompt  <tr><th colspan="4">Tables</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tables">Accessed tables</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tabstatshsh">Table stats history (dates)</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tabstatshdet">Table stats history (detailed)</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tabpartitions">Table partitions</a></td>  
prompt 	</tr>  
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tabstale">Tables and partitions with stale stats</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tabmodif">Modifications on tables and partitions</a></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 	</tr>
prompt  <tr><th colspan="4">Indexes</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indexes">Accessed indexes</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indstatshis">Index stats history</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indpartitions">Index partitions</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indstale">Indexes and partitions with stale stats</a></td>  
prompt 	</tr>
prompt  <tr><th colspan="4">Columns</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#columns">Column statistics</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indcolstats">Indexed columns statistics</a></td> 
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#colstatshist">Column stats history</a></td>
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 	</tr>
prompt </table>
prompt </center>  
prompt 


set heading on

set markup HTML ON ENTMAP OFF
prompt
prompt
prompt
prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Selected sql_id and child_number.</h2>
set markup HTML ON ENTMAP ON

select instance_name, '&sql_id' sql_id, '&childnr' childnr
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


-----------------------
-- Query's full text --
-----------------------

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="sqltext"></A><h2>Full text of the query (up to 50000 characters).</h2>
set markup HTML ON ENTMAP ON

set long 50000
col sql_fulltext for a4000

select sql_fulltext
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;


-----------------------
-- Execution plan    --
-----------------------

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="execplan"></A><h2>Execution plan of the query.</h2>

set markup HTML OFF ENTMAP OFF

prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT plan_table_output
FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'ALL'));
prompt </pre>

prompt
prompt
prompt
prompt
prompt
prompt


-----------------------
-- Tables            --
-----------------------


set markup HTML ON ENTMAP OFF
prompt <h1>Tables.</h1>
prompt
prompt
prompt <A NAME="tables"></A><h2>Tables accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

set heading on

SELECT owner, table_name, last_analyzed, sample_size, num_rows, avg_row_len, blocks, partitioned, global_stats
FROM dba_tables
WHERE table_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
ORDER BY owner, table_name
/


---------------------------------
-- Table stats history (short) --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tabstatshsh"></A><h2>Statistics history of tables in the execution plan (short).</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name, sth.PARTITION_NAME, sth.SUBPARTITION_NAME, sth.STATS_UPDATE_TIME
FROM dba_objects ob
,    DBA_TAB_STATS_HISTORY sth
WHERE ob.object_type in ('TABLE')
AND   ob.object_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
and ob.object_name=sth.table_name
and ob.owner=sth.owner
order by ob.owner, ob.object_name, sth.partition_name, sth.subpartition_name, sth.STATS_UPDATE_TIME asc
;




---------------------------------
-- Table stats history (long)  --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tabstatshdet"></A><h2>Statistics history for tables accessed in the execution plan (detailed).</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name, ob.subobject_name, ob.object_type, to_char(savtime, 'DD-MON-YY HH24:MI:SS') savtime, rowcnt, blkcnt, avgrln ,samplesize, analyzetime
FROM sys.WRI$_OPTSTAT_TAB_HISTORY, dba_objects ob
WHERE object_type in ('TABLE')
AND   object_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
and object_id=obj#
order by ob.owner, ob.object_name, analyzetime asc
;


---------------------------------
-- Table partitions            --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tabpartitions"></A><h2>Partitions of tables accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT table_owner, table_name, partition_name, subpartition_count, last_analyzed, sample_size, num_rows, avg_row_len
FROM dba_tab_partitions
WHERE table_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
ORDER BY table_owner, table_name, partition_name
/


---------------------------------
-- Table: stale stats          --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tabstale"></A><h2>Tables in the execution plan with stale statistics.</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name, ts.PARTITION_NAME, ts.partition_position par_pos, ts. SUBPARTITION_NAME, ts.SUBPARTITION_POSITION subpar_pos, ts.last_analyzed
, ts.stale_stats, ts.global_stats, ts.user_stats, ts.STATTYPE_LOCKED
FROM dba_objects ob
,    dba_tab_statistics ts
WHERE ob.object_type in ('TABLE')
AND   ob.object_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
and ob.object_name=ts.table_name
and ob.owner=ts.owner
and ts.STALE_STATS='YES'
order by ob.owner, ob.object_name, ts.PARTITION_NAME, ts. SUBPARTITION_NAME, ts.last_analyzed asc
;

---------------------------------
-- Table: modifications        --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tabmodif"></A><h2>Modifications on tables in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name, mod.PARTITION_NAME, mod.SUBPARTITION_NAME, mod.inserts, mod.updates, mod.deletes, mod.timestamp, mod.truncated, mod.drop_segments
FROM dba_objects ob
,    dba_tab_modifications mod
WHERE ob.object_type in ('TABLE')
AND   ob.object_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
and ob.object_name=mod.table_name
and ob.owner=mod.table_owner
order by ob.owner, ob.object_name, mod.partition_name, mod.subpartition_name, mod.timestamp asc
;




---------------------------------
-- Indexes                     --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <h1>Indexes statistics.</h1>
prompt
prompt
prompt <A NAME="indexes"></A><h2>Indexes accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT owner, index_name, table_name, last_analyzed, sample_size, num_rows, partitioned, global_stats
FROM dba_indexes
WHERE index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
ORDER BY owner, table_name, index_name
/



---------------------------------
-- Index stats history         --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="indstatshis"></A><h2>Statistics history for indexes accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name, ob.subobject_name, ob.object_type,to_char(savtime, 'DD-MON-YY HH24:MI:SS') savtime
     , rowcnt, BLEVEL , LEAFCNT, DISTKEY, CLUFAC, samplesize, analyzetime
FROM sys.WRI$_OPTSTAT_IND_HISTORY, dba_objects ob
WHERE object_type in ('INDEX')
AND object_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
and object_id=obj#
order by ob.owner, ob.object_name, analyzetime asc
;


---------------------------------
-- Index: partitions --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="indpartitions"></A><h2>Partitions of indexes accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT index_owner, index_name, partition_name, subpartition_count, last_analyzed, sample_size, num_rows
FROM dba_ind_partitions
WHERE index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
ORDER BY index_owner, index_name, partition_name
/



---------------------------------
-- Index: stale stats          --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="indstale"></A><h2>Indexes and partitions with stale stats.</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name, ids.PARTITION_NAME, ids.partition_position par_pos, ids. SUBPARTITION_NAME, ids.SUBPARTITION_POSITION subpar_pos, ids.last_analyzed
, ids.stale_stats, ids.global_stats, ids.user_stats, ids.STATTYPE_LOCKED
FROM dba_objects ob
,    dba_ind_statistics ids
WHERE ob.object_type in ('INDEX')
AND   ob.object_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
and ob.object_name=ids.index_name
and ob.owner=ids.owner
and ids.STALE_STATS='YES'
order by ob.owner, ob.object_name, ids.PARTITION_NAME, ids.SUBPARTITION_NAME, ids.LAST_ANALYZED asc
;






---------------------------------
-- Columns                     --
---------------------------------

set markup HTML ON ENTMAP OFF
prompt <h1>Columns.</h1>
prompt
prompt
prompt <A NAME="columns"></A><h2>Columns of tables accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

set heading on

SELECT owner, table_name, column_name, data_type, last_analyzed, sample_size, NUM_NULLS, NUM_DISTINCT, NUM_BUCKETS, AVG_COL_LEN, HISTOGRAM, GLOBAL_STATS
FROM dba_tab_columns
WHERE table_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
ORDER BY owner, table_name, column_id
/



prompt
prompt
prompt

---------------------------------
-- Indexed column stats        --
---------------------------------

set markup HTML ON ENTMAP OFF
prompt <A NAME="indcolstats"></A><h2>Statistics indexed columns for indexes used in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT ic.index_owner, ic.index_name, ic.table_name, ic.column_name, ic.column_position col_pos, tc.last_analyzed, tc. sample_size, tc.num_distinct, tc.num_nulls, tc.density, tc.histogram, tc.num_buckets
FROM dba_ind_columns ic
,    dba_tab_columns tc
WHERE ic.index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
AND ic.table_owner=tc.owner
AND ic.table_name=tc.table_name
AND ic.column_name=tc.column_name
ORDER BY ic.table_owner, ic.table_name, ic.index_name, ic.column_position
/


---------------------------------
-- Columns stats history       --
---------------------------------

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="colstatshist"></A><h2>Statistics history for indexed columns for indexes used in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT ob.owner, ob.object_name,  col.COLUMN_NAME, to_char(his.savtime, 'DD-MON-YY HH24:MI:SS') savtime
, his.NULL_CNT, his.DISTCNT, his.DENSITY, his.SAMPLE_DISTCNT, his.sample_size,  his.TIMESTAMP#
FROM sys.WRI$_OPTSTAT_HISTHEAD_HISTORY his
, dba_objects ob
, dba_tab_columns col
, dba_ind_columns ic
WHERE ic.index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
AND ic.table_owner=col.owner
AND ic.table_name=col.table_name
AND ic.column_name=col.column_name
and ob.object_type in ('TABLE')
and ob.object_id=his.obj#
and col.COLUMN_ID=his.INTCOL#
and ob.object_name=col.TABLE_NAME
and ob.owner=col.owner
order by col.owner, col.table_name, ic.column_position, col.column_name, his.TIMESTAMP# asc
;




spool off

@/tmp/your_sqlplus_env_&datetime..sql
