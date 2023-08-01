#!/bin/bash
# install zabbix_proxy(centos 6+,debian,ubuntu)
# auth:fanjun
# date:2018-07-25

prefix="/usr/local/zabbix-agentd"
name=`hostname`

initgcc()
{
        #check os
        if [ -f /etc/redhat-release ]
        then
                yum install -y gcc
        else
                apt-get update
                apt-get install -y build-essential
        fi
}
install()
{
        cd /opt
        if [ ! -f "zabbix-3.2.1.tar.gz" ]
        then
                wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/server/zabbix-3.2.1.tar.gz -O zabbix-3.2.1.tar.gz
                tar xzf zabbix-3.2.1.tar.gz
        else
                tar xzf zabbix-3.2.1.tar.gz
        fi
        cd zabbix-3.2.1
        if [ -d "$prefix" ]
        then
                echo "/usr/local/zabbix-agentd existed"
                exit
        fi
        ./configure --enable-agent  --prefix=${prefix}
        make -j 2
        make install
        #create user 
        if ! grep -q zabbix /etc/passwd
        then
                groupadd zabbix
                useradd -g zabbix zabbix -M -s /sbin/nologin
        fi
}
config()
{
        if [ -f /etc/redhat-release ]
        then
                cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
                chmod 755 /etc/init.d/zabbix*
                sed -i "s#BASEDIR=/usr/local#BASEDIR=${prefix}#" /etc/init.d/zabbix_agentd
                echo "/etc/init.d/zabbix_agentd start" >> /etc/rc.local
        else
                cp misc/init.d/debian/zabbix-agent /etc/init.d/
                chmod 755 /etc/init.d/zabbix*
                sed -i "s#DAEMON=/usr/local/sbin#DAEMON=${prefix}/sbin#" /etc/init.d/zabbix-agent
                echo "/etc/init.d/zabbix-agent start" >> /etc/rc.local
        fi

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

        ##### install iptables number monitor
        mkdir -p /usr/local/zabbix-agentd/monitor_scripts
        cat > /usr/local/zabbix-agentd/monitor_scripts/iptables-monitor.sh << 'EOF'
        #!/bin/bash
        # Developers: Rhommel Lamas
        # Purpose: zabbix Plugin for Iptables Rules load check
        # Version 0.5
        PARAM1=$1
        TABLE=$2
        MINRULES=$3
        PARAM4=$4
        LOG=/var/log/iptables/iptables.log
        CHKIPTBLS=`sudo /sbin/iptables -n -t filter -L |egrep "(ACCEPT|DROP)" |grep -v policy|wc -l`
        mkdir -p /var/log/iptables/
        # Parameter Validation
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
       fi
    
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
                        # zabbix exit code 2 = status CRITICAL = red
                            exit 2
        fi
EOF

        #sudoers 
        if ! grep "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables" /etc/sudoers >> /dev/null
        then
        echo -e "zabbix ALL=(ALL) NOPASSWD: /sbin/iptables,/sbin/blockdev\nDefaults:zabbix !requiretty" >> /etc/sudoers
        fi


        chown -R zabbix:zabbix /usr/local/zabbix-agentd/monitor_scripts
        chmod 755 /usr/local/zabbix-agentd/monitor_scripts/*

        #config zabbix_agentd.conf
        cp ${prefix}/etc/zabbix_agentd.conf ${prefix}/etc/zabbix_agentd.conf-old
        sed -i "s/Server=127.0.0.1/Server=hz-monitor.jiagouyun.com/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# Timeout=3?Timeout=30?" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s/Hostname=Zabbix server/Hostname=${name}/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s/ServerActive=127.0.0.1/#ServerActive=127.0.0.1/" ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# Include=/usr/local/etc/zabbix_agentd.conf.d/\*.conf? Include=${prefix}/etc/zabbix_agentd.conf.d/\*.conf?"  ${prefix}/etc/zabbix_agentd.conf
        sed -i "s?# StartAgents=3?StartAgents=10?" ${prefix}/etc/zabbix_agentd.conf
        echo "#########################"
        echo "Congratulations! Zabbix_agent has been installed."
        echo "Start Zabbix Agent ..."
}
start()
{
        if [ -f /etc/redhat-release ]
        then
        /etc/init.d/zabbix_agentd start
        else
        /etc/init.d/zabbix-agent start
        fi
}
initgcc
install
config
start