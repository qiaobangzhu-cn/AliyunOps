#!/bin/bash

user="rundeck"
file="rundeck-launcher-2.6.7.jar"
wget -cq http://zy-res.oss.aliyuncs.com/rundeck/$file
[ -f "$file" ] || exit 1
useradd -m  $user
install -D -o  $user -g  $user ./$file /home/$user/rundeck/$file

temp=`mktemp`
echo $temp
cat >$temp<<EOF
#!/bin/bash
cd \`dirname \$0\`
nohup java -jar $file >rundeck.log 2>&1 &
EOF

install -o $user -g $user -m 755 $temp /home/$user/rundeck/start.sh

cat >$temp<<EOF
#!/bin/bash
cd \`dirname \$0\`
for pid in \`ps -ef | grep -E '$file\$' | grep -v grep|awk '{print \$2}'\`
do
    echo "kill -9 \$pid"
    kill -9 \$pid
done
EOF

install -o $user -g $user -m 755 $temp /home/$user/rundeck/stop.sh

rm -f $temp
chown -R $user:$user /home/$user

ip=`curl -sSL ip.cn 2>&1 | sed -n 's/^[^0-9.]*\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p'`
echo $ip | grep -q -E  '^[0-9]'
if [ $? -ne 0 ];then
    echo "公网IP地址获取失败"
fi

su - $user -c "
    ./rundeck/start.sh

"

#验证是否启动成功 
for t in `seq 1 30`
do
    sleep 1
    ss -ntl | grep -q 4440
    if [ $? -eq 0 ];then
        break
    fi
done

[ -f "/home/$user/rundeck/server/config/rundeck-config.properties" ] || exit 1

sed -i "s/^grails.serverURL=.*/grails.serverURL=http:\/\/$ip:4440/"  /home/$user/rundeck/server/config/rundeck-config.properties

sed -i '
    s/\:admin/\:857db0e9a2/;
    /^user/d;
' /home/$user/rundeck/server/config/realm.properties

su - $user -c "
    ./rundeck/stop.sh
    ./rundeck/start.sh
"

echo "server: http://$ip:4440"
