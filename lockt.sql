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

PROMPT
PROMPT
PROMPT ==================== [ Arbol de Bloqueos ] ====================
PROMPT

SET LINES 200
SET PAGES 1000
SET RECSEP EACH

CLEAR COLUMNS
CLEAR BREAKS

SET HEADING ON
COLUMN chain_id NOPRINT
COLUMN N NOPRINT
COLUMN l NOPRINT
COLUMN blocker FOR 9999999
COLUMN graph FORMAT A15
COLUMN waiting   FOR A12
COLUMN last_call_et FOR A12
COLUMN info1 FOR A50 WORD_WRAP
COLUMN info2 FOR A50 WORD_WRAP

BREAK ON blocker SKIP 3

WITH
w AS
(
 SELECT chain_id
   ,ROWNUM n
   ,LEVEL l
   ,CONNECT_BY_ROOT w.sid root
   --
   --
   ,LPAD('+',LEVEL,'+')||NVL(LEVEL,1) graph
   ,w.in_wait_secs
   ,s.last_call_et
   ,  'S: '||s.status                                 ||CHR(10)
    ||'I: '||s.sid||','||s.serial#||'@'||s.inst_id    ||CHR(10)
    ||'U: '||NVL(s.username,p.pname)||' / '||s.osuser ||CHR(10)
    ||'P: '||CASE WHEN INSTR(s.program,'@') > 0
             THEN SUBSTR(s.program,1,INSTR(s.program,'@')-1)
             ELSE s.program
             END
             ||
             CASE WHEN INSTR(s.program,')') > 0
             THEN SUBSTR(s.program,INSTR(s.program,'('),INSTR(s.program,')')-INSTR(s.program,'(')+1)
             ELSE ''
             END                                               ||CHR(10)
    ||'H: '||s.machine
    info1
  ,  'E: '||w.wait_event_text                                  ||CHR(10)
   ||'Q: '||s.sql_id                                           ||CHR(10)
   ||'M: '||DECODE(w.p1
                   ,1414332418,'Row-S'
                   ,1414332419,'Row-X'
                   ,1414332420,'Share'
                   ,1414332421,'Share RX'
                   ,1414332422,'eXclusive'
                   ,w.p1) ||CHR(10)
   ||'O: '||( SELECT '['||object_type||'] '||owner||'."'||object_name||'"'
               FROM all_objects
               WHERE object_id=CASE WHEN w.wait_event_text LIKE 'enq: TX%' THEN w.row_wait_obj# ELSE w.p2 END ) ||CHR(10)
   ||'R: '||CASE WHEN w.wait_event_text LIKE 'enq: TX%' THEN
             (SELECT dbms_rowid.rowid_create(1,data_object_id,relative_fno,w.row_wait_block#,w.row_wait_row#)
              FROM all_objects, dba_data_files
              WHERE object_id = w.row_wait_obj# AND w.row_wait_file# = file_id
             )
             END
     info2
 FROM v$wait_chains w JOIN gv$session s ON (s.sid = w.sid AND s.serial# = w.sess_serial# AND s.inst_id = w.instance)
   JOIN gv$process p ON (s.inst_id = p.inst_id AND s.paddr = p.addr)
 CONNECT BY PRIOR w.sid = w.blocker_sid AND PRIOR w.sess_serial# = w.blocker_sess_serial# AND PRIOR w.instance = w.blocker_instance
 START WITH w.blocker_sid IS NULL
)
SELECT chain_id,n,l,root blocker,graph
,TO_CHAR(CAST(numtodsinterval(in_wait_secs, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) waiting
,TO_CHAR(CAST(numtodsinterval(last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) last_call_et
,info1
,info2
FROM w
WHERE chain_id IN (SELECT chain_id FROM w GROUP BY chain_id HAVING MAX(in_wait_secs) >= 2 AND MAX(l) > 1 )
ORDER BY root, graph DESC, waiting DESC
;

SET RECSEP WR
