#Crear el archivo deploy.sh y copiar & pegar este contenido
#Para crear los script, ejecutar: sh deploy.sh

mkdir -p .oracle


cd .oracle


cat > repeat.sql <<'LINEAS_CODIGO'
--        Nombre: repeat.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Ayuda a ejecutar otro script cada N segundos por M veces
--           Uso: @repeat <N segundos> <M veces> <script a ejecutar> ENTER
--Requerimientos: El script usa el comando sleep de Sistema Operativo *nix
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

set serveroutput on
set echo off
set term off
set feed off

variable interval_   number;
variable interval_   number;
variable iterations_ number;
variable script      varchar2(128);
begin
 :interval_   := to_number('&1');
 :iterations_ := to_number('&2');
 :script      := '&3';
end;
/

spool r.script.sql

begin
 for i in 1..:iterations_
 loop
  dbms_output.put_line('@@'||:script||'.sql');
  if i < :iterations_
  then
 dbms_output.put_line('!sleep '||:interval_);
  end if;
 end loop;
end;
/

spool off;

set term on
@r.script.sql
LINEAS_CODIGO


cat > waits.sql <<'LINEAS_CODIGO'
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

LINEAS_CODIGO


cat > waits2.sql <<'LINEAS_CODIGO'
-----------------------------------------------------------
--
-- Script:      waiters.sql
-- Purpose:     to count the waiters for each event type
-- For:         8.0 and higher
--
-- Copyright:   (c) 2000 Ixora Pty Ltd
-- Author:      Steve Adams
--
-----------------------------------------------------------
SET ECHO OFF
SET LINES 200
SET PAGES 1000
SET HEADING ON

column wait_class for a20 trunc
column event      for a30 trunc
column t0 for 999
column t1 for 999
column t2 for 999
column t3 for 999
column t4 for 999
column t5 for 999
column t6 for 999
column t7 for 999
column t8 for 999
column t9 for 999


clear breaks
break on report
compute sum of t0 on report
compute sum of t1 on report
compute sum of t2 on report
compute sum of t3 on report
compute sum of t4 on report
compute sum of t5 on report
compute sum of t6 on report
compute sum of t7 on report
compute sum of t8 on report
compute sum of t9 on report

select /*+ CHOOSE */
n.wait_class,
n.name event,
/*
nvl(t0,0) t0,
nvl(t1,0) t1,
nvl(t2,0) t2,
nvl(t3,0) t3,
nvl(t4,0) t4,
nvl(t5,0) t5,
nvl(t6,0) t6,
nvl(t7,0) t7,
nvl(t8,0) t8,
nvl(t9,0) t9
*/
t0,
t1,
t2,
t3,
t4,
t5,
t6,
t7,
t8,
t9
from
 v$event_name  n,
(select event e0, count(*)  t0 from v$session_wait group by event),
(select event e1, count(*)  t1 from v$session_wait group by event),
(select event e2, count(*)  t2 from v$session_wait group by event),
(select event e3, count(*)  t3 from v$session_wait group by event),
(select event e4, count(*)  t4 from v$session_wait group by event),
(select event e5, count(*)  t5 from v$session_wait group by event),
(select event e6, count(*)  t6 from v$session_wait group by event),
(select event e7, count(*)  t7 from v$session_wait group by event),
(select event e8, count(*)  t8 from v$session_wait group by event),
(select event e9, count(*)  t9 from v$session_wait group by event)
where
n.wait_class not in ('Idle') and
n.name != 'Null event' and
n.name != 'null event' and
n.name != 'rdbms ipc message' and
n.name != 'pipe get' and
n.name != 'virtual circuit status' and
n.name not like '%timer%' and
n.name not like '%slave wait' and
n.name not like 'SQL*Net message from %' and
n.name not like 'io done' and
n.name != 'queue messages' and
e0  = n.name and
e1  = n.name and
e2  = n.name and
e3  = n.name and
e4  = n.name and
e5  = n.name and
e6  = n.name and
e7  = n.name and
e8  = n.name and
e9  = n.name and
nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0) > 0
order by
nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0)
;
LINEAS_CODIGO

cat > events.sql <<'LINEAS_CODIGO'
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
,status
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
,s.status
&ge_92_  ,s.sid||','||s.serial#||',@'||s.inst_id identifier
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
LINEAS_CODIGO

cat > sqls.sql <<'LINEAS_CODIGO'
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

LINEAS_CODIGO

cat > sqlid.sql <<'LINEAS_CODIGO'
--        Nombre: sqlid.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra la sentencia SQL segun el sql_id y child_number proporcionado,
--                el plan de ejecucion y el historia de planes de ejecucion de la sentencia
--                con la finalidad de encontrar si la sentencia a cambiado su plan de ejecucion
--           Uso: @sqlid ENTER
--                Id de la Sentencia SQL? (sql_id) []:
--                Child Number la Sentencia SQL? (child_number) []: 
--Requerimientos: Acceso a v$sqltext, dba_hist_snapshot, dba_hist_sqlstat
--Licenciamiento: Diagnostic & Tuning Pack
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Informacion del Cursor / Sentencia SQL ] ====================
PROMPT

SET LINES 200
SET PAGES 1000

CLEAR COLUMNS

ACCEPT xsql_id CHAR DEFAULT '' -
PROMPT 'Id de la Sentencia SQL? (sql_id) []: '


ACCEPT xchild_number CHAR DEFAULT '' -
PROMPT 'Child Number la Sentencia SQL? (child_number) []: '

SET TERM OFF
VARIABLE sql_id_ VARCHAR2(128);
VARIABLE child_number_ number;

EXECUTE :sql_id_ := '&xsql_id';
EXECUTE :child_number_ := '&xchild_number';

SET TERM ON

SELECT sql_text
FROM v$sqltext
WHERE sql_id = :sql_id_
ORDER BY piece
;

SET SERVEROUTPUT ON

SELECT *
FROM table(DBMS_XPLAN.DISPLAY_CURSOR(sql_id          => :sql_id_
,cursor_child_no => :child_number_
,format          => 'TYPICAL'
)
  )
;
--FORMAT:BASIC, TYPICAL, SERIAL, ALL, ADAPTIVE


COL inicio_snapshot FOR A30
COL fin_snapshot    FOR A30

SELECT
 TO_CHAR(b.begin_interval_time,'DD-MON-YYYY HH24:MI:SS')  inicio_snapshot
,TO_CHAR(b.end_interval_time  ,'DD-MON-YYYY HH24:MI:SS')  fin_snapshot
,a.executions_total num_ejecuciones
,ROUND((a.elapsed_time_total/a.executions_total/1e3),2) avg_x_ejecucion_milli
,a.plan_hash_value
,a.rows_processed_total rows_procesados
FROM dba_hist_sqlstat  a
    ,dba_hist_snapshot b
WHERE a.instance_number  = b.instance_number
AND a.snap_id          = b.snap_id
AND a.sql_id           = :sql_id_
AND a.executions_total <> 0
ORDER BY inicio_snapshot
;
LINEAS_CODIGO


cat > killer.sql <<'LINEAS_CODIGO'
--        Nombre: killer.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Nos ayuda a generar las sentencias ALTER SYSTEM para desconectar sesiones
--           Uso: @killer ENTER
--                Columnas a seleccionar? [<lista de columnas>]: 
--                Sentencia WHERE? <columnas WHERE> [1=0]: 
--Requerimientos: ALTER SSYSTEM, Acceso a v$instance, [g]v$session, [g]v$process
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
SET DEFINE ON
SET VERIFY OFF
SET LINES 200
SET PAGES 1000
SET FEED ON

set term off
column oracle_version new_value oracle_version_
column l_92 new_value l_92_
column e_92 new_value e_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column l_112 new_value l_112_
column ge_112 new_value ge_112_
column ge_92_l_112 new_value ge_92_l_112_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ < 9.2 then '' else '--' end l_92 from v$instance;
select case when &oracle_version_ = 9.2 then '' else '--' end e_92 from v$instance;
select case when &oracle_version_ > 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ < 10.1 then '' else '--' end l_101 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 9.2 AND &oracle_version_ < 11.2 then '' else '--' end ge_92_l_112 from v$instance;


define prompt_columns_='identifier,username,osuser,machine,sql_id';
define l_92_prompt_where_='sid serial# username osuser machine sql_id(address-hash)';
define e_92_prompt_where_='inst_id sid serial# username osuser machine sql_id(address-hash)';
define ge_92_prompt_where_='inst_id sid serial# username osuser machine sql_id';

column prompt_where new_value prompt_where_
select case when '&l_92_'  is null then '&l_92_prompt_where_'
  when '&e_92_' is null then '&e_92_prompt_where_'
  when '&ge_92_' is null then '&ge_92_prompt_where_'
 end prompt_where
from dual;

set term on

accept columns_ char default '&prompt_columns_' prompt 'Columnas a seleccionar? [&prompt_columns_]: ';
accept where_ char default '1=0' prompt 'Sentencia WHERE? &prompt_where_ [1=0]: ';

--SPOOL kill.out.sql

COLUMN kill_statement FOR A65
COLUMN identifier FOR A15
COLUMN username FOR A15
COLUMN machine FOR A25
COLUMN sid NOPRINT

SELECT
 kill_statement
,&columns_
FROM
(
SELECT
&l_92_  1  inst_id
&ge_92_  s.inst_id
&l_92_  ,s.sid||','||s.serial# identifier
&ge_92_  ,s.sid||','||s.serial#||'@'||s.inst_id identifier
&ge_112_  ,NVL(s.username,'-|'||p.pname||'|-') username
&l_112_   ,NVL(s.username,'-|ORACLE|-') username
,s.osuser
,CASE WHEN INSTR(s.machine,'.') > 0
 THEN SUBSTR(s.machine,1,INSTR(s.machine,'.'))
 ELSE s.machine
 END machine
&l_101_  ,s.sql_address||'-'||s.sql_hash_value sql_id
&ge_101_  ,s.sql_id
&l_92_  ,'alter system kill session '||''''||s.sid||','||s.serial#||''''||' immediate;' kill_statement
&ge_92_l_112_  ,'alter system kill session '||''''||s.sid||','||s.serial#||',@'||s.inst_id||''''||' immediate;' kill_statement
&ge_112_ ,'alter system disconnect session '||''''||s.sid||','||s.serial#||',@'||s.inst_id||''''||' immediate;' kill_statement
&l_92_ FROM v$session s, v$process p WHERE s.paddr = p.addr
&ge_92_ FROM gv$session s, gv$process p WHERE s.inst_id = p.inst_id AND s.paddr = p.addr
AND s.TYPE != 'BACKGROUND'
AND &where_
)
;
--SPOOL OFF;

--@kill.out.sql
LINEAS_CODIGO


cat > fts.sql <<'LINEAS_CODIGO'
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

LINEAS_CODIGO


cat > redog.sql <<'LINEAS_CODIGO'
--        Nombre: redog.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de los Grupos de Redo Log
--           Uso: @redog ENTER
--Requerimientos: Acceso a v$log
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ========== [ Redo Log Groups ] ==========
PROMPT

SET lines 200
SET pages 1000
SET HEADING ON

col group_size for a10

SELECT l.thread#
  ,l.group#
,CASE WHEN l.bytes < 1024          THEN l.bytes||''
WHEN l.bytes < POWER(1024,2) THEN ROUND(l.bytes/POWER(1024,1),1)||'K'
WHEN l.bytes < POWER(1024,3) THEN ROUND(l.bytes/POWER(1024,2),1)||'M'
WHEN l.bytes < POWER(1024,4) THEN ROUND(l.bytes/POWER(1024,3),1)||'G'
WHEN l.bytes < POWER(1024,5) THEN ROUND(l.bytes/POWER(1024,4),1)||'T'
 END group_size
  ,l.status
FROM v$log l
;
LINEAS_CODIGO


cat > redom.sql <<'LINEAS_CODIGO'
--        Nombre: redom.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de los Miembros de Redo Log
--           Uso: @redom ENTER
--Requerimientos: Acceso a v$instance, v$log, v$log_file
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ========== [ Redo Log Members ] ==========
PROMPT

SET HEADING ON

set term off
column oracle_version new_value oracle_version_
column ge_92 new_value ge_92_
column ge_101 new_value ge_101_
column ge_111 new_value ge_111_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;

set term on

COLUMN status FORMAT A8
COLUMN member FORMAT A60
COLUMN in_fra FORMAT A6

SELECT l.thread#
  ,lf.group#
  ,lf.member
  ,DECODE(lf.status,null,'IN USE',lf.status) status
&ge_92_      ,lf.type
&ge_101_     ,lf.is_recovery_dest_file in_fra
FROM v$log      l
,v$logfile lf
WHERE lf.group# = l.group#
ORDER BY lf.group#
;
LINEAS_CODIGO


cat > control.sql <<'LINEAS_CODIGO'
--        Nombre: control.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de los Controlfiles
--           Uso: @control ENTER
--Requerimientos: Acceso a v$instance, v$controlfile
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
SET LINES 200

PROMPT
PROMPT
PROMPT ========== [ Controlfiles ] ==========
PROMPT

set term off
column oracle_version new_value oracle_version_
column ge_101 new_value ge_101_
column ge_111 new_value ge_111_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;

set term on

COL name FOR A80
COL csize FOR A7
COL in_fra FOR A6

SELECT
 DECODE (ctrl.status,null,'IN USE',ctrl.status) status
,ctrl.name
&ge_111_  ,CASE WHEN ctrl.block_size*file_size_blks < 1024          THEN ctrl.block_size*file_size_blks||''
&ge_111_        WHEN ctrl.block_size*file_size_blks < POWER(1024,2) THEN ROUND(ctrl.block_size*file_size_blks/POWER(1024,1),1)||'K'
&ge_111_        WHEN ctrl.block_size*file_size_blks < POWER(1024,3) THEN ROUND(ctrl.block_size*file_size_blks/POWER(1024,2),1)||'M'
&ge_111_        WHEN ctrl.block_size*file_size_blks < POWER(1024,4) THEN ROUND(ctrl.block_size*file_size_blks/POWER(1024,3),1)||'G'
&ge_111_   END CSIZE
&ge_101_  ,ctrl.is_recovery_dest_file in_fra
FROM v$controlfile ctrl
;
LINEAS_CODIGO


cat > fra.sql <<'LINEAS_CODIGO'
--        Nombre: fra.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de la Fast Recovery Area
--           Uso: @fra ENTER 
--Requerimientos: Acceso a v$database, v$parameter, v$recovery_file_dest, v$recovery_area_usage
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
SET lines 200
SET pages 1000
SET HEADING ON

PROMPT
PROMPT
PROMPT ========== [ Is Archived Redo Log Configured ] ==========
PROMPT


SELECT DECODE(log_mode
 ,'NOARCHIVELOG', 'NO'
 ,'YES'
 ) archiving_on
FROM v$database
;

PROMPT
PROMPT
PROMPT ========== [ Is Flashback Configured ] ==========
PROMPT

SELECT flashback_on
FROM v$database
;

COLUMN value FORMAT A60

SELECT 'db_flashback_retention_target='||value||' (minutes)' value
FROM v$parameter
WHERE name = 'db_flashback_retention_target'
;


PROMPT
PROMPT
PROMPT ========== [ FRA Information ] ==========
PROMPT

COLUMN name FORMAT A50

