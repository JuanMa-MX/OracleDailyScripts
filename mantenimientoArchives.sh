#!/bin/bash

rolBase="${1}";
listaBases="${2}";

if [ "$#" -ne 2 ];
then
   echo "$(date) [ERROR] Numero de parametros incorrecto.";
   echo "Uso: mantenimientoArchives.sh \"PRIMARY|STANDBY\" \"base1 base2 baseN\"";
   exit 1;
fi

ARCHIVE_POLICY="NONE";

if [ "${rolBase}" = "PRIMARY" ];
then
   ARCHIVE_POLICY="configure archivelog deletion policy to shipped to all standby;";
fi

if [ "${rolBase}" = "STANDBY" ];
then
   ARCHIVE_POLICY="configure archivelog deletion policy to applied on all standby;";
fi

if [ "${ARCHIVE_POLICY}" != "NONE" ];
then

   while true;
   do

      for osid in ${listaBases}
      do
         export ORAENV_ASK=NO
         export ORACLE_SID=${osid};

         . oraenv -s ${osid} > /dev/null

         rman <<_eof_
connect target

${ARCHIVE_POLICY}

crosscheck archivelog all;

delete noprompt expired archivelog all;

delete noprompt archivelog all;

exit;
_eof_

         done

         date;

         echo "Durmiendo 5 minutos.";

         sleep 300;#5 minutos
   done
fi
