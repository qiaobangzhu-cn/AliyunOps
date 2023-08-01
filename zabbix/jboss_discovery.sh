#!/bin/bash
#Function: low-level discovery jboss
#Script_name: jboss_discovery.sh
jboss_discovery()
{

  cd /tmp
  local tmpfile="/tmp/jboss.tmp"
  :> "$tmpfile"
  /bin/ps aux | grep -oP "jmxremote.port=\d{1,}"|grep -oP "\d{1,}" > "$tmpfile"
  chmod 777 "$tmpfile" 2&>/dev/null
  local num=$(cat "$tmpfile" | wc -l)
  printf '{\n'
  printf '\t"data":[ '
  while read line;do
    JBOSS_PORT=$(echo $line | awk '{print $1}')
    printf '\n\t\t{'
    printf "\"{#JBOSS_PORT}\":\"${JBOSS_PORT}\"}"
#    ((num--))
#    [ "$num" == 0 ] && break
#    printf ","
  done < "$tmpfile"
  printf '\n\t]\n'
  printf '}\n'
}
case "$1" in
  jboss_discovery)
    "$1"
    ;;
  *)
    echo "Bad Parameter."
    echo "Usage: $0 jboss_discovery"
    exit 1
    ;;
esac