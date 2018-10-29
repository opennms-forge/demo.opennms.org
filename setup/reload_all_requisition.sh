#!/bin/bash

set -e
set -u

docker exec -it demo-horizon /bin/sh -c 'for i in $(/usr/bin/find /opt/opennms/etc/imports -type f -printf "%f\n"); do /opt/opennms/bin/send-event.pl -p '"'url http://pris:8000/requisitions/'"'${i%.*}'"''"' uei.opennms.org/internal/importer/reloadImport; done'

