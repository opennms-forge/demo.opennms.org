#!/bin/bash
GF_USER="admin"
GF_PASS="$(grep ADMIN_PASSWORD ../.grafana.env | awk -F "=" '{ print $2 }')"
ONMS_PASS="$(grep GRAFANA ../.opennms.env | awk -F "=" '{ print $2 }')"
ONMS_USER=grafana
GF_URL=http://localhost:3000
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'


printf "Install OpenNMS Helm app ...\\n"
if  cd .. && docker exec -it demo-grafana /usr/share/grafana/bin/grafana-cli plugins install opennms-helm-app 1>/dev/null; then
    echo -e "${GREEN}done${NO_COLOR}"
else
    echo -e "${RED}failed${NO_COLOR}"
fi

echo "Restart Grafana ..."
docker-compose stop grafana
docker-compose up -d

 printf "#### Waiting for Grafana to come online ####\\n"
 until curl -L --output /dev/null --silent --head --fail "$GF_URL"; do
   printf '.'
   sleep 2
 done
 printf "Grafana is online!\\n"

echo "Setting Organisation Name"
if curl --silent -X PUT "http://$GF_USER:$GF_PASS@127.0.0.1:3000/api/orgs/1" -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{ "name":"OpenNMS" }' &>/dev/null; then
    echo -e "${GREEN}done${NO_COLOR}"
else
    echo -e "${RED}failed${NO_COLOR}"
fi

echo "Enabling HELM App"
if curl --basic -PUT "$GF_USER:$GF_PASS@localhost:3000/api/plugins/opennms-helm-app/settings?enabled=true" -d '' 2>/dev/null; then
    echo -e "${GREEN}done${NO_COLOR}"
else
    echo -e "${RED}failed${NO_COLOR}"
fi

echo "Setting HELM credentials"
echo "Performance Metrics:"
if curl --silent -X POST "http://$GF_USER:$GF_PASS@127.0.0.1:3000/api/datasources/" -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"orgId":1,"id":1,"name":"OpenNMS Horizon PM","type":"opennms-helm-performance-datasource","typeLogoUrl":"public/plugins/opennms-helm-performance-datasource/img/pm-ds.svg","access":"proxy","url":"http://demo-horizon:8980/opennms","password":"","user":"","database":"","basicAuth":true,"basicAuthUser":"'$ONMS_USER'","basicAuthPassword":"'"$ONMS_PASS"'","isDefault":false,"jsonData":null}' >/dev/null; then
    echo -e "${GREEN}done${NO_COLOR}"
else
    echo -e "${RED}failed${NO_COLOR}"
fi

echo "Fault Management:"
if curl --silent -X POST "http://$GF_USER:$GF_PASS@127.0.0.1:3000/api/datasources/" -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{ "orgId":1,"id":2,"name":"OpenNMS Horizon FM","type":"opennms-helm-fault-datasource","typeLogoUrl":"public/plugins/opennms-helm-performance-datasource/img/fm-ds.svg","access":"proxy","url":"http://demo-horizon:8980/opennms","password":"","user":"","database":"","basicAuth":true,"basicAuthUser":"'$ONMS_USER'","basicAuthPassword":"'"$ONMS_PASS"'","isDefault":false,"jsonData":null}' >/dev/null; then
    echo -e "${GREEN}done${NO_COLOR}"
else
    echo -e "${RED}failed${NO_COLOR}"
fi

