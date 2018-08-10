#!/bin/bash

GF_USER=admin
GF_PASS=secret
GF_URL=http://localhost:3000
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

echo -n "Install OpenNMS Helm app ... "
docker-compose exec grafana /usr/share/grafana/bin/grafana-cli plugins install opennms-helm-app 1>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}done${NO_COLOR}"
else
    echo -e "${RED}failed${NO_COLOR}"
fi

echo "Restart Grafana ..."
docker-compose stop grafana
docker-compose up -d
