echo '###有ftp权限用户' 1>&2

CsvFileName=FtpUsers.csv
KeyWord=ftpUsers

# Header line will be added togather
#echo ${CommonHeader}${KeyWord} > ${CsvFileName}

if [ -f /etc/vsftpd/vsftpd.conf ] ; then
	ANON=`cat /etc/vsftpd/vsftpd.conf |grep anonymous_enable |grep -v "^#" |awk -F"=" '{print $2}'`
	ENABLE=`cat /etc/vsftpd/vsftpd.conf |grep userlist_enable |grep -v "^#" |awk -F"=" '{print $2}'`
	DENY=`cat /etc/vsftpd/vsftpd.conf |grep userlist_deny |grep -v "^#" |awk -F"=" '{print $2}'`
	USER_LIST=`cat /etc/vsftpd/user_list |grep -v "^#"`
	ALL_USER=`cat /etc/passwd |grep -v "^#" |awk -F":" '{print $1}'`
	NOLOGIN_USER=`cat /etc/vsftpd/ftpusers |grep -v "^#"`
	if [ $ENABLE = YES ]
	then
	    if [ -n "$DENY" ]
	    then
	        if [ $DENY = YES ]
	        then
	            ftpUsers=$(echo $ALL_USER $USER_LIST $NOLOGIN_USER |sed 's/ /\n/g' |sort |uniq -c |grep "1 " |awk '{print $2}' |tr '\n' ';' )
	        elif [ $DENY = NO ]
	        then
	            ftpUsers=$(echo $ALL_USER $NOLOGIN_USER |sed 's/ /\n/g' |sort |uniq -c |grep "1 " |awk '{print $2}' |tr '\n' ';' )
	        fi
	    else
	        ftpUsers=$(echo $ALL_USER $USER_LIST $NOLOGIN_USER |sed 's/ /\n/g' |sort |uniq -c |grep "1 " |awk '{print $2}'|tr '\n' ';' )
	    fi
	else
	ftpUsers=$(echo $ALL_USER $NOLOGIN_USER |sed 's/ /\n/g' |sort |uniq -c |grep "1 " |awk '{print $2}'|tr '\n' ';' )
	fi
else
	ftpUsers=""
fi

echo ${CommonInfo}${ftpUsers%;} >> ${CsvFileName}

mv ${CsvFileName} ../${UploadDir}/
