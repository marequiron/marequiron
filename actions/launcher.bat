@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
call "%ROOT%\actions\lib.bat" log "Launcher opened"

set "N=0"
call :try "Windows Explorer" "%SystemRoot%\explorer.exe"
call :try "Microsoft Edge" "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
call :try "Microsoft Edge" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
call :try "Google Chrome" "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
call :try "Google Chrome" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
call :try "Google Chrome" "%LocalAppData%\Google\Chrome\Application\chrome.exe"
call :try "Mozilla Firefox" "%ProgramFiles%\Mozilla Firefox\firefox.exe"
call :try "Mozilla Firefox" "%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe"
call :try "Visual Studio Code" "%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
call :try "Visual Studio Code" "%ProgramFiles%\Microsoft VS Code\Code.exe"
call :try "Visual Studio Code" "%ProgramFiles(x86)%\Microsoft VS Code\Code.exe"
call :try "Notepad++" "%ProgramFiles%\Notepad++\notepad++.exe"
call :try "Notepad++" "%ProgramFiles(x86)%\Notepad++\notepad++.exe"
call :try "Word" "%ProgramFiles%\Microsoft Office\root\Office16\WINWORD.EXE"
call :try "Word" "%ProgramFiles(x86)%\Microsoft Office\root\Office16\WINWORD.EXE"
call :try "Excel" "%ProgramFiles%\Microsoft Office\root\Office16\EXCEL.EXE"
call :try "Excel" "%ProgramFiles(x86)%\Microsoft Office\root\Office16\EXCEL.EXE"
call :try "PowerPoint" "%ProgramFiles%\Microsoft Office\root\Office16\POWERPNT.EXE"
call :try "Outlook" "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE"
where /q wt.exe
if not errorlevel 1 call :whereTry "Windows Terminal" wt.exe
where /q pwsh.exe
if not errorlevel 1 call :whereTry "PowerShell 7" pwsh.exe

if "%N%"=="0" (
  echo.
  echo  [!] No supported applications were detected.
  timeout /t 3 >nul 2>&1
  exit /b 0
)

setlocal EnableDelayedExpansion

:show
cls
echo ============================================================
echo  APP LAUNCHER
echo ============================================================
set /a I=1
:showloop
if not defined APP_%I%_NAME goto :showloop_end
echo   [%I%]  !APP_%I%_NAME!   -   !APP_%I%_PATH!
set /a I+=1
goto :showloop
:showloop_end
set /a LAST=I-1
echo   [0]  Back
echo ============================================================
set "CHOICE="
set /p "CHOICE=Launch which one (0-%LAST%)? "
if "%CHOICE%"=="0" exit /b 0
echo(%CHOICE%| findstr /r /x "[0-9][0-9]*" >nul
if errorlevel 1 goto :badchoice
if %CHOICE% LSS 1 goto :badchoice
if %CHOICE% GTR %LAST% goto :badchoice
echo  Starting !APP_%CHOICE%_NAME!...
start "" "!APP_%CHOICE%_PATH!"
call "%ROOT%\actions\lib.bat" log "Launched !APP_%CHOICE%_NAME!"
timeout /t 2 >nul 2>&1
goto :show

:badchoice
echo.
setlocal DisableDelayedExpansion
echo   [!] Invalid choice - try again.
endlocal
timeout /t 2 >nul 2>&1
goto :show

:try
if not exist "%~2" exit /b 0
set /a N+=1
set "APP_%N%_NAME=%~1"
set "APP_%N%_PATH=%~2"
exit /b 0

:whereTry
set /a N+=1
set "APP_%N%_NAME=%~1"
for /f "delims=" %%w in ('where %~2') do (
  set "APP_%N%_PATH=%%w"
  goto :whereDone
)
:whereDone
exit /b 0
