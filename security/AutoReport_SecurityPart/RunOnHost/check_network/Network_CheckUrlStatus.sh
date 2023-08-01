#/bin/sh

CsvFileName=CheckUrlStatus.csv
KeyWord=url,result

# Header line will be added togather
#echo ${CommonHeader}${KeyWord} > ${CsvFileName}

subfunc(){
	url=$1
	result=$(curl -Is --connect-timeout 10 --retry 1 ${url} |egrep "^HTTP"|tail -1 )
	if [ $? -ne 0 ] ; then
		echo ${result}
		result=FAILED
	fi
	echo ${CommonInfo}${url},${result} >> ${CsvFileName}
}

subfunc "https://www.aliyun.com/"
subfunc "https://cloudcare.cn/"
subfunc "https://ddns.oray.com/checkip"

mv ${CsvFileName} ../${UploadDir}/urls/
