--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Operaciones Largas ] ====================
PROMPT

SET LINES 200
SET PAGES 1000

CLEAR COLUMNS
CLEAR BREAKS


set lines 180
col sid format 9999
col start_time format a5 heading "Start|time"
col elapsed format 9999 heading "ELAPSED|past"
col remaining format 9999 heading "left"
col message format a81

select inst_id, to_char(start_time,'hh24:mi') start_time,
sid,
  to_char(cast(numtodsinterval(elapsed_seconds,'SECOND') as interval day(2) to second(0))) elapsed,
  to_char(cast(numtodsinterval(time_remaining,'SECOND') as interval day(2) to second(0))) remaining,
   message
from gv$session_longops where time_remaining > 0
order by 1,2
;
