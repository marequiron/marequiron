@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
set "CONFIG=%ROOT%\config\custom_commands.txt"
if not exist "%CONFIG%" (
  echo  [!] Config file not found: %CONFIG%
  timeout /t 3 >nul 2>&1
  exit /b 0
)

setlocal EnableDelayedExpansion
set "N=0"
for /f "usebackq eol=# delims=" %%c in ("%CONFIG%") do (
  set "line=%%c"
  if not "!line!"=="" (
    set /a N+=1
    set "CUST_!N!=!line!"
  )
)
if "%N%"=="0" (
  setlocal DisableDelayedExpansion
  echo  [!] No commands defined in config\custom_commands.txt
  endlocal
  timeout /t 3 >nul 2>&1
  exit /b 0
)

:show
cls
echo ============================================================
echo  CUSTOM COMMAND RUNNER
echo ============================================================
set /a I=1
:showloop
if not defined CUST_%I% goto :showloop_end
echo   [%I%]  !CUST_%I%!
set /a I+=1
goto :showloop
:showloop_end
set /a LAST=I-1
echo   [R]  Type a command to run
echo   [E]  Edit config\custom_commands.txt
echo   [0]  Back
echo ============================================================
set "CHOICE="
set /p "CHOICE=Select an action: "
if "%CHOICE%"=="0" exit /b 0
if /i "%CHOICE%"=="R" goto :typed
if /i "%CHOICE%"=="E" goto :edit
echo(%CHOICE%| findstr /r /x "[0-9][0-9]*" >nul
if errorlevel 1 goto :badchoice
if %CHOICE% LSS 1 goto :badchoice
if %CHOICE% GTR %LAST% goto :badchoice
echo.
echo  Running: !CUST_%CHOICE%!
call "%ROOT%\actions\lib.bat" log "Ran custom command %CHOICE%"
set "CMD=!CUST_%CHOICE%!"
setlocal DisableDelayedExpansion
call %CMD%
set "RC=%ERRORLEVEL%"
endlocal & set "RC=%RC%"
echo.
echo  [Command finished with code %RC%]
timeout /t 1 >nul 2>&1
goto :show

:typed
set "CMD="
set /p "CMD=  Enter a command: "
if not defined CMD exit /b 0
call "%ROOT%\actions\lib.bat" log "Ran typed command"
setlocal DisableDelayedExpansion
call %CMD%
set "RC=%ERRORLEVEL%"
endlocal & set "RC=%RC%"
echo.
echo  [Command finished with code %RC%]
timeout /t 1 >nul 2>&1
goto :show

:edit
start "" notepad "%CONFIG%"
timeout /t 2 >nul 2>&1
goto :show

:badchoice
echo.
setlocal DisableDelayedExpansion
echo  [!] Invalid choice - try again.
endlocal
timeout /t 2 >nul 2>&1
goto :show
