@echo off
SetLocal EnableDelayedExpansion

path ..\..\WinRAR\PackageScpIntoRarSFX;%path%

rem You can custom your own name.
rem set "BinaryName" as Env variable

rem Default binary file name
set DefaultBinaryName=WinRARSFX

if "%~1"=="" (
	set SourceFolder=Source
) else set SourceFolder=%~1
if "%SourceFolder:~-1%=\"=="\" set SourceFolder=%SourceFolder:~0,-1%

set SfxIconFilename=%SourceFolder%\ZabbixIcon.ico

if not defined SfxIconFilename set SfxIconFilename=%SourceFolder%\SfxIconFilename.ico
rem if not defined SfxImgFilename set SfxImgFilename=%SourceFolder%\SfxImgFilename.bmp

if NOT DEFINED DebugLevel SET DebugLevel=0

set NumberOfFolder=0
set Folder=%~dp0

rem output folder
set BinaryFolder=%Folder%Binary
md "%BinaryFolder%" 2>nul

if NOT defined MoveOverwrite set MoveOverwrite=/-Y

if NOT defined BinaryName (
	for /f "usebackq delims=" %%A in (`dir /ad /b "%SourceFolder%"`) do (
		set /a NumberOfFolder+=1
	)
	if !NumberOfFolder! equ 1 (
		for /f "usebackq delims=" %%A in (`dir /ad /b "%SourceFolder%"`) do set AppName=%%~nA
		set BinaryName=!AppName!
	) else set BinaryName=%DefaultBinaryName%
)

pushd "%Folder%"

echo Build version choice:
echo --------------------------------
dir /ad /b source\zabbix_agent_autoinstall
echo.

set/p AgtVer=Input which VERSION do you want to install ^( the newest one will be used if directly ENTER, OR input like 3.2.0 ^):
if NOT DEFINED AgtVer (
	for /f "usebackq delims=" %%A in (`dir /ad /b source\zabbix_agent_autoinstall`) do set AgtChosen=%%~A
) else (
	set AgtChosen=zabbix_agents_%AgtVer%.win
	set BinaryName=%BinaryName%_%AgtVer%
)

if NOT exist "%SourceFolder%\%AppName%\%AgtChosen%" (
	echo.
	echo Your choice is INVALID.
	timeout 5
	goto :Leave
)

del/a/f/q "%BinaryName%" 2>nul

call Get_WinRAR_Path.bat

rem Exclude main folder from filename
set RAR=%RAR% -ep1
rem Request adm privilege when execution
set RAR=%RAR% -iadm
rem background
set RAR=%RAR% -iBCK
rem Custom SFX file's icon
if defined SfxIconFilename set RAR=%RAR% -iicon"%SfxIconFilename%" -x"%SfxIconFilename%"
rem Custom SFX dialogue image
if defined SfxImgFilename (
	set RAR=%RAR% -iimg"%SfxImgFilename%" -x"%SfxImgFilename%"
) else set RAR=%RAR% -x"%SourceFolder%\SfxImgFilename.bmp"
rem Create RAR 5 format
set RAR=%RAR% -ma5
rem Compression level
set RAR=%RAR% -m5
rem Dictionary size
set RAR=%RAR% -md128m
rem Recursive
set RAR=%RAR% -r
rem Solid
set RAR=%RAR% -s
rem Set sfx module
set RAR=%RAR% -sfxDefault.SFX
rem Apply comment from file
set RAR=%RAR% -z"%~dp0SFXcomments.txt"

if %DebugLevel% gtr 0 echo %RAR%

rem Create Uninstall script
set Uninstallscript="%tmp%\UninstallZabbixAgent.bat"
echo @echo off> %Uninstallscript%
echo SetLocal>> %Uninstallscript%
echo.>> %Uninstallscript%
type source\zabbix_agent_autoinstall\GlobalSetting.bat>> %Uninstallscript%
echo.>> %Uninstallscript%
type source\UninstallZabbixAgent_LastPart.bat>> %Uninstallscript%

rem The variable "RAR" will be used in WinRAR.exe
"%Path_WinRAR%WinRAR.exe" a -ap"%AppName%" "%BinaryName%" "%SourceFolder%\%AppName%\Main.bat" "%SourceFolder%\%AppName%\FirewallRules" "%SourceFolder%\%AppName%\GlobalSetting.bat" %Uninstallscript% "%SourceFolder%\%AppName%\%AgtChosen%"
"%Path_WinRAR%WinRAR.exe" a "%BinaryName%" "%SourceFolder%\RarSfxAgent.bat"
"%Path_WinRAR%WinRAR.exe" a -ap"%AppName%\%AgtChosen%" "%BinaryName%" "%SourceFolder%\%AppName%\GetValidConfig.bat"

move %MoveOverwrite% "%BinaryName%.exe" "%BinaryFolder%""

:Leave
popd

del /a /f /q %Uninstallscript% 2>nul

EndLocal
