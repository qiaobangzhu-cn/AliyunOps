@echo off
setlocal EnableDelayedExpansion

set PackName=ReportSecurity.zip
set exclude=-x*.zip -x*.rar -x*.tar -x*.tgz

pushd "%~dp0"

call Get_WinRAR_Path

path %WinRAR_Path%;%PATH%

del /a /f /q %PackName% 2>nul

dir /ad /b Dealed |findstr /r /c:"." > nul
if not errorlevel 1 (
	winrar a -apReportSecurity -ep1 -r %exclude% %PackName% Dealed\*
)

winrar a %exclude% %PackName% ReportSecurity

popd
