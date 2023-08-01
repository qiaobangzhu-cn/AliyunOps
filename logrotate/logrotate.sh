#!/bin/bash

mkdir -p /alidata/ops_script/

if ! cat /etc/logrotate.conf | grep "include /alidata/ops_script/\*\.logrotate" &> /dev/null ;then
  sed -i 's#include /etc/logrotate.d#include /etc/logrotate.d\ninclude /alidata/ops_script/*.logrotate#'  /etc/logrotate.conf
fi

/etc/init.d/rsyslog restart &> /dev/null
systemctl restart rsyslog &> /dev/null
