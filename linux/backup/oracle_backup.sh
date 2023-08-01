#!/bin/bash
########################
#使用说明：
#[oracle@oracle01 ~]$bash backupscript.sh  $ORACLE_SID
#执行backupscript.sh 带上oracle_sid
#生成 crontab 命令
#在/alidata/oracle/backup/ 目录下生成 scripts 文件夹，命令与cmdfile文件都在其中
#备份文件存放在 /alidata/oracle/backup/ 目录下
#在linux下必须使用Oracle用户执行
###############################
mkdir -p /alidata/oracle/backup/scripts
cd /alidata/oracle/backup/scripts
id | grep 'oracle'
if [ $? -ne 0 ];then
    echo "Please switch to oracle users to perform"
    exit 1
else
cat >> inc0.rman << "EOF"
run {
 crosscheck archivelog all;
 delete noprompt expired archivelog all;
 allocate channel ch1 type disk;
 delete noprompt obsolete recovery window of 7 days;
 release channel ch1;
 allocate channel ch1 type disk;
 allocate channel ch2 type disk;
 set limit channel ch1 readrate =10240;
 set limit channel ch1 kbytes=4096000;    
 set limit channel ch2 readrate =10240;
 set limit channel ch2 kbytes=4096000;
 backup as compressed backupset incremental level 0 database format='/alidata/oracle/backup/inc0_%d_%U' tag='inc0';
 sql"alter system archive log current";
 backup as compressed backupset  format='/alidata/oracle/backup/arch_%d_%U' tag='bkarch' archivelog all delete input;
 backup as compressed backupset current controlfile reuse format='/alidata/oracle/backup/backupctl_%d_%U' tag='bkctl';
 release channel ch1;
 release channel ch2;
}
EOF

cat >> inc1.rman <<"EOF"
run {
crosscheck archivelog all;
delete noprompt expired archivelog all;
allocate channel ch1 type disk;
delete noprompt obsolete recovery window of 7 days;
release channel ch1;
allocate channel ch1 type disk;
allocate channel ch2 type disk;
set limit channel ch1 readrate=10240;
set limit channel ch1 kbytes=4096000;
set limit channel ch2 readrate=10240;
set limit channel ch2 kbytes=4096000;
backup as compressed backupset incremental level 1 database format='/alidata/oracle/backup/inc1_%d_%U' tag='inc1';
sql "alter system archive log current";
backup as compressed backupset format='/alidata/oracle/backup/arch_%d_%U' tag='bkarch' archivelog all delete input;
release channel ch1;
release channel ch2;
allocate channel ch1 device type disk;
backup as compressed backupset current controlfile reuse format='/alidata/oracle/backup/backupctl.ctl' tag='bkctl';
release channel ch1;
}
EOF

cat >> inc2.rman <<"EOF"
run{
crosscheck archivelog all;
delete noprompt expired archivelog all;
allocate channel ch1 device type disk;
delete noprompt obsolete recovery window of 7 days;
release channel ch1;
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
set limit channel ch1 readrate=10240;
set limit channel ch1 kbytes=4096000;
set limit channel ch2 readrate=10240;
set limit channel ch2 kbytes=4096000;
backup as compressed backupset incremental level 2 database format='/alidata/oracle/backup/inc2_%d_%U' tag='inc2';
sql "alter system archive log current";
backup as compressed backupset format='/alidata/oracle/backup/arch_%d_%U' tag='bkarch' archivelog all delete input;
release channel ch1;
release channel ch2;
allocate channel ch1 device type disk;
backup as compressed backupset current controlfile reuse format='/alidata/oracle/backup/backupctl.ctl' tag='bkctl';
release channel ch1;
}
EOF
for i in {0,1,2}
do
	rm -f inc${i}.sh
	for value in $@
	do
		echo "export ORACLE_SID=${value}" >> inc${i}.sh
                echo ":>/alidata/oracle/backup/scripts/inc${value}.log" >> /alidata/oracle/backup/scripts/inc${i}.sh
		echo "$ORACLE_HOME/bin/rman target / cmdfile=/alidata/oracle/backup/scripts/inc${i}.rman log=/alidata/oracle/backup/scripts/inc${value}.log " >> /alidata/oracle/backup/scripts/inc${i}.sh
	done
done
chmod +x *.sh

:> /tmp/crontab.$$
echo "0 0 * * 0 /alidata/oracle/backup/scripts/inc0.sh">> /tmp/crontab.$$
echo "0 0 * * 4 /alidata/oracle/backup/scripts/inc1.sh">> /tmp/crontab.$$
echo "0 0 * * 1,2,3,5,6 /alidata/oracle/backup/scripts/inc2.sh">> /tmp/crontab.$$
crontab /tmp/crontab.$$
\rm /tmp/crontab.$$
fi
