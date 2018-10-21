--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
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
