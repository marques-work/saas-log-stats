#!/bin/bash

if [[ -z "$1" ]]; then
  echo "requires a directory to recursively search"
  exit 1
fi

this_dir=$(cd "`dirname $0`" && pwd)
echo "Searching $1 for controller actions, excluding TenantsController"
grep -rhF "Processing " "$1" | grep -vF TenantsController | awk '{ if ($13 ~ /([A-Za-z]+)#/) print $13; }' > "$this_dir/web-requests.data"
echo "done"