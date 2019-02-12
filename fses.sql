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
