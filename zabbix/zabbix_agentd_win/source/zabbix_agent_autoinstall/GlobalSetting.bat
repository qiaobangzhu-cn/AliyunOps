rem Destination folder name
set InstallFolder=C:\zabbix_agents.win

rem decide architecture
if Defined ProgramFiles(x86) (
	set Arch=win64
) else set Arch=win32
