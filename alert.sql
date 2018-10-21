SET LINES 200
SET PAGES 10000
SET VERIFY OFF

CLEAR BREAKS
CLEAR COLUMNS

set term off

column oracle_version new_value oracle_version_
column ge_111 new_value ge_111_
column lt_111 new_value lt_111_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_  < 11.1 then '' else '--' end lt_111 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;

set term on

CLEAR BREAKS
CLEAR COLUMNS

COL alert FOR A100

select
&lt_111_  (select value from v$parameter where name='background_dump_dest')
&lt_111_  ||'/alert_'||(select instance_name from v$instance)||'.log'
&ge_111_  (select value from v$parameter where name='diagnostic_dest')
&ge_111_  ||'/diag/rdbms/'
&ge_111_  ||(select value from v$parameter where name='db_unique_name')
&ge_111_  ||'/'
&ge_111_  ||(select instance_name from v$instance)
&ge_111_  ||'/trace'
&ge_111_  ||'/alert_'||(select instance_name from v$instance)||'.log'
alert
from dual;

CLEAR BREAKS
CLEAR COLUMNS
