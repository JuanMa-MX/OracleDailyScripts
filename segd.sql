--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com

SET LINES 200
SET PAGES 0
SET VERIFY OFF

CLEAR BREAKS
CLEAR COLUMNS

UNDEFINE where_
UNDEFINE columns_

PROMPT
PROMPT Listado de columnas:
PROMPT
PROMPT [ OWNER           BYTES          RETENTION       CELL_FLASH_CACHE     ]
PROMPT [ SEGMENT_NAME    BLOCKS         MINRETENTION    INMEMORY             ]
PROMPT [ PARTITION_NAME  EXTENTS        PCT_INCREASE    INMEMORY_PRIORITY    ]
PROMPT [ SEGMENT_TYPE    INITIAL_EXTENT FREELISTS       INMEMORY_DISTRIBUTE  ]
PROMPT [ SEGMENT_SUBTYPE NEXT_EXTENT    FREELIST_GROUPS INMEMORY_DUPLICATE   ]
PROMPT [ TABLESPACE_NAME MIN_EXTENTS    RELATIVE_FNO    INMEMORY_COMPRESSION ]
PROMPT [ HEADER_FILE     MAX_EXTENTS    BUFFER_POOL     CELLMEMORY           ]
PROMPT [ HEADER_BLOCK    MAX_SIZE       FLASH_CACHE                          ]
PROMPT
PROMPT Comun [ OWNER,SEGMENT_NAME,PARTITION_NAME,BYTES,TABLESPACE_NAME ]
PROMPT

accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

column oracle_version new_value oracle_version_
column ge_90  new_value ge_90_
column ge_111 new_value ge_111_
column ge_112 new_value ge_112_
column ge_121 new_value ge_121_
column ge_122 new_value ge_122_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 9.0  then '' else '--' end ge_90 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 12.1 then '' else '--' end ge_121 from v$instance;
select case when &oracle_version_ >= 12.2 then '' else '--' end ge_122 from v$instance;

COL OWNER                NEW_VALUE OWNER_
COL SEGMENT_NAME         NEW_VALUE SEGMENT_NAME_
COL PARTITION_NAME       NEW_VALUE PARTITION_NAME_
COL SEGMENT_TYPE         NEW_VALUE SEGMENT_TYPE_
COL SEGMENT_SUBTYPE      NEW_VALUE SEGMENT_SUBTYPE_
COL TABLESPACE_NAME      NEW_VALUE TABLESPACE_NAME_
COL HEADER_FILE          NEW_VALUE HEADER_FILE_
COL HEADER_BLOCK         NEW_VALUE HEADER_BLOCK_
COL BYTES                NEW_VALUE BYTES_
COL BLOCKS               NEW_VALUE BLOCKS_
COL EXTENTS              NEW_VALUE EXTENTS_
COL INITIAL_EXTENT       NEW_VALUE INITIAL_EXTENT_
COL NEXT_EXTENT          NEW_VALUE NEXT_EXTENT_
COL MIN_EXTENTS          NEW_VALUE MIN_EXTENTS_
COL MAX_EXTENTS          NEW_VALUE MAX_EXTENTS_
COL MAX_SIZE             NEW_VALUE MAX_SIZE_
COL RETENTION            NEW_VALUE RETENTION_
COL MINRETENTION         NEW_VALUE MINRETENTION_
COL PCT_INCREASE         NEW_VALUE PCT_INCREASE_
COL FREELISTS            NEW_VALUE FREELISTS_
COL FREELIST_GROUPS      NEW_VALUE FREELIST_GROUPS_
COL RELATIVE_FNO         NEW_VALUE RELATIVE_FNO_
COL BUFFER_POOL          NEW_VALUE BUFFER_POOL_
COL FLASH_CACHE          NEW_VALUE FLASH_CACHE_
COL CELL_FLASH_CACHE     NEW_VALUE CELL_FLASH_CACHE_
COL INMEMORY             NEW_VALUE INMEMORY_
COL INMEMORY_PRIORITY    NEW_VALUE INMEMORY_PRIORITY_
COL INMEMORY_DISTRIBUTE  NEW_VALUE INMEMORY_DISTRIBUTE_
COL INMEMORY_DUPLICATE   NEW_VALUE INMEMORY_DUPLICATE_
COL INMEMORY_COMPRESSION NEW_VALUE INMEMORY_COMPRESSION_
COL CELLMEMORY           NEW_VALUE CELLMEMORY_
COL ORDENAR              NEW_VALUE ORDENAR_

