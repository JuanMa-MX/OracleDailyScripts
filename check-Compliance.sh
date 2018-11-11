#!/bin/bash

#--------------------------------------------------------------------------------#

function titulo()
{
   SECCIONES=$(( ${SECCIONES} + 1));
   linea='-----------------------------------------------------------';
   echo "";
   echo "";
   echo "${linea}";
   echo "(${SECCIONES}) ${1}"
   echo "${linea}";
   echo "";
}

#--------------------------------------------------------------------------------#

function minuscula()
{
   mi="$(echo ${1} | awk '{print tolower($0)}')";
   echo "${mi}";
}

#--------------------------------------------------------------------------------#

function mayuscula()
{
   mi="$(echo ${1} | awk '{print toupper($0)}')";
   echo "${mi}";
}

#--------------------------------------------------------------------------------#

function EsValorNulo()
{
   if [ -z "${1}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#--------------------------------------------------------------------------------#

function ExisteArchivo()
{
   if [ -f "${1}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#--------------------------------------------------------------------------------#

function ExisteDirectorio()
{
   if [ -d "${1}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#--------------------------------------------------------------------------------#

function INSTANCE_STATUS()
{
   EstadoBD="$(sqlplus -S /NOLOG <<_codigo_
CONNECT / AS SYSDBA

SET HEADING OFF
SET PAGES 0
SET FEEDBACK OFF

SELECT status FROM v\$instance;

EXIT;
_codigo_
)";

   case "${EstadoBD}" in
   "STARTED"|"MOUNTED"|"OPEN")
      echo "${EstadoBD}";
   ;;
   *)
      echo "DOWN";
   ;;
   esac
}

#--------------------------------------------------------------------------------#

function DATABASE_DATABASE_ROLE()
{
   RolBD="$(sqlplus -S /NOLOG <<_codigo_
CONNECT / AS SYSDBA

SET HEADING OFF
SET PAGES 0
SET FEEDBACK OFF

SELECT database_role FROM v\$database;

EXIT;
_codigo_
)";

   case "${RolBD}" in
   "LOGICAL STANDBY"|"PHYSICAL STANDBY"|"PRIMARY")
      echo "${RolBD}";
   ;;
   *)
      echo "UNKNOWN";
   ;;
   esac
}

#--------------------------------------------------------------------------------#

function ExisteTablespace()
{
   tbs_a_buscar="$(mayuscula "${1}")";

   tbs_encontrado=$(sqlplus -S /NOLOG <<_codigo_
CONNECT / AS SYSDBA

SET HEADING OFF
SET PAGES 0
SET FEEDBACK OFF

SELECT UPPER(name) tbs FROM v\$tablespace
WHERE name = '${tbs_a_buscar}'
;

EXIT;
_codigo_
);

   if [ "${tbs_a_buscar}" = "${tbs_encontrado}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#--------------------------------------------------------------------------------#

function ValorDeParametro()
{
parametro_a_buscar="${1}";
   sqlplus -S /NOLOG <<_codigo_
CONNECT / AS SYSDBA

SET HEADING OFF
SET PAGES 0
SET FEEDBACK OFF

SELECT LOWER(value) par FROM v\$parameter
WHERE LOWER(name) = LOWER('${parametro_a_buscar}')
;

EXIT;
_codigo_
}

#--------------------------------------------------------------------------------#

function ValorDePropiedad()
{
   propiedad_a_buscar="$(minuscula "${1}")";
   valor_propiedad=$(sqlplus -S /NOLOG <<_codigo_
CONNECT / AS SYSDBA

SET HEADING OFF
SET PAGES 0
SET FEEDBACK OFF

SELECT LOWER(property_value) par FROM database_properties
WHERE LOWER(property_name) = '${propiedad_a_buscar}'
;

EXIT;
_codigo_
);

   echo "${valor_propiedad}";
}

#--------------------------------------------------------------------------------#

function VerificaParametroBD()
{
   parametro="$(minuscula "${1}")";
   valorActual="$(ValorDeParametro "${parametro}")";
   valorEsperado="${2}";

   etiqueta="[ OK  ]";

   if [ "${parametro}" = "audit_syslog_level" ];
   then
      case "${valorActual}" in
      "local1.notice"|"local2.notice"|"local3.notice"|"local4.notice"|"local5.notice"|"local1.warning"|"local2.warning"|"local3.warning"|"local4.warning"|"local5.warning")
         etiqueta="[ OK  ]";
      ;;
      *)
         etiqueta="[ERROR]";
      ;;
      esac
   else
      [ "${valorActual}" = "${valorEsperado}" ] && etiqueta="[ OK  ]" || etiqueta="[ERROR]";
   fi

   if [ "$(EsValorNulo "${valorActual}")" = "S" ];
   then
      valorActual="No configurado";
   fi

   if [ "${etiqueta}" = "[ OK  ]" ];
   then
      valorActual="Si[${valorActual}]";
   else
      valorActual="No[${valorActual}]";
      CODIGO_SALIDA=1;
   fi

   printf "%s %-50s %-20s\n" "${etiqueta}" "${parametro}=${valorEsperado}?" "${valorActual}";
}

