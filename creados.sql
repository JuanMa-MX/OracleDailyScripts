--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
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
