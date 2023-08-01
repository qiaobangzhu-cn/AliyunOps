#!/bin/bash
#zend
###Zend-for-php5.3-begin###
mkdir -p /alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/
if [ ! -f ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ];then
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
fi
tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
mv ./ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/
echo "zend_extension=/alidata/server/php-3/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/server/php-3/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/serverphp-3/etc/php.ini 
###Zend-for-php5.3-end###  


###Zend-for-php5.4-begin###  
#mkdir -p /alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100626/
mkdir -p /alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100525/
if [ ! -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz ];then 
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
fi
tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
mv ./ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so  /alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100525/
echo "zend_extension=/alidata/server/php-4/lib/php/extensions/no-debug-non-zts-20100525/ZendGuardLoader.so" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/server/php-4/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/server/php-4/etc/php.ini 
###Zend-for-php5.4-end###

###Zend-for-php5.5-begin###
#mkdir -p /alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20100626/
mkdir -p /alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20121212/
if [ ! -f zend-loader-php5.5-linux-x86_64.tar.gz ];then
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/zend-loader-php5.5-linux-x86_64.tar.gz
fi	
tar zxvf zend-loader-php5.5-linux-x86_64.tar.gz
mv ./zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so /alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20121212/

echo "zend_extension=/alidata/server/php-5/lib/php/extensions/no-debug-non-zts-20121212/ZendGuardLoader.so" >> /alidata/server/php-5/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-5/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-5/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/serverphp-5/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/server/php-5/etc/php.ini 
###Zend-for-php5.5-end###

###Zend-for-php5.6-begin###
mkdir -p /alidata/server/php-6/lib/php/extensions/no-debug-non-zts-20121212/
if [ ! -f zend-loader-php5.6-linux-x86_64.tar.gz ];then
	wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php/zend/zend-loader-php5.6-linux-x86_64.tar.gz
fi	
tar zxvf zend-loader-php5.6-linux-x86_64.tar.gz
mv ./zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so /alidata/server/php-6/lib/php/extensions/no-debug-non-zts-20121212/

echo "zend_extension=/alidata/server/php-6/lib/php/extensions/no-debug-non-zts-20121212/ZendGuardLoader.so" >> /alidata/server/php-6/etc/php.ini
echo "zend_loader.enable=1" >> /alidata/server/php-6/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /alidata/server/php-6/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /alidata/serverphp-6/etc/php.ini
echo "zend_loader.license_path=" >> /alidata/server/php-6/etc/php.ini 
###Zend-for-php5.6-end###

###Zend-for-php5.2-begin###
mkdir -p /alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/
if [ ! -f ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ];then
  wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/php-5.2/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
fi
tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
mv ./ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so  /alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/

echo "[zend]" >> /alidata/server/php-2/etc/php.ini
echo "zend_optimizer.optimization_level=1023" >> /alidata/server/php-2/etc/php.ini
echo "zend_optimizer.encoder_loader=1"        >> /alidata/server/php-2/etc/php.ini
echo "zend_extension=/alidata/server/php-2/lib/php/extensions/no-debug-non-zts-20090626/ZendOptimizer.so" >> /alidata/server/php-2/etc/php.ini
###Zend-for-php5.2-end###




