@echo off
SetLocal EnableDelayedExpansion

rem Robocopy's options
set RbcpOpt=/e /np /ns

set AdvFirewall=netsh advfirewall firewall

pushd "%~dp0"

rem Initialization
call GlobalSetting.bat

rem Add firewall rules
pushd FirewallRules
for /f "usebackq delims=" %%A in (`dir /a-d /b`) do (
	set remoteip=
	set /p description=< "%%~A"
	for /f "usebackq skip=1 eol=# delims=" %%C in (`type "%%~A"`) do set remoteip=!remoteip!,%%~C
	%AdvFirewall% add rule name="%%~nA" dir=in action=allow program="%InstallFolder%\bin\%Arch%\zabbix_agentd.exe" description="!description!" profile=any remoteip=!remoteip:~1! localport=10050 protocol=tcp
)
popd

rem Copy Uninstall script
robocopy . "%SystemDrive%\." UninstallZabbixAgent.bat /NP /NS /NJH /NJS

rem get source folder name
for /f "usebackq delims=" %%A in (`dir /ad /b`) do set SrcFld=%%~A

rem files without bin folder
robocopy "%SrcFld%" %InstallFolder% /XD bin %RbcpOpt%
rem bin folder
robocopy "%SrcFld%\bin\%Arch%" %InstallFolder%\bin\%Arch% %RbcpOpt%

rem Create log folder
md "%InstallFolder%\log"

rem install and start Windows service
cd/d %InstallFolder%\bin\%Arch%

zabbix_agentd.exe -c %InstallFolder%\conf\zabbix_agentd.win.conf -i
zabbix_agentd.exe -c %InstallFolder%\conf\zabbix_agentd.win.conf -s

popd

EndLocal
