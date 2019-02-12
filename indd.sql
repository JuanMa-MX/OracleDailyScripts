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
PROMPT [ OWNER           MAX_EXTENTS             NUM_ROWS          ITYP_OWNER              ]
PROMPT [ INDEX_NAME      PCT_INCREASE            SAMPLE_SIZE       ITYP_NAME               ]
PROMPT [ INDEX_TYPE      PCT_THRESHOLD           LAST_ANALYZED     PARAMETERS              ]
PROMPT [ TABLE_OWNER     INCLUDE_COLUMN          DEGREE            GLOBAL_STATS            ]
PROMPT [ TABLE_NAME      FREELISTS               INSTANCES         DOMIDX_STATUS           ]
PROMPT [ TABLE_TYPE      FREELIST_GROUPS         PARTITIONED       DOMIDX_OPSTATUS         ]
PROMPT [ UNIQUENESS      PCT_FREE                TEMPORARY         FUNCIDX_STATUS          ]
PROMPT [ COMPRESSION     LOGGING                 GENERATED         JOIN_INDEX              ]
PROMPT [ PREFIX_LENGTH   BLEVEL                  SECONDARY         IOT_REDUNDANT_PKEY_ELIM ]
PROMPT [ TABLESPACE_NAME LEAF_BLOCKS             BUFFER_POOL       DROPPED                 ]
PROMPT [ INI_TRANS       DISTINCT_KEYS           FLASH_CACHE       VISIBILITY              ]
PROMPT [ MAX_TRANS       AVG_LEAF_BLOCKS_PER_KEY CELL_FLASH_CACHE  DOMIDX_MANAGEMENT       ]
PROMPT [ INITIAL_EXTENT  AVG_DATA_BLOCKS_PER_KEY USER_STATS        SEGMENT_CREATED         ]
PROMPT [ NEXT_EXTENT     CLUSTERING_FACTOR       DURATION          ORPHANED_ENTRIES        ]
PROMPT [ MIN_EXTENTS     STATUS                  PCT_DIRECT_ACCESS INDEXING                ]
PROMPT
PROMPT Comun  [ OWNER,INDEX_NAME,INDEX_TYPE,TABLE_OWNER,TABLE_NAME,TABLESPACE_NAME,STATUS ]
PROMPT Tuning [ TABLE_OWNER,TABLE_NAME,INDEX_NAME,INDEX_TYPE,INI_TRANS,FREELISTS,FREELIST_GROUPS,STATUS,NUM_ROWS,SAMPLE_SIZE,LAST_ANALYZED,DEGREE,PARTITIONED ]
PROMPT

accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

column oracle_version new_value oracle_version_
column ge_90  new_value ge_90_
column ge_101 new_value ge_101_
column ge_111 new_value ge_111_
column ge_112 new_value ge_112_
column ge_121 new_value ge_121_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 9.0  then '' else '--' end ge_90  from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 12.1 then '' else '--' end ge_121 from v$instance;

