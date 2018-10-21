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
