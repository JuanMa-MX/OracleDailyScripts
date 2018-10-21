--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
CLEAR BREAKS
CLEAR COLUMNS

VARIABLE interval_     NUMBER;

VARIABLE snapshot     VARCHAR2(8);
VARIABLE actsess      NUMBER;
VARIABLE resp_time    NUMBER;
VARIABLE executions   NUMBER;
VARIABLE parses       NUMBER;
VARIABLE open_cursors NUMBER;
VARIABLE commits      NUMBER;
VARIABLE read_mb      NUMBER;
VARIABLE write_mb     NUMBER;
VARIABLE host_cpu     NUMBER;
VARIABLE transactions NUMBER;

BEGIN
 :interval_ := 15;
 select count(*) into :actsess from v$session where status = 'ACTIVE' and username is not null;

 select to_char(begin_time, 'hh24:mi:ss') snapshot
 --,sum(case when metric_name = 'Current Logons Count'               then value                      else 0 end)
 ,sum(case when metric_name = 'SQL Service Response Time'          then trunc(value/(1e3),3)       else 0 end)
 ,sum(case when metric_name = 'Executions Per Sec'                 then trunc(value,1)             else 0 end)
 ,sum(case when metric_name = 'Total Parse Count Per Sec'          then value                      else 0 end)
 ,sum(case when metric_name = 'Open Cursors Per Sec'               then value                      else 0 end)
 ,sum(case when metric_name = 'User Commits Per Sec'               then value                      else 0 end)
 ,sum(case when metric_name = 'Physical Read Total Bytes Per Sec'  then round(value/(1024*1024),1) else 0 end)
 ,sum(case when metric_name = 'Physical Write Total Bytes Per Sec' then round(value/(1024*1024),1) else 0 end)
 ,sum(case when metric_name = 'Host CPU Utilization (%)'           then trunc(value,1)             else 0 end)
 ,sum(case when metric_name = 'User Transaction Per Sec'           then value                      else 0 end)
 into
:snapshot
 ,:resp_time
 ,:executions
 ,:parses
 ,:open_cursors
 ,:commits
 ,:read_mb
 ,:write_mb
 ,:host_cpu
 ,:transactions
 from v$sysmetric
 where intsize_csec < (:interval_*100*2)
 and metric_name in
 (
--'Current Logons Count'
'SQL Service Response Time'
 ,'Executions Per Sec'
 ,'Total Parse Count Per Sec'
 ,'Open Cursors Per Sec'
 ,'User Commits Per Sec'
 ,'Physical Read Total Bytes Per Sec'
 ,'Physical Write Total Bytes Per Sec'
 ,'Host CPU Utilization (%)'
 ,'User Transaction Per Sec'
 )
 group by to_char(begin_time, 'hh24:mi:ss');
END;
/

COLUMN snapshot     FOR A8         HEADING "Time"
COLUMN actsess      FOR 990        HEADING "ActSess"
COLUMN resp_time    FOR 990.999999 HEADING "RespTimeMilli"
COLUMN executions   FOR 999,990.9  HEADING "Exec/s"
COLUMN parses       FOR 999,990.9  HEADING "Parses/s"
COLUMN open_cursors FOR 999,990.9  HEADING "OpenCur/s"
COLUMN commits      FOR 999,990.9  HEADING "Commit/s"
COLUMN read_mb      FOR 990.9      HEADING "ReadMb/s"
COLUMN write_mb     FOR 990.9      HEADING "WriteMb/s"
COLUMN host_cpu     FOR 990.9      HEADING "HostCPU(%)"
COLUMN transactions FOR 999,990.9  HEADING "Trans/s"

SELECT
:snapshot     snapshot
 ,:host_cpu     host_cpu
 ,:actsess      actsess
 ,:resp_time    resp_time
 ,:executions   executions
 ,:parses       parses
 ,:open_cursors open_cursors
 ,:commits      commits
 ,:read_mb      read_mb
 ,:write_mb     write_mb
 ,:transactions transactions
FROM dual;
