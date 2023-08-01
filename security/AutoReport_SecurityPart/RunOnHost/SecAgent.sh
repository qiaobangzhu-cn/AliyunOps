#!/bin/env sh

# This temp folder will be made in the same directory with $0
# And will be removed after this script done
TmpDir=AutoReport_SecurityPart_tmp
UploadFolderName=RunOnHost

if [ ${EUID} -ne 0 ] ; then
	echo "Example:" >&2
	echo -e "\t\033[31msudo\033[0m sh \"${0}\" <project_id>\n\tor\n\trun \"${0}\" as \033[31mroot\033[0m" >&2
	exit 2
fi

# get project_id
if [ -z "${1}" ] ; then
	echo "Example:" >&2
	echo -e "\tsh \"${0}\" <\033[31mproject_id\033[0m>" >&2
	exit 1
	project_id=MissingProjectId
else
	project_id=${1}
fi
export project_id

HOSTNAME=$(hostname)
export HOSTNAME

# Get date info

export CurYear=$(date "+%Y")
export CurMonth=$(date "+%m")

if [ ${CurMonth} -eq 01 ] ; then
	ChkYear=$(expr ${CurYear} - 1)
	ChkMonth=12
else
	ChkYear=${CurYear}
	ChkMonth=$(expr ${CurMonth} - 1)
fi

export ChkYear
export ChkMonthNum=$(date -d "${ChkYear}-${ChkMonth}-1" "+%m" )
export ChkMonthAbbr=$(date -d "${ChkYear}-${ChkMonth}-1" "+%b" )

# change dir
cd $(dirname ${0} )

# md upload folder

export UploadDir=${project_id}_${HOSTNAME}
mkdir -p ${TmpDir}/${UploadDir}

# clear old pack
rm -f ${UploadDir}.tar

cd ${TmpDir}/${project_id}_${HOSTNAME}

mkdir -p "firewalls" "urls" "vulnerability" "logs/log_boot" "logs/Log_cron"

# extract scripts
cd ..
if [ ! -d ${UploadFolderName}/ ] ; then
	mkdir ${UploadFolderName}
	cd ${UploadFolderName}
	tar xf ../../${UploadFolderName}.tar
else
	cd ${UploadFolderName}
fi

# exe script
sh GetSecInfo.sh ${project_id}

cd ..

# pack ${UploadDir} and vul info file

tar -cf ../${UploadDir}.tar ${UploadDir} ${project_id}_*.csv

cd ..

rm -rf ${UploadFolderName}.tar ${TmpDir}/
rm -f "$0"
