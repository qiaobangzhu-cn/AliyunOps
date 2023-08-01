#!/bin/bash	
	amh host list 2>/dev/null;
	echo -e "\033[41m\033[37m[Warning] Please backup your data first. Uninstall will delete all the data!!! \033[0m ";
	read -p '[Notice] Backup the data now? : (y/n)' confirmBD;
	[ "$confirmBD" != 'y' -a "$confirmBD" != 'n' ] && exit;
	[ "$confirmBD" == 'y' ] && amh backup;
	echo '=============================================================';

	read -p '[Notice] Confirm Uninstall(Delete All Data)? : (y/n)' confirmUN;
	[ "$confirmUN" != 'y' ] && exit;
	amh mysql stop 2>/dev/null;
	amh php stop 2>/dev/null;
	amh nginx stop 2>/dev/null;

	killall nginx;
	killall mysqld;
	killall pure-ftpd;
	killall php-cgi;
	killall php-fpm;

	[ "$SysName" == 'centos' ] && chkconfig amh-start off || update-rc.d -f amh-start remove;
	rm -rf /etc/init.d/amh-start;
	rm -rf /usr/local/libiconv;
	rm -rf /usr/local/nginx/ ;
	for line in `ls /root/amh/modules`; do
		amh module $line uninstall;
	done;
	rm -rf /usr/local/mysql/ /etc/my.cnf  /etc/ld.so.conf.d/mysql.conf /usr/bin/mysql /var/lock/subsys/mysql /var/spool/mail/mysql;
	rm -rf /usr/local/php/ /usr/lib/php /etc/php.ini /etc/php.d /usr/local/zend;
	rm -rf /home/wwwroot/;
	rm -rf /etc/pure-ftpd.conf /etc/pam.d/ftp /usr/local/sbin/pure-ftpd /etc/pureftpd.passwd /etc/amh-iptables;
	rm -rf /etc/logrotate.d/nginx /root/.mysqlroot;
	rm -rf /root/amh /bin/amh;
	rm -rf $AMHDir;
	rm -f /usr/bin/{mysqld_safe,myisamchk,mysqldump,mysqladmin,mysql,nginx,php-fpm,phpize,php};
	rm -rf /alidata;

	echo '[OK] Successfully uninstall AMH.';
	exit;