#!/bin/bash

programname=$0
ONMS_ACCOUNT=admin
ONMS_PASSWORD=admin
ONMS_IP=127.0.0.1



for i in $(curl -s -u $ONMS_ACCOUNT:$ONMS_PASSWORD http://$ONMS_IP:8980/opennms/rest/requisitions | xmllint --format - | grep foreign-source | awk '{print $3}' | cut -d"\"" -f2)
do
  if 
    curl -s \
         -u $ONMS_ACCOUNT:$ONMS_PASSWORD \
         -X POST \
         -d "<event> \
              <uei>uei.opennms.org/internal/importer/reloadImport</uei> \
              <parms> \
               <parm> \
                <parmName>url</parmName> \
                <value>http://pris:8000/requisitions/$i</value> \
               </parm> \
              </parms> \
             </event>" \
         -H "Content-Type: application/xml" \
         http://$ONMS_IP:8980/opennms/rest/events; then

   echo "Requisition $i successfully reloaded"
  else
   echo "REST Command failed"
  fi
done
