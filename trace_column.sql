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
--      old   3: where &kolomnaam = '&trace_value'
--      new   3: where sid = '148'
--      
--      exec dbms_monitor.session_trace_enable(148, 7733, TRUE, TRUE);
--      
--      old   3: where &kolomnaam = '&trace_value'
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
--      old   3: where &kolomnaam = '&trace_value'
--      new   3: where username = 'OWS'
--      
--      exec dbms_monitor.session_trace_enable(148, 7733, TRUE, TRUE);
--      
--      old   3: where &kolomnaam = '&trace_value'
--      new   3: where username = 'OWS'
--      
--      exec dbms_monitor.session_trace_disable(148, 7733);
--
--
--      Version When        Who            What
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     04 apr 2012 M. Krijgsman   Initial
--      1.1     17 dec 2012 M. Krijgsman   trace identifier added.
------------------------------------------------------------------------------------------------------------------------------------------------------


accept kolomnaam    default '' -
  prompt 'Please give the column name in v$session: '

accept trace_value    default '' -
  prompt 'Please give the value you are looking for: '

accept traceid    default '' -
  prompt 'Please give a trace identifier to easier find your trace file: '


set heading off
set lines 132 pages 9999

spool trace_&kolomnaam._&trace_value._on.sql

prompt alter session set tracefile_identifier='&traceid';
prompt 
select 'exec dbms_monitor.session_trace_enable('||sid||', '||serial#||', TRUE, TRUE);'
from v$session
where &kolomnaam = '&trace_value';

spool off

spool trace_&kolomnaam._&trace_value._off.sql

select 'exec dbms_monitor.session_trace_disable('||sid||', '||serial#||');'
from v$session
where &kolomnaam = '&trace_value';

spool off


@trace_&kolomnaam._&trace_value._on.sql


set heading on