SELECT name
  ,ROUND(space_limit/1048576) space_limit_mb
  ,ROUND(space_used/1048576) space_used_mb
  ,ROUND((ROUND(space_used/1048576)*100)/(ROUND(space_limit/1048576))) pct_used
  ,ROUND(space_reclaimable/1048576) space_reclaimable
FROM v$recovery_file_dest
;

SELECT *
FROM v$recovery_area_usage
;
LINEAS_CODIGO


cat > dbsize.sql <<'LINEAS_CODIGO'
--        Nombre: dbsize.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra el tamanio de la Base de Datos por Tipo de Archivo y por Esquema
--           Uso: @dbsize ENTER
--Requerimientos: Acceso a v$log, v$log_file, v$datafile, v$tempfile, dba_segments
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

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
LINEAS_CODIGO


cat > infocon.sql <<'LINEAS_CODIGO'
--        Nombre: infocon.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de la sesion establecida y Base de Datos
--           Uso: @infocon ENTER
--Requerimientos: Acceso a v$instance, v$database, v$version
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
SET LINES 100
SET PAGES 1000
SET HEADING ON
CLEAR BREAKS
CLEAR COLUMNS

set term off
column oracle_version new_value oracle_version_
column l_92 new_value l_92_
column e_92 new_value e_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column l_112 new_value l_112_
column ge_112 new_value ge_112_
column ge_92_l_112 new_value ge_92_l_112_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ < 9.2 then '' else '--' end l_92 from v$instance;
select case when &oracle_version_ = 9.2 then '' else '--' end e_92 from v$instance;
select case when &oracle_version_ > 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ < 10.1 then '' else '--' end l_101 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 9.2 AND &oracle_version_ < 11.2 then '' else '--' end ge_92_l_112 from v$instance;
set term on

COL conexion_actual FOR A50

SELECT
 'RDBMS         : '||(select banner from v$version where rownum = 1)
 ||CHR(10)
 ||CHR(10)
 ||'Conectado como: '||USER
 ||CHR(10)
 ||'Esquema actual: '||SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
 ||CHR(10)
 ||CHR(10)
 ||'Instancia     : '||i.instance_name
 ||CHR(10)
 ||'Version       : '||i.version
 ||CHR(10)
 ||'Iniciada desde: '||TO_CHAR (i.startup_time, 'dd-MON-yyyy hh24:mi')
 ||CHR(10)
 ||'Logins        : '||i.logins
 ||CHR(10)
 ||'Rol           : '||i.instance_role
 ||CHR(10)
 ||'Servidor      : '||i.host_name
 ||CHR(10)
 ||'Plataforma    : '||d.platform_name
 ||CHR(10)
 ||CHR(10)
 ||'Base de Datos : '||d.name
 ||CHR(10)
 ||'Creada desde  : '||TO_CHAR (d.created, 'dd-MON-yyyy')
 ||CHR(10)
 ||'Open Mode     : '||d.open_mode
&ge_92_ ||CHR(10)
&ge_92_ ||'Rol           : '||d.database_role
 ||CHR(10)
 ||'Modo Archive  : '||d.log_mode
&ge_92_ ||CHR(10)
&ge_92_ ||'Force Logging : '||d.force_logging
&ge_101_ ||CHR(10)
&ge_101_ ||'Flashback On? : '||d.flashback_on
 info_de_conexion
FROM v$instance i, v$database d
;
LINEAS_CODIGO


cat > fses.sql <<'LINEAS_CODIGO'
--        Nombre: fses.sql
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion: Muestra informacion de conexion de una sesion en especifico
--           Uso: @fses ENTER
--                Sentencia WHERE? sid spid [1=1]:
--Requerimientos: Acceso a v$instance, [g]v$session, [g]v$process, v$sql
--Licenciamiento: Ninguno
--        Creado: 10/07/2017
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
SET DEFINE ON
SET VERIFY OFF
PROMPT
PROMPT
PROMPT ==================== [ Session Info ] ====================
PROMPT

SET LINES 200
SET PAGES 100
SET HEAD ON
SET LONG 100000
SET LONGC 100000
SET DEFINE ON

set term off
column oracle_version new_value oracle_version_
column l_92 new_value l_92_
column e_92 new_value e_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column l_111 new_value l_111_
column ge_111 new_value ge_111_
column l_112 new_value l_112_
column ge_112 new_value ge_112_
column ge_92_l_112 new_value ge_92_l_112_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ < 9.2 then '' else '--' end l_92 from v$instance;
select case when &oracle_version_ = 9.2 then '' else '--' end e_92 from v$instance;
select case when &oracle_version_ > 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ < 10.1 then '' else '--' end l_101 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ < 11.1 then '' else '--' end l_111 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 9.2 AND &oracle_version_ < 11.2 then '' else '--' end ge_92_l_112 from v$instance;


define prompt_columns_='identifier,username,osuser,machine,sql_id';
define l_92_prompt_where_='sid serial# username osuser machine sql_id(address-hash)';
define e_92_prompt_where_='inst_id sid serial# username osuser machine sql_id(address-hash)';
define ge_92_prompt_where_='inst_id sid serial# username osuser machine sql_id';

column prompt_where new_value prompt_where_
select case when '&l_92_'  is null then '&l_92_prompt_where_'
  when '&e_92_' is null then '&e_92_prompt_where_'
  when '&ge_92_' is null then '&ge_92_prompt_where_'
 end prompt_where
from dual;

set term on

COL dummy_value NOPRINT
COL info_session FOR A80

ACCEPT where_ CHAR DEFAULT '1=1' PROMPT 'Sentencia WHERE? sid spid [1=1]: ';

SELECT 'dummy_value' dummy_value,
&l_92_ 'IDENTIFIER  : ' || sid || ',' || serial# || CHR(10) ||
&ge_92_ 'IDENTIFIER  : ' || sid || ',' || serial# || ',' ||'@'||inst_id || CHR(10) ||
'LOGON TIME  : ' || TO_CHAR(logon_time,'YYYY-MON-DD HH24:MI:SS') || CHR(10) ||
'STATUS      : ' || status || CHR(10) ||
&ge_112_  'USERNAME    : ' ||NVL(username,'-|'||pname||'|-') || CHR(10) ||
&l_112_   'USERNAME    : ' || NVL(username,'-|BGProcess|-') || CHR(10) ||
'SCHEMA      : ' || schemaname || CHR(10) ||
'OSUSER      : ' || osuser || CHR(10) ||
'MODULE      : ' || module || CHR(10) ||
'ACTION      : ' || action || CHR(10) ||
'CLIENT INFO : ' || client_info || CHR(10) ||
'PROGRAM     : ' || program || CHR(10) ||
'SPID        : ' || spid || CHR(10) ||
'MACHINE     : ' || machine || CHR(10) ||
'TYPE        : ' || type || CHR(10) ||
'TERMINAL    : ' || terminal || CHR(10) ||
'CPU         : ' || cpu_time/1e6 || CHR(10) ||
'ELAPSED_TIME: ' || elapsed_time/1e6 || CHR(10) ||
'BUFFER_GETS : ' || buffer_gets || CHR(10) ||
&l_101_  'SQL_ID      : ' || sql_address||'-'||sql_hash_value || CHR(10) ||
&ge_101_ 'SQL_ID      : ' || sql_id || CHR(10) ||
&l_101_  'CHILD_NUM   : ' || child_number || CHR(10) ||
&ge_101_ 'CHILD_NUM   : ' || sql_child_number || CHR(10) ||
&l_111_  'START_TIME  : ' || 'UNKNOWN' || CHR(10) ||
&ge_111_ 'START_TIME  : ' || TO_CHAR(sql_exec_start,'yyyy-mm-dd hh24:mi') || CHR(10) ||
'SQL_TEXT    : ' || sql_text || CHR(10) ||
'--------------------------------------------------------------------------------'
info_session
FROM (   SELECT 
          s.sid,s.serial#,s.logon_time,s.status,s.username,s.schemaname,s.osuser
         ,s.module,s.action,s.client_info,s.program,s.machine,s.type,s.terminal
&l_101_  ,s.sql_address,s.sql_hash_value
&ge_101_ ,s.sql_child_number
&ge_111_ ,s.sql_exec_start
&ge_92_  ,s.inst_id
         ,p.spid
&ge_112_ ,p.pname
         ,q.cpu_time
         ,q.elapsed_time
         ,q.buffer_gets
&ge_101_ ,q.sql_id
&l_101_  ,q.child_number
&l_101_  ,q.sql_text
&ge_101_ ,q.sql_fulltext sql_text
&l_92_   FROM v$session s, v$process p, v$sql q
&l_92_   WHERE s.paddr = p.addr AND q.address(+) = s.sql_adress and q.hash_value = s.sql_hash_value AND q.child_number = s.sql_child_number
&ge_92_  FROM gv$session s INNER JOIN      gv$process p ON (p.inst_id = s.inst_id AND  p.addr = s.paddr)
&ge_92_                    LEFT OUTER JOIN gv$sql     q ON (q.inst_id = s.inst_id
&e_92_                                                  AND q.address = s.sql_adress AND q.hash_value = s.sql_hash_value AND q.child_number = s.sql_child_number )
&ge_101_                                                AND q.sql_id = s.sql_id AND q.child_number = s.sql_child_number )
      )
WHERE &where_ AND NVL(sql_text,'-') NOT LIKE '%dummy_value%'
;
LINEAS_CODIGO


cat > datafiles.sql <<'LINEAS_CODIGO'
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
LINEAS_CODIGO

cat > longops.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Operaciones Largas ] ====================
PROMPT

SET LINES 200
SET PAGES 1000

CLEAR COLUMNS
CLEAR BREAKS


set lines 180
col sid format 9999
col start_time format a5 heading "Start|time"
col elapsed format 9999 heading "ELAPSED|past"
col remaining format 9999 heading "left"
col message format a81

select inst_id, to_char(start_time,'hh24:mi') start_time,
sid,
  to_char(cast(numtodsinterval(elapsed_seconds,'SECOND') as interval day(2) to second(0))) elapsed,
  to_char(cast(numtodsinterval(time_remaining,'SECOND') as interval day(2) to second(0))) remaining,
   message
from gv$session_longops where time_remaining > 0
order by 1,2
;
LINEAS_CODIGO


cat > sqltop.sql <<'LINEAS_CODIGO'
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
LINEAS_CODIGO

cat > locks.sql  <<'LINEAS_CODIGO'
CLEAR BREAKS
CLEAR COLUMNS

SET LINES 200
SET PAGES 10000
COL event_blocker_blocked FOR A35
COL username_sid_serial   FOR A30
COL machine        FOR A25 TRUNC
COL program        FOR A15 TRUNC
COL sqlid_child    FOR A16
COL cnt            FOR 999
COL max_time       FOR A12

