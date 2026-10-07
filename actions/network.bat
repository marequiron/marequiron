@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
set "SELF=%~f0"
call "%ROOT%\actions\lib.bat" log "Network opened (arg=%~1)"
if not "%~1"=="" goto :direct

:menu
cls
echo ============================================================
echo  NETWORK INFO ^& REFRESH
echo ============================================================
echo   [1]  Show network information
echo   [2]  Show Wi-Fi interfaces ^& profiles
echo   [3]  Flush DNS cache
echo   [4]  Release and renew IP address   (admin)
echo   [0]  Back
echo ============================================================
set "CHOICE="
set /p "CHOICE=Select an action: "
if "%CHOICE%"=="0" exit /b 0
if "%CHOICE%"=="1" (call :item1 & goto :menu)
if "%CHOICE%"=="2" (call :item2 & goto :menu)
if "%CHOICE%"=="3" (call :item3 & goto :menu)
if "%CHOICE%"=="4" (call :item4 & goto :menu)
echo.
echo  [!] Invalid choice.
timeout /t 2 >nul 2>&1
goto :menu

:direct
if "%~1"=="1" (call :item1 & goto :done)
if "%~1"=="2" (call :item2 & goto :done)
if "%~1"=="3" (call :item3 & goto :done)
if "%~1"=="4" (call :item4 & goto :done)
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
echo --- ipconfig ---
ipconfig
echo.
echo --- IPv4 addresses ---
powershell -NoProfile -Command "$ips=Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike '169.254*' -and $_.IPAddress -ne '127.0.0.1'}; if($ips){$ips | ForEach-Object { '{0,-30} {1}' -f $_.IPAddress,$_.InterfaceAlias }} else {'No IPv4 addresses found.'}"
echo.
echo --- DNS servers ---
powershell -NoProfile -Command "Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.ServerAddresses} | ForEach-Object { '{0,-30} {1}' -f $_.InterfaceAlias,($_.ServerAddresses -join ', ') }"
call "%ROOT%\actions\lib.bat" log "Network info displayed"
exit /b 0

:item2
echo.
echo --- Current wireless interface ---
netsh wlan show interfaces
if errorlevel 1 echo  [i] Some interface details need Administrator rights or Location services.
echo.
echo --- Saved Wi-Fi profiles ---
netsh wlan show profiles
if errorlevel 1 echo  [i] No Wi-Fi profiles found.
call "%ROOT%\actions\lib.bat" log "Wi-Fi info displayed"
exit /b 0

:item3
echo  Flushing DNS resolver cache...
ipconfig /flushdns
if not errorlevel 1 goto :flushok
echo  [!] Flush failed - Administrator rights may be required.
set "ANS="
set /p "ANS=  Retry elevated ? [y/N] "
if /i "%ANS%"=="y" (call :elevate 3 & exit /b 0)
exit /b 0
:flushok
echo  Done - DNS cache flushed.
call "%ROOT%\actions\lib.bat" log "DNS cache flushed"
exit /b 0

:item4
call "%ROOT%\actions\lib.bat" admin
if errorlevel 1 (call :elevate 4 & exit /b 0)
echo  [!] This releases your IP and reconnects all adapters.
echo  [!] Active downloads and connections will drop.
set "ANS="
set /p "ANS=  Release and renew IP now ? [y/N] "
if /i not "%ANS%"=="y" (echo  Cancelled. & exit /b 0)
echo  Releasing current IP...
ipconfig /release
echo  Requesting a new IP...
ipconfig /renew
ipconfig /flushdns >nul 2>&1
echo  Done.
call "%ROOT%\actions\lib.bat" log "IP release/renew completed"
exit /b 0

:elevate
echo.
echo  [i] Administrator rights are required for this step.
echo  [i] Accept the UAC prompt to continue in a new window.
powershell -NoProfile -Command "Start-Process -FilePath '%SELF%' -ArgumentList '%~1' -Verb RunAs" >nul 2>&1
call "%ROOT%\actions\lib.bat" log "Network: elevation requested for item %~1"
exit /b 0
