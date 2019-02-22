clear columns
clear breaks

set lines 200
set serveroutput on

undefine columns_

set verify off
set feedback off
set pages 0
set time off
set timing off

accept dba_table_ char default 'DBA_TABLES' -
prompt 'Vista de DBA a consultar? [DBA_TABLES]: '

prompt
prompt Listado de Columnas:
prompt ==================================
prompt

declare
   ncols number(4);
   tcols number(4);
   nfils number(4);
   multi number(4);
   linea varchar2(1024);
begin

   select count(*) into tcols from (
   select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_')
   union all
   select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_')
   );

   multi:=0;
   while multi < tcols
   loop
      multi:=multi+4;
   end loop;

   nfils:=case when mod(tcols,4) = 0 then trunc(tcols/4) else floor(tcols/4) + 1 end;
   linea:='';
   ncols:=0;

   if tcols < multi then
      for tabla in (
        select column_name, orden1, orden2 from (
        select  column_name
               ,rownum orden1
               ,case when mod(rownum,nfils) > 0 then mod(rownum,nfils) else nfils end orden2
        from (
        select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_')
        union all
        select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_')
        union all
        select null from dual connect by level <= (multi - tcols)
        order by column_name nulls last
        ))
        order by 3,1
      )
      loop
         ncols:=ncols+1;
         linea:=linea||'['||rpad(tabla.column_name,35,' ')||']';
         if (ncols > 3) then
            dbms_output.put_line(linea);
            linea:='';
            ncols:=0;
         end if;
      end loop;
   else
      for tabla in (
        select column_name, orden1, orden2 from (
        select  column_name
               ,rownum orden1
               ,case when mod(rownum,nfils) > 0 then mod(rownum,nfils) else nfils end orden2
        from (
        select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_')
        union all
        select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_')
        order by column_name nulls last
        ))
        order by 3,1
      )
      loop
         ncols:=ncols+1;
         linea:=linea||'['||rpad(tabla.column_name,35,' ')||']';
         if (ncols > 3) then
            dbms_output.put_line(linea);
            linea:='';
            ncols:=0;
         end if;
      end loop;
   end if;

   dbms_output.put_line(linea);
end;
/


PROMPT
PROMPT
accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

PROMPT
PROMPT
accept distinct_ char default 'N' -
prompt 'Distinct? Y|N [N]: '

PROMPT
PROMPT
accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

set trims on
set lines 32000

spool dbat.consulta.sql

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select 'ORDENAR' column_name from dual union all select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:='COLUMN '||tabla.column_name||' NEW_VALUE '||replace(tabla.column_name,'#','_')||'_';
      dbms_output.put_line(linea);
   end loop;
end;
/

prompt
prompt

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select 'ORDENAR' column_name from dual union all select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:='COLUMN '||tabla.column_name||' NOPRINT';
      dbms_output.put_line(linea);
   end loop;
end;
/

prompt
prompt

select 'SELECT CASE WHEN '||''''||'&&columns_'||''''||' = '||''''||'*'||''''||' THEN '||''''||'--'||''''||' ELSE '||''''||''''||' END ORDENAR' from dual;

declare
   linea varchar2(1024);
   space_columns varchar2(1024) := ' '||replace('&&columns_',',',' ')||' ';
begin
   linea:='';
   for tabla in (select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:=',CASE WHEN '||''''||space_columns||''''||' = '||''''||' * '||''''||' OR INSTR(UPPER('||''''||space_columns||''''||'),'||''''||' '||''''||'||TRIM('||''''||tabla.column_name||''''||')) > 0'||   ' THEN '||''''||''''||' ELSE '||''''||'--'||''''||' END '||tabla.column_name;
      dbms_output.put_line(linea);
   end loop;
end;
/

select 'FROM dual;' from dual;

prompt
prompt

select 'set term on' from dual;

select 'COL info FOR A80' from dual;

prompt
prompt

select 'SELECT ROWNUM, tabs.* FROM ( SELECT '||''''||'''' from dual;

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      if tabla.column_name in ('BLOCK_SIZE'
                              ,'INITIAL_EXTENT'
                              ,'NEXT_EXTENT'
                              )
                           or tabla.column_name LIKE '%BYTES%'
      then
         linea:=q'[&&]'||replace(tabla.column_name,'#','_')||'_'||' '||q'[||LPAD(']'||tabla.column_name||q'[',25,' ')]'||q'[||' : '||]'
                ||q'[ CASE WHEN NVL(]'||tabla.column_name||q'[,0) < 1024     THEN NVL(]'||tabla.column_name||q'[,0)||'']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,2) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,1),1)||'K']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,3) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,2),1)||'M']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,4) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,3),1)||'G']'
                     ||q'[ WHEN NVL(]'||tabla.column_name||q'[,0) < POWER(1024,5) THEN ROUND(NVL(]'||tabla.column_name||q'[,0)/POWER(1024,4),1)||'T']'
                     ||q'[ END ]'||q'[||CHR(10)]';
      else
         linea:=q'[&&]'||replace(tabla.column_name,'#','_')||'_'||' '||q'[||LPAD(']'||tabla.column_name||q'[',25,' ')]'||q'[||' : '||]'||q'[trim(to_char(]'||tabla.column_name||q'[))||CHR(10)]';
      end if;

      dbms_output.put_line(linea);
   end loop;
   dbms_output.put_line('info');
end;
/

declare
   linea varchar2(1024);
begin
   linea:='';
   for tabla in (select column_name from dba_tab_columns where table_name=UPPER('&&dba_table_') union all select column_name from dba_tab_cols where table_name=LOWER('&&dba_table_') order by column_name)
   loop
      linea:=q'[&&]'||replace(tabla.column_name,'#','_')||'_'||' '||','||tabla.column_name;
      dbms_output.put_line(linea);
   end loop;
end;
/

select 'FROM (SELECT '||DECODE(UPPER('&&distinct_'),'Y','DISTINCT','')||' '||q'[&&]'||'columns_'||' FROM '||q'[&&]'||'dba_table_ WHERE '||q'[&&]'||'where_ )' from dual;
select q'[&&]'||'ORDENAR_ ORDER BY '||q'[&&]'||'columns_' from dual;
select ') tabs ;' from dual;


spool off

spool salida.txt
@dbat.consulta.sql
spool off

clear columns
clear breaks
set pages 50000
set lines 200
set feed on

