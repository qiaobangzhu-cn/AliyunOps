pushd "%InstallFolder%\bin\%Arch%"

rem Stop Zabbix agent service
zabbix_agentd.exe -x -c %InstallFolder%\conf\zabbix_agentd.win.conf

rem Uninstall Zabbix agent from service
timeout 2
zabbix_agentd.exe -d
popd
rd/s/q "%InstallFolder%"

rem Delete firewall rules
netsh adv fir delete rule name=all program="%InstallFolder%\bin\%Arch%\zabbix_agentd.exe"

del /a /f /q "%~0" 2>nul
