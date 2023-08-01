@echo off

chcp 437 >nul
setLocal EnableDelayedExpansion

set winAdminUsers=

for /f "usebackq delims=" %%A in (`net localgroup Administrators^|findstr /v /r /i /c:"^Alias name"^|findstr /v /r /i /c:"^Comment"^|findstr /v /r /i /c:"^Members"^|findstr /v /r /i /c:"^The command completed successfully."^|findstr /v /r /i /c:"^-------------------------------"`) do (
	set winAdminUsers=!winAdminUsers!;%%~A
)

echo !CommonInfo!!winAdminUsers:~1!> "%UploadDir%\UserWinAdmin.csv"
