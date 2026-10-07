@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined ROOT for %%r in ("%~dp0..") do set "ROOT=%%~fr"
call "%ROOT%\actions\lib.bat" log "System info requested"

cls
echo ============================================================
echo  SYSTEM INFO SUMMARY   %COMPUTERNAME%   %date% %time%
echo ============================================================
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $cs=Get-CimInstance Win32_ComputerSystem; $cpu=Get-CimInstance Win32_Processor; ''; 'Operating system : {0} {1}' -f $os.Caption,$os.OSArchitecture; 'Version          : {0} (build {1})' -f $os.Version,$os.BuildNumber; 'Install date     : {0}' -f $os.InstallDate; 'Last boot        : {0}' -f $os.LastBootUpTime; $ts=(Get-Date)-$os.LastBootUpTime; 'Uptime           : {0}d {1}h {2}m' -f $ts.Days,$ts.Hours,$ts.Minutes; 'CPU              : {0}' -f (($cpu.Name) -join ', '); 'Cores / logical  : {0} / {1}' -f (($cpu | Measure-Object NumberOfCores -Sum).Sum),(($cpu | Measure-Object NumberOfLogicalProcessors -Sum).Sum); 'Memory           : {0:N1} GB total / {1:N1} GB free' -f ($cs.TotalPhysicalMemory/1GB),($os.FreePhysicalMemory*1KB/1GB); 'User / domain    : {0} on {1}' -f $env:USERNAME,$env:USERDOMAIN; ''; '--- Fixed disks ---'; Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { if($_.Size){ '{0}   {1:N1} GB free of {2:N1} GB   ({3} percent free)' -f $_.DeviceID,($_.FreeSpace/1GB),($_.Size/1GB),[int](100*$_.FreeSpace/$_.Size) } }; ''; '--- Top 5 memory processes ---'; Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 | ForEach-Object { '{0,-30} {1,8} MB' -f $_.ProcessName,[int]($_.WorkingSet64/1MB) }"
echo.
powershell -NoProfile -Command "$ips=Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike '169.254*' -and $_.IPAddress -ne '127.0.0.1'}; if($ips){'--- IPv4 addresses ---'; $ips | ForEach-Object { '{0,-30} {1}' -f $_.IPAddress,$_.InterfaceAlias }} else {'No IPv4 addresses found.'}"
echo.
echo  Log file: %LOGFILE%
call "%ROOT%\actions\lib.bat" log "System info completed"
