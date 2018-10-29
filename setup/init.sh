#!/bin/bash

set -e
set -u

OPENNMS_HOST=localhost
OPENNMS_PORT=8980

echo "#### Deploy Demo OpenNMS System"
echo .
echo .
echo "The following process will initialize the OpenNMS demo stack. ATTENTION: All existing data will be lost!"
echo "If you only want to reload new config please follow the README on https://github.com/opennms-forge/demo.opennms.org"
echo .
echo "The Do you want to continue?(yes/no)"
read input
if [ "$input" == "yes" ]
 then

 # Initialize a new demo instance
 echo "#### Initializing new Horizon Stack"
 docker-compose down -v && docker-compose pull && systemctl restart docker && docker-compose up -d
 echo -n "#### Waiting for OpenNMS to come online"
 until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:${OPENNMS_PORT}); do
   printf '.'
   sleep 2
 done
 echo " DONE"

 # Setup HELM and Dashboards
 echo "#### Setup Grafana HELM Plugin"
 ./setup-helm.sh
 echo "#### Installing Grafana Dashboards"
 ./setup-dashboards.sh

 # Start importing PRIS requisitions
 echo "#### Start importing requisitions"
 docker exec -it demo-horizon /bin/sh -c 'for i in $(/usr/bin/find /opt/opennms/etc/imports -type f -printf "%f\n"); do /opt/opennms/bin/send-event.pl -p '"'url http://pris:8000/requisitions/'"'${i%.*}'"''"' uei.opennms.org/internal/importer/reloadImport; done'

 echo "Deploy process done"
else
 echo "Aborted"
fi
