#!/bin/bash

OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_HOST=172.29.0.6
OPENNMS_PORT=8980


curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @setup/minion-user.xml \
http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
