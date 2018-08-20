#!/bin/bash

OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

echo "#### Start deploy process"

# Clear Shorewall
# Since the default config doesn't allow connections to port 8980, we need to disable it for now

echo "#### Disabling Shorewall" 
shorewall clear

# Initialize a new demo instance

echo "#### Initializing new Horizon Stack"

docker-compose down -v && docker-compose pull && systemctl restart docker && systemctl start docker-compose@horizon

echo -n "#### Waiting for OpenNMS to come online"
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:8980); do
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
./reload_all_requisition.sh

# Initialize users

echo "#### Creating user accounts"
./create_users.sh

echo "Deploy process done"