#--------------------------------------------------------------------------------#

function VerificaExistenciaTablespaceBD()
{
   tablespace="${1}";
   [ "$(ExisteTablespace "${tablespace}")" = "S" ] && valorActual="Si" || valorActual="No";

   valorEsperado="Si";

   etiqueta="[ OK  ]";

   [ "${valorActual}" = "${valorEsperado}" ] && etiqueta="[ OK  ]" || etiqueta="[ERROR]";

   if [ "${etiqueta}" = "[ OK  ]" ];
   then
      valorActual="Si";
   else
      valorActual="No";
      CODIGO_SALIDA=1;
   fi

   printf "%s %-40s %-20s\n" "${etiqueta}" "Existe tablespace '${tablespace}'?" "${valorActual}";
}

#--------------------------------------------------------------------------------#

function VerificaPropiedadBD()
{
   propiedad="${1}";
   valorActual="$(ValorDePropiedad "${propiedad}")";
   valorEsperado="${2}";

   etiqueta="[ OK  ]";

   [ "${valorActual}" = "${valorEsperado}" ] && etiqueta="[ OK  ]" || etiqueta="[ERROR]";

   if [ "${etiqueta}" = "[ OK  ]" ];
   then
      valorActual="Si[${valorActual}]";
   else
      valorActual="No[${valorActual}]";
      CODIGO_SALIDA=1;
   fi

   printf "%s %-50s %-20s\n" "${etiqueta}" "${propiedad}=${valorEsperado}?" "${valorActual}";
}

#--------------------------------------------------------------------------------#

function RevisaFileSystem()
{
   FILESYSTEM="${1}";

   echo "";
   echo "Filesystem: ${FILESYSTEM}";
   echo "";

   grep -qs ${FILESYSTEM} /proc/mounts;
   MONTADO=$?;
   [ ${MONTADO} -eq 0 ] && MONTADO="Si" || MONTADO="No";

   etiqueta="[ OK  ]";

   if [ ${MONTADO} = "No" ];
   then
      etiqueta="[ERROR]";
      CODIGO_SALIDA=1;
   fi

   printf "%s %-30s %-20s\n" "${etiqueta}" "Montado?" "${MONTADO}"

   OWNERSHIP="$(stat --format="%U:%G" "${FILESYSTEM}")";

   etiqueta="[ OK  ]";

   if [ "${OWNERSHIP}" = "${ORAUSER}:${ORADBA}" ];
   then
      OWNERSHIP="Si[${OWNERSHIP}]";
   else
      etiqueta="[ERROR]";
      CODIGO_SALIDA=1;
      OWNERSHIP="No[${OWNERSHIP}]";
   fi
   printf "%s %-30s %-20s\n" "${etiqueta}" "Ownership ${ORAUSER}:${ORADBA}?" "${OWNERSHIP}";
   #echo "chown ${ORAUSER}:${ORADBA} ${FILESYSTEM}" >> ${ARCHIVO_FIX};

   PERMISOS="$(stat --format="%a" "${FILESYSTEM}")";

   etiqueta="[ OK  ]";

   if [ "${PERMISOS}" = "750" ];
   then
      PERMISOS="Si[${PERMISOS}]";
   else
      etiqueta="[ERROR]";
      CODIGO_SALIDA=1;
      PERMISOS="No[${PERMISOS}]";
   fi
   printf "%s %-30s %-20s\n" "${etiqueta}" "Permisos 750?" "${PERMISOS}";
   #echo "chmod 750 ${FILESYSTEM}" >> ${ARCHIVO_FIX};

   touch ${FILESYSTEM}/touch.test &> /dev/null;
   LECTURAYESCRITURA=$?;
   [ ${LECTURAYESCRITURA} -eq 0 ] && LECTURAYESCRITURA="Si" || LECTURAYESCRITURA="No";

   rm -rf ${FILESYSTEM}/touch.test &> /dev/null;

   etiqueta="[ OK  ]";

   if [ "${LECTURAYESCRITURA}" != "Si" ];
   then
      etiqueta="[ERROR]";
      CODIGO_SALIDA=1;
   fi
   printf "%s %-30s %-20s\n" "${etiqueta}" "Lectura/Escritura?" "${LECTURAYESCRITURA}"
   #echo "chmod 750 ${FILESYSTEM}" >> ${ARCHIVO_FIX};
}

