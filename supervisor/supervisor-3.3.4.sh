#!/bin/bash

DATE=`date +%Y%m%d%H%M%S`

mkdir -p /alidata/log/supervisor/
mkdir -p /alidata/ops_script/

if ! easy_install supervisor ;then 
   echo "install error ! exit !!" 
   exit 
fi

\mv /etc/supervisord.conf /etc/supervisord.conf.$DATE &> /dev/null
echo_supervisord_conf > /etc/supervisord.conf

sed -i 's#file=/tmp/supervisor.sock#file=/var/run/supervisor.sock#'  /etc/supervisord.conf
sed -i 's#logfile=/tmp/supervisord.log#logfile=/alidata/log/supervisor/supervisord.log#'  /etc/supervisord.conf
sed -i 's#pidfile=/tmp/supervisord.pid#pidfile=/var/run/supervisord.pid#'  /etc/supervisord.conf
sed -i 's#serverurl=unix:///tmp/supervisor.sock#serverurl=unix:///var/run/supervisor.sock#'  /etc/supervisord.conf

echo "[include]" >> /etc/supervisord.conf
echo "files = /alidata/ops_script/*.supervisor" >> /etc/supervisord.conf

#add rc.local
if ! cat /etc/rc.local | grep "supervisord -c /etc/supervisord.conf" &> /dev/null;then
    echo "supervisord -c /etc/supervisord.conf" >> /etc/rc.local
fi
