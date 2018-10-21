--        Nombre: events.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra los eventos de Espera y las sesiones que experimentan el Evento
--           Uso: @events ENTER
--                Columnas a seleccionar? [identifier,username,osuser,machine,program,sql_id]:
--                Sentencia WHERE? sql_id username osuser machine program [1=1]:
--Requerimientos: Acceso a v$instance, [g]v$session, [g]v$process, v$session_wait
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com
SET LINES 200
SET PAGES 1000
SET DEFINE ON
SET VERIFY OFF

CLEAR COLUMNS
CLEAR BREAKS

COL event            FOR A40 TRUNC
COL waiting_active   FOR A25
COL identifier       FOR A17
COL username         FOR A15
COL osuser           FOR A10
COL machine          FOR A25
COL program          FOR A15 TRUNC
COL sql_id           FOR A30

BREAK ON event SKIP 0
COMPUTE COUNT LABEL 'Total' OF event ON event

--la columna pname no existia antes de 11.2
set term off
column oracle_version new_value oracle_version_
column l_91 new_value l_91_
column e_92 new_value e_92_
column ge_91 new_value ge_91_
column l_92 new_value l_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column ge_112 new_value ge_112_
column l_112 new_value l_112_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--define oracle_version_=9.1;

select case when &oracle_version_ < 9.1 then '' else '--' end l_91 from v$instance;
select case when &oracle_version_ >= 9.1 then '' else '--' end ge_91 from v$instance;
select case when &oracle_version_ < 9.2 then '' else '--' end l_92 from v$instance;
select case when &oracle_version_ = 9.2 then '' else '--' end e_92 from v$instance;
select case when &oracle_version_ >= 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ < 10.1 then '' else '--' end l_101 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112  from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;

define l_101_columns_='sql_id(address-hash) username osuser machine program';
define ge_101_columns_='sql_id username osuser machine program';

column prompt_where new_value prompt_where_
select case when '&l_101_'  is null then '&l_101_columns_'
  when '&ge_101_' is null then '&ge_101_columns_'
 end prompt_where
from dual;

set term on

accept columns_ char default 'identifier,username,osuser,machine,program,sql_id' prompt 'Columnas a seleccionar? [identifier,username,osuser,machine,program,sql_id]: '
accept where_ char default '1=1' prompt 'Sentencia WHERE? &prompt_where_ [1=1]: '

SELECT
 waiting_active
,event
,&columns_
FROM
(
SELECT
&l_101_   CASE WHEN s.status = 'ACTIVE'
&l_101_   THEN TO_CHAR(CAST(numtodsinterval(w.seconds_in_wait, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0)))
&l_101_   ELSE '+00 00:00:00'
&l_101_  END
&l_101_  ||' '
&l_101_  ||TO_CHAR(CAST(numtodsinterval(s.last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waiting_active
&ge_101_  CASE WHEN s.status = 'ACTIVE'
&ge_101_   THEN TO_CHAR(CAST(numtodsinterval(s.seconds_in_wait, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0)))
&ge_101_   ELSE '+00 00:00:00'
&ge_101_  END
&ge_101_  ||' '
&ge_101_  ||TO_CHAR(CAST(numtodsinterval(s.last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waiting_active
&l_101_  ,w.event
&ge_101_ ,s.event
&ge_92_  ,s.sid||','||s.serial#||'@'||s.inst_id identifier
&l_92_   ,s.sid||','||s.serial# identifier
&ge_112_  ,NVL(s.username,'-|'||p.pname||'|-') username
&l_112_   ,NVL(s.username,'-|ORACLE|-') username
,s.osuser
,CASE WHEN INSTR(s.machine,'.') > 0
 THEN SUBSTR(s.machine,1,INSTR(s.machine,'.'))
 ELSE s.machine
 END machine
,CASE WHEN INSTR(s.program,'@') > 0
 THEN SUBSTR(s.program,1,INSTR(s.program,'@')-1)
 ELSE s.program
 END
 ||
 CASE WHEN INSTR(s.program,')') > 0
 THEN SUBSTR(s.program,INSTR(s.program,'('),INSTR(s.program,')')-INSTR(s.program,'(')+1)
 ELSE ''
 END program
&l_101_ ,s.sql_address||'-'||s.sql_hash_value sql_id
&ge_101_  ,s.sql_id
&l_92_ FROM v$session s, v$session_wait w, v$process p WHERE w.sid = s.sid AND p.addr = s.paddr AND s.status = 'ACTIVE'
&e_92_ FROM gv$session s, gv$session_wait w, gv$process p WHERE s.inst_id = p.inst_id AND w.inst_id = s.inst_id AND w.sid = s.sid AND s.paddr = p.addr AND s.status = 'ACTIVE'
&l_101_ AND (w.event NOT LIKE '%Idle%' AND w.event NOT LIKE '%idle%' AND w.event NOT LIKE '%ipc%' AND w.event NOT LIKE '%timer%' AND  w.event NOT LIKE 'Stre%waiting for time%')
&ge_101_ FROM gv$session s, gv$process p WHERE s.inst_id = p.inst_id AND s.paddr = p.addr AND s.status = 'ACTIVE' AND  s.wait_class NOT IN ('Idle')
)
WHERE &where_
order by event
;
