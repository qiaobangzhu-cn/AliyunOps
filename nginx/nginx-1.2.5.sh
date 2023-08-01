#!/bin/bash

SRC_URI="http://oss.aliyuncs.com/aliyunecs/onekey/nginx/nginx-1.2.5.tar.gz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_DIR=nginx-1.2.5
PREFIX=/alidata/nginx
LOGS=$PREFIX/logs
VHOSTS=$PREFIX/conf/vhosts
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

\mv $PREFIX ${PREFIX}.bak.$DATE &> /dev/null
mkdir -p $PREFIX
mkdir -p $VHOSTS
mkdir -p /alidata/install

####---- user add ----begin####
groupadd www &> /dev/null
useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null
####---- user add ----end####
cd /alidata/install

if [ ! -s $PKG_NAME ]; then
  wget -c $SRC_URI
fi

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

######----- install ----begin######
rm -rf $PKG_NAME_DIR
tar zxvf $PKG_NAME
cd $PKG_NAME_DIR
./configure --user=www \
--group=www \
--prefix=$PREFIX \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_gzip_static_module
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
######---- install ----end######

cat > $PREFIX/conf/nginx.conf << EOF
user  www www;
worker_processes  2;

error_log  $LOGS/error.log crit;
pid        $LOGS/nginx.pid;

#Specifies the value for maximum file descriptors that can be opened by this process. 
worker_rlimit_nofile 65535;

events 
{
  use epoll;
  worker_connections 65535;
}


http {
	include       mime.types;
	default_type  application/octet-stream;

	#charset  gb2312;

	server_names_hash_bucket_size 128;
	client_header_buffer_size 32k;
	large_client_header_buffers 4 32k;
	client_max_body_size 8m;

	sendfile on;
	tcp_nopush     on;

	keepalive_timeout 60;

	tcp_nodelay on;

	fastcgi_connect_timeout 300;
	fastcgi_send_timeout 300;
	fastcgi_read_timeout 300;
	fastcgi_buffer_size 64k;
	fastcgi_buffers 4 64k;
	fastcgi_busy_buffers_size 128k;
	fastcgi_temp_file_write_size 128k;

	gzip on;
	gzip_min_length  1k;
	gzip_buffers     4 16k;
	gzip_http_version 1.0;
	gzip_comp_level 2;
	gzip_types       text/plain application/x-javascript text/css application/xml;
	gzip_vary on;
	#limit_zone  crawler  \$binary_remote_addr  10m;
	log_format '\$remote_addr - \$remote_user [\$time_local] "\$request" '
	              '\$status \$body_bytes_sent "\$http_referer" '
	              '"\$http_user_agent" "\$http_x_forwarded_for"';
	include $VHOSTS/*.conf;
}
EOF

mkdir -p /alidata/www/default
echo '<html><head><title>Welcome to nginx!</title></head><body bgcolor="white" text="black"><center><h1>Welcome to nginx!</h1></center></body></html>' > /alidata/www/default/index.html
chown www:www /alidata/www/default/index.html
cat > $VHOSTS/default.conf << EOF
server {
    listen       80 default;
    server_name  _;
	#index.php or index.jsp ???
    index index.html index.htm;
    root /alidata/www/default;
	####<<<PHP settings>>>####
	#location ~ .*\.(php|php5)?$
	#{
	#	fastcgi_pass  127.0.0.1:9000;
	#	fastcgi_index index.php;
	#	include fastcgi.conf;
	#}
	
    ####<<<Tomcat settings>>>####
    #location / {  
	#or : location ~ \.jsp\$ {
	#	proxy_pass http://server:8080;
	#	proxy_set_header        Host \$host;
	#	proxy_set_header        X-Real-IP \$remote_addr;
	#	proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    #}
	
    ####<<<Cache settings>>>####
	location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
	{
		expires 1d;
	}
	location ~ .*\.(js|css)?$
	{
		expires 1d;
	}
	####<<<The log path set>>>####
	access_log  $LOGS/default.log;
}
EOF

echo '#!/bin/bash' >> /etc/init.d/nginx
cat > /etc/init.d/nginx << EOF
# nginx Startup script for the Nginx HTTP Server
# this script create it by ruijie. at 2014.02.26
# if you find any errors on this scripts,please contact ruijie.
# and send mail to ruijie at gmail dot com.
#            ruijie.qiao@gmail.com

nginxd=$PREFIX/sbin/nginx
nginx_config=$PREFIX/conf/nginx.conf
nginx_pid=$PREFIX/logs/nginx.pid

RETVAL=0
prog="nginx"

[ -x \$nginxd ] || exit 0

# Start nginx daemons functions.
start() {
    
    if [ -e \$nginx_pid ] && netstat -tunpl | grep nginx &> /dev/null;then
        echo "nginx already running...."
        exit 1
    fi
        
    echo -n \$"Starting \$prog!"
    \$nginxd -c \${nginx_config}
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && touch /var/lock/nginx
    return \$RETVAL
}


# Stop nginx daemons functions.
stop() {
    echo -n \$"Stopping \$prog!"
    \$nginxd -s stop
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && rm -f /var/lock/nginx
}


# reload nginx service functions.
reload() {

    echo -n \$"Reloading $prog!"
    #kill -HUP \`cat \${nginx_pid}\`
    \$nginxd -s reload
    RETVAL=\$?
    echo

}

# See how we were called.
case "\$1" in
start)
        start
        ;;

stop)
        stop
        ;;

reload)
        reload
        ;;

restart)
        stop
        start
        ;;

*)
        echo \$"Usage: $prog {start|stop|restart|reload|help}"
        exit 1
esac

exit \$RETVAL
EOF
chmod 755 /etc/init.d/nginx

chown -R www:www $LOGS
chmod -R 775 /alidata/www
chown -R www:www /alidata/www
cd ..
sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' $PREFIX/conf/nginx.conf
chmod 755 $PREFIX/sbin/nginx

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:$PREFIX/sbin" &> /dev/null;then
	echo "export PATH=\$PATH:$PREFIX/sbin" >> /etc/profile
fi
source /etc/profile
#add rc.local
if ! cat /etc/rc.local | grep "/etc/init.d/nginx start" &> /dev/null;then
    echo "/etc/init.d/nginx start" >> /etc/rc.local
fi
/etc/init.d/nginx start
cd $DIR
bash