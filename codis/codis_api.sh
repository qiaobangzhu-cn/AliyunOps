#!/bin/bash

codis_api_proxy="http://121.40.207.106:18087/api/proxy/list"
codis_api_overview="http://121.40.207.106:18087/api/overview"
codis_api_servergroups="http://121.40.207.106:18087/api/server_groups"

cd /tmp
echo >  proxy_list
echo >  overview
echo >  groups_list

del_tmpfile(){
  rm -f proxy_list
  rm -f overview
  rm -f groups_list
}

proxys(){
  curl $codis_api_proxy -o proxy_list &> /dev/null
  proxy_count=`cat proxy_list |grep '"id"'|wc -l`
  echo $proxy_count
  del_tmpfile
  exit
}

ops(){
  curl $codis_api_overview -o overview &> /dev/null
  if cat overview | grep '"ops"' &> /dev/null;then
    ops_count=`cat overview | grep '"ops"' | awk -F: '{print $2}' | awk -F, '{print $1}'`
    echo $ops_count
  else
    echo "0"
  fi
  del_tmpfile
  exit
}

groups(){
  curl $codis_api_servergroups -o groups_list &> /dev/null
  groups_count=`cat groups_list | grep '"id"' | wc -l`
  echo $groups_count
  del_tmpfile
  exit 
}

masters(){
  curl $codis_api_servergroups -o groups_list &> /dev/null
  masters_count=`cat groups_list | grep "master" |wc -l`
  echo $masters_count
  del_tmpfile
  exit
}

slaves(){
  curl $codis_api_servergroups -o groups_list &> /dev/null
  slaves_count=`cat groups_list | grep "slave" |wc -l`
  echo $slaves_count
  del_tmpfile
  exit
}

keys(){
 curl $codis_api_overview -o overview &> /dev/null
 if cat overview |grep "keys=" &> /dev/null;then
   ks=`cat overview |grep "keys=" |awk -F: '{print $2}'|awk -F, '{print $1}'|awk -F= '{print $2}'`
   keys_count=0
   for k in $ks
   do
      keys_count=$(($k+$keys_count))
   done
   echo $keys_count
 else
   echo "0"
 fi
 del_tmpfile
 exit
}

memUsed(){
 curl $codis_api_overview -o overview &> /dev/null
 if cat overview |grep '"used_memory"' &> /dev/null;then
   memUsed_count=0
   muse=`cat overview |grep '"used_memory"'|awk -F: '{print $2}'|awk -F\" '{print $2}'`
   for m in $muse
   do
      memUsed_count=$(($m+$memUsed_count))
   done
   #echo $memUsed_count
   #echo $(($memUsed_count%1048576))
   awk 'BEGIN{printf "%.2f\n",'$memUsed_count'/1048576}'
 else
   echo "0"
 fi
 del_tmpfile
 exit
}

case $1 in
  proxys)
      proxys
  ;;
  ops)
      ops
  ;;
  groups)
      groups
  ;;
  masters)
      masters
  ;;
  slaves)
      slaves
  ;;
  keys)
      keys
  ;;
  memUsed)
      memUsed
  ;;
  *)
      echo 'bash codis_api.sh proxys/ops/groups/masters/slaves/keys/memUsed'
  ;;
esac

