@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
set "SELF=%~f0"
call "%ROOT%\actions\lib.bat" log "Process tools opened (arg=%~1 %~2)"
if not "%~1"=="" goto :direct

:menu
cls
echo ============================================================
echo  PROCESS ^& SERVICE TOOLS
echo ============================================================
echo   [1]  Top 10 processes by memory
echo   [2]  Top 10 processes by CPU time
echo   [3]  Kill a process by name
echo   [4]  List running services
echo   [5]  Check a service status
echo   [6]  Start a service             (admin)
echo   [7]  Stop a service              (admin)
echo   [8]  Restart this tool as Administrator
echo   [0]  Back
echo ============================================================
set "CHOICE="
set /p "CHOICE=Select an action: "
if "%CHOICE%"=="0" exit /b 0
if "%CHOICE%"=="1" (call :item1 & goto :menu)
if "%CHOICE%"=="2" (call :item2 & goto :menu)
if "%CHOICE%"=="3" (call :item3 & goto :menu)
if "%CHOICE%"=="4" (call :item4 & goto :menu)
if "%CHOICE%"=="5" (call :item5 & goto :menu)
if "%CHOICE%"=="6" (call :item6 "" & goto :menu)
if "%CHOICE%"=="7" (call :item7 "" & goto :menu)
if "%CHOICE%"=="8" (call :item8 & goto :menu)
echo.
echo  [!] Invalid choice.
timeout /t 2 >nul 2>&1
goto :menu

:direct
if "%~1"=="1" (call :item1 & goto :done)
if "%~1"=="2" (call :item2 & goto :done)
if "%~1"=="3" (call :item3 & goto :done)
if "%~1"=="4" (call :item4 & goto :done)
if "%~1"=="5" (call :item5 & goto :done)
if "%~1"=="6" (call :item6 "%~2" & goto :done)
if "%~1"=="7" (call :item7 "%~2" & goto :done)
goto :done

:done
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 exit /b 0
echo.
echo  Elevated run finished - press Enter to close.
set /p "=  "
exit /b 0

:item1
echo.
powershell -NoProfile -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 | Format-Table Id,ProcessName,@{n='MB';e={[int]($_.WorkingSet64/1MB)}} -AutoSize | Out-String -Width 120"
call "%ROOT%\actions\lib.bat" log "Top memory processes displayed"
exit /b 0

:item2
echo.
powershell -NoProfile -Command "Get-Process | Where-Object {$null -ne $_.CPU} | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table Id,ProcessName,@{n='CPU sec';e={[math]::Round($_.CPU,1)}} -AutoSize | Out-String -Width 120"
call "%ROOT%\actions\lib.bat" log "Top CPU processes displayed"
exit /b 0

:item3
set "PN="
set /p "PN=  Process name to kill (e.g. notepad.exe): "
if not defined PN (echo  Cancelled. & exit /b 0)
tasklist /fi "imagename eq %PN%" 2>nul | findstr /i /c:"%PN%" >nul
if errorlevel 1 (echo  [!] No process named "%PN%" is running. & exit /b 0)
set "ANS="
set /p "ANS=  Really kill %PN% ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & exit /b 0)
taskkill /f /im "%PN%"
if errorlevel 1 echo  [!] Could not kill it - some processes need Administrator rights.
call "%ROOT%\actions\lib.bat" log "Attempted to kill process %PN%"
exit /b 0

:item4
echo.
echo --- Running services ---
net start
call "%ROOT%\actions\lib.bat" log "Running services listed"
exit /b 0

:item5
set "SVC="
set /p "SVC=  Service short name (e.g. wuauserv): "
if not defined SVC (echo  Cancelled. & exit /b 0)
echo.
sc query "%SVC%"
if errorlevel 1060 echo  [!] Service "%SVC%" was not found.
call "%ROOT%\actions\lib.bat" log "Checked service %SVC%"
exit /b 0

:item6
set "SVC=%~1"
if not defined SVC set /p "SVC=  Service short name to start (no spaces): "
if not defined SVC (echo  Cancelled. & exit /b 0)
call :validsvc
if errorlevel 1 exit /b 0
sc query "%SVC%" >nul 2>&1
if errorlevel 1060 (echo  [!] Service "%SVC%" was not found. & exit /b 0)
set "ANS="
set /p "ANS=  Start service %SVC% ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & exit /b 0)
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 (call :elevate 6 "%SVC%" & exit /b 0)
net start "%SVC%"
call "%ROOT%\actions\lib.bat" log "Started service %SVC%"
exit /b 0

:item7
set "SVC=%~1"
if not defined SVC set /p "SVC=  Service short name to stop (no spaces): "
if not defined SVC (echo  Cancelled. & exit /b 0)
call :validsvc
if errorlevel 1 exit /b 0
sc query "%SVC%" >nul 2>&1
if errorlevel 1060 (echo  [!] Service "%SVC%" was not found. & exit /b 0)
set "ANS="
set /p "ANS=  Stop service %SVC% ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & exit /b 0)
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 (call :elevate 7 "%SVC%" & exit /b 0)
net stop "%SVC%"
call "%ROOT%\actions\lib.bat" log "Stopped service %SVC%"
exit /b 0

:item8
echo.
echo  [i] Launching a new Administrator instance...
powershell -NoProfile -Command "Start-Process -FilePath '%ROOT%\OneClick.bat' -Verb RunAs" >nul 2>&1
call "%ROOT%\actions\lib.bat" log "Relaunched tool as Administrator"
echo  [i] Close this window and use the new one.
exit /b 0

:validsvc
echo(%SVC%| findstr /r /x "[A-Za-z0-9][A-Za-z0-9_.-]*" >nul
if errorlevel 1 (
  echo  [!] Use the short service name: letters, digits, dot, dash only - no spaces.
  exit /b 1
)
exit /b 0

:elevate
echo.
echo  [i] Administrator rights are required for this step.
echo  [i] Accept the UAC prompt to continue in a new window.
powershell -NoProfile -Command "Start-Process -FilePath '%SELF%' -ArgumentList '%~1','%~2' -Verb RunAs" >nul 2>&1
call "%ROOT%\actions\lib.bat" log "Processes: elevation requested for %~1 %~2"
exit /b 0
