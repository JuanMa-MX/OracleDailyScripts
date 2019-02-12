--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

--------------------------------------------------------------------------------
--
-- Archivo  :   topa.sql
-- Proposito:   Despliega el Top SQL, Top de Sesiones y Eventos de Espera
--
-- Autor:      Juan Manuel Cruz Lopez
-- Copyright:   (c)
--
-- Uso:
--     @topa.sql <fromtime> <totime>
--
-- Ejemplo:
--     Para ver la actividad de la ultima hora:
--     @topa sysdate-1/24 sysdate
--     Para ver algun periodo en especifico
--     @topa to_date('yyyymmdd_hh24mi','20180703_1000') to_date('yyyymmdd_hh24mi','20180703_1010')
-- Importante:
-- El script usa las vistas ASH, por lo que es requerida la licencia sobre diagnostic+tuning pack
--
--------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT
PROMPT

clear breaks
set term off
column oracle_version new_value oracle_version_
column l_92 new_value l_92_
column e_92 new_value e_92_
column ge_92 new_value ge_92_
column l_101 new_value l_101_
column ge_101 new_value ge_101_
column l_111 new_value l_111_
column ge_111 new_value ge_111_
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
select case when &oracle_version_ < 11.1 then '' else '--' end l_111 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ < 11.2 then '' else '--' end l_112 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 9.2 AND &oracle_version_ < 11.2 then '' else '--' end ge_92_l_112 from v$instance;

set term on
set verify off

set pages 1000
set lines 220
set heading on
set feedback on
col "%This"  for a5
col "AAS"  for 9,990.0
col "User"   for a15
col "Sid"    for 999999
col "Program"  for a50 trunc
col "Secs"   for 999990
col "Wait Class"   for a20 trunc
col "Event"   for a50 trunc
col "CPU" for 9990
col "UsIO" for 9990
col "SyIO" for 9990
col "Comm" for 9990
col "App"  for 9990
col "Conc" for 9990
col "Conf" for 9990
col "Que"  for 9990
col "Net"  for 9990
col "Adm"  for 9990
col "Clus" for 9990
col "Sche" for 9990
col "Oth"  for 9990
col "Sql Id" for a13
col "TimesX" for 9990
col "Cmd Type" for a11
col "UsIO Event" for a23 trunc
col "Full Obj Name" for a60

PROMPT
PROMPT
PROMPT ========== [ Top Events ] ==========
PROMPT

select *
from (
select
 lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ') "%This"
,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
,wait_class "Wait Class"
,event "Event"
--,count(*) "Secs"
from v$active_session_history
where
sample_time between &1 and &2
group by wait_class, event
order by "DBTime" DESC
     )
where rownum <= 20
;

PROMPT
PROMPT
PROMPT ========== [ Top Sql ] ==========
PROMPT

select
 case when sqla.command_type =  1 then 'CREATE TAB'
      when sqla.command_type =  2 then 'INSERT'
      when sqla.command_type =  3 then 'SELECT'
      when sqla.command_type =  6 then 'UPDATE'
      when sqla.command_type =  7 then 'DELETE'
      when sqla.command_type =  9 then 'CREATE IDX'
      when sqla.command_type = 11 then 'ALTER IDX'
      when sqla.command_type = 15 then 'ALTER TAB'
      when sqla.command_type = 26 then 'LOCK TAB'
      when sqla.command_type = 45 then 'ROLLBACK'
      when sqla.command_type = 47 then 'PLSQL EXEC'
      when sqla.command_type = 62 then 'ANALYZE TAB'
      when sqla.command_type = 63 then 'ANALYZE IDX'
      when sqla.command_type = 85 then 'TRUNC TAB'
      when sqla.command_type = 189 then 'MERGE'
      else 'UNKNOWN' end "Cmd Type"
