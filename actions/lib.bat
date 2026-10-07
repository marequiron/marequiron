@echo off
if /i "%~1"=="log" goto :logline
if /i "%~1"=="admin" goto :checkadmin
exit /b 1

:logline
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
if not defined LOGFILE set "LOGFILE=%ROOT%\logs\session.log"
if not exist "%ROOT%\logs" mkdir "%ROOT%\logs"
>>"%LOGFILE%" echo [%date% %time%] %~2
exit /b 0

:checkadmin
powershell -NoProfile -Command "exit ([int](-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))"
exit /b %errorlevel%
