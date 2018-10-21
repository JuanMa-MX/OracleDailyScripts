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
PROMPT ==================== [ Porcentaje de Extents en Tablespaces ] ====================
PROMPT

SET LINES 200
SET PAGES 1000

CLEAR COLUMNS
CLEAR BREAKS

COL tablespace_name FOR A40 WORD_WRAPPED
COL max_extents     FOR 999,999,999,999,999,999
COL curr_extents    FOR 999,999,999,999,999,999

WITH
tbs_extents
AS
(
SELECT tablespace_name
  ,COUNT(*) curr_extents
FROM dba_extents
GROUP BY tablespace_name
)
SELECT tbs.tablespace_name
  ,tbs.max_extents
  ,ext.curr_extents
  ,ROUND((ext.curr_extents*100/(tbs.max_extents)),1) pct_used
FROM tbs_extents ext
,dba_tablespaces tbs
WHERE tbs.tablespace_name = ext.tablespace_name
;
