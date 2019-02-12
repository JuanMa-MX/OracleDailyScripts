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
PROMPT WHERE (1): sql_id='<sql_id>'       AND child_number=<child_number>
PROMPT ---------- hash_value=<hash_value> AND child_number=<child_number>

COLUMN id FORMAT 999
COLUMN name FORMAT A40 WORD_WRAPPED
COLUMN operation FORMAT a40
COLUMN cost FORMAT A8
COLUMN cpu_cost FORMAT A8
COLUMN bytes FORMAT A8
COLUMN io_cost FORMAT A8
COLUMN rows_ heading "ROWS" FORMAT A8

clear breaks
break on sql_id on child_number on hash_value skip 2
undefine 1

SELECT
 p.sql_id
,p.hash_value
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
,CASE WHEN p.cardinality < POWER(1024,1) THEN                p.cardinality||''
WHEN p.cardinality < POWER(1024,2) THEN ROUND(p.cardinality/POWER(1024,1))||'K'
WHEN p.cardinality < POWER(1024,3) THEN ROUND(p.cardinality/POWER(1024,2))||'M'
WHEN p.cardinality < POWER(1024,4) THEN ROUND(p.cardinality/POWER(1024,3))||'G'
WHEN p.cardinality < POWER(1024,5) THEN ROUND(p.cardinality/POWER(1024,4))||'T'
 END rows_
,CASE WHEN p.bytes < POWER(1024,1) THEN                      p.bytes||''
WHEN p.bytes < POWER(1024,2) THEN ROUND(p.bytes/POWER(1024,1))||'K'
WHEN p.bytes < POWER(1024,3) THEN ROUND(p.bytes/POWER(1024,2))||'M'
WHEN p.bytes < POWER(1024,4) THEN ROUND(p.bytes/POWER(1024,3))||'G'
WHEN p.bytes < POWER(1024,5) THEN ROUND(p.bytes/POWER(1024,4))||'T'
 END bytes
,CASE WHEN p.cpu_cost < POWER(1024,1) THEN                      p.cpu_cost||''
WHEN p.cpu_cost < POWER(1024,2) THEN ROUND(p.cpu_cost/POWER(1024,1))||'K'
WHEN p.cpu_cost < POWER(1024,3) THEN ROUND(p.cpu_cost/POWER(1024,2))||'M'
WHEN p.cpu_cost < POWER(1024,4) THEN ROUND(p.cpu_cost/POWER(1024,3))||'G'
WHEN p.cpu_cost < POWER(1024,5) THEN ROUND(p.cpu_cost/POWER(1024,4))||'T'
 END cpu_cost
,CASE WHEN p.io_cost < POWER(1024,1) THEN                      p.io_cost||''
WHEN p.io_cost < POWER(1024,2) THEN ROUND(p.io_cost/POWER(1024,1))||'K'
WHEN p.io_cost < POWER(1024,3) THEN ROUND(p.io_cost/POWER(1024,2))||'M'
WHEN p.io_cost < POWER(1024,4) THEN ROUND(p.io_cost/POWER(1024,3))||'G'
WHEN p.io_cost < POWER(1024,5) THEN ROUND(p.io_cost/POWER(1024,4))||'T'
 END io_cost
FROM
 v$sql_plan p
WHERE &1
ORDER BY sql_id, child_number, id
;
