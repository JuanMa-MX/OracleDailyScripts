--        Nombre: fts.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Nos muestra el espacio libre de los tablespaces
--           Uso: @fts ENTER
--                Columnas a seleccionar? tablespace_name,file_name [tablespace_name]:
--                Sentencia WHERE? contents tablespace_name [1=1]: 
--Requerimientos: Acceso a dba_tablespaces, dba_data_files, dba_temp_files, dba_free_space
--                         v$temp_space_header, v$temp_extent_pool
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ========== [ Tablespaces / Space Usage ] ==========
PROMPT

SET DEFINE ON
SET VERIFY OFF
SET LINES 200
SET PAGES 1000
COLUMN file_name heading 'File|Name' FORMAT A70
COLUMN tablespace_name heading 'Tablespace' FORMAT A30
COLUMN csize heading 'Allocated|Size' FORMAT A9
COLUMN free heading 'Allocated|FreeSpace' FORMAT A9
COLUMN upct heading 'Allocated|Used %' FORMAT A16
COLUMN msize heading 'Maximum|Size' FORMAT A9
COLUMN mfree heading 'Maximum|FreeSpace' FORMAT A9
COLUMN mupct heading 'Maximum|Used %' FORMAT A16
COLUMN contents heading 'Type' FORMAT A10


accept columns_ char default 'tablespace_name' -
prompt 'Columnas a seleccionar? tablespace_name,file_name [tablespace_name]: '

accept where_ char default '1=1' -
prompt 'Sentencia WHERE? contents tablespace_name [1=1]: '

BREAK ON contents SKIP 2

SELECT
 contents
,&columns_
,CASE WHEN SUM(size_mb) < 1024    THEN TO_CHAR(ROUND(SUM(size_mb)              ,1),'9G990D9')||'M'
WHEN SUM(size_mb) < POWER(1024,2) THEN TO_CHAR(ROUND(SUM(size_mb)/POWER(1024,1),1),'9G990D9')||'G'
WHEN SUM(size_mb) < POWER(1024,3) THEN TO_CHAR(ROUND(SUM(size_mb)/POWER(1024,2),1),'9G990D9')||'T'
 END csize
,CASE WHEN SUM(free_mb) < 1024    THEN TO_CHAR(SUM(free_mb)                       ,'9G990D9')||'M'
WHEN SUM(free_mb) < POWER(1024,2) THEN TO_CHAR(ROUND(SUM(free_mb)/POWER(1024,1),1),'9G990D9')||'G'
WHEN SUM(free_mb) < POWER(1024,3) THEN TO_CHAR(ROUND(SUM(free_mb)/POWER(1024,2),1),'9G990D9')||'T'
 END FREE
,'['||RPAD('#',ROUND(TRUNC((SUM(used_mb)*100/SUM(size_mb))*0.1)),'#')||
 RPAD('_',10-ROUND(TRUNC((SUM(used_mb)*100/SUM(size_mb))*0.1)),'_')||
 ']'||LPAD(ROUND((SUM(used_mb)*100/SUM(size_mb)))||'%',4,'.') upct
,CASE WHEN SUM(max_mb) < 1024    THEN TO_CHAR(SUM(max_mb)                       ,'9G990D9')||'M'
WHEN SUM(max_mb) < POWER(1024,2) THEN TO_CHAR(ROUND(SUM(max_mb)/POWER(1024,1),1),'9G990D9')||'G'
WHEN SUM(max_mb) < POWER(1024,3) THEN TO_CHAR(ROUND(SUM(max_mb)/POWER(1024,2),1),'9G990D9')||'T'
 END MSIZE
,CASE WHEN SUM(max_free_mb) < 1024    THEN TO_CHAR(SUM(max_free_mb)                       ,'9G990D9')||'M'
WHEN SUM(max_free_mb) < POWER(1024,2) THEN TO_CHAR(ROUND(SUM(max_free_mb)/POWER(1024,1),1),'9G990D9')||'G'
WHEN SUM(max_free_mb) < POWER(1024,3) THEN TO_CHAR(ROUND(SUM(max_free_mb)/POWER(1024,2),1),'9G990D9')||'T'
 END MFREE
