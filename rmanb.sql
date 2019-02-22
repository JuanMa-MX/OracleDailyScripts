SET LINES 200
SET PAGES 1000
COL start_time  FOR A22
COL end_time    FOR A22
COL input_size  FOR A15
COL output_size FOR A15
COL status      FOR A25

SELECT
  TO_CHAR(start_time,'YYYY-MON-DD HH24:MI:SS') start_time
 ,TO_CHAR(end_time  ,'YYYY-MON-DD HH24:MI:SS') end_time
 ,LPAD(CASE WHEN input_bytes < 1024     THEN TO_CHAR(input_bytes                       ,'9G990D9')||'B'
       WHEN input_bytes < POWER(1024,2) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,1),1),'9G990D9')||'K'
       WHEN input_bytes < POWER(1024,3) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,2),1),'9G990D9')||'M'
       WHEN input_bytes < POWER(1024,4) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,3),1),'9G990D9')||'G'
       WHEN input_bytes < POWER(1024,5) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,4),1),'9G990D9')||'T'
  END
  ,15,' ') input_size
 ,LPAD(CASE WHEN output_bytes < 1024     THEN TO_CHAR(output_bytes                       ,'9G990D9')||'B'
       WHEN output_bytes < POWER(1024,2) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,1),1),'9G990D9')||'K'
       WHEN output_bytes < POWER(1024,3) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,2),1),'9G990D9')||'M'
       WHEN output_bytes < POWER(1024,4) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,3),1),'9G990D9')||'G'
       WHEN output_bytes < POWER(1024,5) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,4),1),'9G990D9')||'T'
  END
  ,15,' ') output_size
 ,input_type
 ,TO_CHAR(CAST(NUMTODSINTERVAL(elapsed_seconds, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) elapsed_time
 ,status
FROM v$rman_backup_job_details
WHERE start_time > TRUNC(SYSDATE)-60
AND input_type in ('DB FULL','DB INCR','ARCHIVELOG')
;

