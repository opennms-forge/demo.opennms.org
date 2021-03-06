#!/bin/bash -e
clear

set -u

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 0
else 

 OPENNMS_HOST=localhost
 OPENNMS_PORT=8980
 
 # -------------------------------
 # Required for http_outage script
 pwd > /etc/docker/.onms_install_path
 # -------------------------------

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

if [[ ! -f ../.postgres.env || ! -f ../.opennms.env || ! -f ../.grafana.env ]];then
    echo "Required environment files are not present. Please check README"
    exit 0
fi

 if [ "$input" == "yes" ]; then
   echo "#### Initializing new Horizon Stack ####"
   cd .. && docker-compose pull && docker-compose down -v && git submodule update --init && git submodule foreach git pull origin master && sysctl -w vm.max_map_count=262144 && docker-compose up -d
   echo -n "#### Waiting for OpenNMS to come online"

   until curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:${OPENNMS_PORT}; do
     printf '.'
     sleep 2
   done

   echo "OpenNMS is online!"
   echo "#### Setup Grafana HELM Plugin ####"
   cd setup && ./setup-helm.sh

   echo "#### Installing Grafana Dashboards ####"
   ./setup-dashboards.sh

   # Start importing PRIS requisitions
   echo "#### Start importing requisitions ####"
   cd .. && docker exec -it demo-horizon /bin/sh -c 'for i in $(/usr/bin/find /opt/opennms/etc/imports -type f -printf "%f\n"); do /opt/opennms/bin/send-event.pl -p '"'url http://pris:8000/requisitions/'"'${i%.*}'"''"' uei.opennms.org/internal/importer/reloadImport; done'

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

 echo "Creating cron entry for http outage script"
 if grep -q http_outage /etc/crontab
 then
  echo "Cron http outage entry already exists!"
 else
  no=$(shuf -i 44-59 -n 1)
  path=$(pwd)
  echo "$no * * * *   root  $path/setup/http_outages.sh" >> /etc/crontab
  echo "Creating cron entry for http outage script done!"
 fi

  # Initiate automated disk fill setup  

 echo "Creating cron entry for fill disk script"
 if grep -q fill_disk /etc/crontab
 then
  echo "Cron fill disk entry already exists!"
 else
  path=$(pwd)
  echo "*/16 * * * *   root  $path/setup/fill_disk.sh" >> /etc/crontab
  echo "Creating cron entry for fill disk script done!"
 fi
 
 # Initiate automated node outage setup  

 echo "Creating cron entry for node outage script"
 if grep -q node_outage /etc/crontab
 then
  echo "Cron node outage entry already exists!"
 else
  no=$(shuf -i 44-59 -n 1)
  path=$(pwd)
  echo "$no * * * *   root  $path/setup/node_outages.sh" >> /etc/crontab
  echo "Creating cron entry for node outage script done!"
 fi
fi