COL OWNER                   NEW_VALUE OWNER_
COL INDEX_NAME              NEW_VALUE INDEX_NAME_
COL INDEX_TYPE              NEW_VALUE INDEX_TYPE_
COL TABLE_OWNER             NEW_VALUE TABLE_OWNER_
COL TABLE_NAME              NEW_VALUE TABLE_NAME_
COL TABLE_TYPE              NEW_VALUE TABLE_TYPE_
COL UNIQUENESS              NEW_VALUE UNIQUENESS_
COL COMPRESSION             NEW_VALUE COMPRESSION_
COL PREFIX_LENGTH           NEW_VALUE PREFIX_LENGTH_
COL TABLESPACE_NAME         NEW_VALUE TABLESPACE_NAME_
COL INI_TRANS               NEW_VALUE INI_TRANS_
COL MAX_TRANS               NEW_VALUE MAX_TRANS_
COL INITIAL_EXTENT          NEW_VALUE INITIAL_EXTENT_
COL NEXT_EXTENT             NEW_VALUE NEXT_EXTENT_
COL MIN_EXTENTS             NEW_VALUE MIN_EXTENTS_
COL MAX_EXTENTS             NEW_VALUE MAX_EXTENTS_
COL PCT_INCREASE            NEW_VALUE PCT_INCREASE_
COL PCT_THRESHOLD           NEW_VALUE PCT_THRESHOLD_
COL INCLUDE_COLUMN          NEW_VALUE INCLUDE_COLUMN_
COL FREELISTS               NEW_VALUE FREELISTS_
COL FREELIST_GROUPS         NEW_VALUE FREELIST_GROUPS_
COL PCT_FREE                NEW_VALUE PCT_FREE_
COL LOGGING                 NEW_VALUE LOGGING_
COL BLEVEL                  NEW_VALUE BLEVEL_
COL LEAF_BLOCKS             NEW_VALUE LEAF_BLOCKS_
COL DISTINCT_KEYS           NEW_VALUE DISTINCT_KEYS_
COL AVG_LEAF_BLOCKS_PER_KEY NEW_VALUE AVG_LEAF_BLOCKS_PER_KEY_
COL AVG_DATA_BLOCKS_PER_KEY NEW_VALUE AVG_DATA_BLOCKS_PER_KEY_
COL CLUSTERING_FACTOR       NEW_VALUE CLUSTERING_FACTOR_
COL STATUS                  NEW_VALUE STATUS_
COL NUM_ROWS                NEW_VALUE NUM_ROWS_
COL SAMPLE_SIZE             NEW_VALUE SAMPLE_SIZE_
COL LAST_ANALYZED           NEW_VALUE LAST_ANALYZED_
COL DEGREE                  NEW_VALUE DEGREE_
COL INSTANCES               NEW_VALUE INSTANCES_
COL PARTITIONED             NEW_VALUE PARTITIONED_
COL TEMPORARY               NEW_VALUE TEMPORARY_
COL GENERATED               NEW_VALUE GENERATED_
COL SECONDARY               NEW_VALUE SECONDARY_
COL BUFFER_POOL             NEW_VALUE BUFFER_POOL_
COL FLASH_CACHE             NEW_VALUE FLASH_CACHE_
COL CELL_FLASH_CACHE        NEW_VALUE CELL_FLASH_CACHE_
COL USER_STATS              NEW_VALUE USER_STATS_
COL DURATION                NEW_VALUE DURATION_
COL PCT_DIRECT_ACCESS       NEW_VALUE PCT_DIRECT_ACCESS_
COL ITYP_OWNER              NEW_VALUE ITYP_OWNER_
COL ITYP_NAME               NEW_VALUE ITYP_NAME_
COL PARAMETERS              NEW_VALUE PARAMETERS_
COL GLOBAL_STATS            NEW_VALUE GLOBAL_STATS_
COL DOMIDX_STATUS           NEW_VALUE DOMIDX_STATUS_
COL DOMIDX_OPSTATUS         NEW_VALUE DOMIDX_OPSTATUS_
COL FUNCIDX_STATUS          NEW_VALUE FUNCIDX_STATUS_
COL JOIN_INDEX              NEW_VALUE JOIN_INDEX_
COL IOT_REDUNDANT_PKEY_ELIM NEW_VALUE IOT_REDUNDANT_PKEY_ELIM_
COL DROPPED                 NEW_VALUE DROPPED_
COL VISIBILITY              NEW_VALUE VISIBILITY_
COL DOMIDX_MANAGEMENT       NEW_VALUE DOMIDX_MANAGEMENT_
COL SEGMENT_CREATED         NEW_VALUE SEGMENT_CREATED_
COL ORPHANED_ENTRIES        NEW_VALUE ORPHANED_ENTRIES_
COL INDEXING                NEW_VALUE INDEXING_
COL ORDENAR                 NEW_VALUE ORDENAR_

