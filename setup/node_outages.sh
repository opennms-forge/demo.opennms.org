#!/bin/bash

# Script stops one of three running Elastic or datacollection containers to generate nodeDown outages in the demo system

set -u
set -e

nodecount=$(docker ps --format '{{.Names}}' --filter "name=dc.*" --filter "name=elastic*" |  wc -l)
if [ "$nodecount" -lt 5 ]
then
  INSTALL_PATH=$(cat /etc/docker/.onms_install_path)
  cd "$INSTALL_PATH" || exit 2
  cd .. &&  docker-compose up -d
else
  mapfile -t array < <(docker ps --format '{{.Names}}' --filter "name=dc.*" --filter "name=elastic*")
  no=$(shuf -i 1-5 -n 1)
  echo "Shutting down node \"${array[$no]}\"..."
  docker stop "${array[$no]}" 1>/dev/null
  echo "Done!"
fi