#--------------------------------------------------------------------------------#

function ComplianceFileSystems()
{
   titulo "Revision de FileSystems";

   for fs in $(ls -l / | awk '{print $9}' | grep "${ORACLE_SID}$")
   do
      RevisaFileSystem "/${fs}";
   done

   fsCC="$(ls -l / | awk '{print $9}' | grep -E "^ccontrol$|^cloudcontrol$")";

   if [ "$(EsValorNulo "${fsCC}")" = "S" ];
   then
      fsCC="cloudcontrol";
   fi

   for fs in $(echo "${fsCC} prog")
   do
      RevisaFileSystem "/${fs}";
   done
}

#--------------------------------------------------------------------------------#

function ComplianceParametros()
{
   titulo "Revision de Parametros de Base de Datos";

   case "${ESTADO_BD}" in
   "STARTED"|"MOUNTED"|"OPEN")
      VerificaParametroBD "os_roles" "false";
      VerificaParametroBD "remote_os_roles" "false";
      VerificaParametroBD "remote_login_passwordfile" "exclusive";
      VerificaParametroBD "resource_limit" "true";
      VerificaParametroBD "sql92_security" "true";
      VerificaParametroBD "audit_sys_operations" "true";
      VerificaParametroBD "_trace_files_public" "false";
      VerificaParametroBD "_system_trig_enabled" "true";
      VerificaParametroBD "audit_trail" "os";
      VerificaParametroBD "audit_syslog_level" "local[1-5].[notice|warning]";
      VerificaParametroBD "use_large_pages" "only";
   ;;
   *)
      echo "[ERROR] Base de Datos en Modo '${ESTADO_BD}'.";
      CODIGO_SALIDA=1;
   ;;
   esac
}

#--------------------------------------------------------------------------------#

function ComplianceTablespaces()
{
   titulo "Revision de Tablespaces de Base de Datos";

   case "${ESTADO_BD}" in
   "MOUNTED"|"OPEN")
      VerificaExistenciaTablespaceBD "system";
      VerificaExistenciaTablespaceBD "sysaux";
      VerificaExistenciaTablespaceBD "undotbs";
      VerificaExistenciaTablespaceBD "temp";
      VerificaExistenciaTablespaceBD "tbs_default";
      VerificaExistenciaTablespaceBD "tbs_data_s_aa";
      VerificaExistenciaTablespaceBD "tbs_data_m_aa";
      VerificaExistenciaTablespaceBD "tbs_data_b_aa";
      VerificaExistenciaTablespaceBD "tbs_indx_s_aa";
      VerificaExistenciaTablespaceBD "tbs_indx_m_aa";
      VerificaExistenciaTablespaceBD "tbs_indx_b_aa";
   ;;
   *)
      echo "[ERROR] Base de Datos en Modo '${ESTADO_BD}'.";
      CODIGO_SALIDA=1;
   ;;
   esac
}

