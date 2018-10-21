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

COLUMN chain_id NOPRINT
COLUMN N NOPRINT
COLUMN l NOPRINT
COLUMN root NOPRINT

COLUMN identifier       FOR A17
COLUMN username         FOR A15
COLUMN osuser           FOR A10
COLUMN machine          FOR A25
COLUMN program          FOR A15 TRUNC

SELECT
 '"'||sid||','||serial#||',@'||inst_id||'"' identifier
,username
,opname
,target
,sofar blocks_read
,totalwork total_blocks
,ROUND(time_remaining/60) minutes
FROM gv$session_longops
WHERE sofar <> totalwork
ORDER BY minutes
;
