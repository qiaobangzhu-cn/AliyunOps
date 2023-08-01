#!/bin/bash
project="deploy"
backup_dir=~/backup/$project/
sql_file=/tmp/rundeck/${project}/$1
echo '文件备份'

if [ ! -f "$sql_file" ];then
    echo "cannot open $sql_file"
    exit 1;
fi

[ -d "$backup_dir" ] || mkdir  -p ~/backup/$project/

mv -f $sql_file  $backup_dir/${1}_`date +"%s"`
if [ $? -ne 0 ];then
    echo "$sql_file backup fail."
    exit 1
fi
