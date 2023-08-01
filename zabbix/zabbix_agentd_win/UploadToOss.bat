@echo off
SetLocal
rem This script depend on 'ossutil' which could be download from https://help.aliyun.com/document_detail/50452.html.

rem To use 'ossutil', you need config proper credential.

rem You need WRITE access to specified bucket to upload objects.

set src_url=Binary
set dst_url=oss://zy-res/zabbix/zabbix_agentd_win/

rem You should edit env PATH if your ossutil is NOT in the following folders.
if exist "%ProgramFiles%\ossutil64\ossutil64.exe" (
	Path %ProgramFiles%\ossutil64;%Path%
	set ossutil=ossutil64
) else if exist "%ProgramFiles(x86)%\ossutil32\ossutil32.exe" (
	rem WOW64
	Path "%ProgramFiles(x86)%"\ossutil32;%Path%
	set ossutil=ossutil32
) else if exist "%ProgramFiles%\ossutil32\ossutil32.exe" (
	rem i386
	Path %ProgramFiles%\ossutil32;%Path%
	set ossutil=ossutil32
) else (
	where ossutil64 2>nul
	if errorlevel 1 (
		where ossutil32 2>nul
		if errorlevel 1 (
			echo Ossutil can NOT be found.
			timeout 60
			exit/b
		) else if errorlevel 0 set ossutil=ossutil32
	) else if errorlevel 0 set ossutil=ossutil64
)

choice /t 5 /d n /m "Do you want to enable FORCE Replacement?"
if errorlevel 2 set Update=--update

pushd "%~dp0"

%ossutil% cp %src_url% %dst_url% --recursive %Update% --force

popd

timeout 60
