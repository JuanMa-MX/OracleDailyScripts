#!/bin/bash
#
#Modo de Ejecucion:
# sh ORACLE-checkOS-show.sh <database> <environment>
#
# <environment> puede ser cualquiera de estos valores [dev|cert|pre|pro]
#
# Ejemplo: sh ORACLE-checkOS-show.sh mibase dev
#--------------------------------------------------------------------------------#

function CheckOSEncabezado()
{
   echo "";
   echo "";
   echo "********************************************************************************";
   echo "********************************************************************************";
   echo "$(date)";
   echo "";
   echo "                        Check OS de Base de Datos Oracle";
   echo "";
   echo " > Servidor     : ${1}";
   echo " > Base de Datos: ${2}";
   echo "";
   echo "Autor: Juan Manuel Cruz Lopez (johnxjean)";
   echo "********************************************************************************";
   echo "********************************************************************************";

}

#--------------------------------------------------------------------------------#

function retornaMemoriaRamTotalDelServidorEnKB()
{
   memoriaKB="$(awk '/MemTotal/ {print $2}' /proc/meminfo)";
   memoriaKB=$(( ${memoriaKB} + (1024 * 1024) ));
   memoriaGB=$(( ${memoriaKB} / (1024 * 1024) ));
   memoriaKB=$(( ${memoriaGB} * (1024 * 1024) ));

   echo "$(( ${memoriaKB} ))";
}


#--------------------------------------------------------------------------------#

function retornaMemoriaSwapTotalDelServidorEnKB()
{
   memoriaKB="$(awk '/SwapTotal/ {print $2}' /proc/meminfo)";
   memoriaKB=$(( ${memoriaKB} + (1024 * 1024) ));
   memoriaGB=$(( ${memoriaKB} / (1024 * 1024) ));
   memoriaKB=$(( ${memoriaGB} * (1024 * 1024) ));

   echo "$(( ${memoriaKB} ))";
}

#--------------------------------------------------------------------------------#

function retornaSistemaOperativoPageSizeEnKB()
{
   echo $(( $(getconf PAGE_SIZE) / 1024 ));
}

#--------------------------------------------------------------------------------#

function retornaSistemaOperativoHugePageSizeEnKB()
{
   echo "$(awk '/Hugepagesize/ {print $2}' /proc/meminfo)";
}

#--------------------------------------------------------------------------------#

function retornaCalculaMemoriaAConfigurarParaOracleEnKB()
{
#Se debe configurar el 62.5% de la memoria RAM actual
#El 62.5% de 8 GB es 5 GB, teniendo la regla de 5 GB por cada 8 GB de RAM
   lRamDelServidorEnKB=$(retornaMemoriaRamTotalDelServidorEnKB);
   lMemoriaAConfigurarParaOracleEnKB=$(( (625 * ${lRamDelServidorEnKB} / 1000) / (1024 * 1024) * (1024 * 1024) ));
#                                        -------------------------------------   --------------   -------------
#                                                           |                           |               |__Transforma lo GB a KB
#                                                           |                           |__Transforma a GB
#                                                           |__Calcula el 62.5 de RAM

echo "${lMemoriaAConfigurarParaOracleEnKB}";
}

#--------------------------------------------------------------------------------#

function retornaValorDeParametroDeKernel()
{
   iNombreDeParametroDeKernel="${1}";
   lValorDeParametroDeKernel="$(grep -Ev "#" ${SYSCTL_CONF} 2> /dev/null | awk -F"=" '/'${iNombreDeParametroDeKernel}'/ {print $2}' | tail -1 | xargs)";

   if [ -z "${lValorDeParametroDeKernel}" ];
   then
      case "${iNombreDeParametroDeKernel}" in
         "kernel.sem")
            lValorDeParametroDeKernel="0 0 0 0";
         ;;
         "net.ipv4.ip_local_port_range")
            lValorDeParametroDeKernel="0 0";
         ;;
         *)
            lValorDeParametroDeKernel="0";
         ;;
      esac
   fi

echo "${lValorDeParametroDeKernel}";
}

#--------------------------------------------------------------------------------#

function retornaValorDeLimiteDeUsuario()
{
   iTipoDeLimite="${1}";
   iNombreDelLimite="${2}";
   lValorDelLimite="$(grep -Ev "#" ${LIMITS_CONF} 2> /dev/null | grep -E ".*${ORAUSER}.*${iTipoDeLimite}.*${iNombreDelLimite}.*" | tail -1 | awk '{print $NF}' | xargs)";

   [ -z "${lValorDelLimite}" ] && echo "0" || echo "${lValorDelLimite}";
}

#--------------------------------------------------------------------------------#

function SISTEMA_tiposervidor()
{
   #valor=$(ps -ef | grep vmtool | grep -v grep | wc -l);
   valor=$(lscpu | grep -Eci "hypervisor.*vendor");

   tipoServidor="$( [ ${valor} -gt 0 ] && echo "Virtual" || echo "Fisico" )";

   etiqueta="[INFO ]";

   printf "%s %-34s %-20s\n" "${etiqueta}" "Sistema.Tipo Servidor" "${tipoServidor}";
}

