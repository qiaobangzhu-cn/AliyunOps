#!/bin/bash
if [ "$(cat /proc/version | grep centos)" != "" ];then
   export LANG=zh_CN.UTF-8
fi

message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的服务于你们，请您仔细阅读本文档。\n1.镜像目录环境\n安装目录及配置文件:/alidata/server\n日志目录:/alidata/log\n网站主目录:/alidata/www\n镜像随机密码：/alidata/init/account.log\n2.相关命令\n/etc/init.d/mysqld start|stop|restart\n/etc/init.d/vsftpd start|stop|restart\n/etc/init.d/nginx start|stop|restart\nbash /alidata/server/tomcat6/bin/startup.sh|shutdown.sh\nbash /alidata/server/tomcat7/bin/startup.sh|shutdown.sh\nbash /alidata/server/tomcat8/bin/startup.sh|shutdown.sh\n3.切换jdk版本 \njdk1.6		 bash /root/jdk-1.6.45.sh\njdk1.7	 bash /root/jdk-1.7.71.sh(默认版本) \njdk1.8	 bash /root/jdk-1.8.40.sh \n4.切换tomcat \ntomcat6.0.41		  bash /root/tomcat-6.0.41.sh \ntomcat7.0.54	  bash /root/tomcat-7.0.54.sh(默认版本) \ntomcat8.0.21	  bash /root/tomcat-8.0.21.sh	\n请按回车键退出" --ok-button 退出 --fb 30 60
}

message
if grep "/alidata/init/firstlogin.sh" /root/.bashrc >/dev/null;then
sed -i "/\/alidata\/init\/firstlogin.sh/d"  /root/.bashrc
fi
