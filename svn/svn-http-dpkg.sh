#!/bin/bash
SVN_PASS=$(date | md5sum |head -c 10)
apt-get update -y
apt-get install subversion apache2 apache2-utils libapache2-svn -y
mkdir -p /alidata/svn && cd /alidata/svn && svnserve -d -r /alidata/svn && svnadmin create project
cat >> /etc/apache2/mods-available/dav_svn.conf << EOF
<Location /svn>
	DAV svn
	SVNPath /alidata/svn/project
	AuthType Basic
	AuthName "svn for project"
	AuthUserFile /alidata/svn/project/conf/password
	AuthzSVNAccessFile /alidata/svn/project/conf/authzapache
	Satisfy all
	Require valid-user
</Location>
EOF
htpasswd -bc /alidata/svn/project/conf/password admin $SVN_PASS
echo "[/]
admin = rw" >> /alidata/svn/project/conf/authzapache
chown -R www-data:www-data /alidata/svn
/etc/init.d/apache2 restart
cd
echo "---------- svn && http install ok ----------"
echo "svn user: admin       svn password:$SVN_PASS"
bash