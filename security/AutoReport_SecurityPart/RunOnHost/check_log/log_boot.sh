#!/bin/env sh

CsvFileName=Log_boot.csv
KeyWord=log_boot

# Header line will be added togather
#echo ${CommonHeader}${KeyWord} > ${CsvFileName}

# check tmp file later
log_boot=FALSE

echo ${CommonInfo}${log_boot%;} >> ${CsvFileName}

mv ${CsvFileName} ../${UploadDir}/