,'['||RPAD('#',ROUND(TRUNC((SUM(max_used_mb)*100/SUM(max_mb))*0.1)),'#')||
 RPAD('_',10-ROUND(TRUNC((SUM(max_used_mb)*100/SUM(max_mb))*0.1)),'_')||
 ']'||LPAD(ROUND((SUM(max_used_mb)*100/SUM(max_mb)))||'%',4,'.') mupct
FROM
(
   SELECT
    t.contents
   ,d.tablespace_name
   ,d.file_name
   ,CASE WHEN TRUNC(d.bytes/(1024*1024)) = 0 THEN 0.001 ELSE TRUNC(d.bytes/(1024*1024)) END size_mb
   ,NVL(free.fmb,0) free_mb
   ,(TRUNC(d.bytes/(1024*1024)) - NVL(free.fmb,0)) used_mb
   ,CASE WHEN TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) = 0 THEN 0.001
    ELSE TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) END  max_mb
   ,(NVL(free.fmb,0) + (TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) - TRUNC(d.bytes/(1024*1024)))) max_free_mb
   ,(TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024))
   -
   (NVL(free.fmb,0) + (TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) - TRUNC(d.bytes/(1024*1024))))
    ) max_used_mb
   FROM dba_data_files d INNER JOIN
        dba_tablespaces t ON (t.tablespace_name = d.tablespace_name)
                                LEFT OUTER JOIN
   (SELECT f.file_id
      ,f.tablespace_name
      ,TRUNC(SUM(f.bytes)/(1024*1024)) fmb
    FROM dba_free_space f
    GROUP BY f.file_id
    ,f.tablespace_name
   ) free
   ON (free.tablespace_name = d.tablespace_name AND free.file_id = d.file_id)
   WHERE t.contents NOT IN ('TEMPORARY')
   UNION ALL
   SELECT
    t.contents
   ,d.tablespace_name
   ,d.file_name
   ,CASE WHEN TRUNC(d.bytes/(1024*1024)) = 0 THEN 0.001 ELSE TRUNC(d.bytes/(1024*1024)) END size_mb
   ,NVL(free.fmb,0) free_mb
   ,(TRUNC(d.bytes/(1024*1024)) - NVL(free.fmb,0)) used_mb
   ,CASE WHEN TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) = 0 THEN 0.001
    ELSE TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) END  max_mb
   ,(NVL(free.fmb,0) + (TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) - TRUNC(d.bytes/(1024*1024)))) max_free_mb
   ,(TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024))
   -
   (NVL(free.fmb,0) + (TRUNC(CASE WHEN NVL(d.maxbytes,0) < d.bytes THEN d.bytes ELSE d.maxbytes END/(1024*1024)) - TRUNC(d.bytes/(1024*1024))))
    ) max_used_mb
   FROM dba_temp_files d INNER JOIN
        dba_tablespaces t ON (t.tablespace_name = d.tablespace_name)
                                LEFT OUTER JOIN
       (SELECT f.tablespace_name, f.file_id,
               ROUND(SUM (  (h.bytes_free + h.bytes_used)
                     - NVL (p.bytes_used, 0)
                   )/(1024*1024)) fmb
        FROM v$temp_space_header h,
             v$temp_extent_pool p,
              dba_temp_files f
        WHERE p.file_id(+) = h.file_id
          AND p.tablespace_name(+) = h.tablespace_name
          AND f.file_id = h.file_id
          AND f.tablespace_name = h.tablespace_name
        GROUP BY f.tablespace_name,f.file_id) free
   ON (free.tablespace_name = d.tablespace_name AND free.file_id = d.file_id)
   WHERE t.contents IN ('TEMPORARY')
)
WHERE &where_
GROUP BY contents, &&columns_
ORDER BY contents, SUM(max_used_mb) DESC
;
CLEAR BREAKS

