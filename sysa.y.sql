--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

CLEAR BREAKS
CLEAR COLUMNS
SET LINES 200

COLUMN sesactive FORMAT 999 HEADING "Active"
COLUMN sesinactive FORMAT 999999 HEADING "Inactive"
COLUMN sesblocked FORMAT 999 HEADING "Blocked"
COLUMN wtime FORMAT A8 TRUNCATE HEADING "Time"
COLUMN num_cpus FORMAT 990 HEADING "NumCPUs";
COLUMN wactive FORMAT 999,990.0 HEADING "AvgActSess"
COLUMN wother FORMAT 990.0 HEADING "Other%"
COLUMN wqueueing FORMAT 990.0 HEADING "Queue%"
COLUMN wnetwork FORMAT 990.0 HEADING "Net%"
COLUMN wadministrative FORMAT 990.0 HEADING "Adm%"
COLUMN wconfiguration FORMAT 990.0 HEADING "Conf%"
COLUMN wcommit FORMAT 990.0 HEADING "Comm%"
COLUMN wapplication FORMAT 990.0 HEADING "Appl%"
COLUMN wconcurrency FORMAT 990.0 HEADING "Conc%"
COLUMN wcluster FORMAT 990.0 HEADING "Clust%"
COLUMN wsystem_io FORMAT 990.0 HEADING "SysIO%"
COLUMN wuser_io FORMAT 990.0 HEADING "UsrIO%"
COLUMN wscheduler FORMAT 990.0 HEADING "Sched%"
COLUMN wtotal FORMAT 990.0 HEADING "CPU%"

BEGIN
:f2_other          := 0;
:f2_queueing       := 0;
:f2_network        := 0;
:f2_administrative := 0;
:f2_configuration  := 0;
:f2_commit         := 0;
:f2_application    := 0;
:f2_concurrency    := 0;
:f2_cluster        := 0;
:f2_system_io      := 0;
:f2_user_io        := 0;
:f2_scheduler      := 0;
:f2_cpu            := 0;
:f2_total          := 0;
:total             := 0;
END;
/

BEGIN
 BEGIN
  SELECT value INTO :num_cpus FROM v$osstat WHERE stat_name='NUM_CPU_CORES';
 EXCEPTION WHEN no_data_found THEN
  SELECT value INTO :num_cpus FROM v$osstat WHERE stat_name='NUM_CPUS';
 END;

 SELECT sum(value)/1E6, to_char(sysdate,'hh24:mi:ss')
 INTO :f2_cpu, :time
 FROM v$sys_time_model
 WHERE stat_name IN ('DB CPU','background cpu time');

 FOR reg IN (SELECT wait_class#
 ,wait_class
 ,time_waited/1E2 time_waited
   FROM v$system_wait_class
   WHERE wait_class <> 'Idle'
  )
 LOOP
  CASE reg.wait_class
 WHEN 'Other'          THEN :f2_other          := reg.time_waited;
 WHEN 'Queueing'       THEN :f2_queueing       := reg.time_waited;
 WHEN 'Network'        THEN :f2_network        := reg.time_waited;
 WHEN 'Administrative' THEN :f2_administrative := reg.time_waited;
 WHEN 'Configuration'  THEN :f2_configuration  := reg.time_waited;
 WHEN 'Commit'         THEN :f2_commit         := reg.time_waited;
 WHEN 'Application'    THEN :f2_application    := reg.time_waited;
 WHEN 'Concurrency'    THEN :f2_concurrency    := reg.time_waited;
 WHEN 'Cluster'        THEN :f2_cluster        := reg.time_waited;
 WHEN 'System I/O'     THEN :f2_system_io      := reg.time_waited;
 WHEN 'User I/O'       THEN :f2_user_io        := reg.time_waited;
 WHEN 'Scheduler'      THEN :f2_scheduler      := reg.time_waited;
  END CASE;
  :f2_total := :f2_total + reg.time_waited;
 END LOOP;
 :total := (:f2_total - :f1_total) + (:f2_cpu - :f1_cpu);
 :total := nullif(:total,0); -- avoid ORA-01476: divisor is equal to zero

 SELECT COUNT(CASE WHEN status IN ('ACTIVE')
   THEN 1
   ELSE NULL
  END),
  COUNT(CASE WHEN status IN ('INACTIVE')
   THEN 1
   ELSE NULL
  END),
  COUNT(CASE WHEN blocking_session IS NOT NULL
   THEN 1
   ELSE NULL
  END)
 INTO
  :sesactive
 ,:sesinactive
 ,:sesblocked
 FROM v$session
 WHERE username IS NOT NULL;
END;
/

select
:sesactive                                           sesactive
, :sesinactive                                         sesinactive
, :sesblocked                                          sesblocked
, :time                                                wtime
, :num_cpus                                            num_cpus
, :total/nullif(:interval_,0)                          wactive
, (:f2_other          - :f1_other)/:total*100          wother
, (:f2_queueing       - :f1_queueing)/:total*100       wqueueing
, (:f2_network        - :f1_network)/:total*100        wnetwork
, (:f2_administrative - :f1_administrative)/:total*100 wadministrative
, (:f2_configuration  - :f1_configuration)/:total*100  wconfiguration
, (:f2_commit         - :f1_commit)/:total*100         wcommit
, (:f2_application    - :f1_application)/:total*100    wapplication
, (:f2_concurrency    - :f1_concurrency)/:total*100    wconcurrency
, (:f2_cluster        - :f1_cluster)/:total*100        wcluster
, (:f2_system_io      - :f1_system_io)/:total*100      wsystem_io
, (:f2_user_io        - :f1_user_io)/:total*100        wuser_io
, (:f2_scheduler      - :f1_scheduler)/:total*100      wscheduler
, (:f2_cpu - :f1_cpu )/:total*100                      wtotal
from dual;

BEGIN
 :f1_other          := :f2_other;
 :f1_queueing       := :f2_queueing;
 :f1_network        := :f2_network;
 :f1_administrative := :f2_administrative;
 :f1_configuration  := :f2_configuration;
 :f1_commit         := :f2_commit ;
 :f1_application    := :f2_application;
 :f1_concurrency    := :f2_concurrency;
 :f1_cluster        := :f2_cluster;
 :f1_system_io      := :f2_system_io;
 :f1_user_io        := :f2_user_io;
 :f1_scheduler      := :f2_scheduler;
 :f1_cpu            := :f2_cpu;
 :f1_total          := :f2_total;
END;
/
