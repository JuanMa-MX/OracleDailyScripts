-----------------------------------------------------------
--
-- Script:      waiters.sql
-- Purpose:     to count the waiters for each event type
-- For:         8.0 and higher
--
-- Copyright:   (c) 2000 Ixora Pty Ltd
-- Author:      Steve Adams
--
-----------------------------------------------------------
SET ECHO OFF
SET LINES 200
SET PAGES 1000
SET HEADING ON

column wait_class for a20 trunc
column event      for a30 trunc
column t0 for 999
column t1 for 999
column t2 for 999
column t3 for 999
column t4 for 999
column t5 for 999
column t6 for 999
column t7 for 999
column t8 for 999
column t9 for 999


clear breaks
break on report
compute sum of t0 on report
compute sum of t1 on report
compute sum of t2 on report
compute sum of t3 on report
compute sum of t4 on report
compute sum of t5 on report
compute sum of t6 on report
compute sum of t7 on report
compute sum of t8 on report
compute sum of t9 on report

select /*+ CHOOSE */
n.wait_class,
n.name event,
/*
nvl(t0,0) t0,
nvl(t1,0) t1,
nvl(t2,0) t2,
nvl(t3,0) t3,
nvl(t4,0) t4,
nvl(t5,0) t5,
nvl(t6,0) t6,
nvl(t7,0) t7,
nvl(t8,0) t8,
nvl(t9,0) t9
*/
t0,
t1,
t2,
t3,
t4,
t5,
t6,
t7,
t8,
t9
from
 v$event_name  n,
(select event e0, count(*)  t0 from v$session_wait group by event),
(select event e1, count(*)  t1 from v$session_wait group by event),
(select event e2, count(*)  t2 from v$session_wait group by event),
(select event e3, count(*)  t3 from v$session_wait group by event),
(select event e4, count(*)  t4 from v$session_wait group by event),
(select event e5, count(*)  t5 from v$session_wait group by event),
(select event e6, count(*)  t6 from v$session_wait group by event),
(select event e7, count(*)  t7 from v$session_wait group by event),
(select event e8, count(*)  t8 from v$session_wait group by event),
(select event e9, count(*)  t9 from v$session_wait group by event)
where
n.wait_class not in ('Idle') and
n.name != 'Null event' and
n.name != 'null event' and
n.name != 'rdbms ipc message' and
n.name != 'pipe get' and
n.name != 'virtual circuit status' and
n.name not like '%timer%' and
n.name not like '%slave wait' and
n.name not like 'SQL*Net message from %' and
n.name not like 'io done' and
n.name != 'queue messages' and
e0  = n.name and
e1  = n.name and
e2  = n.name and
e3  = n.name and
e4  = n.name and
e5  = n.name and
e6  = n.name and
e7  = n.name and
e8  = n.name and
e9  = n.name and
nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0) > 0
order by
nvl(t0, 0) + nvl(t1, 0) + nvl(t2, 0) + nvl(t3, 0) + nvl(t4, 0) +
nvl(t5, 0) + nvl(t6, 0) + nvl(t7, 0) + nvl(t8, 0) + nvl(t9, 0)
;
