#!/bin/bash
#####----install nfs server----####
apt-get update
apt-get -y install nfs-kernel-server
#####----deploy direcotry for nfs use----####
dpkg -s nfs-kernel-server >/dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "install nfs-kernel-server fail"
    exit 1
fi

echo "input the directory path you use for nfs service:"
read Path
if [ -z "$Path" ]
then
    echo "Path is null"
    exit 1
fi
mkdir -p $Path   >/dev/null
if [ *p == '/' ] && [ -d "$Path" ] 
then
    echo "${Path} *(rw,no_root_squash)" >> /etc/exports
    /etc/init.d/nfs-kernel-server restart
else
    echo "$Path is NOT a directory"
fi