SELECT
 CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('OWNER                   ')) > 0 THEN ''   ELSE '--' END OWNER
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INDEX_NAME              ')) > 0 THEN ''   ELSE '--' END INDEX_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INDEX_TYPE              ')) > 0 THEN ''   ELSE '--' END INDEX_TYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLE_OWNER             ')) > 0 THEN ''   ELSE '--' END TABLE_OWNER
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLE_NAME              ')) > 0 THEN ''   ELSE '--' END TABLE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLE_TYPE              ')) > 0 THEN ''   ELSE '--' END TABLE_TYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('UNIQUENESS              ')) > 0 THEN ''   ELSE '--' END UNIQUENESS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('COMPRESSION             ')) > 0 THEN ''   ELSE '--' END COMPRESSION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PREFIX_LENGTH           ')) > 0 THEN ''   ELSE '--' END PREFIX_LENGTH
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLESPACE_NAME         ')) > 0 THEN ''   ELSE '--' END TABLESPACE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INI_TRANS               ')) > 0 THEN ''   ELSE '--' END INI_TRANS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_TRANS               ')) > 0 THEN ''   ELSE '--' END MAX_TRANS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INITIAL_EXTENT          ')) > 0 THEN ''   ELSE '--' END INITIAL_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NEXT_EXTENT             ')) > 0 THEN ''   ELSE '--' END NEXT_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MIN_EXTENTS             ')) > 0 THEN ''   ELSE '--' END MIN_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_EXTENTS             ')) > 0 THEN ''   ELSE '--' END MAX_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_INCREASE            ')) > 0 THEN ''   ELSE '--' END PCT_INCREASE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_THRESHOLD           ')) > 0 THEN ''   ELSE '--' END PCT_THRESHOLD
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INCLUDE_COLUMN          ')) > 0 THEN ''   ELSE '--' END INCLUDE_COLUMN
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FREELISTS               ')) > 0 THEN ''   ELSE '--' END FREELISTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FREELIST_GROUPS         ')) > 0 THEN ''   ELSE '--' END FREELIST_GROUPS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_FREE                ')) > 0 THEN ''   ELSE '--' END PCT_FREE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LOGGING                 ')) > 0 THEN ''   ELSE '--' END LOGGING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BLEVEL                  ')) > 0 THEN ''   ELSE '--' END BLEVEL
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LEAF_BLOCKS             ')) > 0 THEN ''   ELSE '--' END LEAF_BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DISTINCT_KEYS           ')) > 0 THEN ''   ELSE '--' END DISTINCT_KEYS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AVG_LEAF_BLOCKS_PER_KEY ')) > 0 THEN ''   ELSE '--' END AVG_LEAF_BLOCKS_PER_KEY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AVG_DATA_BLOCKS_PER_KEY ')) > 0 THEN ''   ELSE '--' END AVG_DATA_BLOCKS_PER_KEY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CLUSTERING_FACTOR       ')) > 0 THEN ''   ELSE '--' END CLUSTERING_FACTOR
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('STATUS                  ')) > 0 THEN ''   ELSE '--' END STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NUM_ROWS                ')) > 0 THEN ''   ELSE '--' END NUM_ROWS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SAMPLE_SIZE             ')) > 0 THEN ''   ELSE '--' END SAMPLE_SIZE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LAST_ANALYZED           ')) > 0 THEN ''   ELSE '--' END LAST_ANALYZED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEGREE                  ')) > 0 THEN ''   ELSE '--' END DEGREE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INSTANCES               ')) > 0 THEN ''   ELSE '--' END INSTANCES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PARTITIONED             ')) > 0 THEN ''   ELSE '--' END PARTITIONED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TEMPORARY               ')) > 0 THEN ''   ELSE '--' END TEMPORARY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('GENERATED               ')) > 0 THEN ''   ELSE '--' END GENERATED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SECONDARY               ')) > 0 THEN ''   ELSE '--' END SECONDARY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BUFFER_POOL             ')) > 0 THEN ''   ELSE '--' END BUFFER_POOL
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FLASH_CACHE             ')) > 0 THEN ''   ELSE '--' END FLASH_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CELL_FLASH_CACHE        ')) > 0 THEN ''   ELSE '--' END CELL_FLASH_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('USER_STATS              ')) > 0 THEN ''   ELSE '--' END USER_STATS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DURATION                ')) > 0 THEN ''   ELSE '--' END DURATION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_DIRECT_ACCESS       ')) > 0 THEN ''   ELSE '--' END PCT_DIRECT_ACCESS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ITYP_OWNER              ')) > 0 THEN ''   ELSE '--' END ITYP_OWNER
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ITYP_NAME               ')) > 0 THEN ''   ELSE '--' END ITYP_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PARAMETERS              ')) > 0 THEN ''   ELSE '--' END PARAMETERS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('GLOBAL_STATS            ')) > 0 THEN ''   ELSE '--' END GLOBAL_STATS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DOMIDX_STATUS           ')) > 0 THEN ''   ELSE '--' END DOMIDX_STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DOMIDX_OPSTATUS         ')) > 0 THEN ''   ELSE '--' END DOMIDX_OPSTATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FUNCIDX_STATUS          ')) > 0 THEN ''   ELSE '--' END FUNCIDX_STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('JOIN_INDEX              ')) > 0 THEN ''   ELSE '--' END JOIN_INDEX
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('IOT_REDUNDANT_PKEY_ELIM ')) > 0 THEN ''   ELSE '--' END IOT_REDUNDANT_PKEY_ELIM
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DROPPED                 ')) > 0 THEN ''   ELSE '--' END DROPPED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('VISIBILITY              ')) > 0 THEN ''   ELSE '--' END VISIBILITY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DOMIDX_MANAGEMENT       ')) > 0 THEN ''   ELSE '--' END DOMIDX_MANAGEMENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SEGMENT_CREATED         ')) > 0 THEN ''   ELSE '--' END SEGMENT_CREATED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ORPHANED_ENTRIES        ')) > 0 THEN ''   ELSE '--' END ORPHANED_ENTRIES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INDEXING                ')) > 0 THEN ''   ELSE '--' END INDEXING
,CASE WHEN '&columns_' = '*'                                                                   THEN '--' ELSE ''   END ORDENAR
FROM dual
;

