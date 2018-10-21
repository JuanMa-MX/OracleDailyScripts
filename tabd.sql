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

UNDEFINE where_
UNDEFINE columns_

PROMPT
PROMPT Listado de columnas:
PROMPT
PROMPT [ OWNER           FREELISTS                 TABLE_LOCK       SKIP_CORRUPT      INMEMORY               INMEMORY_SERVICE_NAME ]
PROMPT [ TABLE_NAME      FREELIST_GROUPS           SAMPLE_SIZE      MONITORING        INMEMORY_PRIORITY      CONTAINER_MAP_OBJECT  ]
PROMPT [ TABLESPACE_NAME LOGGING                   LAST_ANALYZED    CLUSTER_OWNER     INMEMORY_DISTRIBUTE                          ]
PROMPT [ CLUSTER_NAME    BACKED_UP                 PARTITIONED      DEPENDENCIES      INMEMORY_COMPRESSION                         ]
PROMPT [ IOT_NAME        NUM_ROWS                  IOT_TYPE         COMPRESSION       INMEMORY_DUPLICATE                           ]
PROMPT [ STATUS          BLOCKS                    TEMPORARY        COMPRESS_FOR      DEFAULT_COLLATION                            ]
PROMPT [ PCT_FREE        EMPTY_BLOCKS              SECONDARY        DROPPED           DUPLICATED                                   ]
PROMPT [ PCT_USED        AVG_SPACE                 NESTED           READ_ONLY         SHARDED                                      ]
PROMPT [ INI_TRANS       CHAIN_CNT                 BUFFER_POOL      SEGMENT_CREATED   EXTERNAL                                     ]
PROMPT [ MAX_TRANS       AVG_ROW_LEN               FLASH_CACHE      RESULT_CACHE      CELLMEMORY                                   ]
PROMPT [ INITIAL_EXTENT  AVG_SPACE_FREELIST_BLOCKS CELL_FLASH_CACHE CLUSTERING        CONTAINERS_DEFAULT                           ]
PROMPT [ NEXT_EXTENT     NUM_FREELIST_BLOCKS       ROW_MOVEMENT     ACTIVITY_TRACKING CONTAINER_MAP                                ]
PROMPT [ MIN_EXTENTS     DEGREE                    GLOBAL_STATS     DML_TIMESTAMP     EXTENDED_DATA_LINK                           ]
PROMPT [ MAX_EXTENTS     INSTANCES                 USER_STATS       HAS_IDENTITY      EXTENDED_DATA_LINK_MAP                       ]
PROMPT [ PCT_INCREASE    CACHE                     DURATION         CONTAINER_DATA    INMEMORY_SERVICE                             ]
PROMPT
PROMPT Tuning [ OWNER,TABLE_NAME,TABLESPACE_NAME,DEGREE,INI_TRANS,MAX_TRANS,FREELISTS,FREELIST_GROUPS,SAMPLE_SIZE,NUM_ROWS,LAST_ANALYZED ]
PROMPT

accept columns_ char default '*' -
prompt 'Columnas a mostrar? [*]: '

accept where_ char default '1=1' -
prompt 'Where? [1=1]: '

set term off

column oracle_version new_value oracle_version_
column ge_90  new_value ge_90_
column ge_101 new_value ge_101_
column ge_102 new_value ge_102_
column ge_111 new_value ge_111_
column ge_112 new_value ge_112_
column ge_121 new_value ge_121_
column ge_122 new_value ge_122_

select to_number(substr(version,1,instr(version,'.',1,2)-1)) oracle_version from v$instance;

--  define oracle_version_=9.1;

select case when &oracle_version_ >= 9.0  then '' else '--' end ge_90  from v$instance;
select case when &oracle_version_ >= 10.1 then '' else '--' end ge_101 from v$instance;
select case when &oracle_version_ >= 10.2 then '' else '--' end ge_102 from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 12.1 then '' else '--' end ge_121 from v$instance;
select case when &oracle_version_ >= 12.2 then '' else '--' end ge_122 from v$instance;

