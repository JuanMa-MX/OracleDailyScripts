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
