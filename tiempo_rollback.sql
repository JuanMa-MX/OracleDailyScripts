--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
-------------------------------------------------------------------------------
--- Script: calculate_rollback_time.sql
--- Copyright: (c)  Daniel Alberto Enriquez García
--- Author: Daniel Alberto Enriquez García
---         and main query by Juan Manuel Cruz Lopez
---
---    @calculate_rollback_time.sql  <SID>
---
---   Execution example:
---    @calculate_rollback_time.sql  1868
---
--- Description:  Solo compis chiditos
-------------------------------------------------------------------------------
set serveroutput on
set feedback off
set lines 2000
prompt
prompt Script to get rolling back session info
prompt

set term off;
variable SID_ number;
exec :SID_:='&1';
set term on
declare
 cursor tx is
SELECT s.inst_id,s.sid,s.serial#,s.username,
   t.used_ublk,
   t.used_urec,
   rs.segment_name ,
   ROUND(r.rssize / (1024*1024)),
   t.start_date,
   to_char(cast(numtodsinterval(ROUND((sysdate-t.start_date)*24*60*60),'SECOND') as interval day(2) to second(0))),
DECODE (s.command, 0, 'NULL', 1, 'CRE TAB', 2, 'INSERT', 3, 'SELECT', 4, 'CRE CLUSTER', 5, 'ALT CLUSTER', 6, 'UPDATE', 7, 'DELETE', 8, 'DRP CLUSTER', 9, 'CRE INDEX',
  10, 'DROP INDEX', 11, 'ALT INDEX', 12, 'DROP TABLE', 13, 'CRE SEQ', 14, 'ALT SEQ', 15, 'ALT TABLE', 16, 'DROP SEQ', 17, 'GRANT', 18, 'REVOKE', 19, 'CRE SYN',
  20, 'DROP SYN', 21, 'CRE VIEW', 22, 'DROP VIEW', 23, 'VAL INDEX', 24, 'CRE PROC', 25, 'ALT PROC', 26, 'LOCK TABLE', 28, 'RENAME', 29, 'COMMENT',
  30, 'AUDIT', 31, 'NOAUDIT', 32, 'CRE DBLINK', 33, 'DROP DBLINK', 34, 'CRE DB', 35, 'ALTER DB', 36, 'CRE RBS', 37, 'ALT RBS', 38, 'DROP RBS', 39, 'CRE TBLSPC',
  40, 'ALT TBLSPC', 41, 'DROP TBLSPC', 42, 'ALT SESSION', 43, 'ALT USER', 44, 'COMMIT', 45, 'ROLLBACK', 46, 'SAVEPOINT', 47, 'PL/SQL EXEC', 48, 'SET XACTN',
  49, 'SWITCH LOG', 50, 'EXPLAIN', 51, 'CRE USER', 52, 'CRE ROLE', 53, 'DROP USER', 54, 'DROP ROLE', 55, 'SET ROLE', 56, 'CRE SCHEMA', 57, 'CRE CTLFILE',
  58, 'ALTER TRACING', 59, 'CRE TRIGGER', 60, 'ALT TRIGGER', 61, 'DRP TRIGGER', 62, 'ANALYZE TAB', 63, 'ANALYZE IX', 64, 'ANALYZE CLUS', 65, 'CRE PROFILE',
  66, 'DRP PROFILE', 67, 'ALT PROFILE', 68, 'DRP PROC', 69, 'DRP PROC', 70, 'ALT RESOURCE', 71, 'CRE SNPLOG', 72, 'ALT SNPLOG', 73, 'DROP SNPLOG',
  74, 'CREATE SNAP', 75, 'ALT SNAP', 76, 'DROP SNAP', 79, 'ALTER ROLE', 79, 'ALTER ROLE', 85, 'TRUNC TAB', 86, 'TRUNC CLUST', 88, 'ALT VIEW',
  91, 'CRE FUNC', 92, 'ALT FUNC', 93, 'DROP FUNC', 94, 'CRE PKG', 95, 'ALT PKG', 96, 'DROP PKG', 97, 'CRE PKG BODY', 98, 'ALT PKG BODY',
  99, 'DRP PKG BODY',TO_CHAR (s.command)
)||'('||s.sql_address||' '||s.sql_hash_value||')'
FROM   gv$transaction t,
   gv$session s,
   gv$rollstat r,
   dba_rollback_segs rs
WHERE  s.inst_id = t.inst_id
 AND s.inst_id = r.inst_id
 AND s.saddr = t.ses_addr
 AND t.used_ublk > 0
AND    t.xidusn = r.usn
AND    rs.segment_id = t.xidusn
and    s.sid=:SID_
ORDER BY  s.inst_id
;
 xinstid number;
 xsid       number;
 xserial  number;
 user_name  varchar2(50);
 used_ublk1 number;
 used_ublk2 number;
 undorecord number;
 segmentname varchar2(100);
 segsize   number;
 startdate date;
 elapsedtime varchar2(15);
 commande   varchar2(4000);
 remaining_time varchar2(100);
 xsqlid   varchar2(100);
 xsql_text varchar2(4000);
xprogram varchar2(4000);
xosuser   varchar2(100);

begin

open tx;
FETCH tx into xinstid,xsid, xserial, user_name, used_ublk1, undorecord ,segmentname, segsize,startdate,elapsedtime ,commande;
CLOSE tx;

sys.dbms_lock.sleep(10);

open tx;
FETCH tx into xinstid,xsid, xserial, user_name, used_ublk2, undorecord ,segmentname, segsize,startdate,elapsedtime ,commande;
CLOSE tx;

select
to_char(cast(numtodsinterval(used_ublk2/(used_ublk1 - used_ublk2)/6/60/24,'DAY') as interval day(2) to second(0)))
into remaining_time
from dual;

select q.sql_id, replace(q.SQL_TEXT,chr(0)), program, OSUSER
into  xsqlid,  xsql_text, xprogram , xosuser
from v$session s,v$sql q
where s.PREV_SQL_ADDR = q.address
and s.PREV_HASH_VALUE = q.hash_value
and s.sid = xsid
and s.serial#=xserial;

 if used_ublk2 < used_ublk1
 then
   sys.dbms_output.put_line
   (
 'NODE_ID:               '||to_char(xinstid)||chr(10)||
 'SID:                   '||to_char(xsid)||chr(10)||
 'SERIAL:                '||to_char(xserial)||chr(10)||
 'USERNAME:              '||user_name||chr(10)||
 'USED BLOCKS:           '||to_char(used_ublk2)||chr(10)||
 'SEGMENT NAME:          '||segmentname||chr(10)||
 'SEGMENT SIZE:          '||to_char(segsize)||chr(10)||
 'START_DATE:            '||to_char(startdate,'DD-MM-YYYY HH24:MI:SS')||chr(10)||
 'ELAPSED TIME:          '||to_char(elapsedtime)||chr(10)||
 'REMAINING TIME:        '||remaining_time||chr(10)||
 'ESTIMATED FINISH TIME: '||to_char(sysdate + used_ublk2 / (used_ublk1 - used_ublk2) / 6 / 60 / 24,'DD-MON-YYYY HH24:MI:SS'
 )
   );
   sys.dbms_output.put_line
   (
 'COMMAND:               '||commande||chr(10)||
 'OSUSER:                '||xosuser||chr(10)||
 'PROGRAM:               '||xprogram||chr(10)||
 'SQL_ID:                '||xsqlid||chr(10)||
 'SQL_TEXT:              '||xsql_text
   );
 end if;
end;
/
prompt