#--------------------------------------------------------------------------------#

function CompliancePropiedades()
{
   titulo "Revision de Propiedades de Base de Datos";

   iEsStandby="$([ "${ROL_BD}" = "PHYSICAL STANDBY" ] && echo "S" || echo "N")";

   if [ "${iEsStandby}" = "S" ];
   then
      echo "[ OK  ] Rol de Base de Datos '${ROL_BD}'.";
   else
      case "${ESTADO_BD}" in
      "OPEN")
         VerificaPropiedadBD "default_permanent_tablespace" "tbs_default";
         VerificaPropiedadBD "default_temp_tablespace" "temp";
      ;;
      *)
         echo "[ERROR] Base de Datos en Modo '${ESTADO_BD}'.";
         CODIGO_SALIDA=1;
      ;;
      esac
   fi
}

#--------------------------------------------------------------------------------#

function ORAENV()
{
   RETORNO=1;
   export ORAUSER="prhtorac";
   export ORADBA="dba";
   export ORACLE_SID=${1};
   export ORACLE_BASE="/dboracle-${ORACLE_SID}";

   for SUBDIR in $(ls -l ${ORACLE_BASE} | grep "^d" | awk '{print $9}')
   do
      OH="${ORACLE_BASE}/${SUBDIR}";
      if [ "$(ExisteDirectorio "${OH}/bin")" = "S" ];
      then
         export ORACLE_HOME="${OH}";
         export LD_LIBRARY_PATH="${ORACLE_HOME}/lib";
         export PATH="${ORACLE_HOME}/bin:${PATH}";
         export TNS_ADMIN="${ORACLE_HOME}/network/admin";
         export SPFILE="${ORACLE_HOME}/dbs/spfile$(minuscula "${ORACLE_SID}").ora";
         export PFILE="${ORACLE_HOME}/dbs/init$(minuscula "${ORACLE_SID}").ora";
         export ESTADO_BD="$(INSTANCE_STATUS)";
         export ROL_BD="$(DATABASE_DATABASE_ROLE)";
         export HOSTNAME="$(hostname)";
         export LISTENER_ORA="${TNS_ADMIN}/listener.ora";
         RETORNO=0;
      fi
   done

return ${RETORNO};
}

#--------------------------------------------------------------------------------#

function ValorParametroListener()
{
   lNOMBRE_LISTENER="${1}";
   lPARAMETRO_LISTENER="${2}";

   lVALOR_PARAMETRO="$(grep -v "#" ${LISTENER_ORA} | sed 's/ //g;' | \
                       grep -i "^${lPARAMETRO_LISTENER}_${lNOMBRE_LISTENER}=.*$" | \
                       awk -F"=" '{print $2}')";

echo "$([ "$(EsValorNulo "${lVALOR_PARAMETRO}")" = "S" ] && echo "PARAMETER_NOT_FOUND" || echo "${lVALOR_PARAMETRO}")";
}

#--------------------------------------------------------------------------------#

