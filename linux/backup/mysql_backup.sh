#!/bin/bash 
dir="/opt/backup"

host=localhost
user=root
pass=""
dbname=""
d=`date +%F`
if [ ! -e "$dir" ]
then
	echo " $dir not exist"
	exit 1	
fi 
mysqldump -u$user -p$pass $dbname > ${dir}/$dbname-$d.sql
# gzip
gzip ${dir}/$dbname-$d.sql &
# housekeeper
#find $dir -type f -name $dbname-$d.sql -mtime +1|xargs rm -vf

logger "mysql $d backup done"
