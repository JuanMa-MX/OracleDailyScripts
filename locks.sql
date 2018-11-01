--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

CLEAR BREAKS
CLEAR COLUMNS

SET LINES 200
SET PAGES 10000
COL event_blocker  FOR A30 TRUNC
COL event_blocked  FOR A30 TRUNC
COL identifier     FOR A15
COL username       FOR A15
COL machine        FOR A25 TRUNC
COL program        FOR A15 TRUNC
COL sqlid_child    FOR A16
COL cnt            FOR 999
COL max_time       FOR A12

WITH curr_session AS (SELECT * FROM v$session)
SELECT
       TO_CHAR (CAST (NUMTODSINTERVAL (bl.max_time, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) max_time
      ,bl.max_blocked cnt
      ,se.sid||','||se.serial# identifier
      ,NVL(se.username,'-'||pr.pname||'-') username
      ,se.event event_blocker
      ,bl.event event_blocked
      ,se.sql_id||' '||CASE WHEN se.sql_id IS NULL THEN NULL ELSE se.sql_child_number END sqlid_child
      ,se.program
      ,se.machine
FROM curr_session se, v$process pr
    ,(SELECT c.blocking_session sid, c.event, COUNT(*) max_blocked, max(seconds_in_wait) max_time
      FROM curr_session c group by c.blocking_session, c.event) bl
WHERE pr.addr = se.paddr
  AND se.sid  = bl.sid
ORDER BY max_time, max_blocked
;

