#!/bin/bash

# Script fills up the dc2 container volume.
# 100M disk will fill up in two steps.
# First increase is random is random so it could hit lower warning thresholds and the second run will hit 100% threshold.
# Third run deletes everything to clear

set -x
set -e
set -u

dc2path="/var/lib/docker/volumes/demoopennmsorg_dc2/_data"

usage=$(du -s "$dc2path" | cut -f1 | grep -o -E '[0-9]+')
if [ "$usage" -lt 10 ]
 then 
  no=$(shuf -i 1-88 -n 1)
  fallocate -l "$no"M "$dc2path"/example
 else
  usage=$(du -sh "$dc2path" | cut -f1 | grep -o -E '[0-9]+')
  if [ "$usage" -lt 99 ]
  then 
   let "a= 99-$usage"
   fallocate -l "$a"M "$dc2path"/example_$a
  else 
   rm "$dc2path"/* -rf
  fi
fi