WITH curr_session AS (SELECT * FROM v$session)
SELECT
       TO_CHAR (CAST (NUMTODSINTERVAL (bl.max_time, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) max_time
      ,bl.max_blocked cnt
      ,se.sql_id||' '||CASE WHEN se.sql_id IS NULL THEN NULL ELSE se.sql_child_number END sqlid_child
      ,RPAD(NVL(se.username,'-|BGPROCESS|-'),(29-LENGTH(se.sid||','||se.serial#)),' ')||se.sid||','||se.serial#||CHR(10)||
       RPAD(se.status                ,(29-12),' ')||TO_CHAR (CAST (NUMTODSINTERVAL (se.last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) username_sid_serial
      ,'+'||se.event||CHR(10)||' -'||bl.event event_blocker_blocked
      ,se.program
      ,se.machine
FROM curr_session se
    ,(SELECT c.blocking_session sid, c.event, COUNT(*) max_blocked, max(seconds_in_wait) max_time
      FROM curr_session c group by c.blocking_session, c.event) bl
WHERE se.sid  = bl.sid
ORDER BY max_time, max_blocked
;

LINEAS_CODIGO

cat > lockt.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET ECHO OFF

PROMPT
PROMPT
PROMPT ==================== [ Arbol de Bloqueos ] ====================
PROMPT

SET LINES 200
SET PAGES 1000
SET RECSEP EACH

CLEAR COLUMNS
CLEAR BREAKS

SET HEADING ON
COLUMN chain_id NOPRINT
COLUMN N NOPRINT
COLUMN l NOPRINT
COLUMN blocker FOR 9999999
COLUMN graph FORMAT A15
COLUMN waiting   FOR A12
COLUMN last_call_et FOR A12
COLUMN info1 FOR A50 WORD_WRAP
COLUMN info2 FOR A50 WORD_WRAP

BREAK ON blocker SKIP 3

WITH
w AS
(
 SELECT chain_id
   ,ROWNUM n
   ,LEVEL l
   ,CONNECT_BY_ROOT w.sid root
   --
   --
   ,LPAD('+',LEVEL,'+')||NVL(LEVEL,1) graph
   ,w.in_wait_secs
   ,s.last_call_et
   ,  'S: '||s.status                                 ||CHR(10)
    ||'I: '||s.sid||','||s.serial#||'@'||s.inst_id    ||CHR(10)
    ||'U: '||NVL(s.username,p.pname)||' / '||s.osuser ||CHR(10)
    ||'P: '||CASE WHEN INSTR(s.program,'@') > 0
             THEN SUBSTR(s.program,1,INSTR(s.program,'@')-1)
             ELSE s.program
             END
             ||
             CASE WHEN INSTR(s.program,')') > 0
             THEN SUBSTR(s.program,INSTR(s.program,'('),INSTR(s.program,')')-INSTR(s.program,'(')+1)
             ELSE ''
             END                                               ||CHR(10)
    ||'H: '||s.machine
    info1
  ,  'E: '||w.wait_event_text                                  ||CHR(10)
   ||'Q: '||s.sql_id                                           ||CHR(10)
   ||'M: '||DECODE(w.p1
                   ,1414332418,'Row-S'
                   ,1414332419,'Row-X'
                   ,1414332420,'Share'
                   ,1414332421,'Share RX'
                   ,1414332422,'eXclusive'
                   ,w.p1) ||CHR(10)
   ||'O: '||( SELECT '['||object_type||'] '||owner||'."'||object_name||'"'
               FROM all_objects
               WHERE object_id=CASE WHEN w.wait_event_text LIKE 'enq: TX%' THEN w.row_wait_obj# ELSE w.p2 END ) ||CHR(10)
   ||'R: '||CASE WHEN w.wait_event_text LIKE 'enq: TX%' THEN
             (SELECT dbms_rowid.rowid_create(1,data_object_id,relative_fno,w.row_wait_block#,w.row_wait_row#)
              FROM all_objects, dba_data_files
              WHERE object_id = w.row_wait_obj# AND w.row_wait_file# = file_id
             )
             END
     info2
 FROM v$wait_chains w JOIN gv$session s ON (s.sid = w.sid AND s.serial# = w.sess_serial# AND s.inst_id = w.instance)
   JOIN gv$process p ON (s.inst_id = p.inst_id AND s.paddr = p.addr)
 CONNECT BY PRIOR w.sid = w.blocker_sid AND PRIOR w.sess_serial# = w.blocker_sess_serial# AND PRIOR w.instance = w.blocker_instance
 START WITH w.blocker_sid IS NULL
)
SELECT chain_id,n,l,root blocker,graph
,TO_CHAR(CAST(numtodsinterval(in_wait_secs, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waiting
,TO_CHAR(CAST(numtodsinterval(last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) last_call_et
,info1
,info2
FROM w
WHERE chain_id IN (SELECT chain_id FROM w GROUP BY chain_id HAVING MAX(in_wait_secs) >= 2 AND MAX(l) > 1 )
ORDER BY root, graph DESC, waiting DESC
;

SET RECSEP WR
LINEAS_CODIGO

cat > lockt2.sql <<'LINEAS_CODIGO'
set lines 200
col sess_info for a170 word_wrap

select
   lpad (lvl, 2)         || ' '
 ||lpad ('>', lvl*2, '-')|| ' '
 ||sid || ', ' || serial#|| ' '
 ||username              || ' '
 ||machine               || ' '
 ||osuser                || ' '
 ||program               || ' - '
 ||event sess_info
,to_char (cast (numtodsinterval (seconds_in_wait, 'SECOND') as interval day(2) to second(0))) waiting
,inst_id inst
from
(
   select
     level lvl
    ,connect_by_isleaf leaf
    ,inst_id
    ,sid
    ,serial#
    ,username
    ,machine
    ,osuser
    ,program
    ,event
    ,seconds_in_wait
    ,blocking_session
  from  gv$session
     connect by prior sid = blocking_session
     start with blocking_session is null
) where (lvl = 1 and leaf = 0) or (lvl > 1)
;
LINEAS_CODIGO

cat > longops2.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Operaciones Largas ] ====================
PROMPT

SET LINES 200
SET PAGES 1000

CLEAR COLUMNS
CLEAR BREAKS

COLUMN chain_id NOPRINT
COLUMN N NOPRINT
COLUMN l NOPRINT
COLUMN root NOPRINT

COLUMN identifier       FOR A17
COLUMN username         FOR A15
COLUMN osuser           FOR A10
COLUMN machine          FOR A25
COLUMN program          FOR A15 TRUNC

SELECT
 '"'||sid||','||serial#||',@'||inst_id||'"' identifier
,username
,opname
,target
,sofar blocks_read
,totalwork total_blocks
,ROUND(time_remaining/60) minutes
FROM gv$session_longops
WHERE sofar <> totalwork
ORDER BY minutes
;
LINEAS_CODIGO

cat > fte.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

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
LINEAS_CODIGO

cat > sysa.x.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

VARIABLE interval_          NUMBER;

VARIABLE f1_other          NUMBER;
VARIABLE f1_queueing       NUMBER;
VARIABLE f1_network        NUMBER;
VARIABLE f1_administrative NUMBER;
VARIABLE f1_configuration  NUMBER;
VARIABLE f1_commit         NUMBER;
VARIABLE f1_application    NUMBER;
VARIABLE f1_concurrency    NUMBER;
VARIABLE f1_cluster        NUMBER;
VARIABLE f1_system_io      NUMBER;
VARIABLE f1_user_io        NUMBER;
VARIABLE f1_scheduler      NUMBER;
VARIABLE f1_cpu            NUMBER;
VARIABLE f1_total          NUMBER;

VARIABLE f2_other          NUMBER;
VARIABLE f2_queueing       NUMBER;
VARIABLE f2_network        NUMBER;
VARIABLE f2_administrative NUMBER;
VARIABLE f2_configuration  NUMBER;
VARIABLE f2_commit         NUMBER;
VARIABLE f2_application    NUMBER;
VARIABLE f2_concurrency    NUMBER;
VARIABLE f2_cluster        NUMBER;
VARIABLE f2_system_io      NUMBER;
VARIABLE f2_user_io        NUMBER;
VARIABLE f2_scheduler      NUMBER;
VARIABLE f2_cpu            NUMBER;
VARIABLE f2_total          NUMBER;

VARIABLE total             NUMBER;

VARIABLE time              VARCHAR2(8);

VARIABLE sesactive         NUMBER;
VARIABLE sesinactive       NUMBER;
VARIABLE sesblocked        NUMBER;
VARIABLE num_cpus          NUMBER;

SET TERM OFF

BEGIN
:interval_         := TO_NUMBER('&1');
:f1_other          := 0;
:f1_queueing       := 0;
:f1_network        := 0;
:f1_administrative := 0;
:f1_configuration  := 0;
:f1_commit         := 0;
:f1_application    := 0;
:f1_concurrency    := 0;
:f1_cluster        := 0;
:f1_system_io      := 0;
:f1_user_io        := 0;
:f1_scheduler      := 0;
:f1_cpu            := 0;
:f1_total          := 0;
:sesactive         := 0;
:sesinactive       := 0;
:sesblocked        := 0;
END;
/

SET TERM ON

BEGIN
 SELECT sum(value)/1E6
 INTO :f1_cpu
 FROM v$sys_time_model
 WHERE stat_name IN ('DB CPU','background cpu time');

 FOR reg IN (SELECT wait_class#
 ,wait_class
 ,time_waited/1E2 time_waited
   FROM v$system_wait_class
   WHERE wait_class <> 'Idle'
  )
 LOOP
  CASE reg.wait_class
 WHEN 'Other'          THEN :f1_other          := reg.time_waited;
 WHEN 'Queueing'       THEN :f1_queueing       := reg.time_waited;
 WHEN 'Network'        THEN :f1_network        := reg.time_waited;
 WHEN 'Administrative' THEN :f1_administrative := reg.time_waited;
 WHEN 'Configuration'  THEN :f1_configuration  := reg.time_waited;
 WHEN 'Commit'         THEN :f1_commit         := reg.time_waited;
 WHEN 'Application'    THEN :f1_application    := reg.time_waited;
 WHEN 'Concurrency'    THEN :f1_concurrency    := reg.time_waited;
 WHEN 'Cluster'        THEN :f1_cluster        := reg.time_waited;
 WHEN 'System I/O'     THEN :f1_system_io      := reg.time_waited;
 WHEN 'User I/O'       THEN :f1_user_io        := reg.time_waited;
 WHEN 'Scheduler'      THEN :f1_scheduler      := reg.time_waited;
  END CASE;
  :f1_total := :f1_total + reg.time_waited;
 END LOOP;
END;
/
LINEAS_CODIGO

cat > sysa.y.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

CLEAR BREAKS
CLEAR COLUMNS
SET LINES 200

COLUMN sesactive FORMAT 999 HEADING "Active"
COLUMN sesinactive FORMAT 999999 HEADING "Inactive"
COLUMN sesblocked FORMAT 999 HEADING "Blocked"
COLUMN wtime FORMAT A8 TRUNCATE HEADING "Time"
COLUMN num_cpus FORMAT 990 HEADING "NumCPUs";
COLUMN wactive FORMAT 999,990.0 HEADING "AvgActSess"
COLUMN wother FORMAT 990.0 HEADING "Other%"
COLUMN wqueueing FORMAT 990.0 HEADING "Queue%"
COLUMN wnetwork FORMAT 990.0 HEADING "Net%"
COLUMN wadministrative FORMAT 990.0 HEADING "Adm%"
COLUMN wconfiguration FORMAT 990.0 HEADING "Conf%"
COLUMN wcommit FORMAT 990.0 HEADING "Comm%"
COLUMN wapplication FORMAT 990.0 HEADING "Appl%"
COLUMN wconcurrency FORMAT 990.0 HEADING "Conc%"
COLUMN wcluster FORMAT 990.0 HEADING "Clust%"
COLUMN wsystem_io FORMAT 990.0 HEADING "SysIO%"
COLUMN wuser_io FORMAT 990.0 HEADING "UsrIO%"
COLUMN wscheduler FORMAT 990.0 HEADING "Sched%"
COLUMN wtotal FORMAT 990.0 HEADING "CPU%"

BEGIN
:f2_other          := 0;
:f2_queueing       := 0;
:f2_network        := 0;
:f2_administrative := 0;
:f2_configuration  := 0;
:f2_commit         := 0;
:f2_application    := 0;
:f2_concurrency    := 0;
:f2_cluster        := 0;
:f2_system_io      := 0;
:f2_user_io        := 0;
:f2_scheduler      := 0;
:f2_cpu            := 0;
:f2_total          := 0;
:total             := 0;
END;
/

BEGIN
 BEGIN
  SELECT value INTO :num_cpus FROM v$osstat WHERE stat_name='NUM_CPU_CORES';
 EXCEPTION WHEN no_data_found THEN
  SELECT value INTO :num_cpus FROM v$osstat WHERE stat_name='NUM_CPUS';
 END;

 SELECT sum(value)/1E6, to_char(sysdate,'hh24:mi:ss')
 INTO :f2_cpu, :time
 FROM v$sys_time_model
 WHERE stat_name IN ('DB CPU','background cpu time');

 FOR reg IN (SELECT wait_class#
 ,wait_class
 ,time_waited/1E2 time_waited
   FROM v$system_wait_class
   WHERE wait_class <> 'Idle'
  )
 LOOP
  CASE reg.wait_class
 WHEN 'Other'          THEN :f2_other          := reg.time_waited;
 WHEN 'Queueing'       THEN :f2_queueing       := reg.time_waited;
 WHEN 'Network'        THEN :f2_network        := reg.time_waited;
 WHEN 'Administrative' THEN :f2_administrative := reg.time_waited;
 WHEN 'Configuration'  THEN :f2_configuration  := reg.time_waited;
 WHEN 'Commit'         THEN :f2_commit         := reg.time_waited;
 WHEN 'Application'    THEN :f2_application    := reg.time_waited;
 WHEN 'Concurrency'    THEN :f2_concurrency    := reg.time_waited;
 WHEN 'Cluster'        THEN :f2_cluster        := reg.time_waited;
 WHEN 'System I/O'     THEN :f2_system_io      := reg.time_waited;
 WHEN 'User I/O'       THEN :f2_user_io        := reg.time_waited;
 WHEN 'Scheduler'      THEN :f2_scheduler      := reg.time_waited;
  END CASE;
  :f2_total := :f2_total + reg.time_waited;
 END LOOP;
 :total := (:f2_total - :f1_total) + (:f2_cpu - :f1_cpu);
 :total := nullif(:total,0); -- avoid ORA-01476: divisor is equal to zero

 SELECT COUNT(CASE WHEN status IN ('ACTIVE')
   THEN 1
   ELSE NULL
  END),
  COUNT(CASE WHEN status IN ('INACTIVE')
   THEN 1
   ELSE NULL
  END),
  COUNT(CASE WHEN blocking_session IS NOT NULL
   THEN 1
   ELSE NULL
  END)
 INTO
  :sesactive
 ,:sesinactive
 ,:sesblocked
 FROM v$session
 WHERE username IS NOT NULL;
END;
/

select
:sesactive                                           sesactive
, :sesinactive                                         sesinactive
, :sesblocked                                          sesblocked
, :time                                                wtime
, :num_cpus                                            num_cpus
, :total/nullif(:interval_,0)                          wactive
, (:f2_other          - :f1_other)/:total*100          wother
, (:f2_queueing       - :f1_queueing)/:total*100       wqueueing
, (:f2_network        - :f1_network)/:total*100        wnetwork
, (:f2_administrative - :f1_administrative)/:total*100 wadministrative
, (:f2_configuration  - :f1_configuration)/:total*100  wconfiguration
, (:f2_commit         - :f1_commit)/:total*100         wcommit
, (:f2_application    - :f1_application)/:total*100    wapplication
, (:f2_concurrency    - :f1_concurrency)/:total*100    wconcurrency
, (:f2_cluster        - :f1_cluster)/:total*100        wcluster
, (:f2_system_io      - :f1_system_io)/:total*100      wsystem_io
, (:f2_user_io        - :f1_user_io)/:total*100        wuser_io
, (:f2_scheduler      - :f1_scheduler)/:total*100      wscheduler
, (:f2_cpu - :f1_cpu )/:total*100                      wtotal
from dual;

BEGIN
 :f1_other          := :f2_other;
 :f1_queueing       := :f2_queueing;
 :f1_network        := :f2_network;
 :f1_administrative := :f2_administrative;
 :f1_configuration  := :f2_configuration;
 :f1_commit         := :f2_commit ;
 :f1_application    := :f2_application;
 :f1_concurrency    := :f2_concurrency;
 :f1_cluster        := :f2_cluster;
 :f1_system_io      := :f2_system_io;
 :f1_user_io        := :f2_user_io;
 :f1_scheduler      := :f2_scheduler;
 :f1_cpu            := :f2_cpu;
 :f1_total          := :f2_total;
END;
/
LINEAS_CODIGO


cat > sysa.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

set serveroutput on
set echo off
set term off
set feed off

variable interval_   number;
variable iterations_ number;
begin
 :interval_   := to_number('&1');
 :iterations_ := to_number('&2');
end;
/

spool sysa.script.sql

declare
 j number;
begin
 dbms_output.put_line('set newpage none');
 dbms_output.put_line('set lines 170');
 dbms_output.put_line('set pages 20');
 dbms_output.put_line('set echo off');
 dbms_output.put_line('set feedback off');
 dbms_output.put_line('set recsep off');
 dbms_output.put_line('@@sysa.x.sql '||:interval_);

 j := 0;
 for i in 1..:iterations_
 loop
  if j = 0
  then
 dbms_output.put_line('set head on');
  else
 dbms_output.put_line('set head off');
  end if;
  dbms_output.put_line('!sleep '||:interval_);
  dbms_output.put_line('@@sysa.y.sql');
  j := j + 1;
  if j = 10
  then
j := 0;
  end if;
 end loop;
end;
/

spool off;

set term on
@sysa.script.sql
LINEAS_CODIGO

cat > sysm.x.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

CLEAR BREAKS
CLEAR COLUMNS

VARIABLE interval_     NUMBER;

VARIABLE snapshot     VARCHAR2(8);
VARIABLE actsess      NUMBER;
VARIABLE resp_time    NUMBER;
VARIABLE executions   NUMBER;
VARIABLE parses       NUMBER;
VARIABLE open_cursors NUMBER;
VARIABLE commits      NUMBER;
VARIABLE read_mb      NUMBER;
VARIABLE write_mb     NUMBER;
VARIABLE host_cpu     NUMBER;
VARIABLE transactions NUMBER;

BEGIN
 :interval_ := 15;
 select count(*) into :actsess from v$session where status = 'ACTIVE' and username is not null;

 select to_char(begin_time, 'hh24:mi:ss') snapshot
 --,sum(case when metric_name = 'Current Logons Count'               then value                      else 0 end)
 ,sum(case when metric_name = 'SQL Service Response Time'          then trunc(value/(1e3),3)       else 0 end)
 ,sum(case when metric_name = 'Executions Per Sec'                 then trunc(value,1)             else 0 end)
 ,sum(case when metric_name = 'Total Parse Count Per Sec'          then value                      else 0 end)
 ,sum(case when metric_name = 'Open Cursors Per Sec'               then value                      else 0 end)
 ,sum(case when metric_name = 'User Commits Per Sec'               then value                      else 0 end)
 ,sum(case when metric_name = 'Physical Read Total Bytes Per Sec'  then round(value/(1024*1024),1) else 0 end)
 ,sum(case when metric_name = 'Physical Write Total Bytes Per Sec' then round(value/(1024*1024),1) else 0 end)
 ,sum(case when metric_name = 'Host CPU Utilization (%)'           then trunc(value,1)             else 0 end)
 ,sum(case when metric_name = 'User Transaction Per Sec'           then value                      else 0 end)
 into
:snapshot
 ,:resp_time
 ,:executions
 ,:parses
 ,:open_cursors
 ,:commits
 ,:read_mb
 ,:write_mb
 ,:host_cpu
 ,:transactions
 from v$sysmetric
 where intsize_csec < (:interval_*100*2)
 and metric_name in
 (
--'Current Logons Count'
'SQL Service Response Time'
 ,'Executions Per Sec'
 ,'Total Parse Count Per Sec'
 ,'Open Cursors Per Sec'
 ,'User Commits Per Sec'
 ,'Physical Read Total Bytes Per Sec'
 ,'Physical Write Total Bytes Per Sec'
 ,'Host CPU Utilization (%)'
 ,'User Transaction Per Sec'
 )
 group by to_char(begin_time, 'hh24:mi:ss');
END;
/

COLUMN snapshot     FOR A8         HEADING "Time"
COLUMN actsess      FOR 990        HEADING "ActSess"
COLUMN resp_time    FOR 990.999999 HEADING "RespTimeMilli"
COLUMN executions   FOR 999,990.9  HEADING "Exec/s"
COLUMN parses       FOR 999,990.9  HEADING "Parses/s"
COLUMN open_cursors FOR 999,990.9  HEADING "OpenCur/s"
COLUMN commits      FOR 999,990.9  HEADING "Commit/s"
COLUMN read_mb      FOR 990.9      HEADING "ReadMb/s"
COLUMN write_mb     FOR 990.9      HEADING "WriteMb/s"
COLUMN host_cpu     FOR 990.9      HEADING "HostCPU(%)"
COLUMN transactions FOR 999,990.9  HEADING "Trans/s"

SELECT
:snapshot     snapshot
 ,:host_cpu     host_cpu
 ,:actsess      actsess
 ,:resp_time    resp_time
 ,:executions   executions
 ,:parses       parses
 ,:open_cursors open_cursors
 ,:commits      commits
 ,:read_mb      read_mb
 ,:write_mb     write_mb
 ,:transactions transactions
FROM dual;
LINEAS_CODIGO

cat > sysm.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

set serveroutput on
set echo off
set term off
set feed off

variable iterations_ number;
begin
 :iterations_ := to_number('&1');
end;
/

spool sysm.script.sql

declare
 j number;
begin
 dbms_output.put_line('set newpage none');
 dbms_output.put_line('set lines 170');
 dbms_output.put_line('set pages 20');
 dbms_output.put_line('set echo off');
 dbms_output.put_line('set feedback off');
 dbms_output.put_line('set recsep off');

 j := 0;
 for i in 1..:iterations_
 loop
  if j = 0
  then
 dbms_output.put_line('set head on');
  else
 dbms_output.put_line('set head off');
  end if;
  dbms_output.put_line('@@sysm.x.sql');
  if i < :iterations_
  then
 dbms_output.put_line('!sleep 15');
  end if;
  j := j + 1;
  if j = 10
  then
j := 0;
  end if;
 end loop;
end;
/

spool off;

set term on
@sysm.script.sql
LINEAS_CODIGO

cat > ses.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

set lines 200
set pages 1000
set heading on
set feedback on


set term off
column oracle_version new_value oracle_version_
column l_92 new_value l_92_
column e_92 new_value e_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column l_111 new_value l_111_
column ge_111 new_value ge_111_
column l_112 new_value l_112_
column ge_112 new_value ge_112_
column ge_92_l_112 new_value ge_92_l_112_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ < 9.2 then '' else '--' end l_92 from v$instance;
select case when &oracle_version_ = 9.2 then '' else '--' end e_92 from v$instance;
select case when &oracle_version_ > 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ < 10.1 then '' else '--' end l_101 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ < 11.1 then '' else '--' end l_111 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 9.2 AND &oracle_version_ < 11.2 then '' else '--' end ge_92_l_112 from v$instance;

set term on


col identificador for a20
col username for a20
col machine for a30 trunc
col program for a40 trunc
col sql_id for a30

select
&l_92_ sid||','||serial# identificador
&ge_92_ sid||','||serial#||',@'||inst_id identificador
 ,status
 ,username
 ,machine
 ,program
&l_101_ ,sql_address||'-'||sql_hash_value sql_id
&ge_101_ ,sql_id sql_id
&l_92_  FROM v$session
&ge_92_ FROM gv$session
where username is not null
order by username
,machine
,program
,sql_id
;

LINEAS_CODIGO

cat > ashtop.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

--------------------------------------------------------------------------------
--@ashtop sql_id session_type='FOREGROUND' sysdate-5*(1/24/60) sysdate
--@ashtop sql_id session_type='FOREGROUND' to_date('20180627_0800','yyyymmdd_hh24mi') to_date('20180627_0810','yyyymmdd_hh24mi')
--
--@ashtop sid,username,program session_type='FOREGROUND' sysdate-5*(1/24/60) sysdate
--@ashtop sid,username,program session_type='FOREGROUND' to_date('20180627_0800','yyyymmdd_hh24mi')  to_date('20180627_0810','yyyymmdd_hh24mi')
--
--@ashtop sql_id sid=9225 to_date('20180627_0800','yyyymmdd_hh24mi')  to_date('20180627_0810','yyyymmdd_hh24mi')
--
-- File name:   ashtop.sql v1.1
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--
-- Usage:
--     @ashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @ashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--
-- Other:
--     This script uses only the in-memory v$ACTIVE_SESSION_HISTORY, use
--     @dashtop.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--
--------------------------------------------------------------------------------
COL "%This" FOR A7
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text      FOR A30 word_wrap
COL p2text      FOR A30 word_wrap
COL p3text      FOR A30 word_wrap
COL p1hex       FOR A17
COL p2hex       FOR A17
COL p3hex       FOR A17
COL AAS         FOR 9999.9
COL totalseconds HEAD "Total|Seconds" FOR 99999999
COL event       FOR A40 WORD_WRAP
COL event2      FOR A40 WORD_WRAP
COL username    FOR A20 wrap
COL obj         FOR A30
COL objt        FOR A50
COL sql_opname  FOR A20
COL top_level_call_name FOR A30
COL wait_class  FOR A15

SELECT * FROM (
WITH bclass AS (SELECT class, ROWNUM r from v$waitstat)
SELECT /*+ LEADING(a) USE_HASH(u) */
COUNT(*)                                                     totalseconds
  , ROUND(COUNT(*) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AAS
  , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ')||' |' "%This"
  , &1
  , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
  , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
--    , MAX(sql_exec_id) - MIN(sql_exec_id)
  , COUNT(DISTINCT sql_exec_start||':'||sql_exec_id) dist_sqlexec_seen
FROM
(SELECT
 a.*
   , session_id sid
   , session_serial# serial
   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
   , NVL(event, session_state)||
CASE WHEN a.event IN ('buffer busy waits', 'gc buffer busy', 'gc buffer busy acquire', 'gc buffer busy release')
--THEN ' ['||CASE WHEN (SELECT class FROM bclass WHERE r = a.p3) IS NULL THEN ||']' ELSE null END event2 -- event is NULL in ASH if the session is not waiting (session_state = ON CPU)
THEN ' ['||CASE WHEN a.p3 <= (SELECT MAX(r) FROM bclass)
   THEN (SELECT class FROM bclass WHERE r = a.p3)
   ELSE (SELECT DECODE(MOD(BITAND(a.p3,TO_NUMBER('FFFF','XXXX')) - 17,2),0,'undo header',1,'undo data', 'error') FROM dual)
   END  ||']'
ELSE null END event2 -- event is NULL in ASH if the session is not waiting (session_state = ON CPU)
FROM v$active_session_history a) a
  , dba_users u
  , (SELECT
 object_id,data_object_id,owner,object_name,subobject_name,object_type
   , owner||'.'||object_name obj
   , owner||'.'||object_name||' ['||object_type||']' objt
 FROM dba_objects) o
WHERE
a.user_id = u.user_id
AND a.current_obj# = o.object_id(+)
AND &2
AND sample_time BETWEEN &3 AND &4
GROUP BY
&1
ORDER BY
TotalSeconds DESC
   , &1
)
WHERE
ROWNUM <= 20
;
LINEAS_CODIGO

cat > dashtop.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

--Para ver distribucion de ejecucion de una sentencia, no olvidar descomentar la columna correspondiente
--@dashtop sample_time,sql_opname,sql_id,event "sql_id='7u3j3x0fahyaw'" "to_date('20180804_0000','yyyymmdd_hh24mi')" "to_date('20180804_1200','yyyymmdd_hh24mi')"
--
--Sesiones en espera por un evento en especifico
--@dashtop session_id,username,program,sql_id "event='enq: TX - index contention'" "to_date('20180804_0930','yyyymmdd_hh24mi')" "to_date('20180804_1000','yyyymmdd_hh24mi')"
--
--
--------------------------------------------------------------------------------
--
-- File name:   dashtop.sql
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--
-- Usage:
--     @dashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @dashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--
-- Other:
--     This script uses only the AWR's DBA_HIST_ACTIVE_SESS_HISTORY, use
--     @dashtop.sql for accessiong the v$ ASH view
--
--------------------------------------------------------------------------------
COL "%This" FOR A6
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text FOR A20 word_wrap
COL p2text FOR A20 word_wrap
COL p3text FOR A20 word_wrap
COL p1hex  FOR A17
COL p2hex  FOR A17
COL p3hex  FOR A17
COL event  FOR A30
COL sql_opname FOR A15
COL top_level_call_name FOR A25
col SAMPLE_TIME for a25

SELECT * FROM (
SELECT /*+ LEADING(a) USE_HASH(u) */
LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
  , &1
  , 10 * COUNT(*)                                                      "TotalSeconds"
--      , 10 * SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
--      , 10 * SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
--      , 10 * SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
--      , 10 * SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
--      , 10 * SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
--      , 10 * SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
--      , 10 * SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
--      , 10 * SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
--      , 10 * SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
--      , 10 * SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
--      , 10 * SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
--      , 10 * SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
--      , 10 * SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
--      , 10 * SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
--  , COUNT(DISTINCT sql_exec_start||':'||sql_exec_id) dist_sqlexec_seen
  , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
  , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
FROM
(SELECT
 a.*
   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
   , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
FROM dba_hist_active_sess_history a) a
  , dba_users u
WHERE
a.user_id = u.user_id
AND &2
AND sample_time BETWEEN &3 AND &4
AND snap_id IN (SELECT snap_id FROM dba_hist_snapshot WHERE sample_time BETWEEN &3 AND &4) -- for partition pruning
GROUP BY
&1
ORDER BY
"TotalSeconds" DESC
   , &1
)
WHERE
ROWNUM <= 20
;
LINEAS_CODIGO

cat > tiempo_rollback.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

-------------------------------------------------------------------------------
--- Script: calculate_rollback_time.sql
--- Copyright: (c)  Daniel Alberto Enriquez García
--- Author: Daniel Alberto Enriquez García
---         and main query by Juan Manuel Cruz Lopez
---
---    @calculate_rollback_time.sql  <SID>
---
---   Execution example:
---    @calculate_rollback_time.sql  1868
---
--- Description:  Solo compis chiditos
-------------------------------------------------------------------------------
set serveroutput on
set feedback off
set lines 2000
prompt
prompt Script to get rolling back session info
prompt

set term off;
variable SID_ number;
exec :SID_:='&1';
set term on
--        Nombre:
DECLARE
 cursor tx is
SELECT s.inst_id,s.sid,s.serial#,s.username,
   t.used_ublk,
   t.used_urec,
   rs.segment_name ,
   ROUND(r.rssize / (1024*1024)),
   t.start_date,
   to_char(cast(numtodsinterval(ROUND((sysdate-t.start_date)*24*60*60),'SECOND') as interval day(2) to second(0))),
DECODE (s.command, 0, 'NULL', 1, 'CRE TAB', 2, 'INSERT', 3, 'SELECT', 4, 'CRE CLUSTER', 5, 'ALT CLUSTER', 6, 'UPDATE', 7, 'DELETE', 8, 'DRP CLUSTER', 9, 'CRE INDEX',
  10, 'DROP INDEX', 11, 'ALT INDEX', 12, 'DROP TABLE', 13, 'CRE SEQ', 14, 'ALT SEQ', 15, 'ALT TABLE', 16, 'DROP SEQ', 17, 'GRANT', 18, 'REVOKE', 19, 'CRE SYN',
  20, 'DROP SYN', 21, 'CRE VIEW', 22, 'DROP VIEW', 23, 'VAL INDEX', 24, 'CRE PROC', 25, 'ALT PROC', 26, 'LOCK TABLE', 28, 'RENAME', 29, 'COMMENT',
  30, 'AUDIT', 31, 'NOAUDIT', 32, 'CRE DBLINK', 33, 'DROP DBLINK', 34, 'CRE DB', 35, 'ALTER DB', 36, 'CRE RBS', 37, 'ALT RBS', 38, 'DROP RBS', 39, 'CRE TBLSPC',
  40, 'ALT TBLSPC', 41, 'DROP TBLSPC', 42, 'ALT SESSION', 43, 'ALT USER', 44, 'COMMIT', 45, 'ROLLBACK', 46, 'SAVEPOINT', 47, 'PL/SQL EXEC', 48, 'SET XACTN',
  49, 'SWITCH LOG', 50, 'EXPLAIN', 51, 'CRE USER', 52, 'CRE ROLE', 53, 'DROP USER', 54, 'DROP ROLE', 55, 'SET ROLE', 56, 'CRE SCHEMA', 57, 'CRE CTLFILE',
  58, 'ALTER TRACING', 59, 'CRE TRIGGER', 60, 'ALT TRIGGER', 61, 'DRP TRIGGER', 62, 'ANALYZE TAB', 63, 'ANALYZE IX', 64, 'ANALYZE CLUS', 65, 'CRE PROFILE',
  66, 'DRP PROFILE', 67, 'ALT PROFILE', 68, 'DRP PROC', 69, 'DRP PROC', 70, 'ALT RESOURCE', 71, 'CRE SNPLOG', 72, 'ALT SNPLOG', 73, 'DROP SNPLOG',
  74, 'CREATE SNAP', 75, 'ALT SNAP', 76, 'DROP SNAP', 79, 'ALTER ROLE', 79, 'ALTER ROLE', 85, 'TRUNC TAB', 86, 'TRUNC CLUST', 88, 'ALT VIEW',
  91, 'CRE FUNC', 92, 'ALT FUNC', 93, 'DROP FUNC', 94, 'CRE PKG', 95, 'ALT PKG', 96, 'DROP PKG', 97, 'CRE PKG BODY', 98, 'ALT PKG BODY',
  99, 'DRP PKG BODY',TO_CHAR (s.command)
)||'('||s.sql_address||' '||s.sql_hash_value||')'
FROM   gv$transaction t,
   gv$session s,
   gv$rollstat r,
   dba_rollback_segs rs
WHERE  s.inst_id = t.inst_id
 AND s.inst_id = r.inst_id
 AND s.saddr = t.ses_addr
 AND t.used_ublk > 0
AND    t.xidusn = r.usn
AND    rs.segment_id = t.xidusn
and    s.sid=:SID_
ORDER BY  s.inst_id
;
 xinstid number;
 xsid       number;
 xserial  number;
 user_name  varchar2(50);
 used_ublk1 number;
 used_ublk2 number;
 undorecord number;
 segmentname varchar2(100);
 segsize   number;
 startdate date;
 elapsedtime varchar2(15);
 commande   varchar2(4000);
 remaining_time varchar2(100);
 xsqlid   varchar2(100);
 xsql_text varchar2(4000);
xprogram varchar2(4000);
xosuser   varchar2(100);

begin

open tx;
FETCH tx into xinstid,xsid, xserial, user_name, used_ublk1, undorecord ,segmentname, segsize,startdate,elapsedtime ,commande;
CLOSE tx;

sys.dbms_lock.sleep(10);

open tx;
FETCH tx into xinstid,xsid, xserial, user_name, used_ublk2, undorecord ,segmentname, segsize,startdate,elapsedtime ,commande;
CLOSE tx;

select
to_char(cast(numtodsinterval(used_ublk2/(used_ublk1 - used_ublk2)/6/60/24,'DAY') as interval day(2) to second(0)))
into remaining_time
from dual;

/*
select q.sql_id, replace(q.SQL_TEXT,chr(0)), program, OSUSER
into  xsqlid,  xsql_text, xprogram , xosuser
from v$session s,v$sql q
where s.PREV_SQL_ADDR = q.address
and s.PREV_HASH_VALUE = q.hash_value
and s.sid = xsid
and s.serial#=xserial;
*/
select '', '', program, OSUSER
into  xsqlid,  xsql_text, xprogram , xosuser
from v$session s
where s.sid = xsid
and s.serial#=xserial;

 if used_ublk2 < used_ublk1
 then
   sys.dbms_output.put_line
   (
 'NODE_ID:               '||to_char(xinstid)||chr(10)||
 'SID:                   '||to_char(xsid)||chr(10)||
 'SERIAL:                '||to_char(xserial)||chr(10)||
 'USERNAME:              '||user_name||chr(10)||
 'USED BLOCKS:           '||to_char(used_ublk2)||chr(10)||
 'SEGMENT NAME:          '||segmentname||chr(10)||
 'SEGMENT SIZE:          '||to_char(segsize)||chr(10)||
 'START_DATE:            '||to_char(startdate,'DD-MM-YYYY HH24:MI:SS')||chr(10)||
 'ELAPSED TIME:          '||to_char(elapsedtime)||chr(10)||
 'REMAINING TIME:        '||remaining_time||chr(10)||
 'ESTIMATED FINISH TIME: '||to_char(sysdate + used_ublk2 / (used_ublk1 - used_ublk2) / 6 / 60 / 24,'DD-MON-YYYY HH24:MI:SS'
 )
   );
/*
   sys.dbms_output.put_line
   (
 'COMMAND:               '||commande||chr(10)||
 'OSUSER:                '||xosuser||chr(10)||
 'PROGRAM:               '||xprogram||chr(10)||
 'SQL_ID:                '||xsqlid||chr(10)||
 'SQL_TEXT:              '||xsql_text
   );
*/
 end if;
end;
/
prompt
prompt
LINEAS_CODIGO

cat > alert.sql <<'LINEAS_CODIGO'
SET LINES 200
SET PAGES 10000
SET VERIFY OFF

CLEAR BREAKS
CLEAR COLUMNS

set term off

column oracle_version new_value oracle_version_
column ge_111 new_value ge_111_
column lt_111 new_value lt_111_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_  < 11.1 then '' else '--' end lt_111 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;

set term on

CLEAR BREAKS
CLEAR COLUMNS

COL alert FOR A100

select
&lt_111_  (select value from v$parameter where name='background_dump_dest')
&lt_111_  ||'/alert_'||(select instance_name from v$instance)||'.log'
&ge_111_  (select value from v$parameter where name='diagnostic_dest')
&ge_111_  ||'/diag/rdbms/'
&ge_111_  ||(select value from v$parameter where name='db_unique_name')
&ge_111_  ||'/'
&ge_111_  ||(select instance_name from v$instance)
&ge_111_  ||'/trace'
&ge_111_  ||'/alert_'||(select instance_name from v$instance)||'.log'
alert
from dual;

CLEAR BREAKS
CLEAR COLUMNS
LINEAS_CODIGO


cat > creados.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

set lines 200
set pages 1000
set feed on
col owner for a20
col object_name for a30
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

SELECT owner, object_name, object_type, created, last_ddl_time
FROM  dba_objects
WHERE (created      > (SYSDATE - &minutos_antes*(1/24/60))
 OR last_ddl_time > (SYSDATE - &&minutos_antes*(1/24/60))
  )
;
LINEAS_CODIGO


cat > xplan.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 180
SET PAGES 1000

PROMPT
PROMPT WHERE (1): sql_id='<sql_id>'       AND child_number=<child_number>
PROMPT ---------- hash_value=<hash_value> AND child_number=<child_number>

COLUMN id FORMAT 999
COLUMN name FORMAT A40 WORD_WRAPPED
COLUMN operation FORMAT a40
COLUMN cost FORMAT A8
COLUMN cpu_cost FORMAT A8
COLUMN bytes FORMAT A8
COLUMN io_cost FORMAT A8
COLUMN rows_ heading "ROWS" FORMAT A8

clear breaks
break on sql_id on child_number on hash_value skip 2
undefine 1

SELECT
 p.sql_id
,p.hash_value
,p.child_number
,p.id
,LPAD(' ',p.depth,' ')||p.operation||' '||p.options operation
,CASE WHEN p.object_name IS NULL THEN '' ELSE p.object_owner||'.'||p.object_name END name
,CASE WHEN p.cost < POWER(1024,1) THEN                      p.cost||''
WHEN p.cost < POWER(1024,2) THEN ROUND(p.cost/POWER(1024,1))||'K'
WHEN p.cost < POWER(1024,3) THEN ROUND(p.cost/POWER(1024,2))||'M'
WHEN p.cost < POWER(1024,4) THEN ROUND(p.cost/POWER(1024,3))||'G'
WHEN p.cost < POWER(1024,5) THEN ROUND(p.cost/POWER(1024,4))||'T'
 END cost
,CASE WHEN p.cardinality < POWER(1024,1) THEN                p.cardinality||''
WHEN p.cardinality < POWER(1024,2) THEN ROUND(p.cardinality/POWER(1024,1))||'K'
WHEN p.cardinality < POWER(1024,3) THEN ROUND(p.cardinality/POWER(1024,2))||'M'
WHEN p.cardinality < POWER(1024,4) THEN ROUND(p.cardinality/POWER(1024,3))||'G'
WHEN p.cardinality < POWER(1024,5) THEN ROUND(p.cardinality/POWER(1024,4))||'T'
 END rows_
,CASE WHEN p.bytes < POWER(1024,1) THEN                      p.bytes||''
WHEN p.bytes < POWER(1024,2) THEN ROUND(p.bytes/POWER(1024,1))||'K'
WHEN p.bytes < POWER(1024,3) THEN ROUND(p.bytes/POWER(1024,2))||'M'
WHEN p.bytes < POWER(1024,4) THEN ROUND(p.bytes/POWER(1024,3))||'G'
WHEN p.bytes < POWER(1024,5) THEN ROUND(p.bytes/POWER(1024,4))||'T'
 END bytes
,CASE WHEN p.cpu_cost < POWER(1024,1) THEN                      p.cpu_cost||''
WHEN p.cpu_cost < POWER(1024,2) THEN ROUND(p.cpu_cost/POWER(1024,1))||'K'
WHEN p.cpu_cost < POWER(1024,3) THEN ROUND(p.cpu_cost/POWER(1024,2))||'M'
WHEN p.cpu_cost < POWER(1024,4) THEN ROUND(p.cpu_cost/POWER(1024,3))||'G'
WHEN p.cpu_cost < POWER(1024,5) THEN ROUND(p.cpu_cost/POWER(1024,4))||'T'
 END cpu_cost
,CASE WHEN p.io_cost < POWER(1024,1) THEN                      p.io_cost||''
WHEN p.io_cost < POWER(1024,2) THEN ROUND(p.io_cost/POWER(1024,1))||'K'
WHEN p.io_cost < POWER(1024,3) THEN ROUND(p.io_cost/POWER(1024,2))||'M'
WHEN p.io_cost < POWER(1024,4) THEN ROUND(p.io_cost/POWER(1024,3))||'G'
WHEN p.io_cost < POWER(1024,5) THEN ROUND(p.io_cost/POWER(1024,4))||'T'
 END io_cost
FROM
 v$sql_plan p
WHERE &1
ORDER BY sql_id, child_number, id
;
LINEAS_CODIGO

cat > allxplan.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 180
SET PAGES 1000

PROMPT
PROMPT WHERE (1): sql_id='<sql_id>'
PROMPT ---------- hash_value=<hash_value>

COLUMN id FORMAT 999
COLUMN name FORMAT A40 WORD_WRAPPED
COLUMN operation FORMAT a40
COLUMN cost FORMAT A8
COLUMN cpu_cost FORMAT A8
COLUMN bytes FORMAT A8
COLUMN io_cost FORMAT A8

clear breaks
break on sql_id on child_number on plan_hash_value skip 2
undefine 1

SELECT
 p.sql_id
,p.plan_hash_value
,p.child_number
,p.id
,LPAD(' ',p.depth,' ')||p.operation||' '||p.options operation
,CASE WHEN p.object_name IS NULL THEN '' ELSE p.object_owner||'.'||p.object_name END name
,CASE WHEN p.cost < POWER(1024,1) THEN                      p.cost||''
WHEN p.cost < POWER(1024,2) THEN ROUND(p.cost/POWER(1024,1))||'K'
WHEN p.cost < POWER(1024,3) THEN ROUND(p.cost/POWER(1024,2))||'M'
WHEN p.cost < POWER(1024,4) THEN ROUND(p.cost/POWER(1024,3))||'G'
WHEN p.cost < POWER(1024,5) THEN ROUND(p.cost/POWER(1024,4))||'T'
 END cost
FROM
 v$sql_plan p
WHERE &1
and p.id = 0
ORDER BY sql_id, child_number, id
;

LINEAS_CODIGO

cat > undefine.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

UNDEFINE 1
UNDEFINE 2
UNDEFINE 3
UNDEFINE 4
UNDEFINE 5
UNDEFINE 6
UNDEFINE 7
UNDEFINE 8
UNDEFINE 9
UNDEFINE sql_id
UNDEFINE identifier
UNDEFINE username
UNDEFINE osuser
UNDEFINE machine
UNDEFINE sid
UNDEFINE spid
UNDEFINE tablespace_name
UNDEFINE columns_
UNDEFINE where_
clear breaks
LINEAS_CODIGO

cat > sqlx.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 150
SET PAGES 1000
COLUMN cost_order NOPRINT
COLUMN optimizer FORMAT A15
COLUMN et_day2sec FORMAT A12

SELECT
 s.sid
,s.serial#
,s.sql_id
,s.sql_child_number child_number
,p.optimizer
,CASE WHEN p.cost < POWER(1024,1) THEN                      p.cost||''
WHEN p.cost < POWER(1024,2) THEN ROUND(p.cost/POWER(1024,1))||'K'
WHEN p.cost < POWER(1024,3) THEN ROUND(p.cost/POWER(1024,2))||'M'
WHEN p.cost < POWER(1024,4) THEN ROUND(p.cost/POWER(1024,3))||'G'
WHEN p.cost < POWER(1024,5) THEN ROUND(p.cost/POWER(1024,4))||'T'
 END cost
,p.cost cost_order
,TO_CHAR(CAST(NUMTODSINTERVAL(TRUNC(q.elapsed_time/(1e6)),'SECOND') AS INTERVAL DAY(2) TO SECOND(0)) ) ET_DAY2SEC
,CASE WHEN FLOOR(elapsed_time/1e6) < 1 THEN TRUNC(q.elapsed_time/(1e3))
 ELSE NULL
 END et_milli
FROM
 v$session  s
,v$sql      q
,v$sql_plan p
WHERE
q.sql_id       = s.sql_id
AND q.child_number = s.sql_child_number
AND p.sql_id       = s.sql_id
AND p.child_number = s.sql_child_number
AND p.id           = 0
ORDER BY cost_order
;
LINEAS_CODIGO


cat > sga.sql <<'LINEAS_CODIGO'
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
LINEAS_CODIGO


cat > topa.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

--------------------------------------------------------------------------------
--
-- Archivo  :   topa.sql
-- Proposito:   Despliega el Top SQL, Top de Sesiones y Eventos de Espera
--
-- Autor:      Juan Manuel Cruz Lopez
-- Copyright:   (c)
--
-- Uso:
--     @topa.sql <fromtime> <totime>
--
-- Ejemplo:
--     Para ver la actividad de la ultima hora:
--     @topa sysdate-1/24 sysdate
--     Para ver algun periodo en especifico
--     @topa to_date('yyyymmdd_hh24mi','20180703_1000') to_date('yyyymmdd_hh24mi','20180703_1010')
-- Importante:
-- El script usa las vistas ASH, por lo que es requerida la licencia sobre diagnostic+tuning pack
--
--------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT

clear breaks
set term off
column oracle_version new_value oracle_version_
column l_92 new_value l_92_
column e_92 new_value e_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column l_111 new_value l_111_
column ge_111 new_value ge_111_
column l_112 new_value l_112_
column ge_112 new_value ge_112_
column ge_92_l_112 new_value ge_92_l_112_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ < 9.2 then '' else '--' end l_92 from v$instance;
select case when &oracle_version_ = 9.2 then '' else '--' end e_92 from v$instance;
select case when &oracle_version_ > 9.2 then '' else '--' end ge_92 from v$instance;
select case when &oracle_version_ < 10.1 then '' else '--' end l_101 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ < 11.1 then '' else '--' end l_111 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 9.2 AND &oracle_version_ < 11.2 then '' else '--' end ge_92_l_112 from v$instance;

set term on
set verify off

set pages 1000
set lines 220
set heading on
set feedback on
col "%This"  for a5
col "AAS"  for 9,990.0
col "User"   for a15
col "Sid"    for 999999
col "Program"  for a50 trunc
col "Secs"   for 999990
col "Wait Class"   for a20 trunc
col "Event"   for a50 trunc
col "CPU" for 9990
col "UsIO" for 9990
col "SyIO" for 9990
col "Comm" for 9990
col "App"  for 9990
col "Conc" for 9990
col "Conf" for 9990
col "Que"  for 9990
col "Net"  for 9990
col "Adm"  for 9990
col "Clus" for 9990
col "Sche" for 9990
col "Oth"  for 9990
col "Sql Id" for a13
col "TimesX" for 9990
col "Cmd Type" for a11
col "UsIO Event" for a23 trunc
col "Full Obj Name" for a60

PROMPT
PROMPT
PROMPT ========== [ Top Events ] ==========
PROMPT

select *
from (
select
 lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ') "%This"
,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
,wait_class "Wait Class"
,event "Event"
--,count(*) "Secs"
from v$active_session_history
where
sample_time between &1 and &2
group by wait_class, event
order by "DBTime" DESC
     )
where rownum <= 20
;

PROMPT
PROMPT
PROMPT ========== [ Top Sql ] ==========
PROMPT

select
 case when sqla.command_type =  1 then 'CREATE TAB'
      when sqla.command_type =  2 then 'INSERT'
      when sqla.command_type =  3 then 'SELECT'
      when sqla.command_type =  6 then 'UPDATE'
      when sqla.command_type =  7 then 'DELETE'
      when sqla.command_type =  9 then 'CREATE IDX'
      when sqla.command_type = 11 then 'ALTER IDX'
      when sqla.command_type = 15 then 'ALTER TAB'
      when sqla.command_type = 26 then 'LOCK TAB'
      when sqla.command_type = 45 then 'ROLLBACK'
      when sqla.command_type = 47 then 'PLSQL EXEC'
      when sqla.command_type = 62 then 'ANALYZE TAB'
      when sqla.command_type = 63 then 'ANALYZE IDX'
      when sqla.command_type = 85 then 'TRUNC TAB'
      when sqla.command_type = 189 then 'MERGE'
      else 'UNKNOWN' end "Cmd Type"
,fash.*
from
(
   select *
   from (
      select
       lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ')         "%This"
      ,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
      ,ash.sql_id "Sql Id"
&ge_111_      ,count(distinct ash.sql_exec_start) "TimesX"
      --,count(*)                                                                "Secs"
      ,round(count(case when ash.wait_class is null            then 1 else null end)*100/count(*)) "CPU"
      ,round(count(case when ash.wait_class = 'User I/O'       then 1 else null end)*100/count(*)) "UsIO"
      ,round(count(case when ash.wait_class = 'System I/O'     then 1 else null end)*100/count(*)) "SyIO"
      ,round(count(case when ash.wait_class = 'Commit'         then 1 else null end)*100/count(*)) "Comm"
      ,round(count(case when ash.wait_class = 'Application'    then 1 else null end)*100/count(*)) "App"
      ,round(count(case when ash.wait_class = 'Concurrency'    then 1 else null end)*100/count(*)) "Conc"
      ,round(count(case when ash.wait_class = 'Configuration'  then 1 else null end)*100/count(*)) "Conf"
      ,round(count(case when ash.wait_class = 'Queueing'       then 1 else null end)*100/count(*)) "Que"
      ,round(count(case when ash.wait_class = 'Network'        then 1 else null end)*100/count(*)) "Net"
      ,round(count(case when ash.wait_class = 'Administrative' then 1 else null end)*100/count(*)) "Adm"
      ,round(count(case when ash.wait_class = 'Cluster'        then 1 else null end)*100/count(*)) "Clus"
      ,round(count(case when ash.wait_class = 'Scheduler'      then 1 else null end)*100/count(*)) "Sche"
      ,round(count(case when ash.wait_class = 'Other'          then 1 else null end)*100/count(*)) "Oth"
      from v$active_session_history ash
      where ash.sample_time between &1 and &2
      group by ash.sql_id --,ash.sql_opname
      order by "DBTime" desc
        )
   where rownum <= 20
) fash
,v$sqlarea sqla
where sqla.sql_id(+) = fash."Sql Id"
order by "DBTime" desc
;

PROMPT
PROMPT
PROMPT ========== [ Top Sessions ] ==========
PROMPT

select
 fash."%This"
,fash."DBTime"
,fash."Sid"
,dbau.username||':'||fash."Program" "Program"
,fash."CPU"
,fash."UsIO"
,fash."SyIO"
,fash."Comm"
,fash."App"
,fash."Conc"
,fash."Conf"
,fash."Que"
,fash."Net"
,fash."Adm"
,fash."Clus"
,fash."Sche"
,fash."Oth"
from
(
   select *
   from (
      select
       lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ')         "%This"
      ,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
      ,ash.session_id "Sid"
      ,ash.user_id
      ,replace(replace(replace(ash.program,' ','_'),'(',''),')','') "Program"
      --,count(*)                                                                "Secs"
      ,round(count(case when ash.wait_class is null            then 1 else null end)*100/count(*)) "CPU"
      ,round(count(case when ash.wait_class = 'User I/O'       then 1 else null end)*100/count(*)) "UsIO"
      ,round(count(case when ash.wait_class = 'System I/O'     then 1 else null end)*100/count(*)) "SyIO"
      ,round(count(case when ash.wait_class = 'Commit'         then 1 else null end)*100/count(*)) "Comm"
      ,round(count(case when ash.wait_class = 'Application'    then 1 else null end)*100/count(*)) "App"
      ,round(count(case when ash.wait_class = 'Concurrency'    then 1 else null end)*100/count(*)) "Conc"
      ,round(count(case when ash.wait_class = 'Configuration'  then 1 else null end)*100/count(*)) "Conf"
      ,round(count(case when ash.wait_class = 'Queueing'       then 1 else null end)*100/count(*)) "Que"
      ,round(count(case when ash.wait_class = 'Network'        then 1 else null end)*100/count(*)) "Net"
      ,round(count(case when ash.wait_class = 'Administrative' then 1 else null end)*100/count(*)) "Adm"
      ,round(count(case when ash.wait_class = 'Cluster'        then 1 else null end)*100/count(*)) "Clus"
      ,round(count(case when ash.wait_class = 'Scheduler'      then 1 else null end)*100/count(*)) "Sche"
      ,round(count(case when ash.wait_class = 'Other'          then 1 else null end)*100/count(*)) "Oth"
      from
       v$active_session_history ash
      where ash.sample_time between &1 and &2
      group by
       ash.session_id
      ,ash.user_id
      ,ash.program
      order by "DBTime" desc
        )
   where rownum <= 20
) fash
,dba_users dbau
where
  dbau.user_id = fash.user_id
order by "DBTime" desc
;

PROMPT
PROMPT
PROMPT ========== [ Top Segments Read ] ==========
PROMPT

select
 case when sqla.command_type =   1 then 'CREATE TAB'
      when sqla.command_type =   2 then 'INSERT'
      when sqla.command_type =   3 then 'SELECT'
      when sqla.command_type =   6 then 'UPDATE'
      when sqla.command_type =   7 then 'DELETE'
      when sqla.command_type =   9 then 'CREATE IDX'
      when sqla.command_type =  11 then 'ALTER IDX'
      when sqla.command_type =  15 then 'ALTER TAB'
      when sqla.command_type =  26 then 'LOCK TAB'
      when sqla.command_type =  45 then 'ROLLBACK'
      when sqla.command_type =  47 then 'PLSQL EXEC'
      when sqla.command_type =  62 then 'ANALYZE TAB'
      when sqla.command_type =  63 then 'ANALYZE IDX'
      when sqla.command_type =  85 then 'TRUNC TAB'
      when sqla.command_type = 189 then 'MERGE'
      else 'UNKNOWN' end "Cmd Type"
,fash.sql_id "Sql Id"
,fash."%This"
,fash."DBTime"
,fash."UsIO Event"
,substr(dbao.object_type,1,5)||':'||dbao.owner||'.'||dbao.object_name "Full Obj Name"
from (
   select *
   from (
   select
    ash.sql_id
   ,lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ') "%This"
   ,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
   ,ash.event "UsIO Event"
   ,ash.current_obj#
   from v$active_session_history ash
   where
   ash.sample_time between &1 and &2
   and (ash.event like 'db file s%' or ash.event like 'direct p%')
   group by ash.sql_id,ash.wait_class, ash.event, ash.current_obj#
   order by "DBTime" desc
        )
   where rownum <= 20
     ) fash
,dba_objects dbao
,v$sqlarea sqla
where sqla.sql_id(+) = fash.sql_id
  and dbao.object_id(+) = fash.current_obj#
order by "DBTime" desc
;

PROMPT
PROMPT
PROMPT ========== [ Top Activity ] ==========
PROMPT

col "Time" for a8

select *
from (
select
 count(*)                                                                "Secs"
,to_char(ash.sample_time,'hh24:mi') "Time"
--,round(count(case when ash.wait_class is null            then 1 else null end)*100/count(*)) "Idle"
,trunc(sum(case when ash.wait_class = 'User I/O'       then 1 else 0 end)/60,3) "UsIO"
,trunc(sum(case when ash.wait_class = 'System I/O'     then 1 else 0 end)/60,3) "SyIO"
,trunc(sum(case when ash.wait_class = 'Commit'         then 1 else 0 end)/60,3) "Comm"
,trunc(sum(case when ash.wait_class = 'Application'    then 1 else 0 end)/60,3) "App"
,trunc(sum(case when ash.wait_class = 'Concurrency'    then 1 else 0 end)/60,3) "Conc"
,trunc(sum(case when ash.wait_class = 'Configuration'  then 1 else 0 end)/60,3) "Conf"
,trunc(sum(case when ash.wait_class = 'Queueing'       then 1 else 0 end)/60,3) "Que"
,trunc(sum(case when ash.wait_class = 'Network'        then 1 else 0 end)/60,3) "Net"
,trunc(sum(case when ash.wait_class = 'Administrative' then 1 else 0 end)/60,3) "Adm"
,trunc(sum(case when ash.wait_class = 'Cluster'        then 1 else 0 end)/60,3) "Clus"
,trunc(sum(case when ash.wait_class = 'Scheduler'      then 1 else 0 end)/60,3) "Sche"
,trunc(sum(case when ash.wait_class = 'Other'          then 1 else 0 end)/60,3) "Oth"
,trunc(sum(case when ash.wait_class is null            then 1 else 0 end)/60,3) "Cpu"
from
 v$active_session_history ash
where ash.sample_time between sysdate-1/24*2 and sysdate
group by
 to_char(ash.sample_time,'hh24:mi')
order by "Time"
     )
;


PROMPT
PROMPT
PROMPT ========== [ System Metric History ] ==========
PROMPT

set lines 200
set pages 70
set feedback on
set heading on
col lat for 990
col cup       for 990
col rt for 9990.990
col utps  for 9990
col rdops     for 999990
col sc       for 999990
col uraps       for 999990
col ocps       for 999990
col ucps       for 9990
col ntvps       for 999990
col prtbps       for 999999990
col pwtbps       for 999999990
col rec for 9990
col bcr for 9990
col oth for 9990
col rma for 9990
col str for 9990
col dat for 9990
col dbw for 9990
col lgw for 9990
col xdb for 9990
col dwr for 9990
col arc for 9990
col dre for 9990
col ama for 9990
col lwri for 9990
col swri for 9990
col lrea for 9990
col srea for 9990

select
 metric.*
&ge_112_ ,funmetric.*
&ge_112_ ,tiometric.*
from
(
select
 to_char(smh.end_time,'hh24:mi') time
,sum(case when smh.metric_name = 'Average Synchronous Single-Block Read Latency'  then trunc(to_number(value))        else 0 end) lat
,sum(case when smh.metric_name = 'Host CPU Utilization (%)'  then trunc(to_number(value))        else 0 end) cup
,sum(case when smh.metric_name = 'SQL Service Response Time' then trunc(to_number(value)*10,3)   else 0 end) rt
,sum(case when smh.metric_name = 'User Transaction Per Sec'  then to_number(value)               else 0 end) utps
--,sum(case when metric_name = 'Redo Generated Per Sec'    then round(to_number(value)/(1024)) else 0 end) rdops
&ge_111_ ,sum(case when smh.metric_name = 'Session Count'             then round(to_number(value))        else 0 end) sc
&l_111_  ,sum(case when smh.metric_name = 'Current Logons Count'             then round(to_number(value))        else 0 end) sc
--,sum(case when metric_name = 'CR Undo Records Applied Per Sec' then round(to_number(value))        else 0 end) uraps
--,sum(case when metric_name = 'Open Cursors Per Sec' then round(to_number(value))        else 0 end) ocps
,sum(case when smh.metric_name = 'User Commits Per Sec' then round(to_number(value))        else 0 end) ucps
,sum(case when smh.metric_name = 'Network Traffic Volume Per Sec' then round(to_number(value)/(1024*1024))        else 0 end) ntvps
--,sum(case when metric_name = 'Physical Read Total Bytes Per Sec' then round(to_number(value)/(1024*1024))        else 0 end) prtbps
--,sum(case when metric_name = 'Physical Write Total Bytes Per Sec' then round(to_number(value)/(1024*1024))        else 0 end) pwtbps
from v$sysmetric_history    smh
where smh.metric_name IN
(
 'Average Synchronous Single-Block Read Latency'
,'SQL Service Response Time'
,'Host CPU Utilization (%)'
,'User Transaction Per Sec'
,'Redo Generated Per Sec'
&ge_111_ ,'Session Count'
&l_111_ ,'Current Logons Count'
,'CR Undo Records Applied Per Sec'
,'Open Cursors Per Sec'
,'User Commits Per Sec'
,'Network Traffic Volume Per Sec'
,'Physical Read Total Bytes Per Sec'
,'Physical Write Total Bytes Per Sec'
)
and (case when round(smh.intsize_csec/100) > 30 then 60 else 15 end) > 30
and smh.end_time between sysdate-1/24 and sysdate
group by to_char(smh.end_time,'hh24:mi')
) metric
&ge_112_ ,
&ge_112_ (
&ge_112_ select
&ge_112_  to_char(fmh.end_time,'hh24:mi') time
&ge_112_ ,sum(case when fmh.function_name = 'Recovery'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) rec
&ge_112_ ,sum(case when fmh.function_name = 'Buffer Cache Reads'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) bcr
&ge_112_ ,sum(case when fmh.function_name = 'Others'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) oth
&ge_112_ ,sum(case when fmh.function_name = 'RMAN'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) rma
&ge_112_ ,sum(case when fmh.function_name = 'Streams AQ'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) str
&ge_112_ ,sum(case when fmh.function_name = 'Data Pump'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dat
&ge_112_ ,sum(case when fmh.function_name = 'DBWR'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dbw
&ge_112_ ,sum(case when fmh.function_name = 'LGWR'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) lgw
&ge_112_ ,sum(case when fmh.function_name = 'XDB'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) xdb
&ge_112_ ,sum(case when fmh.function_name = 'Direct Writes'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dwr
&ge_112_ ,sum(case when fmh.function_name = 'ARCH'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) arc
&ge_112_ ,sum(case when fmh.function_name = 'Direct Reads'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dre
&ge_112_ ,sum(case when fmh.function_name = 'Archive Manager'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) ama
&ge_112_ from v$iofuncmetric_history fmh
&ge_112_ where fmh.function_name in (
&ge_112_  'Recovery'
&ge_112_ ,'Buffer Cache Reads'
&ge_112_ ,'Others'
&ge_112_ ,'RMAN'
&ge_112_ ,'Streams AQ'
&ge_112_ ,'Inmemory Populate'
&ge_112_ ,'Smart Scan'
&ge_112_ ,'Data Pump'
&ge_112_ ,'DBWR'
&ge_112_ ,'LGWR'
&ge_112_ ,'XDB'
&ge_112_ ,'Direct Writes'
&ge_112_ ,'ARCH'
&ge_112_ ,'Direct Reads'
&ge_112_ ,'Archive Manager'
&ge_112_ )
&ge_112_ and (case when round(fmh.intsize_csec/100) > 30 then 60 else 15 end) > 30
&ge_112_ and fmh.end_time between sysdate-1/24 and sysdate
&ge_112_ group by to_char(fmh.end_time,'hh24:mi')
&ge_112_ ) funmetric
&ge_112_ ,
&ge_112_ (
&ge_112_ select
&ge_112_  to_char(tmh.end_time,'hh24:mi') time
&ge_112_ ,sum(nvl(tmh.large_read_mbps,0)) lwri
&ge_112_ ,sum(nvl(tmh.small_write_mbps,0)) swri
&ge_112_ ,sum(nvl(tmh.large_read_mbps,0)) lrea
&ge_112_ ,sum(nvl(tmh.small_read_mbps,0)) srea
&ge_112_ from v$iofuncmetric_history tmh
&ge_112_ where (case when round(tmh.intsize_csec/100) > 30 then 60 else 15 end) > 30
&ge_112_ and tmh.end_time between sysdate-1/24 and sysdate
&ge_112_ group by to_char(tmh.end_time,'hh24:mi')
&ge_112_ ) tiometric
&ge_112_ where funmetric.time = metric.time
&ge_112_   and tiometric.time = metric.time
order by metric.time
;


SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Resource Limits ] ====================
PROMPT

CLEAR BREAKS

SELECT * FROM v$resource_limit;


SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Lock Summary ] ====================
PROMPT

CLEAR BREAKS
CLEAR COLUMNS

SET LINES 200
SET PAGES 10000
COL event_blocker_blocked FOR A35
COL username_sid_serial   FOR A30
COL machine        FOR A25 TRUNC
COL program        FOR A15 TRUNC
COL sqlid_child    FOR A16
COL cnt            FOR 999
COL max_time       FOR A12

WITH curr_session AS (SELECT * FROM v$session)
SELECT
       TO_CHAR (CAST (NUMTODSINTERVAL (bl.max_time, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) max_time
      ,bl.max_blocked cnt
      ,se.sql_id||' '||CASE WHEN se.sql_id IS NULL THEN NULL ELSE se.sql_child_number END sqlid_child
      ,RPAD(NVL(se.username,'-|BGPROCESS|-'),(29-LENGTH(se.sid||','||se.serial#)),' ')||se.sid||','||se.serial#||CHR(10)||
       RPAD(se.status                ,(29-12),' ')||TO_CHAR (CAST (NUMTODSINTERVAL (se.last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) username_sid_serial
      ,'+'||se.event||CHR(10)||' -'||bl.event event_blocker_blocked
      ,se.program
      ,se.machine
FROM curr_session se
    ,(SELECT c.blocking_session sid, c.event, COUNT(*) max_blocked, max(seconds_in_wait) max_time
      FROM curr_session c group by c.blocking_session, c.event) bl
WHERE se.sid  = bl.sid
ORDER BY max_time, max_blocked
;

SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ File Metric History ] ====================
PROMPT

CLEAR BREAKS
CLEAR COLUMNS

set lines 200
col begin_time     for a25 heading "Fecha|Inicio"
col max_read_avg   for a12 heading "Promedio|Maximo|Lectura"
col min_read_avg   for a12 heading "Promedio|Minimo|Lectura"
col avg_read_time  for a12 heading "Promedio|Tiempo|Lectura"
col max_write_avg  for a12 heading "Promedio|Maximo|Escritura"
col min_write_avg  for a12 heading "Promedio|Minimo|Escritura"
col avg_write_time for a12 heading "Promedio|Tiempo|Escritura"

--Las metricas que da Oracle son en Centesimas de segundo
SELECT
   to_char(begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
  ,lpad(case when max(average_read_time)  < (         100) then to_char(max(average_read_time)            ,'9G990D99')||'c'
        when max(average_read_time)       < (      100*60) then to_char(max(average_read_time/(100))      ,'9G990D99')||'s'
        when max(average_read_time)       < (   100*60*60) then to_char(max(average_read_time/(100*60))   ,'9G990D99')||'m'
        when max(average_read_time)       < (100*60*60*60) then to_char(max(average_read_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') max_read_avg
  ,lpad(case when min(average_read_time)  < (         100) then to_char(min(average_read_time)            ,'9G990D99')||'c'
        when min(average_read_time)       < (      100*60) then to_char(min(average_read_time/(100))      ,'9G990D99')||'s'
        when min(average_read_time)       < (   100*60*60) then to_char(min(average_read_time/(100*60))   ,'9G990D99')||'m'
        when min(average_read_time)       < (100*60*60*60) then to_char(min(average_read_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') min_read_avg
  ,lpad(case when avg(average_read_time)  < (         100) then to_char(avg(average_read_time)            ,'9G990D99')||'c'
        when avg(average_read_time)       < (      100*60) then to_char(avg(average_read_time/(100))      ,'9G990D99')||'s'
        when avg(average_read_time)       < (   100*60*60) then to_char(avg(average_read_time/(100*60))   ,'9G990D99')||'m'
        when avg(average_read_time)       < (100*60*60*60) then to_char(avg(average_read_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') avg_read_time
  ,lpad(case when max(average_write_time) < (         100) then to_char(max(average_write_time)            ,'9G990D99')||'c'
        when max(average_write_time)      < (      100*60) then to_char(max(average_write_time/(100))      ,'9G990D99')||'s'
        when max(average_write_time)      < (   100*60*60) then to_char(max(average_write_time/(100*60))   ,'9G990D99')||'m'
        when max(average_write_time)      < (100*60*60*60) then to_char(max(average_write_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') max_write_avg
  ,lpad(case when min(average_write_time) < (         100) then to_char(min(average_write_time)            ,'9G990D99')||'c'
        when min(average_write_time)      < (      100*60) then to_char(min(average_write_time/(100))      ,'9G990D99')||'s'
        when min(average_write_time)      < (   100*60*60) then to_char(min(average_write_time/(100*60))   ,'9G990D99')||'m'
        when min(average_write_time)      < (100*60*60*60) then to_char(min(average_write_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') min_write_avg
  ,lpad(case when avg(average_write_time) < (         100) then to_char(avg(average_write_time)            ,'9G990D99')||'c'
        when avg(average_write_time)      < (      100*60) then to_char(avg(average_write_time/(100))      ,'9G990D99')||'s'
        when avg(average_write_time)      < (   100*60*60) then to_char(avg(average_write_time/(100*60))   ,'9G990D99')||'m'
        when avg(average_write_time)      < (100*60*60*60) then to_char(avg(average_write_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') avg_write_time
FROM v$filemetric_history
GROUP BY
   begin_time
  ,end_time
ORDER BY 1
;


PROMPT
PROMPT
PROMPT ==================== [ Existencia de Backups ] ====================
PROMPT

CLEAR BREAKS
CLEAR COLUMNS

set lines 200

col logn_time for a25
col sid_serial for a20
col username for a20
col backup_type for a15
col job_name for a30

select
   to_char(s.logon_time,'yyyy-mm-dd hh24:mi:ss') logon_time
  ,s.status
  ,s.username
  ,s.sid||','||s.serial# sid_serial
  ,case when s.program like 'rman%'                       then 'RMAN'
        when s.program like 'ude%' or s.program like '%DM%' or s.program like '%DW%' then 'DATAPUMP'
        else '-'
   end backup_type
  ,dps.job_name job_name
from v$session s, dba_datapump_sessions dps
where (program like 'rman%' or program like 'ude%' or program like '%DM%' or program like '%DW%')
   and dps.saddr(+) = s.saddr
order by backup_type, logon_time
;

LINEAS_CODIGO


cat > tseg.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

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
LINEAS_CODIGO

cat > rlimit.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

set lines 200

clear breaks

select * from v$resource_limit
where current_utilization > 0;

LINEAS_CODIGO


cat > miash.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 200
SET PAGES 10000

CLEAR BREAKS
CLEAR COLUMNS

COL username FOR A20
COL event FOR A30 TRUNC
COL event2 FOR A30 TRUNC
COL program FOR A30 TRUNC
COL sql_id FOR A13

SELECT *
FROM (
   SELECT
      ROUND(COUNT(*) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AS "AAS"
     ,ROUND(100 * RATIO_TO_REPORT(COUNT(*)) OVER (), 1) AS "ACTIVITY%"
     ,COUNT(*) AS "DB_TIME"
     ,&&1
FROM (
        SELECT a.*
              ,NVL(a.event,'ON CPU') event2
              ,blocking_session blocker
        FROM v$active_session_history a
     ) ash
    ,dba_users u
    ,(SELECT object_id
            ,data_object_id
            ,owner
            ,object_name
            ,subobject_name
            ,object_type
            ,owner||'.'||object_name obj
            ,object_type||'/'||owner||'.'||object_name objt
      FROM dba_objects) ob
WHERE u.user_id = ash.user_id
  AND ash.current_obj# = ob.object_id(+)
  AND sample_time BETWEEN &&3 AND &&4
AND &&2
GROUP BY &&1
ORDER BY count(*) DESC
)
WHERE rownum <= &&5
;
LINEAS_CODIGO

cat > indcolumns.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

select
   t.owner
  ,t.table_name
  ,ic.index_owner
  ,ic.index_name
  ,ic.column_position
  ,ic.column_name
from dba_tables      t
    ,dba_ind_columns ic
where t.owner in ('RCVRY')
  and t.table_name in ('LOV_VALS')
  and ic.table_owner = t.owner
  and ic.table_name  = t.table_name
order by owner
        ,table_name
        ,index_owner
        ,index_name
        ,column_position
;
LINEAS_CODIGO

cat > tx.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 180
SET PAGES 1000

accept where_ char default '1=1' -
prompt 'Sentencia WHERE? start_date sid username [1=1]: '

PROMPT
PROMPT WHERE (1): start_date < <sysdate> AND sid=<sid>

COL sid FOR A10
COL ses_status FOR A10
COL tx_status FOR A10
COL last_call_et FOR A12
COL time_tx_active FOR A14

SELECT s.sid||'' sid
      ,s.status ses_status
      ,TO_CHAR(CAST(numtodsinterval(((sysdate-t.start_date)*(1*24*60*60)), 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) last_call_et
      ,t.status tx_status
      ,TO_CHAR(CAST(numtodsinterval(((sysdate-t.start_date)*(1*24*60*60)), 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) time_tx_active
      ,t.start_date
FROM v$transaction t
    ,v$session     s
WHERE t.ses_addr = s.saddr
  AND &&where_
ORDER BY t.start_date
;
LINEAS_CODIGO

cat > swd.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET ECHO OFF
CLEAR BREAKS
CLEAR COLUMNS

accept sid_ number default 0 -
prompt 'Session Id? []: '

PROMPT
PROMPT
PROMPT ========== [ Eventos de Espera de la Sesion ] ==========
PROMPT

COL wait_class FOR A20 TRUNC
COL event FOR A40 TRUNC
COL waited FOR A12

SELECT s.wait_class
      ,s.event
      ,TO_CHAR(CAST(numtodsinterval(s.time_waited/100, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waited
FROM gv$session_event s
WHERE s.inst_id = SYS_CONTEXT ('USERENV', 'INSTANCE')
  AND s.wait_class not in ('Idle')
  AND s.sid = &&sid_
ORDER BY waited DESC
;

PROMPT ========== [ Ultimos 10 / Seq#=1 Mas reciente ] ==========
PROMPT

COL seq# FOR 999
COL p1_p2_p3 FOR A60 TRUNC

SELECT s.seq#
      ,CASE s.seq# WHEN 1 THEN DECODE (s.wait_time, 0, 'WAITING', 'WAITED') ELSE 'WAITED' END status
      ,TO_CHAR(CAST(numtodsinterval(s.wait_time/100, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waited
      ,e.wait_class
      ,s.event
      ,s.p1text||'='||s.p1||' '||s.p2text||'='||s.p2||' '||s.p3text||'='||s.p3 p1_p2_p3
FROM gv$session_wait_history s INNER JOIN gv$event_name e
   ON e.inst_id = s.inst_id AND e.event# = s.event#
WHERE s.inst_id = SYS_CONTEXT ('USERENV', 'INSTANCE')
  AND s.sid = &&sid_
ORDER BY seq#
;

LINEAS_CODIGO


cat > loadp60.sql <<'LINEAS_CODIGO'
--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

col short_name  format a20              heading 'Load Profile'
col per_sec     format 999,999,999.9    heading 'Per Second'
col per_tx      format 999,999,999.9    heading 'Per Transaction'
set colsep '   '

select lpad(short_name, 20, ' ') short_name
     , per_sec
     , per_tx from
    (select short_name
          , max(decode(typ, 1, value)) per_sec
          , max(decode(typ, 2, value)) per_tx
          , max(m_rank) m_rank
       from
        (select /*+ use_hash(s) */
                m.short_name
              , s.value * coeff value
              , typ
              , m_rank
           from v$sysmetric s,
               (select 'Database Time Per Sec'                      metric_name, 'DB Time' short_name, .01 coeff, 1 typ, 1 m_rank from dual union all
                select 'CPU Usage Per Sec'                          metric_name, 'DB CPU' short_name, .01 coeff, 1 typ, 2 m_rank from dual union all
                select 'Redo Generated Per Sec'                     metric_name, 'Redo size' short_name, 1 coeff, 1 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Sec'                      metric_name, 'Logical reads' short_name, 1 coeff, 1 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Sec'                   metric_name, 'Block changes' short_name, 1 coeff, 1 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Sec'                     metric_name, 'Physical reads' short_name, 1 coeff, 1 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Sec'                    metric_name, 'Physical writes' short_name, 1 coeff, 1 typ, 7 m_rank from dual union all
                select 'User Calls Per Sec'                         metric_name, 'User calls' short_name, 1 coeff, 1 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Sec'                  metric_name, 'Parses' short_name, 1 coeff, 1 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Sec'                   metric_name, 'Hard Parses' short_name, 1 coeff, 1 typ, 10 m_rank from dual union all
                select 'Logons Per Sec'                             metric_name, 'Logons' short_name, 1 coeff, 1 typ, 11 m_rank from dual union all
                select 'Executions Per Sec'                         metric_name, 'Executes' short_name, 1 coeff, 1 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Sec'                     metric_name, 'Rollbacks' short_name, 1 coeff, 1 typ, 13 m_rank from dual union all
                select 'User Transaction Per Sec'                   metric_name, 'Transactions' short_name, 1 coeff, 1 typ, 14 m_rank from dual union all
                select 'User Rollback UndoRec Applied Per Sec'      metric_name, 'Applied urec' short_name, 1 coeff, 1 typ, 15 m_rank from dual union all
                select 'Redo Generated Per Txn'                     metric_name, 'Redo size' short_name, 1 coeff, 2 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Txn'                      metric_name, 'Logical reads' short_name, 1 coeff, 2 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Txn'                   metric_name, 'Block changes' short_name, 1 coeff, 2 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Txn'                     metric_name, 'Physical reads' short_name, 1 coeff, 2 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Txn'                    metric_name, 'Physical writes' short_name, 1 coeff, 2 typ, 7 m_rank from dual union all
                select 'User Calls Per Txn'                         metric_name, 'User calls' short_name, 1 coeff, 2 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Txn'                  metric_name, 'Parses' short_name, 1 coeff, 2 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Txn'                   metric_name, 'Hard Parses' short_name, 1 coeff, 2 typ, 10 m_rank from dual union all
                select 'Logons Per Txn'                             metric_name, 'Logons' short_name, 1 coeff, 2 typ, 11 m_rank from dual union all
                select 'Executions Per Txn'                         metric_name, 'Executes' short_name, 1 coeff, 2 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Txn'                     metric_name, 'Rollbacks' short_name, 1 coeff, 2 typ, 13 m_rank from dual union all
                select 'User Transaction Per Txn'                   metric_name, 'Transactions' short_name, 1 coeff, 2 typ, 14 m_rank from dual union all
                select 'User Rollback Undo Records Applied Per Txn' metric_name, 'Applied urec' short_name, 1 coeff, 2 typ, 15 m_rank from dual) m
          where m.metric_name = s.metric_name
            and s.intsize_csec > 5000 --mayor a 50 segundos
            and s.intsize_csec < 7000) --memor a 70 segundos
      group by short_name)
 order by m_rank;

set colsep ' '
LINEAS_CODIGO


cat > dbat.sql <<'LINEAS_CODIGO'
clear columns
clear breaks

set lines 200
set serveroutput on

undefine columns_

set verify off
set feedback off
set pages 0
set time off
set timing off
set echo off

accept dba_table_ char default 'DBA_TABLES' -
prompt 'Vista de DBA a consultar? [DBA_TABLES]: '

prompt
prompt Listado de Columnas:
prompt ==================================
prompt

declare
   ncols number(4);
   tcols number(4);
   nfils number(4);
   multi number(4);
   linea varchar2(1024);
begin

   select count(*) into tcols from (
   select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_')
   union all
   select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_')
   );

   multi:=0;
   while multi < tcols
   loop
      multi:=multi+4;
   end loop;

   nfils:=case when mod(tcols,4) = 0 then trunc(tcols/4) else floor(tcols/4) + 1 end;
   linea:='';
   ncols:=0;

   if tcols < multi then
      for tabla in (
        select column_name, orden1, orden2 from (
        select  column_name
               ,rownum orden1
               ,case when mod(rownum,nfils) > 0 then mod(rownum,nfils) else nfils end orden2
        from (
        select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_')
        union all
        select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_')
        union all
        select null from dual connect by level <= (multi - tcols)
        order by column_name nulls last
        ))
        order by 3,1
      )
      loop
         ncols:=ncols+1;
         linea:=linea||'['||rpad(tabla.column_name,35,' ')||']';
         if (ncols > 3) then
            dbms_output.put_line(linea);
            linea:='';
            ncols:=0;
         end if;
      end loop;
   else
      for tabla in (
        select column_name, orden1, orden2 from (
        select  column_name
               ,rownum orden1
               ,case when mod(rownum,nfils) > 0 then mod(rownum,nfils) else nfils end orden2
        from (
        select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_')
        union all
        select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_')
        order by column_name nulls last
        ))
        order by 3,1
      )
      loop
         ncols:=ncols+1;
         linea:=linea||'['||rpad(tabla.column_name,35,' ')||']';
         if (ncols > 3) then
            dbms_output.put_line(linea);
            linea:='';
            ncols:=0;
         end if;
      end loop;
   end if;

   dbms_output.put_line(linea);
end;
/


PROMPT
PROMPT
accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

PROMPT
PROMPT
accept distinct_ char default 'N' -
prompt 'Distinct? Y|N [N]: '

PROMPT
PROMPT
accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

set trims on
set lines 32000

spool dbat.consulta.sql

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select 'ORDENAR' column_name from dual union all select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:='COLUMN '||tabla.column_name||' NEW_VALUE '||replace(tabla.column_name,'#','_')||'_';
      dbms_output.put_line(linea);
   end loop;
end;
/

prompt
prompt

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select 'ORDENAR' column_name from dual union all select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:='COLUMN '||tabla.column_name||' NOPRINT';
      dbms_output.put_line(linea);
   end loop;
end;
/

prompt
prompt

select 'SELECT CASE WHEN '||''''||'&&columns_'||''''||' = '||''''||'*'||''''||' THEN '||''''||'--'||''''||' ELSE '||''''||''''||' END ORDENAR' from dual;

declare
   linea varchar2(1024);
   space_columns varchar2(1024) := ' '||replace('&&columns_',',',' ')||' ';
begin
   linea:='';
   for tabla in (select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:=',CASE WHEN '||''''||space_columns||''''||' = '||''''||' * '||''''||' OR INSTR(UPPER('||''''||space_columns||''''||'),'||''''||' '||''''||'||TRIM('||''''||tabla.column_name||''''||')) > 0'||   ' THEN '||''''||''''||' ELSE '||''''||'--'||''''||' END '||tabla.column_name;
      dbms_output.put_line(linea);
   end loop;
end;
/

select 'FROM dual;' from dual;

prompt
prompt

select 'set term on' from dual;

select 'COL info FOR A80' from dual;

prompt
prompt

select 'SELECT ROWNUM, tabs.* FROM ( SELECT '||''''||'''' from dual;

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      if tabla.column_name in ('BLOCK_SIZE'
                              ,'INITIAL_EXTENT'
                              ,'NEXT_EXTENT'
                              )
                           or tabla.column_name LIKE '%BYTES%'
      then
         linea:=q'[&&]'||replace(tabla.column_name,'#','_')||'_'||' '||q'[||LPAD(']'||tabla.column_name||q'[',25,' ')]'||q'[||' : '||]'
                ||q'[ CASE WHEN NVL(]'||tabla.column_name||q'[,0) < 1024     THEN NVL(]'||tabla.column_name||q'[,0)||'']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,2) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,1),1)||'K']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,3) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,2),1)||'M']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,4) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,3),1)||'G']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,5) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,4),1)||'T']'
                     ||q'[ END ]'||q'[||CHR(10)]';
      else
         linea:=q'[&&]'||replace(tabla.column_name,'#','_')||'_'||' '||q'[||LPAD(']'||tabla.column_name||q'[',25,' ')]'||q'[||' : '||]'||q'[trim(to_char(]'||tabla.column_name||q'[))||CHR(10)]';
      end if;

      dbms_output.put_line(linea);
   end loop;
   dbms_output.put_line('info');
end;
/

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:=q'[&&]'||replace(tabla.column_name,'#','_')||'_'||' '||','||tabla.column_name;
      dbms_output.put_line(linea);
   end loop;
end;
/

select 'FROM (SELECT '||DECODE(UPPER('&&distinct_'),'Y','DISTINCT','')||' '||q'[&&]'||'columns_'||' FROM '||q'[&&]'||'dba_table_ WHERE '||q'[&&]'||'where_ )' from dual;
select q'[&&]'||'ORDENAR_ ORDER BY '||q'[&&]'||'columns_' from dual;
select ') tabs ;' from dual;


spool off

spool salida.txt
@dbat.consulta.sql
spool off

clear columns
clear breaks
set pages 50000
set lines 200
set feed on

LINEAS_CODIGO

##
## *** Para sacar en formato separado por pipes (|)
##
#**Ejecutar en vi
#
# - Quitar las primeras lineas antes de los datos
# - Quitar las lineas despues de los datos
# - Ejecutar:
# sed -i 's/^[ ]*//g ; s/[ ]*$//g ; s/^[0-9]*[ ]*//g ; s/^$/linea_en_blanco/g' salida.txt
#
# O usando vi:
# :%s/^[ ]*//g | %s/[ ]*$//g | %s/^[0-9]*[ ]*//g | %s/^$/linea_en_blanco/g
#
#**Obtener cabeceras
#
# function cabeceras()
# {
#    contador=0;
#    escrito=0;
#    lineaConcatenada="";
#    while read linea;
#    do
#       columna_valor=$(echo "${linea}" | cut -d":" -f1);
#       if [ "${linea}" == "linea_en_blanco" ]; then
#          echo "${lineaConcatenada}";
#          lineaConcatenada="";
#          contador=1;
#       else
#          if [ -z "${lineaConcatenada}" ]; then
#             lineaConcatenada="${columna_valor}";
#             escrito=1;
#          else
#             lineaConcatenada="${lineaConcatenada}|${columna_valor}";
#          fi
#       fi
#       if [ ${contador} -gt 0 -a ${escrito} -gt 0 ]; then break; else contador=0; fi
#    done < salida.txt
#    echo "${lineaConcatenada}";
# }
# cabeceras > salida-final.txt
#
# #Para poner el cuerpo
#
# function cuerpo()
# {
#    lineaConcatenada="";
#    while read linea;
#    do
#       columna_valor=$(echo "${linea}" | cut -d":" -f2-);
#       if [ "${linea}" == "linea_en_blanco" ]; then
#          echo "${lineaConcatenada}";
#          lineaConcatenada="";
#       else
#          if [ -z "${lineaConcatenada}" ]; then
#             lineaConcatenada="${columna_valor}";
#          else
#             lineaConcatenada="${lineaConcatenada}|${columna_valor}";
#          fi
#       fi
#    done < salida.txt
#    echo "${lineaConcatenada}";
# }
# cuerpo >> salida-final.txt

cat > tdisco.sql <<'LINEAS_CODIGO'
set lines 200
col begin_time     for a25 heading "Fecha|Inicio"
col max_read_avg   for a12 heading "Promedio|Maximo|Lectura"
col min_read_avg   for a12 heading "Promedio|Minimo|Lectura"
col avg_read_time  for a12 heading "Promedio|Tiempo|Lectura"
col max_write_avg  for a12 heading "Promedio|Maximo|Escritura"
col min_write_avg  for a12 heading "Promedio|Minimo|Escritura"
col avg_write_time for a12 heading "Promedio|Tiempo|Escritura"

--Las metricas que da Oracle son en Centesimas de segundo
SELECT
   to_char(begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
  ,lpad(case when max(average_read_time)  < (         100) then to_char(max(average_read_time)            ,'9G990D99')||'c'
        when max(average_read_time)       < (      100*60) then to_char(max(average_read_time/(100))      ,'9G990D99')||'s'
        when max(average_read_time)       < (   100*60*60) then to_char(max(average_read_time/(100*60))   ,'9G990D99')||'m'
        when max(average_read_time)       < (100*60*60*60) then to_char(max(average_read_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') max_read_avg
  ,lpad(case when min(average_read_time)  < (         100) then to_char(min(average_read_time)            ,'9G990D99')||'c'
        when min(average_read_time)       < (      100*60) then to_char(min(average_read_time/(100))      ,'9G990D99')||'s'
        when min(average_read_time)       < (   100*60*60) then to_char(min(average_read_time/(100*60))   ,'9G990D99')||'m'
        when min(average_read_time)       < (100*60*60*60) then to_char(min(average_read_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') min_read_avg
  ,lpad(case when avg(average_read_time)  < (         100) then to_char(avg(average_read_time)            ,'9G990D99')||'c'
        when avg(average_read_time)       < (      100*60) then to_char(avg(average_read_time/(100))      ,'9G990D99')||'s'
        when avg(average_read_time)       < (   100*60*60) then to_char(avg(average_read_time/(100*60))   ,'9G990D99')||'m'
        when avg(average_read_time)       < (100*60*60*60) then to_char(avg(average_read_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') avg_read_time
  ,lpad(case when max(average_write_time) < (         100) then to_char(max(average_write_time)            ,'9G990D99')||'c'
        when max(average_write_time)      < (      100*60) then to_char(max(average_write_time/(100))      ,'9G990D99')||'s'
        when max(average_write_time)      < (   100*60*60) then to_char(max(average_write_time/(100*60))   ,'9G990D99')||'m'
        when max(average_write_time)      < (100*60*60*60) then to_char(max(average_write_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') max_write_avg
  ,lpad(case when min(average_write_time) < (         100) then to_char(min(average_write_time)            ,'9G990D99')||'c'
        when min(average_write_time)      < (      100*60) then to_char(min(average_write_time/(100))      ,'9G990D99')||'s'
        when min(average_write_time)      < (   100*60*60) then to_char(min(average_write_time/(100*60))   ,'9G990D99')||'m'
        when min(average_write_time)      < (100*60*60*60) then to_char(min(average_write_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') min_write_avg
  ,lpad(case when avg(average_write_time) < (         100) then to_char(avg(average_write_time)            ,'9G990D99')||'c'
        when avg(average_write_time)      < (      100*60) then to_char(avg(average_write_time/(100))      ,'9G990D99')||'s'
        when avg(average_write_time)      < (   100*60*60) then to_char(avg(average_write_time/(100*60))   ,'9G990D99')||'m'
        when avg(average_write_time)      < (100*60*60*60) then to_char(avg(average_write_time/(100*60*60)),'9G990D99')||'h'
   end,12,' ') avg_write_time
FROM v$filemetric_history
GROUP BY
   begin_time
  ,end_time
ORDER BY 1
;
LINEAS_CODIGO


cat > rmanb.sql <<'LINEAS_CODIGO'
SET LINES 200
SET PAGES 1000
COL start_time  FOR A22
COL end_time    FOR A22
COL input_size  FOR A15
COL output_size FOR A15
COL status      FOR A25

SELECT
  TO_CHAR(start_time,'YYYY-MON-DD HH24:MI:SS') start_time
 ,TO_CHAR(end_time  ,'YYYY-MON-DD HH24:MI:SS') end_time
 ,LPAD(CASE WHEN input_bytes < 1024     THEN TO_CHAR(input_bytes                       ,'9G990D9')||'B'
       WHEN input_bytes < POWER(1024,2) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,1),1),'9G990D9')||'K'
       WHEN input_bytes < POWER(1024,3) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,2),1),'9G990D9')||'M'
       WHEN input_bytes < POWER(1024,4) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,3),1),'9G990D9')||'G'
       WHEN input_bytes < POWER(1024,5) THEN TO_CHAR(TRUNC(input_bytes/POWER(1024,4),1),'9G990D9')||'T'
  END
  ,15,' ') input_size
 ,LPAD(CASE WHEN output_bytes < 1024     THEN TO_CHAR(output_bytes                       ,'9G990D9')||'B'
       WHEN output_bytes < POWER(1024,2) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,1),1),'9G990D9')||'K'
       WHEN output_bytes < POWER(1024,3) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,2),1),'9G990D9')||'M'
       WHEN output_bytes < POWER(1024,4) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,3),1),'9G990D9')||'G'
       WHEN output_bytes < POWER(1024,5) THEN TO_CHAR(TRUNC(output_bytes/POWER(1024,4),1),'9G990D9')||'T'
  END
  ,15,' ') output_size
 ,input_type
 ,TO_CHAR(CAST(NUMTODSINTERVAL(elapsed_seconds, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) elapsed_time
 ,status
FROM v$rman_backup_job_details
WHERE start_time > TRUNC(SYSDATE)-60
AND input_type in ('DB FULL','DB INCR','ARCHIVELOG')
;

LINEAS_CODIGO


cat > backups.sql <<'LINEAS_CODIGO'
PROMPT
PROMPT
PROMPT ==================== [ Existencia de Backups ] ====================
PROMPT

CLEAR BREAKS
CLEAR COLUMNS

set lines 200

col logn_time for a25
col sid_serial for a20
col username for a20
col backup_type for a15
col job_name for a30

select
   to_char(s.logon_time,'yyyy-mm-dd hh24:mi:ss') logon_time
  ,s.status
  ,s.username
  ,s.sid||','||s.serial# sid_serial
  ,case when s.program like 'rman%'                       then 'RMAN'
        when s.program like 'ude%' or s.program like '%DM%' or s.program like '%DW%' then 'DATAPUMP'
        else '-'
   end backup_type
  ,dps.job_name job_name
from v$session s, dba_datapump_sessions dps
where (program like 'rman%' or program like 'ude%' or program like '%DM%' or program like '%DW%')
   and dps.saddr(+) = s.saddr
order by backup_type, logon_time
;

LINEAS_CODIGO