function VerificaParametroDeListener()
{
   iNombreDeListener="$(mayuscula "${1}")";
   iNombreDeParametroDeListener="$(mayuscula "${2}")";
   valorEsperado="${3}";
   valorActual="$(ValorParametroListener "${iNombreDeListener}" "${iNombreDeParametroDeListener}")";

   dbtrac="/dbtrac01-${ORACLE_SID}";

   etiqueta="[ OK  ]";

   case "${iNombreDeParametroDeListener}" in
      "IS_ACTIVE")
         etiqueta="[ OK  ]";

         procId="$(ps -ef | grep -w "tnslsnr" | grep -iw "${iNombreDeListener}" | awk '{print $2}')";

         if [ "$(EsValorNulo "${procId}")" = "S" ];
         then
            etiqueta="[ERROR]";
            valorActual="No[PORT=UNKNOWN]";
         else
            puertoListener="$(netstat -tulpn 2>/dev/null | awk '/'${procId}'\/tnslsnr/{print $4}' | cut -d":" -f2)";
            valorActual="Si[PORT=${puertoListener}]";
         fi
         printf "%s %-87s %-20s\n" "${etiqueta}" "Listener activo?" "${valorActual}";
      ;;
      "ADR_BASE")
         etiqueta="[ OK  ]";

         if [ "$(ExisteDirectorio "${valorActual}")" = "N" ]; then etiqueta="[ERROR]"; fi

         if [ "${etiqueta}" = "[ OK  ]" ];
         then
            valorActualAux="Si";
         else
            valorActualAux="No";
            CODIGO_SALIDA=1;
         fi

         printf "%s %-87s %-20s\n" "${etiqueta}" "ADR_BASE: Existe dir. '${valorActual}'?" "${valorActualAux}";

         etiqueta="[ OK  ]";
         enDBTRAC="$(echo "${valorActual}" | grep "${dbtrac}")";

         if [ "$(EsValorNulo "${enDBTRAC}")" = "S" ]; then etiqueta="[ERROR]"; fi

         if [ "${etiqueta}" = "[ OK  ]" ];
         then
            valorActualAux="Si";
         else
            valorActualAux="No";
            CODIGO_SALIDA=1;
         fi

         printf "%s %-87s %-20s\n" "${etiqueta}" "ADR_BASE: Dir. '${valorActual}' en '${dbtrac}'?" "${valorActualAux}";
      ;;
      *)
         valorEsperado="$(mayuscula "${valorEsperado}")";
         valorActual="$(mayuscula "${valorActual}")";
         if ! [ ${valorActual} = ${valorEsperado} ];
         then
            etiqueta="[ERROR]";
         fi

         if [ "${etiqueta}" = "[ OK  ]" ];
         then
            valorActual="Si[${valorActual}]";
         else
            valorActual="No[${valorActual}]";
            CODIGO_SALIDA=1;
         fi

         printf "%s %-87s %-20s\n" "${etiqueta}" "${iNombreDeParametroDeListener}=${valorEsperado}?" "${valorActual}";
      ;;
   esac
}

#--------------------------------------------------------------------------------#

function ComplianceListeners()
{
   titulo "Revision de Configuracion de Listeners";

   PREFIJO_LISTENER="$(echo "LISTENER_${ORACLE_SID}" | awk '{print toupper($0)}')";

   LISTA_LISTENERS=$(grep -v "#" ${LISTENER_ORA} | sed 's/ //g;' | tr '=' '\n' | grep "^${PREFIJO_LISTENER}.*$");

   for currListener in $(echo ${LISTA_LISTENERS})
   do
      echo "";
      echo "Listener: ${currListener}";
      echo "";
      VerificaParametroDeListener "${currListener}" "IS_ACTIVE"          ""
      VerificaParametroDeListener "${currListener}" "ADMIN_RESTRICTIONS" "ON"
      VerificaParametroDeListener "${currListener}" "DIAG_ADR_ENABLED"   "ON"
      VerificaParametroDeListener "${currListener}" "LOGGING"            "ON"
      VerificaParametroDeListener "${currListener}" "TRACE_LEVEL"        "OFF"
      VerificaParametroDeListener "${currListener}" "TRACE_TIMESTAMP"    "TRUE"
      VerificaParametroDeListener "${currListener}" "ADR_BASE"           "";
   done
}

#--------------------------------------------------------------------------------#

function ValorDeLimite()
{
profile_a_buscar="$(mayuscula "${1}")";
resource_a_buscar="$(mayuscula "${2}")";

   sqlplus -S /NOLOG <<_codigo_
CONNECT / AS SYSDBA

SET HEADING OFF
SET PAGES 0
SET FEEDBACK OFF

SELECT UPPER(limit) limit FROM dba_profiles
WHERE profile = '${profile_a_buscar}' and resource_name='${resource_a_buscar}'
;

EXIT;
_codigo_
}

#--------------------------------------------------------------------------------#

