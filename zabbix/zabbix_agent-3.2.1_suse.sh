#!/bin/bash

prefix="/usr/local/zabbix-agentd"
name=`hostname`

function install {
	cd /opt
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/zabbix-3.2.1.tar.gz -O zabbix-3.2.1.tar.gz
	tar xzf zabbix-3.2.1.tar.gz
	cd zabbix-3.2.1
	if [ -d "$prefix" ]
	then
		echo "/usr/local/zabbix-agentd existed"
		exit 
	fi
	./configure --enable-agent  --prefix=${prefix}
	make -j 2
	make install
	groupadd zabbix
	useradd -g zabbix zabbix -M -s /sbin/nologin
	cp misc/init.d/suse/9.2/zabbix_agentd /etc/init.d/
	chmod +x /etc/init.d/zabbix_agentd
	sed -i "s#/usr/local/sbin#/usr/local/zabbix-agentd/sbin#" /etc/init.d/zabbix_agentd
	echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
	
	##install disk IO monitor
	mkdir -p /usr/local/zabbix-agentd/monitor_scripts
    cat > /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh << 'EOF'
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
EOF
    
    
    chmod 755 /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh
    chown zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh   
    echo "UserParameter=mount_disk_discovery,/bin/bash /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh mount_disk_discovery" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/diskio-discovery-monitor.conf
    echo "下面出现磁盘信息，说明配置成功，如果没有，请检查！"
    /bin/bash /usr/local/zabbix-agentd/monitor_scripts/diskio-discovery-monitor.sh mount_disk_discovery
    chown zabbix.zabbix /tmp/mounts.tmp
    
    ##### install iptables number monitor
    mkdir -p /usr/local/zabbix-agentd/monitor_scripts
    cat > /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh << 'EOF'
    #!/bin/bash
    #
    # Developers: Rhommel Lamas
    # Purpose: zabbix Plugin for Iptables Rules load check
    # Version 0.5
    #
    PARAM1=$1
    TABLE=$2
    MINRULES=$3
    PARAM4=$4
    LOG=/var/log/iptables/iptables.log
    CHKIPTBLS=`sudo /sbin/iptables -n -t filter -L |egrep "(ACCEPT|DROP)" |grep -v policy|wc -l`
    mkdir -p /var/log/iptables/
    
    #
    # Parameter Validation
    ##
    
    if [ "$PARAM1" != "-T" -o "$TABLE" == "" -o "$MINRULES" != "-r" -o "$PARAM4" == "" ]; then
                    echo "Usage: $0 -T <table> -r <min rules>"
                    echo ""
                    exit 3
                    # zabbix exit code 3 = status UNKNOWN = orange
    
    
    if [ "$PARAM1" == "-h" ]; then
                    echo ""
                    echo "          -h = Display's this Help"
            echo "          -T = Table to check"
                    echo "                           Available Tables:"
                    echo "                                  nat"
                    echo "                                  mangle"
                    echo "                                  filter"
            echo "          -r = Minimun quantity of rules"
                    echo ""
            # zabbix exit code 3 = status UNKNOWN = orange
                    exit 3
       fi
    fi
    
    ##
    #       DO NOT MODIFY ANYTHING BELOW THIS
    ##
    
    $CHKIPTBLS >/dev/null 2>/dev/null
    
    if [ "$CHKIPTBLS" == 0 ]; then
            TOTRULES=$CHKIPTBLS
    else
            TOTRULES=$CHKIPTBLS
    fi
    
    
    if [ "$TOTRULES" == "$PARAM4" ]; then
                        echo "$TOTRULES"
                        # Zabbix exit code 0 = status OK = green
                        exit 0
    else
                        echo  "$TOTRULES"
    #                                       for i in `w  -h | cut -f1 -d" " | sort | uniq`
    #                                       do
    #
    #                                               echo "`date '+%d/%m/%Y - %H:%M:%S'` - CRITICAL - $i is logged in and there are only $TOTRULES loaded" >> $LOG
    #                                       done
                        # zabbix exit code 2 = status CRITICAL = red
                            exit 2
    fi
EOF
    
    
    
    
    if ! grep "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables" /etc/sudoers >> /dev/null
    then
    echo -e "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables,/sbin/blockdev\nDefaults:zabbix !requiretty" >> /etc/sudoers
    fi

    echo "UserParameter=ipts,bash /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh -T filter -r 1" > /usr/local/zabbix-agentd/etc/zabbix_agentd.conf.d/iptables-monitor.conf

    chown -R zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts
    chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*
	
}

function config {
	cp ${prefix}/etc/zabbix_agentd.conf ${prefix}/etc/zabbix_agentd.conf-old
	sed -i "s/Server=127.0.0.1/Server=hz-monitor.jiagouyun.com/" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s?# Timeout=3?Timeout=30?" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s/Hostname=Zabbix server/Hostname=${name}/" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s/ServerActive=127.0.0.1/#ServerActive=127.0.0.1/" ${prefix}/etc/zabbix_agentd.conf
	sed -i "s?# Include=/usr/local/etc/zabbix_agentd.conf.d/\*.conf? Include=${prefix}/etc/zabbix_agentd.conf.d/\*.conf?"  ${prefix}/etc/zabbix_agentd.conf
	sed -i "s?# StartAgents=3?StartAgents=10?" ${prefix}/etc/zabbix_agentd.conf
    echo "#########################"
    echo "Congratulations! Zabbix_agent has been installed successfully."
    echo "Start Zabbix Agent ..."
}

start {
    /etc/init.d/zabbix_agentd start
}

install
config
start