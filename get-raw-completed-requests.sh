#!/bin/bash

if [[ -z "$1" ]]; then
  echo "requires a directory to recursively search"
  exit 1
fi

this_dir=$(cd "`dirname $0`" && pwd)
echo "Searching $1 for controller actions, excluding TenantsController"
grep -rhF "Completed in " "$1" | grep -vF "/tenants" | grep -F -e "200 OK" -e "302 Found" | awk '{print $14 + 0,$NF}' > "$this_dir/completed-requests.data"
echo "done"