#--------------------------------------------------------------------------------#

function SISTEMA_arquitectura()
{
   arquitecturaEsperado="x86_64";
   arquitecturaActual="$(uname -i)";

   etiqueta="$( [ "${arquitecturaActual}" = "${arquitecturaEsperado}" ] && echo "[ OK  ]" || echo "[ERROR]" )";

   printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Sistema.Arquitectura" "${arquitecturaEsperado}" "${arquitecturaActual}";
}

#--------------------------------------------------------------------------------#

function SISTEMA_kernelversion()
{
   KernerVersionEsperado=0;
   MajorRevisionEsperado=0;
   MinorRevisionEsperado=0;
             FixEsperado=0;

   versionActual=$(uname -r | sed 's/-/./g');
   KernerVersion=$(echo "${versionActual}" | cut -d"." -f1);
   MajorRevision=$(echo "${versionActual}" | cut -d"." -f2);
   MinorRevision=$(echo "${versionActual}" | cut -d"." -f3);
             Fix=$(echo "${versionActual}" | cut -d"." -f4);


   #Si es Red Hat 6 2.6.32-71
   if [ ${REL_RELEASE} -eq 6 ];
   then
      KernerVersionEsperado=2;
      MajorRevisionEsperado=6;
      MinorRevisionEsperado=32;
                FixEsperado=71;
   fi

   #Si es Red Hat 7 3.10.0-123
   if [ ${REL_RELEASE} -eq 7 ];
   then
      KernerVersionEsperado=3;
      MajorRevisionEsperado=10;
      MinorRevisionEsperado=0;
      FixEsperado=123;
   fi

   errorKernel="S";

   if [ ${KernerVersion} -eq ${KernerVersionEsperado} ] && \
      [ ${MajorRevision} -eq ${MajorRevisionEsperado} ] && \
      [ ${MinorRevision} -eq ${MinorRevisionEsperado} ];
   then
      if [ ${Fix} -ge ${FixEsperado} ]; then errorKernel="N"; fi
   fi

   etiqueta="$( [ "${errorKernel}" = "N" ] && echo "[ OK  ]" || echo "[ERROR]" )";

   versionEsperado="${KernerVersionEsperado}.${MajorRevisionEsperado}.${MinorRevisionEsperado}-${FixEsperado}";
   versionActual="${KernerVersion}.${MajorRevision}.${MinorRevision}-${Fix}";

   printf "%s %-34s Minimo esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Sistema.kernel-version" "${versionEsperado}" "${versionActual}";
}

#--------------------------------------------------------------------------------#

function RevisaTipoServidor()
{
   echo "";
   echo "Revision Tipo de Servidor";
   echo "-------------------------";

   SISTEMA_tiposervidor;
}

#--------------------------------------------------------------------------------#

function RevisaTipoArquitectura()
{
   echo "";
   echo "Revision Tipo de Arquitectura";
   echo "-----------------------------";

   SISTEMA_arquitectura;
}

#--------------------------------------------------------------------------------#

function RevisaVersionKernel()
{
   echo "";
   echo "Revision de Version de Kernel";
   echo "-----------------------------";
   SISTEMA_kernelversion;
}

#--------------------------------------------------------------------------------#

function SISTEMA_memoriaRAM()
{
   #Memoria minima del servidor es 7 GB
   memoriaMinimaEsperadaEnKB=$(( 7 * 1024 * 1024 ));
   memoriaEnKB=$(retornaMemoriaRamTotalDelServidorEnKB);

   etiqueta="$( [ ${memoriaMinimaEsperadaEnKB} -lt ${memoriaEnKB} ] &&  echo "[ OK  ]" || echo "[ERROR]" )";

   printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Memoria minima Servidor en KB" "${memoriaMinimaEsperadaEnKB}" "${memoriaEnKB}";
}

function RevisaMinimoMemoriaRAM()
{
   echo "";
   echo "Revision de Memoria minima del Servidor";
   echo "---------------------------------------";

   SISTEMA_memoriaRAM;
}

#--------------------------------------------------------------------------------#

function SISTEMA_memoriaSWAP()
{
   memoriaRAMEnKB=$(retornaMemoriaRamTotalDelServidorEnKB);
   swapEnKB=$(retornaMemoriaSwapTotalDelServidorEnKB);

   memoriaSwapMinimaEsperadaEnKB=0;

   ##Tomando en cuenta que no se entregan servidores con RAM menor a 2 GB
   ##16777216 KB = 16GB
   l16GbEnKB=$(( 16 * 1024 * 1024 ));
    l8GbEnKB=$((  8 * 1024 * 1024 ));

   #Si la Memoria RAM es menor a 16 GB, entonces, pedir 8 GB de Swap
   memoriaSwapMinimaEsperadaEnKB=$( [ ${memoriaRAMEnKB} -lt ${l16GbEnKB} ] && echo ${l8GbEnKB} || echo ${l16GbEnKB} );

   etiqueta="$( [ ${memoriaSwapMinimaEsperadaEnKB} -le ${swapEnKB} ] && echo "[ OK  ]" || echo "[ERROR]" )";

   printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "SWAP minima de Servidor en KB" "${memoriaSwapMinimaEsperadaEnKB}" "${swapEnKB}";
}

