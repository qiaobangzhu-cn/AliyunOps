#!/bin/bash
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

\mv /alidata/httpd /alidata/httpd.bak.$DATE &> /dev/null
mkdir -p /alidata/install
mkdir -p /alidata/www/default
cd /alidata/install
####---- user add ----begin####
groupadd www &> /dev/null
useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null
####---- user add ----end####

rm -rf httpd-2.4.9 apr-1.5.0 apr-util-1.5.3
if [ ! -s httpd-2.4.9.tar.gz ];then
  wget http://t-down.oss-cn-hangzhou.aliyuncs.com/httpd-2.4.9.tar.gz
fi
tar zxvf httpd-2.4.9.tar.gz

if [ ! -s apr-1.5.0.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/apache/apr-1.5.0.tar.gz
fi
tar -zxvf apr-1.5.0.tar.gz
cp -rf apr-1.5.0 httpd-2.4.9/srclib/apr

if [ ! -s apr-util-1.5.3.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/apache/apr-util-1.5.3.tar.gz
fi
tar -zxvf apr-util-1.5.3.tar.gz
cp -rf apr-util-1.5.3 httpd-2.4.9/srclib/apr-util

####<<<apache+tomcat settings>>> demo url: http://limingnihao.iteye.com/blog/1934548
#LoadModule proxy_module modules/mod_proxy.so
#LoadModule proxy_ajp_module modules/mod_proxy_ajp.so
#LoadModule proxy_ftp_module modules/mod_proxy_ftp.so
#LoadModule proxy_http_module modules/mod_proxy_http.so
#LoadModule proxy_connect_module modules/mod_proxy_connect.so
#LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
####---- install dependencies ----begin####
if [ "$(cat /proc/version | grep redhat)" != "" ];then
  wget http://git.jiagouyun.com/operation/operation/raw/master/linux/redhat/CentOS-Base.repo -O /etc/yum.repos.d/CentOS-Base.repo
  yum makecache
  yum -y install gcc gcc-c++ gcc-g77 make unzip automake openssl openssl-devel curl curl-devel pcre-devel
elif [ "$(cat /proc/version | grep centos)" != "" ];then
#note : The CentOS 5 series, Yum will install 32 bit packet, then filter out 32.
  if [ `uname -m` == "x86_64" ];then
	  if cat /etc/issue |grep "5\." &> /dev/null;then
		 if ! cat /etc/yum.conf |grep "exclude=\*\.i?86" &> /dev/null;then
			sed -i 's;\[main\];\[main\]\nexclude=*.i?86;' /etc/yum.conf
		 fi
		 rpm --import /etc/pki/rpm-gpg/RPM*
	  fi
  fi
  yum makecache
  yum -y install gcc gcc-c++ gcc-g77 make unzip automake openssl openssl-devel curl curl-devel pcre-devel
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
  sed -i 's/exit 0//' /etc/rc.local
  apt-get -y update
  apt-get -y install unzip libcurl4-openssl-dev libpcre3-dev
elif [ "$(cat /proc/version | grep -i debian)" != "" ];then
  apt-get -y update
  apt-get -y install unzip libcurl4-openssl-dev libpcre3-dev
fi
####---- install dependencies ----end####

####---- pcre install ----begin####
#note : Httpd version 2.4 is too high, 
#       the installation of Yum PCRE version is too low,
#       must the compiler source code!
if [ ! -f pcre-8.12.tar.gz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/pcre-8.12.tar.gz
fi
rm -rf pcre-8.12
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12
./configure
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..
####---- pcre install ----end####

cd httpd-2.4.9
./configure --prefix=/alidata/httpd \
--with-mpm=prefork \
--enable-so \
--enable-rewrite \
--enable-mods-shared=all \
--enable-nonportable-atomics=yes \
--disable-dav \
--enable-deflate \
--enable-cache \
--enable-disk-cache \
--enable-mem-cache \
--enable-file-cache \
--enable-ssl \
--with-included-apr \
--enable-modules=all  \
--enable-mods-shared=all
#--with-ssl=/usr/local/ssl \

if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cp support/apachectl /etc/init.d/httpd
chmod u+x /etc/init.d/httpd
cd ..

\cp /alidata/httpd/conf/httpd.conf /alidata/httpd/conf/httpd.conf.bak

#sed -i "s;#LoadModule rewrite_module modules/mod_rewrite.so;LoadModule rewrite_module modules/mod_rewrite.so\nLoadModule php5_module modules/libphp5.so;" /alidata/httpd/conf/httpd.conf
sed -i "s#User daemon#User www#" /alidata/httpd/conf/httpd.conf
sed -i "s#Group daemon#Group www#" /alidata/httpd/conf/httpd.conf
sed -i "s;#ServerName www.example.com:80;ServerName www.example.com:80;" /alidata/httpd/conf/httpd.conf
sed -i "s#/alidata/httpd/htdocs#/#" /alidata/httpd/conf/httpd.conf
#sed -i "s#<Directory />#<Directory \"/alidata/www\">#" /alidata/httpd/conf/httpd.conf
sed -i '/<Directory \/>/,+3 d' /alidata/httpd/conf/httpd.conf
sed -i "s#Options Indexes FollowSymLinks#Options FollowSymLinks#" /alidata/httpd/conf/httpd.conf
#sed -i "s#AllowOverride None#AllowOverride all#" /alidata/httpd/conf/httpd.conf
#sed -i "s#DirectoryIndex index.html#DirectoryIndex index.html index.htm index.php#" /alidata/httpd/conf/httpd.conf
sed -i "s;#Include conf/extra/httpd-mpm.conf;Include conf/extra/httpd-mpm.conf;" /alidata/httpd/conf/httpd.conf
sed -i "s;#Include conf/extra/httpd-vhosts.conf;Include conf/extra/httpd-vhosts.conf;" /alidata/httpd/conf/httpd.conf

echo "HostnameLookups off" >> /alidata/httpd/conf/httpd.conf
#echo "AddType application/x-httpd-php .php" >> /alidata/httpd/conf/httpd.conf

echo "Include /alidata/httpd/conf/vhosts/*.conf" > /alidata/httpd/conf/extra/httpd-vhosts.conf

mkdir -p /alidata/httpd/conf/vhosts/
cat > /alidata/httpd/conf/vhosts/default.conf << END
#ProxyRequests Off
<VirtualHost *:80>
        ServerName localhost
        ServerAlias localhost
		###<<<PHP settings>>>###
        DocumentRoot /alidata/www/default
		
		###<<<tomcat settings>>>###
		#<proxy balancer://yourProxyName>
		#	 BalancerMember http://server1:8080
		#	 BalancerMember ajp://server1:8009
		#</proxy>
        #ProxyPass /yourProject/css !
        #ProxyPass /yourProject/images !
        #ProxyPass /yourProject/js !
        #ProxyPass / balancer://yourProxyName/ stickysession=JSESSIONID nofailover=On
        #ProxyPassReverse / balancer://yourProxyName/
		
        ErrorLog "/alidata/httpd/logs/default-error.log"
        CustomLog "/alidata/httpd/logs/default.log" common
</VirtualHost>
END

#adjust httpd-mpm.conf
sed -i 's/StartServers             5/StartServers            10/g' /alidata/httpd/conf/extra/httpd-mpm.conf
sed -i 's/MinSpareServers          5/MinSpareServers         10/g' /alidata/httpd/conf/extra/httpd-mpm.conf
sed -i 's/MaxSpareServers         10/MaxSpareServers         30/g' /alidata/httpd/conf/extra/httpd-mpm.conf
sed -i 's/MaxRequestWorkers      250/MaxRequestWorkers      255/g' /alidata/httpd/conf/extra/httpd-mpm.conf

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/httpd/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/httpd/bin" >> /etc/profile
fi
source /etc/profile
#add rc.local
if ! cat /etc/rc.local | grep "/etc/init.d/httpd start" &> /dev/null;then
    echo "/etc/init.d/httpd start" >> /etc/rc.local
fi
/etc/init.d/httpd start
cd $DIR
bash
