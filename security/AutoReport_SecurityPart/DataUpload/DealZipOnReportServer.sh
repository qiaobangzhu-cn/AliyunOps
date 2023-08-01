#!/usr/bin/env bash

# run this script as zyadmin

TEMP=/tmp

cd $(dirname $0)

LogFile="./$(basename -s .sh $0).log"

[ -f ReportSecurity.txt ]||exit 1

date>>"${LogFile}"

rm -fr ${TEMP}/ReportSecurity/
unzip -q ReportSecurity.zip -d ${TEMP}
rm -f ReportSecurity.zip ReportSecurity.txt

# get 2 dates
last_date=$(date -d "$(date +%Y-%m)-01 -2 month" +%F)
this_date=$(date -d "$(date +%Y-%m)-01 -1 month" +%F)

sudo sed -i "s/${last_date}/${this_date}/g" "/root/DevOps-Report-Back-end/update_data_security.py"
sudo python "/root/DevOps-Report-Back-end/update_data_security.py"
