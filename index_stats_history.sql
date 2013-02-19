------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve index statistics history
--
--      Script      index_stats_history.sql
--      Run as      DBA
--
--      Purpose     Retrieves a history of index statistics, including rowcount, leafcount, clustering factor and samplesize.
--
--      Input       owner, index_name
--
--      Author      M. Krijgsman
--
--      Remarks     Example of output:
--
--      OWNER        OBJECT_NAME  OBJECT_TYPE       OBJ# SAVTIME                                  FLAGS ROWCNT     BLEVEL     LEAFCNT    DISTKEY    LBLKKEY    DBLKKEY        CLUFAC SAMPLESIZE ANALYZETIME
--      ------------ ------------ ----------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -------------------
--      APP_OWNER    PROBLEMI4    INDEX           110698 17-FEB-13 01.32.01.338205 AM +01:00    10       49558          2        539        334          1        131      43791      49558 16-02-2013:01:29:26
--      APP_OWNER    PROBLEMI4    INDEX           110698 18-FEB-13 01.44.18.390596 AM +01:00    10       49564          2        540        334          1        131      43797      49564 17-02-2013:01:32:01
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     19 feb 2013 M. Krijgsman   First version
------------------------------------------------------------------------------------------------------------------------------------------------------

col OWNER for a12
col OBJECT_NAME for a30
col OBJECT_TYPE for a14
col SUBOBJECT_NAME for a30

SELECT ob.owner, ob.object_name, ob.subobject_name, ob.object_type,obj#, savtime, flags, rowcnt, BLEVEL , LEAFCNT, DISTKEY, LBLKKEY, DBLKKEY, CLUFAC,samplesize, analyzetime
FROM sys.WRI$_OPTSTAT_IND_HISTORY, dba_objects ob
WHERE owner=upper('&OWNER')
and object_name=upper('&INDEX')
and object_type in ('INDEX')
and object_id=obj#
order by savtime asc;