COL OWNER                      NEW_VALUE OWNER_
COL TABLE_NAME                 NEW_VALUE TABLE_NAME_
COL TABLESPACE_NAME            NEW_VALUE TABLESPACE_NAME_
COL CLUSTER_NAME               NEW_VALUE CLUSTER_NAME_
COL IOT_NAME                   NEW_VALUE IOT_NAME_
COL STATUS                     NEW_VALUE STATUS_
COL PCT_FREE                   NEW_VALUE PCT_FREE_
COL PCT_USED                   NEW_VALUE PCT_USED_
COL INI_TRANS                  NEW_VALUE INI_TRANS_
COL MAX_TRANS                  NEW_VALUE MAX_TRANS_
COL INITIAL_EXTENT             NEW_VALUE INITIAL_EXTENT_
COL NEXT_EXTENT                NEW_VALUE NEXT_EXTENT_
COL MIN_EXTENTS                NEW_VALUE MIN_EXTENTS_
COL MAX_EXTENTS                NEW_VALUE MAX_EXTENTS_
COL PCT_INCREASE               NEW_VALUE PCT_INCREASE_
COL FREELISTS                  NEW_VALUE FREELISTS_
COL FREELIST_GROUPS            NEW_VALUE FREELIST_GROUPS_
COL LOGGING                    NEW_VALUE LOGGING_
COL BACKED_UP                  NEW_VALUE BACKED_UP_
COL NUM_ROWS                   NEW_VALUE NUM_ROWS_
COL BLOCKS                     NEW_VALUE BLOCKS_
COL EMPTY_BLOCKS               NEW_VALUE EMPTY_BLOCKS_
COL AVG_SPACE                  NEW_VALUE AVG_SPACE_
COL CHAIN_CNT                  NEW_VALUE CHAIN_CNT_
COL AVG_ROW_LEN                NEW_VALUE AVG_ROW_LEN_
COL AVG_SPACE_FREELIST_BLOCKS  NEW_VALUE AVG_SPACE_FREELIST_BLOCKS_
COL NUM_FREELIST_BLOCKS        NEW_VALUE NUM_FREELIST_BLOCKS_
COL DEGREE                     NEW_VALUE DEGREE_
COL INSTANCES                  NEW_VALUE INSTANCES_
COL CACHE                      NEW_VALUE CACHE_
COL TABLE_LOCK                 NEW_VALUE TABLE_LOCK_
COL SAMPLE_SIZE                NEW_VALUE SAMPLE_SIZE_
COL LAST_ANALYZED              NEW_VALUE LAST_ANALYZED_
COL PARTITIONED                NEW_VALUE PARTITIONED_
COL IOT_TYPE                   NEW_VALUE IOT_TYPE_
COL TEMPORARY                  NEW_VALUE TEMPORARY_
COL SECONDARY                  NEW_VALUE SECONDARY_
COL NESTED                     NEW_VALUE NESTED_
COL BUFFER_POOL                NEW_VALUE BUFFER_POOL_
COL FLASH_CACHE                NEW_VALUE FLASH_CACHE_
COL CELL_FLASH_CACHE           NEW_VALUE CELL_FLASH_CACHE_
COL ROW_MOVEMENT               NEW_VALUE ROW_MOVEMENT_
COL GLOBAL_STATS               NEW_VALUE GLOBAL_STATS_
COL USER_STATS                 NEW_VALUE USER_STATS_
COL DURATION                   NEW_VALUE DURATION_
COL SKIP_CORRUPT               NEW_VALUE SKIP_CORRUPT_
COL MONITORING                 NEW_VALUE MONITORING_
COL CLUSTER_OWNER              NEW_VALUE CLUSTER_OWNER_
COL DEPENDENCIES               NEW_VALUE DEPENDENCIES_
COL COMPRESSION                NEW_VALUE COMPRESSION_
COL COMPRESS_FOR               NEW_VALUE COMPRESS_FOR_
COL DROPPED                    NEW_VALUE DROPPED_
COL READ_ONLY                  NEW_VALUE READ_ONLY_
COL SEGMENT_CREATED            NEW_VALUE SEGMENT_CREATED_
COL RESULT_CACHE               NEW_VALUE RESULT_CACHE_
COL CLUSTERING                 NEW_VALUE CLUSTERING_
COL ACTIVITY_TRACKING          NEW_VALUE ACTIVITY_TRACKING_
COL DML_TIMESTAMP              NEW_VALUE DML_TIMESTAMP_
COL HAS_IDENTITY               NEW_VALUE HAS_IDENTITY_
COL CONTAINER_DATA             NEW_VALUE CONTAINER_DATA_
COL INMEMORY                   NEW_VALUE INMEMORY_
COL INMEMORY_PRIORITY          NEW_VALUE INMEMORY_PRIORITY_
COL INMEMORY_DISTRIBUTE        NEW_VALUE INMEMORY_DISTRIBUTE_
COL INMEMORY_COMPRESSION       NEW_VALUE INMEMORY_COMPRESSION_
COL INMEMORY_DUPLICATE         NEW_VALUE INMEMORY_DUPLICATE_
COL DEFAULT_COLLATION          NEW_VALUE DEFAULT_COLLATION_
COL DUPLICATED                 NEW_VALUE DUPLICATED_
COL SHARDED                    NEW_VALUE SHARDED_
COL EXTERNAL                   NEW_VALUE EXTERNAL_
COL CELLMEMORY                 NEW_VALUE CELLMEMORY_
COL CONTAINERS_DEFAULT         NEW_VALUE CONTAINERS_DEFAULT_
COL CONTAINER_MAP              NEW_VALUE CONTAINER_MAP_
COL EXTENDED_DATA_LINK         NEW_VALUE EXTENDED_DATA_LINK_
COL EXTENDED_DATA_LINK_MAP     NEW_VALUE EXTENDED_DATA_LINK_MAP_
COL INMEMORY_SERVICE           NEW_VALUE INMEMORY_SERVICE_
COL INMEMORY_SERVICE_NAME      NEW_VALUE INMEMORY_SERVICE_NAME_
COL CONTAINER_MAP_OBJECT       NEW_VALUE CONTAINER_MAP_OBJECT_
COL ORDENAR                    NEW_VALUE ORDENAR_

