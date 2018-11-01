--        Nombre: sqltop.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra el Top 5 de Sentencias SQL en diversas categorias
--           Uso: @sqltop ENTER
--Requerimientos: Acceso a v$sqlstats
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Top 5 SQL ] ====================
PROMPT

PROMPT >> buffer_gets <<
SELECT *
FROM
(SELECT sql_id
   ,buffer_gets
   ,disk_reads
   ,sorts
   ,ROUND(cpu_time/(1e6*60)) cpu_min
   ,rows_processed
   ,elapsed_time
FROM v$sqlstats
ORDER BY buffer_gets DESC)
WHERE rownum <= 5
;

PROMPT >> disk_reads <<
SELECT *
FROM
(SELECT sql_id
   ,buffer_gets
   ,disk_reads
   ,sorts
   ,ROUND(cpu_time/(1e6*60)) cpu_min
   ,rows_processed
   ,elapsed_time
FROM v$sqlstats
ORDER BY disk_reads DESC)
WHERE rownum <= 5
;

PROMPT >> sorts <<
SELECT *
FROM
(SELECT sql_id
   ,buffer_gets
   ,disk_reads
   ,sorts
   ,ROUND(cpu_time/(1e6*60)) cpu_min
   ,rows_processed
   ,elapsed_time
FROM v$sqlstats
ORDER BY sorts DESC)
WHERE rownum <= 5
;

PROMPT >> cpu <<
SELECT *
FROM
(SELECT sql_id
   ,buffer_gets
   ,disk_reads
   ,sorts
   ,ROUND(cpu_time/(1e6*60)) cpu_min
   ,rows_processed
   ,elapsed_time
FROM v$sqlstats
ORDER BY cpu_min DESC)
WHERE rownum <= 5
;

PROMPT >> rows_processed <<
SELECT *
FROM
(SELECT sql_id
   ,buffer_gets
   ,disk_reads
   ,sorts
   ,ROUND(cpu_time/(1e6*60)) cpu_min
   ,rows_processed
   ,elapsed_time
FROM v$sqlstats
ORDER BY rows_processed DESC)
WHERE rownum <= 5
;

PROMPT >> elapsed_time <<
SELECT *
FROM
(SELECT sql_id
   ,buffer_gets
   ,disk_reads
   ,sorts
   ,ROUND(cpu_time/(1e6*60)) cpu_min
   ,rows_processed
   ,elapsed_time
FROM v$sqlstats
ORDER BY elapsed_time DESC)
WHERE rownum <= 5
;