function VerificaLimiteDeProfile()
{
   iNombreDeProfile="$(mayuscula "${1}")";
   iNombreDeResource="$(mayuscula "${2}")";
   valorEsperado="$(mayuscula "${3}")";
   valorActual="$(ValorDeLimite "${iNombreDeProfile}" "${iNombreDeResource}")";

   [ "${valorActual}" = "${valorEsperado}" ] && etiqueta="[ OK  ]" || etiqueta="[ERROR]";

   if [ "$(EsValorNulo "${valorActual}")" = "S" ];
   then
      valorActual="PROFILE_NOT_FOUND";
   fi

   if [ "${etiqueta}" = "[ OK  ]" ];
   then
      valorActual="Si[${valorActual}]";
   else
      valorActual="No[${valorActual}]";
      CODIGO_SALIDA=1;
   fi

   printf "%s %-50s %-20s\n" "${etiqueta}" "${iNombreDeResource}=${valorEsperado}?" "${valorActual}";
}

#--------------------------------------------------------------------------------#

function ComplianceProfiles()
{
   titulo "Revision de Configuracion de Profiles";

   iEsStandby="$([ "${ROL_BD}" = "PHYSICAL STANDBY" ] && echo "S" || echo "N")";

   if [ "${iEsStandby}" = "S" ];
   then
      echo "[ OK  ] Rol de Base de Datos '${ROL_BD}'.";
   else
      case "${ESTADO_BD}" in
      "OPEN")
         echo "";
         echo "Profile: ADHOC";
         echo "";
         VerificaLimiteDeProfile "ADHOC" "PASSWORD_REUSE_MAX"       "5"
         VerificaLimiteDeProfile "ADHOC" "FAILED_LOGIN_ATTEMPTS"    "5"
         VerificaLimiteDeProfile "ADHOC" "PASSWORD_REUSE_TIME"      "30"
         VerificaLimiteDeProfile "ADHOC" "PASSWORD_LIFE_TIME"       "30"
         VerificaLimiteDeProfile "ADHOC" "PASSWORD_GRACE_TIME"      "15"
         VerificaLimiteDeProfile "ADHOC" "PASSWORD_LOCK_TIME"       "1";
         VerificaLimiteDeProfile "ADHOC" "PASSWORD_VERIFY_FUNCTION" "F_PASSCHECK";
   
         echo "";
         echo "Profile: DBA";
         echo "";
         VerificaLimiteDeProfile "DBA" "PASSWORD_REUSE_MAX"       "5"
         VerificaLimiteDeProfile "DBA" "FAILED_LOGIN_ATTEMPTS"    "5"
         VerificaLimiteDeProfile "DBA" "PASSWORD_REUSE_TIME"      "30"
         VerificaLimiteDeProfile "DBA" "PASSWORD_LIFE_TIME"       "30"
         VerificaLimiteDeProfile "DBA" "PASSWORD_GRACE_TIME"      "15"
         VerificaLimiteDeProfile "DBA" "PASSWORD_LOCK_TIME"       "UNLIMITED";
         VerificaLimiteDeProfile "DBA" "PASSWORD_VERIFY_FUNCTION" "F_PASSCHECK";
   
         echo "";
         echo "Profile: DEFAULT";
         echo "";
         VerificaLimiteDeProfile "DEFAULT" "PASSWORD_REUSE_MAX"       "5"
         VerificaLimiteDeProfile "DEFAULT" "FAILED_LOGIN_ATTEMPTS"    "5"
         VerificaLimiteDeProfile "DEFAULT" "PASSWORD_REUSE_TIME"      "5"
         VerificaLimiteDeProfile "DEFAULT" "PASSWORD_LIFE_TIME"       "UNLIMITED"
         VerificaLimiteDeProfile "DEFAULT" "PASSWORD_GRACE_TIME"      "UNLIMITED"
         VerificaLimiteDeProfile "DEFAULT" "PASSWORD_LOCK_TIME"       "UNLIMITED";
         VerificaLimiteDeProfile "DEFAULT" "PASSWORD_VERIFY_FUNCTION" "F_PASSCHECK";
   
         echo "";
         echo "Profile: PROCESS";
         echo "";
         VerificaLimiteDeProfile "PROCESS" "PASSWORD_REUSE_MAX"       "UNLIMITED"
         VerificaLimiteDeProfile "PROCESS" "FAILED_LOGIN_ATTEMPTS"    "UNLIMITED"
         VerificaLimiteDeProfile "PROCESS" "PASSWORD_REUSE_TIME"      "UNLIMITED"
         VerificaLimiteDeProfile "PROCESS" "PASSWORD_LIFE_TIME"       "UNLIMITED"
         VerificaLimiteDeProfile "PROCESS" "PASSWORD_GRACE_TIME"      "UNLIMITED"
         VerificaLimiteDeProfile "PROCESS" "PASSWORD_LOCK_TIME"       "UNLIMITED";
         VerificaLimiteDeProfile "PROCESS" "PASSWORD_VERIFY_FUNCTION" "F_PASSCHECK";
   
         echo "";
         echo "Profile: SUPPORT";
         echo "";
         VerificaLimiteDeProfile "SUPPORT" "PASSWORD_REUSE_MAX"       "5"
         VerificaLimiteDeProfile "SUPPORT" "FAILED_LOGIN_ATTEMPTS"    "5"
         VerificaLimiteDeProfile "SUPPORT" "PASSWORD_REUSE_TIME"      "30"
         VerificaLimiteDeProfile "SUPPORT" "PASSWORD_LIFE_TIME"       "30"
         VerificaLimiteDeProfile "SUPPORT" "PASSWORD_GRACE_TIME"      "15"
         VerificaLimiteDeProfile "SUPPORT" "PASSWORD_LOCK_TIME"       "UNLIMITED";
         VerificaLimiteDeProfile "SUPPORT" "PASSWORD_VERIFY_FUNCTION" "F_PASSCHECK";
   
         echo "";
         echo "Profile: USERS";
         echo "";
         VerificaLimiteDeProfile "USERS" "PASSWORD_REUSE_MAX"       "5"
         VerificaLimiteDeProfile "USERS" "FAILED_LOGIN_ATTEMPTS"    "5"
         VerificaLimiteDeProfile "USERS" "PASSWORD_REUSE_TIME"      "30"
         VerificaLimiteDeProfile "USERS" "PASSWORD_LIFE_TIME"       "30"
         VerificaLimiteDeProfile "USERS" "PASSWORD_GRACE_TIME"      "15"
         VerificaLimiteDeProfile "USERS" "PASSWORD_LOCK_TIME"       "1";
         VerificaLimiteDeProfile "USERS" "PASSWORD_VERIFY_FUNCTION" "F_PASSCHECK";
      ;;
      *)
         echo "[ERROR] Base de Datos en Modo '${ESTADO_BD}'.";
         CODIGO_SALIDA=1;
      ;;
      esac
   fi
}