#--------------------------------------------------------------------------------#

function RevisaMinimoMemoriaSWAP()
{
   echo "";
   echo "Revision de Memoria SWAP minima del Servidor";
   echo "--------------------------------------------";

   SISTEMA_memoriaSWAP;
}

#--------------------------------------------------------------------------------#

function GCC_version()
{
   gcc --version &> /dev/null;
   resultado=$?;

   VERSION=$( [ ${resultado} -eq 0 ] && echo "$(gcc --version 2> /dev/null | grep "^gcc")" || echo "Compilador NO Encontrado." );

   etiqueta=$( [ "${VERSION}" != "Compilador NO Encontrado." ] && echo "[ OK  ]" || echo "[ERROR]" );

   printf "%s %-34s %-40s\n" "${etiqueta}" "Compilador.gcc" "${VERSION}";
}

#--------------------------------------------------------------------------------#

function RevisaCompilador()
{
   echo "";
   echo "Revision de Compilador";
   echo "----------------------";

   GCC_version;
}

#--------------------------------------------------------------------------------#

function KERNEL_transparent_hugepages()
{
   thpEsperado="[never]";
   thpActual="";

   for valor in $(cat /sys/kernel/mm/transparent_hugepage/enabled 2> /dev/null)
   do
      if [[ "${valor}" =~ ^\[.*\]$ ]]; then thpActual="${valor}"; fi
   done

   etiqueta="$( [ "${thpActual}" = "${thpEsperado}" ] && echo "[ OK  ]" || echo "[ERROR]" )";

   printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "transparent_hugepages" "${thpEsperado}" "${thpActual}";
}

#--------------------------------------------------------------------------------#

function RevisaTransparentHugePages()
{
   echo "";
   echo "Revision de Transparent HugePages";
   echo "---------------------------------";

   KERNEL_transparent_hugepages;
}

#--------------------------------------------------------------------------------#

function ValidaParametroDeKernel()
{
   iNombreDeParametroDeKernel="${1}";
   iValorEsperadoDeParametroDeKernel="${2}";
   lValorActualDeParametroDeKernel="$(retornaValorDeParametroDeKernel "${iNombreDeParametroDeKernel}")";

   etiqueta="[ OK  ]";

   case "${iNombreDeParametroDeKernel}" in
      "kernel.sem")
         semEsperado="${iValorEsperadoDeParametroDeKernel}";
         semActual="${lValorActualDeParametroDeKernel}";

         semmslEsperado=$(echo ${semEsperado} | awk '{print $1}');
         semmslActual=$(echo ${semActual} | awk '{print $1}');
         if [ ${semmslActual} -ne ${semmslEsperado} ]; then etiqueta="[ERROR]"; fi

         semmnsEsperado=$(echo ${semEsperado} | awk '{print $2}');
         semmnsActual=$(echo ${semActual} | awk '{print $2}');
         if [ ${semmnsActual} -ne ${semmnsEsperado} ]; then etiqueta="[ERROR]"; fi

         semopmEsperado=$(echo ${semEsperado} | awk '{print $3}');
         semopmActual=$(echo ${semActual} | awk '{print $3}');
         if [ ${semopmActual} -ne ${semopmEsperado} ]; then etiqueta="[ERROR]"; fi

         semmniEsperado=$(echo ${semEsperado} | awk '{print $4}');
         semmniActual=$(echo ${semActual} | awk '{print $4}');
         if [ ${semmniActual} -ne ${semmniEsperado} ]; then etiqueta="[ERROR]"; fi
      ;;

      "net.ipv4.ip_local_port_range")
         rangeEsperado="${iValorEsperadoDeParametroDeKernel}";
         rangeActual="${lValorActualDeParametroDeKernel}";

         minEsperado=$(echo ${rangeEsperado} | awk '{print $1}');
         minActual=$(echo ${rangeActual} | awk '{print $1}');

         if [ ${minActual} -ne ${minEsperado} ]; then etiqueta="[ERROR]"; fi

         maxEsperado=$(echo ${rangeEsperado} | awk '{print $2}');
         maxActual=$(echo ${rangeActual} | awk '{print $2}');

         if [ ${maxActual} -ne ${maxEsperado} ]; then etiqueta="[ERROR]"; fi
      ;;

       *)
         if [ ${lValorActualDeParametroDeKernel} -ne ${iValorEsperadoDeParametroDeKernel} ]; then etiqueta="[ERROR]"; fi
      ;;
   esac

   printf "%s %-34s Minimo esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "${iNombreDeParametroDeKernel}" "${iValorEsperadoDeParametroDeKernel}" "${lValorActualDeParametroDeKernel}";

#   if [ "${etiqueta}" == "[ERROR]" ];
#   then
   echo "grep -iv \"${iNombreDeParametroDeKernel}\" ${SYSCTL_CONF} > ${SYSCTL_CONF_TMP};"                  >> ${ARCHIVO_FIX};
   echo "cat ${SYSCTL_CONF_TMP} > ${SYSCTL_CONF};"                                                         >> ${ARCHIVO_FIX};
   echo "echo \"${iNombreDeParametroDeKernel} = ${iValorEsperadoDeParametroDeKernel}\" >> ${SYSCTL_CONF};" >> ${ARCHIVO_FIX};
