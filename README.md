# One-Click Toolbox

A single double-click (`OneClick.bat`) opens a menu of safe, local actions for
this Windows machine. Everything runs locally - no remote hosts, no cloud calls.

## Quick start

Double-click **`OneClick.bat`**. Pick a number, press Enter. Actions that need
Administrator rights trigger a UAC prompt and continue in an elevated window.

## Menu

| # | Action | What it does |
|---|--------|--------------|
| 1 | System info summary | OS, CPU, RAM, disk space, uptime, top memory processes, IPv4 addresses |
| 2 | Disk & temp cleanup | User temp, Windows temp, Recycle Bin, Windows Update cache (each asks Y/N first) |
| 3 | Network info & refresh | ipconfig, DNS servers, Wi-Fi profiles, flush DNS, release/renew IP |
| 4 | App launcher | Detects installed apps (Edge, Chrome, Firefox, VS Code, Notepad++, Office, Windows Terminal, PowerShell 7) and launches them |
| 5 | Process & service tools | Top processes by memory/CPU, kill a process, list/check/start/stop services, restart tool as admin |
| 6 | Custom command runner | Runs numbered commands from `config\custom_commands.txt`, or any command you type |

## Files

```
OneClick.bat                 main menu (double-click this)
actions\sysinfo.bat          menu option 1
actions\cleanup.bat          menu option 2
actions\network.bat          menu option 3
actions\launcher.bat         menu option 4
actions\processes.bat        menu option 5
actions\custom.bat           menu option 6
actions\lib.bat              shared helpers (logging, admin check)
config\custom_commands.txt   your custom commands (edit with menu 6 -> E)
logs\                        one log file per menu session (not in git)
```

## Custom commands

Edit `config\custom_commands.txt` - one command per line, `#` starts a
comment. Save the file and the menu refreshes next time it opens. Avoid `!`
characters in commands.

## Direct action arguments (optional)

Each action script accepts its menu number as an argument, which is also how
elevated windows re-run a single step:

```bat
actions\sysinfo.bat
actions\cleanup.bat 1        (1-5, see cleanup menu)
actions\network.bat 3        (1-4, see network menu)
actions\processes.bat 1      (1-8, see processes menu)
```

## Requirements

- Windows 10 or 11
- PowerShell 5.1 (built in)
- Administrator rights only for: Windows temp, Windows Update cache,
  IP release/renew, service start/stop

## License

MIT - see [LICENSE](LICENSE).
