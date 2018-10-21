--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
VARIABLE interval_          NUMBER;

VARIABLE f1_other          NUMBER;
VARIABLE f1_queueing       NUMBER;
VARIABLE f1_network        NUMBER;
VARIABLE f1_administrative NUMBER;
VARIABLE f1_configuration  NUMBER;
VARIABLE f1_commit         NUMBER;
VARIABLE f1_application    NUMBER;
VARIABLE f1_concurrency    NUMBER;
VARIABLE f1_cluster        NUMBER;
VARIABLE f1_system_io      NUMBER;
VARIABLE f1_user_io        NUMBER;
VARIABLE f1_scheduler      NUMBER;
VARIABLE f1_cpu            NUMBER;
VARIABLE f1_total          NUMBER;

VARIABLE f2_other          NUMBER;
VARIABLE f2_queueing       NUMBER;
VARIABLE f2_network        NUMBER;
VARIABLE f2_administrative NUMBER;
VARIABLE f2_configuration  NUMBER;
VARIABLE f2_commit         NUMBER;
VARIABLE f2_application    NUMBER;
VARIABLE f2_concurrency    NUMBER;
VARIABLE f2_cluster        NUMBER;
VARIABLE f2_system_io      NUMBER;
VARIABLE f2_user_io        NUMBER;
VARIABLE f2_scheduler      NUMBER;
VARIABLE f2_cpu            NUMBER;
VARIABLE f2_total          NUMBER;

VARIABLE total             NUMBER;

VARIABLE time              VARCHAR2(8);

VARIABLE sesactive         NUMBER;
VARIABLE sesinactive       NUMBER;
VARIABLE sesblocked        NUMBER;
VARIABLE num_cpus          NUMBER;

SET TERM OFF

BEGIN
:interval_         := TO_NUMBER('&1');
:f1_other          := 0;
:f1_queueing       := 0;
:f1_network        := 0;
:f1_administrative := 0;
:f1_configuration  := 0;
:f1_commit         := 0;
:f1_application    := 0;
:f1_concurrency    := 0;
:f1_cluster        := 0;
:f1_system_io      := 0;
:f1_user_io        := 0;
:f1_scheduler      := 0;
:f1_cpu            := 0;
:f1_total          := 0;
:sesactive         := 0;
:sesinactive       := 0;
:sesblocked        := 0;
END;
/

SET TERM ON

BEGIN
 SELECT sum(value)/1E6
 INTO :f1_cpu
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
 WHEN 'Other'          THEN :f1_other          := reg.time_waited;
 WHEN 'Queueing'       THEN :f1_queueing       := reg.time_waited;
 WHEN 'Network'        THEN :f1_network        := reg.time_waited;
 WHEN 'Administrative' THEN :f1_administrative := reg.time_waited;
 WHEN 'Configuration'  THEN :f1_configuration  := reg.time_waited;
 WHEN 'Commit'         THEN :f1_commit         := reg.time_waited;
 WHEN 'Application'    THEN :f1_application    := reg.time_waited;
 WHEN 'Concurrency'    THEN :f1_concurrency    := reg.time_waited;
 WHEN 'Cluster'        THEN :f1_cluster        := reg.time_waited;
 WHEN 'System I/O'     THEN :f1_system_io      := reg.time_waited;
 WHEN 'User I/O'       THEN :f1_user_io        := reg.time_waited;
 WHEN 'Scheduler'      THEN :f1_scheduler      := reg.time_waited;
  END CASE;
  :f1_total := :f1_total + reg.time_waited;
 END LOOP;
END;
/
