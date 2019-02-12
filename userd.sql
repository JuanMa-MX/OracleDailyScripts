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
PROMPT [ USERNAME       DEFAULT_TABLESPACE          EXTERNAL_NAME       LAST_LOGIN        ]
PROMPT [ USER_ID        TEMPORARY_TABLESPACE        PASSWORD_VERSIONS   ORACLE_MAINTAINED ]
PROMPT [ PASSWORD       LOCAL_TEMP_TABLESPACE       EDITIONS_ENABLED    INHERITED         ]
PROMPT [ ACCOUNT_STATUS CREATED                     AUTHENTICATION_TYPE DEFAULT_COLLATION ]
PROMPT [ LOCK_DATE      PROFILE                     PROXY_ONLY_CONNECT  IMPLICIT          ]
PROMPT [ EXPIRY_DATE    INITIAL_RSRC_CONSUMER_GROUP COMMON              ALL_SHARD         ]
PROMPT
PROMPT Comun [ USERNAME,ACCOUNT_STATUS,DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE,PROFILE,CREATED,LAST_LOGIN ]
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

select case when &oracle_version_ >= 9.0  then '' else '--' end ge_90  from v$instance;
select case when &oracle_version_ >= 11.1 then '' else '--' end ge_111 from v$instance;
select case when &oracle_version_ >= 11.2 then '' else '--' end ge_112 from v$instance;
select case when &oracle_version_ >= 12.1 then '' else '--' end ge_121 from v$instance;
select case when &oracle_version_ >= 12.2 then '' else '--' end ge_122 from v$instance;

COL USERNAME                    NEW_VALUE USERNAME_
COL USER_ID                     NEW_VALUE USER_ID_
COL PASSWORD                    NEW_VALUE PASSWORD_
COL ACCOUNT_STATUS              NEW_VALUE ACCOUNT_STATUS_
COL LOCK_DATE                   NEW_VALUE LOCK_DATE_
COL EXPIRY_DATE                 NEW_VALUE EXPIRY_DATE_
COL DEFAULT_TABLESPACE          NEW_VALUE DEFAULT_TABLESPACE_
COL TEMPORARY_TABLESPACE        NEW_VALUE TEMPORARY_TABLESPACE_
COL LOCAL_TEMP_TABLESPACE       NEW_VALUE LOCAL_TEMP_TABLESPACE_
COL CREATED                     NEW_VALUE CREATED_
COL PROFILE                     NEW_VALUE PROFILE_
COL INITIAL_RSRC_CONSUMER_GROUP NEW_VALUE INITIAL_RSRC_CONSUMER_GROUP_
COL EXTERNAL_NAME               NEW_VALUE EXTERNAL_NAME_
COL PASSWORD_VERSIONS           NEW_VALUE PASSWORD_VERSIONS_
COL EDITIONS_ENABLED            NEW_VALUE EDITIONS_ENABLED_
COL AUTHENTICATION_TYPE         NEW_VALUE AUTHENTICATION_TYPE_
COL PROXY_ONLY_CONNECT          NEW_VALUE PROXY_ONLY_CONNECT_
COL COMMON                      NEW_VALUE COMMON_
COL LAST_LOGIN                  NEW_VALUE LAST_LOGIN_
COL ORACLE_MAINTAINED           NEW_VALUE ORACLE_MAINTAINED_
COL INHERITED                   NEW_VALUE INHERITED_
COL DEFAULT_COLLATION           NEW_VALUE DEFAULT_COLLATION_
COL IMPLICIT                    NEW_VALUE IMPLICIT_
COL ALL_SHARD                   NEW_VALUE ALL_SHARD_
COL ORDENAR                     NEW_VALUE ORDENAR_