,fash.*
from
(
   select *
   from (
      select
       lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ')         "%This"
      ,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
      ,ash.sql_id "Sql Id"
&ge_111_      ,count(distinct ash.sql_exec_start) "TimesX"
      --,count(*)                                                                "Secs"
      ,round(count(case when ash.wait_class is null            then 1 else null end)*100/count(*)) "CPU"
      ,round(count(case when ash.wait_class = 'User I/O'       then 1 else null end)*100/count(*)) "UsIO"
      ,round(count(case when ash.wait_class = 'System I/O'     then 1 else null end)*100/count(*)) "SyIO"
      ,round(count(case when ash.wait_class = 'Commit'         then 1 else null end)*100/count(*)) "Comm"
      ,round(count(case when ash.wait_class = 'Application'    then 1 else null end)*100/count(*)) "App"
      ,round(count(case when ash.wait_class = 'Concurrency'    then 1 else null end)*100/count(*)) "Conc"
      ,round(count(case when ash.wait_class = 'Configuration'  then 1 else null end)*100/count(*)) "Conf"
      ,round(count(case when ash.wait_class = 'Queueing'       then 1 else null end)*100/count(*)) "Que"
      ,round(count(case when ash.wait_class = 'Network'        then 1 else null end)*100/count(*)) "Net"
      ,round(count(case when ash.wait_class = 'Administrative' then 1 else null end)*100/count(*)) "Adm"
      ,round(count(case when ash.wait_class = 'Cluster'        then 1 else null end)*100/count(*)) "Clus"
      ,round(count(case when ash.wait_class = 'Scheduler'      then 1 else null end)*100/count(*)) "Sche"
      ,round(count(case when ash.wait_class = 'Other'          then 1 else null end)*100/count(*)) "Oth"
      from v$active_session_history ash
      where ash.sample_time between &1 and &2
      group by ash.sql_id --,ash.sql_opname
      order by "DBTime" desc
        )
   where rownum <= 20
) fash
,v$sqlarea sqla
where sqla.sql_id(+) = fash."Sql Id"
order by "DBTime" desc
;

PROMPT
PROMPT
PROMPT ========== [ Top Sessions ] ==========
PROMPT

select
 fash."%This"
,fash."DBTime"
,fash."Sid"
,dbau.username||':'||fash."Program" "Program"
,fash."CPU"
,fash."UsIO"
,fash."SyIO"
,fash."Comm"
,fash."App"
,fash."Conc"
,fash."Conf"
,fash."Que"
,fash."Net"
,fash."Adm"
,fash."Clus"
,fash."Sche"
,fash."Oth"
from
(
   select *
   from (
      select
       lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ')         "%This"
      ,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
      ,ash.session_id "Sid"
      ,ash.user_id
      ,replace(replace(replace(ash.program,' ','_'),'(',''),')','') "Program"
      --,count(*)                                                                "Secs"
      ,round(count(case when ash.wait_class is null            then 1 else null end)*100/count(*)) "CPU"
      ,round(count(case when ash.wait_class = 'User I/O'       then 1 else null end)*100/count(*)) "UsIO"
      ,round(count(case when ash.wait_class = 'System I/O'     then 1 else null end)*100/count(*)) "SyIO"
      ,round(count(case when ash.wait_class = 'Commit'         then 1 else null end)*100/count(*)) "Comm"
      ,round(count(case when ash.wait_class = 'Application'    then 1 else null end)*100/count(*)) "App"
      ,round(count(case when ash.wait_class = 'Concurrency'    then 1 else null end)*100/count(*)) "Conc"
      ,round(count(case when ash.wait_class = 'Configuration'  then 1 else null end)*100/count(*)) "Conf"
      ,round(count(case when ash.wait_class = 'Queueing'       then 1 else null end)*100/count(*)) "Que"
      ,round(count(case when ash.wait_class = 'Network'        then 1 else null end)*100/count(*)) "Net"
      ,round(count(case when ash.wait_class = 'Administrative' then 1 else null end)*100/count(*)) "Adm"
      ,round(count(case when ash.wait_class = 'Cluster'        then 1 else null end)*100/count(*)) "Clus"
      ,round(count(case when ash.wait_class = 'Scheduler'      then 1 else null end)*100/count(*)) "Sche"
      ,round(count(case when ash.wait_class = 'Other'          then 1 else null end)*100/count(*)) "Oth"
      from
       v$active_session_history ash
      where ash.sample_time between &1 and &2
      group by
       ash.session_id
      ,ash.user_id
      ,ash.program
      order by "DBTime" desc
        )
   where rownum <= 20
) fash
,dba_users dbau
where
  dbau.user_id = fash.user_id