#--------------------------------------------------------------------------------#

function ComplianceEncabezado()
{
   echo "";
   echo "";
   echo "********************************************************************************";
   echo "********************************************************************************";
   echo "$(date)";
   echo "";
   echo "                       Check/Compliance de Base de Datos";
   echo "";
   echo " > Servidor     : ${HOSTNAME}";
   echo " > Base de Datos: ${ORACLE_SID}";
   echo "          Estado: ${ESTADO_BD}";
   echo "             Rol: ${ROL_BD}";
   echo "";
   echo "********************************************************************************";
   echo "********************************************************************************";

}

#--------------------------------------------------------------------------------#

function main()
{
   CODIGO_SALIDA=0;
   SECCIONES=0;
   ORAENV "${@}"

   ComplianceEncabezado;
   ComplianceFileSystems;
   ComplianceParametros;
   CompliancePropiedades;
   ComplianceTablespaces;
   ComplianceProfiles;
   ComplianceListeners;

   echo "";
   [ ${CODIGO_SALIDA} -eq 0 ] && echo "Todo correcto!" || echo "Favor de atender los errores.";
   echo "Exit status ${CODIGO_SALIDA}";
   exit ${CODIGO_SALIDA};
}

#--------------------------------------------------------------------------------#

main "${@}" 2>&1 | tee /prog/log/ORA-COMPLIANCE-$(hostname -s)-${1}.log
