@echo off
SetLocal

rem For standalone
if NOT defined Year set Year=%1
if NOT defined Month set Month=%2
if NOT defined Day set Day=%3
if not defined UploadDir set UploadDir=.

if "%Month:~0,1%"=="0" set Month=%Month:~1%
if "%Day:~0,1%"=="0" set Day=%Day:~1%

if %Day% lss 11 (
	if %Month% equ 1 (
		set Month=12
		set /a Year-=1
	) else (
		set /a Month-=1
	)
)

pushd "%UploadDir%"

wmic /output:qfe_tmp.csv qfe where "installedon like '%Month%/%%/%Year%'" get Caption,CSName,Description,HotFixId,InstalledBy,InstalledOn /format:csv 2>nul

rem Empty or not
for /f %%A in ("qfe_tmp.csv") do if %%~zA lss 17 (
	del /a /f /q qfe_tmp.csv
	popd
	exit/b
)

rem remove first line
for /f "usebackq skip=1 delims=" %%A in (`type qfe_tmp.csv`) do (
	echo %%A>> qfe_tmp2.csv
)

rem project_id,COMPUTERNAME,ETH0,ETH1,HotFixID,Description,Caption,InstalledBy,InstalledOn
logparser -q:on -i:csv -o:csv "select '%project_id%' as project_id,'%COMPUTERNAME%' as COMPUTERNAME,'%ETH0%' as ETH0,'%ETH1%' as ETH1,HotFixId,Description,Caption,InstalledBy,InstalledOn into qfe_tmp3.csv from qfe_tmp2.csv order by InstalledOn"

rem remove header line
for /f "usebackq skip=1 delims=" %%A in (`type qfe_tmp3.csv`) do (
	echo %%A>> WindowsQuickFix.csv
)

del /a /f /q qfe_tmp*.csv
popd
Endlocal
