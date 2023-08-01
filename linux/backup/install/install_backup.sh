#!/bin/bash
wget http://sourceforge.net/p/zhuyun/svn/HEAD/tree/linux/backup/install/oss.tar.gz?format=raw -O oss.tar.gz
tar vxf oss.tar.gz
rm -rf /opt/ncscripts &> /dev/null
rm -r /usr/bin/alicmd &> /dev/null
rm -r /usr/bin/alicmd.pyc &> /dev/null
mkdir -p /opt/ncscripts &> /dev/null
mv oss /opt/ncscripts 
ln -s /opt/ncscripts/oss/alicmd.pyc  /usr/bin/alicmd.pyc
echo '#!/bin/bash' > /usr/bin/alicmd
echo 'python /usr/bin/alicmd.pyc $*' >> /usr/bin/alicmd
chmod a+x /usr/bin/alicmd
