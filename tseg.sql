--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
set verify off
PROMPT

accept columns_ char default 'owner' -
prompt 'Columnas a seleccionar? [owner,segment_type,segment_name]: '

accept where_ char default '1=1' -
prompt 'Sentencia WHERE? [1=1]: '

set pages 1000
set lines 200
col segment_type for a20
col owner for a20
col segment_name for a50
col ssize for a9
col seg_siz noprint
select
 &columns_
,case when sum(bytes) < 1024          then to_char(sum(bytes)                       ,'9G990D9')||'B'
      when sum(bytes) < power(1024,2) then to_char(trunc(sum(bytes)/power(1024,1),1),'9G990D9')||'K'
      when sum(bytes) < power(1024,3) then to_char(trunc(sum(bytes)/power(1024,2),1),'9G990D9')||'M'
      when sum(bytes) < power(1024,4) then to_char(trunc(sum(bytes)/power(1024,3),1),'9G990D9')||'G'
      when sum(bytes) < power(1024,5) then to_char(trunc(sum(bytes)/power(1024,4),1),'9G990D9')||'T'
 end ssize
,sum(bytes) seg_siz
from dba_segments
where &where_
group by
 &columns_
order by seg_siz desc
;

set verify on
