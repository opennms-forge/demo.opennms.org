#!/bin/bash

programname=$0
OPENNMS_HOST=127.0.0.1
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980
PRIS_HOST=pris
PRIS_PORT=8000

function usage {
    echo "usage: $programname [requisition-name]"
    exit 1
}


if [ "$#" -ne 1 ]; then
    echo "Choose a requisition to reload"
    echo "------------------------------"
    curl -s -u $OPENNMS_USER:$OPENNMS_PASS http://$OPENNMS_HOST:$OPENNMS_PORT/opennms/rest/requisitions | xmllint --format - | grep foreign-source | awk '{print $3}' | cut -d"\"" -f2
    echo "------------------------------"
    usage
fi

for i in $(curl -s -u $OPENNMS_USER:$OPENNMS_PASS http://$OPENNMS_HOST:$OPENNMS_PORT/opennms/rest/requisitions | xmllint --format - | grep foreign-source | awk '{print $3}' | cut -d"\"" -f2)
do
 if [[ $i = ${1} ]]; then
  if 
    curl -s \
         -u $OPENNMS_USER:$OPENNMS_PASS \
         -X POST \
         -d "<event> \
              <uei>uei.opennms.org/internal/importer/reloadImport</uei> \
              <parms> \
               <parm> \
                <parmName>url</parmName> \
                <value>http://$PRIS_HOST:$PRIS_PORT/requisitions/${1}</value> \
               </parm> \
              </parms> \
             </event>" \
         -H "Content-Type: application/xml" \
         http://$OPENNMS_HOST:$OPENNMS_PORT/opennms/rest/events; then

   echo "Requisition ${1} successfully reloaded"
   exit 1
  else
   echo "REST Command failed"
  fi
 fi
done
echo "Unknown Requisition"
exit 0
