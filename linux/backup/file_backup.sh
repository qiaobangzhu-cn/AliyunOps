#!/bin/bash

backuptime=$(/bin/date "+%Y%m%d")
LogFile=/alidata/backup/plist.log
newfile=BackupName$backuptime.tgz
oldfile=BackupName$(date +%Y%m%d --date='7 days ago').tgz
DIR=`pwd`

echo "-------------------------------------------" >> $LogFile
echo $(date +"%Y-%m-%d %H:%M:%S") >> $LogFile
echo "--------------------------" >> $LogFile

cd /alidata/backup/
#Delete Old File
if [ -f $oldfile ]
then
   rm -f $oldfile >> $LogFile 2>&1
   echo "[$oldfile]Delete Old File Success!" >> $LogFile
else
   echo "[$oldfile]No Old Backup File!" >> $LogFile
fi

cd /alidata/SourceDir
if [ -f $newfile ]
then
   echo "[$newfile]The Backup File is exists,Can't Backup!" >> $LogFile
else
   echo $newfile
   tar zcf $newfile plist
   mv $newfile /alidata/backup
   echo "[$newfile.tgz]Backup Success!" >> $LogFile
fi
cd $DIR
