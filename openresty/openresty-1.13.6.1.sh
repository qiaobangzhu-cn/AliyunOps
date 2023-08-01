#!/bin/bash
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/openresty/openresty-1.13.6.1/openresty-1.13.6.1.tar.gz" 
SRC_URI_WAF="http://zy-res.oss-cn-hangzhou.aliyuncs.com/openresty/openresty-1.13.6.1/waf.tgz"
PKG_NAME=`basename $SRC_URI`
PKG_NAME_WAF=`basename $SRC_URI_WAF`
PKG_NAME_DIR=openresty-1.13.6.1
PKG_NAME_WAF_DIR=waf
PREFIX=/alidata/openresty
LOGS=$PREFIX/nginx/logs
VHOSTS=$PREFIX/nginx/conf/vhosts
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

\mv $PREFIX $PREFIX.bak.$DATE &> /dev/null
mkdir -p $PREFIX
mkdir -p $VHOSTS
mkdir -p /alidata/install

groupadd www &> /dev/null
useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null

cd /alidata/install
if [ ! -s $PKG_NAME ]; then
    wget -c $SRC_URI
fi

if [ "$(cat /proc/version | grep centos)" != "" ];then
    yum makecache
    yum -y install readline-devel pcre-devel openssl-devel gcc
elif [ "$(cat /proc/version | grep ubuntu)" != "" ];then
    apt-get -y update
    apt-get -y install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential
fi

rm -rf $PKG_NAME_DIR
tar xvf $PKG_NAME
cd $PKG_NAME_DIR

./configure --prefix=$PREFIX --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-stream 

if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install

cat > $PREFIX/nginx/conf/nginx.conf << EOF
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
	lua_shared_dict limit 50m;
    	lua_package_path "/alidata/openresty/nginx/conf/waf/?.lua";
    	init_by_lua_file "/alidata/openresty/nginx/conf/waf/init.lua";
    	access_by_lua_file "/alidata/openresty/nginx/conf/waf/access.lua";
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

cd /alidata/install
if [ ! -s $PKG_NAME_WAF ]; then
    wget -c $SRC_URI_WAF
fi
rm -rf $PKG_NAME_WAF_DIR
tar zxvf $PKG_NAME_WAF
cp -a ./waf $PREFIX/nginx/conf/

cat > $PREFIX/nginx/conf/waf/config.lua << EOF
--WAF config file,enable = "on",disable = "off"

--waf status
config_waf_enable = "on"
--log dir
config_log_dir = "/tmp"
--rule setting
config_rule_dir = "/alidata/openresty/nginx/conf/waf/rule-config"
--enable/disable white url
config_white_url_check = "on"
--enable/disable white ip
config_white_ip_check = "on"
--enable/disable block ip
config_black_ip_check = "on"
--enable/disable url filtering
config_url_check = "on"
--enalbe/disable url args filtering
config_url_args_check = "on"
--enable/disable user agent filtering
config_user_agent_check = "on"
--enable/disable cookie deny filtering
config_cookie_check = "on"
--enable/disable cc filtering
config_cc_check = "on"
--cc rate the xxx of xxx seconds
config_cc_rate = "10/60"
--enable/disable post filtering
config_post_check = "on"
--config waf output redirect/html
config_waf_output = "url"
--if config_waf_output ,setting url
config_waf_redirect_url = "www.cloudcare.cn"
config_output_html=[[
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="zh-cn" />
<title>网站防火墙</title>
</head>
<body>
<h1 align="center"> 被拦截。
</body>
</html>
]]
EOF



echo '#!/bin/bash' >> /etc/init.d/nginx
cat > /etc/init.d/nginx << EOF
nginxd=$PREFIX/nginx/sbin/nginx
nginx_config=$PREFIX/nginx/conf/nginx.conf
nginx_pid=$PREFIX/nginx/logs/nginx.pid

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
sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' $PREFIX/nginx/conf/nginx.conf
chmod 755 $PREFIX/nginx/sbin/nginx

if ! cat /etc/profile | grep "export PATH=\$PATH:$PREFIX/nginx/sbin" &> /dev/null;then
	echo "export PATH=\$PATH:$PREFIX/nginx/sbin" >> /etc/profile
fi
source /etc/profile
if ! cat /etc/rc.local | grep "/etc/init.d/nginx start" &> /dev/null;then
    echo "/etc/init.d/nginx start" >> /etc/rc.local
fi
/etc/init.d/nginx start
cd $DIR
bash
