#!/bin/bash
if [ "$(cat /proc/version | grep centos)" != "" ];then
   export LANG=zh_CN.UTF-8
fi

message() {
whiptail --title "镜像环境及命令简介" --msgbox "尊敬的用户，为了更好的服务于你们，请您仔细阅读本文档。\n1.镜像目录环境\n安装目录及配置文件:/alidata/server\n日志目录:/alidata/log\n网站主目录:/alidata/www/\n镜像随机密码：/alidata/account.log\n2.相关命令\n/etc/init.d/httpd start|stop|restart\n/etc/init.d/mysqld start|stop|restart\n想更换php版本，请执行switch命令\n3.请按回车键下一步" --ok-button 下一步 --fb 20 60
switch_php
}


switch_php() {
OPTION=$(whiptail --title "php默认使用5.4" --menu "您可以选择php进行切换\nhelp:需要用到键盘的tab键,方向键,回车键" 15 60 4  1 "php5.2.17" 2 "php5.3.29" 3 "php5.4.23" 4 "php5.5.7" 5 "php5.6.8" --fb --ok-button 确定 --cancel-button 取消 3>&1 1>&2 2>&3)

if [ "$OPTION" = "1" ]; then
  /etc/init.d/httpd stop &> /dev/null
  killall httpd  &> /dev/null
  rm -rf /etc/init.d/httpd
  rm -rf /alidata/server/httpd
  rm -rf /alidata/server/php
  rm -rf /etc/php.ini
  rm -rf /etc/httpd
  ln -s /alidata/server/httpd-2 /etc/httpd
  ln -s /alidata/server/php-2/etc/php.ini  /etc/php.ini
  ln -s /alidata/server/httpd-2 /alidata/server/httpd
  ln -s /alidata/server/php-2  /alidata/server/php
  ln -s /etc/init.d/httpd-2 /etc/init.d/httpd 
  /etc/init.d/httpd start  &> /dev/null
  /etc/init.d/httpd restart &> /dev/null
elif [ "$OPTION" = "2" ]; then
  /etc/init.d/httpd stop &> /dev/null
  killall httpd  &> /dev/null
  rm -rf /etc/init.d/httpd
  rm -rf /alidata/server/httpd
  rm -rf /alidata/server/php
  rm -rf /etc/php.ini
  rm -rf /etc/httpd
  ln -s /alidata/server/httpd-3 /etc/httpd
  ln -s /alidata/server/php-3/etc/php.ini  /etc/php.ini
  ln -s /alidata/server/httpd-3 /alidata/server/httpd
  ln -s /alidata/server/php-3  /alidata/server/php
  ln -s /etc/init.d/httpd-3 /etc/init.d/httpd
  /etc/init.d/httpd start  &> /dev/null
  /etc/init.d/httpd restart &> /dev/null
elif [ "$OPTION" = "3" ]; then
  /etc/init.d/httpd stop &> /dev/null
  killall httpd  &> /dev/null
  rm -rf /etc/init.d/httpd
  rm -rf /alidata/server/httpd
  rm -rf /alidata/server/php
  rm -rf /etc/php.ini
  rm -rf /etc/httpd
  ln -s /alidata/server/httpd-4 /etc/httpd
  ln -s /alidata/server/php-4/etc/php.ini  /etc/php.ini
  ln -s /alidata/server/httpd-4 /alidata/server/httpd
  ln -s /alidata/server/php-4  /alidata/server/php
  ln -s /etc/init.d/httpd-4 /etc/init.d/httpd
  /etc/init.d/httpd start  &> /dev/null
  /etc/init.d/httpd restart &> /dev/null
elif [ "$OPTION" = "4" ]; then        
  /etc/init.d/httpd stop &> /dev/null
  killall httpd  &> /dev/null
  rm -rf /etc/init.d/httpd
  rm -rf /alidata/server/httpd
  rm -rf /alidata/server/php
  rm -rf /etc/php.ini
  rm -rf /etc/httpd
  ln -s /alidata/server/httpd-5 /etc/httpd
  ln -s /alidata/server/php-5/etc/php.ini  /etc/php.ini
  ln -s /alidata/server/httpd-5 /alidata/server/httpd
  ln -s /alidata/server/php-5  /alidata/server/php
  ln -s /etc/init.d/httpd-5 /etc/init.d/httpd
  /etc/init.d/httpd start  &> /dev/null
  /etc/init.d/httpd restart &> /dev/null
elif [ "$OPTION" = "5" ]; then        
  /etc/init.d/httpd stop &> /dev/null
  killall httpd  &> /dev/null
  rm -rf /etc/init.d/httpd
  rm -rf /alidata/server/httpd
  rm -rf /alidata/server/php
  rm -rf /etc/php.ini
  rm -rf /etc/httpd
  ln -s /alidata/server/httpd-6 /etc/httpd
  ln -s /alidata/server/php-6/etc/php.ini  /etc/php.ini
  ln -s /alidata/server/httpd-6 /alidata/server/httpd
  ln -s /alidata/server/php-6  /alidata/server/php
  ln -s /etc/init.d/httpd-6 /etc/init.d/httpd
  /etc/init.d/httpd start  &> /dev/null
  /etc/init.d/httpd restart &> /dev/null
fi
}

message


