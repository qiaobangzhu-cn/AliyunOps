#/bin/sh

# make sure this url is same with db's record
Url_CheckIP=https://ddns.oray.com/checkip

# Ip's RE, easy one
IpRE=([0-9]{1,3}\.){1,3}[0-9]{1,3}

GetIp="curl -s \"${Url_CheckIP}\" | egrep -o \"${IpRE}\""

PublicIp=$(eval ${GetIp} )

if [ $? -ne 0 ] ; then
	sleep 20
	PublicIp=$(eval ${GetIp} ) > /dev/null
	if [ $? -ne 0 ] ; then
		Return=2
		Message="Without Public IP"
	else
		Return=0
		Message=${PublicIp}
	fi
elif [ -z "${PublicIp}" ] ; then
	Return=1
	Message="Service unavailable"
else
	Return=0
	Message=${PublicIp}
fi
echo ${Message}
exit ${Return}
