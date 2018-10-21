--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
SET LINES 200
SET PAGES 0
SET VERIFY OFF

CLEAR BREAKS
CLEAR COLUMNS

COL info FOR A80

UNDEFINE columns_
UNDEFINE where_

prompt
prompt Listado de columnas:
prompt
PROMPT [ FILE_NAME       STATUS         INCREMENT_BY       ]
PROMPT [ FILE_ID         RELATIVE_FNO   USER_BYTES         ]
PROMPT [ TABLESPACE_NAME AUTOEXTENSIBLE USER_BLOCKS        ]
PROMPT [ BYTES           MAXBYTES       ONLINE_STATUS      ]
PROMPT [ BLOCKS          MAXBLOCKS      LOST_WRITE_PROTECT ]
PROMPT
PROMPT Comun [ TABLESPACE_NAME,FILE_NAME,BYTES,MAXBYTES,AUTOEXTENSIBLE ]
PROMPT

accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

column oracle_version new_value oracle_version_
column ge_90 new_value ge_90_
column ge_102 new_value ge_102_
column ge_122 new_value ge_122_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 9.0 then '' else '--' end ge_90 from v$instance;
select case when &oracle_version_ >= 10.2 then '' else '--' end ge_102 from v$instance;
select case when &oracle_version_ >= 12.2 then '' else '--' end ge_122 from v$instance;

COL FILE_NAME          NEW_VALUE FILE_NAME_
COL FILE_ID            NEW_VALUE FILE_ID_
COL TABLESPACE_NAME    NEW_VALUE TABLESPACE_NAME_
COL BYTES              NEW_VALUE BYTES_
COL BLOCKS             NEW_VALUE BLOCKS_
COL STATUS             NEW_VALUE STATUS_
COL RELATIVE_FNO       NEW_VALUE RELATIVE_FNO_
COL AUTOEXTENSIBLE     NEW_VALUE AUTOEXTENSIBLE_
COL MAXBYTES           NEW_VALUE MAXBYTES_
COL MAXBLOCKS          NEW_VALUE MAXBLOCKS_
COL INCREMENT_BY       NEW_VALUE INCREMENT_BY_
COL USER_BYTES         NEW_VALUE USER_BYTES_
COL USER_BLOCKS        NEW_VALUE USER_BLOCKS_
COL ONLINE_STATUS      NEW_VALUE ONLINE_STATUS_
COL LOST_WRITE_PROTECT NEW_VALUE LOST_WRITE_PROTECT_
COL ORDENAR            NEW_VALUE ORDENAR_

SELECT
 CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FILE_NAME         ')) > 0 THEN ''   ELSE '--' END FILE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FILE_ID           ')) > 0 THEN ''   ELSE '--' END FILE_ID
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLESPACE_NAME   ')) > 0 THEN ''   ELSE '--' END TABLESPACE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BYTES             ')) > 0 THEN ''   ELSE '--' END BYTES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BLOCKS            ')) > 0 THEN ''   ELSE '--' END BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('STATUS            ')) > 0 THEN ''   ELSE '--' END STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('RELATIVE_FNO      ')) > 0 THEN ''   ELSE '--' END RELATIVE_FNO
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AUTOEXTENSIBLE    ')) > 0 THEN ''   ELSE '--' END AUTOEXTENSIBLE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAXBYTES          ')) > 0 THEN ''   ELSE '--' END MAXBYTES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAXBLOCKS         ')) > 0 THEN ''   ELSE '--' END MAXBLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INCREMENT_BY      ')) > 0 THEN ''   ELSE '--' END INCREMENT_BY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('USER_BYTES        ')) > 0 THEN ''   ELSE '--' END USER_BYTES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('USER_BLOCKS       ')) > 0 THEN ''   ELSE '--' END USER_BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ONLINE_STATUS     ')) > 0 THEN ''   ELSE '--' END ONLINE_STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LOST_WRITE_PROTECT')) > 0 THEN ''   ELSE '--' END LOST_WRITE_PROTECT
,CASE WHEN '&columns_' = '*'                                                             THEN '--' ELSE ''   END ORDENAR
FROM dual
;

set term on

COL FILE_NAME          NOPRINT
COL FILE_ID            NOPRINT
COL TABLESPACE_NAME    NOPRINT
COL BYTES              NOPRINT
COL BLOCKS             NOPRINT
COL STATUS             NOPRINT
COL RELATIVE_FNO       NOPRINT
COL AUTOEXTENSIBLE     NOPRINT
COL MAXBYTES           NOPRINT
COL MAXBLOCKS          NOPRINT
COL INCREMENT_BY       NOPRINT
COL USER_BYTES         NOPRINT
COL USER_BLOCKS        NOPRINT
COL ONLINE_STATUS      NOPRINT
COL LOST_WRITE_PROTECT NOPRINT