order by "DBTime" desc
;

PROMPT
PROMPT
PROMPT ========== [ Top Segments Read ] ==========
PROMPT

select
 case when sqla.command_type =   1 then 'CREATE TAB'
      when sqla.command_type =   2 then 'INSERT'
      when sqla.command_type =   3 then 'SELECT'
      when sqla.command_type =   6 then 'UPDATE'
      when sqla.command_type =   7 then 'DELETE'
      when sqla.command_type =   9 then 'CREATE IDX'
      when sqla.command_type =  11 then 'ALTER IDX'
      when sqla.command_type =  15 then 'ALTER TAB'
      when sqla.command_type =  26 then 'LOCK TAB'
      when sqla.command_type =  45 then 'ROLLBACK'
      when sqla.command_type =  47 then 'PLSQL EXEC'
      when sqla.command_type =  62 then 'ANALYZE TAB'
      when sqla.command_type =  63 then 'ANALYZE IDX'
      when sqla.command_type =  85 then 'TRUNC TAB'
      when sqla.command_type = 189 then 'MERGE'
      else 'UNKNOWN' end "Cmd Type"
,fash.sql_id "Sql Id"
,fash."%This"
,fash."DBTime"
,fash."UsIO Event"
,substr(dbao.object_type,1,5)||':'||dbao.owner||'.'||dbao.object_name "Full Obj Name"
from (
   select *
   from (
   select
    ash.sql_id
   ,lpad(round(ratio_to_report(count(*)) over () * 100)||'%',5,' ') "%This"
   ,to_char(cast(numtodsinterval(count(*), 'second') as interval day(2) to second(0))) "DBTime"
   ,ash.event "UsIO Event"
   ,ash.current_obj#
   from v$active_session_history ash
   where
   ash.sample_time between &1 and &2
   and (ash.event like 'db file s%' or ash.event like 'direct p%')
   group by ash.sql_id,ash.wait_class, ash.event, ash.current_obj#
   order by "DBTime" desc
        )
   where rownum <= 20
     ) fash
,dba_objects dbao
,v$sqlarea sqla
where sqla.sql_id(+) = fash.sql_id
  and dbao.object_id(+) = fash.current_obj#
order by "DBTime" desc
;

PROMPT
PROMPT
PROMPT ========== [ Top Activity ] ==========
PROMPT

col "Time" for a8

select *
from (
select
 count(*)                                                                "Secs"
,to_char(ash.sample_time,'hh24:mi') "Time"
--,round(count(case when ash.wait_class is null            then 1 else null end)*100/count(*)) "Idle"
,trunc(sum(case when ash.wait_class = 'User I/O'       then 1 else 0 end)/60,3) "UsIO"
,trunc(sum(case when ash.wait_class = 'System I/O'     then 1 else 0 end)/60,3) "SyIO"
,trunc(sum(case when ash.wait_class = 'Commit'         then 1 else 0 end)/60,3) "Comm"
,trunc(sum(case when ash.wait_class = 'Application'    then 1 else 0 end)/60,3) "App"
,trunc(sum(case when ash.wait_class = 'Concurrency'    then 1 else 0 end)/60,3) "Conc"
,trunc(sum(case when ash.wait_class = 'Configuration'  then 1 else 0 end)/60,3) "Conf"
,trunc(sum(case when ash.wait_class = 'Queueing'       then 1 else 0 end)/60,3) "Que"
,trunc(sum(case when ash.wait_class = 'Network'        then 1 else 0 end)/60,3) "Net"
,trunc(sum(case when ash.wait_class = 'Administrative' then 1 else 0 end)/60,3) "Adm"
,trunc(sum(case when ash.wait_class = 'Cluster'        then 1 else 0 end)/60,3) "Clus"
,trunc(sum(case when ash.wait_class = 'Scheduler'      then 1 else 0 end)/60,3) "Sche"
,trunc(sum(case when ash.wait_class = 'Other'          then 1 else 0 end)/60,3) "Oth"
,trunc(sum(case when ash.wait_class is null            then 1 else 0 end)/60,3) "Cpu"
from
 v$active_session_history ash
where ash.sample_time between sysdate-1/24*2 and sysdate
group by
 to_char(ash.sample_time,'hh24:mi')
order by "Time"
     )
