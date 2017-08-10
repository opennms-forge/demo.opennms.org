#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=RejVojafecip
OPENNMS_PORT=8988

# set -x

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:${OPENNMS_PORT}); do
    printf '.'
    sleep 2
done
echo "    DONE"

#
# Setup Demo data with foreign sources, requisitions and a topology
#
echo -n "Create Foreign Source Server                       ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @foreign-source-Server.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/foreignSources
echo "DONE"

echo -n "Create Foreign Source Websites                     ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @foreign-source-Websites.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/foreignSources
echo "DONE"