SELECT
 CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('OWNER               ')) > 0 THEN ''   ELSE '--' END OWNER
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SEGMENT_NAME        ')) > 0 THEN ''   ELSE '--' END SEGMENT_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PARTITION_NAME      ')) > 0 THEN ''   ELSE '--' END PARTITION_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SEGMENT_TYPE        ')) > 0 THEN ''   ELSE '--' END SEGMENT_TYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SEGMENT_SUBTYPE     ')) > 0 THEN ''   ELSE '--' END SEGMENT_SUBTYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLESPACE_NAME     ')) > 0 THEN ''   ELSE '--' END TABLESPACE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('HEADER_FILE         ')) > 0 THEN ''   ELSE '--' END HEADER_FILE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('HEADER_BLOCK        ')) > 0 THEN ''   ELSE '--' END HEADER_BLOCK
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BYTES               ')) > 0 THEN ''   ELSE '--' END BYTES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BLOCKS              ')) > 0 THEN ''   ELSE '--' END BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXTENTS             ')) > 0 THEN ''   ELSE '--' END EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INITIAL_EXTENT      ')) > 0 THEN ''   ELSE '--' END INITIAL_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NEXT_EXTENT         ')) > 0 THEN ''   ELSE '--' END NEXT_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MIN_EXTENTS         ')) > 0 THEN ''   ELSE '--' END MIN_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_EXTENTS         ')) > 0 THEN ''   ELSE '--' END MAX_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_SIZE            ')) > 0 THEN ''   ELSE '--' END MAX_SIZE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('RETENTION           ')) > 0 THEN ''   ELSE '--' END RETENTION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MINRETENTION        ')) > 0 THEN ''   ELSE '--' END MINRETENTION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_INCREASE        ')) > 0 THEN ''   ELSE '--' END PCT_INCREASE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FREELISTS           ')) > 0 THEN ''   ELSE '--' END FREELISTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FREELIST_GROUPS     ')) > 0 THEN ''   ELSE '--' END FREELIST_GROUPS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('RELATIVE_FNO        ')) > 0 THEN ''   ELSE '--' END RELATIVE_FNO
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BUFFER_POOL         ')) > 0 THEN ''   ELSE '--' END BUFFER_POOL
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FLASH_CACHE         ')) > 0 THEN ''   ELSE '--' END FLASH_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CELL_FLASH_CACHE    ')) > 0 THEN ''   ELSE '--' END CELL_FLASH_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY            ')) > 0 THEN ''   ELSE '--' END INMEMORY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_PRIORITY   ')) > 0 THEN ''   ELSE '--' END INMEMORY_PRIORITY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_DISTRIBUTE ')) > 0 THEN ''   ELSE '--' END INMEMORY_DISTRIBUTE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_DUPLICATE  ')) > 0 THEN ''   ELSE '--' END INMEMORY_DUPLICATE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_COMPRESSION')) > 0 THEN ''   ELSE '--' END INMEMORY_COMPRESSION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CELLMEMORY          ')) > 0 THEN ''   ELSE '--' END CELLMEMORY
,CASE WHEN '&columns_' = '*'                                                               THEN '--' ELSE ''   END ORDENAR
FROM dual
;

set term on

CLEAR BREAKS
CLEAR COLUMNS

COL info FOR A80

