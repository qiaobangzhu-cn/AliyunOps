#!/bin/bash
#Function: low-level discovery tomcat
#Script_name: tomcat_discovery.sh
tomcat_discovery()
{

  cd /tmp
  local tmpfile="/tmp/tomcat.tmp"
  :> "$tmpfile"
  /bin/ps aux | grep -oP "jmxremote.port=\d{1,}"|grep -oP "\d{1,}" > "$tmpfile"
  chmod 777 "$tmpfile" 2&>/dev/null
  local num=$(cat "$tmpfile" | wc -l)
  printf '{\n'
  printf '\t"data":[ '
  while read line;do
    TOMCAT_PORT=$(echo $line | awk '{print $1}')
    printf '\n\t\t{'
    printf "\"{#TOMCAT_PORT}\":\"${TOMCAT_PORT}\"}"
    ((num--))
    [ "$num" == 0 ] && break
    printf ","
  done < "$tmpfile"
  printf '\n\t]\n'
  printf '}\n'
}
case "$1" in
  tomcat_discovery)
    "$1"
    ;;
  *)
    echo "Bad Parameter."
    echo "Usage: $0 tomcat_discovery"
    exit 1
    ;;
esac