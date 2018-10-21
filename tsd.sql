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

UNDEFINE columns_
UNDEFINE where_

prompt
prompt Listado de columnas:
prompt
PROMPT [ TABLESPACE_NAME  CONTENTS                 PREDICATE_EVALUATION     ]
PROMPT [ BLOCK_SIZE       LOGGING                  ENCRYPTED                ]
PROMPT [ INITIAL_EXTENT   FORCE_LOGGING            COMPRESS_FOR             ]
PROMPT [ NEXT_EXTENT      EXTENT_MANAGEMENT        DEF_INMEMORY             ]
PROMPT [ MIN_EXTENTS      ALLOCATION_TYPE          DEF_INMEMORY_PRIORITY    ]
PROMPT [ MAX_EXTENTS      PLUGGED_IN               DEF_INMEMORY_DISTRIBUTE  ]
PROMPT [ MAX_SIZE         SEGMENT_SPACE_MANAGEMENT DEF_INMEMORY_COMPRESSION ]
PROMPT [ PCT_INCREASE     DEF_TAB_COMPRESSION      DEF_INMEMORY_DUPLICATE   ]
PROMPT [ MIN_EXTLEN       RETENTION                                         ]
PROMPT [ STATUS           BIGFILE                                           ]
PROMPT
PROMPT Comun [ TABLESPACE_NAME,CONTENTS,BIGFILE,BLOCK_SIZE,EXTENT_MANAGEMENT,ALLOCATION_TYPE,SEGMENT_SPACE_MANAGEMENT ]
PROMPT

accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

column oracle_version new_value oracle_version_
column ge_90 new_value ge_90_
column ge_101 new_value ge_101_
column ge_111 new_value ge_111_
column ge_121 new_value ge_121_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 9.0 then '' else '--' end ge_90 from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ >= 12.1 then '' else '--' end ge_121 from v$instance;

COL TABLESPACE_NAME          NEW_VALUE TABLESPACE_NAME_
COL BLOCK_SIZE               NEW_VALUE BLOCK_SIZE_
COL INITIAL_EXTENT           NEW_VALUE INITIAL_EXTENT_
COL NEXT_EXTENT              NEW_VALUE NEXT_EXTENT_
COL MIN_EXTENTS              NEW_VALUE MIN_EXTENTS_
COL MAX_EXTENTS              NEW_VALUE MAX_EXTENTS_
COL MAX_SIZE                 NEW_VALUE MAX_SIZE_
COL PCT_INCREASE             NEW_VALUE PCT_INCREASE_
COL MIN_EXTLEN               NEW_VALUE MIN_EXTLEN_
COL STATUS                   NEW_VALUE STATUS_
COL CONTENTS                 NEW_VALUE CONTENTS_
COL LOGGING                  NEW_VALUE LOGGING_
COL FORCE_LOGGING            NEW_VALUE FORCE_LOGGING_
COL EXTENT_MANAGEMENT        NEW_VALUE EXTENT_MANAGEMENT_
COL ALLOCATION_TYPE          NEW_VALUE ALLOCATION_TYPE_
COL PLUGGED_IN               NEW_VALUE PLUGGED_IN_
COL SEGMENT_SPACE_MANAGEMENT NEW_VALUE SEGMENT_SPACE_MANAGEMENT_
COL DEF_TAB_COMPRESSION      NEW_VALUE DEF_TAB_COMPRESSION_
COL RETENTION                NEW_VALUE RETENTION_
COL BIGFILE                  NEW_VALUE BIGFILE_
COL PREDICATE_EVALUATION     NEW_VALUE PREDICATE_EVALUATION_
COL ENCRYPTED                NEW_VALUE ENCRYPTED_
COL COMPRESS_FOR             NEW_VALUE COMPRESS_FOR_
COL DEF_INMEMORY             NEW_VALUE DEF_INMEMORY_
COL DEF_INMEMORY_PRIORITY    NEW_VALUE DEF_INMEMORY_PRIORITY_
COL DEF_INMEMORY_DISTRIBUTE  NEW_VALUE DEF_INMEMORY_DISTRIBUTE_
COL DEF_INMEMORY_COMPRESSION NEW_VALUE DEF_INMEMORY_COMPRESSION_
COL DEF_INMEMORY_DUPLICATE   NEW_VALUE DEF_INMEMORY_DUPLICATE_
COL ORDENAR                  NEW_VALUE ORDENAR_