SELECT
 CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('USERNAME                   ')) > 0 THEN ''   ELSE '--' END USERNAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('USER_ID                    ')) > 0 THEN ''   ELSE '--' END USER_ID
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PASSWORD                   ')) > 0 THEN ''   ELSE '--' END PASSWORD
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ACCOUNT_STATUS             ')) > 0 THEN ''   ELSE '--' END ACCOUNT_STATUS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LOCK_DATE                  ')) > 0 THEN ''   ELSE '--' END LOCK_DATE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXPIRY_DATE                ')) > 0 THEN ''   ELSE '--' END EXPIRY_DATE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEFAULT_TABLESPACE         ')) > 0 THEN ''   ELSE '--' END DEFAULT_TABLESPACE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('TEMPORARY_TABLESPACE       ')) > 0 THEN ''   ELSE '--' END TEMPORARY_TABLESPACE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LOCAL_TEMP_TABLESPACE      ')) > 0 THEN ''   ELSE '--' END LOCAL_TEMP_TABLESPACE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('CREATED                    ')) > 0 THEN ''   ELSE '--' END CREATED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PROFILE                    ')) > 0 THEN ''   ELSE '--' END PROFILE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INITIAL_RSRC_CONSUMER_GROUP')) > 0 THEN ''   ELSE '--' END INITIAL_RSRC_CONSUMER_GROUP
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EXTERNAL_NAME              ')) > 0 THEN ''   ELSE '--' END EXTERNAL_NAME
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PASSWORD_VERSIONS          ')) > 0 THEN ''   ELSE '--' END PASSWORD_VERSIONS
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('EDITIONS_ENABLED           ')) > 0 THEN ''   ELSE '--' END EDITIONS_ENABLED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('AUTHENTICATION_TYPE        ')) > 0 THEN ''   ELSE '--' END AUTHENTICATION_TYPE
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('PROXY_ONLY_CONNECT         ')) > 0 THEN ''   ELSE '--' END PROXY_ONLY_CONNECT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('COMMON                     ')) > 0 THEN ''   ELSE '--' END COMMON
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('LAST_LOGIN                 ')) > 0 THEN ''   ELSE '--' END LAST_LOGIN
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ORACLE_MAINTAINED          ')) > 0 THEN ''   ELSE '--' END ORACLE_MAINTAINED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('INHERITED                  ')) > 0 THEN ''   ELSE '--' END INHERITED
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('DEFAULT_COLLATION          ')) > 0 THEN ''   ELSE '--' END DEFAULT_COLLATION
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('IMPLICIT                   ')) > 0 THEN ''   ELSE '--' END IMPLICIT
,CASE WHEN '&columns_' = '*' OR INSTR(UPPER('&columns_'),TRIM('ALL_SHARD                  ')) > 0 THEN ''   ELSE '--' END ALL_SHARD
,CASE WHEN '&columns_' = '*'                                                                      THEN '--' ELSE ''   END ORDENAR
FROM dual
;

set term on

CLEAR BREAKS
CLEAR COLUMNS

COL info FOR A80

COL USERNAME                    NOPRINT
COL USER_ID                     NOPRINT
COL PASSWORD                    NOPRINT
COL ACCOUNT_STATUS              NOPRINT
COL LOCK_DATE                   NOPRINT
COL EXPIRY_DATE                 NOPRINT
COL DEFAULT_TABLESPACE          NOPRINT
COL TEMPORARY_TABLESPACE        NOPRINT
COL LOCAL_TEMP_TABLESPACE       NOPRINT
COL CREATED                     NOPRINT
COL PROFILE                     NOPRINT
COL INITIAL_RSRC_CONSUMER_GROUP NOPRINT
COL EXTERNAL_NAME               NOPRINT
COL PASSWORD_VERSIONS           NOPRINT
COL EDITIONS_ENABLED            NOPRINT
COL AUTHENTICATION_TYPE         NOPRINT
COL PROXY_ONLY_CONNECT          NOPRINT
COL COMMON                      NOPRINT
COL LAST_LOGIN                  NOPRINT
COL ORACLE_MAINTAINED           NOPRINT
COL INHERITED                   NOPRINT
COL DEFAULT_COLLATION           NOPRINT
COL IMPLICIT                    NOPRINT
COL ALL_SHARD                   NOPRINT

