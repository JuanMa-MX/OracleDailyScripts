--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 180
SET PAGES 1000

PROMPT
PROMPT WHERE (1): sql_id='<sql_id>'
PROMPT ---------- hash_value=<hash_value>

COLUMN id FORMAT 999
COLUMN name FORMAT A40 WORD_WRAPPED
COLUMN operation FORMAT a40
COLUMN cost FORMAT A8
COLUMN cpu_cost FORMAT A8
COLUMN bytes FORMAT A8
COLUMN io_cost FORMAT A8

clear breaks
break on sql_id on child_number on plan_hash_value skip 2
undefine 1

SELECT
 p.sql_id
,p.plan_hash_value
,p.child_number
,p.id
,LPAD(' ',p.depth,' ')||p.operation||' '||p.options operation
,CASE WHEN p.object_name IS NULL THEN '' ELSE p.object_owner||'.'||p.object_name END name
,CASE WHEN p.cost < POWER(1024,1) THEN                      p.cost||''
WHEN p.cost < POWER(1024,2) THEN ROUND(p.cost/POWER(1024,1))||'K'
WHEN p.cost < POWER(1024,3) THEN ROUND(p.cost/POWER(1024,2))||'M'
WHEN p.cost < POWER(1024,4) THEN ROUND(p.cost/POWER(1024,3))||'G'
WHEN p.cost < POWER(1024,5) THEN ROUND(p.cost/POWER(1024,4))||'T'
 END cost
FROM
 v$sql_plan p
WHERE &1
and p.id = 0
ORDER BY sql_id, child_number, id
;