COL OWNER                NOPRINT
COL SEGMENT_NAME         NOPRINT
COL PARTITION_NAME       NOPRINT
COL SEGMENT_TYPE         NOPRINT
COL SEGMENT_SUBTYPE      NOPRINT
COL TABLESPACE_NAME      NOPRINT
COL HEADER_FILE          NOPRINT
COL HEADER_BLOCK         NOPRINT
COL BYTES                NOPRINT
COL BLOCKS               NOPRINT
COL EXTENTS              NOPRINT
COL INITIAL_EXTENT       NOPRINT
COL NEXT_EXTENT          NOPRINT
COL MIN_EXTENTS          NOPRINT
COL MAX_EXTENTS          NOPRINT
COL MAX_SIZE             NOPRINT
COL RETENTION            NOPRINT
COL MINRETENTION         NOPRINT
COL PCT_INCREASE         NOPRINT
COL FREELISTS            NOPRINT
COL FREELIST_GROUPS      NOPRINT
COL RELATIVE_FNO         NOPRINT
COL BUFFER_POOL          NOPRINT
COL FLASH_CACHE          NOPRINT
COL CELL_FLASH_CACHE     NOPRINT
COL INMEMORY             NOPRINT
COL INMEMORY_PRIORITY    NOPRINT
COL INMEMORY_DISTRIBUTE  NOPRINT
COL INMEMORY_DUPLICATE   NOPRINT
COL INMEMORY_COMPRESSION NOPRINT
COL CELLMEMORY           NOPRINT