SELECT
 CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLESPACE_NAME         ')) > 0 THEN ''   ELSE '--' END TABLESPACE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BLOCK_SIZE              ')) > 0 THEN ''   ELSE '--' END BLOCK_SIZE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INITIAL_EXTENT          ')) > 0 THEN ''   ELSE '--' END INITIAL_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NEXT_EXTENT             ')) > 0 THEN ''   ELSE '--' END NEXT_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MIN_EXTENTS             ')) > 0 THEN ''   ELSE '--' END MIN_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_EXTENTS             ')) > 0 THEN ''   ELSE '--' END MAX_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_SIZE                ')) > 0 THEN ''   ELSE '--' END MAX_SIZE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_INCREASE            ')) > 0 THEN ''   ELSE '--' END PCT_INCREASE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MIN_EXTLEN              ')) > 0 THEN ''   ELSE '--' END MIN_EXTLEN
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('STATUS                  ')) > 0 THEN ''   ELSE '--' END STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CONTENTS                ')) > 0 THEN ''   ELSE '--' END CONTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LOGGING                 ')) > 0 THEN ''   ELSE '--' END LOGGING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FORCE_LOGGING           ')) > 0 THEN ''   ELSE '--' END FORCE_LOGGING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXTENT_MANAGEMENT       ')) > 0 THEN ''   ELSE '--' END EXTENT_MANAGEMENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ALLOCATION_TYPE         ')) > 0 THEN ''   ELSE '--' END ALLOCATION_TYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PLUGGED_IN              ')) > 0 THEN ''   ELSE '--' END PLUGGED_IN
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SEGMENT_SPACE_MANAGEMENT')) > 0 THEN ''   ELSE '--' END SEGMENT_SPACE_MANAGEMENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEF_TAB_COMPRESSION     ')) > 0 THEN ''   ELSE '--' END DEF_TAB_COMPRESSION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('RETENTION               ')) > 0 THEN ''   ELSE '--' END RETENTION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BIGFILE                 ')) > 0 THEN ''   ELSE '--' END BIGFILE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PREDICATE_EVALUATION    ')) > 0 THEN ''   ELSE '--' END PREDICATE_EVALUATION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ENCRYPTED               ')) > 0 THEN ''   ELSE '--' END ENCRYPTED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('COMPRESS_FOR            ')) > 0 THEN ''   ELSE '--' END COMPRESS_FOR
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEF_INMEMORY            ')) > 0 THEN ''   ELSE '--' END DEF_INMEMORY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEF_INMEMORY_PRIORITY   ')) > 0 THEN ''   ELSE '--' END DEF_INMEMORY_PRIORITY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEF_INMEMORY_DISTRIBUTE ')) > 0 THEN ''   ELSE '--' END DEF_INMEMORY_DISTRIBUTE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEF_INMEMORY_COMPRESSION')) > 0 THEN ''   ELSE '--' END DEF_INMEMORY_COMPRESSION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEF_INMEMORY_DUPLICATE  ')) > 0 THEN ''   ELSE '--' END DEF_INMEMORY_DUPLICATE
,CASE WHEN '&columns_' = '*'                                                                   THEN '--' ELSE ''   END ORDENAR
FROM dual
;

set term on

COL info FOR A80

COL TABLESPACE_NAME          NOPRINT
COL BLOCK_SIZE               NOPRINT
COL INITIAL_EXTENT           NOPRINT
COL NEXT_EXTENT              NOPRINT
COL MIN_EXTENTS              NOPRINT
COL MAX_EXTENTS              NOPRINT
COL MAX_SIZE                 NOPRINT
COL PCT_INCREASE             NOPRINT
COL MIN_EXTLEN               NOPRINT
COL STATUS                   NOPRINT
COL CONTENTS                 NOPRINT
COL LOGGING                  NOPRINT
COL FORCE_LOGGING            NOPRINT
COL EXTENT_MANAGEMENT        NOPRINT
COL ALLOCATION_TYPE          NOPRINT
COL PLUGGED_IN               NOPRINT
COL SEGMENT_SPACE_MANAGEMENT NOPRINT
COL DEF_TAB_COMPRESSION      NOPRINT
COL RETENTION                NOPRINT
COL BIGFILE                  NOPRINT
COL PREDICATE_EVALUATION     NOPRINT
COL ENCRYPTED                NOPRINT
COL COMPRESS_FOR             NOPRINT
COL DEF_INMEMORY             NOPRINT
COL DEF_INMEMORY_PRIORITY    NOPRINT
COL DEF_INMEMORY_DISTRIBUTE  NOPRINT
COL DEF_INMEMORY_COMPRESSION NOPRINT
COL DEF_INMEMORY_DUPLICATE   NOPRINT


