alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select status, SQL_ID,ERROR_NUMBER,ERROR_MESSAGE,sql_exec_start,ELAPSED_TIME/1e6 segs from v$sql_monitor 
where sql_id in ('161x3q3w0vfjz','dbygp89abzbxa','5nmdzv3z1gcbv') order by SQL_EXEC_START, sql_id
;



alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select status, SQL_ID,ERROR_NUMBER,ERROR_MESSAGE,min(sql_exec_start) sql_exec_start,max(ELAPSED_TIME/1e6) segs from v$sql_monitor 
where sql_id in ('161x3q3w0vfjz','dbygp89abzbxa','5nmdzv3z1gcbv')
group by status, SQL_ID,ERROR_NUMBER,ERROR_MESSAGE,sql_exec_start
order by SQL_EXEC_START, sql_id
;
