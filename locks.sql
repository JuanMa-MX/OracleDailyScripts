--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
CLEAR BREAKS
CLEAR COLUMNS

SET LINES 200
SET PAGES 10000
COL event          FOR A40 TRUNC
COL waiting_active FOR A25
COL identifier     FOR A17
COL username       FOR A15
COL osuser         FOR A10
COL machine        FOR A25
COL program        FOR A15 TRUNC
COL sqlid_child    FOR A20
COL max_blocked_time FOR A16

WITH curr_session AS (SELECT * FROM v$session)
SELECT
       TO_CHAR (CAST (NUMTODSINTERVAL (bl.max_blocked_time, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) max_blocked_time
      ,bl.waiters_cnt
      ,se.sid||','||se.serial# identifier
      ,NVL(se.username,'-'||pr.pname||'-') username
      ,se.sql_id||' '||CASE WHEN se.sql_id IS NULL THEN NULL ELSE se.sql_child_number END sqlid_child
      ,se.program
      ,se.machine
FROM curr_session se, v$process pr
    ,(SELECT c.blocking_session sid, COUNT(*) waiters_cnt, max(seconds_in_wait) max_blocked_time
      FROM curr_session c group by c.blocking_session) bl
WHERE pr.addr = se.paddr
  AND se.sid  = bl.sid
ORDER BY max_blocked_time, waiters_cnt
;
