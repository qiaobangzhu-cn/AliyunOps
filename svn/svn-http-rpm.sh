#!/bin/bash
TMP=true
while ${TMP}
    do
    echo "1: svnserver 1.7"
    echo "2: svnserver 1.8"
    echo "3: svnserver 1.9"
    read -p "Please choose your country: " i
    case "$i" in
      1)
      echo "Install svnserver 1.7,plasea wait...."
      VERSION=1.7
      TMP=false;;
      2)
      echo "Install svnserver 1.8,plasea wait...."
      VERSION=1.8
      TMP=false;;
      3)
      echo "Install svnserver 1.9,plasea wait...."
      VERSION=1.9
      TMP=false;;
      *)
      echo "Please choose version"
      ;;
    esac
done
#add yum
echo "
[WandiscoSVN]
name=Wandisco SVN Repo
baseurl=http://opensource.wandisco.com/centos/6/svn-${VERSION}/RPMS/$basearch/
enabled=1
gpgcheck=0
" > /etc/yum.repos.d/wandisco-svn.repo

#install svn httpd
yum clean all
yum install subversion httpd mod_dav_svn -y

#configure snv and http
mv /etc/httpd/conf.d/subversion.conf /etc/httpd/conf.d/subversion.conf.old
echo "
# WANdisco Subversion Configuration
# For more information on HTTPD configuration options for Subversion please see:
# http://svnbook.red-bean.com/nightly/en/svn.serverconfig.httpd.html
# Please remember that when using webdav HTTPD needs read and write access your repositories.

# Needed to do Subversion Apache server.
LoadModule dav_svn_module     modules/mod_dav_svn.so
# Only needed if you decide to do "per-directory" access control.
LoadModule authz_svn_module   modules/mod_authz_svn.so

<Location /svn>
  DAV svn
  SVNParentPath /home/svn/
  AuthType Basic
  AuthName \"SVN Repo\"
  AuthUserFile /etc/httpd/conf.d/passwd
  AuthzSVNAccessFile /etc/httpd/conf.d/authz
  Require valid-user
</Location>
" > /etc/httpd/conf.d/subversion.conf

echo "
### This file is an example authorization file for svnserve.
### Its format is identical to that of mod_authz_svn authorization
### files.
### As shown below each section defines authorizations for the path and
### (optional) repository specified by the section name.
### The authorizations follow. An authorization line can refer to:
###  - a single user,
###  - a group of users defined in a special [groups] section,
###  - an alias defined in a special [aliases] section,
###  - all authenticated users, using the '$authenticated' token,
###  - only anonymous users, using the '$anonymous' token,
###  - anyone, using the '*' wildcard.
###
### A match can be inverted by prefixing the rule with '~'. Rules can
### grant read ('r') access, read-write ('rw') access, or no access
### ('').

[aliases]
# joe = /C=XZ/ST=Dessert/L=Snake City/O=Snake Oil, Ltd./OU=Research Institute/CN=Joe Average

[groups]
# harry_and_sally = harry,sally
# harry_sally_and_joe = harry,sally,&joe
[project:/]
svnuser = rw
* =
# [/foo/bar]
# harry = rw
# &joe = r
# * =

# [repository:/baz/fuz]
# @harry_and_sally = rw
# * = r
" > /etc/httpd/conf.d/authz

mkdir /home/svn && svnadmin create /home/svn/project && chown -R apache:apache /home/svn

#add svn user
htpasswd -bc /etc/httpd/conf.d/passwd svnuser 12344321
/etc/init.d/httpd start
svnserve -d -r /home/svn/

echo "http://ip/svn/project    user:svnuser passwd:12344321
please stop iptables or open 3690 and 80
svn passwd file in /etc/httpd/conf.d/passwd
add svnuser use command \"htpasswd -b /etc/httpd/conf.d/passwd svnusername password\"" > svnserverinstall.log
cat svnserverinstall.log