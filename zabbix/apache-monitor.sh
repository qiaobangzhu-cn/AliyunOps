#!/bin/bash
if [[ "$1" = "Workers" ]]; then
wget --quiet -O - http://127.0.0.1/server-status?auto | grep Score | grep -o "\." | wc -l
else
wget --quiet -O - http://127.0.0.1/server-status?auto | head -n 9 | grep $1 | awk -F ":" '{print $2}'
fi