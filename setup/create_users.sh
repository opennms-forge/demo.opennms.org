#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:8980); do
    printf '.'
    sleep 2
done
echo " DONE"

# Change to project root directory
cd ..

echo -n "Create Minion user                                  "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @setup/minion-user.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
echo "DONE"

echo -n "Create Grafana user                                 "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @setup/grafana-user.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
echo "DONE"

echo -n "Edit Admin user                                     "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @setup/admin-user.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
echo "DONE"
