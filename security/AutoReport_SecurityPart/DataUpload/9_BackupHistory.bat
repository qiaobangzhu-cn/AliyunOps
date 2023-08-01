@echo off
SetLocal

pushd "%~dp0"

set Y=%date:~0,4%
set M=%date:~5,2%


move ReportSecurity.zip ReportSecurity_History\ReportSecurity_%Y%%M%.zip
rem move ReportSecurity ReportSecurity_History\ReportSecurity_%Y%%M%

md ReportSecurity 2> nul

popd
pause
