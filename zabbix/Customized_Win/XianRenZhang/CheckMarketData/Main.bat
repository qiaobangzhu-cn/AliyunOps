@echo off
SetLocal EnableDelayedExpansion

rem This folder is parent folder of daily data.
set DataFolder=C:\Users\Public\Documents\Sync\DataFolder

rem set OutputStr={"data":[{"{#CheckResult}":"^!CheckResult^!"}]}

rem Prefix of data files
set Prefix=SH_ SZ_
rem set Prefix=SH_

rem 500KiB
set FileSizeLimit=512000
rem set FileSizeLimit=912000

set WD=%~dp0
set HolidayTalbleFolder=%WD%
set RuleFolder=%WD%

set WorkdayKeyword=Special Working Day

set IsWorkday=1

rem '1' means normal
set CheckResult=1

rem ---Date---

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Year /value^|find /i "Year"`) do set %%~A

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Month /value^|find /i "Month"`) do set %%~A
if %Month% lss 10 set Month=0%Month%

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Day /value^|find /i "Day"`) do set %%~A
if %Day% lss 10 set Day=0%Day%

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get DayOfWeek /value^|find /i "DayOfWeek"`) do set %%~A

set DATE_WIN=%Year%%Month%%Day%
rem set DATE_WIN=20170912

set HolidayTalble="%HolidayTalbleFolder%HolidaysChina%Year%.csv"

type %HolidayTalble%|find "%DATE_WIN%," >nul
if errorlevel 1 (
	if %DayOfWeek% equ 0 set IsWorkday=0
	if %DayOfWeek% equ 6 set IsWorkday=0
) else if errorlevel 0 (
	for /f "usebackq delims=, tokens=3" %%C in (`type %HolidayTalble%^|find "%DATE_WIN%,"`) do (
		if /I NOT "%%~C"=="%WorkdayKeyword%" set IsWorkday=0
	)
)

if %IsWorkday% equ 0 exit/b 1

rem ---Time---

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Hour /value^|find /i "Hour"`) do set %%~A
rem set Hour=9
if %Hour% neq 9 exit /b 2

for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Minute /value^|find /i "Minute"`) do set %%~A
rem set Minute=0
if %Minute% GTR 25 exit /b 3

rem for /f "usebackq delims=" %%A in (`wmic path Win32_LocalTime get Second /value^|find /i "Second"`) do set %%~A

pushd "%DataFolder%"

rem This folder will be created by a local program
cd "%DATE_WIN%"

for %%A in (%Prefix%) do (
	set NumOfFiles=0
	set FileSizeCheck=1
	set NumOfFilesCheck=1
	for /f "usebackq delims=" %%D in (`dir/B %%A%DATE_WIN%*.DBF 2^>nul`) do (
		set/a NumOfFiles+=1
		if %%~zD lss %FileSizeLimit% set FileSizeCheck=0
	)
	for /f "usebackq delims=, tokens=2" %%G in (`type "%RuleFolder%Rule_NumberOfFiles.csv"^|findstr /r /c:"^%Minute%,"`) do (
		if !NumOfFiles! lss %%G set NumOfFilesCheck=0
	)
	set /A MarketCheck=!FileSizeCheck!^&!NumOfFilesCheck!
	rem echo %%AMarketCheck=!MarketCheck!
	if !MarketCheck! neq 1 set CheckResult=0
)

echo %CheckResult%

popd

EndLocal
goto :EOF
