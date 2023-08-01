#!/bin/bash
if [ `uname -m` == "x86_64" ];then
machine=x86_64
else
machine=i686
fi

#memcache
#if [ ! -f memcache-3.0.6.tgz ];then
#	wget http://oss.aliyuncs.com/aliyunecs/onekey/php_extend/memcache-3.0.6.tgz
#rm -rf memcache-3.0.6
#tar -xzvf memcache-3.0.6.tgz
#cd memcache-3.0.6
#/alidata/server/php/bin/phpize
#./configure --enable-memcache --with-php-config=/alidata/server/php/bin/php-config
#CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
#if [ $CPU_NUM -gt 1 ];then
#    make -j$CPU_NUM
#else
#    make
#fi
#make install
#cd ..
#echo "extension=memcache.so" >> /alidata/server/php/etc/php.ini

#zend
###Zend-for-php5.3-begin###
mkdir -p /alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/
if [ $machine == "x86_64" ];then
	if [ ! -f ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ];then
		wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	fi
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	mv ./ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/
else
    if [ ! -f ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz ];then
        wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	fi
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	mv ./ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/
fi
echo "zend_extension=/alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/serverphp-3/etc/php.ini 
###Zend-for-php5.3-end###  


###Zend-for-php5.4-begin###  
mkdir -p /alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100626/
if [ $machine == "x86_64" ];then
	if [ ! -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz ];then 
		wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
	fi
	tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
	mv ./ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so  /alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100626/
	
else
    if [ ! -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz ];then 
		wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
	fi
	tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
	mv ./ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100626/
fi
echo "zend_extension=/alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100626/ZendGuardLoader.so" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/server/php-4/etc/php.ini 
###Zend-for-php5.4-end###

###Zend-for-php5.5-begin###
mkdir -p /alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20100626/
if [ $machine == "x86_64" ];then
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/zend-loader-php5.5-linux-x86_64.tar.gz
	tar zxvf zend-loader-php5.5-linux-x86_64.tar.gz
	mv ./zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so /alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20100626/
else
    wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/zend-loader-php5.5-linux-i386.tar.gz
	tar zxvf zend-loader-php5.5-linux-i386.tar.gz
	mv ./zend-loader-php5.5-linux-i386/ZendGuardLoader.so /alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20100626/
fi
echo "zend_extension=/alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20100626/ZendGuardLoader.so" >> /alidata/server/php-5/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-5/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-5/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/serverphp-5/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/server/php-5/etc/php.ini 
###Zend-for-php5.5-end###

###Zend-for-php5.2-begin###
mkdir -p /alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/
if [ `uname -m` == "x86_64" ];then
  if [ ! -f ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
  fi
  tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
  mv ./ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so  /alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/
else
  if [ ! -f ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
  fi
  tar zxvf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
  mv ./ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so    /alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/
fi 

echo "[zend]" >> /alidata/server/php-2/etc/php.ini
echo "zend_optimizer.optimization_level=1023" >> /alidata/server/php-2/etc/php.ini
echo "zend_optimizer.encoder_loader=1"        >> /alidata/server/php-2/etc/php.ini
echo "zend_extension=/alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/ZendOptimizer.so" >> /alidata/server/php-2/etc/php.ini
###Zend-for-php5.2-end###