#   fi
}

#--------------------------------------------------------------------------------#

function ValidaLimiteDeUsuario()
{
   iNombreDelLimite="${1}";
   iValorEsperadoDelLimiteSoft="${2}";
   iValorEsperadoDelLimiteHard="${3}";
   lValorActualDelLimiteSoft=$(retornaValorDeLimiteDeUsuario "soft" "${iNombreDelLimite}");
   lValorActualDelLimiteHard=$(retornaValorDeLimiteDeUsuario "hard" "${iNombreDelLimite}");

   #validando Soft
   etiqueta="[ OK  ]";

#   if [ ${lValorActualDelLimiteSoft} -eq -1 ];
#   then
#      lValorActualDelLimiteSoft="-1 (unlimited)";
#   else
   if [ ${lValorActualDelLimiteSoft} -ne ${iValorEsperadoDelLimiteSoft} ];
   then
      etiqueta="[ERROR]";
   fi
#   fi

   printf "%s %-34s Minimo esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "limit: ${ORAUSER} soft ${iNombreDelLimite}" "${iValorEsperadoDelLimiteSoft}" "${lValorActualDelLimiteSoft}";

   #validando Hard
   etiqueta="[ OK  ]";

#   if [ ${lValorActualDelLimiteHard} -eq -1 ];
#   then
#      lValorActualDelLimiteHard="-1 (unlimited)";
#   else
   if [ ${lValorActualDelLimiteHard} -ne ${iValorEsperadoDelLimiteHard} ];
   then
      etiqueta="[ERROR]";
   fi
#   fi

   printf "%s %-34s Minimo esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "limit: ${ORAUSER} hard ${iNombreDelLimite}" "${iValorEsperadoDelLimiteHard}" "${lValorActualDelLimiteHard}";

   echo "grep -Eiv \".*${ORAUSER}.*${iNombreDelLimite}.*\" ${LIMITS_CONF} > ${LIMITS_CONF_TMP};"              >> ${ARCHIVO_FIX};
   echo "cat ${LIMITS_CONF_TMP} > ${LIMITS_CONF};"                                                            >> ${ARCHIVO_FIX};
   echo "echo -e \"${ORAUSER}\tsoft\t${iNombreDelLimite}\t${iValorEsperadoDelLimiteSoft}\" >> ${LIMITS_CONF}" >> ${ARCHIVO_FIX};
   echo "echo -e \"${ORAUSER}\thard\t${iNombreDelLimite}\t${iValorEsperadoDelLimiteHard}\" >> ${LIMITS_CONF}" >> ${ARCHIVO_FIX};
}

#--------------------------------------------------------------------------------#

function RevisaParametrosKernelYLimites()
{
   echo "";
   echo "Revision de Parametros de Kernel (${SYSCTL_CONF})";
   echo "---------------------------------------------------";

           lHP=$(( ${ORA_MEMORY_LIMIT_KB} / ${OS_HUGE_PAGE_SIZE_KB} ));
   lHPOverHead=$(( ${ORA_MEMORY_LIMIT_KB} / 1024 / 1024 / 2 ));

   if [ ${lHPOverHead} -lt 2 ]; then lHPOverHead=2; fi

   lHUGEPAGES=$(( ${lHP} + ${lHPOverHead} ));
      lSHMALL=$(( ${lHUGEPAGES} *  ${OS_HUGE_PAGE_SIZE_KB} / ${OS_PAGE_SIZE_KB} ));
      lSHMMAX=$(( ${lHUGEPAGES} *  ${OS_HUGE_PAGE_SIZE_KB} * 1024 ));

                           #Parametro                        #Valor Esperado
   ValidaParametroDeKernel "vm.nr_hugepages"                 "${lHUGEPAGES}"
   ValidaParametroDeKernel "kernel.shmall"                   "${lSHMALL}"
   ValidaParametroDeKernel "kernel.shmmax"                   "${lSHMMAX}"
   ValidaParametroDeKernel "kernel.sem"                      "250 32000 100 128"
   ValidaParametroDeKernel "kernel.panic_on_oops"            "1"
   ValidaParametroDeKernel "fs.file-max"                     "6815744"
   ValidaParametroDeKernel "fs.aio-max-nr"                   "1048576"
   ValidaParametroDeKernel "net.ipv4.ip_local_port_range"    "9000 65500"
   ValidaParametroDeKernel "net.core.rmem_default"           "262144"
   ValidaParametroDeKernel "net.core.rmem_max"               "4194304"
   ValidaParametroDeKernel "net.core.wmem_default"           "262144"
   ValidaParametroDeKernel "net.core.wmem_max"               "1048576"
   ValidaParametroDeKernel "net.ipv4.conf.all.rp_filter"     "2"
   ValidaParametroDeKernel "net.ipv4.conf.default.rp_filter" "2"

   #Si se corrigen parametros de Kernel, es requerido cargar los valores
   if [ $(grep "${SYSCTL_CONF}" ${ARCHIVO_FIX} | wc -l) -ne 0 ];
   then
      echo "/usr/sbin/sysctl -p &> /dev/null" >> ${ARCHIVO_FIX};
      echo "/usr/sbin/sysctl -p &> /dev/null" >> ${ARCHIVO_FIX};
      echo "/usr/sbin/sysctl -p &> /dev/null" >> ${ARCHIVO_FIX};
   fi

   echo "";
   echo "Revision de Limites de Shell (${LIMITS_CONF})";
   echo "--------------------------------------------------------";

   lMEMLOCK=$(( ${lHUGEPAGES} *  ${OS_HUGE_PAGE_SIZE_KB} ));
                         #Limite   #Soft Esperado  #Hard Esperado
   ValidaLimiteDeUsuario "nproc"   "32768"         "32768"
   ValidaLimiteDeUsuario "nofile"  "65536"         "65536"
   ValidaLimiteDeUsuario "stack"   "32768"         "32768"
   ValidaLimiteDeUsuario "memlock" "${lMEMLOCK}"   "${lMEMLOCK}"
}

