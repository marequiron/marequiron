@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
set "SELF=%~f0"
call "%ROOT%\actions\lib.bat" log "Cleanup opened (arg=%~1)"
if not "%~1"=="" goto :direct

:menu
cls
echo ============================================================
echo  DISK ^& TEMP CLEANUP
echo ============================================================
echo   [1]  Clear user temp folder      %TEMP%
echo   [2]  Clear Windows temp folder   (admin)
echo   [3]  Empty Recycle Bin
echo   [4]  Clear Windows Update cache  (admin)
echo   [5]  Run everything
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
goto :done

:done
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 exit /b 0
echo.
echo  Elevated run finished - press Enter to close.
set /p "=  "
exit /b 0

:item1
set "ANS="
set /p "ANS=  Delete temporary files in %TEMP% ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & call "%ROOT%\actions\lib.bat" log "Cleanup user temp cancelled" & exit /b 0)
echo  Working...
set "FREED="
for /f %%s in ('powershell -NoProfile -Command "$b=[int64]0;$s=(Get-ChildItem -LiteralPath $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum;if($s){$b=[int64]$s};Get-ChildItem -LiteralPath $env:TEMP -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue;$s=(Get-ChildItem -LiteralPath $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum;$a=[int64]0;if($s){$a=[int64]$s};[string]([int64](($b-$a)/1MB))"') do set "FREED=%%s"
if not defined FREED set "FREED=0"
echo  Done - about %FREED% MB freed.
call "%ROOT%\actions\lib.bat" log "Cleanup user temp completed, freed ~%FREED% MB"
exit /b 0

:item2
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 (call :elevate 2 & exit /b 0)
set "ANS="
set /p "ANS=  Delete temporary files in %windir%\Temp ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & exit /b 0)
echo  Working...
set "FREED="
for /f %%s in ('powershell -NoProfile -Command "$p=Join-Path $env:windir Temp;$b=[int64]0;$s=(Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum;if($s){$b=[int64]$s};Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue;$s=(Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum;$a=[int64]0;if($s){$a=[int64]$s};[string]([int64](($b-$a)/1MB))"') do set "FREED=%%s"
if not defined FREED set "FREED=0"
echo  Done - about %FREED% MB freed.
call "%ROOT%\actions\lib.bat" log "Cleanup windows temp completed, freed ~%FREED% MB"
exit /b 0

:item3
set "ANS="
set /p "ANS=  Empty the Recycle Bin ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & call "%ROOT%\actions\lib.bat" log "Recycle bin empty cancelled" & exit /b 0)
powershell -NoProfile -Command "Clear-RecycleBin -Force -Confirm:$false -ErrorAction SilentlyContinue; '  Recycle Bin emptied.'"
call "%ROOT%\actions\lib.bat" log "Recycle bin emptied"
exit /b 0

:item4
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 (call :elevate 4 & exit /b 0)
set "ANS="
set /p "ANS=  Clear the Windows Update download cache ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & exit /b 0)
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
set "FREED="
for /f %%s in ('powershell -NoProfile -Command "$p=Join-Path $env:windir SoftwareDistribution;$p=Join-Path $p Download;$b=[int64]0;$s=(Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum;if($s){$b=[int64]$s};Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue;$s=(Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum;$a=[int64]0;if($s){$a=[int64]$s};[string]([int64](($b-$a)/1MB))"') do set "FREED=%%s"
if not defined FREED set "FREED=0"
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
net start dosvc >nul 2>&1
echo  Done - about %FREED% MB freed, services restarted.
call "%ROOT%\actions\lib.bat" log "Windows Update cache cleared, freed ~%FREED% MB"
exit /b 0

:item5
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 (call :elevate 5 & exit /b 0)
call :item1
call :item2
call :item3
call :item4
exit /b 0

:elevate
echo.
echo  [i] Administrator rights are required for this step.
echo  [i] Accept the UAC prompt to continue in a new window.
powershell -NoProfile -Command "Start-Process -FilePath '%SELF%' -ArgumentList '%~1' -Verb RunAs" >nul 2>&1
call "%ROOT%\actions\lib.bat" log "Cleanup: elevation requested for item %~1"
exit /b 0
