--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
CLEAR BREAKS
CLEAR COLUMNS

accept sid_ number default 0 -
prompt 'Session Id? []: '

PROMPT
PROMPT
PROMPT ========== [ Eventos de Espera de la Sesion ] ==========
PROMPT

COL wait_class FOR A20 TRUNC
COL event FOR A40 TRUNC
COL waited FOR A12

SELECT s.wait_class
      ,s.event
      ,TO_CHAR(CAST(numtodsinterval(s.time_waited/100, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waited
FROM gv$session_event s
WHERE s.inst_id = SYS_CONTEXT ('USERENV', 'INSTANCE')
  AND s.wait_class not in ('Idle')
  AND s.sid = &&sid_
ORDER BY waited DESC
;

PROMPT ========== [ Ultimos 10 / Seq#=1 Mas reciente ] ==========
PROMPT

COL seq# FOR 999
COL p1_p2_p3 FOR A60 TRUNC

SELECT s.seq#
      ,CASE s.seq# WHEN 1 THEN DECODE (s.wait_time, 0, 'WAITING', 'WAITED') ELSE 'WAITED' END status
      ,TO_CHAR(CAST(numtodsinterval(s.wait_time/100, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waited
      ,e.wait_class
      ,s.event
      ,s.p1text||'='||s.p1||' '||s.p2text||'='||s.p2||' '||s.p3text||'='||s.p3 p1_p2_p3
FROM gv$session_wait_history s INNER JOIN gv$event_name e
   ON e.inst_id = s.inst_id AND e.event# = s.event#
WHERE s.inst_id = SYS_CONTEXT ('USERENV', 'INSTANCE')
  AND s.sid = &&sid_
ORDER BY seq#
;

