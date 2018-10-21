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
