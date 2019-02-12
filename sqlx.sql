--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 150
SET PAGES 1000
COLUMN cost_order NOPRINT
COLUMN optimizer FORMAT A15
COLUMN et_day2sec FORMAT A12

SELECT
 s.sid
,s.serial#
,s.sql_id
,s.sql_child_number child_number
,p.optimizer
,CASE WHEN p.cost < POWER(1024,1) THEN                      p.cost||''
WHEN p.cost < POWER(1024,2) THEN ROUND(p.cost/POWER(1024,1))||'K'
WHEN p.cost < POWER(1024,3) THEN ROUND(p.cost/POWER(1024,2))||'M'
WHEN p.cost < POWER(1024,4) THEN ROUND(p.cost/POWER(1024,3))||'G'
WHEN p.cost < POWER(1024,5) THEN ROUND(p.cost/POWER(1024,4))||'T'
 END cost
,p.cost cost_order
,TO_CHAR(CAST(NUMTODSINTERVAL(TRUNC(q.elapsed_time/(1e6)),'SECOND') AS INTERVAL DAY(2) TO SECOND(0)) ) ET_DAY2SEC
,CASE WHEN FLOOR(elapsed_time/1e6) < 1 THEN TRUNC(q.elapsed_time/(1e3))
 ELSE NULL
 END et_milli
FROM
 v$session  s
,v$sql      q
,v$sql_plan p
WHERE
q.sql_id       = s.sql_id
AND q.child_number = s.sql_child_number
AND p.sql_id       = s.sql_id
AND p.child_number = s.sql_child_number
AND p.id           = 0
ORDER BY cost_order
;
