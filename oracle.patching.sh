#!/bin/bash

#----------------------------------------------------------------------------------------------------#

function titulo()
{
   echo "";
   echo "+";
   echo "+";
   echo "++++++++ ${1}";
   echo "+";
   echo "+";
   echo "";
}

#----------------------------------------------------------------------------------------------------#

function es_nulo()
{
   #S el parametro de entrada es nulo
   if [ -z "${1}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function existe_archivo()
{
   if [ -f "${1}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function existe_directorio()
{
   if [ -d "${1}" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function msginfo()
{
   echo -e "$(date "+%Y-%m-%d %H:%M:%S")[INFO       ] ${1}";
}

#----------------------------------------------------------------------------------------------------#

function msgok()
{
   echo -e "$(date "+%Y-%m-%d %H:%M:%S")[SUCCESS    ] ${1}";
}

#----------------------------------------------------------------------------------------------------#

function msgwarning()
{
   echo -e "$(date "+%Y-%m-%d %H:%M:%S")[WARNING    ] ${1}";
}

#----------------------------------------------------------------------------------------------------#

function msgerror()
{
   echo -e "$(date "+%Y-%m-%d %H:%M:%S")[ERROR      ] ${1}";
}

#----------------------------------------------------------------------------------------------------#

function msgfatal()
{
   echo -e "$(date "+%Y-%m-%d %H:%M:%S")[FATAL ERROR] ${1}";
   msgexit 1;
   exit 1;
}

#----------------------------------------------------------------------------------------------------#

function msgexit()
{
   echo "Exit code:${1}";
}

#----------------------------------------------------------------------------------------------------#

function define_variables_globales()
{
   export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";
   export ORACLE_SID="${1}";
   export ORACLE_MEDIA="/dbtemp01-${ORACLE_SID}/oraclemedia";
}

#----------------------------------------------------------------------------------------------------#

function hay_procesos_bg_activos()
{
   numero_de_procesos_bg_activos="$(ps -e -o cmd | grep -v "grep" | grep -c "ora_.*_${ORACLE_SID}")";

   #Si numero_de_procesos_bg_activos es mayor a cero
   if [ ${numero_de_procesos_bg_activos} -gt 0 ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function identificar_base_de_datos()
{
   titulo "Identificando Base de Datos";

   msginfo "Verificando procesos de instancia { $ORACLE_SID } activos";

   #Si hay pocesos backgroup activos
   if [ "$(hay_procesos_bg_activos)" == "S" ];
   then
      msgok "Procesos de instancia { $ORACLE_SID } encontrados:";

      ps -e -o cmd --no-heading --sort cmd | grep -v "grep" | grep "ora_.*_${ORACLE_SID}" ;

      echo "Total:$(ps -e -o cmd | grep -v "grep" | grep -c "ora_.*_${ORACLE_SID}")";
   else
      msgfatal "No se encontraron procesos de instancia { ${ORACLE_SID} } activos";
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_variables_de_ambiente_de_base_de_datos()
{
   titulo "Obtener variables de Ambiente e Instalacion de Instancia { ${ORACLE_SID} }";

   PMON="ora_pmon_${ORACLE_SID}";
   PMON_PID=$(ps -e -o pid,cmd | grep -w ${PMON} | grep -v "grep" | awk '{ print $1 }');

   #Si PMON_PID no es nulo
   if [ "$(es_nulo "${PMON_PID}")" == "N" ];
   then
      export ORACLE_BASE="$(strings /proc/${PMON_PID}/environ | grep -w "ORACLE_BASE" | grep -v "grep" | cut -d"=" -f2)";
      export ORACLE_HOME="$(strings /proc/${PMON_PID}/environ | grep -w "ORACLE_HOME" | grep -v "grep" | cut -d"=" -f2)";
      export OPATCH_HOME="${ORACLE_HOME}/OPatch";
      export PATH="${ORACLE_HOME}/bin:${OPATCH_HOME}:${PATH}";

      msgok "ORACLE_BASE=${ORACLE_BASE}";
      msgok "ORACLE_HOME=${ORACLE_HOME}";
      msgok "OPATCH_HOME=${OPATCH_HOME}";
      msgok "PATH=${PATH}";

      export ORAUSER="$(stat --printf='%U\n' ${ORACLE_HOME})";
      export ORADBA="$(stat --printf='%G\n' ${ORACLE_HOME})";

      msgok "ORAUSER=${ORAUSER}";
      msgok "ORADBA=${ORADBA}";
   else
      msgfatal "No se encontraron procesos de instancia { ${ORACLE_SID} } activos";
   fi
}

#----------------------------------------------------------------------------------------------------#

function instance_status()
{
   ISTATUS=$(sqlplus -S /nolog <<_sql_
CONNECT / AS SYSDBA
SET FEEDBACK OFF
SET PAGES 0
SET HEADING OFF

SELECT TRIM(status) col FROM v\$instance;

DISCONNECT;
EXIT;
_sql_
);

   total_ORA="$(echo "${ISTATUS}" | grep "ORA-" | grep -v "grep" | wc -l)";

   #Si total_ORA es igual a cero
   if [ ${total_ORA} -eq 0 ];
   then
      echo "${ISTATUS}";
   else
      echo "DOWN";
   fi
}

#----------------------------------------------------------------------------------------------------#

function database_database_role()
{
   DROL=$(sqlplus -S /nolog <<_sql_
CONNECT / AS SYSDBA
SET FEEDBACK OFF
SET PAGES 0
SET HEADING OFF

SELECT TRIM(database_role) col FROM v\$database;

DISCONNECT;
EXIT;
_sql_
);

   total_ORA="$(echo "${DROL}" | grep "ORA-" | grep -v "grep" | wc -l)";

   #Si total_ORA es igual a cero
   if [ ${total_ORA} -eq 0 ];
   then
      echo "${DROL}";
   else
      echo "UNKNOWN";
   fi
}

#----------------------------------------------------------------------------------------------------#

function standby_media_recovery()
{
   MRECOVERY=$(sqlplus -S /nolog <<_sql_
CONNECT / AS SYSDBA
SET FEEDBACK OFF
SET PAGES 0
SET HEADING OFF

--Puede o no traer resultado
SELECT 'ACTIVE' col FROM v\$managed_standby
WHERE process LIKE 'MRP%'
AND ROWNUM < 2;

DISCONNECT;
EXIT;
_sql_
);

   total_ORA="$(echo "${MRECOVERY}" | grep "ORA-" | grep -v "grep" | wc -l)";

   #Si total_ORA es igual a cero y MRECOVERY no es nulo
   if [ ${total_ORA} -eq 0 ] && [ "$(es_nulo "${MRECOVERY}")" == "N" ];
   then
      echo "${MRECOVERY}";
   else
      echo "INACTIVE";
   fi
}

#----------------------------------------------------------------------------------------------------#

function instance_version()
{
   IVERSION=$(sqlplus -S /nolog <<_sql_
CONNECT / AS SYSDBA
SET FEEDBACK OFF
SET PAGES 0
SET HEADING OFF

SET SERVEROUTPUT ON

DECLARE
   instance_version       v\$instance.version%TYPE;
   instance_version_tmp   v\$instance.version%TYPE;
   instance_version_final v\$instance.version%TYPE;
   numero_tokens          NUMBER := 0;
BEGIN
   SELECT version INTO instance_version FROM v\$instance;

   instance_version_tmp := instance_version;

   FOR idx IN 1..4
   LOOP
      instance_version_final:=instance_version_final||SUBSTR(instance_version_tmp,1,INSTR(instance_version_tmp,'.')-1);
      IF idx < 4
      THEN
         instance_version_final:=instance_version_final||'.';
      END IF;
      instance_version_tmp:=SUBSTR(instance_version_tmp,INSTR(instance_version_tmp,'.')+1);
   END LOOP;

   DBMS_OUTPUT.PUT_LINE(instance_version_final);
END;
/

DISCONNECT;
EXIT;
_sql_
);

   total_ORA="$(echo "${IVERSION}" | grep "ORA-" | grep -v "grep" | wc -l)";

   #Si total_ORA es igual a cero
   if [ ${total_ORA} -eq 0 ];
   then
      echo "${IVERSION}";
   else
      echo "0.0.0.0";
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_variables_para_parche_a_instalar()
{
   msginfo "Buscando directorios de parches para version { ${INSTANCE_VERSION} }";

   export PATCH_BASE_NUEVO="${ORACLE_MEDIA}/${INSTANCE_VERSION}/patches";

   lista_parches="$(ls ${PATCH_BASE_NUEVO} 2> /dev/null)";

   #Si lista_parches no es nulo
   if [ "$(es_nulo "${lista_parches}")" == "N" ];
   then
      msgok "Directorios de parches para version { ${INSTANCE_VERSION} } encontrados en directorio { ${PATCH_BASE_NUEVO}  }:";
      ls ${PATCH_BASE_NUEVO};
   fi

   msginfo "Buscando directorio de parche mas reciente";

   PATCH="$(ls -l ${ORACLE_MEDIA}/${INSTANCE_VERSION}/patches 2> /dev/null | \
                 grep "^d" | tail -1 | awk '{ print $9 }')";

   export PATCH_HOME_NUEVO="${PATCH_BASE_NUEVO}/${PATCH}";

   #Si PATCH no es nulo
   if [ "$(es_nulo "${PATCH}")" == "N" ];
   then
      msgok "Directorio { ${PATCH_HOME_NUEVO} } de parche mas reciente encontrado";
   else
      msgfatal "No se encontraron directorios de parches en { ${PATCH_HOME_NUEVO} }";
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_version_de_parche_a_instalar()
{
   titulo "Obtener nombre y version de Parche a aplicar";

   #Si PATCH_HOME_NUEVO es nulo
   if [ "$(es_nulo "${PATCH_HOME_NUEVO}")" == "S" ];
   then
      obtener_variables_para_parche_a_instalar;
   fi

   msginfo "Buscando archivos ZIP en directorio { ${PATCH_HOME_NUEVO} }";

   lista_archivos_zip="$(ls ${PATCH_HOME_NUEVO}/*.zip 2> /dev/null)";

   #Si lista_archivos_zip no es nulo
   if [ "$(es_nulo "${lista_archivos_zip}")" == "N" ];
   then
      msgok "Archivos ZIP encontrados:";
      ls ${PATCH_HOME_NUEVO}/*.zip | awk -F"/" '{ print $NF }';

      PATCH_ZIP_NUEVO="";
      PATCH_NAME_NUEVO="";
      PATCH_VERSION_NUEVO="";

      for azip in $(echo ${lista_archivos_zip})
      do
         msginfo "Analizando archivo ZIP { ${azip} }";

         PATCH_VERSION_TMP="$(unzip -p ${azip} PatchSearch.xml 2> /dev/null  | \
                              grep '<psu_bundle>[a-zA-Z0-9. ]*</psu_bundle>' | \
                              sed 's+[a-zA-Z<>_/]*++g' | awk '{ print $1 }' | xargs)";

         #Si PATCH_VERSION_TMP no es nulo
         if [ "$(es_nulo "${PATCH_VERSION_TMP}")" == "N" ];
         then
            PATCH_NAME_NUEVO="$(unzip -p ${azip} PatchSearch.xml 2> /dev/null | grep '<name>[0-9]\+</name>' | \
                          head -1 | sed 's+[a-zA-Z <>_/]*++g' | xargs)";
            PATCH_ZIP_NUEVO="${azip}";
            PATCH_VERSION_NUEVO="${PATCH_VERSION_TMP}";
         fi
      done

      #Si PATCH_ZIP no es nulo
      if [ "$(es_nulo "${PATCH_ZIP_NUEVO}")" == "N" ];
      then
         msgok "El archivo ZIP { ${PATCH_ZIP_NUEVO} } contiene el parche Oracle";
         msgok "Nombre de Parche { ${PATCH_NAME_NUEVO} } encontrado";
         msgok "Version de Parche { ${PATCH_VERSION_NUEVO} } encontrado";
      else
         msgfatal "No se encontraron archivos ZIP con parche en el directorio { ${PATCH_HOME_NUEVO} }";
      fi
   else
      msgfatal "No se encontraron archivos ZIP en el directorio { ${PATCH_HOME_NUEVO} }";
   fi

   export PATCH_ZIP_NUEVO;
   export PATCH_NAME_NUEVO;
   export PATCH_VERSION_NUEVO;
}

#----------------------------------------------------------------------------------------------------#

function es_opatch_valido()
{
   #Se validara solo la ejecucion correcta de { opatch version }
   opatch version &> opatch_version.log;

   fue_comando_anterior_correcto=${?};
   [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

   #Si fue el comando anterior correcto
   if [ "${fue_comando_anterior_correcto}" == "S" ];
   then
      echo "S";
   else
      #Correccion de Error:
         #Invalid maximum heap size: -Xmx3072mM }
         #Error: Could not create the Java Virtual Machine.
         #Error: A fatal exception has occurred. Program will exit.
         #
         #OPatch failed with error code 1
      numero_coincidencias=$(grep -Eic ".*Invalid.*maximum.*heap.*size.*-Xmx3072.*" opatch_version.log);

      #Si hubo coincidencias del error de Invalid maximum heap size
      if [ ${numero_coincidencias} -gt 0 ];
      then
         #Se modifica OPatch en esta seccion de codigo
         #if [ "$PLATFORM" = "Linux" -a "$ARCH" = "x86_64" ];then
         #   DEFAULT_HEAP="-Xmx3072m" -- Se cambia a --> DEFAULT_HEAP="-Xmx3072"
         #else
         #   DEFAULT_HEAP="-Xmx1536m"
         #fi

         sed -i 's/.*DEFAULT_HEAP.*=.*3072.*/DEFAULT_HEAP="-Xmx3072"/g' ${OPATCH_HOME}/opatch &> /dev/null;

         opatch version &> opatch_version.log;

         fue_comando_anterior_correcto=${?};
         [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

         #Si fue el comando anterior correcto
         if [ "${fue_comando_anterior_correcto}" == "S" ];
         then
            echo "S";
         else
            echo "N";
         fi
      else
         echo "N";
      fi
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_version_de_opatch_instalado()
{
   titulo "Obtener version de ultimo OPatch instalado en ORACLE_HOME { ${ORACLE_HOME} }";

   msginfo "Obteniendo version de ultimo OPatch instalado";

   OPATCH_VERSION_ULTIMO="";

   if [ "$(es_opatch_valido)" == "S" ];
   then
      OPATCH_VERSION_ULTIMO="$(opatch version | grep -i version | awk '{ print $3 }' | xargs)";

      msgok "Version de ultimo OPatch instalado { ${OPATCH_VERSION_ULTIMO} }";
   else
      msgwarning "No se pudo obtener la version de ultimo Opatch instalado";
   fi

   export OPATCH_VERSION_ULTIMO;
}

#----------------------------------------------------------------------------------------------------#

function obtener_version_de_opatch_a_instalar()
{
   titulo "Obtener version de OPatch a instalar";

   #Si PATCH_HOME es nulo
   if [ "$(es_nulo "${PATCH_HOME_NUEVO}")" == "S" ];
   then
      obtener_variables_para_parche_a_instalar;
   fi

   msginfo "Buscando archivos ZIP en directorio { ${PATCH_HOME_NUEVO} }";

   lista_archivos_zip="$(ls ${PATCH_HOME_NUEVO}/*.zip 2> /dev/null)";
   if [ "$(es_nulo "${lista_archivos_zip}")" == "N" ];
   then
      msgok "Archivos ZIP encontrados:";
      ls ${PATCH_HOME_NUEVO}/*.zip | awk -F"/" '{ print $NF }';

      OPATCH_VERSION_NUEVO="";
      OPATCH_ZIP_NUEVO="";

      for azip in $(echo ${lista_archivos_zip})
      do
         msginfo "Analizando archivo ZIP { ${azip} }";

         OPATCH_VERSION_TMP="$(unzip -p ${azip} OPatch/version.txt 2> /dev/null  | \
                              grep "OPATCH_VERSION" | cut -d":" -f2 | xargs)";

         #Si OPATCH_VERSION_TMP no es nulo
         if [ "$(es_nulo "${OPATCH_VERSION_TMP}")" == "N" ];
         then
            OPATCH_VERSION_NUEVO="${OPATCH_VERSION_TMP}";
            OPATCH_ZIP_NUEVO="${azip}";
         fi
      done

         #Si OPATCH_ZIP_NUEVO no es nulo
      if [ "$(es_nulo "${OPATCH_ZIP_NUEVO}")" == "N" ];
      then
         msgok "El archivo ZIP { ${OPATCH_ZIP_NUEVO} } contiene el OPatch a instalar";
         msgok "Version de OPatch { ${OPATCH_VERSION_NUEVO} } encontrado";
      else
         msgfatal "No se encontraron archivos ZIP con el OPatch en el directorio { ${PATCH_HOME} }";
      fi
   else
      msgfatal "No se encontraron archivos ZIP en el directorio { ${PATCH_HOME} }";
   fi

   export OPATCH_ZIP_NUEVO;
   export OPATCH_VERSION_NUEVO;
}

#----------------------------------------------------------------------------------------------------#

function obtener_informacion_de_base_de_datos()
{
   titulo "Obtener informacion de la Base de Datos { ${ORACLE_SID} }";

   export INSTANCE_VERSION="$(instance_version)";
   msgok "Version de la Instancia       { ${ORACLE_SID} } es { ${INSTANCE_VERSION} }";

   export INSTANCE_STATUS="$(instance_status)";
   msgok "Estatus de la Instancia       { ${ORACLE_SID} } es { ${INSTANCE_STATUS} }";

   export DATABASE_DATABASE_ROLE="$(database_database_role)";
   msgok "Rol de Base de Datos          { ${ORACLE_SID} } es { ${DATABASE_DATABASE_ROLE} }";

   export STANDBY_MEDIA_RECOVERY="$(standby_media_recovery)";
   msgok "Recuperacion de Base de Datos { ${ORACLE_SID} } es { ${STANDBY_MEDIA_RECOVERY} }";
}

#----------------------------------------------------------------------------------------------------#

function lista_listeners_activos()
{
   listado_listeners_activos="$(ps -C tnslsnr -o cmd --no-headers | awk '{print $2}' | tr '\n' ' ')";

   echo "${listado_listeners_activos}";
}

#----------------------------------------------------------------------------------------------------#

function hay_procesos_listener_activos()
{
   lista_listeners="$(lista_listeners_activos)";

   #Si el listado de listeners No es Nulo
   if [ "$(es_nulo "${lista_listeners}")" == "N" ];
   then
      echo "S";
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_listeners_activos()
{
   titulo "Obtener Listeners activos en ORACLE_HOME { ${ORACLE_HOME} }";

   LISTENERS_DE_ORACLE_HOME="$(lista_listeners_activos)";

   msginfo "Identificando listeners activos con ORACLE_HOME { ${ORACLE_HOME} }";

   #Si LISTENERS_DE_ORACLE_HOME no es nulo
   if [ "$(es_nulo "${LISTENERS_DE_ORACLE_HOME}")" == "N" ];
   then
      msgok "Listeners activos en ORACLE_HOME { ${ORACLE_HOME} } encontrados:";
       echo "${LISTENERS_DE_ORACLE_HOME}" | tr ' ' '\n';
   else
      msginfo "No se encontraron listeners activos en ORACLE_HOME { ${ORACLE_HOME} }";
   fi

   export LISTENERS_DE_ORACLE_HOME;
}

#----------------------------------------------------------------------------------------------------#

function reconstruir_inventory_pointer_location()
{
   msginfo "Reconstruyendo archivo apuntador de la ruta del Inventario Central { ${INVENTORY_POINTER_LOCATION} }";

   cat - > ${INVENTORY_POINTER_LOCATION} <<_contenido_
inventory_loc=${ORACLE_CENTRAL_INVENTORY_LOCATION}
inst_group=${ORADBA}
_contenido_

   fue_comando_anterior_correcto=${?};
   [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

   #Si fue el comando anterior correcto
   if [ "${fue_comando_anterior_correcto}" == "S" ];
   then
      msgok "Reconstruccion de archivo apuntador de la ruta del Inventario Central { ${INVENTORY_POINTER_LOCATION} } correcto";
   else
      msgfatal "No fue posible reconstruir el archivo apuntador de la ruta del Inventario Central { ${INVENTORY_POINTER_LOCATION} }\nIntervencion manual requerida";
   fi
}

#----------------------------------------------------------------------------------------------------#

function reconstruir_oracle_central_inventory()
{
   msginfo "Reconstruyendo Inventario Central de Oracle { ${ORACLE_CENTRAL_INVENTORY_LOCATION} }";

   if [ "$(existe_directorio "${ORACLE_CENTRAL_INVENTORY_LOCATION}")" == "S" ];
   then
      msginfo "Eliminando directorio { ${ORACLE_CENTRAL_INVENTORY_LOCATION} }";
      rm -rf ${ORACLE_CENTRAL_INVENTORY_LOCATION};

      fue_comando_anterior_correcto=${?};
      [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

      #Si fue el comando anterior correcto
      if [ "${fue_comando_anterior_correcto}" == "S" ];
      then
         msgok "Borrado de directorio { ${ORACLE_CENTRAL_INVENTORY_LOCATION} } correcto";
      else
         msgfatal "No fue posible borrar el directorio { ${ORACLE_CENTRAL_INVENTORY_LOCATION} }\nIntervencion manual requerida";
      fi
   fi

   msginfo "Ejecutando comando { ${ORACLE_HOME}/oui/bin/runInstaller -silent -ignoreSysPrereqs -invPtrLoc "${INVENTORY_POINTER_LOCATION}" -attachHome ORACLE_HOME="${ORACLE_HOME}" ORACLE_HOME_NAME="ORAHOME_${ORACLE_SID}" }";

   ${ORACLE_HOME}/oui/bin/runInstaller -silent -ignoreSysPrereqs -invPtrLoc "${INVENTORY_POINTER_LOCATION}" -attachHome ORACLE_HOME="${ORACLE_HOME}" ORACLE_HOME_NAME="ORAHOME_${ORACLE_SID}"

   msgok "Reconstruccion de Inventario Central de Oracle terminado";
}

#----------------------------------------------------------------------------------------------------#

function obtener_oracle_central_inventory()
{
   titulo "Obtener Inventario Central de Oracle para Base de Datos { ${ORACLE_SID} }";

   if [ "$(es_opatch_valido)" == "S" ];
   then
      export INVENTORY_POINTER_LOCATION="${ORACLE_HOME}/oraInst.loc";
      export ORACLE_CENTRAL_INVENTORY_LOCATION="${ORACLE_HOME}/oraInventory";

      RECONSTRUIR_INVENTORY_POINTER_LOCATION="N";
      msginfo "Buscando archivo apuntador de la ruta del Inventario Central { ${INVENTORY_POINTER_LOCATION} }";

      #Si existe_archivo INVENTORY_POINTER_LOCATION
      if [ "$(existe_archivo "${INVENTORY_POINTER_LOCATION}")" == "S" ];
      then
         msgok "Archivo apuntador de la ruta del Inventario Central { ${INVENTORY_POINTER_LOCATION} } encontrado";
      else
         msgwarning "No se encontro el archivo apuntador de la ruta de Inventario Central { ${INVENTORY_POINTER_LOCATION} }";
         RECONSTRUIR_INVENTORY_POINTER_LOCATION="S";
      fi

      ORACLE_CENTRAL_INVENTORY_LOCATION_ACTUAL="$(grep "inventory_loc" ${INVENTORY_POINTER_LOCATION} 2> /dev/null | \
                                                  cut -d"=" -f2 | xargs)";

      msginfo "Verificando que el Directorio { ${ORACLE_CENTRAL_INVENTORY_LOCATION} } este configurado en archivo { ${INVENTORY_POINTER_LOCATION} }";

      #Si ORACLE_CENTRAL_INVENTORY_LOCATION es igual a ORACLE_CENTRAL_INVENTORY_LOCATION_ACTUAL
      if [ "${ORACLE_CENTRAL_INVENTORY_LOCATION}" == "${ORACLE_CENTRAL_INVENTORY_LOCATION_ACTUAL}" ];
      then
         msgok "El Directorio { ${ORACLE_CENTRAL_INVENTORY_LOCATION} } esta configurado en archivo { ${INVENTORY_POINTER_LOCATION} }";
      else
         msgwarning "El Directorio { ${ORACLE_CENTRAL_INVENTORY_LOCATION} } no esta configurado en archivo { ${INVENTORY_POINTER_LOCATION} }";
         cat ${INVENTORY_POINTER_LOCATION};
         RECONSTRUIR_INVENTORY_POINTER_LOCATION="S";
      fi

      #Si RECONSTRUIR_INVENTORY_POINTER_LOCATION igual a S
      if [ "${RECONSTRUIR_INVENTORY_POINTER_LOCATION}" == "S" ];
      then
         msginfo "El archivo apuntador de la ruta de Inventario Central sera reconstruido";

         reconstruir_inventory_pointer_location;
      fi

      msginfo "Verificando la existencia del Directorio de Inventario Central { ${ORACLE_CENTRAL_INVENTORY_LOCATION} }";

      #Si existe el directorio ORACLE_CENTRAL_INVENTORY_LOCATION
      if [ "$(existe_directorio "${ORACLE_CENTRAL_INVENTORY_LOCATION}")" == "S" ];
      then
         msgok "Directorio de Inventario Central { ${ORACLE_CENTRAL_INVENTORY_LOCATION} } existente";
      else
         msgwarning "No fue posible verificar la existencia del  Directorio de Inventario Central { ${ORACLE_CENTRAL_INVENTORY_LOCATION} }";
         RECONSTRUIR_ORACLE_CENTRAL_INVENTORY="S";
      fi

      if [ "${RECONSTRUIR_ORACLE_CENTRAL_INVENTORY}" == "S" ];
      then
         msginfo "El Inventario Central de Oracle sera reconstruido";
         reconstruir_oracle_central_inventory;
      fi

      msginfo "Verificando ejecucion correcta de comando { opatch lsinventory }";

      opatch lsinventory &> opatch_lsinventory.log;

      fue_comando_anterior_correcto=${?};
      [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

      #Si fue el comando anterior correcto
      if [ "${fue_comando_anterior_correcto}" == "S" ];
      then
         msgok "Comando { opatch lsinventory } ejecutado correctamente\nVer log { opatch_lsinventory.log }";
      else
         msgwarning "Comando { opatch lsinventory } ejecutado con errores.";

         msginfo "El Inventario Central de Oracle sera reconstruido";
         reconstruir_oracle_central_inventory;

         msginfo "Verificando ejecucion correcta de comando { opatch lsinventory }";

         opatch lsinventory &> opatch_lsinventory.log;

         fue_comando_anterior_correcto=${?};
         [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

         #Si fue el comando anterior correcto
         if [ "${fue_comando_anterior_correcto}" == "S" ];
         then
            msgok "Comando { opatch lsinventory } ejecutado correctamente\nVer log { opatch_lsinventory.log }";
         else
            msgerror "Comando { opatch lsinventory } ejecutado con errores";
            msgfatal "Inventario Central de Oracle con errores\nIntervencion manual requerida\nVer log { opatch_lsinventory.log }";
         fi
      fi
   else
      msgfatal "No se pudo obtener una ejecucion correcta del OPatch instalado\nIntervencion manual requerida\Ver log { opatch_version.log }";
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_ultimo_parche_aplicado_en_oracle_home()
{
   titulo "Obtener ultimo Parche aplicado en ORACLE_HOME { ${ORACLE_HOME} }";

   resultado_lista_parches="$(opatch lspatches 2> /dev/null | head -1)";

   no_hay_parches="$(echo "${resultado_lista_parches}" | grep -i "no interim patches installed")";

   if [ "$(es_nulo "${no_hay_parches}")" == "N" ];
   then
      export PATCH_VERSION_ULTIMO="${INSTANCE_VERSION}.0";
      export PATCH_NAME_ULTIMO="${no_hay_parches}";
   else
      export PATCH_NAME_ULTIMO="$(echo "${resultado_lista_parches}" | awk -F";" '{ print $1 }')";
      export PATCH_VERSION_ULTIMO="$(echo "${resultado_lista_parches}" | sed 's+ +;+g' | awk -F";" '{ print $8 }')";
   fi

   msgok "Nombre { ${PATCH_NAME_ULTIMO} } de Ultimo Parche aplicado en ORACLE_HOME { ${ORACLE_HOME} }";
   msgok "Version { ${PATCH_VERSION_ULTIMO} } de Ultimo Parche aplicado en ORACLE_HOME { ${ORACLE_HOME} }";
   #msgok "Fecha { ${patch_date} } de aplicacion de Ultimo Parche en ORACLE_HOME { ${ORACLE_HOME} }";
}

#----------------------------------------------------------------------------------------------------#

function es_parche_a_instalar_mayor_a_instalado()
{
         major_database_release_number_ultimo=$(echo "${PATCH_VERSION_ULTIMO}" | cut -d"." -f1);
   database_maintenance_release_number_ultimo=$(echo "${PATCH_VERSION_ULTIMO}" | cut -d"." -f2);
     application_server_release_number_ultimo=$(echo "${PATCH_VERSION_ULTIMO}" | cut -d"." -f3);
     component_specific_release_number_ultimo=$(echo "${PATCH_VERSION_ULTIMO}" | cut -d"." -f4);
      platform_specific_release_number_ultimo=$(echo "${PATCH_VERSION_ULTIMO}" | cut -d"." -f5);

         major_database_release_number_nuevo=$(echo "${PATCH_VERSION_NUEVO}" | cut -d"." -f1);
   database_maintenance_release_number_nuevo=$(echo "${PATCH_VERSION_NUEVO}" | cut -d"." -f2);
     application_server_release_number_nuevo=$(echo "${PATCH_VERSION_NUEVO}" | cut -d"." -f3);
     component_specific_release_number_nuevo=$(echo "${PATCH_VERSION_NUEVO}" | cut -d"." -f4);
      platform_specific_release_number_nuevo=$(echo "${PATCH_VERSION_NUEVO}" | cut -d"." -f5);
   #Si los primeros 4 componentes son iguales entre version de parche nuevo y el ultimo aplicado
   if [       ${major_database_release_number_ultimo} -eq ${major_database_release_number_nuevo}       ] && \
      [ ${database_maintenance_release_number_ultimo} -eq ${database_maintenance_release_number_nuevo} ] && \
      [   ${application_server_release_number_ultimo} -eq ${application_server_release_number_nuevo}   ] && \
      [   ${component_specific_release_number_ultimo} -eq ${component_specific_release_number_nuevo}   ];
   then
      #Si el 5to componente de la version del ultimo parche aplicado es menor al nuevo
      if [ ${platform_specific_release_number_ultimo} -lt ${platform_specific_release_number_nuevo} ];
      then
         echo "S";
      else
         echo "N";
      fi
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function es_opatch_a_instalar_mayor_a_instalado()
{
         major_database_release_number_ultimo=$(echo "${OPATCH_VERSION_ULTIMO}" | cut -d"." -f1);
   database_maintenance_release_number_ultimo=$(echo "${OPATCH_VERSION_ULTIMO}" | cut -d"." -f2);
     application_server_release_number_ultimo=$(echo "${OPATCH_VERSION_ULTIMO}" | cut -d"." -f3);
     component_specific_release_number_ultimo=$(echo "${OPATCH_VERSION_ULTIMO}" | cut -d"." -f4);
      platform_specific_release_number_ultimo=$(echo "${OPATCH_VERSION_ULTIMO}" | cut -d"." -f5);

         major_database_release_number_nuevo=$(echo "${OPATCH_VERSION_NUEVO}" | cut -d"." -f1);
   database_maintenance_release_number_nuevo=$(echo "${OPATCH_VERSION_NUEVO}" | cut -d"." -f2);
     application_server_release_number_nuevo=$(echo "${OPATCH_VERSION_NUEVO}" | cut -d"." -f3);
     component_specific_release_number_nuevo=$(echo "${OPATCH_VERSION_NUEVO}" | cut -d"." -f4);
      platform_specific_release_number_nuevo=$(echo "${OPATCH_VERSION_NUEVO}" | cut -d"." -f5);
   #Si los primeros 4 componentes son iguales entre version de parche nuevo y el ultimo aplicado
   if [ ${major_database_release_number_ultimo} -eq ${major_database_release_number_nuevo} ];
   then
      if [ ${database_maintenance_release_number_ultimo} -lt ${database_maintenance_release_number_nuevo} ];
      then
         echo "S";
      else
         if [ ${application_server_release_number_ultimo} -lt ${application_server_release_number_nuevo} ];
         then
            echo "S";
         else
            if [ ${component_specific_release_number_ultimo} -lt ${component_specific_release_number_nuevo} ];
            then
               echo "S";
            else
               if [ ${platform_specific_release_number_ultimo} -lt ${platform_specific_release_number_nuevo} ];
               then
                  echo "S";
               else
                  echo "N";
               fi
            fi
         fi
      fi
   else
      echo "N";
   fi
}

#----------------------------------------------------------------------------------------------------#

function obtener_filesystem_con_10gb_de_espacio_libre()
{
   titulo "Obtener File System candidato para almacenar Respaldos de ORACLE_HOME y OPatch";

   msginfo "Obteniendo File System con espacio libre >= 10 GB";

   filesystem_espacio_nombre="$(df --output=target,avail | grep ".*${ORACLE_SID}" | grep -v "oracle" | sort -nk 2 | tail -1)";

   filesystem_espacio=$(echo "${filesystem_espacio_nombre}" | awk '{ print $2 }');
   filesystem_espacio=$(( ${filesystem_espacio} / 1024 / 1024 ));

   export FILESYSTEM_RESPALDO="$(echo "${filesystem_espacio_nombre}" | awk '{ print $1 }')";

   if [ "$(es_nulo "${FILESYSTEM_RESPALDO}")" == "N" ];
   then
      if [ ${filesystem_espacio} -ge 10 ];
      then
         msgok "Se elige el File System { ${FILESYSTEM_RESPALDO} } con espacio libre { ${filesystem_espacio}GB } para respaldo de ORACLE_HOME y OPatch";
         df -Ph ${FILESYSTEM_RESPALDO};
      else
         msgfatal "El File System { ${FILESYSTEM_RESPALDO} } con mayor espacio libre { ${filesystem_espacio} }, no cuenta con los 10 GB requeridos";
      fi
   else
      msgfatal "No se pudo identificar un File System para respaldar el ORACLE_HOME y OPatch";
   fi
}

#----------------------------------------------------------------------------------------------------#

function instalar_nuevo_opatch()
{
   #Si no se ha elegido file system para respaldo
   if [ "$(es_nulo "${FILESYSTEM_RESPALDO}")" == "S" ];
   then
      obtener_filesystem_con_10gb_de_espacio_libre;
   fi

   fecha="$(date "+%Y%m%dT%H%M%S")";

   msginfo "Respaldando OPatch instalado { ${OPATCH_HOME} }";

   if [ "$(existe_directorio "${OPATCH_HOME}")" == "S" ];
   then
      if [ "$(es_nulo "${OPATCH_VERSION_ULTIMO}")" == "S" ];
      then
         nombre_repaldo="OPatch-0-${fecha}";
      else
         nombre_repaldo="OPatch-${OPATCH_VERSION_ULTIMO}-${fecha}";
      fi

      mv ${OPATCH_HOME} ${FILESYSTEM_RESPALDO}/${nombre_repaldo} 2> /dev/null;

      fue_comando_anterior_correcto=${?};
      [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

      #Si fue el comando anterior correcto
      if [ "${fue_comando_anterior_correcto}" == "S" ];
      then
         msgok "Respaldo de OPatch instalado { ${OPATCH_HOME} } correcto";
         ls -ld ${FILESYSTEM_RESPALDO}/${nombre_repaldo} | awk '{ print $9 }';
      else
         msgwarning "No fue posible respaldar el OPatch instalado { ${OPATCH_HOME} }";
      fi
   else
      msgok "No se encontro OPatch { ${OPATCH_HOME} instalado";
   fi

   msginfo "Instalando nueva version de OPatch { ${OPATCH_VERSION_NUEVO} }";

   msginfo "Ejecutando comando { unzip -o ${OPATCH_ZIP_NUEVO} -d ${ORACLE_HOME} }";

   unzip -o ${OPATCH_ZIP_NUEVO} -d ${ORACLE_HOME} &> unzip_opatch.log;

   fue_comando_anterior_correcto=${?};
   [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

   #Si fue el comando anterior correcto
   if [ "${fue_comando_anterior_correcto}" == "S" ];
   then
      msgok "Instalacion de OPatch { ${OPATCH_HOME} } correcto. Ver log { unzip_opatch.log }";
      opatch version | grep -i "version";
   else
      msgfatal "No fue posible instalar OPatch { ${OPATCH_VERSION_NUEVO} }\nIntervencion manual requerida\nVer log { unzip_opatch.log }";
   fi
}

#----------------------------------------------------------------------------------------------------#

function respaldar_oracle_home()
{
   #Si no se ha elegido file system para respaldo
   if [ "$(es_nulo "${FILESYSTEM_RESPALDO}")" == "S" ];
   then
      obtener_filesystem_con_10gb_de_espacio_libre;
   fi

   fecha="$(date "+%Y%m%dT%H%M%S")";
   nombre_oracle_home_zip="ORACLE_HOME-${ORACLE_SID}-${fecha}.zip";

   msginfo "Respaldando ORACLE_HOME { ${ORACLE_HOME} } en File System { ${FILESYSTEM_RESPALDO} }";
   msginfo "Ejecutando comando { zip -r ${FILESYSTEM_RESPALDO}/${nombre_oracle_home_zip} ${ORACLE_HOME}  }";
   msginfo "Ver progreso en archivo { respaldo_oracle_home.log }";

   zip -r ${FILESYSTEM_RESPALDO}/${nombre_oracle_home_zip} ${ORACLE_HOME} &> respaldo_oracle_home.log;

   echo $?;
}

#----------------------------------------------------------------------------------------------------#

function instalar_nuevo_parche_en_oracle_home()
{
   msginfo "Instalando parche";
   #Descomprime parche
   #Bajar listeners
   #Bajar Base de Datos
   #Aplicar Parche
   #Subir base de datos
   #Subir Listeners
}

#----------------------------------------------------------------------------------------------------#

function instalar_parche_a_oracle_home()
{
   titulo "Instalar Parche { ${PATCH_NAME_NUEVO} (${PATCH_VERSION_NUEVO}) } en ORACLE_HOME { ${ORACLE_HOME} }";

   msginfo "Identificar si el Parche { ${PATCH_NAME_NUEVO} (${PATCH_VERSION_NUEVO}) } debe ser instalado";

   #if [ "$(es_parche_a_instalar_mayor_a_instalado)" == "S" ];
   if true;
   then
      msgok "Se aplicara Parche { ${PATCH_NAME_NUEVO} (${PATCH_VERSION_NUEVO}) }";

      msginfo "Identificar si el OPatch { ${OPATCH_VERSION_NUEVO} } debe ser instalado";

      #if [ "$(es_opatch_a_instalar_mayor_a_instalado)" == "S" ];
      if true;
      then
         instalar_nuevo_opatch;
      else
         msgok "Se usara OPatch { ${OPATCH_VERSION_ULTIMO} } instalado";
      fi

      instalar_nuevo_parche_en_oracle_home;
      echo "";
      echo "Proceder a instalar parche";
   else
      msgerror "El Ultimo Parche instalado { ${PATCH_NAME_ULTIMO} (${PATCH_VERSION_ULTIMO}) } es mayor o igual al Parche { ${PATCH_NAME_NUEVO} (${PATCH_VERSION_NUEVO}) } que se desea instalar";
   fi
}

#----------------------------------------------------------------------------------------------------#

function detener_servicios_listener()
{
   titulo "Deteniendo Servicios de Listener en ORACLE_HOME { ${ORACLE_HOME} }";

   if [ "$(es_nulo "${LISTENERS_DE_ORACLE_HOME}")" == "N" ];
   then
      msginfo "Listado de Listeners activos en ORACLE_HOME { ${ORACLE_HOME} }:";
      echo "${LISTENERS_DE_ORACLE_HOME}" | tr ' ' '\n';

      listeners_ok="";
      listeners_error="";
      for flistener in $(echo "${LISTENERS_DE_ORACLE_HOME}")
      do
         msginfo "Deteniendo Listener { ${flistener} }";

         lsnrctl stop ${flistener} &> /dev/null;

         fue_comando_anterior_correcto=${?};
         [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

         #Si fue el comando anterior correcto
         if [ "${fue_comando_anterior_correcto}" == "S" ];
         then
            msgok "Listener { ${flistener} } detenido correctamente";
            listeners_ok="${listeners_ok} ${flistener}";
         else
            msgerror "No fue posible detener el Listener { ${flistener} }";
            listeners_error="${listeners_error} ${flistener}";
         fi
      done

      #Si Listeners con error es nulo
      if [ "$(es_nulo "${listeners_error}")" == "S" ];
      then
         msgok "Los Listeners { ${listeners_ok} } se han detenido correctamente";
      else
         msgfatal "No fue posible detener los Listeners { ${listeners_error} }";
      fi
   else
      msginfo "No hay Servicios de Listeners activos en ORACLE_HOME { ${ORACLE_HOME} }";
   fi
}

#----------------------------------------------------------------------------------------------------#

function activar_servicios_listener()
{
   titulo "Activando Servicios de Listener en ORACLE_HOME { ${ORACLE_HOME} }";

   if [ "$(es_nulo "${LISTENERS_DE_ORACLE_HOME}")" == "N" ];
   then
      msginfo "Listado de Listeners a activar en ORACLE_HOME { ${ORACLE_HOME} }:";
      echo "${LISTENERS_DE_ORACLE_HOME}" | tr ' ' '\n';

      listeners_ok="";
      listeners_error="";
      for flistener in $(echo "${LISTENERS_DE_ORACLE_HOME}")
      do
         msginfo "Activando Listener { ${flistener} }";

         lsnrctl start ${flistener} &> /dev/null;

         fue_comando_anterior_correcto=${?};
         [[ ${fue_comando_anterior_correcto} -eq 0 ]] && fue_comando_anterior_correcto="S" || fue_comando_anterior_correcto="N";

         #Si fue el comando anterior correcto
         if [ "${fue_comando_anterior_correcto}" == "S" ];
         then
            msgok "Listener { ${flistener} } activado correctamente";
            listeners_ok="${listeners_ok} ${flistener}";
         else
            msgerror "No fue posible activar el Listener { ${flistener} }";
            listeners_error="${listeners_error} ${flistener}";
         fi
      done

      #Si Listeners con error es nulo
      if [ "$(es_nulo "${listeners_error}")" == "S" ];
      then
         msgok "Los Listeners { ${listeners_ok} } se han activado correctamente";
      else
         msgfatal "No fue posible activar los Listeners { ${listeners_error} }";
      fi
   else
      msginfo "No hay Servicios de Listeners en ORACLE_HOME { ${ORACLE_HOME} } que activar";
   fi
}

#----------------------------------------------------------------------------------------------------#

function main()
{
   define_variables_globales "${@}";
   identificar_base_de_datos;
   obtener_variables_de_ambiente_de_base_de_datos;
   obtener_informacion_de_base_de_datos;
   obtener_listeners_activos;
   obtener_oracle_central_inventory;
   obtener_ultimo_parche_aplicado_en_oracle_home;
   #transferir_parche_desde_repositorio;
   #Para obtener el parche mas reciente, se me ocurre que en el repositorio
   #haya un link simbolico hacia el parche mas reciente
   #Cada que se agregue un parche nuevo, se ira actualizando el link simbolico
   obtener_version_de_parche_a_instalar;
   obtener_version_de_opatch_instalado;
   obtener_version_de_opatch_a_instalar;
   obtener_filesystem_con_10gb_de_espacio_libre;
   instalar_parche_a_oracle_home;
   #ok:respaldar_oracle_home;
   detener_servicios_listener;
   activar_servicios_listener
   #detener_servicio_base_de_datos;
   #instalar_parche_a_base_de_datos;
   #workarround para tabla externa antes de parchar base de datos
}

#----------------------------------------------------------------------------------------------------#

main "${@}";
