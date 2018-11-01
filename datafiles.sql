--        Nombre: datafiles.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra los Datafiles de la Base de Datos
--           Uso: @datafiles ENTER
--                Sentencia WHERE? t.name [1=1]:
--Requerimientos: Acceso a v$tablespace, v$datafile
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Datafiles ] ====================
PROMPT

SET LINES 200
SET PAGES 1000
SET HEAD ON
SET DEFINE ON
SET VERIFY OFF

ACCEPT where_ CHAR DEFAULT '1=1' -
PROMPT 'Sentencia WHERE? t.name [1=1]: '

COL ts# FOR 999,999
COL tbs_name FOR A30
COL file# FOR 999,999
COL dbf_size FOR A10
COL dbf_name FOR A60

SELECT
 t.ts#
,t.name tbs_name
,CASE WHEN d.bytes < 1024          THEN d.bytes||''
WHEN d.bytes < POWER(1024,2) THEN ROUND(d.bytes/POWER(1024,1),1)||'K'
WHEN d.bytes < POWER(1024,3) THEN ROUND(d.bytes/POWER(1024,2),1)||'M'
WHEN d.bytes < POWER(1024,4) THEN ROUND(d.bytes/POWER(1024,3),1)||'G'
WHEN d.bytes < POWER(1024,5) THEN ROUND(d.bytes/POWER(1024,4),1)||'T'
 END dbf_size
,d.file#
,d.name dbf_name
FROM v$tablespace t
,v$datafile d
WHERE d.ts# = t.ts#
AND &where_
ORDER BY t.ts#
,d.file#
;
