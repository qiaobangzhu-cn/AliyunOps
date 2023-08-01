#!/bin/bash
if [ "$(cat /proc/version | grep centos)" != "" ];then
   export LANG=zh_CN.UTF-8
fi

message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的服务于你们，请您仔细阅读本文档。\n1.镜像目录环境\n安装目录及配置文件:/alidata/server\n日志目录:/alidata/log\n网站主目录:/alidata/www\n镜像随机密码：/alidata/account.log\n2.相关命令\n/etc/init.d/nginx start|stop|restart\n/etc/init.d/php-fpm start|stop|restart\n/etc/init.d/mysql start|stop|restart\n/etc/init.d/vsftpd start|stop|restart\nswitch\n3.请按回车键下一步" --ok-button 下一步 --fb 20 60
switch_php
}




#switch_php
message
#if grep "/alidata/init/firstlogin.sh" /root/.bashrc >/dev/null;then
#sed -i "/\/alidata\/init\/firstlogin.sh/d"  /root/.bashrc
#fi