set term on

CLEAR BREAKS
CLEAR COLUMNS

COL info FOR A80

COL OWNER                   NOPRINT
COL INDEX_NAME              NOPRINT
COL INDEX_TYPE              NOPRINT
COL TABLE_OWNER             NOPRINT
COL TABLE_NAME              NOPRINT
COL TABLE_TYPE              NOPRINT
COL UNIQUENESS              NOPRINT
COL COMPRESSION             NOPRINT
COL PREFIX_LENGTH           NOPRINT
COL TABLESPACE_NAME         NOPRINT
COL INI_TRANS               NOPRINT
COL MAX_TRANS               NOPRINT
COL INITIAL_EXTENT          NOPRINT
COL NEXT_EXTENT             NOPRINT
COL MIN_EXTENTS             NOPRINT
COL MAX_EXTENTS             NOPRINT
COL PCT_INCREASE            NOPRINT
COL PCT_THRESHOLD           NOPRINT
COL INCLUDE_COLUMN          NOPRINT
COL FREELISTS               NOPRINT
COL FREELIST_GROUPS         NOPRINT
COL PCT_FREE                NOPRINT
COL LOGGING                 NOPRINT
COL BLEVEL                  NOPRINT
COL LEAF_BLOCKS             NOPRINT
COL DISTINCT_KEYS           NOPRINT
COL AVG_LEAF_BLOCKS_PER_KEY NOPRINT
COL AVG_DATA_BLOCKS_PER_KEY NOPRINT
COL CLUSTERING_FACTOR       NOPRINT
COL STATUS                  NOPRINT
COL NUM_ROWS                NOPRINT
COL SAMPLE_SIZE             NOPRINT
COL LAST_ANALYZED           NOPRINT
COL DEGREE                  NOPRINT
COL INSTANCES               NOPRINT
COL PARTITIONED             NOPRINT
COL TEMPORARY               NOPRINT
COL GENERATED               NOPRINT
COL SECONDARY               NOPRINT
COL BUFFER_POOL             NOPRINT
COL FLASH_CACHE             NOPRINT
COL CELL_FLASH_CACHE        NOPRINT
COL USER_STATS              NOPRINT
COL DURATION                NOPRINT
COL PCT_DIRECT_ACCESS       NOPRINT
COL ITYP_OWNER              NOPRINT
COL ITYP_NAME               NOPRINT
COL PARAMETERS              NOPRINT
COL GLOBAL_STATS            NOPRINT
COL DOMIDX_STATUS           NOPRINT
COL DOMIDX_OPSTATUS         NOPRINT
COL FUNCIDX_STATUS          NOPRINT
COL JOIN_INDEX              NOPRINT
COL IOT_REDUNDANT_PKEY_ELIM NOPRINT
COL DROPPED                 NOPRINT
COL VISIBILITY              NOPRINT
COL DOMIDX_MANAGEMENT       NOPRINT
COL SEGMENT_CREATED         NOPRINT
COL ORPHANED_ENTRIES        NOPRINT
COL INDEXING                NOPRINT

