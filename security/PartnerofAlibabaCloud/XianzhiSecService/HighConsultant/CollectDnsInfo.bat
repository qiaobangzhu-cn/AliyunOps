@echo off
SetLocal EnableDelayedExpansion

set DomainListFile1="%tmp%\DomainListFile1.txt"
set DomainListFile2="%tmp%\DomainListFile2.txt"
set DomainListFile3="%tmp%\DomainListFile3.csv"

echo.> %DomainListFile1%
echo.> %DomainListFile2%
echo Domain,RRType,RRData>%DomainListFile3%

if exist DnsServer.txt (
	for /f "usebackq delims=" %%A in ("DnsServer.txt") do (
		set DS=%%~A.
	)
)

pushd "%~dp0"

notepad %DomainListFile1%

for /f "usebackq delims=" %%A in (`type %DomainListFile1%`) do (
	rem exclude duplicate
	findstr /r /c:"^%%A$" %DomainListFile2% >nul
	if errorlevel 1 (
		echo %%A>>%DomainListFile2%
	)
)

Title Please waiting ...
echo It's due to number of domains, network and DNS.

for /f "usebackq delims=" %%A in (`type %DomainListFile2%`) do (
	call GetCname.bat %%~A %DS%
	if errorlevel 1 (
		call GetA.bat %%~A %DS%
		set Result_A=!errorlevel!
		call GetAAAA.bat %%~A %DS%
		set Result_AAAA=!errorlevel!
		set /a Result_Address=Result_A^&Result_AAAA
		if !Result_Address! EQU 1 (
			echo %%~A,-,^(May be non-existent^)>>%DomainListFile3%
		)
	)
)

rem Make use .csv is associated with EXCEL
start "" %DomainListFile3%

del %DomainListFile1% 2>nul
del %DomainListFile2% 2>nul

popd

EndLocal
