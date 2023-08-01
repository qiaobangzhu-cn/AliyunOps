#!/bin/bash
#Function: low-level discovery mounted disk
#Script_name: mount_disk_discovery.sh 
mount_disk_discovery()
{
  local regexp="\b(btrfs|ext2|ext3|ext4|jfs|reiser|xfs|ffs|ufs|jfs|jfs2|vxfs|hfs|ntfs|fat32|zfs)\b"
  local tmpfile="/tmp/mounts.tmp"
  :> "$tmpfile"
  egrep "$regexp" /proc/mounts > "$tmpfile"
  local num=$(cat "$tmpfile" | wc -l)
  printf '{\n'
  printf '\t"data":[ '
  while read line;do
    DEV_NAME=$(echo $line | awk '{print $1}')
    FS_NAME=$(echo $line | awk '{print $2}')
    SEC_SIZE=$(sudo /sbin/blockdev --getss $DEV_NAME 2>/dev/null)
    printf '\n\t\t{'
    printf "\"{#DEV_NAME}\":\"${DEV_NAME}\","
    printf "\"{#FS_NAME}\":\"${FS_NAME}\","
    printf "\"{#SEC_SIZE}\":\"${SEC_SIZE}\"}"
    ((num--))
    [ "$num" == 0 ] && break
    printf ","
  done < "$tmpfile"
  printf '\n\t]\n'
  printf '}\n'
}
case "$1" in
  mount_disk_discovery)
    "$1"
    ;;
  *)
    echo "Bad Parameter."
    echo "Usage: $0 mount_disk_discovery"
    exit 1
    ;;
esac
