PROMPT
PROMPT
PROMPT ==================== [ Existencia de Backups ] ====================
PROMPT

CLEAR BREAKS
CLEAR COLUMNS

set lines 200

col logn_time for a25
col sid_serial for a20
col username for a20
col backup_type for a15
col job_name for a30

select
   to_char(s.logon_time,'yyyy-mm-dd hh24:mi:ss') logon_time
  ,s.status
  ,s.username
  ,s.sid||','||s.serial# sid_serial
  ,case when s.program like 'rman%'                       then 'RMAN'
        when s.program like 'ude%' or s.program like '%DM%' or s.program like '%DW%' then 'DATAPUMP'
        else '-'
   end backup_type
  ,dps.job_name job_name
from v$session s, dba_datapump_sessions dps
where (program like 'rman%' or program like 'ude%' or program like '%DM%' or program like '%DW%')
   and dps.saddr(+) = s.saddr
order by backup_type, logon_time
;