#--------------------------------------------------------------------------------#

function RevisaPaquetes()
{
   echo "";
   echo "Revision de Paquetes Requeridos (rpms)";
   echo "--------------------------------------------------------";

   echo "";
   echo "> Para TSM";
   paquetesRHEL7_TSM=(TIVsm-API64 TIVsm-BA);

   for paqueteArray in "${paquetesRHEL7_TSM[@]}"
   do
      paqueteRPM=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" ${paqueteArray} | grep "x86_64");
      etiqueta="[ OK  ]";

      if [ -z "${paqueteRPM}" ];
      then
         paqueteRPM="No instalado";
         etiqueta="[ERROR]";
         echo "yum -y install ${paqueteArray}*.x86_64" >> ${ARCHIVO_FIX};
      fi

      printf "%s %-34s Encontrado: %-20s\n" "${etiqueta}" "64bit: ${paqueteArray}" "${paqueteRPM}";
   done

   echo "";
   echo "> Para Oracle 64 bit";

   if [ ${REL_RELEASE} -eq 6 ] || [ ${REL_RELEASE} -eq 7 ];
   then
   #https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ladbi/supported-red-hat-enterprise-linux-7-distributions-for-x86-64.html#GUID-2E11B561-6587-4789-A583-2E33D705E498
      paquetesRHEL7_12c_64bit=( binutils compat-libcap1 compat-libstdc++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libxcb libX11 libXau libXi libXtst make net-tools nfs-utils smartmontools sysstat );

#       gcc-4.4.4-13.el6 (x86_64)
#       gcc-c++-4.4.4-13.el6 (x86_64)
#       libXext-1.1 (x86_64)
#       libXext-1.1 (i686)

      paquetesRHEL7_12c_32bit=( compat-libstdc++ glibc glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel libxcb libX11 libXau libXi libXtst );

      for paqueteArray in "${paquetesRHEL7_12c_64bit[@]}"
      do
         if [ "${paqueteArray}" == "compat-libstdc++" ];
         then
            paqueteRPM=$(rpm -qa --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" | grep "${paqueteArray}" | grep "x86_64");
         else
            paqueteRPM=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" ${paqueteArray} | grep "x86_64");
         fi

         etiqueta="[ OK  ]";

         if [ -z "${paqueteRPM}" ];
         then
            paqueteRPM="No instalado";
            etiqueta="[ERROR]";
            echo "yum -y install ${paqueteArray}*.x86_64" >> ${ARCHIVO_FIX};
         fi

         printf "%s %-34s Encontrado: %-20s\n" "${etiqueta}" "64bit: ${paqueteArray}" "${paqueteRPM}";
      done

      echo "";
      echo "> Para Oracle 32 bit";

      for paqueteArray in "${paquetesRHEL7_12c_32bit[@]}"
      do
         if [ "${paqueteArray}" == "compat-libstdc++" ];
         then
            #paqueteRPM=$(rpm -qa --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" | grep "${paqueteArray}-*" | grep -E "i386|i586|i686");
            paqueteRPM=$(rpm -qa --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" | grep "${paqueteArray}-*" | grep -E "i686");
         else
            #paqueteRPM=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" ${paqueteArray} | grep -E "i386|i586|i686");
            paqueteRPM=$(rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" ${paqueteArray} | grep -E "i686");
         fi

         etiqueta="[ OK  ]";

         if [ -z "${paqueteRPM}" ];
         then
            paqueteRPM="No instalado";
            etiqueta="[ERROR]";
            echo "yum -y install ${paqueteArray}*.i686" >> ${ARCHIVO_FIX};
         fi

         printf "%s %-34s Encontrado: %-20s\n" "${etiqueta}" "32bit: ${paqueteArray}" "${paqueteRPM}";
      done
   fi
}

#--------------------------------------------------------------------------------#

function USUARIO_oracle()
{
   id_usuario=$(id -u ${ORAUSER} 2> /dev/null);
   comandoCorrecto=$?;

   etiqueta="[ OK  ]";

   if [ ${comandoCorrecto} -eq 0 ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Usuario ${ORAUSER}" "Existe el usuario" "Existe el usuario";
      if [ ${id_usuario} -ne 0 ];
      then
         printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Id Usuario ${ORAUSER}" "> 0" "${id_usuario}";
      else
         etiqueta="[ERROR]";
         printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Id Usuario ${ORAUSER}" "> 0" "${id_usuario}";
      fi
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Usuario ${ORAUSER}" "Existe el usuario" "No existe el usuario";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Id Usuario ${ORAUSER}" "> 0" "0";
   fi

   homeEsperado="/home/${ORAUSER}";
   homeActual="$(eval echo ~${ORAUSER})";

   etiqueta="[ OK  ]";

   if [ "${homeActual}" == "${homeEsperado}" ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Home usuario ${ORAUSER}" "${homeEsperado}" "${homeActual}";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Home usuario ${ORAUSER}" "${homeEsperado}" "${homeActual}";
#      echo "echo \"\";" >> ${ARCHIVO_FIX};
#      echo "echo \"\";" >> ${ARCHIVO_FIX};
#      echo "echo \"Se cambiara el Home del usuario ${ORAUSER}\";" >> ${ARCHIVO_FIX};
#      echo "echo -e \"\tHome actual:\t${homeActual}\";" >> ${ARCHIVO_FIX};
#      echo "echo -e \"\tHome esperado:\t${homeEsperado}\";" >> ${ARCHIVO_FIX};
#      echo "echo \"\";" >> ${ARCHIVO_FIX};
#      echo "echo \"En otra terminal verifica que no haya procesos de Base de Datos (Bases y/o Listeners) en ejecucion.\"" >> ${ARCHIVO_FIX};
#      echo "read -p \"Si no hay procesos de Base de Datos, presiona ENTER para continuar\"" >> ${ARCHIVO_FIX};
      echo "mkdir -p ${homeEsperado}" >> ${ARCHIVO_FIX};
      echo "chown ${ORAUSER}:${ORADBA} ${homeEsperado}" >> ${ARCHIVO_FIX};
      echo "chmod 700 ${homeEsperado}" >> ${ARCHIVO_FIX};
#      echo "echo \"\";" >> ${ARCHIVO_FIX};
      #echo "mv ${homeActual} ${homeEsperado}" >> ${ARCHIVO_FIX};
      #echo "cp -rp ${homeActual}/* ${homeEsperado}/" >> ${ARCHIVO_FIX};
      echo "cp -rp ${homeActual}/.bash_profile ${homeEsperado}/ 2> /dev/null" >> ${ARCHIVO_FIX};
      echo "/usr/sbin/usermod -d ${homeEsperado} ${ORAUSER} 2> /dev/null" >> ${ARCHIVO_FIX};
#      echo "if [ \$? -eq 0 ];"  >> ${ARCHIVO_FIX};
#      echo "then"  >> ${ARCHIVO_FIX};
#      echo "echo \"[ OK  ] Modificacion de Home exitosa!\";"  >> ${ARCHIVO_FIX};
#      echo "else"  >> ${ARCHIVO_FIX};
#      echo "echo \"[ERROR] No fue posible modificar el Home del usuario.\";"  >> ${ARCHIVO_FIX};
#      echo "fi"  >> ${ARCHIVO_FIX};
#      echo "echo \"\";" >> ${ARCHIVO_FIX};
   fi

   esDBA=$(groups ${ORAUSER} | grep -w "${ORADBA}" | wc -l);

   etiqueta="[ OK  ]";

   if [ ${esDBA} -eq 1 ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "${ORAUSER} pertenece a ${ORADBA}" "Si" "Si";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "${ORAUSER} Pertenece a ${ORADBA}" "Si" "No";
   fi

   perteneceCompilador=$(groups ${ORAUSER} | grep -w "${ORACOMPILADOR}" | wc -l);

   etiqueta="[ OK  ]";

   if [ ${perteneceCompilador} -eq 1 ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "${ORAUSER} pertenece a ${ORACOMPILADOR}" "Si" "Si";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "${ORAUSER} Pertenece a ${ORACOMPILADOR}" "Si" "No";
  fi

}

#--------------------------------------------------------------------------------#

function RevisaUsuarioOracle()
{
   echo "";
   echo "Revision de usuario Oracle (${ORAUSER})";
   echo "----------------------------------------";

   USUARIO_oracle;
}

#--------------------------------------------------------------------------------#

function RevisaDirectorioMinimo()
{
   DIRECTORIO="${1}";

   ls -ld ${DIRECTORIO} &> /dev/null
   EXISTE=$?;

   etiqueta="[ OK  ]";

   if [ ${EXISTE} -eq 0 ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Directorio ${DIRECTORIO}" "Existe" "Existe";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "Directorio ${DIRECTORIO}" "Existe" "No existe";
   fi
}

#--------------------------------------------------------------------------------#

function RevisaDirectoriosMinimos()
{

   echo "";
   echo "Revision de Directorios Raiz Minimos";
   echo "------------------------------------";

   lOSID="${1}";#ORACLE_SID
   lOENV="${2}";#ENVIRONMENT

   arrayDirectorios=( dboracle- dbtrac01- dbsyst01- dbsaux01- dbundo01- dbtemp01- dbreco01- dbreco02- dbreco03- dbreco04- dbreco05- dbreco06- dbdata01- dbindx01- dbbkup01- );

   #PRO=PRODUCTION, solo en produccion se valida el /arch_
   if [ "${lOENV}" = "PRO" ]; then arrayDirectorios+=( arch_ ); fi

   for fs in "${arrayDirectorios[@]}"
   do
      RevisaDirectorioMinimo "/${fs}${lOSID}";
   done

   arrayOtros=( prog );

   #PRO=PRODUCTION, solo en produccion se valida el /cloudcontrol
   if [ "${lOENV}" = "PRO" ];
   then
      fsCC="$(ls -l / | awk '{print $9}' | grep -E "^ccontrol$|^cloudcontrol$")";

      if [ -z "${fsCC}" ]; then fsCC="cloudcontrol"; fi

      arrayOtros+=( ${fsCC} );
   fi

   for fs in "${arrayOtros[@]}"
   do
      RevisaDirectorioMinimo "/${fs}";
   done
}

#--------------------------------------------------------------------------------#

function RevisaFileSystem()
{
   FILESYSTEM="${1}";

   echo "";
   echo "Revision de FileSystem '${FILESYSTEM}'";
   echo "--------------------------------------------------";

   grep -qs ${FILESYSTEM} /proc/mounts;
   MONTADO=$?;

   etiqueta="[ OK  ]";

   if [ ${MONTADO} -eq 0 ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} montado" "Si" "Si";
   else
      etiqueta="[ERROR]";
     printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} montado" "Si" "No";
   fi

   OWNERSHIP="$(stat --format="%U:%G" "${FILESYSTEM}")";

   etiqueta="[ OK  ]";

   if [ "${OWNERSHIP}" = "${ORAUSER}:${ORADBA}" ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} ownership" "${ORAUSER}:${ORADBA}" "${OWNERSHIP}";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} ownership" "${ORAUSER}:${ORADBA}" "${OWNERSHIP}";
      echo "chown ${ORAUSER}:${ORADBA} ${FILESYSTEM}" >> ${ARCHIVO_FIX};
   fi

   PERMISOS="$(stat --format="%a" "${FILESYSTEM}")";

   etiqueta="[ OK  ]";

   if [ "${PERMISOS}" = "750" ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} permisos" "750" "${PERMISOS}";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} permisos" "750" "${PERMISOS}";
      echo "chmod 750 ${FILESYSTEM}" >> ${ARCHIVO_FIX};
   fi

   touch ${FILESYSTEM}/touch.test &> /dev/null;

   ESCRITURALECTURA=$?;

   rm -rf ${FILESYSTEM}/touch.test &> /dev/null;

   etiqueta="[ OK  ]";

   if [ "${ESCRITURALECTURA}" -eq 0 ];
   then
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} Read/Write" "Si" "Si";
   else
      etiqueta="[ERROR]";
      printf "%s %-34s Esperado: %-20s Encontrado: %-20s\n" "${etiqueta}" "FS ${FILESYSTEM} Read/Write" "Si" "No";
      #echo "chmod 750 ${FILESYSTEM}" >> ${ARCHIVO_FIX};
   fi
}

#--------------------------------------------------------------------------------#

function RevisaFileSystems()
{
   lOSID="${1}";#ORACLE_SID
   lOENV="${2}";#Environment

   #PRO=PRODUCTION, solo en produccion se valida el /arch_
   listaFS=$( [ "${lOENV}" = "PRO" ] \
              && echo "$(ls -l / | awk '{print $9}' | grep "${lOSID}$"                  )" \
              || echo "$(ls -l / | awk '{print $9}' | grep "${lOSID}$" | grep -v "arch_")"
            );

   for fs in $(echo "${listaFS}")
   do
      RevisaFileSystem "/${fs}";
   done

   fsCC="$(ls -l / | awk '{print $9}' | grep -E "^ccontrol$|^cloudcontrol$")";

   if [ -z "${fsCC}" ];
   then
      fsCC="cloudcontrol";
   fi

   for fs in $(echo "${fsCC} prog")
   do
      RevisaFileSystem "/${fs}";
   done
}

#--------------------------------------------------------------------------------#

function verParametrosKernelYLimites()
{
   echo "";
   echo "";
   echo "Parametros de Kernel";
   echo "---------------------------------";
   grep "vm.nr_hugepages"                 ${SYSCTL_CONF};
   grep "kernel.shmall"                   ${SYSCTL_CONF};
   grep "kernel.shmmax"                   ${SYSCTL_CONF};
   grep "kernel.sem"                      ${SYSCTL_CONF};
   grep "kernel.panic_on_oops"            ${SYSCTL_CONF};
   grep "fs.file-max"                     ${SYSCTL_CONF};
   grep "fs.aio-max-nr"                   ${SYSCTL_CONF};
   grep "net.ipv4.ip_local_port_range"    ${SYSCTL_CONF};
   grep "net.core.rmem_default"           ${SYSCTL_CONF};
   grep "net.core.rmem_max"               ${SYSCTL_CONF};
   grep "net.core.wmem_default"           ${SYSCTL_CONF};
   grep "net.core.wmem_max"               ${SYSCTL_CONF};
   grep "net.ipv4.conf.all.rp_filter"     ${SYSCTL_CONF};
   grep "net.ipv4.conf.default.rp_filter" ${SYSCTL_CONF};

   echo "";
   echo "";
   echo "Limites de Usuario";
   echo "---------------------------------";
   grep "nproc"   ${LIMITS_CONF};
   grep "nofile"  ${LIMITS_CONF};
   grep "stack"   ${LIMITS_CONF};
   grep "memlock" ${LIMITS_CONF};
}

#--------------------------------------------------------------------------------#

function Revisiones()
{
   lOSID="$(echo ${1} | awk '{print tolower($0)}')";
   lOENV="$(echo ${2} | awk '{print toupper($0)}')";

   CheckOSEncabezado "$(hostname)" "${lOSID}"

   RevisaTipoServidor;
   RevisaTipoArquitectura;
   RevisaVersionKernel;
   RevisaMinimoMemoriaRAM;
   RevisaMinimoMemoriaSWAP;
   RevisaCompilador;
   RevisaTransparentHugePages;
   RevisaParametrosKernelYLimites;
   RevisaPaquetes;
   RevisaUsuarioOracle;
   RevisaDirectoriosMinimos "${lOSID}" "${lOENV}";
   RevisaFileSystems        "${lOSID}" "${lOENV}";
}

#--------------------------------------------------------------------------------#

function main()
{
   OSID="$(echo ${1} | awk '{print tolower($0)}')";
   OENV="$(echo ${2} | awk '{print toupper($0)}')";

   ORAUSER="prhtorac"; #--Cambiar en caso que el usuario de instalacion sea distinto
   ORADBA="dba";       #--Cambiar en caso que el grupo de instalacion sea distinto

   ORACOMPILADOR="grpacmpl"; #--Cambiar en caso que el grupo de compiladores sea distinto

   REL_RELEASE=$(grep "release" /etc/redhat-release | awk '{print $7}' | sed -e 's|\..*$||');

   SYSCTL_CONF="/etc/sysctl.conf";
   SYSCTL_CONF_TMP="/tmp/sysctl.tmp";
   #LIMITS_CONF="/etc/security/limits.conf";
   LIMITS_CONF="/etc/security/limits.d/90-${ORAUSER}.conf";
   LIMITS_CONF_TMP="/tmp/90-${ORAUSER}.tmp";

   OS_PAGE_SIZE_KB=$(retornaSistemaOperativoPageSizeEnKB);
   OS_HUGE_PAGE_SIZE_KB=$(retornaSistemaOperativoHugePageSizeEnKB);
   ORA_MEMORY_LIMIT_KB=$(retornaCalculaMemoriaAConfigurarParaOracleEnKB);


   cat /dev/null > ${ARCHIVO_FIX};

   Revisiones "$@"

   echo ""                  ;
   echo ""                  ;
   echo "Resumen de errores";
   echo "------------------";

   conteoErrores=$(grep -iw "\[ERROR\]" ${ARCHIVO_LOG} | wc -l);

   CODIGO_EXIT=1;
   if [ ${conteoErrores} -eq 0 ];
   then
      echo "En hora buena!. No se encontraron errores.";
      CODIGO_EXIT=0;
   fi

   grep -iw "\[ERROR\]" ${ARCHIVO_LOG}           ;

##Apply##
   echo ""                                       ;
   echo ""                                       ;
   echo ">>> Valores ANTES de la modificacion:"  ;
   verParametrosKernelYLimites                   ;
   echo ""                                       ;
   echo ""                                       ;
   echo ">>> Configurando nuevos valores..."     ;
   sh ${ARCHIVO_FIX}                             ;
   echo ""                                       ;
   echo ">>> Valores DESPUES de la modificacion:";
   verParametrosKernelYLimites                   ;

return ${CODIGO_EXIT};
}

#---------------------------------------- MAIN ----------------------------------------#
ARCHIVO_FIX="check-OS.${1}.fix";
ARCHIVO_LOG="check-OS.${1}.log";

main "$@" |& tee ${ARCHIVO_LOG}
CODIGO_EXIT=$?;

RUTA_LOG_PARA_SOPORTE="/prog/log";
mkdir -p                   ${RUTA_LOG_PARA_SOPORTE} 2> /dev/null;
chown ${ORAUSER}:${ORADBA} ${RUTA_LOG_PARA_SOPORTE} 2> /dev/null;
chmod u=rwx,g-rwx,o-rwx    ${RUTA_LOG_PARA_SOPORTE} 2> /dev/null;

if [ -d ${RUTA_LOG_PARA_SOPORTE} ];
then
   LOG_PARA_SOPORTE="Log_Checklist_DB_${1}.log";

   cp    ${ARCHIVO_LOG}       ${RUTA_LOG_PARA_SOPORTE}/${LOG_PARA_SOPORTE};
   chown ${ORAUSER}:${ORADBA} ${RUTA_LOG_PARA_SOPORTE}/${LOG_PARA_SOPORTE};
fi

exit ${CODIGO_EXIT};