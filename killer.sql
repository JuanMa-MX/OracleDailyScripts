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
