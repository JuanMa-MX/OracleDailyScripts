--        Nombre: sqls.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra las sentencias SQL en ejecucion e indica el
--                numero de sesiones que la estan ejecutando
--           Uso: @sqls ENTER
--Requerimientos: Acceso a [g]v$session, v$sqlarea
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Conteo de Sesiones por sentencia SQL ] ====================
PROMPT

SET LINES 200
SET PAGES 1000

CLEAR COLUMNS
CLEAR BREAKS

COMPUTE SUM LABEL 'Total en Ejecucion' OF CONTEO ON REPORT
BREAK ON REPORT

COL sql_text FOR a60

COL sql_id FOR A20
COL count  FOR 999,990

SELECT s.sql_id
  ,COUNT(*) conteo
  ,sqla.sql_text
FROM gv$session s, v$sqlarea sqla
WHERE s.state = 'WAITING'
AND s.sql_id IS NOT NULL
AND sqla.sql_id=s.sql_id
GROUP BY s.sql_id, sqla.sql_text
ORDER BY 2
;

