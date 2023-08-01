#!/bin/bash

#Store the script and log in /alidata/ops_script/
LogFile=/alidata/ops_script/del-log.log
DELDAY="+10"
LOGDIR=/alidata/tomcat/logs/*.log

echo "-------------------------------------------" >> $LogFile
echo $(date +"%Y-%m-%d %H:%M:%S") >> $LogFile
echo "$LOGDIR---del----->" >> $LogFile
if find $LOGDIR -type f -mtime $DELDAY >> $LogFile
then
   find $LOGDIR -type f -mtime $DELDAY -exec rm -f {}  \;
fi

