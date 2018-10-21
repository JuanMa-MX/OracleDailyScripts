--    By : JohnXJean
--Support: johnxjean@gmail.com
set serveroutput on
set echo off
set term off
set feed off

variable interval_   number;
variable interval_   number;
variable iterations_ number;
variable script      varchar2(128);
begin
 :interval_   := to_number('&1');
 :iterations_ := to_number('&2');
 :script      := '&3';
end;
/

spool r.script.sql

begin
 for i in 1..:iterations_
 loop
  dbms_output.put_line('@@'||:script||'.sql');
  if i < :iterations_
  then
 dbms_output.put_line('!sleep '||:interval_);
  end if;
 end loop;
end;
/

spool off;

set term on
@r.script.sql
