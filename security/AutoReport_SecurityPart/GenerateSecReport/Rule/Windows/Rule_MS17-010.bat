@echo off
SetLocal EnableDelayedExpansion
rem rule MS17-010

rem Windows SMB Server (RCE)

rem This security update resolves vulnerabilities in Microsoft Windows. The most severe of the vulnerabilities could
rem allow remote code execution if an attacker sends specially crafted messages to a Microsoft Server Message Block 1.0 (SMBv1) server.

set Affected=1
set NotAffected=0

set InsInfoFile=%~1

rem Affected All windows

set Return=%NotAffected%

rem we will check windows update status later
set Return=%Affected%

exit/b %Return%
