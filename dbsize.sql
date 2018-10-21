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
SET LINES 200
SET PAGES 1000
SET HEADING ON

clear breaks
break on report
compute sum of "MB" on report
compute sum of "GB" on report
compute sum of "TB" on report

column "MB" format 999,999,999,990

PROMPT
PROMPT
PROMPT ==================== [ DB Size by Files ] ====================
PROMPT

select file_type, round(sum(bytes)/(1024*1024)) mb,
  round(sum(bytes)/(1024*1024*1024)) gb,
  round(sum(bytes)/(1024*1024*1024*1024)) tb,
count(0) files_ctn
from
(select 'Datafiles' file_type, bytes from v$datafile
union all
select 'Redologs' file_type, bytes*members bytes
 from (select g.group#, g.bytes, count(0) members
from v$log g, v$logfile m
 where g.group#=m.group#
group by g.group#, g.bytes)
union all
select 'Tempfiles' file_type, bytes from v$tempfile
)
group by file_type
;


PROMPT
PROMPT ==================== [ DB Size by schemas ] ====================
PROMPT

COL owner FOR A30

select owner, ROUND(sum(bytes)/(1024*1024),2) mb, ROUND(sum(bytes)/(1024*1024*1024),2) gb
 from dba_segments
group by owner
;
