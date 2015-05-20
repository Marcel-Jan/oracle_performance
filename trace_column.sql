------------------------------------------------------------------------------------------------------------------------------------------------------
--      Trace a session based on a column in v$session
--
--      Script      trace_kolom.sql
--      Run as      DBA
--
--      Purpose     Quickly start a trace on one or more sessions.
--
--      Input       v$session column name, value of data in the column you are looking in, a trace file identifier.
--
--      Author      M. Krijgsman
--
--      Example:  
--      Suppose you want to trace session 148.
--
--      SQL> @trace_column
--      Please give the column name in v$session: sid
--
--      Please give the value you are looking for: 148
--      old   3: where &v_columnname = '&trace_value'
--      new   3: where sid = '148'
--      
--      exec dbms_monitor.session_trace_enable(148, 7733, TRUE, TRUE);
--      
--      old   3: where &v_columnname = '&trace_value'
--      new   3: where sid = '148'
--      
--      exec dbms_monitor.session_trace_disable(148, 7733);
--
--      
--      Suppose you want to trace sessions with the condition username='OWS' .
--
--      SQL> @trace_kolom
--      
--      Please give the column name in v$session: username
--      Please give the value you are looking for: OWS
--      old   3: where &v_columnname = '&trace_value'
--      new   3: where username = 'OWS'
--      
--      exec dbms_monitor.session_trace_enable(148, 7733, TRUE, TRUE);
--      
--      old   3: where &v_columnname = '&trace_value'
--      new   3: where username = 'OWS'
--      
--      exec dbms_monitor.session_trace_disable(148, 7733);
--
--
--      Version When        Who            What
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     04 apr 2012 M. Krijgsman   Initial
--      1.1     17 dec 2012 M. Krijgsman   trace identifier added.
--      1.2     May 18 2015 M. Krijgsman   Generated .sql files are spooled to /tmp. trace_identifier now really works :)
--      1.3     May 19 2015 M. Krijgsman   After chosing the column name, you see what values are in that column.
------------------------------------------------------------------------------------------------------------------------------------------------------

set linesize 3000
set verify off



accept v_columnname    default '' -
  prompt 'Please give the column name in v$session: '

col &v_columnname for a50

select &v_columnname, count(*)
from v$session
group by &v_columnname
order by &v_columnname;


accept trace_value    default '' -
  prompt 'Please give the value you are looking for: '

accept traceid    default '' -
  prompt 'Please give a trace identifier to easier find your trace file: '


set heading off
set lines 132 pages 9999

spool /tmp/trace_&v_columnname._&trace_value._on.sql

prompt alter session set tracefile_identifier='&traceid';;
prompt 
select 'exec dbms_monitor.session_trace_enable('||sid||', '||serial#||', TRUE, TRUE);'
from v$session
where &v_columnname = '&trace_value';

spool off

spool /tmp/trace_&v_columnname._&trace_value._off.sql

select 'exec dbms_monitor.session_trace_disable('||sid||', '||serial#||');'
from v$session
where &v_columnname = '&trace_value';

spool off


@/tmp/trace_&v_columnname._&trace_value._on.sql


set heading on
