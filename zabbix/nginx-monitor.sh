#!/bin/bash
source /usr/local/zabbix-agentd/monitor_scripts/nginx-monitor.sh.conf
accepts(){
  curl localhost:$PORT 2>/dev/null |sed -n '3p'|awk '{print $1}'
}
handled(){
  curl localhost:$PORT 2>/dev/null |sed -n '3p'|awk '{print $2}'
}
requests(){
  curl localhost:$PORT 2>/dev/null |sed -n '3p'|awk '{print $3}'
}
active(){
  curl localhost:$PORT 2>/dev/null |sed -n '1p'|awk '{print $3}'
}
reading(){
  curl localhost:$PORT 2>/dev/null |sed -n '4p'|awk '{print $2}'
}
writing(){
  curl localhost:$PORT 2>/dev/null |sed -n '4p'|awk '{print $4}'
}
waiting(){
  curl localhost:$PORT 2>/dev/null |sed -n '4p'|awk '{print $6}'
}
case $1 in
   accepts)
       accepts
   ;;
   handled)
       handled
   ;;
   requests)
       requests
   ;;
   active)
       active
   ;;
   reading)
       reading
   ;;
   writing)
       writing
   ;;
   waiting)
       waiting
   ;;
  *)
   ;;
esac