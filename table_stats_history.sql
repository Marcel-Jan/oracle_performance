------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve table statistics history
--
--      Script      table_stats_history.sql
--      Run as      DBA
--
--      Purpose     Retrieves a history of table statistics, including rowcount, average row length and samplesize.
--
--      Input       owner, table_name
--
--      Author      M. Krijgsman
--
--      Remarks     Example of output:
--
--      OWNER     OBJECT_NAME OBJECT_TYPE       OBJ# SAVTIME                             FLAGS      ROWCNT     BLKCNT     AVGRLN     SAMPLESIZE ANALYZETIME          CACHEDBLK   CACHEHIT LOGICALREAD
--      --------- ----------- ----------- ---------- ----------------------------------- ---------- ---------- ---------- ---------- ---------- ------------------- ---------- ---------- -----------
--      APP_OWNER PROBLEM     TABLE           109478 15-SEP-12 02.25.54.008891 AM +02:00    10      279280     205630       2429      27928     14-09-2012:02:22:17
--      APP_OWNER PROBLEM     TABLE           109478 16-SEP-12 02.20.56.839385 AM +02:00    10      280790     205630       2430      28079     15-09-2012:02:24:48
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.0     18 jan 2012 M. Krijgsman   First version
------------------------------------------------------------------------------------------------------------------------------------------------------

col OWNER for a12
col OBJECT_NAME for a30
col OBJECT_TYPE for a14
col SUBOBJECT_NAME for a30

SELECT ob.owner, ob.object_name, ob.subobject_name, ob.object_type,obj#, savtime, flags, rowcnt, blkcnt, avgrln ,samplesize, analyzetime, cachedblk, cachehit, logicalread
FROM sys.WRI$_OPTSTAT_TAB_HISTORY, dba_objects ob
WHERE owner=upper('&OWNER')
and object_name=upper('&TABLE')
and object_type in ('TABLE')
and object_id=obj#
order by savtime asc;
