--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
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