SELECT
 CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('OWNER                    ')) > 0 THEN ''   ELSE '--' END OWNER
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLE_NAME               ')) > 0 THEN ''   ELSE '--' END TABLE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLESPACE_NAME          ')) > 0 THEN ''   ELSE '--' END TABLESPACE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CLUSTER_NAME             ')) > 0 THEN ''   ELSE '--' END CLUSTER_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('IOT_NAME                 ')) > 0 THEN ''   ELSE '--' END IOT_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('STATUS                   ')) > 0 THEN ''   ELSE '--' END STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_FREE                 ')) > 0 THEN ''   ELSE '--' END PCT_FREE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_USED                 ')) > 0 THEN ''   ELSE '--' END PCT_USED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INI_TRANS                ')) > 0 THEN ''   ELSE '--' END INI_TRANS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_TRANS                ')) > 0 THEN ''   ELSE '--' END MAX_TRANS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INITIAL_EXTENT           ')) > 0 THEN ''   ELSE '--' END INITIAL_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NEXT_EXTENT              ')) > 0 THEN ''   ELSE '--' END NEXT_EXTENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MIN_EXTENTS              ')) > 0 THEN ''   ELSE '--' END MIN_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MAX_EXTENTS              ')) > 0 THEN ''   ELSE '--' END MAX_EXTENTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PCT_INCREASE             ')) > 0 THEN ''   ELSE '--' END PCT_INCREASE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FREELISTS                ')) > 0 THEN ''   ELSE '--' END FREELISTS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FREELIST_GROUPS          ')) > 0 THEN ''   ELSE '--' END FREELIST_GROUPS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LOGGING                  ')) > 0 THEN ''   ELSE '--' END LOGGING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BACKED_UP                ')) > 0 THEN ''   ELSE '--' END BACKED_UP
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NUM_ROWS                 ')) > 0 THEN ''   ELSE '--' END NUM_ROWS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BLOCKS                   ')) > 0 THEN ''   ELSE '--' END BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EMPTY_BLOCKS             ')) > 0 THEN ''   ELSE '--' END EMPTY_BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AVG_SPACE                ')) > 0 THEN ''   ELSE '--' END AVG_SPACE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CHAIN_CNT                ')) > 0 THEN ''   ELSE '--' END CHAIN_CNT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AVG_ROW_LEN              ')) > 0 THEN ''   ELSE '--' END AVG_ROW_LEN
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AVG_SPACE_FREELIST_BLOCKS')) > 0 THEN ''   ELSE '--' END AVG_SPACE_FREELIST_BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NUM_FREELIST_BLOCKS      ')) > 0 THEN ''   ELSE '--' END NUM_FREELIST_BLOCKS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEGREE                   ')) > 0 THEN ''   ELSE '--' END DEGREE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INSTANCES                ')) > 0 THEN ''   ELSE '--' END INSTANCES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CACHE                    ')) > 0 THEN ''   ELSE '--' END CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TABLE_LOCK               ')) > 0 THEN ''   ELSE '--' END TABLE_LOCK
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SAMPLE_SIZE              ')) > 0 THEN ''   ELSE '--' END SAMPLE_SIZE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LAST_ANALYZED            ')) > 0 THEN ''   ELSE '--' END LAST_ANALYZED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PARTITIONED              ')) > 0 THEN ''   ELSE '--' END PARTITIONED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('IOT_TYPE                 ')) > 0 THEN ''   ELSE '--' END IOT_TYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TEMPORARY                ')) > 0 THEN ''   ELSE '--' END TEMPORARY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SECONDARY                ')) > 0 THEN ''   ELSE '--' END SECONDARY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('NESTED                   ')) > 0 THEN ''   ELSE '--' END NESTED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('BUFFER_POOL              ')) > 0 THEN ''   ELSE '--' END BUFFER_POOL
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('FLASH_CACHE              ')) > 0 THEN ''   ELSE '--' END FLASH_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CELL_FLASH_CACHE         ')) > 0 THEN ''   ELSE '--' END CELL_FLASH_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ROW_MOVEMENT             ')) > 0 THEN ''   ELSE '--' END ROW_MOVEMENT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('GLOBAL_STATS             ')) > 0 THEN ''   ELSE '--' END GLOBAL_STATS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('USER_STATS               ')) > 0 THEN ''   ELSE '--' END USER_STATS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DURATION                 ')) > 0 THEN ''   ELSE '--' END DURATION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SKIP_CORRUPT             ')) > 0 THEN ''   ELSE '--' END SKIP_CORRUPT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('MONITORING               ')) > 0 THEN ''   ELSE '--' END MONITORING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CLUSTER_OWNER            ')) > 0 THEN ''   ELSE '--' END CLUSTER_OWNER
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEPENDENCIES             ')) > 0 THEN ''   ELSE '--' END DEPENDENCIES
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('COMPRESSION              ')) > 0 THEN ''   ELSE '--' END COMPRESSION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('COMPRESS_FOR             ')) > 0 THEN ''   ELSE '--' END COMPRESS_FOR
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DROPPED                  ')) > 0 THEN ''   ELSE '--' END DROPPED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('READ_ONLY                ')) > 0 THEN ''   ELSE '--' END READ_ONLY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SEGMENT_CREATED          ')) > 0 THEN ''   ELSE '--' END SEGMENT_CREATED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('RESULT_CACHE             ')) > 0 THEN ''   ELSE '--' END RESULT_CACHE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CLUSTERING               ')) > 0 THEN ''   ELSE '--' END CLUSTERING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ACTIVITY_TRACKING        ')) > 0 THEN ''   ELSE '--' END ACTIVITY_TRACKING
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DML_TIMESTAMP            ')) > 0 THEN ''   ELSE '--' END DML_TIMESTAMP
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('HAS_IDENTITY             ')) > 0 THEN ''   ELSE '--' END HAS_IDENTITY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CONTAINER_DATA           ')) > 0 THEN ''   ELSE '--' END CONTAINER_DATA
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY                 ')) > 0 THEN ''   ELSE '--' END INMEMORY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_PRIORITY        ')) > 0 THEN ''   ELSE '--' END INMEMORY_PRIORITY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_DISTRIBUTE      ')) > 0 THEN ''   ELSE '--' END INMEMORY_DISTRIBUTE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_COMPRESSION     ')) > 0 THEN ''   ELSE '--' END INMEMORY_COMPRESSION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_DUPLICATE       ')) > 0 THEN ''   ELSE '--' END INMEMORY_DUPLICATE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEFAULT_COLLATION        ')) > 0 THEN ''   ELSE '--' END DEFAULT_COLLATION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DUPLICATED               ')) > 0 THEN ''   ELSE '--' END DUPLICATED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('SHARDED                  ')) > 0 THEN ''   ELSE '--' END SHARDED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXTERNAL                 ')) > 0 THEN ''   ELSE '--' END EXTERNAL
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CELLMEMORY               ')) > 0 THEN ''   ELSE '--' END CELLMEMORY
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CONTAINERS_DEFAULT       ')) > 0 THEN ''   ELSE '--' END CONTAINERS_DEFAULT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CONTAINER_MAP            ')) > 0 THEN ''   ELSE '--' END CONTAINER_MAP
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXTENDED_DATA_LINK       ')) > 0 THEN ''   ELSE '--' END EXTENDED_DATA_LINK
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXTENDED_DATA_LINK_MAP   ')) > 0 THEN ''   ELSE '--' END EXTENDED_DATA_LINK_MAP
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_SERVICE         ')) > 0 THEN ''   ELSE '--' END INMEMORY_SERVICE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INMEMORY_SERVICE_NAME    ')) > 0 THEN ''   ELSE '--' END INMEMORY_SERVICE_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CONTAINER_MAP_OBJECT     ')) > 0 THEN ''   ELSE '--' END CONTAINER_MAP_OBJECT
,CASE WHEN '&columns_' = '*'                                                                    THEN '--' ELSE ''   END ORDENAR
FROM dual
;

