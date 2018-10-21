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
