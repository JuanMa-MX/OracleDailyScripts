--        Nombre: redog.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de los Grupos de Redo Log
--           Uso: @redog ENTER
--Requerimientos: Acceso a v$log
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ========== [ Redo Log Groups ] ==========
PROMPT

SET lines 200
SET pages 1000
SET HEADING ON

col group_size for a10

SELECT l.thread#
  ,l.group#
,CASE WHEN l.bytes < 1024          THEN l.bytes||''
WHEN l.bytes < POWER(1024,2) THEN ROUND(l.bytes/POWER(1024,1),1)||'K'
WHEN l.bytes < POWER(1024,3) THEN ROUND(l.bytes/POWER(1024,2),1)||'M'
WHEN l.bytes < POWER(1024,4) THEN ROUND(l.bytes/POWER(1024,3),1)||'G'
WHEN l.bytes < POWER(1024,5) THEN ROUND(l.bytes/POWER(1024,4),1)||'T'
 END group_size
  ,l.status
FROM v$log l
;
