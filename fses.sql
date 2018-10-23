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
&l_92_ 'IDENTIFIER  : ' || s.sid || ',' || s.serial# || CHR(10) ||
&ge_92_ 'IDENTIFIER  : ' || s.sid || ',' || s.serial# || ',' ||'@'||s.inst_id || CHR(10) ||
'LOGON TIME  : ' || TO_CHAR(s.logon_time,'YYYY-MON-DD HH24:MI:SS') || CHR(10) ||
'STATUS      : ' || s.status || CHR(10) ||
&ge_112_  'USERNAME    : ' ||NVL(s.username,'-|'||p.pname||'|-') || CHR(10) ||
&l_112_   'USERNAME    : ' || s.username || CHR(10) ||
'SCHEMA      : ' || s.schemaname || CHR(10) ||
'OSUSER      : ' || s.osuser || CHR(10) ||
'MODULE      : ' || s.program || CHR(10) ||
'ACTION      : ' || s.schemaname || CHR(10) ||
'CLIENT INFO : ' || s.client_info || CHR(10) ||
'PROGRAM     : ' || s.program || CHR(10) ||
'SPID        : ' || p.spid || CHR(10) ||
'MACHINE     : ' || s.machine || CHR(10) ||
'TYPE        : ' || s.type || CHR(10) ||
'TERMINAL    : ' || s.terminal || CHR(10) ||
'CPU         : ' || q.cpu_time/1e6 || CHR(10) ||
'ELAPSED_TIME: ' || q.elapsed_time/1e6 || CHR(10) ||
'BUFFER_GETS : ' || q.buffer_gets || CHR(10) ||
&l_101_  'SQL_ID      : ' || s.sql_address||'-'||s.sql_hash_value || CHR(10) ||
&ge_101_ 'SQL_ID      : ' || q.sql_id || CHR(10) ||
&l_101_  'CHILD_NUM   : ' || q.child_number || CHR(10) ||
&ge_101_ 'CHILD_NUM   : ' || s.sql_child_number || CHR(10) ||
&l_111_  'START_TIME  : ' || 'UNKNOWN' || CHR(10) ||
&ge_111_ 'START_TIME  : ' || TO_CHAR(s.sql_exec_start,'yyyy-mm-dd hh24:mi') || CHR(10) ||
&l_101_  'SQL_TEXT    : ' || q.sql_text || CHR(10) ||
&ge_101_ 'SQL_TEXT    : ' || q.sql_fulltext || CHR(10) ||
'--------------------------------------------------------------------------------'
info_session
&l_92_  FROM (SELECT * FROM v$session WHERE &where_ ) s, v$process p, v$sql q
&l_92_  WHERE s.paddr = p.addr AND q.address(+) = s.sql_adress and q.hash_value = s.sql_hash_value AND q.child_number = s.sql_child_number
&ge_92_ FROM (SELECT * FROM gv$session WHERE &where_ ) s INNER JOIN gv$process p ON (p.inst_id = s.inst_id AND  p.addr = s.paddr)
&ge_92_                   LEFT OUTER JOIN gv$sql q ON (q.inst_id = s.inst_id
&e_92_                                             AND q.address = s.sql_adress AND q.hash_value = s.sql_hash_value AND q.child_number = s.sql_child_number )
&ge_101_                                           AND q.sql_id = s.sql_id AND q.child_number = s.sql_child_number )
WHERE NVL(q.sql_text,'-') NOT LIKE '%dummy_value%'
;
