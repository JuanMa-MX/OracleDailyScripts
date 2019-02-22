--        Nombre: sqls.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra las sentencias SQL en ejecucion e indica el
--                numero de sesiones que la estan ejecutando
--           Uso: @sqls ENTER
--Requerimientos: Acceso a [g]v$session, v$sqlarea
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

CLEAR BREAKS
CLEAR COLUMNS

SET LINES 200
SET PAGES 10000
COL event_blocker_blocked FOR A35
COL username_sid_serial   FOR A30
COL machine        FOR A25 TRUNC
COL program        FOR A15 TRUNC
COL sqlid_child    FOR A16
COL cnt            FOR 999
COL max_time       FOR A12

WITH curr_session AS (SELECT * FROM v$session)
SELECT
       TO_CHAR (CAST (NUMTODSINTERVAL (bl.max_time, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) max_time
      ,bl.max_blocked cnt
      ,se.sql_id||' '||CASE WHEN se.sql_id IS NULL THEN NULL ELSE se.sql_child_number END sqlid_child
      ,RPAD(NVL(se.username,'-|BGPROCESS|-'),(29-LENGTH(se.sid||','||se.serial#)),' ')||se.sid||','||se.serial#||CHR(10)||
       RPAD(se.status                ,(29-12),' ')||TO_CHAR (CAST (NUMTODSINTERVAL (se.last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) username_sid_serial
      ,'+'||se.event||CHR(10)||' -'||bl.event event_blocker_blocked
      ,se.program
      ,se.machine
FROM curr_session se
    ,(SELECT c.blocking_session sid, c.event, COUNT(*) max_blocked, max(seconds_in_wait) max_time
      FROM curr_session c group by c.blocking_session, c.event) bl
WHERE se.sid  = bl.sid
ORDER BY max_time, max_blocked
;