SELECT ROWNUM, inds.*
FROM (
SELECT                              ''
&ge_90_  &OWNER_                   ||LPAD(TRIM('OWNER                  '),23,' ')||' : '||OWNER                  ||CHR(10)
&ge_90_  &INDEX_NAME_              ||LPAD(TRIM('INDEX_NAME             '),23,' ')||' : '||INDEX_NAME             ||CHR(10)
&ge_90_  &INDEX_TYPE_              ||LPAD(TRIM('INDEX_TYPE             '),23,' ')||' : '||INDEX_TYPE             ||CHR(10)
&ge_90_  &TABLE_OWNER_             ||LPAD(TRIM('TABLE_OWNER            '),23,' ')||' : '||TABLE_OWNER            ||CHR(10)
&ge_90_  &TABLE_NAME_              ||LPAD(TRIM('TABLE_NAME             '),23,' ')||' : '||TABLE_NAME             ||CHR(10)
&ge_90_  &TABLE_TYPE_              ||LPAD(TRIM('TABLE_TYPE             '),23,' ')||' : '||TABLE_TYPE             ||CHR(10)
&ge_90_  &UNIQUENESS_              ||LPAD(TRIM('UNIQUENESS             '),23,' ')||' : '||UNIQUENESS             ||CHR(10)
&ge_90_  &COMPRESSION_             ||LPAD(TRIM('COMPRESSION            '),23,' ')||' : '||COMPRESSION            ||CHR(10)
&ge_90_  &PREFIX_LENGTH_           ||LPAD(TRIM('PREFIX_LENGTH          '),23,' ')||' : '||PREFIX_LENGTH          ||CHR(10)
&ge_90_  &TABLESPACE_NAME_         ||LPAD(TRIM('TABLESPACE_NAME        '),23,' ')||' : '||TABLESPACE_NAME        ||CHR(10)
&ge_90_  &INI_TRANS_               ||LPAD(TRIM('INI_TRANS              '),23,' ')||' : '||INI_TRANS              ||CHR(10)
&ge_90_  &MAX_TRANS_               ||LPAD(TRIM('MAX_TRANS              '),23,' ')||' : '||MAX_TRANS              ||CHR(10)
&ge_90_  &INITIAL_EXTENT_          ||LPAD(TRIM('INITIAL_EXTENT         '),23,' ')||' : '||CASE WHEN INITIAL_EXTENT < 1024     THEN INITIAL_EXTENT||''
&ge_90_  &INITIAL_EXTENT_                                                                 WHEN INITIAL_EXTENT < POWER(1024,2) THEN ROUND(INITIAL_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &INITIAL_EXTENT_                                                                 WHEN INITIAL_EXTENT < POWER(1024,3) THEN ROUND(INITIAL_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &INITIAL_EXTENT_                                                                 WHEN INITIAL_EXTENT < POWER(1024,4) THEN ROUND(INITIAL_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &INITIAL_EXTENT_                                                                 WHEN INITIAL_EXTENT < POWER(1024,5) THEN ROUND(INITIAL_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &INITIAL_EXTENT_                                                                 END                    ||CHR(10)
&ge_90_  &NEXT_EXTENT_             ||LPAD(TRIM('NEXT_EXTENT            '),23,' ')||' : '||CASE WHEN NEXT_EXTENT < 1024     THEN NEXT_EXTENT||''
&ge_90_  &NEXT_EXTENT_                                                                    WHEN NEXT_EXTENT < POWER(1024,2) THEN ROUND(NEXT_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &NEXT_EXTENT_                                                                    WHEN NEXT_EXTENT < POWER(1024,3) THEN ROUND(NEXT_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &NEXT_EXTENT_                                                                    WHEN NEXT_EXTENT < POWER(1024,4) THEN ROUND(NEXT_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &NEXT_EXTENT_                                                                    WHEN NEXT_EXTENT < POWER(1024,5) THEN ROUND(NEXT_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &NEXT_EXTENT_                                                                    END                    ||CHR(10)
&ge_90_  &MIN_EXTENTS_             ||LPAD(TRIM('MIN_EXTENTS            '),23,' ')||' : '||MIN_EXTENTS            ||CHR(10)
&ge_90_  &MAX_EXTENTS_             ||LPAD(TRIM('MAX_EXTENTS            '),23,' ')||' : '||MAX_EXTENTS            ||CHR(10)
&ge_90_  &PCT_INCREASE_            ||LPAD(TRIM('PCT_INCREASE           '),23,' ')||' : '||PCT_INCREASE           ||CHR(10)
&ge_90_  &PCT_THRESHOLD_           ||LPAD(TRIM('PCT_THRESHOLD          '),23,' ')||' : '||PCT_THRESHOLD          ||CHR(10)
&ge_90_  &INCLUDE_COLUMN_          ||LPAD(TRIM('INCLUDE_COLUMN         '),23,' ')||' : '||INCLUDE_COLUMN         ||CHR(10)
&ge_90_  &FREELISTS_               ||LPAD(TRIM('FREELISTS              '),23,' ')||' : '||FREELISTS              ||CHR(10)
&ge_90_  &FREELIST_GROUPS_         ||LPAD(TRIM('FREELIST_GROUPS        '),23,' ')||' : '||FREELIST_GROUPS        ||CHR(10)
&ge_90_  &PCT_FREE_                ||LPAD(TRIM('PCT_FREE               '),23,' ')||' : '||PCT_FREE               ||CHR(10)
&ge_90_  &LOGGING_                 ||LPAD(TRIM('LOGGING                '),23,' ')||' : '||LOGGING                ||CHR(10)
&ge_90_  &BLEVEL_                  ||LPAD(TRIM('BLEVEL                 '),23,' ')||' : '||BLEVEL                 ||CHR(10)
&ge_90_  &LEAF_BLOCKS_             ||LPAD(TRIM('LEAF_BLOCKS            '),23,' ')||' : '||LEAF_BLOCKS            ||CHR(10)
&ge_90_  &DISTINCT_KEYS_           ||LPAD(TRIM('DISTINCT_KEYS          '),23,' ')||' : '||DISTINCT_KEYS          ||CHR(10)
&ge_90_  &AVG_LEAF_BLOCKS_PER_KEY_ ||LPAD(TRIM('AVG_LEAF_BLOCKS_PER_KEY'),23,' ')||' : '||AVG_LEAF_BLOCKS_PER_KEY||CHR(10)
&ge_90_  &AVG_DATA_BLOCKS_PER_KEY_ ||LPAD(TRIM('AVG_DATA_BLOCKS_PER_KEY'),23,' ')||' : '||AVG_DATA_BLOCKS_PER_KEY||CHR(10)
&ge_90_  &CLUSTERING_FACTOR_       ||LPAD(TRIM('CLUSTERING_FACTOR      '),23,' ')||' : '||CLUSTERING_FACTOR      ||CHR(10)
&ge_90_  &STATUS_                  ||LPAD(TRIM('STATUS                 '),23,' ')||' : '||STATUS                 ||CHR(10)
&ge_90_  &NUM_ROWS_                ||LPAD(TRIM('NUM_ROWS               '),23,' ')||' : '||NUM_ROWS               ||CHR(10)
&ge_90_  &SAMPLE_SIZE_             ||LPAD(TRIM('SAMPLE_SIZE            '),23,' ')||' : '||SAMPLE_SIZE            ||CHR(10)
&ge_90_  &LAST_ANALYZED_           ||LPAD(TRIM('LAST_ANALYZED          '),23,' ')||' : '||TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD HH24:MI:SS')||CHR(10)
&ge_90_  &DEGREE_                  ||LPAD(TRIM('DEGREE                 '),23,' ')||' : '||DEGREE                 ||CHR(10)
&ge_90_  &INSTANCES_               ||LPAD(TRIM('INSTANCES              '),23,' ')||' : '||INSTANCES              ||CHR(10)
&ge_90_  &PARTITIONED_             ||LPAD(TRIM('PARTITIONED            '),23,' ')||' : '||PARTITIONED            ||CHR(10)
&ge_90_  &TEMPORARY_               ||LPAD(TRIM('TEMPORARY              '),23,' ')||' : '||TEMPORARY              ||CHR(10)
&ge_90_  &GENERATED_               ||LPAD(TRIM('GENERATED              '),23,' ')||' : '||GENERATED              ||CHR(10)
&ge_90_  &SECONDARY_               ||LPAD(TRIM('SECONDARY              '),23,' ')||' : '||SECONDARY              ||CHR(10)
&ge_90_  &BUFFER_POOL_             ||LPAD(TRIM('BUFFER_POOL            '),23,' ')||' : '||BUFFER_POOL            ||CHR(10)
&ge_112_ &FLASH_CACHE_             ||LPAD(TRIM('FLASH_CACHE            '),23,' ')||' : '||FLASH_CACHE            ||CHR(10)
&ge_112_ &CELL_FLASH_CACHE_        ||LPAD(TRIM('CELL_FLASH_CACHE       '),23,' ')||' : '||CELL_FLASH_CACHE       ||CHR(10)
&ge_90_  &USER_STATS_              ||LPAD(TRIM('USER_STATS             '),23,' ')||' : '||USER_STATS             ||CHR(10)
&ge_90_  &DURATION_                ||LPAD(TRIM('DURATION               '),23,' ')||' : '||DURATION               ||CHR(10)
&ge_90_  &PCT_DIRECT_ACCESS_       ||LPAD(TRIM('PCT_DIRECT_ACCESS      '),23,' ')||' : '||PCT_DIRECT_ACCESS      ||CHR(10)
&ge_90_  &ITYP_OWNER_              ||LPAD(TRIM('ITYP_OWNER             '),23,' ')||' : '||ITYP_OWNER             ||CHR(10)
&ge_90_  &ITYP_NAME_               ||LPAD(TRIM('ITYP_NAME              '),23,' ')||' : '||ITYP_NAME              ||CHR(10)
&ge_90_  &PARAMETERS_              ||LPAD(TRIM('PARAMETERS             '),23,' ')||' : '||PARAMETERS             ||CHR(10)
&ge_90_  &GLOBAL_STATS_            ||LPAD(TRIM('GLOBAL_STATS           '),23,' ')||' : '||GLOBAL_STATS           ||CHR(10)
&ge_90_  &DOMIDX_STATUS_           ||LPAD(TRIM('DOMIDX_STATUS          '),23,' ')||' : '||DOMIDX_STATUS          ||CHR(10)
&ge_90_  &DOMIDX_OPSTATUS_         ||LPAD(TRIM('DOMIDX_OPSTATUS        '),23,' ')||' : '||DOMIDX_OPSTATUS        ||CHR(10)
&ge_90_  &FUNCIDX_STATUS_          ||LPAD(TRIM('FUNCIDX_STATUS         '),23,' ')||' : '||FUNCIDX_STATUS         ||CHR(10)
&ge_101_ &JOIN_INDEX_              ||LPAD(TRIM('JOIN_INDEX             '),23,' ')||' : '||JOIN_INDEX             ||CHR(10)
&ge_101_ &IOT_REDUNDANT_PKEY_ELIM_ ||LPAD(TRIM('IOT_REDUNDANT_PKEY_ELIM'),23,' ')||' : '||IOT_REDUNDANT_PKEY_ELIM||CHR(10)
&ge_101_ &DROPPED_                 ||LPAD(TRIM('DROPPED                '),23,' ')||' : '||DROPPED                ||CHR(10)
&ge_111_ &VISIBILITY_              ||LPAD(TRIM('VISIBILITY             '),23,' ')||' : '||VISIBILITY             ||CHR(10)
&ge_111_ &DOMIDX_MANAGEMENT_       ||LPAD(TRIM('DOMIDX_MANAGEMENT      '),23,' ')||' : '||DOMIDX_MANAGEMENT      ||CHR(10)
&ge_112_ &SEGMENT_CREATED_         ||LPAD(TRIM('SEGMENT_CREATED        '),23,' ')||' : '||SEGMENT_CREATED        ||CHR(10)
&ge_121_ &ORPHANED_ENTRIES_        ||LPAD(TRIM('ORPHANED_ENTRIES       '),23,' ')||' : '||ORPHANED_ENTRIES       ||CHR(10)
&ge_121_ &INDEXING_                ||LPAD(TRIM('INDEXING               '),23,' ')||' : '||INDEXING               ||CHR(10)
info
&ge_90_  &OWNER_                   ,OWNER
&ge_90_  &INDEX_NAME_              ,INDEX_NAME
&ge_90_  &INDEX_TYPE_              ,INDEX_TYPE
&ge_90_  &TABLE_OWNER_             ,TABLE_OWNER
&ge_90_  &TABLE_NAME_              ,TABLE_NAME
&ge_90_  &TABLE_TYPE_              ,TABLE_TYPE
&ge_90_  &UNIQUENESS_              ,UNIQUENESS
&ge_90_  &COMPRESSION_             ,COMPRESSION
&ge_90_  &PREFIX_LENGTH_           ,PREFIX_LENGTH
&ge_90_  &TABLESPACE_NAME_         ,TABLESPACE_NAME
&ge_90_  &INI_TRANS_               ,INI_TRANS
&ge_90_  &MAX_TRANS_               ,MAX_TRANS
&ge_90_  &&INITIAL_EXTENT_         ,INITIAL_EXTENT
&ge_90_  &&NEXT_EXTENT_            ,NEXT_EXTENT
&ge_90_  &MIN_EXTENTS_             ,MIN_EXTENTS
&ge_90_  &MAX_EXTENTS_             ,MAX_EXTENTS
&ge_90_  &PCT_INCREASE_            ,PCT_INCREASE
&ge_90_  &PCT_THRESHOLD_           ,PCT_THRESHOLD
&ge_90_  &INCLUDE_COLUMN_          ,INCLUDE_COLUMN
&ge_90_  &FREELISTS_               ,FREELISTS
&ge_90_  &FREELIST_GROUPS_         ,FREELIST_GROUPS
&ge_90_  &PCT_FREE_                ,PCT_FREE
&ge_90_  &LOGGING_                 ,LOGGING
&ge_90_  &BLEVEL_                  ,BLEVEL
&ge_90_  &LEAF_BLOCKS_             ,LEAF_BLOCKS
&ge_90_  &DISTINCT_KEYS_           ,DISTINCT_KEYS
&ge_90_  &AVG_LEAF_BLOCKS_PER_KEY_ ,AVG_LEAF_BLOCKS_PER_KEY
&ge_90_  &AVG_DATA_BLOCKS_PER_KEY_ ,AVG_DATA_BLOCKS_PER_KEY
&ge_90_  &CLUSTERING_FACTOR_       ,CLUSTERING_FACTOR
&ge_90_  &STATUS_                  ,STATUS
&ge_90_  &NUM_ROWS_                ,NUM_ROWS
&ge_90_  &SAMPLE_SIZE_             ,SAMPLE_SIZE
&ge_90_  &LAST_ANALYZED_           ,LAST_ANALYZED
&ge_90_  &DEGREE_                  ,DEGREE
&ge_90_  &INSTANCES_               ,INSTANCES
&ge_90_  &PARTITIONED_             ,PARTITIONED
&ge_90_  &TEMPORARY_               ,TEMPORARY
&ge_90_  &GENERATED_               ,GENERATED
&ge_90_  &SECONDARY_               ,SECONDARY
&ge_90_  &BUFFER_POOL_             ,BUFFER_POOL
&ge_112_ &FLASH_CACHE_             ,FLASH_CACHE
&ge_112_ &CELL_FLASH_CACHE_        ,CELL_FLASH_CACHE
&ge_90_  &USER_STATS_              ,USER_STATS
&ge_90_  &DURATION_                ,DURATION
&ge_90_  &PCT_DIRECT_ACCESS_       ,PCT_DIRECT_ACCESS
&ge_90_  &ITYP_OWNER_              ,ITYP_OWNER
&ge_90_  &ITYP_NAME_               ,ITYP_NAME
&ge_90_  &PARAMETERS_              ,PARAMETERS
&ge_90_  &GLOBAL_STATS_            ,GLOBAL_STATS
&ge_90_  &DOMIDX_STATUS_           ,DOMIDX_STATUS
&ge_90_  &DOMIDX_OPSTATUS_         ,DOMIDX_OPSTATUS
&ge_90_  &FUNCIDX_STATUS_          ,FUNCIDX_STATUS
&ge_101_ &JOIN_INDEX_              ,JOIN_INDEX
&ge_101_ &IOT_REDUNDANT_PKEY_ELIM_ ,IOT_REDUNDANT_PKEY_ELIM
&ge_101_ &DROPPED_                 ,DROPPED
&ge_111_ &VISIBILITY_              ,VISIBILITY
&ge_111_ &DOMIDX_MANAGEMENT_       ,DOMIDX_MANAGEMENT
&ge_112_ &SEGMENT_CREATED_         ,SEGMENT_CREATED
&ge_121_ &ORPHANED_ENTRIES_        ,ORPHANED_ENTRIES
&ge_121_ &INDEXING_                ,INDEXING
FROM dba_indexes
WHERE &where_
&ORDENAR_ ORDER BY &columns_
) inds
;

CLEAR BREAKS
CLEAR COLUMNS
