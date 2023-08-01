@echo off
SetLocal

rem Exclude Obj setting

rem package script itself
rem set ExcludeObj=%ExcludeObj% -xr-!"%~nx0"
rem Main script
set ExcludeObj=%ExcludeObj% -xr-!"SecAgent.sh"
rem git files
set ExcludeObj=%ExcludeObj% -xr!.gitignore
set ExcludeObj=%ExcludeObj% -xr!README.md
rem Windows platform files
set ExcludeObj=%ExcludeObj% -xr!*.exe
set ExcludeObj=%ExcludeObj% -xr!*.bat

call Get_7-Zip_Path.bat

path %Path_7-Zip%;%path%

pushd "%~dp0"

for /f "delims=" %%A in ("%cd%") do Set FolderName=%%~nA

del /a /f /q "%FolderName%.tar" 2>nul

7z.exe a -ttar %FolderName%.tar * %ExcludeObj%

popd

timeout 99
