echo '###有远程shell权限用户' 1>&2
cat /etc/passwd |grep "/bin/bash" |grep -v "^#" |awk -F":" '{print $1}'|tr '\n' ';'
