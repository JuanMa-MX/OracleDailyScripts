--        Nombre: fra.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de la Fast Recovery Area
--           Uso: @fra ENTER 
--Requerimientos: Acceso a v$database, v$parameter, v$recovery_file_dest, v$recovery_area_usage
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
SET ECHO OFF
SET lines 200
SET pages 1000
SET HEADING ON

PROMPT
PROMPT
PROMPT ========== [ Is Archived Redo Log Configured ] ==========
PROMPT


SELECT DECODE(log_mode
 ,'NOARCHIVELOG', 'NO'
 ,'YES'
 ) archiving_on
FROM v$database
;

PROMPT
PROMPT
PROMPT ========== [ Is Flashback Configured ] ==========
PROMPT

SELECT flashback_on
FROM v$database
;

COLUMN value FORMAT A60

SELECT 'db_flashback_retention_target='||value||' (minutes)' value
FROM v$parameter
WHERE name = 'db_flashback_retention_target'
;


PROMPT
PROMPT
PROMPT ========== [ FRA Information ] ==========
PROMPT

COLUMN name FORMAT A50

SELECT name
  ,ROUND(space_limit/1048576) space_limit_mb
  ,ROUND(space_used/1048576) space_used_mb
  ,ROUND((ROUND(space_used/1048576)*100)/(ROUND(space_limit/1048576))) pct_used
  ,ROUND(space_reclaimable/1048576) space_reclaimable
FROM v$recovery_file_dest
;

SELECT *
FROM v$recovery_area_usage
;