SELECT ROWNUM, dbfs.*
FROM (
SELECT
                                ''
&ge_90_  &TABLESPACE_NAME_    ||LPAD(TRIM('TABLESPACE_NAME   '),18,' ')||' : '||TABLESPACE_NAME    ||CHR(10)
&ge_90_  &FILE_ID_            ||LPAD(TRIM('FILE_ID           '),18,' ')||' : '||FILE_ID            ||CHR(10)
&ge_90_  &FILE_NAME_          ||LPAD(TRIM('FILE_NAME         '),18,' ')||' : '||FILE_NAME          ||CHR(10)
&ge_90_  &BYTES_              ||LPAD(TRIM('BYTES             '),18,' ')||' : '||CASE WHEN bytes < 1024          THEN bytes ||''
&ge_90_  &BYTES_                                                                WHEN bytes < POWER(1024,2) THEN ROUND(bytes/POWER(1024,1),1)||'K'
&ge_90_  &BYTES_                                                                WHEN bytes < POWER(1024,3) THEN ROUND(bytes/POWER(1024,2),1)||'M'
&ge_90_  &BYTES_                                                                WHEN bytes < POWER(1024,4) THEN ROUND(bytes/POWER(1024,3),1)||'G'
&ge_90_  &BYTES_                                                                WHEN bytes < POWER(1024,5) THEN ROUND(bytes/POWER(1024,4),1)||'T'
&ge_90_  &BYTES_                                                                END                ||CHR(10)
&ge_90_  &BLOCKS_             ||LPAD(TRIM('BLOCKS            '),18,' ')||' : '||BLOCKS             ||CHR(10)
&ge_90_  &STATUS_             ||LPAD(TRIM('STATUS            '),18,' ')||' : '||STATUS             ||CHR(10)
&ge_90_  &RELATIVE_FNO_       ||LPAD(TRIM('RELATIVE_FNO      '),18,' ')||' : '||RELATIVE_FNO       ||CHR(10)
&ge_90_  &AUTOEXTENSIBLE_     ||LPAD(TRIM('AUTOEXTENSIBLE    '),18,' ')||' : '||AUTOEXTENSIBLE     ||CHR(10)
&ge_90_  &MAXBYTES_           ||LPAD(TRIM('MAXBYTES          '),18,' ')||' : '||CASE WHEN maxbytes < 1024          THEN maxbytes ||''
&ge_90_  &MAXBYTES_                                                             WHEN maxbytes < POWER(1024,2) THEN ROUND(maxbytes/POWER(1024,1),1)||'K'
&ge_90_  &MAXBYTES_                                                             WHEN maxbytes < POWER(1024,3) THEN ROUND(maxbytes/POWER(1024,2),1)||'M'
&ge_90_  &MAXBYTES_                                                             WHEN maxbytes < POWER(1024,4) THEN ROUND(maxbytes/POWER(1024,3),1)||'G'
&ge_90_  &MAXBYTES_                                                             WHEN maxbytes < POWER(1024,5) THEN ROUND(maxbytes/POWER(1024,4),1)||'T'
&ge_90_  &MAXBYTES_                                                             END                ||CHR(10)
&ge_90_  &MAXBLOCKS_          ||LPAD(TRIM('MAXBLOCKS         '),18,' ')||' : '||MAXBLOCKS          ||CHR(10)
&ge_90_  &INCREMENT_BY_       ||LPAD(TRIM('INCREMENT_BY      '),18,' ')||' : '||INCREMENT_BY       ||CHR(10)
&ge_90_  &USER_BYTES_         ||LPAD(TRIM('USER_BYTES        '),18,' ')||' : '||CASE WHEN user_bytes < 1024          THEN user_bytes ||''
&ge_90_  &USER_BYTES_                                                           WHEN user_bytes < POWER(1024,2) THEN ROUND(user_bytes/POWER(1024,1),1)||'K'
&ge_90_  &USER_BYTES_                                                           WHEN user_bytes < POWER(1024,3) THEN ROUND(user_bytes/POWER(1024,2),1)||'M'
&ge_90_  &USER_BYTES_                                                           WHEN user_bytes < POWER(1024,4) THEN ROUND(user_bytes/POWER(1024,3),1)||'G'
&ge_90_  &USER_BYTES_                                                           WHEN user_bytes < POWER(1024,5) THEN ROUND(user_bytes/POWER(1024,4),1)||'T'
&ge_90_  &USER_BYTES_                                                           END                ||CHR(10)
&ge_90_  &USER_BLOCKS_        ||LPAD(TRIM('USER_BLOCKS       '),18,' ')||' : '||USER_BLOCKS        ||CHR(10)
&ge_102_ &ONLINE_STATUS_      ||LPAD(TRIM('ONLINE_STATUS     '),18,' ')||' : '||ONLINE_STATUS      ||CHR(10)
&ge_122_ &LOST_WRITE_PROTECT_ ||LPAD(TRIM('LOST_WRITE_PROTECT'),18,' ')||' : '||LOST_WRITE_PROTECT ||CHR(10)
info
&ge_90_  &TABLESPACE_NAME_    ,TABLESPACE_NAME
&ge_90_  &FILE_ID_            ,FILE_ID
&ge_90_  &FILE_NAME_          ,FILE_NAME
&ge_90_  &BYTES_              ,BYTES
&ge_90_  &BLOCKS_             ,BLOCKS
&ge_90_  &STATUS_             ,STATUS
&ge_90_  &RELATIVE_FNO_       ,RELATIVE_FNO
&ge_90_  &AUTOEXTENSIBLE_     ,AUTOEXTENSIBLE
&ge_90_  &MAXBYTES_           ,MAXBYTES
&ge_90_  &MAXBLOCKS_          ,MAXBLOCKS
&ge_90_  &INCREMENT_BY_       ,INCREMENT_BY
&ge_90_  &USER_BYTES_         ,USER_BYTES
&ge_90_  &USER_BLOCKS_        ,USER_BLOCKS
&ge_102_ &ONLINE_STATUS_      ,ONLINE_STATUS
&ge_122_ &LOST_WRITE_PROTECT_ ,LOST_WRITE_PROTECT
FROM dba_data_files
WHERE &where_
& ORDENAR_ ORDER BY &columns_
) dbfs
;

CLEAR COLUMNS
CLEAR BREAKS