;


PROMPT
PROMPT
PROMPT ========== [ System Metric History ] ==========
PROMPT

set lines 200
set pages 70
set feedback on
set heading on
col lat for 990
col cup       for 990
col rt for 9990.990
col utps  for 9990
col rdops     for 999990
col sc       for 999990
col uraps       for 999990
col ocps       for 999990
col ucps       for 9990
col ntvps       for 999990
col prtbps       for 999999990
col pwtbps       for 999999990
col rec for 9990
col bcr for 9990
col oth for 9990
col rma for 9990
col str for 9990
col dat for 9990
col dbw for 9990
col lgw for 9990
col xdb for 9990
col dwr for 9990
col arc for 9990
col dre for 9990
col ama for 9990
col lwri for 9990
col swri for 9990
col lrea for 9990
col srea for 9990

select
 metric.*
&ge_112_ ,funmetric.*
&ge_112_ ,tiometric.*
from
(
select
 to_char(smh.end_time,'hh24:mi') time
,sum(case when smh.metric_name = 'Average Synchronous Single-Block Read Latency'  then trunc(to_number(value))        else 0 end) lat
,sum(case when smh.metric_name = 'Host CPU Utilization (%)'  then trunc(to_number(value))        else 0 end) cup
,sum(case when smh.metric_name = 'SQL Service Response Time' then trunc(to_number(value)*10,3)   else 0 end) rt
,sum(case when smh.metric_name = 'User Transaction Per Sec'  then to_number(value)               else 0 end) utps
--,sum(case when metric_name = 'Redo Generated Per Sec'    then round(to_number(value)/(1024)) else 0 end) rdops
&ge_111_ ,sum(case when smh.metric_name = 'Session Count'             then round(to_number(value))        else 0 end) sc
&l_111_  ,sum(case when smh.metric_name = 'Current Logons Count'             then round(to_number(value))        else 0 end) sc
--,sum(case when metric_name = 'CR Undo Records Applied Per Sec' then round(to_number(value))        else 0 end) uraps
--,sum(case when metric_name = 'Open Cursors Per Sec' then round(to_number(value))        else 0 end) ocps
,sum(case when smh.metric_name = 'User Commits Per Sec' then round(to_number(value))        else 0 end) ucps
,sum(case when smh.metric_name = 'Network Traffic Volume Per Sec' then round(to_number(value)/(1024*1024))        else 0 end) ntvps
--,sum(case when metric_name = 'Physical Read Total Bytes Per Sec' then round(to_number(value)/(1024*1024))        else 0 end) prtbps
--,sum(case when metric_name = 'Physical Write Total Bytes Per Sec' then round(to_number(value)/(1024*1024))        else 0 end) pwtbps
from v$sysmetric_history    smh
where smh.metric_name IN
(
 'Average Synchronous Single-Block Read Latency'
,'SQL Service Response Time'
,'Host CPU Utilization (%)'
,'User Transaction Per Sec'
,'Redo Generated Per Sec'
&ge_111_ ,'Session Count'
&l_111_ ,'Current Logons Count'
,'CR Undo Records Applied Per Sec'
,'Open Cursors Per Sec'
,'User Commits Per Sec'
,'Network Traffic Volume Per Sec'
,'Physical Read Total Bytes Per Sec'
,'Physical Write Total Bytes Per Sec'
)
and (case when round(smh.intsize_csec/100) > 30 then 60 else 15 end) > 30
and smh.end_time between sysdate-1/24 and sysdate
group by to_char(smh.end_time,'hh24:mi')
) metric
&ge_112_ ,
&ge_112_ (
&ge_112_ select
&ge_112_  to_char(fmh.end_time,'hh24:mi') time
&ge_112_ ,sum(case when fmh.function_name = 'Recovery'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) rec
&ge_112_ ,sum(case when fmh.function_name = 'Buffer Cache Reads'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) bcr
&ge_112_ ,sum(case when fmh.function_name = 'Others'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) oth
&ge_112_ ,sum(case when fmh.function_name = 'RMAN'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) rma
&ge_112_ ,sum(case when fmh.function_name = 'Streams AQ'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) str
&ge_112_ ,sum(case when fmh.function_name = 'Data Pump'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dat
&ge_112_ ,sum(case when fmh.function_name = 'DBWR'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dbw
&ge_112_ ,sum(case when fmh.function_name = 'LGWR'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) lgw
&ge_112_ ,sum(case when fmh.function_name = 'XDB'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) xdb
&ge_112_ ,sum(case when fmh.function_name = 'Direct Writes'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dwr
&ge_112_ ,sum(case when fmh.function_name = 'ARCH'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) arc
&ge_112_ ,sum(case when fmh.function_name = 'Direct Reads'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) dre
&ge_112_ ,sum(case when fmh.function_name = 'Archive Manager'
&ge_112_           then nvl(fmh.small_read_mbps,0)+nvl(fmh.small_write_mbps,0)+nvl(fmh.large_read_mbps,0)+nvl(fmh.large_write_mbps,0)
&ge_112_           else 0
&ge_112_      end) ama
&ge_112_ from v$iofuncmetric_history fmh
&ge_112_ where fmh.function_name in (
&ge_112_  'Recovery'
&ge_112_ ,'Buffer Cache Reads'
&ge_112_ ,'Others'
&ge_112_ ,'RMAN'
&ge_112_ ,'Streams AQ'
&ge_112_ ,'Inmemory Populate'
&ge_112_ ,'Smart Scan'
&ge_112_ ,'Data Pump'
&ge_112_ ,'DBWR'
&ge_112_ ,'LGWR'
&ge_112_ ,'XDB'
&ge_112_ ,'Direct Writes'
&ge_112_ ,'ARCH'
&ge_112_ ,'Direct Reads'
&ge_112_ ,'Archive Manager'
&ge_112_ )
&ge_112_ and (case when round(fmh.intsize_csec/100) > 30 then 60 else 15 end) > 30
&ge_112_ and fmh.end_time between sysdate-1/24 and sysdate
&ge_112_ group by to_char(fmh.end_time,'hh24:mi')
&ge_112_ ) funmetric
&ge_112_ ,
&ge_112_ (
&ge_112_ select
&ge_112_  to_char(tmh.end_time,'hh24:mi') time
&ge_112_ ,sum(nvl(tmh.large_read_mbps,0)) lwri
&ge_112_ ,sum(nvl(tmh.small_write_mbps,0)) swri
&ge_112_ ,sum(nvl(tmh.large_read_mbps,0)) lrea
&ge_112_ ,sum(nvl(tmh.small_read_mbps,0)) srea
&ge_112_ from v$iofuncmetric_history tmh
&ge_112_ where (case when round(tmh.intsize_csec/100) > 30 then 60 else 15 end) > 30
&ge_112_ and tmh.end_time between sysdate-1/24 and sysdate
&ge_112_ group by to_char(tmh.end_time,'hh24:mi')
&ge_112_ ) tiometric
&ge_112_ where funmetric.time = metric.time
&ge_112_   and tiometric.time = metric.time
order by metric.time
;


SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Resource Limits ] ====================
PROMPT

CLEAR BREAKS

SELECT * FROM v$resource_limit;


SET ECHO OFF
PROMPT
PROMPT
PROMPT ==================== [ Lock tree ] ====================
PROMPT

SET LINES 200
SET PAGES 1000
SET RECSEP OFF

CLEAR COLUMNS
CLEAR BREAKS

COLUMN chain_id NOPRINT
COLUMN N NOPRINT
COLUMN l NOPRINT
COLUMN root NOPRINT

COLUMN event            FOR A40 WORD_WRAP
COLUMN waiting_active   FOR A25
COLUMN graph FORMAT A10
COLUMN identifier       FOR A17
COLUMN username         FOR A15
COLUMN osuser           FOR A10
COLUMN machine          FOR A25
COLUMN program          FOR A15 TRUNC


BREAK ON root SKIP 3
COMPUTE COUNT LABEL 'Total' OF root ON root

WITH
w AS
(
 SELECT chain_id
   ,ROWNUM n
   ,LEVEL l
   ,CONNECT_BY_ROOT w.sid root
   --
   --
   ,LPAD(' ',LEVEL,' ')
   ||'> '||w.wait_event_text
   ||' '
   ||s.sql_id
   ||CASE WHEN w.wait_event_text LIKE 'enq: TM%'
  THEN ' mode '
 ||DECODE(w.p1 ,1414332418,'Row-S' ,1414332419,'Row-X' ,1414332420,'Share' ,1414332421,'Share RX' ,1414332422,'eXclusive')
 ||( SELECT ' '||object_type||' "'||owner||'"."'||object_name||'" ' FROM all_objects WHERE object_id=w.p2 )
  WHEN w.wait_event_text LIKE 'enq: TX%'
  THEN (SELECT ' '
 ||object_type
 ||' "'||owner||'"."'||object_name||'"'
 ||' '
 ||dbms_rowid.rowid_create(1,data_object_id,relative_fno,w.row_wait_block#,w.row_wait_row#)
FROM all_objects, dba_data_files
WHERE object_id = w.row_wait_obj# AND w.row_wait_file# = file_id
)
 END event
   ,TO_CHAR(CAST(numtodsinterval(w.in_wait_secs, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0)))
   ||' '
   ||TO_CHAR(CAST(numtodsinterval(s.last_call_et, 'SECOND') AS INTERVAL DAY(2) TO SECOND(0)))
   waiting_active
   ,LPAD('+',LEVEL,'+')||NVL(LEVEL,1) graph
  ,s.sid||','||s.serial#||'@'||s.inst_id identifier
  ,NVL(s.username,'-|'||p.pname||'|-') username
  ,s.osuser
  ,CASE WHEN INSTR(s.machine,'.') > 0
THEN SUBSTR(s.machine,1,INSTR(s.machine,'.'))
ELSE s.machine
END machine
  ,CASE WHEN INSTR(s.program,'@') > 0
THEN SUBSTR(s.program,1,INSTR(s.program,'@')-1)
ELSE s.program
   END
   ||
   CASE WHEN INSTR(s.program,')') > 0
THEN SUBSTR(s.program,INSTR(s.program,'('),INSTR(s.program,')')-INSTR(s.program,'(')+1)
ELSE ''
   END program
 FROM v$wait_chains w JOIN gv$session s ON (s.sid = w.sid AND s.serial# = w.sess_serial# AND s.inst_id = w.instance)
   JOIN gv$process p ON (s.inst_id = p.inst_id AND s.paddr = p.addr)
 CONNECT BY PRIOR w.sid = w.blocker_sid AND PRIOR w.sess_serial# = w.blocker_sess_serial# AND PRIOR w.instance = w.blocker_instance
 START WITH w.blocker_sid IS NULL
)
SELECT *
FROM w
WHERE chain_id IN (SELECT chain_id FROM w GROUP BY chain_id HAVING MAX(waiting_active) >= '+00 00:00:10' AND MAX(l) > 1 )
ORDER BY root, graph DESC, waiting_active DESC
;

SET RECSEP WR