SELECT ROWNUM, users.*
FROM (
SELECT                                  ''
&ge_90_  &USERNAME_                    ||LPAD(TRIM('USERNAME                   '),27,' ')||' : '||USERNAME                   ||CHR(10)
&ge_90_  &USER_ID_                     ||LPAD(TRIM('USER_ID                    '),27,' ')||' : '||USER_ID                    ||CHR(10)
&ge_90_  &PASSWORD_                    ||LPAD(TRIM('PASSWORD                   '),27,' ')||' : '||PASSWORD                   ||CHR(10)
&ge_90_  &ACCOUNT_STATUS_              ||LPAD(TRIM('ACCOUNT_STATUS             '),27,' ')||' : '||ACCOUNT_STATUS             ||CHR(10)
&ge_90_  &LOCK_DATE_                   ||LPAD(TRIM('LOCK_DATE                  '),27,' ')||' : '||TO_CHAR(LOCK_DATE,'YYYY-MM-DD HH24:MI:SS')||CHR(10)
&ge_90_  &EXPIRY_DATE_                 ||LPAD(TRIM('EXPIRY_DATE                '),27,' ')||' : '||TO_CHAR(EXPIRY_DATE,'YYYY-MM-DD HH24:MI:SS')||CHR(10)
&ge_90_  &DEFAULT_TABLESPACE_          ||LPAD(TRIM('DEFAULT_TABLESPACE         '),27,' ')||' : '||DEFAULT_TABLESPACE         ||CHR(10)
&ge_90_  &TEMPORARY_TABLESPACE_        ||LPAD(TRIM('TEMPORARY_TABLESPACE       '),27,' ')||' : '||TEMPORARY_TABLESPACE       ||CHR(10)
&ge_122_ &LOCAL_TEMP_TABLESPACE_       ||LPAD(TRIM('LOCAL_TEMP_TABLESPACE      '),27,' ')||' : '||LOCAL_TEMP_TABLESPACE      ||CHR(10)
&ge_90_  &CREATED_                     ||LPAD(TRIM('CREATED                    '),27,' ')||' : '||TO_CHAR(CREATED,'YYYY-MM-DD HH24:MI:SS')||CHR(10)
&ge_90_  &PROFILE_                     ||LPAD(TRIM('PROFILE                    '),27,' ')||' : '||PROFILE                    ||CHR(10)
&ge_90_  &INITIAL_RSRC_CONSUMER_GROUP_ ||LPAD(TRIM('INITIAL_RSRC_CONSUMER_GROUP'),27,' ')||' : '||INITIAL_RSRC_CONSUMER_GROUP||CHR(10)
&ge_90_  &EXTERNAL_NAME_               ||LPAD(TRIM('EXTERNAL_NAME              '),27,' ')||' : '||EXTERNAL_NAME              ||CHR(10)
&ge_90_  &PASSWORD_VERSIONS_           ||LPAD(TRIM('PASSWORD_VERSIONS          '),27,' ')||' : '||PASSWORD_VERSIONS          ||CHR(10)
&ge_90_  &EDITIONS_ENABLED_            ||LPAD(TRIM('EDITIONS_ENABLED           '),27,' ')||' : '||EDITIONS_ENABLED           ||CHR(10)
&ge_112_ &AUTHENTICATION_TYPE_         ||LPAD(TRIM('AUTHENTICATION_TYPE        '),27,' ')||' : '||AUTHENTICATION_TYPE        ||CHR(10)
&ge_121_ &PROXY_ONLY_CONNECT_          ||LPAD(TRIM('PROXY_ONLY_CONNECT         '),27,' ')||' : '||PROXY_ONLY_CONNECT         ||CHR(10)
&ge_121_ &COMMON_                      ||LPAD(TRIM('COMMON                     '),27,' ')||' : '||COMMON                     ||CHR(10)
&ge_121_ &LAST_LOGIN_                  ||LPAD(TRIM('LAST_LOGIN                 '),27,' ')||' : '||TO_CHAR(LAST_LOGIN,'YYYY-MM-DD HH24:MI:SS')||CHR(10)
&ge_121_ &ORACLE_MAINTAINED_           ||LPAD(TRIM('ORACLE_MAINTAINED          '),27,' ')||' : '||ORACLE_MAINTAINED          ||CHR(10)
&ge_122_ &INHERITED_                   ||LPAD(TRIM('INHERITED                  '),27,' ')||' : '||INHERITED                  ||CHR(10)
&ge_122_ &DEFAULT_COLLATION_           ||LPAD(TRIM('DEFAULT_COLLATION          '),27,' ')||' : '||DEFAULT_COLLATION          ||CHR(10)
&ge_122_ &IMPLICIT_                    ||LPAD(TRIM('IMPLICIT                   '),27,' ')||' : '||IMPLICIT                   ||CHR(10)
&ge_122_ &ALL_SHARD_                   ||LPAD(TRIM('ALL_SHARD                  '),27,' ')||' : '||ALL_SHARD                  ||CHR(10)
info
&ge_90_  &USERNAME_                    ,USERNAME
&ge_90_  &USER_ID_                     ,USER_ID
&ge_90_  &PASSWORD_                    ,PASSWORD
&ge_90_  &ACCOUNT_STATUS_              ,ACCOUNT_STATUS
&ge_90_  &LOCK_DATE_                   ,LOCK_DATE
&ge_90_  &EXPIRY_DATE_                 ,EXPIRY_DATE
&ge_90_  &DEFAULT_TABLESPACE_          ,DEFAULT_TABLESPACE
&ge_90_  &TEMPORARY_TABLESPACE_        ,TEMPORARY_TABLESPACE
&ge_122_ &LOCAL_TEMP_TABLESPACE_       ,LOCAL_TEMP_TABLESPACE
&ge_90_  &CREATED_                     ,CREATED
&ge_90_  &PROFILE_                     ,PROFILE
&ge_90_  &INITIAL_RSRC_CONSUMER_GROUP_ ,INITIAL_RSRC_CONSUMER_GROUP
&ge_90_  &EXTERNAL_NAME_               ,EXTERNAL_NAME
&ge_90_  &PASSWORD_VERSIONS_           ,PASSWORD_VERSIONS
&ge_90_  &EDITIONS_ENABLED_            ,EDITIONS_ENABLED
&ge_112_ &AUTHENTICATION_TYPE_         ,AUTHENTICATION_TYPE
&ge_121_ &PROXY_ONLY_CONNECT_          ,PROXY_ONLY_CONNECT
&ge_121_ &COMMON_                      ,COMMON
&ge_121_ &LAST_LOGIN_                  ,LAST_LOGIN
&ge_121_ &ORACLE_MAINTAINED_           ,ORACLE_MAINTAINED
&ge_122_ &INHERITED_                   ,INHERITED
&ge_122_ &DEFAULT_COLLATION_           ,DEFAULT_COLLATION
&ge_122_ &IMPLICIT_                    ,IMPLICIT
&ge_122_ &ALL_SHARD_                   ,ALL_SHARD
FROM dba_users
WHERE &where_
&ORDENAR_ ORDER BY &columns_
) users
;

CLEAR BREAKS
CLEAR COLUMNS
