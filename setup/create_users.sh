#!/bin/bash
OPENNMS_HOST=127.0.0.1
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:8980); do
    printf '.'
    sleep 2
done
echo " DONE"


for i in *-user.xml;
do

 echo -n "Creating user with $i"
 curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @$i \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
 echo .
done

echo -n "Setting admin password"
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @admin.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
echo .
