#!/bin/bash -e
clear

set -u

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 0
else 

 OPENNMS_HOST=localhost
 OPENNMS_PORT=8980
 pwd > /etc/docker/.onms_install_path

 echo "#### Deploy Demo OpenNMS System #### "
 echo 
 echo 
 echo "The following process will initialize the OpenNMS demo stack."
 echo
 echo
 echo " ATTENTION:  All existing data will be lost!"
 echo
 echo
 echo "If you only want to reload new config please follow the README on https://github.com/opennms-forge/demo.opennms.org"
 echo 
 echo "Do you want to continue?(yes/no)"
 read -r input

 if [ "$input" == "yes" ]; then
   echo "#### Initializing new Horizon Stack ####"
   docker-compose pull && docker-compose down -v && git submodule update --init && git submodule foreach git pull origin master && sysctl -w vm.max_map_count=262144 && docker-compose up -d
   echo -n "#### Waiting for OpenNMS to come online"

   until curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:${OPENNMS_PORT}; do
     printf '.'
     sleep 2
   done

   echo "OpenNMS is online!"
   echo "#### Setup Grafana HELM Plugin ####"
   ./setup-helm.sh

   echo "#### Installing Grafana Dashboards ####"
   ./setup-dashboards.sh

   # Start importing PRIS requisitions
   echo "#### Start importing requisitions ####"
   docker exec -it demo-horizon /bin/sh -c 'for i in $(/usr/bin/find /opt/opennms/etc/imports -type f -printf "%f\n"); do /opt/opennms/bin/send-event.pl -p '"'url http://pris:8000/requisitions/'"'${i%.*}'"''"' uei.opennms.org/internal/importer/reloadImport; done'

   echo "Deploy process done!"
 else
   echo
   echo "-> Aborted"
 fi

 # Creating cron entry to restart the stack once a day
  echo "Creating cron restart entry"
 if
    grep -q "0\\ 0\\ \\*\\ \\*\\ \\*\\ \\ \\ root\\ \\ systemctl\\ restart\\ docker\\.service" /etc/crontab
 then
    echo "Cron entry already exists"
 else
    echo "0 0 * * *   root  systemctl restart docker.service" >> /etc/crontab
    echo "Done!"
 fi


 # Initiate automated HTTP outage setup  

 echo "Creating cron entry for http outage sript"
 if grep -q http_outage /etc/crontab
 then
  echo "Cron entry already exists!"
  exit 0
 else
  no=$(shuf -i 15-59 -n 1)
  path=$(pwd)
  echo ""$no" * * * *   root  "$path"/http_outages.sh" >> /etc/crontab
  echo "Done!"
 fi
fi
