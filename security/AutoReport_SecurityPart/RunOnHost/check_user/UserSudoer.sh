echo '###有sudo权限用户' 1>&2

CsvFileName=UserSudoer.csv
KeyWord=sudoUsers

# Header line will be added togather
#echo ${CommonHeader}${KeyWord} > ${CsvFileName}

USER=`cat /etc/sudoers |grep -v "^#" |grep -v Defaults|grep -v "^$" |awk '{print $1}'|grep -v "^%" |sort |uniq`
GROUPUSER=`cat /etc/sudoers |grep -v "^#" |grep -v Defaults|grep -v "^$" |awk '{print $1}'|grep "^%" |sort |uniq|awk -F"%" '{print $2}'`
USER_WHEEL=`cat /etc/group |grep "$GROUPUSER" |awk -F":" '{print $4}'`
sudoUsers=$(echo $USER $USER_WHEEL |sed 's/ /\n/g' |sed 's/,/\n/g'|sort -u|tr '\n' ';' )

echo ${CommonInfo}${sudoUsers%;} >> ${CsvFileName}

mv ${CsvFileName} ../${UploadDir}/