SELECT ROWNUM, segs.*
FROM (
SELECT                            ''
&ge_90_  &OWNER_                ||LPAD(TRIM('OWNER                '),20,' ')||' : '||OWNER               ||CHR(10)
&ge_90_  &SEGMENT_NAME_         ||LPAD(TRIM('SEGMENT_NAME         '),20,' ')||' : '||SEGMENT_NAME        ||CHR(10)
&ge_90_  &PARTITION_NAME_       ||LPAD(TRIM('PARTITION_NAME       '),20,' ')||' : '||PARTITION_NAME      ||CHR(10)
&ge_90_  &SEGMENT_TYPE_         ||LPAD(TRIM('SEGMENT_TYPE         '),20,' ')||' : '||SEGMENT_TYPE        ||CHR(10)
&ge_111_ &SEGMENT_SUBTYPE_      ||LPAD(TRIM('SEGMENT_SUBTYPE      '),20,' ')||' : '||SEGMENT_SUBTYPE     ||CHR(10)
&ge_90_  &TABLESPACE_NAME_      ||LPAD(TRIM('TABLESPACE_NAME      '),20,' ')||' : '||TABLESPACE_NAME     ||CHR(10)
&ge_90_  &HEADER_FILE_          ||LPAD(TRIM('HEADER_FILE          '),20,' ')||' : '||HEADER_FILE         ||CHR(10)
&ge_90_  &HEADER_BLOCK_         ||LPAD(TRIM('HEADER_BLOCK         '),20,' ')||' : '||HEADER_BLOCK        ||CHR(10)
&ge_90_  &BYTES_                ||LPAD(TRIM('BYTES                '),20,' ')||' : '||CASE WHEN BYTES < 1024          THEN bytes ||''
&ge_90_  &BYTES_                                                                     WHEN BYTES < POWER(1024,2) THEN ROUND(BYTES/POWER(1024,1),1)||'K'
&ge_90_  &BYTES_                                                                     WHEN BYTES < POWER(1024,3) THEN ROUND(BYTES/POWER(1024,2),1)||'M'
&ge_90_  &BYTES_                                                                     WHEN BYTES < POWER(1024,4) THEN ROUND(BYTES/POWER(1024,3),1)||'G'
&ge_90_  &BYTES_                                                                     WHEN BYTES < POWER(1024,5) THEN ROUND(BYTES/POWER(1024,4),1)||'T'
&ge_90_  &BYTES_                                                                     END                 ||CHR(10)
&ge_90_  &BLOCKS_               ||LPAD(TRIM('BLOCKS               '),20,' ')||' : '||BLOCKS              ||CHR(10)
&ge_90_  &EXTENTS_              ||LPAD(TRIM('EXTENTS              '),20,' ')||' : '||EXTENTS             ||CHR(10)
&ge_90_  &INITIAL_EXTENT_       ||LPAD(TRIM('INITIAL_EXTENT       '),20,' ')||' : '||CASE WHEN INITIAL_EXTENT < 1024     THEN INITIAL_EXTENT||''
&ge_90_  &INITIAL_EXTENT_                                                            WHEN INITIAL_EXTENT < POWER(1024,2) THEN ROUND(INITIAL_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &INITIAL_EXTENT_                                                            WHEN INITIAL_EXTENT < POWER(1024,3) THEN ROUND(INITIAL_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &INITIAL_EXTENT_                                                            WHEN INITIAL_EXTENT < POWER(1024,4) THEN ROUND(INITIAL_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &INITIAL_EXTENT_                                                            WHEN INITIAL_EXTENT < POWER(1024,5) THEN ROUND(INITIAL_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &INITIAL_EXTENT_                                                            END                 ||CHR(10)
&ge_90_  &NEXT_EXTENT_          ||LPAD(TRIM('NEXT_EXTENT          '),20,' ')||' : '||CASE WHEN NEXT_EXTENT < 1024     THEN NEXT_EXTENT||''
&ge_90_  &NEXT_EXTENT_                                                               WHEN NEXT_EXTENT < POWER(1024,2) THEN ROUND(NEXT_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &NEXT_EXTENT_                                                               WHEN NEXT_EXTENT < POWER(1024,3) THEN ROUND(NEXT_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &NEXT_EXTENT_                                                               WHEN NEXT_EXTENT < POWER(1024,4) THEN ROUND(NEXT_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &NEXT_EXTENT_                                                               WHEN NEXT_EXTENT < POWER(1024,5) THEN ROUND(NEXT_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &NEXT_EXTENT_                                                               END                 ||CHR(10)
&ge_90_  &MIN_EXTENTS_          ||LPAD(TRIM('MIN_EXTENTS          '),20,' ')||' : '||MIN_EXTENTS         ||CHR(10)
&ge_90_  &MAX_EXTENTS_          ||LPAD(TRIM('MAX_EXTENTS          '),20,' ')||' : '||MAX_EXTENTS         ||CHR(10)
&ge_111_ &MAX_SIZE_             ||LPAD(TRIM('MAX_SIZE             '),20,' ')||' : '||CASE WHEN MAX_SIZE < 1024     THEN MAX_SIZE||''
&ge_111_ &MAX_SIZE_                                                                  WHEN MAX_SIZE < POWER(1024,2) THEN ROUND(MAX_SIZE/POWER(1024,1),1)||'K'
&ge_111_ &MAX_SIZE_                                                                  WHEN MAX_SIZE < POWER(1024,3) THEN ROUND(MAX_SIZE/POWER(1024,2),1)||'M'
&ge_111_ &MAX_SIZE_                                                                  WHEN MAX_SIZE < POWER(1024,4) THEN ROUND(MAX_SIZE/POWER(1024,3),1)||'G'
&ge_111_ &MAX_SIZE_                                                                  WHEN MAX_SIZE < POWER(1024,5) THEN ROUND(MAX_SIZE/POWER(1024,4),1)||'T'
&ge_111_ &MAX_SIZE_                                                                  END                 ||CHR(10)
&ge_111_ &RETENTION_            ||LPAD(TRIM('RETENTION            '),20,' ')||' : '||RETENTION           ||CHR(10)
&ge_111_ &MINRETENTION_         ||LPAD(TRIM('MINRETENTION         '),20,' ')||' : '||MINRETENTION        ||CHR(10)
&ge_90_  &PCT_INCREASE_         ||LPAD(TRIM('PCT_INCREASE         '),20,' ')||' : '||PCT_INCREASE        ||CHR(10)
&ge_90_  &FREELISTS_            ||LPAD(TRIM('FREELISTS            '),20,' ')||' : '||FREELISTS           ||CHR(10)
&ge_90_  &FREELIST_GROUPS_      ||LPAD(TRIM('FREELIST_GROUPS      '),20,' ')||' : '||FREELIST_GROUPS     ||CHR(10)
&ge_90_  &RELATIVE_FNO_         ||LPAD(TRIM('RELATIVE_FNO         '),20,' ')||' : '||RELATIVE_FNO        ||CHR(10)
&ge_90_  &BUFFER_POOL_          ||LPAD(TRIM('BUFFER_POOL          '),20,' ')||' : '||BUFFER_POOL         ||CHR(10)
&ge_112_ &FLASH_CACHE_          ||LPAD(TRIM('FLASH_CACHE          '),20,' ')||' : '||FLASH_CACHE         ||CHR(10)
&ge_112_ &CELL_FLASH_CACHE_     ||LPAD(TRIM('CELL_FLASH_CACHE     '),20,' ')||' : '||CELL_FLASH_CACHE    ||CHR(10)
&ge_121_ &INMEMORY_             ||LPAD(TRIM('INMEMORY             '),20,' ')||' : '||INMEMORY            ||CHR(10)
&ge_121_ &INMEMORY_PRIORITY_    ||LPAD(TRIM('INMEMORY_PRIORITY    '),20,' ')||' : '||INMEMORY_PRIORITY   ||CHR(10)
&ge_121_ &INMEMORY_DISTRIBUTE_  ||LPAD(TRIM('INMEMORY_DISTRIBUTE  '),20,' ')||' : '||INMEMORY_DISTRIBUTE ||CHR(10)
&ge_121_ &INMEMORY_DUPLICATE_   ||LPAD(TRIM('INMEMORY_DUPLICATE   '),20,' ')||' : '||INMEMORY_DUPLICATE  ||CHR(10)
&ge_121_ &INMEMORY_COMPRESSION_ ||LPAD(TRIM('INMEMORY_COMPRESSION '),20,' ')||' : '||INMEMORY_COMPRESSION||CHR(10)
&ge_122_ &CELLMEMORY_           ||LPAD(TRIM('CELLMEMORY           '),20,' ')||' : '||CELLMEMORY          ||CHR(10)
info
&ge_90_  &OWNER_                ,OWNER
&ge_90_  &SEGMENT_NAME_         ,SEGMENT_NAME
&ge_90_  &PARTITION_NAME_       ,PARTITION_NAME
&ge_90_  &SEGMENT_TYPE_         ,SEGMENT_TYPE
&ge_111_ &SEGMENT_SUBTYPE_      ,SEGMENT_SUBTYPE
&ge_90_  &TABLESPACE_NAME_      ,TABLESPACE_NAME
&ge_90_  &HEADER_FILE_          ,HEADER_FILE
&ge_90_  &HEADER_BLOCK_         ,HEADER_BLOCK
&ge_90_  &BYTES_                ,BYTES
&ge_90_  &BLOCKS_               ,BLOCKS
&ge_90_  &EXTENTS_              ,EXTENTS
&ge_90_  &INITIAL_EXTENT_       ,INITIAL_EXTENT
&ge_90_  &NEXT_EXTENT_          ,NEXT_EXTENT
&ge_90_  &MIN_EXTENTS_          ,MIN_EXTENTS
&ge_90_  &MAX_EXTENTS_          ,MAX_EXTENTS
&ge_111_ &MAX_SIZE_             ,MAX_SIZE
&ge_111_ &RETENTION_            ,RETENTION
&ge_111_ &MINRETENTION_         ,MINRETENTION
&ge_90_  &PCT_INCREASE_         ,PCT_INCREASE
&ge_90_  &FREELISTS_            ,FREELISTS
&ge_90_  &FREELIST_GROUPS_      ,FREELIST_GROUPS
&ge_90_  &RELATIVE_FNO_         ,RELATIVE_FNO
&ge_90_  &BUFFER_POOL_          ,BUFFER_POOL
&ge_112_ &FLASH_CACHE_          ,FLASH_CACHE
&ge_112_ &CELL_FLASH_CACHE_     ,CELL_FLASH_CACHE
&ge_121_ &INMEMORY_             ,INMEMORY
&ge_121_ &INMEMORY_PRIORITY_    ,INMEMORY_PRIORITY
&ge_121_ &INMEMORY_DISTRIBUTE_  ,INMEMORY_DISTRIBUTE
&ge_121_ &INMEMORY_DUPLICATE_   ,INMEMORY_DUPLICATE
&ge_121_ &INMEMORY_COMPRESSION_ ,INMEMORY_COMPRESSION
&ge_122_ &CELLMEMORY_           ,CELLMEMORY
FROM dba_segments
WHERE &where_
&ORDENAR_ ORDER BY &columns_
) segs
;

CLEAR BREAKS
CLEAR COLUMNS
