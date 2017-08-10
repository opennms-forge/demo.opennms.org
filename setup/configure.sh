#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=RejVojafecip
OPENNMS_PORT=8988

GRAFANA_HOST=localhost
GRAFANA_PORT=3001
GRAFANA_USER=admin
GRAFANA_PASS=mysecret

MINION_USER=minion
MINION_PASS=minion

# set -x

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:${OPENNMS_PORT}); do
    printf '.'
    sleep 2
done
echo " DONE"

# Change to project root directory
cd ..

echo -n "Create Minion user                                 ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @setup/minion-user.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
echo "DONE"

echo -n "Create user on Minion for ReST API and HTTP broker ... "
docker-compose exec minion "/opt/minion/bin/scvcli set opennms.http ${MINION_USER} ${MINION_PASS}"
docker-compose exec minion "/opt/minion/bin/scvcli set opennms.broker ${MINION_USER} ${MINION_PASS}"

#
# Change into OpenNMS config directory to apply configuration patches for Graylog and ActiveMQ for Minions
#
cd etc
echo -n "Enable listening for ActiveMQ on all interfaces    ... "
patch opennms-activemq.xml < ../setup/activemq-listen.patch
echo "DONE"

echo "Restart OpenNMS Horizon                            ... "
docker-compose stop opennms && docker-compose up -d

echo -n "Wait for web app to be ready                       "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:${OPENNMS_PORT}); do
    printf '.'
    sleep 2
done
echo " DONE"