set term on

CLEAR BREAKS
CLEAR COLUMNS

COL info FOR A80

COL OWNER                     NOPRINT
COL TABLE_NAME                NOPRINT
COL TABLESPACE_NAME           NOPRINT
COL CLUSTER_NAME              NOPRINT
COL IOT_NAME                  NOPRINT
COL STATUS                    NOPRINT
COL PCT_FREE                  NOPRINT
COL PCT_USED                  NOPRINT
COL INI_TRANS                 NOPRINT
COL MAX_TRANS                 NOPRINT
COL INITIAL_EXTENT            NOPRINT
COL NEXT_EXTENT               NOPRINT
COL MIN_EXTENTS               NOPRINT
COL MAX_EXTENTS               NOPRINT
COL PCT_INCREASE              NOPRINT
COL FREELISTS                 NOPRINT
COL FREELIST_GROUPS           NOPRINT
COL LOGGING                   NOPRINT
COL BACKED_UP                 NOPRINT
COL NUM_ROWS                  NOPRINT
COL BLOCKS                    NOPRINT
COL EMPTY_BLOCKS              NOPRINT
COL AVG_SPACE                 NOPRINT
COL CHAIN_CNT                 NOPRINT
COL AVG_ROW_LEN               NOPRINT
COL AVG_SPACE_FREELIST_BLOCKS NOPRINT
COL NUM_FREELIST_BLOCKS       NOPRINT
COL DEGREE                    NOPRINT
COL INSTANCES                 NOPRINT
COL CACHE                     NOPRINT
COL TABLE_LOCK                NOPRINT
COL SAMPLE_SIZE               NOPRINT
COL LAST_ANALYZED             NOPRINT
COL PARTITIONED               NOPRINT
COL IOT_TYPE                  NOPRINT
COL TEMPORARY                 NOPRINT
COL SECONDARY                 NOPRINT
COL NESTED                    NOPRINT
COL BUFFER_POOL               NOPRINT
COL FLASH_CACHE               NOPRINT
COL CELL_FLASH_CACHE          NOPRINT
COL ROW_MOVEMENT              NOPRINT
COL GLOBAL_STATS              NOPRINT
COL USER_STATS                NOPRINT
COL DURATION                  NOPRINT
COL SKIP_CORRUPT              NOPRINT
COL MONITORING                NOPRINT
COL CLUSTER_OWNER             NOPRINT
COL DEPENDENCIES              NOPRINT
COL COMPRESSION               NOPRINT
COL COMPRESS_FOR              NOPRINT
COL DROPPED                   NOPRINT
COL READ_ONLY                 NOPRINT
COL SEGMENT_CREATED           NOPRINT
COL RESULT_CACHE              NOPRINT
COL CLUSTERING                NOPRINT
COL ACTIVITY_TRACKING         NOPRINT
COL DML_TIMESTAMP             NOPRINT
COL HAS_IDENTITY              NOPRINT
COL CONTAINER_DATA            NOPRINT
COL INMEMORY                  NOPRINT
COL INMEMORY_PRIORITY         NOPRINT
COL INMEMORY_DISTRIBUTE       NOPRINT
COL INMEMORY_COMPRESSION      NOPRINT
COL INMEMORY_DUPLICATE        NOPRINT
COL DEFAULT_COLLATION         NOPRINT
COL DUPLICATED                NOPRINT
COL SHARDED                   NOPRINT
COL EXTERNAL                  NOPRINT
COL CELLMEMORY                NOPRINT
COL CONTAINERS_DEFAULT        NOPRINT
COL CONTAINER_MAP             NOPRINT
COL EXTENDED_DATA_LINK        NOPRINT
COL EXTENDED_DATA_LINK_MAP    NOPRINT
COL INMEMORY_SERVICE          NOPRINT
COL INMEMORY_SERVICE_NAME     NOPRINT
COL CONTAINER_MAP_OBJECT      NOPRINT

