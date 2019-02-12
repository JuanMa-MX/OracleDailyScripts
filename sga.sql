--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

set lines 100
col "Main SGA Areas" for a17
col "Pool" for a15
col "Value" for a10
SELECT 1 dummy, 'DB Buffer Cache' "Main SGA Areas", name "Pool"
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END "Value"
FROM v$sgastat
WHERE pool is null and
      name = 'buffer_cache'
group by name
union all
SELECT 2, 'Shared Pool', pool
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END value
FROM v$sgastat
WHERE pool = 'shared pool'
group by pool
union all
SELECT 3, 'Streams Pool', pool
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END value
FROM v$sgastat
WHERE pool = 'streams pool'
group by pool
union all
SELECT 4, 'Large Pool', pool
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END value
FROM v$sgastat
WHERE pool = 'large pool'
group by pool
union all
SELECT 5, 'Java Pool', pool
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END value
FROM v$sgastat
WHERE pool = 'java pool'
group by pool
union all
SELECT 6, 'Redo Log Buffer', name
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END value
FROM v$sgastat
WHERE pool is null and
      name = 'log_buffer'
group by name
union all
SELECT 7, 'Fixed SGA', name
,CASE WHEN SUM(bytes) < 1024          THEN SUM(bytes)||''
WHEN SUM(bytes) < POWER(1024,2) THEN ROUND(SUM(bytes)/POWER(1024,1),1)||'K'
WHEN SUM(bytes) < POWER(1024,3) THEN ROUND(SUM(bytes)/POWER(1024,2),1)||'M'
WHEN SUM(bytes) < POWER(1024,4) THEN ROUND(SUM(bytes)/POWER(1024,3),1)||'G'
WHEN SUM(bytes) < POWER(1024,5) THEN ROUND(SUM(bytes)/POWER(1024,4),1)||'T'
END value
FROM v$sgastat
WHERE pool is null and
      name = 'fixed_sga'
group by name
ORDER BY 1
;
