--        Nombre: waits.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra los eventos de Espera actuales y cuantas sesiones experimentan ese evento
--           Uso: @waits ENTER
--Requerimientos: Acceso a [g]v$session
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com


SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Conteo de sesiones por Evento de Espera ] ====================
PROMPT

SET LINES 200
SET PAGES 1000
SET HEADING ON

CLEAR COLUMNS
CLEAR BREAKS

BREAK ON REPORT
COMPUTE SUM OF count ON REPORT

COL count FOR 999,990
COL state FOR A10
COL wait_class FOR A20 TRUNC
COL event FOR A40 TRUNC

SELECT COUNT(*) count
      ,CASE WHEN state != 'WAITING' THEN 'WORKING' ELSE 'WAITING' END AS state
      ,CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE wait_class END wait_class
      ,CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE event END event
FROM gv$session
WHERE type = 'USER'
AND status = 'ACTIVE'
AND wait_class NOT IN ('Idle')
GROUP BY
   CASE WHEN state != 'WAITING' THEN 'WORKING' ELSE 'WAITING' END
  ,CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE wait_class END
  ,CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE event END
ORDER BY
 1 DESC, 2 DESC
;

