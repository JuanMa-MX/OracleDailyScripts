--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
set serveroutput on
set echo off
set term off
set feed off

variable interval_   number;
variable iterations_ number;
begin
 :interval_   := to_number('&1');
 :iterations_ := to_number('&2');
end;
/

spool sysa.script.sql

declare
 j number;
begin
 dbms_output.put_line('set newpage none');
 dbms_output.put_line('set lines 170');
 dbms_output.put_line('set pages 20');
 dbms_output.put_line('set echo off');
 dbms_output.put_line('set feedback off');
 dbms_output.put_line('set recsep off');
 dbms_output.put_line('@@sysa.x.sql '||:interval_);

 j := 0;
 for i in 1..:iterations_
 loop
  if j = 0
  then
 dbms_output.put_line('set head on');
  else
 dbms_output.put_line('set head off');
  end if;
  dbms_output.put_line('!sleep '||:interval_);
  dbms_output.put_line('@@sysa.y.sql');
  j := j + 1;
  if j = 10
  then
j := 0;
  end if;
 end loop;
end;
/

spool off;

set term on
@sysa.script.sql