SELECT rownum, tbs.*
FROM (
SELECT
                                      ''
&ge_90_  &TABLESPACE_NAME_          ||LPAD(TRIM('TABLESPACE_NAME         '),25,' ')||' : '||TABLESPACE_NAME         ||CHR(10)
&ge_90_  &STATUS_                   ||LPAD(TRIM('STATUS                  '),25,' ')||' : '||STATUS                  ||CHR(10)
&ge_90_  &CONTENTS_                 ||LPAD(TRIM('CONTENTS                '),25,' ')||' : '||CONTENTS                ||CHR(10)
&ge_101_ &BIGFILE_                  ||LPAD(TRIM('BIGFILE                 '),25,' ')||' : '||BIGFILE                 ||CHR(10)
&ge_90_  &EXTENT_MANAGEMENT_        ||LPAD(TRIM('EXTENT_MANAGEMENT       '),25,' ')||' : '||EXTENT_MANAGEMENT       ||CHR(10)
&ge_90_  &ALLOCATION_TYPE_          ||LPAD(TRIM('ALLOCATION_TYPE         '),25,' ')||' : '||ALLOCATION_TYPE         ||CHR(10)
&ge_90_  &SEGMENT_SPACE_MANAGEMENT_ ||LPAD(TRIM('SEGMENT_SPACE_MANAGEMENT'),25,' ')||' : '||SEGMENT_SPACE_MANAGEMENT||CHR(10)
&ge_111_ &COMPRESS_FOR_             ||LPAD(TRIM('COMPRESS_FOR            '),25,' ')||' : '||COMPRESS_FOR            ||CHR(10)
&ge_90_  &BLOCK_SIZE_               ||LPAD(TRIM('BLOCK_SIZE              '),25,' ')||' : '||CASE WHEN BLOCK_SIZE < 1024     THEN BLOCK_SIZE||''
&ge_90_  &BLOCK_SIZE_                                                                       WHEN BLOCK_SIZE < POWER(1024,2) THEN ROUND(BLOCK_SIZE/POWER(1024,1),1)||'K'
&ge_90_  &BLOCK_SIZE_                                                                       WHEN BLOCK_SIZE < POWER(1024,3) THEN ROUND(BLOCK_SIZE/POWER(1024,2),1)||'M'
&ge_90_  &BLOCK_SIZE_                                                                       WHEN BLOCK_SIZE < POWER(1024,4) THEN ROUND(BLOCK_SIZE/POWER(1024,3),1)||'G'
&ge_90_  &BLOCK_SIZE_                                                                       WHEN BLOCK_SIZE < POWER(1024,5) THEN ROUND(BLOCK_SIZE/POWER(1024,4),1)||'T'
&ge_90_  &BLOCK_SIZE_                                                                       END                     ||CHR(10)
&ge_90_  &INITIAL_EXTENT_           ||LPAD(TRIM('INITIAL_EXTENT          '),25,' ')||' : '||CASE WHEN INITIAL_EXTENT < 1024     THEN INITIAL_EXTENT||''
&ge_90_  &INITIAL_EXTENT_                                                                   WHEN INITIAL_EXTENT < POWER(1024,2) THEN ROUND(INITIAL_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &INITIAL_EXTENT_                                                                   WHEN INITIAL_EXTENT < POWER(1024,3) THEN ROUND(INITIAL_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &INITIAL_EXTENT_                                                                   WHEN INITIAL_EXTENT < POWER(1024,4) THEN ROUND(INITIAL_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &INITIAL_EXTENT_                                                                   WHEN INITIAL_EXTENT < POWER(1024,5) THEN ROUND(INITIAL_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &INITIAL_EXTENT_                                                                   END                     ||CHR(10)
&ge_90_  &NEXT_EXTENT_              ||LPAD(TRIM('NEXT_EXTENT             '),25,' ')||' : '||CASE WHEN NEXT_EXTENT < 1024     THEN NEXT_EXTENT||''
&ge_90_  &NEXT_EXTENT_                                                                      WHEN NEXT_EXTENT < POWER(1024,2) THEN ROUND(NEXT_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &NEXT_EXTENT_                                                                      WHEN NEXT_EXTENT < POWER(1024,3) THEN ROUND(NEXT_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &NEXT_EXTENT_                                                                      WHEN NEXT_EXTENT < POWER(1024,4) THEN ROUND(NEXT_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &NEXT_EXTENT_                                                                      WHEN NEXT_EXTENT < POWER(1024,5) THEN ROUND(NEXT_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &NEXT_EXTENT_                                                                      END                     ||CHR(10)
&ge_90_  &MIN_EXTENTS_              ||LPAD(TRIM('MIN_EXTENTS             '),25,' ')||' : '||MIN_EXTENTS             ||CHR(10)
&ge_90_  &MAX_EXTENTS_              ||LPAD(TRIM('MAX_EXTENTS             '),25,' ')||' : '||MAX_EXTENTS             ||CHR(10)
&ge_111_ &MAX_SIZE_                 ||LPAD(TRIM('MAX_SIZE                '),25,' ')||' : '||CASE WHEN MAX_SIZE < 1024     THEN MAX_SIZE||''
&ge_111_ &MAX_SIZE_                                                                         WHEN MAX_SIZE < POWER(1024,2) THEN ROUND(MAX_SIZE/POWER(1024,1),1)||'K'
&ge_111_ &MAX_SIZE_                                                                         WHEN MAX_SIZE < POWER(1024,3) THEN ROUND(MAX_SIZE/POWER(1024,2),1)||'M'
&ge_111_ &MAX_SIZE_                                                                         WHEN MAX_SIZE < POWER(1024,4) THEN ROUND(MAX_SIZE/POWER(1024,3),1)||'G'
&ge_111_ &MAX_SIZE_                                                                         WHEN MAX_SIZE < POWER(1024,5) THEN ROUND(MAX_SIZE/POWER(1024,4),1)||'T'
&ge_111_ &MAX_SIZE_                                                                         END                     ||CHR(10)
&ge_90_  &PCT_INCREASE_             ||LPAD(TRIM('PCT_INCREASE            '),25,' ')||' : '||PCT_INCREASE            ||CHR(10)
&ge_90_  &MIN_EXTLEN_               ||LPAD(TRIM('MIN_EXTLEN              '),25,' ')||' : '||CASE WHEN MIN_EXTLEN < 1024     THEN MIN_EXTLEN||''
&ge_90_  &MIN_EXTLEN_                                                                       WHEN MIN_EXTLEN < POWER(1024,2) THEN ROUND(MIN_EXTLEN/POWER(1024,1),1)||'K'
&ge_90_  &MIN_EXTLEN_                                                                       WHEN MIN_EXTLEN < POWER(1024,3) THEN ROUND(MIN_EXTLEN/POWER(1024,2),1)||'M'
&ge_90_  &MIN_EXTLEN_                                                                       WHEN MIN_EXTLEN < POWER(1024,4) THEN ROUND(MIN_EXTLEN/POWER(1024,3),1)||'G'
&ge_90_  &MIN_EXTLEN_                                                                       WHEN MIN_EXTLEN < POWER(1024,5) THEN ROUND(MIN_EXTLEN/POWER(1024,4),1)||'T'
&ge_90_  &MIN_EXTLEN_                                                                       END                     ||CHR(10)
&ge_90_  &LOGGING_                  ||LPAD(TRIM('LOGGING                 '),25,' ')||' : '||LOGGING                 ||CHR(10)
&ge_90_  &FORCE_LOGGING_            ||LPAD(TRIM('FORCE_LOGGING           '),25,' ')||' : '||FORCE_LOGGING           ||CHR(10)
&ge_90_  &PLUGGED_IN_               ||LPAD(TRIM('PLUGGED_IN              '),25,' ')||' : '||PLUGGED_IN              ||CHR(10)
&ge_101_ &DEF_TAB_COMPRESSION_      ||LPAD(TRIM('DEF_TAB_COMPRESSION     '),25,' ')||' : '||DEF_TAB_COMPRESSION     ||CHR(10)
&ge_101_ &RETENTION_                ||LPAD(TRIM('RETENTION               '),25,' ')||' : '||RETENTION               ||CHR(10)
&ge_111_ &PREDICATE_EVALUATION_     ||LPAD(TRIM('PREDICATE_EVALUATION    '),25,' ')||' : '||PREDICATE_EVALUATION    ||CHR(10)
&ge_111_ &ENCRYPTED_                ||LPAD(TRIM('ENCRYPTED               '),25,' ')||' : '||ENCRYPTED               ||CHR(10)
&ge_121_ &DEF_INMEMORY_             ||LPAD(TRIM('DEF_INMEMORY            '),25,' ')||' : '||DEF_INMEMORY            ||CHR(10)
&ge_121_ &DEF_INMEMORY_PRIORITY_    ||LPAD(TRIM('DEF_INMEMORY_PRIORITY   '),25,' ')||' : '||DEF_INMEMORY_PRIORITY   ||CHR(10)
&ge_121_ &DEF_INMEMORY_DISTRIBUTE_  ||LPAD(TRIM('DEF_INMEMORY_DISTRIBUTE '),25,' ')||' : '||DEF_INMEMORY_DISTRIBUTE ||CHR(10)
&ge_121_ &DEF_INMEMORY_COMPRESSION_ ||LPAD(TRIM('DEF_INMEMORY_COMPRESSION'),25,' ')||' : '||DEF_INMEMORY_COMPRESSION||CHR(10)
&ge_121_ &DEF_INMEMORY_DUPLICATE_   ||LPAD(TRIM('DEF_INMEMORY_DUPLICATE  '),25,' ')||' : '||DEF_INMEMORY_DUPLICATE  ||CHR(10)
info
&ge_90_  &TABLESPACE_NAME_           ,TABLESPACE_NAME
&ge_90_  &STATUS_                    ,STATUS
&ge_90_  &CONTENTS_                  ,CONTENTS
&ge_101_ &BIGFILE_                   ,BIGFILE
&ge_90_  &EXTENT_MANAGEMENT_         ,EXTENT_MANAGEMENT
&ge_90_  &ALLOCATION_TYPE_           ,ALLOCATION_TYPE
&ge_90_  &SEGMENT_SPACE_MANAGEMENT_  ,SEGMENT_SPACE_MANAGEMENT
&ge_111_ &COMPRESS_FOR_              ,COMPRESS_FOR
&ge_90_  &BLOCK_SIZE_                ,BLOCK_SIZE
&ge_90_  &INITIAL_EXTENT_            ,INITIAL_EXTENT
&ge_90_  &NEXT_EXTENT_               ,NEXT_EXTENT
&ge_90_  &MIN_EXTENTS_               ,MIN_EXTENTS
&ge_90_  &MAX_EXTENTS_               ,MAX_EXTENTS
&ge_111_ &MAX_SIZE_                  ,MAX_SIZE
&ge_90_  &PCT_INCREASE_              ,PCT_INCREASE
&ge_90_  &MIN_EXTLEN_                ,MIN_EXTLEN
&ge_90_  &LOGGING_                   ,LOGGING
&ge_90_  &FORCE_LOGGING_             ,FORCE_LOGGING
&ge_90_  &PLUGGED_IN_                ,PLUGGED_IN
&ge_101_ &DEF_TAB_COMPRESSION_       ,DEF_TAB_COMPRESSION
&ge_101_ &RETENTION_                 ,RETENTION
&ge_111_ &PREDICATE_EVALUATION_      ,PREDICATE_EVALUATION
&ge_111_ &ENCRYPTED_                 ,ENCRYPTED
&ge_121_ &DEF_INMEMORY_              ,DEF_INMEMORY
&ge_121_ &DEF_INMEMORY_PRIORITY_     ,DEF_INMEMORY_PRIORITY
&ge_121_ &DEF_INMEMORY_DISTRIBUTE_   ,DEF_INMEMORY_DISTRIBUTE
&ge_121_ &DEF_INMEMORY_COMPRESSION_  ,DEF_INMEMORY_COMPRESSION
&ge_121_ &DEF_INMEMORY_DUPLICATE_    ,DEF_INMEMORY_DUPLICATE
FROM dba_tablespaces
WHERE &where_
&ORDENAR_ ORDER BY &columns_
) tbs
;

CLEAR COLUMNS
CLEAR BREAKS
