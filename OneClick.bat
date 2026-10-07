@echo off
setlocal EnableExtensions DisableDelayedExpansion
title One-Click Toolbox
color 0A
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
if not exist "%ROOT%\logs" mkdir "%ROOT%\logs"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%i"
set "LOGFILE=%ROOT%\logs\run_%STAMP%.log"
call "%ROOT%\actions\lib.bat" log "Session started on %COMPUTERNAME% as %USERNAME%"

:menu
cls
echo ============================================================
echo    ONE-CLICK TOOLBOX   -   %COMPUTERNAME%
echo ============================================================
echo    [1]  System info summary
echo    [2]  Disk ^& temp cleanup
echo    [3]  Network info ^& refresh
echo    [4]  App launcher
echo    [5]  Process ^& service tools
echo    [6]  Custom command runner
echo    [0]  Exit
echo ============================================================
set "CHOICE="
set /p "CHOICE=Select an action: "
if "%CHOICE%"=="1" (call "%ROOT%\actions\sysinfo.bat" & goto :after)
if "%CHOICE%"=="2" (call "%ROOT%\actions\cleanup.bat" & goto :after)
if "%CHOICE%"=="3" (call "%ROOT%\actions\network.bat" & goto :after)
if "%CHOICE%"=="4" (call "%ROOT%\actions\launcher.bat" & goto :after)
if "%CHOICE%"=="5" (call "%ROOT%\actions\processes.bat" & goto :after)
if "%CHOICE%"=="6" (call "%ROOT%\actions\custom.bat" & goto :after)
if "%CHOICE%"=="0" exit /b 0
echo.
echo  [!] Invalid choice "%CHOICE%" - try again.
timeout /t 2 >nul 2>&1
goto :menu

:after
echo.
set /p "=  Press Enter to return to the menu..."
echo.
goto :menu
