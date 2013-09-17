#!/bin/bash

if [[ -z "$1" ]]; then
  echo "requires a directory to recursively search"
  exit 1
fi

this_dir=$(cd "`dirname $0`" && pwd)
echo "Searching $1 background job runs. Output is name, duration, db-time, cpu-time."
grep -hrF "Ran once in" "$1" | grep -vF "migrate_all_sites" | grep -vF "clean_expired_sessions" | awk '{ print $9,$15 + 0,$17 + 0,$19 + 0 }' > "$this_dir/background-jobs.data"
echo "done"