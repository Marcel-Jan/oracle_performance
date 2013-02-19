------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve column statistics history
--
--      Script      column_stats_history.sql
--      Run as      DBA
--
--      Purpose     Retrieves a history of column statistics, including null count, density, blevels, clustering factor and samplesize.
--
--      Input       owner, table_name, column_name
--
--      Author      M. Krijgsman
--
--      Remarks     Example of output:
--
--      OWNER      OBJECT_NAME COLUMN_NAME SAVTIME                             NULL_CNT DISTCNT DENSITY    LOWVAL               HIVAL                    AVGCLN SAMPLE_DISTCNT SAMPLE_SIZE TIMESTAMP#
--      ---------- ----------- ----------- ----------------------------------- -------- ------- ---------- -------------------- ------------------------ ------ -------------- ----------- --------------------
--      OWNER_SMR  CM3RM1      NUMBER      17-FEB-13 01.31.25.688464 AM +01:00        0   48150 .000020768 43303030333030303239 433130363632                 11           4949        4949 16-02-2013:01:28:50
--      OWNER_SMR  CM3RM1      NUMBER      18-FEB-13 01.43.42.970048 AM +01:00        0   50370 .000019853 43303030333030303035 5344303030313434353437       11           5037        5037 17-02-2013:01:31:18
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     19 feb 2013 M. Krijgsman   First version
------------------------------------------------------------------------------------------------------------------------------------------------------

col OWNER for a12
col OBJECT_NAME for a30
col OBJECT_TYPE for a14
col COLUMN_NAME for a30

SELECT ob.owner, ob.object_name,  col.COLUMN_NAME, ob.object_type,obj#, his.savtime
, his.NULL_CNT, his.MINIMUM , his.MAXIMUM, his.DISTCNT, his.DENSITY, his.LOWVAL, his.HIVAL, his.AVGCLN, his.SAMPLE_DISTCNT, his.sample_size,  his.TIMESTAMP#
FROM sys.WRI$_OPTSTAT_HISTHEAD_HISTORY his
, dba_objects ob
, dba_tab_columns col
WHERE ob.owner=upper('&OWNER')
and ob.object_name=upper('&TABLE')
and ob.object_type in ('TABLE')
and col.column_name=('&COLUMN_NAME')
and ob.object_id=his.obj#
and col.COLUMN_ID=his.INTCOL#
and ob.object_name=col.TABLE_NAME
and ob.owner=col.owner
order by savtime asc;