SELECT ROWNUM, tabs.*
FROM (
SELECT                                 ''
&ge_90_  &OWNER_                     ||LPAD(TRIM('OWNER                     '),25,' ')||' : '||OWNER                    ||CHR(10)
&ge_90_  &TABLE_NAME_                ||LPAD(TRIM('TABLE_NAME                '),25,' ')||' : '||TABLE_NAME               ||CHR(10)
&ge_90_  &TABLESPACE_NAME_           ||LPAD(TRIM('TABLESPACE_NAME           '),25,' ')||' : '||TABLESPACE_NAME          ||CHR(10)
&ge_90_  &CLUSTER_NAME_              ||LPAD(TRIM('CLUSTER_NAME              '),25,' ')||' : '||CLUSTER_NAME             ||CHR(10)
&ge_90_  &IOT_NAME_                  ||LPAD(TRIM('IOT_NAME                  '),25,' ')||' : '||IOT_NAME                 ||CHR(10)
&ge_102_ &STATUS_                    ||LPAD(TRIM('STATUS                    '),25,' ')||' : '||STATUS                   ||CHR(10)
&ge_90_  &PCT_FREE_                  ||LPAD(TRIM('PCT_FREE                  '),25,' ')||' : '||PCT_FREE                 ||CHR(10)
&ge_90_  &PCT_USED_                  ||LPAD(TRIM('PCT_USED                  '),25,' ')||' : '||PCT_USED                 ||CHR(10)
&ge_90_  &INI_TRANS_                 ||LPAD(TRIM('INI_TRANS                 '),25,' ')||' : '||INI_TRANS                ||CHR(10)
&ge_90_  &MAX_TRANS_                 ||LPAD(TRIM('MAX_TRANS                 '),25,' ')||' : '||MAX_TRANS                ||CHR(10)
&ge_90_  &INITIAL_EXTENT_            ||LPAD(TRIM('INITIAL_EXTENT            '),25,' ')||' : '||CASE WHEN INITIAL_EXTENT < 1024     THEN INITIAL_EXTENT||''
&ge_90_  &INITIAL_EXTENT_                                                                      WHEN INITIAL_EXTENT < POWER(1024,2) THEN ROUND(INITIAL_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &INITIAL_EXTENT_                                                                      WHEN INITIAL_EXTENT < POWER(1024,3) THEN ROUND(INITIAL_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &INITIAL_EXTENT_                                                                      WHEN INITIAL_EXTENT < POWER(1024,4) THEN ROUND(INITIAL_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &INITIAL_EXTENT_                                                                      WHEN INITIAL_EXTENT < POWER(1024,5) THEN ROUND(INITIAL_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &INITIAL_EXTENT_                                                                      END                      ||CHR(10)
&ge_90_  &NEXT_EXTENT_               ||LPAD(TRIM('NEXT_EXTENT               '),25,' ')||' : '||CASE WHEN NEXT_EXTENT < 1024     THEN NEXT_EXTENT||''
&ge_90_  &NEXT_EXTENT_                                                                         WHEN NEXT_EXTENT < POWER(1024,2) THEN ROUND(NEXT_EXTENT/POWER(1024,1),1)||'K'
&ge_90_  &NEXT_EXTENT_                                                                         WHEN NEXT_EXTENT < POWER(1024,3) THEN ROUND(NEXT_EXTENT/POWER(1024,2),1)||'M'
&ge_90_  &NEXT_EXTENT_                                                                         WHEN NEXT_EXTENT < POWER(1024,4) THEN ROUND(NEXT_EXTENT/POWER(1024,3),1)||'G'
&ge_90_  &NEXT_EXTENT_                                                                         WHEN NEXT_EXTENT < POWER(1024,5) THEN ROUND(NEXT_EXTENT/POWER(1024,4),1)||'T'
&ge_90_  &NEXT_EXTENT_                                                                         END                      ||CHR(10)
&ge_90_  &MIN_EXTENTS_               ||LPAD(TRIM('MIN_EXTENTS               '),25,' ')||' : '||MIN_EXTENTS              ||CHR(10)
&ge_90_  &MAX_EXTENTS_               ||LPAD(TRIM('MAX_EXTENTS               '),25,' ')||' : '||MAX_EXTENTS              ||CHR(10)
&ge_90_  &PCT_INCREASE_              ||LPAD(TRIM('PCT_INCREASE              '),25,' ')||' : '||PCT_INCREASE             ||CHR(10)
&ge_90_  &FREELISTS_                 ||LPAD(TRIM('FREELISTS                 '),25,' ')||' : '||FREELISTS                ||CHR(10)
&ge_90_  &FREELIST_GROUPS_           ||LPAD(TRIM('FREELIST_GROUPS           '),25,' ')||' : '||FREELIST_GROUPS          ||CHR(10)
&ge_90_  &LOGGING_                   ||LPAD(TRIM('LOGGING                   '),25,' ')||' : '||LOGGING                  ||CHR(10)
&ge_90_  &BACKED_UP_                 ||LPAD(TRIM('BACKED_UP                 '),25,' ')||' : '||BACKED_UP                ||CHR(10)
&ge_90_  &NUM_ROWS_                  ||LPAD(TRIM('NUM_ROWS                  '),25,' ')||' : '||NUM_ROWS                 ||CHR(10)
&ge_90_  &BLOCKS_                    ||LPAD(TRIM('BLOCKS                    '),25,' ')||' : '||BLOCKS                   ||CHR(10)
&ge_90_  &EMPTY_BLOCKS_              ||LPAD(TRIM('EMPTY_BLOCKS              '),25,' ')||' : '||EMPTY_BLOCKS             ||CHR(10)
&ge_90_  &AVG_SPACE_                 ||LPAD(TRIM('AVG_SPACE                 '),25,' ')||' : '||AVG_SPACE                ||CHR(10)
&ge_90_  &CHAIN_CNT_                 ||LPAD(TRIM('CHAIN_CNT                 '),25,' ')||' : '||CHAIN_CNT                ||CHR(10)
&ge_90_  &AVG_ROW_LEN_               ||LPAD(TRIM('AVG_ROW_LEN               '),25,' ')||' : '||AVG_ROW_LEN              ||CHR(10)
&ge_90_  &AVG_SPACE_FREELIST_BLOCKS_ ||LPAD(TRIM('AVG_SPACE_FREELIST_BLOCKS '),25,' ')||' : '||AVG_SPACE_FREELIST_BLOCKS||CHR(10)
&ge_90_  &NUM_FREELIST_BLOCKS_       ||LPAD(TRIM('NUM_FREELIST_BLOCKS       '),25,' ')||' : '||NUM_FREELIST_BLOCKS      ||CHR(10)
&ge_90_  &DEGREE_                    ||LPAD(TRIM('DEGREE                    '),25,' ')||' : '||DEGREE                   ||CHR(10)
&ge_90_  &INSTANCES_                 ||LPAD(TRIM('INSTANCES                 '),25,' ')||' : '||INSTANCES                ||CHR(10)
&ge_90_  &CACHE_                     ||LPAD(TRIM('CACHE                     '),25,' ')||' : '||CACHE                    ||CHR(10)
&ge_90_  &TABLE_LOCK_                ||LPAD(TRIM('TABLE_LOCK                '),25,' ')||' : '||TABLE_LOCK               ||CHR(10)
&ge_90_  &SAMPLE_SIZE_               ||LPAD(TRIM('SAMPLE_SIZE               '),25,' ')||' : '||SAMPLE_SIZE              ||CHR(10)
&ge_90_  &LAST_ANALYZED_             ||LPAD(TRIM('LAST_ANALYZED             '),25,' ')||' : '||TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD HH24:MI:SS')||CHR(10)
&ge_90_  &PARTITIONED_               ||LPAD(TRIM('PARTITIONED               '),25,' ')||' : '||PARTITIONED              ||CHR(10)
&ge_90_  &IOT_TYPE_                  ||LPAD(TRIM('IOT_TYPE                  '),25,' ')||' : '||IOT_TYPE                 ||CHR(10)
&ge_90_  &TEMPORARY_                 ||LPAD(TRIM('TEMPORARY                 '),25,' ')||' : '||TEMPORARY                ||CHR(10)
&ge_90_  &SECONDARY_                 ||LPAD(TRIM('SECONDARY                 '),25,' ')||' : '||SECONDARY                ||CHR(10)
&ge_90_  &NESTED_                    ||LPAD(TRIM('NESTED                    '),25,' ')||' : '||NESTED                   ||CHR(10)
&ge_90_  &BUFFER_POOL_               ||LPAD(TRIM('BUFFER_POOL               '),25,' ')||' : '||BUFFER_POOL              ||CHR(10)
&ge_90_  &FLASH_CACHE_               ||LPAD(TRIM('FLASH_CACHE               '),25,' ')||' : '||FLASH_CACHE              ||CHR(10)
&ge_90_  &CELL_FLASH_CACHE_          ||LPAD(TRIM('CELL_FLASH_CACHE          '),25,' ')||' : '||CELL_FLASH_CACHE         ||CHR(10)
&ge_90_  &ROW_MOVEMENT_              ||LPAD(TRIM('ROW_MOVEMENT              '),25,' ')||' : '||ROW_MOVEMENT             ||CHR(10)
&ge_90_  &GLOBAL_STATS_              ||LPAD(TRIM('GLOBAL_STATS              '),25,' ')||' : '||GLOBAL_STATS             ||CHR(10)
&ge_90_  &USER_STATS_                ||LPAD(TRIM('USER_STATS                '),25,' ')||' : '||USER_STATS               ||CHR(10)
&ge_90_  &DURATION_                  ||LPAD(TRIM('DURATION                  '),25,' ')||' : '||DURATION                 ||CHR(10)
&ge_90_  &SKIP_CORRUPT_              ||LPAD(TRIM('SKIP_CORRUPT              '),25,' ')||' : '||SKIP_CORRUPT             ||CHR(10)
&ge_90_  &MONITORING_                ||LPAD(TRIM('MONITORING                '),25,' ')||' : '||MONITORING               ||CHR(10)
&ge_90_  &CLUSTER_OWNER_             ||LPAD(TRIM('CLUSTER_OWNER             '),25,' ')||' : '||CLUSTER_OWNER            ||CHR(10)
&ge_90_  &DEPENDENCIES_              ||LPAD(TRIM('DEPENDENCIES              '),25,' ')||' : '||DEPENDENCIES             ||CHR(10)
&ge_90_  &COMPRESSION_               ||LPAD(TRIM('COMPRESSION               '),25,' ')||' : '||COMPRESSION              ||CHR(10)
&ge_111_ &COMPRESS_FOR_              ||LPAD(TRIM('COMPRESS_FOR              '),25,' ')||' : '||COMPRESS_FOR             ||CHR(10)
&ge_90_  &DROPPED_                   ||LPAD(TRIM('DROPPED                   '),25,' ')||' : '||DROPPED                  ||CHR(10)
&ge_112_ &READ_ONLY_                 ||LPAD(TRIM('READ_ONLY                 '),25,' ')||' : '||READ_ONLY                ||CHR(10)
&ge_112_ &SEGMENT_CREATED_           ||LPAD(TRIM('SEGMENT_CREATED           '),25,' ')||' : '||SEGMENT_CREATED          ||CHR(10)
&ge_112_ &RESULT_CACHE_              ||LPAD(TRIM('RESULT_CACHE              '),25,' ')||' : '||RESULT_CACHE             ||CHR(10)
&ge_121_ &CLUSTERING_                ||LPAD(TRIM('CLUSTERING                '),25,' ')||' : '||CLUSTERING               ||CHR(10)
&ge_121_ &ACTIVITY_TRACKING_         ||LPAD(TRIM('ACTIVITY_TRACKING         '),25,' ')||' : '||ACTIVITY_TRACKING        ||CHR(10)
&ge_121_ &DML_TIMESTAMP_             ||LPAD(TRIM('DML_TIMESTAMP             '),25,' ')||' : '||DML_TIMESTAMP            ||CHR(10)
&ge_121_ &HAS_IDENTITY_              ||LPAD(TRIM('HAS_IDENTITY              '),25,' ')||' : '||HAS_IDENTITY             ||CHR(10)
&ge_121_ &CONTAINER_DATA_            ||LPAD(TRIM('CONTAINER_DATA            '),25,' ')||' : '||CONTAINER_DATA           ||CHR(10)
&ge_121_ &INMEMORY_                  ||LPAD(TRIM('INMEMORY                  '),25,' ')||' : '||INMEMORY                 ||CHR(10)
&ge_121_ &INMEMORY_PRIORITY_         ||LPAD(TRIM('INMEMORY_PRIORITY         '),25,' ')||' : '||INMEMORY_PRIORITY        ||CHR(10)
&ge_121_ &INMEMORY_DISTRIBUTE_       ||LPAD(TRIM('INMEMORY_DISTRIBUTE       '),25,' ')||' : '||INMEMORY_DISTRIBUTE      ||CHR(10)
&ge_121_ &INMEMORY_COMPRESSION_      ||LPAD(TRIM('INMEMORY_COMPRESSION      '),25,' ')||' : '||INMEMORY_COMPRESSION     ||CHR(10)
&ge_121_ &INMEMORY_DUPLICATE_        ||LPAD(TRIM('INMEMORY_DUPLICATE        '),25,' ')||' : '||INMEMORY_DUPLICATE       ||CHR(10)
&ge_122_ &DEFAULT_COLLATION_         ||LPAD(TRIM('DEFAULT_COLLATION         '),25,' ')||' : '||DEFAULT_COLLATION        ||CHR(10)
&ge_122_ &DUPLICATED_                ||LPAD(TRIM('DUPLICATED                '),25,' ')||' : '||DUPLICATED               ||CHR(10)
&ge_122_ &SHARDED_                   ||LPAD(TRIM('SHARDED                   '),25,' ')||' : '||SHARDED                  ||CHR(10)
&ge_122_ &EXTERNAL_                  ||LPAD(TRIM('EXTERNAL                  '),25,' ')||' : '||EXTERNAL                 ||CHR(10)
&ge_122_ &CELLMEMORY_                ||LPAD(TRIM('CELLMEMORY                '),25,' ')||' : '||CELLMEMORY               ||CHR(10)
&ge_122_ &CONTAINERS_DEFAULT_        ||LPAD(TRIM('CONTAINERS_DEFAULT        '),25,' ')||' : '||CONTAINERS_DEFAULT       ||CHR(10)
&ge_122_ &CONTAINER_MAP_             ||LPAD(TRIM('CONTAINER_MAP             '),25,' ')||' : '||CONTAINER_MAP            ||CHR(10)
&ge_122_ &EXTENDED_DATA_LINK_        ||LPAD(TRIM('EXTENDED_DATA_LINK        '),25,' ')||' : '||EXTENDED_DATA_LINK       ||CHR(10)
&ge_122_ &EXTENDED_DATA_LINK_MAP_    ||LPAD(TRIM('EXTENDED_DATA_LINK_MAP    '),25,' ')||' : '||EXTENDED_DATA_LINK_MAP   ||CHR(10)
&ge_122_ &INMEMORY_SERVICE_          ||LPAD(TRIM('INMEMORY_SERVICE          '),25,' ')||' : '||INMEMORY_SERVICE         ||CHR(10)
&ge_122_ &INMEMORY_SERVICE_NAME_     ||LPAD(TRIM('INMEMORY_SERVICE_NAME     '),25,' ')||' : '||INMEMORY_SERVICE_NAME    ||CHR(10)
&ge_122_ &CONTAINER_MAP_OBJECT_      ||LPAD(TRIM('CONTAINER_MAP_OBJECT      '),25,' ')||' : '||CONTAINER_MAP_OBJECT     ||CHR(10)
info
&ge_90_  &OWNER_                     ,OWNER
&ge_90_  &TABLE_NAME_                ,TABLE_NAME
&ge_90_  &TABLESPACE_NAME_           ,TABLESPACE_NAME
&ge_90_  &CLUSTER_NAME_              ,CLUSTER_NAME
&ge_90_  &IOT_NAME_                  ,IOT_NAME
&ge_102_ &STATUS_                    ,STATUS
&ge_90_  &PCT_FREE_                  ,PCT_FREE
&ge_90_  &PCT_USED_                  ,PCT_USED
&ge_90_  &INI_TRANS_                 ,INI_TRANS
&ge_90_  &MAX_TRANS_                 ,MAX_TRANS
&ge_90_  &INITIAL_EXTENT_            ,INITIAL_EXTENT
&ge_90_  &NEXT_EXTENT_               ,NEXT_EXTENT
&ge_90_  &MIN_EXTENTS_               ,MIN_EXTENTS
&ge_90_  &MAX_EXTENTS_               ,MAX_EXTENTS
&ge_90_  &PCT_INCREASE_              ,PCT_INCREASE
&ge_90_  &FREELISTS_                 ,FREELISTS
&ge_90_  &FREELIST_GROUPS_           ,FREELIST_GROUPS
&ge_90_  &LOGGING_                   ,LOGGING
&ge_90_  &BACKED_UP_                 ,BACKED_UP
&ge_90_  &NUM_ROWS_                  ,NUM_ROWS
&ge_90_  &BLOCKS_                    ,BLOCKS
&ge_90_  &EMPTY_BLOCKS_              ,EMPTY_BLOCKS
&ge_90_  &AVG_SPACE_                 ,AVG_SPACE
&ge_90_  &CHAIN_CNT_                 ,CHAIN_CNT
&ge_90_  &AVG_ROW_LEN_               ,AVG_ROW_LEN
&ge_90_  &AVG_SPACE_FREELIST_BLOCKS_ ,AVG_SPACE_FREELIST_BLOCKS
&ge_90_  &NUM_FREELIST_BLOCKS_       ,NUM_FREELIST_BLOCKS
&ge_90_  &DEGREE_                    ,DEGREE
&ge_90_  &INSTANCES_                 ,INSTANCES
&ge_90_  &CACHE_                     ,CACHE
&ge_90_  &TABLE_LOCK_                ,TABLE_LOCK
&ge_90_  &SAMPLE_SIZE_               ,SAMPLE_SIZE
&ge_90_  &LAST_ANALYZED_             ,LAST_ANALYZED
&ge_90_  &PARTITIONED_               ,PARTITIONED
&ge_90_  &IOT_TYPE_                  ,IOT_TYPE
&ge_90_  &TEMPORARY_                 ,TEMPORARY
&ge_90_  &SECONDARY_                 ,SECONDARY
&ge_90_  &NESTED_                    ,NESTED
&ge_90_  &BUFFER_POOL_               ,BUFFER_POOL
&ge_90_  &FLASH_CACHE_               ,FLASH_CACHE
&ge_90_  &CELL_FLASH_CACHE_          ,CELL_FLASH_CACHE
&ge_90_  &ROW_MOVEMENT_              ,ROW_MOVEMENT
&ge_90_  &GLOBAL_STATS_              ,GLOBAL_STATS
&ge_90_  &USER_STATS_                ,USER_STATS
&ge_90_  &DURATION_                  ,DURATION
&ge_90_  &SKIP_CORRUPT_              ,SKIP_CORRUPT
&ge_90_  &MONITORING_                ,MONITORING
&ge_90_  &CLUSTER_OWNER_             ,CLUSTER_OWNER
&ge_90_  &DEPENDENCIES_              ,DEPENDENCIES
&ge_90_  &COMPRESSION_               ,COMPRESSION
&ge_111_ &COMPRESS_FOR_              ,COMPRESS_FOR
&ge_90_  &DROPPED_                   ,DROPPED
&ge_112_ &READ_ONLY_                 ,READ_ONLY
&ge_112_ &SEGMENT_CREATED_           ,SEGMENT_CREATED
&ge_112_ &RESULT_CACHE_              ,RESULT_CACHE
&ge_121_ &CLUSTERING_                ,CLUSTERING
&ge_121_ &ACTIVITY_TRACKING_         ,ACTIVITY_TRACKING
&ge_121_ &DML_TIMESTAMP_             ,DML_TIMESTAMP
&ge_121_ &HAS_IDENTITY_              ,HAS_IDENTITY
&ge_121_ &CONTAINER_DATA_            ,CONTAINER_DATA
&ge_121_ &INMEMORY_                  ,INMEMORY
&ge_121_ &INMEMORY_PRIORITY_         ,INMEMORY_PRIORITY
&ge_121_ &INMEMORY_DISTRIBUTE_       ,INMEMORY_DISTRIBUTE
&ge_121_ &INMEMORY_COMPRESSION_      ,INMEMORY_COMPRESSION
&ge_121_ &INMEMORY_DUPLICATE_        ,INMEMORY_DUPLICATE
&ge_122_ &DEFAULT_COLLATION_         ,DEFAULT_COLLATION
&ge_122_ &DUPLICATED_                ,DUPLICATED
&ge_122_ &SHARDED_                   ,SHARDED
&ge_122_ &EXTERNAL_                  ,EXTERNAL
&ge_122_ &CELLMEMORY_                ,CELLMEMORY
&ge_122_ &CONTAINERS_DEFAULT_        ,CONTAINERS_DEFAULT
&ge_122_ &CONTAINER_MAP_             ,CONTAINER_MAP
&ge_122_ &EXTENDED_DATA_LINK_        ,EXTENDED_DATA_LINK
&ge_122_ &EXTENDED_DATA_LINK_MAP_    ,EXTENDED_DATA_LINK_MAP
&ge_122_ &INMEMORY_SERVICE_          ,INMEMORY_SERVICE
&ge_122_ &INMEMORY_SERVICE_NAME_     ,INMEMORY_SERVICE_NAME
&ge_122_ &CONTAINER_MAP_OBJECT_      ,CONTAINER_MAP_OBJECT
FROM dba_tables
WHERE &where_
&ORDENAR_ ORDER BY &columns_
) tabs
;

CLEAR BREAKS
CLEAR COLUMNS
